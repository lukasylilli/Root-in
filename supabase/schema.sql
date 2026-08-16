-- Root-in — Server-Schema und Zugriffsregeln (PLAN.md Phase 27.4)
--
-- ANWENDEN: Supabase-Projekt öffnen → SQL Editor → diese Datei einfügen →
-- ausführen. Sie ist mehrfach ausführbar (idempotent).
--
-- WARUM DIESE DATEI IM REPOSITORY LIEGT
-- Die Struktur eines Servers, die nur in einer Weboberfläche existiert, kann
-- niemand versionieren, gegenlesen oder nach einem Unfall wiederherstellen.
-- Hier steht sie neben dem Code, der sie benutzt.
--
-- ⚠️ DAS PROJEKT IST OPEN SOURCE — jeder liest diese Datei.
-- Das ist bei Row Level Security vorgesehen: Die Regeln sind kein Geheimnis,
-- sie sind ein Mechanismus. Aber es heißt, dass sie wirklich stimmen müssen.
-- Auf Unkenntnis des Angreifers ist kein Verlass.
--
-- ⚠️ ZWEI SCHLÜSSEL, ZWEI WELTEN
--   anon / public  → steht in der App, ist auslesbar, DARF öffentlich sein.
--                    Für ihn gelten die Regeln unten.
--   service_role   → umgeht JEDE Regel hier. Gehört ausschließlich in die
--                    Supabase-Oberfläche. Niemals in App, Repository oder CI.

-- ---------------------------------------------------------------------------
-- 1. Profil
-- ---------------------------------------------------------------------------
-- Eine Zeile je Konto.
--
-- E-Mail und Passwort verwaltet Supabase in `auth.users` — sie werden hier
-- BEWUSST NICHT wiederholt. Eine zweite Kopie der Adresse wäre eine zweite
-- Stelle, die veralten kann, und ein zweiter Ort, an dem sie auslaufen kann.
--
-- Der Benutzername gehört uns: Er ist der Name IN der App, nicht die Kennung,
-- mit der man sich anmeldet (PLAN.md 27.5).
create table if not exists public.profiles (
  user_id      uuid primary key references auth.users (id) on delete cascade,
  username     text,
  display_name text,
  updated_at   timestamptz not null default now()
);

-- Nachrüstbar auf einer Datenbank, die schon nach der alten Fassung angelegt
-- wurde (Benutzername kam erst mit dem Wechsel auf echte E-Mails dazu).
alter table public.profiles add column if not exists username text;

-- ⚠️ EINDEUTIGKEIT AUF DEM KLEINGESCHRIEBENEN NAMEN, nicht auf dem rohen.
-- Sonst wären „Ali" und „ali" zwei Konten, und die Zusage „der Name gehört
-- genau einem Menschen" wäre keine. Die App normalisiert vorher genauso
-- (`lib/core/services/username_rules.dart`) — beide Seiten müssen dieselbe
-- Regel anwenden, sonst hält eine von beiden sie nicht ein.
create unique index if not exists profiles_username_lower_key
  on public.profiles (lower(username))
  where username is not null;

-- ---------------------------------------------------------------------------
-- 2. Sicherung des Bestands
-- ---------------------------------------------------------------------------
-- GENAU EINE Zeile je Konto — deshalb ist `user_id` der Primärschlüssel und
-- nicht nur ein Verweis. Eine Sicherung ist ein Stand, keine Historie; ohne
-- diese Einschränkung sammelten sich stillschweigend Kopien an, und niemand
-- wüsste, welche gilt.
--
-- `payload` ist das Backup-JSON aus `lib/data/models/backup_data.dart` —
-- dieselbe Serialisierung wie Export/Import, kein zweites Format
-- (PLAN.md Abschnitt 9, „Puzzling"/DRY).
--
-- `schema_version` ist die Version DIESES JSON-Formats, nicht die der
-- lokalen Datenbank. Sie entscheidet, ob eine ältere App eine neuere
-- Sicherung ablehnen muss, statt sie falsch zu lesen.
create table if not exists public.backups (
  user_id        uuid primary key references auth.users (id) on delete cascade,
  payload        jsonb       not null,
  schema_version integer     not null,
  device_label   text,
  updated_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3. Row Level Security
-- ---------------------------------------------------------------------------
-- ⚠️ OHNE DIESE ZEILEN IST JEDE TABELLE OBEN FÜR JEDEN LESBAR UND SCHREIBBAR.
-- Der anon-Schlüssel steht in der ausgelieferten App; er ist kein Schutz.
-- RLS ist der einzige Schutz. Deshalb steht es hier direkt hinter dem
-- Anlegen der Tabellen und nicht in einem späteren Schritt.
alter table public.profiles enable row level security;
alter table public.backups  enable row level security;

-- Eine Regel je Vorgang statt einer „for all"-Regel: So steht jede erlaubte
-- Handlung ausdrücklich da, und ein späteres Weglassen fällt beim Lesen auf.
-- `auth.uid()` ist die Kennung aus dem mitgeschickten Token — ohne Anmeldung
-- ist sie null, und dann trifft keine Regel zu (die Tabelle bleibt leer).

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = user_id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = user_id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "profiles_delete_own" on public.profiles;
create policy "profiles_delete_own" on public.profiles
  for delete using (auth.uid() = user_id);

drop policy if exists "backups_select_own" on public.backups;
create policy "backups_select_own" on public.backups
  for select using (auth.uid() = user_id);

drop policy if exists "backups_insert_own" on public.backups;
create policy "backups_insert_own" on public.backups
  for insert with check (auth.uid() = user_id);

drop policy if exists "backups_update_own" on public.backups;
create policy "backups_update_own" on public.backups
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "backups_delete_own" on public.backups;
create policy "backups_delete_own" on public.backups
  for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 4. `updated_at` schreibt der Server, nicht die App
-- ---------------------------------------------------------------------------
-- Eine von der App gesetzte Zeit ist die Zeit einer möglicherweise falsch
-- gestellten Geräteuhr — dieselbe Sorge, aus der `time_service.dart`
-- entstanden ist. „Zuletzt gesichert vor …" muss sich auf eine Uhr stützen,
-- die der Nutzer nicht stellen kann.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before insert or update on public.profiles
  for each row execute function public.touch_updated_at();

drop trigger if exists backups_touch_updated_at on public.backups;
create trigger backups_touch_updated_at
  before insert or update on public.backups
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- 5. Ist ein Benutzername noch frei?
-- ---------------------------------------------------------------------------
-- Reine Höflichkeit für die Registrierung: Der Fehler soll kommen, BEVOR der
-- Nutzer auf „Registrieren" tippt — nicht danach, wenn das Konto schon
-- angelegt ist.
--
-- ⚠️ DIE WAHRHEIT IST DER EINDEUTIGE INDEX OBEN, NICHT DIESE FUNKTION.
-- Zwischen der Frage und dem Absenden kann jemand anders denselben Namen
-- nehmen. Die App muss den Fehlschlag beim Schreiben also trotzdem behandeln;
-- diese Funktion erspart ihn nur im Normalfall.
--
-- `security definer` ist nötig, weil RLS sonst nur die EIGENE Profilzeile
-- sichtbar macht — eine Prüfung auf fremde Namen käme immer „frei" zurück.
-- Zurück kommt ausschließlich ja/nein: keine Adresse, keine Kennung, kein
-- fremdes Profil. Wer den anon-Schlüssel hat, kann damit ausprobieren, ob ein
-- Name existiert — das ist bei jeder Registrierung dieser Welt so und der
-- Preis dafür, dem Nutzer „Name schon vergeben" sagen zu können.
create or replace function public.username_available(candidate text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select not exists (
    select 1 from public.profiles
     where lower(username) = lower(trim(candidate))
  );
$$;

revoke all on function public.username_available(text) from public;
grant execute on function public.username_available(text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 6. Konto löschen
-- ---------------------------------------------------------------------------
-- `on delete cascade` oben räumt Profil und Sicherung ab, sobald der Eintrag
-- in `auth.users` verschwindet. Das Löschen des Kontos selbst kann der
-- anon-Schlüssel NICHT auslösen — dafür braucht es einen Aufruf mit erhöhten
-- Rechten (Edge Function). Solange es den nicht gibt, ist „Konto löschen" in
-- der App ein Löschen der Daten plus Abmelden; der leere Auth-Eintrag bleibt.
-- ⚠️ Das ist für 27.8 zu klären, nicht zu vergessen: Ein Konto, das man nicht
-- loswird, ist ein Datenschutz-Problem.

-- ---------------------------------------------------------------------------
-- 7. Gegenprobe (PLAN.md 27.4) — nach dem Anwenden ausführen
-- ---------------------------------------------------------------------------
-- Muss beide Tabellen mit rowsecurity = true zeigen. Steht dort false, ist
-- die Tabelle offen, und der Rest dieser Datei ist wirkungslos.
--
--   select tablename, rowsecurity
--     from pg_tables
--    where schemaname = 'public';
--
-- Die eigentliche Probe läuft aber NICHT hier, sondern von außen mit dem
-- anon-Schlüssel: ohne Anmeldung lesen (muss leer bleiben) und als Konto A
-- die Zeilen von Konto B abfragen (muss leer bleiben). Ein `select` im
-- SQL-Editor läuft mit erhöhten Rechten und umgeht die Regeln — er beweist
-- an dieser Stelle also gar nichts.

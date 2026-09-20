# Root-in — Habit Maker / Routine Tracker — Projektplan

> Lebendiges Dokument. Wird bei jeder relevanten Änderung am Projekt aktualisiert.
>
> 🧭 **Arbeitsweise in jedem neuen Chat (feste Regel von Lukas, 2026-09-18) — nicht entfernen.**
> Claude hat zwischen Chats kein Gedächtnis; **diese vier Dateien SIND das Gedächtnis des Projekts:**
> `Root-in/PLAN.md` · `Root-in/MAP.md` · `vox/PLAN.md` · `vox/PROJECT_MAP.md`.
> **1 — Zu Beginn jedes Chats:** alle vier **frisch von GitHub** lesen (api.github.com, Branch main), nie aus dem Gedächtnis.
> **2 — Danach:** den ersten offenen Schritt suchen und ohne Rückfrage erledigen.
> **3 — Am Ende jeder Arbeit (und jedes Chats):** in PLAN und MAP **desselben** Repos einen kurzen Eintrag schreiben —
> was, warum, in welcher Datei/Phase — und die Zeile „Letzte Sitzung / nächster Schritt" unten aktualisieren.
> **Was nicht in PLAN und MAP steht, existiert für den nächsten Chat nicht.** Inhaltsverzeichnis und Hinweise bleiben erhalten.
>
> 🗓️ **Letzte Sitzung:** 2026-09-20 — an Root-in **nichts geändert**; nur vermerkt, was in Vox passiert ist und Root-in berührt: Vox hat jetzt eine Profil-Seite
> mit **Passwort ändern, E-Mail ändern, „Passwort vergessen" und „auf allen Geräten abmelden"**. ⚠️ `auth.users` ist geteilt — **jede Änderung von Passwort oder E-Mail in Vox gilt
> auch in Root-in** (Vox sagt das dem Nutzer). Umgekehrt gibt es in Root-in **keine** „Passwort vergessen"-Seite; die Mail-Links von Vox führen auf `lukasylilli.github.io/vox/`
> — dafür muss diese Adresse in Supabase → Redirect URLs stehen, sonst landet der Link auf der Site URL (mutmaßlich Root-in, das den Wiederherstellungs-Link nicht behandelt).
> Vox schreibt weiterhin **nur** in `vox_backups`, nie in `profiles`/`backups`. „Konto löschen" bleibt in Vox aus (L.1d, Entscheidung für beide Apps).
>
> 🗓️ **Vorherige Sitzung:** 2026-09-19 — an Root-in nichts geändert; nur vermerkt: Lukas fragte nach dem Veröffentlichungszeitpunkt von Vox. Weder die Vox- noch die Root-in-Dateien nennen ein Datum. Offen auf der Root-in-Seite (brauchen Lukas): PLAN-Tabelle Nr. 3 (`schema.sql` + „Konto löschen"), 5 (Durchgang auf echtem iPhone), 6 (eigener SMTP), 7 (ein Konto für Root-in und Vox, Phase 30 — Zeitpunkt nicht festgelegt). Details: `vox/PLAN.md` → „Letzte Sitzung".
>
> 🗓️ **Vorherige Sitzung:** 2026-09-18 — an Root-in nichts geändert; nur vermerkt, was in Vox passiert ist (L.6: Grammatik-Lektionen
> aus Lukas' Büchern, Inhalte neu geschrieben). ⏭️ **Nächster Schritt in Root-in:** die offenen Punkte unten — sie brauchen Lukas.
>
> **Stand 2026-09-15.** **Root-in ist eine Web-App** — live unter `lukasylilli.github.io/Root-in/`, ohne Store, ohne Installation. **224 Tests grün** (+2 bewusst übersprungen), `flutter analyze` sauber, **Browser-Durchgang 23/23 in der Automatik** und eine **Gegenprobe bei jedem Push** (31.2), 13/13 Zugriffsregeln am Server (18 Prüfungen, sobald `schema.sql` nach 31.3 eingespielt ist).
>
> ⚠️ **Ab dem 2026-08-17 gibt es keinen Entwicklungsrechner mehr.** Der Nutzer löscht alles, was nicht auf GitHub liegt — inklusive VS Code. **Jede weitere Änderung entsteht auf GitHub.** Was das für die Prüfung bedeutet, steht in [Abschnitt 9](#9-arbeitsweise--konventionen) und [Phase 29](#phase-29--arbeiten-und-prüfen-ohne-rechner--beauftragt-2026-08-17).
>
> ⚠️ **Es gibt nur die Web-Fassung** ([Phase 28](#phase-28--nur-noch-web--umgesetzt-2026-08-17)). Android, iOS und Desktop sind **aus dem Projekt entfernt**, ebenso die Erinnerungen — ein Browser kann keinen Wecker stellen. Die Versionsgeschichte behält alles.
>
> ✅ **[Phase 27 — Nutzerkonten & Cloud (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-)**: freiwilliges Konto, Cloud-Sicherung.
>
> ✅ **[Phase 29 — Arbeiten und Prüfen ohne Rechner](#phase-29--arbeiten-und-prüfen-ohne-rechner--beauftragt-2026-08-17)**: Server-Prüfung und Browser-Durchgang laufen auf GitHub, `meine/` liegt im Repository, die Datenschutzerklärung veröffentlicht sich selbst.
>
> 📄 **Datenschutzerklärung — wo sie steht und wie man sie ändert:** Der Text liegt in **`store/PRIVACY_POLICY.md`** (Deutsch + Englisch). Online steht er unter **`https://lukasylilli.github.io/Root-in/privacy.html`**, in der App unter *Einstellungen → Datenschutzerklärung*. **Ändern = die Datei auf GitHub bearbeiten und speichern** — die Automatik baut die Seite neu und stellt sie mit der App zusammen online. Es gibt keine zweite Kopie, die nachgezogen werden müsste (29.5; Schritt für Schritt in MAP.md, Abschnitt „Datenschutzerklärung").
>
> ⬜ **Was noch offen ist — in der Reihenfolge, in der es angegangen gehört:**
>
> | # | Offen | Wer | Warum in dieser Reihenfolge |
> |---|---|---|---|
> | 1 | ~~**Benutzername nachtragen können**~~ ✅ (31.1) | Claude | erledigt 2026-09-13 |
> | 2 | ~~**Browser-Durchgang erweitern**~~ ✅ (31.2) | Claude | erledigt — die Gegenprobe fand dabei einen echten Fehler in der App (31.2b) |
> | 3 | **`supabase/schema.sql` einmal im SQL-Editor ausführen**, danach *Actions → Server-Zugriffsregeln prüfen → Run workflow* (31.3) | **Nutzer** | „Konto löschen" ist gebaut; ohne die Funktion auf dem Server löscht die App nur die Daten und sagt das ehrlich |
> | 3b | ~~**Automatik auf Node 24**~~ ✅ (31.4) | Claude | erledigt |
> | 3c | ~~**Kein geheimer Schlüssel im Bundle**~~ ✅ (31.5) | Claude | erledigt |
> | 4 | **Alten Gist löschen** (29.5) | Nutzer | Überflüssig, aber auffindbar — und veraltet |
> | 5 | **Durchgang auf einem echten iPhone** (Phase 26, 27.9) | Nutzer | Chrome in der Automatik sieht weder Safari noch die abgelegte Fassung |
> | 6 | Eigener SMTP-Dienst → Passwort-Zurücksetzen (27.2) | Nutzer, dann Claude | Ohne ihn ist die E-Mail gespeichert, aber nutzlos. Der Knopf kommt **erst danach** — ungeprüft gebaut wäre er ein Knopf ins Leere |
> | 7 | **Ein Konto für Root-in und Vox** ([Phase 30](#phase-30--ein-konto-für-root-in-und-vox--beauftragt-2026-08-17-für-die-letzten-projektschritte)) | Nutzer beantwortet die Fragen, dann beide | Vom Nutzer für die **letzten** Projektschritte angesagt |
>
> 🌐 **2026-09-16 — Startsprache (31.6):** Ohne eigene Wahl folgt Root-in der Gerätesprache; kann die App keine davon, startet sie jetzt auf **Englisch** (vorher Deutsch).
>
> 🔗 **2026-09-13/15 — Root-in wird aus Vox verlinkt (nur diese Richtung).** In Vox öffnet die Karte **„Routine"** unter *Selbstlernen* die Adresse `https://lukasylilli.github.io/Root-in/` in einem neuen Tab (`core/constants/app_links.dart` → `rootInUrl`). **Bewusst kein Code-Merge** — Root-in bleibt ein eigenes Repo und eigenständig nutzbar, für alle, die nur die Routine-App brauchen. Für Root-in folgt daraus **keine Änderung**; hier steht es nur, damit die Verbindung auf beiden Seiten dokumentiert ist. ⚠️ Wer die Adresse von Root-in je ändert, muss `app_links.dart` **im Vox-Repo** nachziehen — Root-in weiß nichts von diesem Link.

## Inhaltsverzeichnis
1. [Vision](#1-vision)
2. [Zielplattformen](#2-zielplattformen)
3. [Datenhaltung](#3-datenhaltung)
4. [Tech-Stack](#4-tech-stack)
5. [App-Struktur / Seiten](#5-app-struktur--seiten)
6. [Vorlagen & Standard-Kategorien](#6-vorlagen--standard-kategorien)
7. [Kern-Konzepte](#7-kern-konzepte)
8. [Architektur-Prinzip](#8-architektur-prinzip)
9. [Arbeitsweise & Konventionen](#9-arbeitsweise--konventionen)
10. [Roadmap / Phasen](#10-roadmap--phasen)
    - 10.1 [Erledigte Phasen (Kurzfassung)](#101-erledigte-phasen-kurzfassung)
    - 10.2 [Festlegungen aus erledigten Phasen, die man noch braucht](#102-festlegungen-aus-erledigten-phasen-die-man-noch-braucht)
    - [Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-) ✅
    - [Phase 28 — Nur noch Web](#phase-28--nur-noch-web--umgesetzt-2026-08-17) ✅
    - [Phase 26 — Web-Fassung: was noch offen ist](#phase-26--web-fassung-was-noch-offen-ist-) 🔄
    - [Phase 29 — Arbeiten und Prüfen ohne Rechner](#phase-29--arbeiten-und-prüfen-ohne-rechner--beauftragt-2026-08-17) ✅
    - [Phase 30 — Ein Konto für Root-in und Vox](#phase-30--ein-konto-für-root-in-und-vox--beauftragt-2026-08-17-für-die-letzten-projektschritte) ⬜
    - [Phase 31 — Was ohne den Nutzer noch geht](#phase-31--was-ohne-den-nutzer-noch-geht--beauftragt-2026-09-13) ✅
11. [Entscheidungs-Log & dauerhafte Lehren](#11-entscheidungs-log--dauerhafte-lehren)
    - 11.1 [Log (Kurzfassung)](#111-log-kurzfassung) · 11.2 [Dauerhafte Lehren & Fallstricke](#112-dauerhafte-lehren--fallstricke) (1–41)
12. [Offene Fragen](#12-offene-fragen)

## 1. Vision
App zum Aufbauen und Verfolgen von Gewohnheiten/Routinen. Nutzer legen Habits an, haken sie täglich ab, sehen Streaks/Statistiken und werden durch kleine Gamification-Elemente motiviert, dranzubleiben. **Erinnerungen gehörten bis Phase 28 dazu und sind entfallen** — Root-in läuft nur im Browser, und ein Browser stellt keinen Wecker. Inhaltlicher Schwerpunkt: Sprachenlernen (siehe Anleitungs-Rubrik und Standard-Kategorien).

## 2. Zielplattformen

**Web (PWA) — und sonst nichts.** Erreichbar unter `lukasylilli.github.io/Root-in/`: eine Adresse, kein Store, keine Installation, kein Konto bei Google oder Apple.

⚠️ **Am 2026-08-17 vom Nutzer festgelegt**, in zwei Schritten am selben Tag. Zuerst: *„ziel ist web app, dass alle ohne app store oder google play das nutzen können."* Dann, nachdem der Plan Android und iOS nur **zurückgestellt** hatte: *„کلا انتشار در اپ استور و گوگل پلی و نسخه اندروید رو از پلن حذف کن، فقط نسخه وب خواهیم داشت."*

**Entfernt, nicht pausiert** (Phase 28): die Ordner `android/`, `ios/`, `macos/`, `linux/`, `windows/`, die neun Startbildschirm-Widgets, das gesamte Store-Material und der Signaturschlüssel-Weg. ⚠️ **Die Versionsgeschichte behält alles** — wer die Android-Fassung je zurückholen will, findet sie vollständig im Stand vom 2026-08-17. Ein Plan, der Wege aufbewahrt, die niemand mehr gehen wird, ist ein Archiv und kein Plan.

**Was die Entscheidung wert ist:** Kein Store-Konto, keine Prüfzeiten, keine 12-Tester-Regel, keine Altersfreigabe-Formulare, keine 99 $/Jahr für Apple — und ein Update ist ein `git push`.

⚠️ **Was sie kostet, und das gehört ausgesprochen:**

| Fehlt | Warum | Stand |
|---|---|---|
| **Erinnerungen** | Ein Browser kann keine Weckzeit stellen; `flutter_local_notifications` hat keine Web-Umsetzung | **entfernt** (Phase 28), nicht nur ausgeblendet |
| **Startbildschirm-Widgets** | Eine Website kann kein Widget stellen | entfernt |
| **Querformat-Sperre** | Die Ausrichtung gehört im Browser dem Gerät | war nie im Web wirksam |

Für eine Habit-App ist der Wegfall der Erinnerungen kein Detail. Er ist der Preis dafür, dass **jeder** die App über eine Adresse erreicht — und der Nutzer hat ihn bewusst bezahlt: *„یاد آور ها رو کلا حذف کن چون نسخه وب نمیتونه الارم داشته باشه."*

## 3. Datenhaltung

⚠️ **Mit Phase 27 (2026-08-17) hat sich dieser Abschnitt geändert.** Root-in war von Tag eins „vollständig lokal, kein Backend, keine Nutzerkonten"; das gilt so nicht mehr.

| | Bis Phase 26 | **Heute (ab Phase 27)** |
|---|---|---|
| Ort der Daten | ausschließlich auf dem Gerät | Gerät **bleibt die Quelle der Wahrheit**, mit Konto zusätzlich eine Kopie auf dem Server |
| Nutzerkonten | keine | **freiwillig** — ohne Konto läuft die App unverändert weiter |
| Backend | keins | Supabase (Postgres + Auth), kostenloser Tarif, Region Frankfurt |
| Netzzugriff | Datums-Verifikation, Anleitungs-Texte | zusätzlich Anmeldung und Cloud-Sicherung |
| Personenbezug | keiner | mit Konto: E-Mail-Adresse ⇒ Gewohnheiten werden personenbezogen (27.8) |

**Vier Sätze, die weiterhin gelten — und die die ganze Phase getragen haben:**
- **Lokal zuerst.** Die App muss ohne Internet **und ohne Konto** vollständig benutzbar bleiben. Der Server ist eine **Kopie**, keine Voraussetzung. Fällt er aus, merkt man es nur daran, dass „zuletzt gesichert" älter wird.
- **Ohne Schlüssel im Bau gibt es die Cloud überhaupt nicht** (`supportsCloudSync`) — kein Knopf, keine Rubrik, kein Netzverkehr.
- **Sicherung, kein Abgleich.** Hochladen automatisch, Herunterladen nur auf Nachfrage; zwei Geräte ohne Zusammenführungs-Logik löschen sich sonst gegenseitig Daten.
- „Wettkampf" zwischen Nutzern läuft **nicht** über den Server, sondern über geteilte **Bilder** des Fortschritts (Telegram-Gruppe, siehe Anleitung „Lernplanung"). Bestätigt 2026-07-19, auch mit Server unverändert.

Lokale Datenbank: Drift (SQLite, im Browser über WebAssembly); Key-Value: `shared_preferences` → `localStorage`; Export: JSON über das Share-Sheet bzw. als Download — **dasselbe JSON, das auch in die Cloud geht.**

⚠️ **„Auf dem Gerät" heißt im Browser: im Speicher dieser Website.** Das ist nicht nur eine Formulierung für die Datenschutzerklärung, sondern etwas, das den Nutzer trifft: „Website-Daten löschen" räumt den Bestand ab, und **Safari löscht ihn nach sieben Tagen ohne Besuch**, sofern die Seite nicht auf dem Home-Bildschirm liegt. Daran hängen der einmalige Hinweis aus 26.8 und die Bitte um dauerhaften Speicher beim Start.

## 4. Tech-Stack
| Bereich | Wahl | Begründung |
|---|---|---|
| State Management | flutter_riverpod | Testbar, kein BuildContext nötig |
| Navigation | go_router | Deklarative Routen, Bottom-Nav + verschachtelte Tabs |
| Lokale DB | drift + drift_flutter + sqlite3 | SQL für Streaks/Statistik. `sqlite3_flutter_libs` bewusst nicht (end-of-life) |
| Key-Value | shared_preferences | Profil, Einstellungen |
| **Backend** | supabase_flutter | **Phase 27** — Postgres + Auth + RLS, kostenloser Tarif. Einzige Stelle: `core/services/auth_service.dart`. ⚠️ Ohne Schlüssel wird es nicht einmal gestartet |
| Netzzugriff | http + http_parser | **Kein `dart:io`** (Lehre 30) — es übersetzt für den Browser und wirft dort |
| Diagramme | fl_chart | Balken/Linie/Kreis; Wrapper ausschließlich in `chart_card.dart` |
| Matrix-Grid | eigene Komponente | Volle Design-Kontrolle, überall wiederverwendbar |
| Home-Animation | eigener CustomPainter (+ lottie als Slot) | Berg-Szene ohne Asset-Abhängigkeit |
| Teilen | share_plus + screenshot | Share-Sheet für App-Link und Fortschritts-Bild |
| QR-Code | qr_flutter | Adresse der Web-Fassung auf der Fortschritts-Karte. Reines Dart, kein Platform-Channel |
| Externe Links | url_launcher | Kontakt, Anleitungs-Links |
| Datei-Auswahl | `<input type="file">` in `core/services/file_pick/` | Im Browser gibt es keine Dateipfade. `flutter_file_dialog` ist mit Phase 28 entfallen |
| Lokalisierung | flutter gen-l10n (ARB) + flutter_localizations | DE/EN/**FA** inkl. RTL, 276 Schlüssel je Sprache. `intl` bleibt auf `^0.20.2` (SDK-Pin) |
| Markdown | flutter_markdown_plus | Anleitungs-Texte; Vorgänger ist discontinued |
| Werbung / In-App-Kauf | ~~google_mobile_ads~~ · ~~in_app_purchase~~ | **Seit Phase 20 vollständig auskommentiert** |
| Design | Material 3 | Konsistent mit Flutter-Standard |
| Tests | flutter_test, mocktail | Unit- und Widget-Tests |

## 5. App-Struktur / Seiten

**5.1 Home** — Berg-Fortschritts-Animation (Kennzahl wählbar), Prozent & Punkte, individualisierbares Widget-Dashboard, Knopf „Fortschritt teilen".

**5.2 Heute** — Tagesring-Kopf, **wählbares Datum** (Pfeile, Auswahl, zurück auf heute; Zukunft gesperrt), Liste der Gewohnheiten mit Abhaken/Minuten, „+"-Button, Menü Bearbeiten/Löschen.

**5.3 View** (Tabs Woche / Übersicht / Monat / Jahr) — Woche/Monat/Jahr je ein individualisierbares Dashboard; **Übersicht** = die letzten vier Kalenderwochen als **eine** quer liegende Bühne mit festem Raster, Vollbild-Knopf, Querformat-Sperre.

**5.4 Einstellungen** — Sprache, Darstellungsmodus, Farb-Variante, Quelle der Berg-Animation · Konto, Kategorien · App teilen, Sicherung exportieren/importieren, Kontakt · Rubrik **Root-in Anleitung** (vier Themen) · Eintrag **موارد دیگر** direkt darunter.

**5.5 Konto** — ganz oben die Rubrik **„Konto & Cloud"** (Phase 27: anmelden/registrieren, hinterlegte E-Mail, Stand der letzten Sicherung, sichern, wiederherstellen, Server-Daten löschen; **ohne Cloud unsichtbar**). Darunter unverändert: Profil (Name, lokal), Achievements-Grid, längste Serie, Gesamt-Statistik, Dashboard über den gesamten Verlauf, „Fortschritt teilen" (bleibt hier — die Anleitung „Lernplanung" verweist ausdrücklich darauf).

⚠️ Die Anmeldung sitzt bewusst **hier** und nicht in einer eigenen Rubrik daneben: Ein Konto ist genau das, worum es auf dieser Seite ohnehin geht. Zwei Orte für dasselbe Thema wären die verbotene Doppelung — und der Nutzer müsste sich merken, welcher was kann.

**5.6 Kategorien** — Liste, anlegen, umbenennen (kaskadiert), löschen (blockiert solange in Benutzung), Standard-Kategorien beim Erststart + Nachrüst-Knopf, Symbol je Standard-Kategorie.

## 6. Vorlagen & Standard-Kategorien

**Habit-Vorlagen** (`core/constants/habit_templates.dart`, 11 Stück): YouTube, Kursbuch, Arbeitsbuch, Wörter 10 Min, Wörter 1 Stunde, Grammatik aktiv, Schreiben, Lesen, Sprechen, Hören, Auswendiglernen. Ziel-Typ je Vorlage: Abhaken **oder** Dauer/Menge. Jede trägt ein `categoryId`, das auf eine der sieben Kategorien zeigt.

**Standard-Kategorien** (`core/constants/default_categories.dart`) — die **sieben Fertigkeiten** aus der Anleitung:

| Deutsch | Englisch | Persisch |
|---|---|---|
| Grammatik | Grammar | دستور زبان |
| Wortschatz | Vocabulary | واژگان |
| Auswendiglernen | Memorization | حفظ کردن |
| Lesen | Reading | خواندن |
| Schreiben | Writing | نوشتن |
| Sprechen | Speaking | صحبت کردن |
| Hören | Listening | شنیدن |

Beim Erststart in der gewählten Sprache angelegt, danach **Nutzerdaten**: frei umbenennbar, löschbar, erweiterbar. Kurs- und Videounterricht zählen laut Anleitung zu **Grammatik**.

## 7. Kern-Konzepte

**Punkte & Prozent** — jede Seite zeigt Fortschritt in beidem. **Matrix-Grid** — wiederverwendbare Heatmap (Zellen = Tage, Intensität = Erledigungsgrad). **Diagramme** — Typ-Diagramm je Kategorie + Fortschritts-Trend, via `chart_card.dart`. **Streak** — aktuelle + längste Serie, 1 Tag pro Woche darf ausgelassen werden. **Achievements** — 11 vordefinierte. **Teilen** — App teilen (Text + Adresse) und Fortschritt teilen (Bild mit fester Breite, Übersicht-Block, QR-Code). **Die geteilte Adresse** — `core/constants/app_links.dart` ist die einzige Quelle. **Home-Animation** — Berg-Aufstieg, über `AppAssets.homeAnimation` gegen ein Lottie-Asset tauschbar. **Kategorien** — jede Gewohnheit gehört zu genau einer; die Liste verwaltet der Nutzer.

## 8. Architektur-Prinzip
Feature-first (Dateien im Einzelnen: MAP.md):
- `core/` — Services, Theme, Utils, Konstanten, geteilte Widgets
- `data/` — Drift-Datenbank, DAOs, Repository, Modelle
- `features/<feature>/` — Screens, Widgets, Provider (home, today, view, habits, settings, guide, account, categories, others, onboarding, **auth**)

## 9. Arbeitsweise & Konventionen

**Schrittweiser Aufbau** — phasenweise, nicht alles auf einmal. Nach jedem wesentlichen Schritt werden PLAN.md und MAP.md aktualisiert.

**Inhaltsverzeichnis-Pflicht** — jede `.md`-Datei beginnt mit einem Inhaltsverzeichnis. Gilt **nicht** für `.dart`-Dateien (eine Datei = eine Verantwortung, Navigation über MAP.md).

**„Puzzling" / DRY** — für jede wiederkehrende Sache genau **eine** Datei/Klasse (Farben, Styles, Buttons, Dialoge, Diagramme, Services). Andere Stellen referenzieren sie.

**Design-Token-Prinzip** — jeder Design-Aspekt hat seine eigene Datei (`app_colors`, `app_theme_tokens`, `app_theme_variant`, `app_fonts`, `app_text_styles`, `app_spacing`, `app_theme`, `app_button`); der Nutzer-Zustand liegt in `settings_service.dart`, die Sprachen in `core/l10n/app_language.dart`. Eine Änderung zieht durch die ganze App.

**Plattform-Weichen heißen nach Fähigkeiten, nicht nach Plattformen** — `usesBrowserStorage` statt `kIsWeb`. **`kIsWeb` steht an genau einer Stelle**: `core/utils/platform_support.dart`. ⚠️ Die Regel bleibt, obwohl es nur noch eine Plattform gibt: Sie kostet nichts und hält die Frage lesbar.

**Datenerhalt geht vor** — die Datenbank ist Nutzereigentum. **Jede Änderung an `schemaVersion` braucht im selben Schritt einen `onUpgrade`-Zweig und einen Migrations-Test.** Fehlt er, startet die App nach dem Update nicht mehr auf dem alten Bestand — vom Nutzer aus gesehen dasselbe wie Datenverlust.

**Verifizieren statt annehmen** — „Build erfolgreich" ist kein Beweis. Ein neuer Oberflächen-Test wird **einmal gegen den kaputten Stand gehalten** (Lehre 32). ⚠️ **Womit geprüft werden kann, hat sich am 2026-08-17 geändert** — siehe die Tabelle unten.

### Wo gearbeitet wird: nur noch GitHub *(ab 2026-08-17)*

**Vom Nutzer festgelegt:** *„هیچ چیزی دیگ از داخل مک و پوشه های محلی … نمیشه چون در حال پاک کردن هر چیزی هستم که توی گیت هاب نیست. از الان به بعد تمام تغییرات فقط در گیت هاب."* Auch VS Code wird gelöscht.

**Damit gilt: Was nicht im Repository steht, existiert nicht.** Kein `flutter` auf einer Kommandozeile, kein Emulator, kein Simulator, kein `git` auf einer Festplatte. Jede Änderung ist eine Änderung an Dateien im Repository, und der einzige Ausführende ist die Automatik.

⚠️ **Das ist keine Unbequemlichkeit, sondern eine Verschiebung der Beweislast.** Bisher hing die Sicherheit an drei Werkzeugen, von denen zwei einen Mac brauchten. Was bleibt und was fehlt:

| Prüfung | Wo | Nach dem Löschen |
|---|---|---|
| `flutter analyze` | GitHub-Action, **vor** jeder Veröffentlichung | ✅ bleibt |
| `flutter test` (224 Fälle) | GitHub-Action, **vor** jeder Veröffentlichung | ✅ bleibt |
| Bau der Web-Fassung | GitHub-Action | ✅ bleibt |
| **`tool/rls_check.sh`** — Zugriffsregeln von außen | GitHub-Action `rls-check.yml`, **von Hand** auszulösen | ✅ **gerettet** (29.2) — nach jeder Änderung an `schema.sql` auslösen |
| **Echter Browser** — früher `tool/webtest.py` (Safari, macOS) | `tool/webtest_ci.py` (Chrome) in `deploy-web.yml`, **vor** jeder Veröffentlichung, **blockierend** | ✅ **ersetzt** (29.3), 23 Prüfungen (31.2). ⚠️ Chrome, nicht Safari |
| **Gegenprobe des Browser-Durchgangs** | `webtest-gegenprobe.yml`, **bei jedem Push**, veröffentlicht nichts | ✅ **neu** (31.2) — beweist, dass der Durchgang rot werden kann, und fand beim ersten Lauf einen echten Fehler (31.2b) |
| **Kein geheimer Schlüssel im Bundle** | `tool/check_bundle_secrets.py` in `deploy-web.yml`, nach dem Bau, **blockierend** | ✅ **neu** (31.5) — mit Zeugen: findet sie den erlaubten Schlüssel nicht, ist sie blind und wird rot |
| iOS-Simulator | macOS | ⛔ fällt weg |
| **Echtes iPhone** | beim Nutzer | ✅ **bleibt — und ist damit der einzige verbliebene Blick auf die echte Oberfläche** |

✅ **Die Lücke ist seit 29.3 geschlossen** (2026-09-12). Alle Tests laufen auf der Dart-VM und öffnen **keinen** Browser — genau diese Lücke hatte in Phase 26 drei kaputte Hauptseiten durchgelassen (Lehre 31). Jetzt startet vor jeder Veröffentlichung ein echter Chrome die gebaute Seite und tippt durch die Reiter; ein roter Durchgang hält die Veröffentlichung auf. ⚠️ **Was er nicht sieht:** Safari-Eigenheiten und die auf dem Home-Bildschirm abgelegte Fassung (Lehre 34). Dafür bleibt das iPhone des Nutzers.

**Was daraus für jede weitere Änderung folgt:**
- **Kleine Schritte, ein Thema je Push.** Ein grüner Lauf sagt „übersetzt und Tests grün", nicht „sieht richtig aus". Je kleiner der Schritt, desto leichter ist ein Fehler dem Push zuzuordnen.
- **Der Nutzer ist der Abnehmende.** Was die Oberfläche betrifft, gilt erst als fertig, wenn er es auf seinem iPhone gesehen hat.
- **Reine Logik gehört in einen Test**, nicht in einen Blick — ein Test ist das Einzige, was ohne Rechner noch von selbst prüft.

## 10. Roadmap / Phasen

### 10.1 Erledigte Phasen (Kurzfassung)

| Phase | Ergebnis | fertig |
|---|---|---|
| 0 Setup | Abhängigkeiten, Ordnerstruktur, Theme-Gerüst, Router + Bottom-Nav-Shell | 07-19 |
| 1 Datenmodell & Heute | Drift-Tabellen, Vorlagen, Abhaken, Punkte/Prozent, Streak inkl. Frei-Tag-Regel, TimeService | 07-19 |
| 2 Navigation & Matrix-Grid | View-Tabs, wiederverwendbares `MatrixGrid`, DST-sichere Datumsarithmetik | 07-20 |
| 3 Statistik-Seiten | Kategorie-Balken + Fortschritts-Trend je Zeitraum, **ein** fl_chart-Wrapper | 07-20 |
| 4 + 4.5 Konto & Kategorien | Profil lokal, 11 Achievements, lebenslange Statistik; `Categories`-Tabelle (Referenz per **Name**), **ein** Formular für Anlegen + Bearbeiten | 07-20 |
| 5 + 5.5 Teilen & Dashboard | Fortschritts-Karte als Screenshot; 5 Diagrammtypen, Drag-and-Drop-Dashboard je Seite | 07-20/21 |
| 6 + 7 Einstellungen & Erinnerungen | Hell/Dunkel/System, Farbvarianten, Kontakt; tägliche Notification je Gewohnheit inkl. Snooze | 07-21 |
| 8 + 8.5 + 8.6 Home-Animation | Berg-Szene nach Nutzer-Vorlage, Kennzahl wählbar, Lottie-Slot verdrahtet | 07-21 |
| 9 Backup & Export | JSON-Export/-Import, IDs bleiben erhalten, Erinnerungen werden neu geplant | 07-21 |
| 10 + 10.5 + 10.7 Home-Screen-Widgets | Fortschritts-Widget + **fünf eigenständige** Diagramm-Widgets (Auswahl auf dem Startbildschirm) | 07-23 |
| 10.6a–d Erscheinungsbild nach Spec | Design-Tokens, Spec-Look auf allen Seiten, Ring/Checklist/Farbkachel — **9 Home-Screen-Widgets** | 07-26 |
| 11 + 11.5 + 11.6 Lokalisierung & Onboarding | DE/EN über ARB, **ein** Sprach-Schalter; vierteilige Erststart-Erklärung mit Merker | 07-26 |
| 14 Monetarisierung (Code) | AdMob-Banner + Einmalkauf — **in Phase 20 vollständig auskommentiert** | 07-26 |
| 15.1 + 15.2 Paketname & Store-Material | `com.rootin.app`, Upload-Schlüssel, signiertes Bundle; Symbole, Feature-Grafik, Screenshots, Store-Texte, Datenschutzerklärung | 07-26 |
| 16 + 16.1 Übersicht-Seite | 28 Tagesspalten in **einem** festen Raster (alle Maße in einer Datei), Vollbild-Route, Querformat-Sperre | 07-30 |
| 17 → 17.3 Root-in Anleitung | Vier Seiten, Inhalte als Markdown aus dem Repository (ohne App-Update änderbar), DE/EN/FA | 08-01 |
| 18 Persisch vollständig | Persisch als echte Oberflächen-Sprache inkl. RTL; Sonderweg `contentLanguageCode` entfallen | 08-01 |
| 19 Teilen überarbeitet | **Ein** Sheet für Home und Konto, Karte mit Übersicht-Block, QR-Code, feste Bildbreite | 08-01 |
| 20 Werbung auskommentiert | Werbe- und Kauf-Code stillgelegt (nicht gelöscht), Pakete und Manifest-Einträge ebenso | 08-01 |
| 21.1 + 21.2 Standard-Kategorien | Die sieben Fertigkeiten beim Erststart, Nachrüst-Knopf, Vorlagen je Kategorie, Lösch-Hinweis mit Anzahl | 08-01 |
| 22 Rubrik „موارد دیگر" | Einseitiger Kanal aus dem Repository; Struktur aus `index.json`, je Sprache getrennt | 08-02 |
| 23 Erinnerungen, die erinnern | Serie im Erinnerungstext, dauerhafte Tagesstand-Meldung (eigener leiser Kanal), Sperrbildschirm | 08-02 |
| 24 Beliebiges Datum nachtragen | `selectedDateProvider` (Override, `null` = heute), Datumszeile, Zukunft gesperrt | 08-02 |
| 25 Daten überleben jedes Update | Migrations-Test über echte Bestände aus Schema 1 und 2, `android:allowBackup` ausdrücklich | 08-02 |
| 13 Diagramm-Feinschliff | Trend bündelt auf Wochen-/Monatsmittel, Balken-Achsen aufgeräumt, Tab- und Randfall-Tests | 08-07 |
| 26 Web-Fassung (PWA) | Drift auf WebAssembly, vier Plattform-Weichen an **einer** Stelle, GitHub-Action baut und veröffentlicht, Speicher-Hinweis für Safari · **live** | 08-14 |
| 26.9 Weniger Rückfragen | `.claude/settings.json` mit ermittelter (nicht geratener) Freigabeliste | 08-14 |
| 26.10 → 26.13 Web-Fehler behoben | `dart:io` aus `lib/` verbannt, Web-Symbole aus der einen Quelle, Koordinaten-Versatz der abgelegten Fassung | 08-14/16 |
| 27 Nutzerkonten & Cloud | Supabase: freiwilliges Konto (E-Mail + Passwort + Benutzername), Cloud-Sicherung im vorhandenen Backup-Format, Profil-Abgleich, Datenschutzerklärung neu · Zugriffsregeln von außen mit echten Konten geprüft | 08-17 |
| 27.11 Geteilter Link | QR-Code und Share-Text zeigten auf eine Play-Seite mit **HTTP 404**; jetzt auf die Web-Fassung | 08-17 |
| 28 Nur noch Web | Erinnerungen bis in die Datenbank entfernt (Schema 4), Android/iOS/Desktop und Store-Material gestrichen | 08-17 |
| 29 Arbeiten ohne Rechner | Server-Prüfung als Action, Browser-Durchgang (Chrome) **blockiert** die Veröffentlichung, `meine/` versioniert, `privacy.html` entsteht bei jedem Bau | 09-12 |
| 31 Was ohne Nutzer geht | Benutzername nachtragen · Browser-Durchgang 23 Punkte + **Gegenprobe** (fand 40 s Ladekreis statt „Kein Internet") · Konto vollständig löschen · Automatik auf Node 24 · kein geheimer Schlüssel im Bundle | 09-13 |

**Stand nach Phase 31: 224 Tests grün** (+2 bewusst übersprungen). **Stand nach Phase 29: 210 Tests grün** (+2 bewusst übersprungen), darunter neu `privacy_page_test.dart`. **Stand nach Phase 28: 205 Tests grün** (+2 bewusst übersprungen), `flutter analyze` sauber, 13/13 Zugriffsregeln am Server. ⚠️ Die Zahl ist **kleiner** als die 228 von Phase 27 — mit Erinnerungen und Startbildschirm-Widgets sind auch deren 23 Tests entfallen. Weniger Tests sind hier kein Rückschritt, sondern die Folge von weniger Funktion.

### 10.2 Festlegungen aus erledigten Phasen, die man noch braucht

Die Langfassungen sind eingedampft; was hier steht, braucht man beim Weiterbauen. Alles Übrige steht im Code und in Abschnitt 11.

**Persisch (18).** Persisch ist vollwertige Oberflächen-Sprache. **Ziffern bleiben westlich** (Begründung in `core/l10n/app_numbers.dart`, dort liegt auch die einzige Prozent-Formatierung). **Übersicht, Diagramme und Berg-Animation bleiben links-läufig** — ein Kalender Mo–So läuft auch in persischen Kalendern so, und ein Spiegeln würde jede Koordinate in `overview_metrics.dart` umkehren. Schriftart bleibt die Plattform-Schrift; zeigt ein Gerät Kästchen, ist `app_fonts.dart` der eine Ort. ⬜ Die Übersetzung ist ein **Entwurf** — der Nutzer geht sie als Muttersprachler durch.

**Teilen (19).** Knopf auf Home **und** Konto, beide öffnen `showShareProgressSheet()`. Der Konto-Weg musste bleiben, weil die Anleitung „Lernplanung" ihn wörtlich beschreibt. Die Karte hat eine **feste Breite**; der `Screenshot`-Knoten liegt **innerhalb** der Vorschau-`FittedBox`, sonst wäre das Bild so klein wie die Vorschau. Den Übersicht-Block bekommt sie als **fertiges Widget**, damit `core/` nichts aus `features/` importiert.

**Werbung stillgelegt (20).** Alles auskommentiert, nichts gelöscht; jede Stelle trägt den Marker `PHASE 20 (2026-08-01)`. Wiedereinschalten ist ein `grep`. Der Kaufmerker in `shared_preferences` bleibt unangetastet. ✅ Die Datenschutzerklärung veröffentlicht sich seit 29.5 selbst (`privacy.html`); der alte Gist ist nur noch zu löschen.

**Standard-Kategorien (21).** Entstehen beim Erststart in der gewählten Sprache (`ensureDefaultCategories`, nur bei leerer Tabelle); `addMissingCategories` rüstet Bestandsnutzer nach. Sie sind **Nutzerdaten** — nichts im Code schützt sie; das Symbol wird über den **Namen** zugeordnet, wer umbenennt verliert es.

**„موارد دیگر" (22).** Struktur aus `content/others/<sprache>/index.json`, **nicht** aus der GitHub-API (60 Abrufe/Stunde je IP — hinter einer geteilten Mobilfunk-Adresse bliebe die Rubrik leer). **Kein Rückfall zwischen Sprachen.** Vier Fehlerfälle sichtbar unterschieden: kein Netz · Manifest fehlt · Manifest kaputt (der Autor soll erfahren, dass **seine Datei** das Problem ist) · einzelner Text fehlt. Pflege-Anleitung: `store/OTHERS_CONTENT.md`. ⚠️ GitHub liefert mit `max-age=300` — bis zu fünf Minuten Verzögerung nach dem Hochladen.

~~**Erinnerungen (23).**~~ **Mit Phase 28 vollständig entfernt** — samt Tagesstand-Meldung, Paketen, DB-Spalten und ARB-Schlüsseln. Ein Browser stellt keinen Wecker. Was von Phase 23 bleibt, ist ein Gedanke, der weiterträgt: **Ein Sender, mehrere Empfänger.** Der heutige Fortschritt wird in `app.dart` an genau einer Stelle beobachtet; damals hingen Widget und Meldung daran, heute die Cloud-Sicherung. Keine Seite muss daran denken, nach einer Änderung nachzuziehen.

**Datum nachtragen (24).** `selectedDateProvider` ist der eine Schalter; dahinter ein **Override** (`null` = heute), damit die Seite über Mitternacht von selbst weiterspringt. Die Fortschritts-Karte bleibt auf heute (getrennte Provider über dieselbe Family). ⚠️ **Ein Nachtrag verlängert die Serie rückwirkend** — gewollt. Die Datums-Prüfung im Netz bleibt unangetastet: nachtragen ja, „heute" vordatieren nein.

**Datenerhalt (25).** Die Gefahr war nie das Update selbst, sondern eine Schema-Änderung ohne Migration. ⚠️ **Im Browser wiegt das schwerer als früher auf Android:** Dort lag die Datei in einem App-Verzeichnis, das niemand anfasst; hier liegt sie in IndexedDB/OPFS, und eine Migration, die scheitert, trifft einen Bestand, von dem es **keine zweite Kopie auf dem Gerät** gibt (die Cloud-Sicherung hat nur, wer ein Konto hat). Der Migrations-Test zieht echte Bestände aus Schema 1 und 2 hoch und prüft, dass **dieselben IDs** dastehen — eine Migration, die Gewohnheiten neu anlegt statt sie zu behalten, würde jede Erledigung von ihrer Gewohnheit trennen. Der vierte Testfall ist eine **Bremse**: Er hält `schemaVersion` auf dem geprüften Wert fest.

**Web-Fassung (26).** Drift auf WebAssembly (`sqlite3.wasm` + `drift_worker.js`, von `tool/fetch_web_db_assets.sh` geholt). **Die beste Weiche ist keine Weiche** — Sicherung und Bild-Teilen verloren ihren Plattform-Anteil ganz, statt einen Web-Sonderfall zu bekommen; mit Phase 28 ist diese Linie zu Ende gegangen und die Weichen sind ganz weg. Bau-Schalter stehen ausschließlich in `tool/build_web.sh` — die Automatik ruft dasselbe Skript. **Kein `gh-pages`-Zweig**: Pages nimmt das Artefakt direkt entgegen, damit landet das Bauergebnis nie in der Versionsgeschichte.

**Was die vier Web-Fehler waren (26.10–26.13)** — die Ursachen stehen als Lehren 30–34; hier nur das Ergebnis: `dart:io` ist vollständig aus `lib/` verschwunden (`package:http` überall), die Web-Symbole kommen aus derselben Quelle wie die Android-Symbole, und `web/index.html` trägt **kein** `viewport-fit=cover` und `default` statt `black-translucent`. `tool/webtest.py` prüfte seither **20 Punkte** inklusive aller vier Reiter, einer Anleitungs-Seite und der Rubrik „Konto & Cloud" — und wurde am kaputten Stand rot gemessen, bevor er am reparierten grün wurde. ⚠️ **Er braucht macOS und ist ab Phase 29 nicht mehr ausführbar**; sein Ersatz `tool/webtest_ci.py` läuft seit 29.3 in der Automatik.

---

### Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase) ✅
**Code fertig am 2026-08-17.** Offen bleibt beim Nutzer ein eigener SMTP-Dienst (27.2) und der Gerätedurchgang (27.9); was Claude noch nachzieht, steht in [Phase 31](#phase-31--was-ohne-den-nutzer-noch-geht--beauftragt-2026-09-13).
**Vom Nutzer am 2026-08-16 beauftragt:** *„اطلاعات حساب کاربر اینجا ذخیره بشه — Supabase … اینجوری ی سرور داریم که رایگان و اتوماتیک اطلاعات کاربران رو ذخیره میکنه."* Ein Server, der die Nutzerdaten kostenlos und automatisch aufbewahrt.

#### 27.0 Was diese Phase umkehrt — vor dem ersten Handgriff lesen

⚠️ **Root-in war von Tag eins „vollständig lokal, kein Backend, keine Nutzerkonten".** Dieser Satz steht nicht nur in Abschnitt 3, sondern trägt eine Kette von Entscheidungen. Was daran hängt:

| Betroffen | Heute | Nach Phase 27 |
|---|---|---|
| Abschnitt 3 | „kein Backend, keine Nutzerkonten" | Server als **Kopie**, Konto **freiwillig** |
| `store/PRIVACY_POLICY.md` | „Daten verlassen das Gerät nicht" | muss die Server-Speicherung nennen — **und der Gist muss nachgezogen werden** (er aktualisiert sich nicht von selbst) |
| Phase 22 | „kein Rückkanal, das wäre ein Server" | der Server existiert dann; die Entscheidung bleibt trotzdem, siehe Abschnitt 12 |
| Phase 26.5 | „Root-in hat heute keine Geheimnisse" | der `anon`-Schlüssel kommt ins Bundle (kein Geheimnis, siehe 27.3), der `service_role`-Schlüssel **niemals** |

⚠️ **Die Datenschutz-Anpassung ist keine Nacharbeit.** Wer die Adresse an Schüler gibt und deren E-Mail speichert, schuldet ihnen einen zutreffenden Text. Mit Phase 28 ist der Text nachgezogen; offen bleibt nur noch der veröffentlichte Gist.

#### 27.0b Die Entscheidungen des Nutzers ✅ *(getroffen 2026-08-16)*

| Frage | Entscheidung |
|---|---|
| Pflicht oder freiwillig? | **freiwillig** — ohne Konto läuft die App unverändert weiter |
| Registrierung | **echte E-Mail + Passwort + Benutzername** *(geändert am 2026-08-16, siehe unten)* |
| Was wandert auf den Server? | **Profil und die Nutzerdaten** — Gewohnheiten, Tage/Erledigungen, Kategorien |
| Richtung | **Sicherung, kein stiller Abgleich** (hochladen automatisch, herunterladen auf Nachfrage) |
| Quellcode | **bleibt öffentlich auf GitHub — das Projekt ist Open Source** |

⚠️ **Am 2026-08-16 vom Nutzer geändert: echte E-Mail statt künstlicher Adresse.** Die vorherige Fassung dieses Plans baute den Benutzernamen intern zu einer Adresse um (`ali@rootin.invalid`), weil Supabase Passwort-Anmeldung ohne Adresse nicht kennt. Das ist hinfällig — jetzt gibt es drei echte Angaben:

| Angabe | Wofür | Wo sie liegt |
|---|---|---|
| **E-Mail** | Kennung gegenüber Supabase **und** der einzige Weg, ein Passwort zurückzusetzen | `auth.users` (von Supabase verwaltet) |
| **Passwort** | Anmeldung | `auth.users`, gehasht — **wir sehen es nie** |
| **Benutzername** | Name in der App; eindeutig, damit man einen Menschen ansprechen kann | `profiles.username` (unsere Tabelle) |

**Was der Wechsel bringt:** ✅ Ein vergessenes Passwort ist **wiederherstellbar** — genau der Punkt, der vorher der Preis war.

⚠️ **Was er kostet — und das ist kein Nebensatz:** Der eingebaute Mail-Versand von Supabase ist für echte Nutzer **unbrauchbar**. Nachgelesen am 2026-08-16 in der Supabase-Dokumentation, nicht geraten:

> „Currently this value is set to **2 messages per hour**." · Der Dienst ist „best-effort only", ohne Zustell-Garantie, und verschickt nur an **vorab freigegebene Adressen des eigenen Teams**.

**Für 200 Schüler heißt das: gar nicht.** Nicht „langsam" — die Nachrichten kämen bei fremden Adressen überhaupt nicht an. Wer echte E-Mails will, braucht **einen eigenen SMTP-Dienst** (27.2).

**Der Weg, der beides möglich macht, ohne jetzt zu blockieren:**
1. **Jetzt:** E-Mail wird bei der Registrierung erfasst, **„Confirm email" bleibt AUS**. Anmelden funktioniert sofort; es wird keine einzige Nachricht verschickt, also greift keine Grenze.
2. **Sobald ein SMTP-Dienst eingerichtet ist:** Passwort-Zurücksetzen geht — **rückwirkend für alle**, die sich vorher registriert haben. Ihre Adressen liegen schon da.

⚠️ **Die Kehrseite von „Confirm email AUS" gehört benannt:** Niemand prüft, ob die Adresse stimmt. Ein Tippfehler fällt erst auf, wenn das Zurücksetzen gebraucht wird — also im schlechtesten Moment. Gegenmaßnahme in 27.5: Die Adresse steht **sichtbar** in der Rubrik „Konto & Cloud" und ist dort änderbar.

⚠️ **Mit echten E-Mails wird aus einer Kopie personenbezogene Datenverarbeitung.** Eine E-Mail-Adresse ist ein personenbezogenes Datum; Gewohnheiten und Erledigungen sind es im Zusammenhang mit ihr ebenfalls. Das verschärft 27.8 — die Datenschutzerklärung und das Play-Formular sind ab hier keine Formalie mehr.

⚠️ **Open Source verschärft eine Regel, statt sie zu lockern:** Jeder kann `supabase/schema.sql` lesen und damit **genau sehen, welche Zugriffsregeln ihn abwehren**. Das ist bei RLS vorgesehen und in Ordnung — aber es heißt, dass die Regeln wirklich stimmen müssen; auf Unkenntnis des Angreifers ist kein Verlass. Und es macht die Trennung der Schlüssel noch wichtiger: `anon` ist öffentlich, `service_role` darf **nirgends** im Repository auftauchen.

#### 27.1 Ausgangslage — was schon da ist und trägt

Diese Phase beginnt nicht bei null; drei Dinge aus Phase 26 sind genau dafür gebaut worden:

- **`core/constants/app_config.dart`** nimmt Werte über `String.fromEnvironment` entgegen, `.env.example` ist die Vorlage, die echte `.env` ist ausgeschlossen. Phase 26.5 sagt wörtlich: *„Das Gerüst steht trotzdem, damit ein späterer Server-Anteil nicht improvisiert wird."* Dieser Moment ist jetzt.
- **`core/utils/platform_support.dart`** ist die eine Stelle für Fähigkeits-Abfragen — dort kommt `supportsCloudSync` hinein.
- **`data/models/backup_data.dart`** serialisiert den **kompletten** Bestand verlustfrei nach JSON, ohne Datei- oder Plattform-Zugriff, mit fünf Tests. **Das ist das Format für die Cloud-Sicherung** — ein zweites Serialisierungs-Format wäre genau die Doppelung, die Abschnitt 9 verbietet.

#### 27.2 Supabase-Projekt anlegen *(führt der Nutzer durch, Anleitung auf Persisch)*
- [ ] Konto auf supabase.com, neues Projekt. **Region bewusst wählen** (nahe an den Nutzern), Datenbank-Passwort in den Passwortmanager.
- [ ] **Authentication → Providers → Email:** eingeschaltet lassen, aber ⚠️ **„Confirm email" AUS** — vorerst. Mit dem eingebauten Mail-Dienst käme die Bestätigung bei fremden Adressen **nie an**, und niemand könnte sich anmelden. Einschalten, sobald SMTP steht (siehe unten).
- [ ] Mindestlänge des Passworts dort setzen (Vorschlag: 8).
- [ ] **Drei Schalter der Data API** (beim Anlegen oder unter *Settings → API*):

  | Schalter | Wert | Grund |
  |---|---|---|
  | Enable Data API | **AN** | Ohne sie erreicht die App keine einzige Tabelle — nur die Anmeldung liefe |
  | Automatically expose new tables | **AUS** | Empfehlung von Supabase. ⚠️ Dann vergibt **`schema.sql` die Rechte selbst** (Abschnitt 3 dort) — genau deshalb stehen sie seit dem 2026-08-16 ausdrücklich drin und nicht implizit |
  | Enable automatic RLS | **AN** | Sicherheitsnetz für eine später von Hand angelegte Tabelle. `schema.sql` schaltet RLS ohnehin ein |

  ⚠️ **Der mittlere Schalter hat eine Lücke aufgedeckt:** Die erste Fassung von `schema.sql` verließ sich auf die automatische Freigabe. Steht der Schalter auf „aus", hätte die App „permission denied" gemeldet — und man hätte es dem SQL nicht angesehen. Jetzt trägt die Datei ihre Rechte selbst und funktioniert in **beiden** Einstellungen.
- [ ] ⬜ **Eigener SMTP-Dienst — nötig, sobald Passwort-Zurücksetzen funktionieren soll.** Nicht blockierend für den Bau, aber ohne ihn ist die E-Mail nur gespeichert, nicht nutzbar. Kostenlose Tarife gibt es (z. B. Resend, Brevo); ⚠️ deren Grenzen **am Tag der Einrichtung nachlesen**, nicht aus zweiter Hand übernehmen. Danach in *Authentication → Emails → SMTP Settings* eintragen und mit einer **echten fremden Adresse** testen — der eingebaute Dienst schickt nur an das eigene Team, ein Test an die eigene Adresse beweist also nichts.
- [ ] Aus den Projekt-Einstellungen notieren: **Project URL** und **anon/public key**. ⚠️ Den **`service_role`-Schlüssel nicht** — er umgeht jede Zugriffsregel und darf weder in die App noch ins Repository. Das Repository ist öffentlich.
- [x] **Grenzen des kostenlosen Tarifs nachgelesen** (`supabase.com/pricing`, 2026-08-16 — nicht aus dem Gedächtnis):

  | Grenze | Wert | Bei ~200 Schülern |
  |---|---|---|
  | Aktive Nutzer je Monat | **50 000** | 200 → 0,4 % ✅ |
  | Datenbank | **500 MB** | ~40 MB ✅ (≈200 KB je Schüler nach einem Jahr) |
  | Ausgehender Verkehr | **5 GB/Monat** | weit darunter ✅ |
  | Dateispeicher | 1 GB | wird nicht genutzt ✅ |
  | Aktive Projekte | 2 | eines nötig ✅ |

  ➜ **Die Nutzerzahl ist kein Engpass** — Luft um den Faktor 250. Der Speicher trägt auch vier- bis fünfhundert Schüler.

- [x] ⚠️ **Der eine Bund, der zählt: „Free projects are paused after 1 week of inactivity."** Nach der Verteilung an die Schüler nie ein Thema (tägliche Nutzung). **Während der Bauzeit sehr wohl** — liegt das Projekt ein paar Tage still, schläft es und muss von Hand geweckt werden. Ein fehlgeschlagener Sicherungs-Versuch in dieser Zeit ist **kein Fehler im Code**; das gehört gewusst, bevor jemand danach sucht.
- [x] ⚠️ **Im kostenlosen Tarif sichert Supabase die Datenbank nicht täglich.** Für Root-in ist das tragbar, aber nur wegen der Grundentscheidung: **Die Daten liegen auf dem Gerät, der Server hält eine Kopie.** Geht der Server verloren, haben die Nutzer ihren Bestand weiterhin — er wandert beim nächsten Mal wieder hoch. Wäre der Server die Quelle der Wahrheit, wäre dieser Punkt ein Ausschlusskriterium.
- [ ] ⚠️ **Erreichbarkeit im Zielland prüfen.** Die Nutzer sind überwiegend persischsprachig. Ist die Supabase-Adresse dort nicht erreichbar, ist das kein Grund gegen die Phase — aber ein zwingender Grund für 27.7 („die App bleibt ohne Server voll benutzbar").

#### 27.3 Konfiguration im Code ✅ *(gebaut 2026-08-16)*
- [x] `app_config.dart` um `supabaseUrl`, `supabaseAnonKey` und `hasSupabaseConfig` erweitert (`String.fromEnvironment`, Standard **leer**); `.env.example` ergänzt.
- [x] **Neue Fähigkeit `supportsCloudSync`** in `platform_support.dart`. ⚠️ Sie hängt als einzige dort **nicht an der Plattform**, sondern an der Konfiguration — der Kommentar sagt das ausdrücklich, damit niemand sie später „vereinheitlicht".
- [x] ⚠️ **Der `anon`-Schlüssel ist der eine erlaubte Sonderfall** zur Regel aus 26.5: Er ist dafür gemacht, in Clients zu stehen. Die Begründung steht jetzt in `app_config.dart` — direkt neben dem Schlüssel, zusammen mit der Gegenwarnung zu `service_role`.
- [x] **`test/unit/cloud_config_test.dart`** hält die Zusage fest: ohne Schlüssel ist `supportsCloudSync` falsch. Sonst wäre „verhält sich wie vorher" eine Behauptung — und die App böte eine Anmeldung an, die nirgendwohin führt.
- [x] **`tool/build_web.sh` reicht die Werte durch.** Es liest `.env`, **falls** eine da ist, und nimmt sonst die Umgebungsvariablen — seit Phase 29 immer der zweite Fall. ⚠️ Eine vorhandene Umgebungsvariable gewinnt gegen die Datei. Leer bleibt zulässig: Dann hat die Web-Fassung schlicht keine Cloud.
- [x] **`main.dart` startet Supabase vor dem ersten Frame** — und nur, wenn konfiguriert. ⚠️ Der Aufruf kann den Start nicht verhindern: `initialize()` fängt jeden Fehler ab. Ein Server, der nicht antwortet, ist kein Grund, eine App nicht zu starten, die ohnehin lokal arbeitet.
- [x] **Schlüssel als GitHub-Actions-Secrets** (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, vom Nutzer am 2026-08-17 hinterlegt); der Bau-Schritt in `deploy-web.yml` reicht sie durch. ⚠️ Fehlen sie, sind die Werte leer und die Automatik baut eine Fassung **ohne Konto** — kein Fehler, sondern der Zustand von vor Phase 27.

#### 27.4 Server-Schema und Zugriffsregeln 🔄
- [x] **`supabase/schema.sql` liegt im Repository**, nicht nur in der Weboberfläche — sonst existiert die Server-Struktur an einer Stelle, die niemand versionieren, gegenlesen oder nach einem Unfall wiederherstellen kann. Mehrfach ausführbar.
- [x] Zwei Tabellen: `profiles` (Anzeigename) und `backups`. ⚠️ Bei `backups` ist `user_id` der **Primärschlüssel**, nicht nur ein Verweis: Eine Sicherung ist ein **Stand**, keine Historie — sonst sammelten sich stillschweigend Kopien an und niemand wüsste, welche gilt.
- [x] **Zwei voneinander unabhängige Schichten**, beide ausdrücklich im SQL: **Rechte** (wer darf die Tabelle überhaupt anfassen) und **RLS** (welche Zeilen). ⚠️ Die Rechte gehen **nur an `authenticated`, ausdrücklich nicht an `anon`** — wer nicht angemeldet ist, kommt gar nicht erst bis zu den Regeln. Selbst eine falsche Regel wäre damit für nicht angemeldete Zugriffe folgenlos.
- [x] **RLS auf beiden Tabellen, im selben Block wie das Anlegen**, mit je einer Regel pro Vorgang (select/insert/update/delete) statt einer `for all`-Regel: So steht jede erlaubte Handlung ausdrücklich da, und ein späteres Weglassen fällt beim Lesen auf.
- [x] **`updated_at` setzt der Server per Trigger**, nicht die App. Eine von der App gesetzte Zeit ist die Zeit einer möglicherweise falsch gestellten Geräteuhr — dieselbe Sorge, aus der `time_service.dart` entstand. „Zuletzt gesichert vor …" muss sich auf eine Uhr stützen, die der Nutzer nicht stellen kann.
- [x] ✅ **Gegenprobe bestanden — von außen, mit echten Konten** (`tool/rls_check.sh`, 2026-08-16, **13 von 13**). ⚠️ Ein `select` im SQL-Editor beweist hier nichts: Er läuft mit erhöhten Rechten und umgeht die Regeln. Geprüft wurde mit dem öffentlichen Schlüssel, also genau so, wie ein Fremder es täte:

  | Geprüft | Ergebnis |
  |---|---|
  | Ohne Anmeldung `profiles`/`backups` lesen | ✅ abgewiesen (HTTP 401) — die Rechte-Schicht greift |
  | Registrierung liefert sofort ein Token | ✅ **belegt nebenbei: „Confirm email" ist aus** |
  | A sieht ausschließlich die eigene Zeile | ✅ 0 fremde |
  | A fragt gezielt nach B's Zeile | ✅ leer |
  | A schreibt eine Sicherung auf **B's** Kennung | ✅ abgewiesen (HTTP 403) |
  | A schreibt seine eigene | ✅ geht |
  | B sieht A's Sicherung | ✅ nein |
  | B nimmt A's Benutzernamen | ✅ abgewiesen (HTTP 409, eindeutiger Index) |

- [x] **`tool/rls_check.sh` bleibt im Projekt** und liest die Zugangsdaten aus `.env`. ⚠️ **Nach jeder Änderung an `schema.sql` erneut laufen lassen** — eine Regel, die man nicht gegengeprüft hat, ist eine Hoffnung. Die zwei Testkonten liegen auf `@example.com` (per RFC 2606 reserviert, dort gibt es niemanden) und dürfen stehen bleiben.
- [x] ⚠️ **Offen und nicht zu vergessen:** „Konto löschen" kann der `anon`-Schlüssel nicht auslösen — der Eintrag in `auth.users` braucht erhöhte Rechte (Edge Function). Solange es die nicht gibt, löscht die App nur Daten und meldet ab; der leere Auth-Eintrag bleibt. **Für 27.8 zu klären.** ✅ **In 31.3 gebaut** (`delete_own_account()`) — wirksam, sobald `schema.sql` eingespielt ist.

#### 27.5 Anmelden in der App *(E-Mail + Passwort + Benutzername)*

**Registrierung: drei Felder.** E-Mail und Passwort gehen an Supabase, der Benutzername in unsere `profiles`-Tabelle. **Anmeldung: E-Mail + Passwort.**

✅ **Entschieden am 2026-08-16: Anmeldung über die E-Mail.** Die Alternative — Anmeldung mit dem Benutzernamen — hätte eine öffentliche Zuordnung Benutzername → E-Mail gebraucht (**verrät fremde Adressen**) oder eine Edge Function, die die Anmeldung serverseitig übernimmt. Der Benutzername ist damit der Name *in* der App, nicht die Kennung.

- [x] **`core/services/username_rules.dart`** *(hieß bis zum Wechsel `username_credentials.dart`)* — Normalisierung und Prüfung des Benutzernamens, reines Dart ohne Paket. Die Umrechnung in eine künstliche Adresse ist **ersatzlos entfallen**; sie war der Kern der alten Entscheidung und wäre jetzt toter Code, der jemanden in die Irre führt.
- [x] **Normalisiert (klein, ohne Leerraum), und zwar immer.** ⚠️ Ohne das wären „Ali" und „ali" zwei verschiedene Benutzernamen — und weil der Name eindeutig sein soll, wäre die Eindeutigkeit eine Illusion. Ein eigener Testfall hält es fest.
- [x] **Erlaubte Zeichen geprüft** (Kleinbuchstaben, Ziffern, `_`, `-`; 3–30 Zeichen; Rand alphanumerisch). Ablehnungsgründe kommen **sprachneutral** als `UsernameIssue` heraus — die App spricht drei Sprachen, der Dienst keine.
- [x] `test/unit/username_rules_test.dart`.
- [x] **`core/services/auth_service.dart`** — die einzige Stelle, die `supabase_flutter` kennt. Alle Methoden geben ein `AuthResult` zurück, **statt zu werfen**: Eine fehlgeschlagene Anmeldung ist ein erwarteter Verlauf, keine Ausnahme.
- [x] **Fehler werden über den `code` zugeordnet, nicht über die Meldung.** ⚠️ Der englische Text ist Prosa und ändert sich ohne Ankündigung; der Code gehört zur dokumentierten Schnittstelle. Wer `message.contains('already')` prüft, baut etwas, das beim nächsten Server-Update **still** bricht — die App läuft weiter, nur die Auskunft an den Nutzer wird nutzlos. Die Codes sind am 2026-08-16 in der Supabase-Dokumentation nachgelesen, nicht geraten.
- [x] ⚠️ **Ohne Konfiguration meldet jeder Aufruf `notConfigured`** — kein Wurf, kein Netzverkehr. Ein eigener Testfall geht alle Methoden in diesem Zustand durch.
- [x] **`supabase_flutter` ist nur eine Zeile in `initialize()`** — und die läuft nur, wenn `supportsCloudSync` wahr ist. ⚠️ Ein Fehler dort darf den App-Start **nicht** verhindern; die Methode fängt alles ab und meldet `false`.
- [x] ⚠️ **`anonKey` heißt in neueren Fassungen `publishableKey`** (beim Bauen aufgefallen, der alte Name ist als veraltet markiert). Derselbe Wert — in der Supabase-Oberfläche kann er als „anon public" **oder** „Publishable key" auftauchen. Steht als Kommentar an der Aufrufstelle, damit niemand zwei Schlüssel sucht.
- [x] `test/unit/auth_issue_test.dart` — 7 Fälle.
- [x] **Web-Bau gegengeprüft:** läuft, `main.dart.js` wächst durch das Paket auf ~4,4 MB (vorher ~4,0 MB). Vertretbar, aber es ist ein Zuwachs für **alle** — auch für die, die nie ein Konto anlegen.
- [x] **`features/auth/presentation/auth_sheet.dart`** — Anmelden und Registrieren in **einem** Sheet, umgeschaltet über einen Segment-Knopf. Dasselbe Muster wie `showShareProgressSheet()`: eine Funktion, ein Einstieg. Zwei Seiten mit fast gleichem Formular wären zwei Stellen für jede spätere Änderung.
- [x] **Die Übersetzung der Gründe steht in der Oberfläche, nicht im Dienst** (`authIssueText`, `usernameIssueText`). Der Dienst kennt keine Sprache, die Oberfläche keine Server-Codes. Wer das vermischt, braucht `BuildContext` in einem Dienst — und kann ihn nicht mehr testen.
- [x] **Der Benutzername wird geprüft, BEVOR ein Konto entsteht.** Sonst legte eine ungültige Eingabe erst das Konto an und scheiterte dann am Namen.
- [x] **`cloudSyncEnabledProvider`** statt eines direkten Zugriffs auf `supportsCloudSync` in der Oberfläche. ⚠️ Ohne ihn wäre die halbe Oberfläche dieser Phase **unprüfbar**: Im Testlauf gibt es keine Schlüssel, also verstecken sich die Widgets grundsätzlich.
- [x] ⚠️ **Reihenfolge bei der Registrierung, und was schiefgehen kann:** Erst `signUp(email, password)`, **dann** die Profilzeile mit dem Benutzernamen (die braucht die Kennung, die es erst danach gibt). Ist der Name schon vergeben, existiert das Konto bereits, die Profilzeile aber nicht — **kein kaputter Zustand, aber einer, der behandelt werden muss**: Die Oberfläche fragt nach einem anderen Namen, `claimUsername()` schreibt ihn nach. Das Konto darf dabei **nicht** gelöscht werden; nur der Name fehlt. ✅ **Seit 31.1 auch in der Oberfläche.**
- [x] **Verfügbarkeit vorab prüfen** über `username_available()` — reine Höflichkeit. ⚠️ **Die Wahrheit ist der eindeutige Index der Datenbank**: Zwischen Frage und Absenden kann ein anderer denselben Namen nehmen. Bei Zweifeln antwortet die Abfrage „frei" — ein Formular, das wegen einer wackligen Verbindung „vergeben" behauptet, hält jemanden von seinem eigenen Namen ab. ✅ Seit 31.1 fragt das Formular.
- [ ] **„Passwort vergessen" ist vorgesehen**, funktioniert aber erst mit eigenem SMTP (27.2). ⚠️ Solange es das nicht gibt, darf der Knopf **nicht** dastehen und ins Leere greifen — dieselbe Regel wie bei den Erinnerungen im Browser (26.1).
- [x] **Rubrik „Konto & Cloud" auf der bestehenden Konto-Seite** (`account_cloud_card.dart`) — **nicht** in einer eigenen Rubrik daneben. ⚠️ Entscheidung des Nutzers und die richtige: Ein Konto ist genau das, worum es auf dieser Seite ohnehin geht; ein zweiter Ort für dasselbe Thema wäre die verbotene Doppelung, und der Nutzer müsste sich merken, welcher der beiden Orte was kann.
- [x] Zeigt: angemeldet als … · die hinterlegte E-Mail **sichtbar** samt Hinweis (Gegenmaßnahme zum Tippfehler, 27.0b) · Stand der letzten Sicherung · Sichern · Wiederherstellen · Abmelden. **Verschwindet vollständig ohne Cloud.**
- [x] Texte in **allen drei** ARB-Dateien, `flutter gen-l10n` gelaufen (Lehre 20).
- [x] **Fehlermeldungen sprachneutral** durchgereicht und erst in der Oberfläche übersetzt.
- [x] `test/support/fake_auth_service.dart` + `test/widget/account_cloud_card_test.dart` (6 Fälle, darunter **„ohne Cloud ist die Rubrik gar nicht da"**, das Konto ohne Benutzernamen und die persische Fassung). ⚠️ **Kein Test spricht mit dem echten Server.**
- [x] „Konto löschen" — ✅ gebaut in 31.3.

#### 27.6 Profil in der Cloud ✅ *(gebaut 2026-08-17)*
- [x] **`profile_cloud_sync.dart`** — beim Anmelden abgleichen, bei lokaler Änderung hochladen. Angehängt an dieselbe Listener-Stelle in `app.dart` wie Widget und Tagesstand.
- [x] ⚠️ **Die Regel für den Zusammenstoß steht ausdrücklich da, nicht im Zufall:**

  | lokal | Server | Ergebnis |
  |---|---|---|
  | leer | gesetzt | Server gewinnt (neues Gerät, der Name kommt zurück) |
  | gesetzt | leer | lokal wird hochgeladen |
  | gesetzt | gesetzt | **lokal gewinnt** |
  | leer | leer | nichts zu tun |

  **Warum bei Gleichstand das Gerät gewinnt:** Es ist die Quelle der Wahrheit (Abschnitt 3). Der Nutzer sitzt vor diesem Gerät; würde ihm ein älterer Name vom Server über den gerade eingegebenen gelegt, sähe es wie ein verlorener Eintrag aus. Andersherum verliert er höchstens einen Namen, den er anderswo gesetzt hat — sichtbar und korrigierbar.

#### 27.7 Cloud-Sicherung des ganzen Bestands ✅ *(gebaut 2026-08-17)*
- [x] **Format ist das vorhandene Backup-JSON** (`backup_data.dart`) — dieselbe Serialisierung wie Export/Import, dieselben fünf Tests, dieselbe Versions-Prüfung. Kein zweites Format: Jede spätere Änderung am Datenmodell müsste sonst an zwei Stellen nachgezogen werden, und die zweite würde vergessen.
- [x] **`cloud_backup_service.dart`** mit `upload` / `fetch` / `restore` / `lastBackupAt`. ⚠️ **`fetch` und `restore` sind getrennt**, damit die Oberfläche vorher sagen kann, *was* überschrieben würde. Ein Wiederherstellen ohne diese Ansage wäre der schnellste Weg, jemandem seinen Bestand zu nehmen.
- [x] **`lastBackupAt()` fragt nur den Zeitstempel ab**, nicht die Sicherung. Sonst lüde jeder Aufbau der Konto-Seite den gesamten Bestand herunter — bei einem gewachsenen Verlauf einige hundert Kilobyte für eine Zeile Text.
- [x] **Hochladen automatisch** (`cloud_auto_backup.dart`), **als dritter Empfänger an demselben Sender** wie Startbildschirm-Widget und Tagesstand (Phase 23). ⚠️ **Entprellt (20 s)** — ohne das schickte eine Morgenrunde mit acht Häkchen achtmal den ganzen Bestand.
- [x] **Zweiter Auslöser für Gewohnheiten/Kategorien:** Sie ändern den Bestand, ohne den heutigen Fortschritt zu berühren — eine umbenannte Gewohnheit landete sonst erst beim nächsten Abhaken in der Sicherung.
- [x] **Herunterladen nur auf Nachfrage**, mit Bestätigungsdialog, der ausspricht, dass der lokale Bestand vollständig ersetzt wird.
- [x] Sichtbarer Stand „zuletzt gesichert" — eine Sicherung, deren Alter man nicht sieht, ist eine Vermutung. Der Zeitstempel kommt **vom Server** (Trigger), nicht von der Geräteuhr.
- [x] ⚠️ **Scheitern ist folgenlos und stumm.** Die automatische Sicherung meldet keinen Fehler und startet keinen Wiederholungs-Sturm; die nächste Änderung versucht es ohnehin erneut. Eine automatische Sicherung, die den Nutzer mit Fehlern behelligt, wäre schlimmer als keine. Nur die **von Hand** ausgelöste sagt, was passiert ist.
- [x] ⚠️ **Eine Sicherung aus einer neueren App-Fassung wird abgelehnt** (`tooNew`), nicht halb eingespielt: Ein älterer Leser verlöre Felder, die er nicht kennt — und das fiele erst viel später auf.
- [ ] ⚠️ **Die Grenze bleibt:** Das ist eine **Sicherung**, kein Abgleich. Wer auf zwei Geräten arbeitet, hat zwei Bestände; die Wiederherstellung überschreibt. Ein echter Abgleich braucht Zeitstempel je Zeile und Grabsteine für Löschungen — eine eigene Phase, keine Fußnote.

#### 27.8 Datenschutz nachziehen ✅

⚠️ **Mit der Entscheidung für echte E-Mails wiegt dieser Abschnitt schwerer als geplant.** Eine E-Mail-Adresse ist ein personenbezogenes Datum; damit werden auch Gewohnheiten und Erledigungen personenbezogen, weil sie einer identifizierbaren Person zugeordnet sind. Das ist keine Formalie mehr.

⚠️ **Die Begründung hat einmal gewechselt, die Pflicht nie.** Bis zum 2026-08-17 stand hier „blockiert die Play-Veröffentlichung". Mit der Streichung von Store und Android (Phase 28) wäre diese Begründung ersatzlos weggefallen — die Pflicht aber nicht: Wer 200 Schülern eine Adresse gibt und ihre E-Mail speichert, schuldet ihnen einen zutreffenden Text, ganz ohne Store. **Ein Grund, der beim ersten Gegenwind verschwindet, war der falsche Grund.**

- [x] **`store/PRIVACY_POLICY.md` überarbeitet, beide Sprachfassungen.** Neuer Punkt 4 („Konto und Sicherung auf dem Server") nennt in einer Tabelle **welche** Daten, **wozu**, **wo** (Supabase, EU/Frankfurt), **wer sie sieht** (nur der Eigentümer, technisch über RLS), **wann** hochgeladen wird und **wie** man sie loswird. Die Kurzfassung sagt in beiden Sprachen zuerst: **ohne Konto verlässt nichts das Gerät.**
- [x] **Punkt 9 (Rechte) neu geschrieben** — der alte Satz „wir speichern nichts, also gibt es nichts herauszugeben" ist mit Konto schlicht falsch. Jetzt: Auskunft/Übertragbarkeit über den vorhandenen Export, Berichtigung in der App, Löschung, Rechtsgrundlage Einwilligung, Aufsichtsbehörde.
- [x] **Die Erststart-Erklärung sagt es jetzt richtig** (alle drei Sprachen): „Deine Daten bleiben auf diesem Gerät; ein Konto ist freiwillig und legt zusätzlich eine Sicherung an." Der alte Satz behauptete das Gegenteil dessen, was die App seit heute kann.
- [x] **„Daten auf dem Server löschen"** in der Rubrik „Konto & Cloud" (`deleteServerData()`): löscht Sicherung und Profilzeile, lässt den lokalen Bestand unangetastet. ⚠️ **Das ist bewusst nicht als „Konto löschen" beschriftet** — der Eintrag in `auth.users` bleibt, weil der öffentliche Schlüssel ihn nicht entfernen darf. Die Datenschutzerklärung nennt dafür den Weg über eine Nachricht; sie darf den Knopf **nicht** als vollständige Löschung ausgeben.
- [x] ~~**Den Gist neu speichern**~~ — **gegenstandslos seit 29.5:** Die Erklärung entsteht bei jedem Bau als `privacy.html`. Dem Nutzer bleibt nur, den alten Gist zu löschen.
- [x] **Vollständige Kontolöschung in der App** ✅ 31.3 — wirksam, sobald `schema.sql` eingespielt ist.
- [x] **Abschnitt 3 und die Datenschutz-Aussage im Onboarding geprüft** (2026-09-13): Abschnitt 3 beschreibt Gerät + freiwillige Kopie; `onboardingWelcomeBody` sagt „Deine Daten bleiben auf diesem Gerät; ein Konto ist freiwillig und legt zusätzlich eine Sicherung an." — beides stimmt.

#### 27.9 Prüfen
- [x] **Im echten Browser angesehen** (lokaler Bau **mit** Schlüsseln, Safari im Telefon-Format): Die Rubrik „Konto & Cloud" steht oben auf der Konto-Seite, persisch und rechtsläufig, mit dem Knopf „ورود". Bildschirmfoto gemacht — nicht aus grünen Tests geschlossen.
- [x] ⚠️ **Dabei ist Lehre 32 noch einmal aufgetreten:** Die erste Prüfung suchte den Titel „حساب و ابر" im Semantik-Baum und meldete „nicht da", obwohl die Karte deutlich sichtbar war. Reine Texte stehen dort unzuverlässig, **Knöpfe immer** — der Knopf „ورود" war der Beleg. Wer eine Oberfläche über Semantik prüft, prüft an Knöpfen.
- [x] Tests grün, `flutter analyze` sauber, **und der Bau ohne Schlüssel verhält sich wie vorher** (eigener Testfall).
- [x] **`tool/webtest.py` erweitert — jetzt 20 Prüfungen**, die letzten beiden für die Konto-Rubrik. ⚠️ Der Durchgang enthält **keine** Zugangsdaten und meldet sich nicht an: Ein Oberflächen-Test, der Konten anlegt, hinterlässt bei jedem Lauf Datenmüll auf dem Server. Geprüft wird, dass die Rubrik **da ist und Anmelden anbietet** — dass die Anmeldung selbst trägt, beweist `tool/rls_check.sh` mit echten Konten von außen. **Zwei Werkzeuge, zwei Zuständigkeiten.**
- [x] ⚠️ **Fehlt der Schlüssel, ist die fehlende Rubrik richtig** — der Durchgang unterscheidet das und meldet keinen Fehlschlag, statt eine der beiden Lagen falsch zu bewerten.
- [x] **Regeltests nachgezogen**, die vorher nur als Prosa im Plan standen: `profile_cloud_sync_test.dart` (7 Fälle — die ganze Zusammenstoß-Tabelle aus 27.6) und `cloud_backup_service_test.dart` (4 Fälle, Verhalten ohne Konto). ⚠️ Eine Regel, die nur im Dokument steht, hält niemanden auf: Wer sie beim nächsten Umbau umdreht, bekommt keinen Fehler — nur einen Nutzer, dem beim Anmelden der Name überschrieben wird.
- [x] ⚠️ **Lehre 32 ist beim Bauen dieser Prüfung ein DRITTES Mal zugeschnappt.** Wieder wurde nach einer Überschrift gesucht („نمایه"), wieder meldete die Prüfung „nicht da", während das Gesuchte auf dem Bildschirmfoto stand. Konsequenz: Die Warnung steht jetzt **im Docstring von `shows()`** — dort liest sie, wer sie braucht. Ein Hinweis, der nur im Plan steht, erreicht den Moment des Tippens nicht.
- [ ] Gerätedurchgang: anmelden, Bestand anlegen, App löschen und neu installieren, wiederherstellen. **Das ist die eigentliche Prüfung dieser Phase** — alles davor ist Vorbereitung.
- [ ] ⚠️ **Flugmodus-Durchgang:** vollständige Benutzung ohne Netz, danach mit Netz die Sicherung nachziehen.

#### 27.11 Der geteilte Link führte ins Leere ✅ *(2026-08-17)*
**Vom Nutzer gemeldet:** *„موقع اشتراک گذاری لینک اشتباهی زیرش میاد"* — beim Teilen steht der falsche Link darunter.

**Nachgemessen, nicht angenommen:**

| Adresse | Antwort |
|---|---|
| `play.google.com/store/apps/details?id=com.rootin.app` (bisher geteilt) | **HTTP 404** |
| `lukasylilli.github.io/Root-in/` (jetzt geteilt) | HTTP 200 |

Die Fortschritts-Karte trug seit Phase 19 den Play-Store-Link — für eine App, die dort **nie veröffentlicht wurde**. Jeder geteilte QR-Code führte auf eine „nicht gefunden"-Seite von Google.

⚠️ **Warum das besonders unangenehm ist:** Ein geteiltes Bild bleibt in Chats liegen. Wer den Code scannt und eine Fehlerseite bekommt, probiert es kein zweites Mal — **und meldet es auch nicht.** Der Schaden ist still und dauerhaft.

- [x] **`appShareUrl` ist die neue eine Quelle** und zeigt auf die **Web-Fassung**. Zwei Gründe, und der zweite gilt auch nach einer Play-Veröffentlichung weiter: Der Link war schlicht tot — **und** eine Play-Seite schließt genau die iPhone-Nutzer aus, für die die Web-Fassung überhaupt gebaut wurde (Phase 26). Wer teilt, weiß nicht, was der Empfänger benutzt.
- [x] ⚠️ **Der bestehende Test hat den Fehler mitgetragen.** Er prüfte, dass `playStoreUrl` korrekt gebildet ist — das war es. Es war nur die **falsche** Adresse. Geprüft wird jetzt `appShareUrl`, dazu `test/unit/app_links_test.dart` mit der ausdrücklichen Regel „geteilt wird die Web-Fassung, nicht der Store".

✅ **Mit Phase 28 ist die Frage entschieden:** Es gibt keine Store-Veröffentlichung, `playStoreUrl` ist gestrichen, `appShareUrl` zeigt auf die Web-Fassung — die einzige, die es gibt.

#### 27.10 Risiken, die diese Phase mitbringt
| Risiko | Folge | Umgang |
|---|---|---|
| Server im Zielland nicht erreichbar | Anmeldung und Sicherung scheitern | App bleibt ohne Server voll benutzbar (27.7); Scheitern ist folgenlos |
| Kostenloses Projekt pausiert nach **1 Woche ohne Zugriff** | Sicherungen laufen ins Leere | Nach der Verteilung kein Thema (tägliche Nutzung); **während der Bauzeit einplanen**. Alter der Sicherung sichtbar machen |
| Kein tägliches Server-Backup im freien Tarif | Serverdaten könnten verloren gehen | tragbar, **weil** das Gerät die Quelle der Wahrheit bleibt — der Bestand wandert wieder hoch |
| **Kein eigener SMTP-Dienst** | Passwort-Zurücksetzen unmöglich; eingebauter Versand schafft **2 Nachrichten/Stunde** und nur an eigene Team-Adressen | E-Mail jetzt schon erfassen, „Confirm email" aus; SMTP nachrüsten — wirkt rückwirkend für alle (27.0b/27.2) |
| **Tippfehler in der E-Mail** (weil unbestätigt) | fällt erst beim Zurücksetzen auf, also im schlechtesten Moment | Adresse sichtbar und änderbar in „Konto & Cloud" (27.5) |
| **E-Mail = personenbezogenes Datum** | Die Datenschutzerklärung wird falsch | 27.8 — Pflicht gegenüber echten Nutzern, ganz ohne Store |
| RLS vergessen oder falsch | **fremde Daten für jeden lesbar** | RLS im selben Schritt wie die Tabelle, Gegenprobe in 27.4 |
| `service_role`-Schlüssel gerät in die App | vollständiger Datenbank-Zugriff für jeden | Schlüssel nie ins Repository; im Bundle nach ihm suchen — ✅ **seit 31.5 bei jedem Bau automatisch** (`tool/check_bundle_secrets.py`, blockierend) |
| Zwei Geräte, ein Konto | ein Bestand überschreibt den anderen | Sicherung statt Abgleich, Wiederherstellung nur auf Nachfrage |

---

### Phase 28 — Nur noch Web ✅ *(umgesetzt 2026-08-17)*

**Vier Anweisungen des Nutzers, in seinen Worten:**

1. *„حریم خصوصی رو خودت اپدیت کن"* — die Datenschutzerklärung selbst nachziehen.
2. *„یاد آور ها رو کلا حذف کن چون نسخه وب نمیتونه الارم داشته باشه"* — Erinnerungen **ganz** entfernen; die Web-Fassung kann keinen Wecker stellen.
3. *„کلا انتشار در اپ استور و گوگل پلی و نسخه اندروید رو از پلن حذف کن، فقط نسخه وب خواهیم داشت"* — Store-Veröffentlichung und Android-Fassung aus dem Plan **streichen**. Es wird nur die Web-Fassung geben.
4. *„کل اپ رو قراره برای همیشه تو نسخه وب داشته باشم و کلا از مک پاکش کنم … بقیه تغییرات رو داخل گیت هاب ادامه میدیم"* — das Projekt verschwindet vom Mac; weitergearbeitet wird auf GitHub.

⚠️ **Das ist keine Verschiebung mehr, sondern eine Streichung.** Am Vormittag desselben Tages wurden Phase 15 und 12 „zurückgestellt, **nicht** gestrichen" — mit der Begründung, eine zurückgedrehte Entscheidung solle nicht bei null anfangen. Diese Begründung ist hinfällig. Was gestrichen ist, verschwindet auch aus dem Plan: **Ein Plan, der Wege aufbewahrt, die niemand mehr gehen wird, ist ein Archiv und kein Plan.** Die Versionsgeschichte behält alles — wer die Android-Fassung je zurückholen will, findet sie vollständig im Stand vom 2026-08-17.

#### 28.0 ⚠️ Was beim Löschen des Macs verloren geht — VOR dem Löschen lesen

Nach dem Löschen gibt es **keine zweite Kopie**. Alles, was nicht im Repository liegt, ist dann weg:

| Was | Lage | Zu tun |
|---|---|---|
| **`meine/`** — 19 Vorlagen-Bilder, die Berg-Animations-Vorlage (React/SVG), zwei Design-Specs, `Logo.jpeg` | ✅ **seit 2026-09-12 im Repository** — auf Entscheidung des Nutzers (bis dahin bewusst ausgeschlossen, 0 von 24 Dateien versioniert) | nichts mehr |
| `.env` (Supabase-Adresse + öffentlicher Schlüssel) | ⛔ nicht versioniert | **Kein Verlust:** Beide Werte liegen als GitHub-Actions-Secrets, und der `anon`-Schlüssel steht ohnehin auslesbar im veröffentlichten Bundle (Lehre 26). Die Automatik baut also weiter |
| `assets/icon/app_icon.png` (1024×1024) | ✅ versioniert | nichts — das App-Symbol überlebt. `Logo.jpeg` als Ursprung liegt in `meine/` |
| Signaturschlüssel `~/development/keys/root-in-upload.jks` | ⛔ außerhalb des Projekts | Mit Anweisung 3 **gegenstandslos**. Wer ihn trotzdem behalten will, sichert ihn jetzt; ohne ihn ist eine Play-Veröffentlichung später unmöglich |
| `.claude/settings.local.json` | ⛔ nicht versioniert | egal — maschinenlokal |

#### 28.1 Erinnerungen vollständig entfernt ✅

Nicht „im Browser ausblenden" (so war es seit 26.1), sondern **weg**. Betroffen sind neun Ebenen, und keine darf übrig bleiben — ein halb entfernter Feature-Strang ist schlimmer als gar keiner:

- [x] `core/services/notification_service.dart` und `features/settings/presentation/reminders_page.dart` löschen
- [x] Route `/reminders` aus `app_routes.dart` + `app_router.dart`, Eintrag aus `settings_page.dart`
- [x] Erinnerungs-Schalter und Time-Picker aus `habit_form_sheet.dart`
- [x] `setHabitReminder` / `rescheduleAllReminders` aus `habit_repository.dart`, `setReminder` / `habitsWithReminder` aus `habit_dao.dart`
- [x] Tagesstand-Meldung (Phase 23): Listener in `app.dart`, `status_notification_enabled` in `settings_service.dart`
- [x] ⚠️ **DB-Spalten `reminderEnabled` / `reminderMinuteOfDay`: `schemaVersion` 3 → 4 mit `onUpgrade`-Zweig UND Migrations-Test.** „Datenerhalt geht vor" (Abschnitt 9) gilt beim Entfernen genauso wie beim Hinzufügen — Bestandsnutzer der Web-Fassung haben echte Daten
- [x] Pakete: `flutter_local_notifications`, `timezone`, `flutter_timezone`
- [x] ARB-Schlüssel in **allen drei** Sprachen, danach `flutter gen-l10n` (Lehre 20)
- [x] Tests: `reschedule_reminders_test.dart`, `daily_status_notification_test.dart`, `reminders_page_test.dart`, `support/fake_notification_service.dart` weg; `habit_form_sheet_test.dart`, `persian_ui_test.dart` nachziehen

#### 28.2 Android, iOS und Desktop entfernt ✅
- [x] Ordner `android/`, `ios/`, `macos/`, `linux/`, `windows/`
- [x] `home_widget_service.dart` samt der neun Startbildschirm-Widgets und `colorTileInteractionCallback`
- [x] Pakete `home_widget` und `flutter_file_dialog`. ⚠️ **Der bedingte Import in `file_pick/` bleibt** — `flutter test` läuft auf der Dart-VM und wählt dort den `_io`-Zweig; er wird zu einem ehrlichen Stub, nicht gelöscht
- [x] `platform_support.dart` schrumpft auf das, was im Browser noch eine Frage ist
- [x] Store-Material: `store/PLAY_LISTING.md`, Feature-Grafik, Play-Symbol, Screenshots
- [x] ⚠️ **`store/PRIVACY_POLICY.md` bleibt** — sie hängt nicht am Store (siehe 28.3)

#### 28.3 Datenschutzerklärung ✅
- [x] Erinnerungen und Benachrichtigungen aus dem Text nehmen, Android-/Play-Bezüge streichen
- [x] ~~**Der Gist bleibt Nutzersache**~~ — mit 29.5 überholt: Die Erklärung veröffentlicht sich selbst; der Gist ist nur noch zu löschen

#### 28.4 Weiterarbeit auf GitHub ✅
- [x] Alles gepusht, `main` grün (die Automatik läuft `analyze` + `test` **vor** jeder Veröffentlichung).
- [x] **Veröffentlichte Seite nachgewiesen — im iOS-Simulator, nicht mit `webtest.py`.** Das Bildschirmfoto zeigt die neue Erklärung mit **drei** Punkten. ⚠️ `webtest.py` war zu diesem Zeitpunkt auf diesem Rechner nicht mehr brauchbar (Lehre 38); ein Werkzeug, das nicht mehr misst, wird nicht zur Abnahme herangezogen.
- [x] ➜ **Was danach kommt, steht in [Phase 29](#phase-29--arbeiten-und-prüfen-ohne-rechner--beauftragt-2026-08-17):** Der Wegfall des Rechners nimmt zwei von drei Prüfständen mit. Das ist kein Nebeneffekt dieser Phase, sondern ihre eigentliche Folge.

#### 28.5 Was dabei gefunden wurde

- ⚠️ **Der erste Web-Bau nach dem Entfernen der Pakete schlug fehl** — `Couldn't resolve flutter_local_notifications_web`. Die Ursache war ein **stehengebliebener generierter** `web_plugin_registrant.dart` im `.dart_tool`. `flutter clean` räumt ihn weg. Im CI fällt das nie auf (frischer Checkout) — es trifft nur den, der lokal weiterbaut.
- ⚠️ **`file_pick/pick_text_file_io.dart` musste bleiben.** Der Reflex war, mit der letzten mobilen Plattform auch den `_io`-Zweig zu löschen. Das hätte **jeden Test** unübersetzbar gemacht: `flutter test` läuft auf der Dart-VM, und der bedingte Import wählt dort genau diesen Zweig. Er ist jetzt ein Stub mit einer Begründung im Docstring — kein toter Code, sondern eine Notwendigkeit der Testumgebung.
- ⚠️ **Zum Schluss ein Fehlalarm, der fast zu einer Fehlersuche im Code geführt hätte.** `tool/webtest.py` meldete gegen die veröffentlichte Seite dreimal „nichts gezeichnet". Verdächtigt wurden nacheinander `--csp`, `-O4`, der `--base-href` und die neue Datenbank-Migration; jede These wurde gebaut und gemessen, jede war falsch. Entschieden hat die Gegenprobe: **derselbe Durchgang gegen den Stand vor Phase 28 scheiterte genauso**, und dieselbe Kombination hatte eine Stunde zuvor 20/20 bestanden. Es lag am Rechner (Lehre 38). **Der Beweis, dass die App läuft, kam am Ende aus dem iOS-Simulator** — ein Bildschirmfoto der veröffentlichten Seite, mit den drei statt vier Erklärungs-Punkten.
- **Die Migration war der heikelste Teil.** Eine Spalte zu entfernen heißt in SQLite, die Tabelle neu zu bauen — genau dabei können IDs verrutschen, und an `habits.id` hängt jede Erledigung. Der neue Testfall zieht deshalb einen echten Schema-3-Bestand **mit gesetzter Erinnerung** hoch und prüft beides: dass die Zeilen mit ihren IDs stehen **und** dass die Spalten wirklich weg sind. Gegenprobe gemacht (Lehre 32): ohne `alterTable` wird er rot.

---

### Phase 26 — Web-Fassung: was noch offen ist 🔄
**Die einzige Plattform** (Abschnitt 2). Die Fassung ist gebaut und veröffentlicht; zuletzt am 2026-08-17 mit 20/20 in Safari geprüft; **seit 29.3 prüft die Automatik bei jedem Push in Chrome** (10 Punkte, blockierend).

**Der Durchgang auf einem echten iPhone** — er war schon vorher der einzige Test, den weder Safari am Mac noch der Simulator ersetzen konnten (in beiden lässt sich das Ablegen nicht nachstellen, 26.12). ⚠️ **Seit Phase 29 ist er nicht mehr nur der beste, sondern der einzige Blick auf die echte Oberfläche:**

- [ ] Seite in Safari öffnen → erscheint der Speicher-Hinweis genau **einmal**?
- [ ] „Zum Home-Bildschirm" → startet sie **ohne Adressleiste**? Stimmt das App-Symbol?
- [ ] **Bestätigung von 26.13:** Erststart durchtippen — reagieren die Knöpfe **dort, wo sie stehen**? ⚠️ Vorher das alte Symbol **löschen** und neu ablegen, sonst startet die abgelegte Fassung weiter mit der alten `index.html` aus dem Zwischenspeicher.
- [ ] Konto anlegen, Gewohnheit anlegen, „Jetzt sichern" → liegt in Supabase eine Zeile in `backups`?
- [ ] App vom Home-Bildschirm löschen, neu ablegen, anmelden, **wiederherstellen** — ist der Bestand zurück?
- [ ] Bleiben die Daten nach dem Schließen? Funktionieren Teilen und Export?

⚠️ **GitHub Pages kann `Cross-Origin-Opener-Policy`/`Embedder-Policy` nicht setzen.** Drift nutzt dann nicht die schnellste Speicherart. **Die Daten bleiben erhalten** — eine Frage der Geschwindigkeit, kein Datenverlust. Wer das ändern will, braucht einen Hoster mit eigenen Kopfzeilen.

---

### Phase 29 — Arbeiten und Prüfen ohne Rechner ✅ *(beauftragt 2026-08-17)*
**Umgesetzt am 2026-09-12.** Beim Nutzer bleibt nur, den alten Gist zu löschen (29.5).

**Vom Nutzer:** *„هیچ چیزی دیگ از داخل مک و پوشه های محلی برنامه نویسی و یا کد نویسی نمیشه چون در حال پاک کردن هر چیزی هستم که توی گیت هاب نیست. از الان به بعد تمام تغییرات فقط در گیت هاب."* Dazu wird VS Code gelöscht; gearbeitet wird künftig aus der Cloud heraus.

⚠️ **Diese Phase ist keine Aufräumarbeit, sondern schließt ein Loch, das der Wegfall des Rechners aufreißt.** Die Tabelle in Abschnitt 9 zeigt es: Von drei Prüfständen bleibt einer automatisch (`analyze` + `test`), einer verwaist (`rls_check.sh`), einer fällt ganz weg (`webtest.py`). **Keiner der 205 Tests öffnet einen Browser** — genau die Lücke, durch die in Phase 26 drei kaputte Hauptseiten geschlüpft sind (Lehre 31).

#### 29.1 Was schon getragen hat ✅
- [x] Die Automatik prüft **vor** jeder Veröffentlichung: `pub get` → `analyze` → `test` → bauen → Pages. Eine rote Prüfung veröffentlicht nicht.
- [x] Die Supabase-Schlüssel liegen als Repository-Secrets, nicht in einer Datei auf dem Rechner (27.3) — die Automatik baut also weiter, wenn `.env` verschwindet.
- [x] `tool/build_web.sh` ist die **eine** Stelle der Bau-Schalter, und die Automatik ruft genau dieses Skript. Es gibt keinen „Bau von Hand", der davon abweichen könnte.
- [x] `tool/fetch_web_db_assets.sh` holt `sqlite3.wasm` und `drift_worker.js` **im Lauf** — beide sind bewusst nicht versioniert und fehlen deshalb nie, weil sie jedes Mal frisch kommen.

#### 29.2 `rls_check.sh` erreichbar machen ✅
- [x] **`.github/workflows/rls-check.yml`** mit `workflow_dispatch` — von Hand auslösbar über *Actions → Server-Zugriffsregeln prüfen → Run workflow*.
- [x] **Das Skript musste nicht angefasst werden.** Es liest `.env` nur, **falls** vorhanden, und nimmt sonst die Umgebungsvariablen; die kommen aus denselben Secrets wie der Bau. ⚠️ Gegenprobe gemacht, nicht angenommen: in einem leeren Verzeichnis, mit `env -i` und nur den zwei Werten — **13/13**.
- [x] ⚠️ **Nicht bei jedem Push.** Der Durchgang legt zwei echte Testkonten an (`@example.com`, RFC 2606); der Anlass ist ohnehin ein anderer — **nach jeder Änderung an `supabase/schema.sql`**.
- [x] ⚠️ **Nur der `anon`-Schlüssel wird durchgereicht**, und das ist der Sinn: Die Prüfung fragt mit denselben Rechten, die jeder Fremde hat. Mit `service_role` liefe sie an allen Regeln vorbei und bewiese das Gegenteil dessen, was sie beweisen soll.

#### 29.3 Ersatz für den Browser-Durchgang ✅
- [x] **`tool/webtest_ci.py`**, eingehängt in `deploy-web.yml` **vor** der Veröffentlichung. Dasselbe WebDriver-Protokoll wie `webtest.py`, nur gegen ChromeDriver (auf `ubuntu-latest` vorhanden), über `urllib` — **keine neue Abhängigkeit**.
- [x] Geprüft werden 10 Punkte: zeichnet die App · Erststart-Erklärung · Speicher-Hinweis · Merker im Browser-Speicher · Datenbank angelegt · die drei Reiter **mit Inhalt** (nicht nur „der Reiter ist da" — er war auch da, als drei Seiten leer blieben, 26.10).
- [x] **Die teuer bezahlten Regeln sind mitgenommen:** Zeichenfläche im Schatten-DOM (Lehre 36), an Knöpfen ablesen (32/35), auf Zustände warten (36), beim gescheiterten Start abbrechen (36).
- [x] ⚠️ **Zwei Wege, die NICHT funktionieren — gemessen, nicht vermutet.** `chrome --headless --screenshot` liefert blankes Grün: Virtuelle Zeit lässt WebAssembly nicht fertig werden. Mit `--run-all-compositor-stages-before-draw` läuft der Aufruf **endlos**, weil eine Flutter-App nie ruhig wird (die Sterne auf der Home-Seite animieren dauerhaft) — nach 10 Minuten abgebrochen. Deshalb ein echter Treiber statt eines Bildschirmfotos.
- [x] ⚠️ **Er blockiert die Veröffentlichung.** Der erste Einbau lief mit `continue-on-error: true`, weil er vorher nirgends erprobt werden konnte. **Daran fiel auf, dass diese Zeile die Prüfung wertlos macht:** Ein solcher Schritt meldet auch dann „success", wenn er fehlgeschlagen ist — von außen nicht zu unterscheiden, und das Protokoll braucht eine Anmeldung (HTTP 403). Ein Tor, das immer offen steht, ist eine Tür im Feld.
- [x] **Das Skript sagt seine Diagnose als Arbeitsablauf-Anmerkung** (`::error::`). Anmerkungen sind bei einem öffentlichen Repository **ohne Anmeldung lesbar**, das Protokoll nicht — ohne sie ist ein gescheiterter Lauf von außen stumm.
- [x] ⚠️ **Gegen den kaputten Stand gehalten — unfreiwillig, aber vollständig** (Lehre 32): Der erste blockierende Lauf war **rot**, mit 6 von 10 Prüfungen. Die Anmerkung nannte den Grund, die Ursache war eine einzige: Der **Speicher-Hinweis** aus 26.8 ist ein modaler Dialog und stand allen Reitern im Weg; beim Übertragen aus `webtest.py` war dieser eine Schritt verloren gegangen. Damit ist bewiesen, dass der Durchgang rot werden **kann** — die Frage, die bei jedem neuen Test offen bleibt.

#### 29.4 Was im Repository nicht mehr gebraucht wird ✅
- [x] `Root-in.code-workspace` entfernt — VS Code ist gelöscht.
- [x] `.claude/settings.json` **bleibt**. Sie beschreibt zwar eine Freigabeliste für Claude Code auf einem Rechner, schadet aber nichts, und ob sie in der Cloud greift, ist hier nicht geprüft — eine Datei auf Verdacht zu löschen wäre schlechter als sie stehen zu lassen.
- [x] ⚠️ **`tool/webtest.py` bleibt.** Es ist nicht mehr ausführbar (macOS), aber die Vorlage, aus der 29.3 entstanden ist — und der Beweis dafür, dass ein einziger übersehener Schritt beim Abschreiben sechs Prüfungen rot färbt.

#### 29.5 Die Datenschutzerklärung veröffentlicht sich selbst ✅

**Vom Nutzer:** *„schreib privacy-policy in plan und map, damit ich später es online schreiben kann."*

⚠️ **Eine Kopie in PLAN/MAP hätte genau den Fehler wiederholt, der den Gist zweimal veralten ließ** (nach Phase 20 und nach 27.8). Die Ursache war nie Nachlässigkeit, sondern die zweite Kopie: Wer eine Quelle zweimal pflegen muss, pflegt sie irgendwann einmal. Also nicht abschreiben — **den Handgriff abschaffen.**

- [x] **`tool/build_privacy_page.py`** wandelt `store/PRIVACY_POLICY.md` bei **jedem Bau** in `build/web/privacy.html`. Eine Änderung an der Markdown-Datei **ist** damit die Veröffentlichung.
- [x] Erreichbar unter **`https://lukasylilli.github.io/Root-in/privacy.html`** — dieselbe Adresse wie die App, dieselbe Automatik.
- [x] **Abhängigkeitsfrei.** Das Dokument benutzt genau sieben Markdown-Elemente (nachgezählt); ein Wandler dafür ist kürzer als die Diskussion über `pip install`. Dieselbe Überlegung wie bei `store/make_feature_graphic.py`.
- [x] ⚠️ **Die INTERNE NOTIZ am Dateiende wird abgeschnitten**, statt sich darauf zu verlassen, dass ein Browser HTML-Kommentare versteckt — sonst stünde sie im Quelltext der Seite.
- [x] **Eintrag „Datenschutzerklärung" in den Einstellungen**, in allen drei Sprachen. Eine Erklärung unter einer Adresse, die niemand kennt, erfüllt ihren Zweck nicht — und die App speichert E-Mail-Adressen.
- [x] `test/unit/privacy_page_test.dart` (4 Fälle) ruft **das echte Skript** auf. ⚠️ Er hat sofort einen Fehler gefunden: **18 mehrzeilige Listenpunkte** verloren ihre Folgezeile, wodurch eine über zwei Zeilen laufende Fettschrift als rohe Sternchen mitten auf der Seite stand.
- [ ] ⬜ **Was dem Nutzer bleibt:** den alten Gist auf die neue Adresse zeigen lassen oder löschen. Er ist jetzt überflüssig — aber solange er existiert, findet ihn jemand und liest einen veralteten Text.

---

### Phase 30 — Ein Konto für Root-in und Vox ⬜ *(beauftragt 2026-08-17, für die letzten Projektschritte)*

**Vom Nutzer:** *„ثبت اکانت برنامه root-in و ثبت اکانت داخل برنامه vox جوری خواهد بود که هر دو از یک اکانت استفاده کنند! این برای اخرین مراحل پروژه‌است."* — Registrierung in Root-in und Registrierung in **Vox** sollen **dasselbe Konto** benutzen. Ausdrücklich für die **letzten** Schritte des Projekts.

✅ **2026-09-15 — die erste offene Frage ist beantwortet.** Beide Projekte werden seit 2026-09-13 aus **einem** Claude-Projekt betreut; Vox wurde am 2026-09-15 vollständig durchgesehen (Code + Daten, direkt über die GitHub-API). Stand von Vox:

| | Vox (`github.com/lukasylilli/vox`) |
|---|---|
| Art | **Flutter-Web-App**, live unter `lukasylilli.github.io/vox/` — wie Root-in: kein Store, keine Installation |
| Umfang | 253 Dart-Dateien (ohne `*.g.dart`), ~41 400 Zeilen |
| Datenhaltung | **drift + SQLite-WASM** im Browser (IndexedDB/OPFS) + `shared_preferences` — identisch zu Root-in |
| Konten | **gar keine.** Kein Supabase, kein `auth_service.dart`, kein Login — Vox ist heute vollständig kontenlos (README: „ohne Konto, ohne Abo") |
| Automatik | eigener Workflow `deploy-web.yml`: `flutter analyze` + `flutter test` + `flutter build web` → GitHub Pages bei jedem Push auf `main` |

⇒ **Für Phase 30 heißt das: der günstige Fall.** Zweite Flutter-Web-App mit demselben Datenstapel — `auth_service.dart` ist fast unverändert übernehmbar. Aber: **Vox hat noch keinerlei Konto-Oberfläche**; „ein Konto für beide" ist auf der Vox-Seite kein Anschluss, sondern ein Neubau (Registrierung, Anmeldung, Löschen, Datenschutztext). Das ist Aufwand in Vox, nicht in Root-in.

⚠️ **Der Rest dieser Phase ist weiterhin offen.** Was unten steht, ist **keine Planung von Vox**, sondern die Aufstellung dessen, was ein gemeinsames Konto **auf der Root-in-Seite** bedeutet, und der Fragen, die vor dem ersten Handgriff beantwortet sein müssen.

**Was aus „ein Konto" technisch folgt, wenn Root-in bleibt, wie es ist:**

Ein Konto ist bei Supabase eine Zeile in `auth.users`, und die gehört **einem Projekt**. „Dasselbe Konto" heißt deshalb: **beide Apps sprechen mit demselben Supabase-Projekt.** Daraus folgt Punkt für Punkt:

| Betroffen | Heute in Root-in | Mit gemeinsamem Konto |
|---|---|---|
| `auth.users` | nur Root-in-Nutzer | **geteilt** — wer sich in Vox registriert, existiert auch in Root-in und umgekehrt |
| `profiles` (Anzeigename, `username`) | Root-in-eigen | zu klären: **ein** gemeinsames Profil oder je App eines? Der eindeutige Index auf `lower(username)` gilt dann **über beide Apps** |
| `backups` | Root-in-eigen (`user_id` = Primärschlüssel) | bleibt Root-in-eigen; Vox braucht eine **eigene** Tabelle, keine gemeinsame |
| Zugriffsregeln (RLS) | mit `tool/rls_check.sh` von außen geprüft | **erneut zu prüfen** — jede neue Tabelle bringt neue Regeln (29.2) |
| Datenschutzerklärung | nennt Root-in und Supabase | **muss beide Apps nennen**: Wer sich einmal registriert, gibt sein Einverständnis für zwei Anwendungen |
| Der `anon`-Schlüssel | steht im Root-in-Bundle | steht dann in **beiden** Bundles — unverändert kein Geheimnis, aber zwei Wege hinein |

**Fragen, die vor dem ersten Handgriff beantwortet gehören** — sie ändern den Aufwand um Größenordnungen:
- [x] **Gibt es Vox schon, und womit ist es gebaut?** ✅ beantwortet 2026-09-15 (Tabelle oben): ja — Flutter-Web, drift + SQLite-WASM, GitHub Pages, **ohne jedes Konto**. `auth_service.dart` ist übernehmbar; die Konto-Oberfläche in Vox muss neu gebaut werden.
- [ ] **Ein Supabase-Projekt für beide, oder zwei getrennte?** Ein Konto für beide **erzwingt** ein gemeinsames Projekt. ⚠️ Der freie Tarif erlaubt **zwei aktive Projekte** — das ist hier kein Engpass, aber die Entscheidung ist trotzdem eine Einbahnstraße: Konten nachträglich zusammenzuführen heißt, Nutzer neu registrieren zu lassen.
- [ ] **Ein Anzeigename und ein Benutzername für beide** — oder je App eigene? Ein gemeinsamer Name ist einfacher und vermutlich gewollt („derselbe Mensch"), macht aber den Benutzernamen zu einer projektweiten Ressource.
- [ ] **Was passiert beim Löschen?** Wer in Vox sein Konto löscht, löscht auch seinen Root-in-Zugang. Das gehört in beide Oberflächen **und** in die Datenschutzerklärung.

⚠️ **Der günstigste Zeitpunkt ist vor dem ersten echten Nutzer** — genau die Lehre aus Phase 27, wo das Anmeldeverfahren einmal umgeworfen wurde und es billig war, weil noch niemand ein Konto hatte. **Root-in hat jetzt echte Nutzer, sobald die Adresse verteilt ist.** Wer Vox danach anschließt, kann `auth.users` nicht mehr folgenlos umbauen. Das ist der eine Grund, diese Phase **nicht** beliebig weit nach hinten zu schieben, obwohl der Nutzer sie „für die letzten Schritte" angesetzt hat.

---

### Phase 31 — Was ohne den Nutzer noch geht ✅ *(beauftragt 2026-09-13)*
**Umgesetzt am 2026-09-13**, jeder Schritt einzeln gepusht und in der Automatik grün. Beim Nutzer bleibt aus dieser Phase nur: `schema.sql` einspielen (31.3).

**Vom Nutzer:** *„mach alles weiter, laut plan und map bis ende, es bleibt nur was ich tun muss und du kannst nicht."* Dazu der Hinweis, dass auf seinem Rechner nichts mehr liegt — **jede Änderung geht auf GitHub**, geprüft wird von der Automatik.

Diese Phase sammelt die offenen Punkte aus früheren Phasen, die **kein Konto, kein Gerät und keine Entscheidung des Nutzers** brauchen. Alles andere steht in der Tabelle ganz oben und bleibt, wo es ist.

⚠️ **Bewusst NICHT hier: „Passwort vergessen" (27.5).** Der Knopf ließe sich bauen, aber nicht prüfen — ohne SMTP kommt keine Nachricht an, und der Weg zurück in die App (Link aus der E-Mail, neues Passwort setzen) ist genau der Teil, der im Browser schiefgehen kann. **Ein ungeprüfter Knopf ins Leere ist schlechter als keiner** (dieselbe Regel wie 26.1). Er kommt, wenn der Dienst steht.

#### 31.1 Benutzername nachtragen (27.5) ✅ *(2026-09-13)*
- [x] **Vor der Registrierung wird gefragt, ob der Name frei ist** (`isUsernameAvailable`, normalisiert). Ist er vergeben, entsteht **gar kein** Konto.
- [x] ⚠️ **Scheitert der Name NACH dem Anlegen des Kontos** (Wettlauf, oder die Verbindung bricht genau dazwischen ab), schaltet das Sheet in den **Nur-Name-Modus**: E-Mail und Passwort verschwinden, `claimUsername` schreibt den neuen Namen nach. Vorher stand dann „Name vergeben" im Formular — und ein zweiter Versuch scheiterte an „E-Mail schon registriert". **Aus diesem Zustand kam der Nutzer nicht heraus.** Erkannt wird der Fall daran, dass nach dem Fehlschlag **ein Konto angemeldet ist** — nicht am Fehlercode, denn auch „offline" kann genau zwischen Konto und Name auftreten.
- [x] **Konto-Seite:** Unter „Noch kein Benutzername" steht jetzt „Benutzernamen festlegen" und öffnet dasselbe Sheet im Nur-Name-Modus. Der Knopf erscheint erst **nach** dem Laden — während der Abfrage ist der Name nur unbekannt, nicht fehlend.
- [x] ⚠️ **Dabei gefunden (aus dem Ablauf abgeleitet, nicht beobachtet):** Die Konto-Seite lud den Namen, sobald sich die Anmeldung meldete — und die kann sich **vor** dem Schreiben der Profilzeile melden. Dann bliebe „Noch kein Benutzername" stehen, obwohl der Name gesetzt ist. Der Provider liegt jetzt als `accountUsernameProvider` in `auth_service.dart`, und das Sheet invalidiert ihn nach jedem Erfolg.
- [x] Tests: `auth_sheet_test.dart` (3 Fälle, darunter der Wettlauf) und ein neuer Fall in `account_cloud_card_test.dart`. ⚠️ **`FakeAuthService.signUp` legt jetzt wie der echte Dienst erst das Konto, dann den Namen an** — vorher tat er beides in einem Schritt und hätte die Sackgasse nie zeigen können. Ein Fake, der bequemer ist als das Original, testet das Original nicht.
- [x] ⚠️ **Nebenbei:** `dart format` hat drei lange einzeilige `if … return …;` in `auth_service.dart` umgebrochen und damit drei `curly_braces_in_flow_control_structures`-Hinweise erzeugt. `flutter analyze` wertet auch Hinweise als Fehler — die Automatik wäre rot geworden. Klammern ergänzt, lokal gegengeprüft.

#### 31.2 Browser-Durchgang erweitern (29.3) ✅ *(2026-09-13)*
- [x] **23 statt 11 Prüfungen** — alles, was `webtest.py` zusätzlich konnte: Anleitungs-Seite offen (UND-Verknüpfung: Thema da, Bottom-Navigation weg), Text geladen (Eintrag im Browser-Speicher), kein „Erneut versuchen"; Neuladen mit Erststart-Merker; Konto-Seite und „Anmelden"; `privacy.html` erreichbar, beide Sprachen, ohne interne Notiz. ⚠️ Die Zahl „10" in diesem Plan war falsch — es waren 11, nachgezählt an der Anmerkung eines Laufs.
- [x] **`WEBTEST_EXPECT_CLOUD`:** Ist das Secret gesetzt, ist eine fehlende Konto-Rubrik ein **Fehler** und nicht „ohne Schlüssel gebaut". Vorher hätte eine Änderung, die die Rubrik versehentlich versteckt, grün bestanden.
- [x] **`tool/webtest_serve.sh`** — die eine Stelle für „ausliefern wie GitHub Pages und prüfen"; beide Arbeitsabläufe rufen sie.
- [x] ⚠️ **Die Gegenprobe (`webtest-gegenprobe.yml`)** baut absichtlich beschädigt — ohne Supabase-Schlüssel, `raw.githubusercontent.com` im Browser gesperrt, `privacy.html` gelöscht — und ist nur grün, wenn **genau** die sechs dafür zuständigen Prüfungen rot sind und alle übrigen grün. Welche das sind, steht an einer Stelle (`GEGENPROBE_ROT` in `webtest_ci.py`). Sie veröffentlicht nichts und läuft bei **jedem** Push. Damit ist Lehre 32 kein Vorsatz mehr, sondern ein Lauf.
- [x] Nicht angemeldet — dieselbe Regel wie bisher.

#### 31.2b Was die Gegenprobe beim ersten Lauf gefunden hat ✅ *(2026-09-13)*

⚠️ **Ohne Netz zeigten Anleitung und „موارد دیگر" rund 40 Sekunden lang nur einen Ladekreis** statt „Kein Internet" mit „Erneut versuchen". Der erste Lauf der Gegenprobe war **rot**: Fünf der sechs Prüfungen wurden wie erwartet rot, aber „kein ‚Erneut versuchen'-Knopf" blieb **grün**, obwohl das Netz gesperrt war.

- [x] **Ursache — gemessen, nicht vermutet:** Riverpod 3 wiederholt einen Provider, der eine Exception wirft, **von selbst** — bis zu zehnmal, 0,2 bis 6,4 Sekunden Pause (nachgelesen in `riverpod-3.3.2`, `ProviderContainer.defaultRetry`). Während der Wiederholungen ist der Zustand „lädt", nicht „Fehler"; der Knopf erscheint erst nach dem letzten Versuch. Nebenbei liefen still zehn weitere Abrufe.
- [x] **Warum kein Test es sah:** Die Widget-Tests warten mit `pumpAndSettle`, und das spult die Pausen in **virtueller** Zeit vor. Am Ende stand der Knopf da — der Test war grün, ein Nutzer hätte 40 Sekunden gewartet.
- [x] **Erst rot, dann repariert:** Zwei Regressionstests (`guide_page_test.dart`, `others_page_test.dart`) warten bewusst **ohne** `pumpAndSettle` eine Sekunde und verlangen den Knopf **und genau einen** Abrufversuch. Beide waren vor der Behebung rot.
- [x] **Behebung an einer Stelle:** `lib/core/utils/no_retry.dart` (`noAutomaticRetry`), angewendet am Container in `main.dart` (für alle Provider der App) **und** an den drei Providern mit Fehlerzustand — Tests bauen ihren eigenen `ProviderScope` und sähen den Container sonst nie.
- [x] **Die Gegenprobe danach: grün** — genau die sechs erwarteten Prüfungen rot, alle übrigen grün.

#### 31.3 Konto vollständig löschen (27.4 · 27.8) ✅ Code *(2026-09-13)* · ⬜ Nutzer: einspielen
- [x] **`delete_own_account()`** in `supabase/schema.sql` statt einer Edge Function. ⚠️ **Die Abweichung ist begründet:** Eine Edge Function bräuchte eine eigene Bereitstellung (Supabase-CLI plus Zugangs-Token als Secret) — ein zweiter Weg auf den Server. Die Funktion geht denselben Weg wie der Rest der Datei und lässt sich von außen prüfen. `security definer`, **kein Parameter** (sie löscht ausschließlich `auth.uid()`), `search_path` leer, Ausführung nur für `authenticated` — `anon` und `PUBLIC` ausdrücklich entzogen, weil Supabase neuen Funktionen sonst von selbst `anon`-Rechte gibt.
- [x] **`AuthService.deleteAccount()`** unterscheidet drei Ausgänge: gelöscht · **Funktion fehlt** (`PGRST202`) · Fehler. ⚠️ „Fehlt" ist bewusst nicht „Fehler": Die Oberfläche soll dann tun, was ohne sie geht, statt „Server nicht erreichbar" zu behaupten.
- [x] **„Konto löschen" ersetzt „Daten auf dem Server löschen"** in „Konto & Cloud" — mit einer Rückfrage, die ausspricht, was **bleibt** (der Bestand auf dem Gerät).
- [x] ⚠️ **Fehlt die Funktion auf dem Server**, löscht die App Sicherung und Profil, **meldet ab** und sagt ehrlich, dass der Anmelde-Eintrag bleibt. **Dabei gefunden:** Der alte Knopf „Daten auf dem Server löschen" meldete **nicht** ab — die automatische Sicherung hätte beim nächsten Häkchen alles wieder hochgeladen. 27.4 behauptete „löscht die Daten und meldet ab"; der Code tat nur das Erste.
- [x] ⚠️ **Die Rückmeldung wird vor dem Löschen vorbereitet** (Messenger, Dienste, Texte): Mit dem Abmelden verschwindet die Ansicht, danach wären `context` und `ref` nicht mehr benutzbar. Abmelden nach dem Löschen ist sicher: `gotrue` 2.27 verwirft die Sitzung zuerst lokal und nimmt die Absage des Servers („Nutzer gibt es nicht") hin — nachgelesen, nicht angenommen.
- [x] **`rls_check.sh`:** Wegwerf-Konto C löscht sich selbst · danach scheitert seine Anmeldung · ohne Anmeldung löscht die Funktion nichts · A's Sicherung bleibt. ⚠️ **Erst C, dann die Abweisung ohne Anmeldung** — fehlt die Funktion, wäre jede Abweisung ein 404 und bewiese nichts. Fehlt sie, sagt das Skript genau das, samt Hinweis auf `schema.sql`.
- [x] **Datenschutzerklärung** (beide Sprachen, Punkt 4 und 8): Löschen geht in der App; die E-Mail bleibt nur für den Fall, dass die App meldet, es habe nicht ganz geklappt. Stand „September 2026".
- [x] Tests: drei neue Fälle in `account_cloud_card_test.dart` — Rückfrage mit Abbrechen und Löschen · Funktion fehlt · kein Netz.
- [ ] ⬜ **Nutzer:** `supabase/schema.sql` einmal im SQL-Editor ausführen, danach *Actions → Server-Zugriffsregeln prüfen → Run workflow*. Erwartet: **18 von 18**. ⚠️ Erst dieser Lauf zeigt, ob der Eigentümer der Funktion in diesem Projekt `auth.users` löschen darf. Scheitert „C löscht sein EIGENES Konto", bleibt die App beim ehrlichen Rückfall — kaputt geht nichts.

#### 31.4 Automatik auf Node 24 ✅ *(2026-09-13)*
- [x] **Anlass:** Jeder Lauf warnte „Node.js 20 is deprecated" für `checkout@v4`, `configure-pages@v5`, `upload-pages-artifact@v3` und `deploy-pages@v4`. ⚠️ **Ohne Rechner ist das kein Schönheitsfehler:** Wird Node 20 abgeschaltet, steht die Veröffentlichung — und niemand kann sie ersatzweise von Hand erledigen.
- [x] **Angehoben in allen drei Arbeitsabläufen:** `checkout@v7`, `configure-pages@v6`, `upload-pages-artifact@v5`, `deploy-pages@v5`. `subosito/flutter-action@v2` läuft ohne Node und blieb.
- [x] **Versionshinweise der großen Sprünge gelesen, nicht geraten:** checkout v5 (Node 24) · v6 (Zugangsdaten in eigener Datei) · v7 (Fork-PRs bei `pull_request_target` gesperrt) · deploy-pages v5 (Node 24) · upload-pages-artifact v4 (**Dateien mit Punkt am Anfang kommen nicht mehr ins Artefakt** — die Seite braucht keine) · v5 (`upload-artifact@v7`). Keine Änderung betrifft diese Abläufe.
- [x] **Nachgewiesen am ersten Lauf danach:** gebaut, geprüft, veröffentlicht — ohne Node-20-Warnung.

#### 31.5 Kein geheimer Schlüssel im Bundle (27.10) ✅ *(2026-09-13)*
- [x] **Anlass:** 27.10 nennt als gefährlichstes Risiko der Konto-Phase, dass der `service_role`-Schlüssel in die App gerät — er umgeht jede Zugriffsregel, und das Bundle ist öffentlich lesbar (Lehre 26). Als Gegenmaßnahme stand dort „im Bundle nach ihm suchen". **Getan hat es niemand** — eine Regel, die nur im Dokument steht (Lehre 35).
- [x] **`tool/check_bundle_secrets.py`** läuft in `deploy-web.yml` nach dem Bau und **blockiert** die Veröffentlichung: rot bei einem JWT mit `role=service_role` und bei `sb_secret_…`; der erlaubte `anon`- bzw. `sb_publishable_`-Schlüssel ist grün. Die Schlüssel selbst werden nie ausgegeben, nur der Fundort.
- [x] ⚠️ **Der Zeuge (Lehre 32):** Ist ein Supabase-Secret hinterlegt, bekommt das Skript `--expect-anon`. Findet es dann **keinen** erlaubten Schlüssel, ist es blind und wird rot — ein Suchlauf, der nichts findet, wäre sonst auch dann grün, wenn er an der falschen Stelle sucht.
- [x] **Gegen einen echten Bau gemessen**, nicht nur gegen Testdateien: der lokale Web-Bau vom 2026-09-12 (4,6 MB `main.dart.js`, mit Schlüsseln) — genau **ein** erlaubter Schlüssel, kein verbotener. Damit ist belegt, dass die Suchmuster das minifizierte Bundle wirklich lesen.
- [x] `test/unit/bundle_secrets_test.dart` (5 Fälle) ruft das echte Skript: anon grün · `service_role` rot und nicht ausgegeben · `sb_secret_` rot · blinder Suchlauf rot · ohne Erwartung grün.
- [x] **In der Automatik:** erster Lauf grün, der erlaubte Schlüssel gefunden.

#### 31.6 Startsprache: Englisch als Rückfall ✅ *(2026-09-16)*
- [x] **Anlass (Nutzer):** Ein englischsprachiger Besucher, der beim ersten Öffnen eine Sprache sieht, die er nicht lesen kann, schließt die App sofort. Regel: **Standard Englisch; Persisch nur, wenn das Gerät Persisch meldet.**
- [x] **Stand vorher:** Root-in folgte schon der Gerätesprache (`AppLanguage.system` → `resolveLocale`: erste Gerätesprache, die die App kann — de/en/fa). Nur der **Rückfall** für nicht unterstützte Sprachen (z. B. Türkisch) war **Deutsch**.
- [x] **Geändert:** `fallbackLocale` in `lib/core/l10n/app_language.dart` → `Locale('en')`. Eine Zeile, eine Stelle. Deutsch bekommt weiterhin, wessen Gerät Deutsch meldet — das ist eine unterstützte Sprache, kein Rückfall.
- [x] ⚠️ **Nicht verwechseln:** Die ARB-**Vorlage** bleibt `app_de.arb` (`l10n.yaml`); sie entscheidet nur, woher ein fehlender Text kommt, nicht die Startsprache.
- [x] Vox hat dieselbe Regel in seinem eigenen Repo umgesetzt (Vox PLAN.md → L.3a) — **kein gemeinsamer Code**, nur dieselbe Entscheidung.

---

## 11. Entscheidungs-Log & dauerhafte Lehren

### 11.1 Log (Kurzfassung)
- **2026-07-19** — Projekt-Setup, Tech-Stack, vollständig lokale Datenhaltung, Wettkampf nur per geteiltem Bild. Arbeitsweise beschlossen: phasenweise, PLAN/MAP nach jedem Schritt, Inhaltsverzeichnis-Pflicht, DRY. `sqlite3_flutter_libs` als end-of-life erkannt → `drift_flutter` + `sqlite3`.
- **2026-07-20** — Phasen 2–4.5. Matrix-Grid nimmt bewusst nur Zeitraum + Intensitäts-Map (kein DB-Zugriff) → überall wiederverwendbar. Kategorien referenzieren per **Name** statt Fremdschlüssel (kein Migrationsrisiko). Design-Token-Prinzip ausformuliert. **Ursache aller Build-Abstürze gefunden: iCloud** (Lehre 1).
- **2026-07-21 bis 07-25** — Phasen 5–10.6c. Nutzer wählt volles Drag-and-Drop-Dashboard; Berg-Animation nach gelieferter Vorlage nachgebaut; Backup erhält IDs; `file_picker` scheitert an win32 (Lehre 13). Nach Nutzer-Korrektur **10.7**: fünf eigenständige Diagramm-Widgets, Auswahl auf dem Startbildschirm statt in der App.
- **2026-07-26** — Phasen 11–11.6, 14, 15.1/15.2. Lokalisierung: Enum-Labels wurden Methoden, Achievements/Vorlagen bekamen stabile IDs, Notification-Texte bekommen die Sprache injiziert; **Nutzerdaten werden nicht mitübersetzt** (Lehre 11). `applicationId` = `com.rootin.app` inkl. Kotlin-Paketumzug. Store-Material erstellt — dabei zwei echte Fehler gefunden (Balkenachse bei dreistelligen Werten, Screenshot-Seitenverhältnis über dem Play-Limit).
- **2026-07-29/30** — Phase 16/16.1 (Übersicht) und 17/17.1/17.2 (Anleitung aus dem Repository). Tragend: alle Maße in **einer** Datei, `Stack` mit festen Koordinaten statt Flex, **keine** Lücke zwischen den Wochen. Dabei gefunden: **`INTERNET` stand nur im Debug-Manifest** (Lehre 5).
- **2026-08-01** — Phasen 20, 21, 19, 18 — bewusst **in dieser Reihenfolge**: 20 nimmt Schlüssel weg, 21 und 19 legen neue an, 18 übersetzt zuletzt. So wurde `app_fa.arb` genau einmal geschrieben statt dreimal nachgezogen. Werbung wird **auskommentiert, nicht gelöscht** (Nutzerwunsch) mit einem Marker als Wiederfinde-Anker. QR-Code auf der Teilen-Karte: ja. Ziffern bleiben westlich, auch auf Persisch (Lehre 4 im Hintergrund). Fünf tote ARB-Schlüssel entfernt, bevor sie Übersetzungsarbeit kosteten.
- **2026-08-02** — Phasen 25, 24, 23, 22, in dieser Reihenfolge: **Datenerhalt schützt, was die anderen anfassen**; die größte Phase kommt zuletzt. Entscheidungen des Nutzers: `index.json` statt GitHub-API, Inhalte je Sprache getrennt. Beim Verallgemeinern des Inhalts-Dienstes fiel eine Falle auf — der neue Zwischenspeicher-Schlüssel hätte alte Installationen offline vor eine leere Anleitung gestellt (Lehre 22).
- **2026-08-07** — Phase 13. Gebündelt wird in **benennbaren** Stufen (Tag/Woche/Monat), nicht stufenlos: *Was der Nutzer nicht benennen kann, kann er nicht einordnen.* Die Diagramm-Höhe bleibt fest, weil dieselben Widgets offscreen in 320×200 gerendert werden. **Geometrie wird gemessen, nicht behauptet.** Der Emulator-Durchgang fand trotz 183 grüner Tests einen echten RTL-Fehler (Lehre 25).
- **2026-08-07 bis 08-14 (Phase 26)** — Web-Fassung als PWA. **Die Grenze wurde vorab benannt, nicht hinterher:** „niemand soll den Code nachbauen können" ist im Web unerreichbar (Lehre 26), und eine Zusage, die nicht hält, wäre schlimmer als eine klare Absage. **Die beste Weiche ist keine Weiche** — der Web-Auftrag hat den mobilen Code vereinfacht, nicht verkompliziert. **Kein `gh-pages`-Zweig**, ein gemeinsames Bau-Skript. Die Kontrolle vor dem ersten Commit fand zwei Dinge, die mitgegangen wären (`meine/`, `settings.local.json` mit hunderten absoluten Pfaden).
- **2026-08-14** — 26.10/26.11: vier gemeldete Web-Fehler, **zwei** Ursachen. **Die Meldung war nicht die Beobachtung** — „kein Internetzugang" auf „Heute" hieß in Wahrheit „Seite bleibt leer". Erst messen, dann reparieren. `dart:io` ist im Browser eine Attrappe (Lehre 30); beide Fundstellen hatten einen korrekten `try`-Block, er stand nur **eine Zeile zu spät**. Eine Regel, die kein Verhaltenstest prüfen kann, bekam einen **Quelltext-Test**. Acht bestandene Browser-Prüfungen und trotzdem drei kaputte Seiten (Lehre 31); der erweiterte Durchgang wurde deshalb gegen den **kaputten** Stand gehalten (Lehre 32).
- **2026-08-16** — 26.12/26.13: „Knöpfe reagieren nicht" — drei plausible Erklärungen der Reihe nach **gemessen und widerlegt**, ohne eine Zeile zu ändern (Lehre 33). Die fehlende Bedingung nannte der Nutzer: **nur in der auf dem Home-Bildschirm abgelegten Fassung**, und man muss ein Stück **über** den Knopf tippen. Damit war es kein toter Knopf, sondern ein Koordinaten-Versatz (Lehre 34). Werkzeug-Gewinn: der iOS-Simulator als Prüfstand für echtes iOS-Safari.
- **2026-09-16** — 31.6: Rückfallsprache Deutsch → **Englisch** (Nutzerwunsch: Standard Englisch, Persisch nur bei persischem Gerät). Die Gerätesprache hatte Root-in schon beachtet; geändert wurde nur der Rückfall.
- **2026-09-16** — Nur Doku, kein Code: In **Vox** ist S.6 umgesetzt (eigene Listen mit fester id, Vox-Nutzlast Fassung 2 → 3). **Für Root-in ändert sich nichts** — Vox schreibt nur in seine eigene Tabelle `vox_backups`; die gemeinsame Hülle `{version, exportedAt, app, payload}` bleibt gleich, und `version` zählt **je App getrennt** (Root-ins Zählung ist davon unberührt). Hier vermerkt, weil beide Apps dasselbe Supabase-Projekt teilen.
- **2026-09-16** — Nur Doku, kein Code: In **Vox** ist V.2 umgesetzt (Wortindex statt alle Wortkarten beim Start). Reine Vox-Sache — kein Server, keine gemeinsamen Daten; **für Root-in keine Änderung.**
- **2026-09-16** — Nur Doku, kein Code: In **Vox** ist L.1a umgesetzt (Wächter: veröffentlichte Wort-ids dürfen nie verschwinden). **Für Root-in keine Änderung.** Die dabei gefundene Lehre (`| tee` verschluckt Fehler ohne `set -o pipefail`) gilt auch hier, falls ein Workflow je `| tee` nutzt.
- **2026-09-16** — Nur Doku, kein Code: In **Vox** ist L.1b umgesetzt (Migrationstest über alle veröffentlichten Datenbank-Fassungen mit drifts `SchemaVerifier`; Fehlertexte roter CI-Schritte als Annotation, lesbar über api.github.com). **Für Root-in keine Änderung.** Beide Ideen passen auch hier, falls Root-in je eine neue Datenbank-Fassung bekommt — dann bewusst übernehmen, nicht nebenbei.
- **2026-09-16** — Nur Doku, kein Code: In **Vox** sind alle 84 Grammatik-Lektionen live (L.2c/G3–G6). Reine Vox-Inhalte — **für Root-in keine Änderung.**
- **2026-09-18** — Nur Doku, kein Code: Entscheidungen von Lukas für **Vox** festgehalten (restliche Übungen erst nach dem Launch; Quellen der leeren Decks kommen einzeln). **Für Root-in keine Änderung.**
- **2026-09-18** — Nur Doku, kein Code: In **Vox** ist L.6 eröffnet (Lukas schickt Grammatik-Lektionen seiner Bücher einzeln; Inhalte werden neu geschrieben, nie abgeschrieben). **Für Root-in keine Änderung.**
- **2026-09-16** — Nur Doku, kein Code: In **Vox** hat jede Grammatik-Lektion jetzt Übungen (G7a, 336 Übungen; Lukas: Übungen kommen vor dem Launch). Reine Vox-Inhalte, nichts wird gespeichert — **für Root-in keine Änderung.**
- **2026-09-16** — Nur Doku, kein Code: In **Vox** gibt es jetzt einen Grammatik-Niveau-Test A1–C2 (G7b). Ergebnis wird nicht gespeichert — **für Root-in keine Änderung.**
- **2026-09-16** — Nur Doku, kein Code: In **Vox** entstehen Grammatik-Übungen jetzt auch zufällig aus den Beispielsätzen (G7c). Reine Vox-Inhalte — **für Root-in keine Änderung.** Vorschau: G7e (Niveau-Test-Ergebnis speichern) berührt den Vox-Lernstand; ob die gemeinsame Supabase-Datenbank betroffen ist, wird dort geprüft und hier vermerkt.
- **2026-08-16 (Phase 27 beauftragt)** — Nutzerdaten sollen auf einem Server liegen (Supabase). Damit fällt die älteste Festlegung des Projekts („kein Backend, keine Nutzerkonten"). Vor dem ersten Handgriff festgehalten, **was daran hängt** (27.0) — insbesondere, dass die Datenschutzerklärung und das Play-Formular keine Nacharbeit sind, sondern eine **Bedingung der Veröffentlichung**.

- **2026-08-17 (Phase 27 gebaut)** — Konto, Cloud-Sicherung, Datenschutz. Tragende Entscheidungen:
  - **Das Anmeldeverfahren wurde einmal umgeworfen — rechtzeitig.** Zuerst „Benutzername ohne E-Mail" (Supabase kann das nicht von sich aus, also künstliche Adressen), dann auf Wunsch des Nutzers **echte E-Mail**. Der halbe Tag Arbeit war nicht verloren: Die Umrechnung fiel **ersatzlos** weg statt als toter Code liegen zu bleiben, und die Namensregeln blieben. **Vor dem ersten echten Nutzer ist ein Umwurf billig** — danach verwaist er Konten.
  - **Nachgelesen statt geraten, dreimal.** Tarifgrenzen (`supabase.com/pricing`), Mail-Grenze (**2 Nachrichten/Stunde und nur an eigene Team-Adressen** — damit war „E-Mail-Bestätigung an" von vornherein unmöglich) und die Fehler-Codes der Anmeldung. Alle drei hätten aus dem Gedächtnis falsch geraten werden können, und zwei davon hätten die Phase in eine Sackgasse geführt.
  - **Zwei unabhängige Schutzschichten am Server**, ausgelöst durch eine Frage des Nutzers zu den Data-API-Schaltern: Rechte (nur `authenticated`, nie `anon`) **und** RLS. Dabei fiel auf, dass `schema.sql` sich auf einen Schalter in einer Weboberfläche verlassen hatte — jetzt trägt die Datei ihre Rechte selbst.

- **2026-08-17 (Neuausrichtung + Fehlalarm)** — Die Web-Fassung ist ab jetzt **das Ziel** (Abschnitt 2), nicht der Ersatzweg; PLAN und MAP wurden vollständig darauf umgestellt. Beim ersten Durchgang gegen die frisch veröffentlichte Seite meldete `webtest.py` dann **16 rote Prüfungen** — und **keine einzige stimmte**. Die App war in Ordnung (im iOS-Simulator einwandfrei), GitHub Pages hatte nur noch nicht ausgeliefert. Der eigentliche Fund war das **Werkzeug**: Ein leerer Semantik-Baum lässt jede Text-Prüfung scheitern und jede Abwesenheits-Prüfung bestehen, das Ergebnis liest sich wie ein Totalschaden. Dazu die teuerste Fehlmessung des Tages — `document.querySelectorAll('canvas')` findet Flutters Zeichenfläche **nie**, weil sie im Schatten-DOM liegt; die falsche These „die App zeichnet nichts" hielt sich über mehrere Bauten, bis eine **leere Vergleichs-App denselben Wert lieferte**. `webtest.py` bricht jetzt beim gescheiterten Start ab, sagt in Worten warum, und wartet überall auf **Zustände statt auf die Uhr** (Lehre 36). Danach: dreimal hintereinander 20/20 grün, auch die Rubrik „Konto & Cloud" — womit zugleich bewiesen ist, dass die Supabase-Schlüssel in der veröffentlichten Fassung ankommen.
  - **Geprüft wurde von außen, mit echten Konten** (`tool/rls_check.sh`, 13/13). Ein `select` im SQL-Editor läuft mit erhöhten Rechten und beweist nichts.
  - **Der geteilte QR-Code führte seit Phase 19 auf HTTP 404** — gemeldet vom Nutzer, nachgemessen, behoben. Der bestehende Test hatte den Fehler mitgetragen: Er prüfte, dass die Play-Adresse *korrekt gebildet* war. War sie. War nur die falsche.
  - **Lehre 35 entstand aus dreimaligem Rückfall in Lehre 32.** Eine Regel gehört an die Stelle, an der man gegen sie verstößt — in den Docstring, in den Kommentar, in einen Test. Nicht nur in dieses Dokument.

- **2026-08-17 (Ziel neu gesetzt)** — *„ziel ist web app, dass alle ohne app store oder google play das nutzen können."* Damit kehrt sich Abschnitt 2 um: **Web ist das Ziel**, Android und iOS nativ sind zurückgestellt. Was das bedeutet:
  - **Phase 15 und 12 werden pausiert, nicht gestrichen.** Material, Signaturschlüssel und Wege bleiben vollständig stehen — eine zurückgedrehte Entscheidung soll nicht bei null anfangen.
  - **Die Datenschutzerklärung war als „Play-Blocker" begründet — das trug nicht.** Mit dem Zurückstellen von Phase 15 wäre die Begründung weggefallen, die Pflicht aber nicht: Wer 200 Schülern eine Adresse gibt und ihre E-Mail speichert, schuldet ihnen einen zutreffenden Text, ganz ohne Store. Der Punkt ist deshalb aus Phase 15 heraus nach 27.8 gewandert. **Ein Grund, der beim ersten Gegenwind verschwindet, war der falsche Grund.**
  - **Der Preis steht jetzt ausdrücklich in Abschnitt 2:** Die Hauptplattform hat **keine Erinnerungen** und keine Startbildschirm-Widgets. Bei einer Habit-App ist das erste kein Detail — es ist die offene Frage dieser Neuausrichtung und steht als solche in Abschnitt 12.
  - **Der Android-Durchgang (21.3) wurde mittendrin angehalten** — Release-APK mit Cloud-Schlüsseln gebaut und auf einem frischen Emulator installiert, dann kam die neue Zielsetzung. Der plattformunabhängige Teil der Liste (leerer Zustand, Sprachen, Persisch, Teilen, Datenerhalt) gilt weiter, nur gehört er jetzt in den iPhone-Durchgang.

- **2026-08-17 (Phase 28 — nur noch Web)** — Der Nutzer streicht, was am Vormittag noch „zurückgestellt, nicht gestrichen" hieß: *„فقط نسخه وب خواهیم داشت."* Dazu: Erinnerungen ganz entfernen, Datenschutz nachziehen, und das Projekt verschwindet vom Mac — weitergearbeitet wird auf GitHub.
  - **Zurückgestellt und gestrichen sind zwei verschiedene Dinge, und der Unterschied gehört ins Dokument.** Am Vormittag war die Begründung fürs Aufheben „eine zurückgedrehte Entscheidung soll nicht bei null anfangen". Sie trug nicht mehr. Jetzt sind 153 Dateien weg — **die Versionsgeschichte behält alles**, und genau deshalb darf der Plan sie loslassen.
  - **Die Erinnerungen gingen tiefer als gedacht:** neun Ebenen bis hinunter in die Datenbank. Eine Funktion zu entfernen ist selten das Gegenteil davon, sie zu bauen — die Migration 3 → 4 war aufwendiger als die 2 → 3, die sie einst angelegt hatte.
  - ⚠️ **Beim Löschen des Macs zählt nur, was im Repository liegt.** Die Prüfung fand `meine/` mit **0 von 24 Dateien versioniert** — Screenshots, Design-Specs und die Logo-Quelle. Bewusst ausgeschlossen, also bleibt es auch draußen; der Nutzer sichert es selbst. Die Prüfung selbst ist die Lehre: **Vor einer Löschung nicht fragen „ist alles gepusht?", sondern „was ist nie gepusht worden?"** (Lehre 37).

- **2026-08-17 (Phase 29/30 beauftragt — das Projekt verlässt den Rechner)** — *„از الان به بعد تمام تغییرات فقط در گیت هاب."* Alles, was nicht auf GitHub liegt, wird gelöscht, VS Code inbegriffen.
  - ⚠️ **Die eigentliche Folge ist nicht bequemlicher, sondern gefährlicher:** Von drei Prüfständen bleibt einer (`analyze` + `test` in der Automatik), einer verwaist (`rls_check.sh` — rettbar, 29.2), einer fällt weg (`webtest.py`, braucht macOS). **Keiner der 205 Tests öffnet einen Browser.** Genau diese Lücke ließ in Phase 26 drei kaputte Hauptseiten durch (Lehre 31), und sie ist jetzt wieder offen (Lehre 39).
  - **Was bleibt, ist der Nutzer mit seinem iPhone.** Damit wird er vom Auftraggeber zum letzten Prüfstand — das gehört ausgesprochen, weil es die Reihenfolge der offenen Punkte bestimmt.
  - **Neu angesagt: ein gemeinsames Konto für Root-in und Vox** (Phase 30). Festgehalten ist nur, was feststeht; über Vox ist in diesem Projekt nichts dokumentiert, also wird darüber auch nichts behauptet. ⚠️ Aufgeschrieben ist dafür, was „ein Konto" auf der Root-in-Seite **erzwingt** — ein gemeinsames Supabase-Projekt — und dass der günstigste Zeitpunkt **vor** dem ersten echten Nutzer liegt.

- **2026-09-12 (Phase 29 umgesetzt)** — Server-Prüfung als Action (von Hand), Browser-Durchgang in der Automatik, `meine/` auf Wunsch des Nutzers ins Repository, Datenschutzerklärung als `privacy.html` bei jedem Bau.
  - **Der Browser-Durchgang war zuerst nicht blockierend — und damit wertlos.** `continue-on-error` meldet „success" auch beim Scheitern. Beim Umstellen auf blockierend war der erste Lauf **rot** (6/10): Beim Abschreiben aus `webtest.py` war das Wegklicken des Speicher-Hinweises verloren gegangen. Unfreiwillig, aber genau die Gegenprobe, die Lehre 32 verlangt.
  - **„Schreib die Datenschutzerklärung in PLAN und MAP" wurde nach seinem Zweck umgesetzt, nicht wörtlich:** Eine weitere Kopie hätte den Fehler wiederholt, an dem der Gist zweimal veraltet ist. Stattdessen **eine** Quelle, die sich selbst veröffentlicht — und PLAN/MAP sagen, **wo** sie steht und **wie** man sie ändert.
- **2026-09-13 (Phase 31 beauftragt)** — *„mach alles weiter … bis ende."* Gesammelt, was ohne Nutzer geht: Benutzername nachtragen (ein echter Sackgassen-Zustand, beim Durchsehen von 27.5 gefunden — der Dienst konnte es, die Oberfläche nie), Browser-Durchgang erweitern, Konto vollständig löschen. „Passwort vergessen" bewusst **nicht**: ohne SMTP nicht prüfbar.
- **2026-09-13 (Phase 31 umgesetzt)** — 31.1 bis 31.5, jeder Schritt einzeln gepusht und in der Automatik grün.
  - **Die Gegenprobe hat sich beim ersten Lauf bezahlt gemacht** (31.2b): ein echter Fehler in der App, den über 200 grüne Tests und ein 23/23-Browser-Durchgang übersehen hatten. Lehren 40 und 41.
  - **Zweimal stand im Plan, was der Code nicht tat:** „löscht die Daten und meldet ab" (der alte Knopf meldete nicht ab) und „10 Prüfungen" (es waren 11). Beides fiel beim Bauen auf, nicht beim Lesen — noch ein Grund, Zusagen in Tests zu halten statt in Prosa (Lehre 35).
  - **`FakeAuthService.signUp` war bequemer als das Original** — Konto und Name in einem Schritt — und hätte die Sackgasse aus 31.1 nie zeigen können. Ein Fake, der bequemer ist als das Original, testet das Original nicht.
  - **„Im Bundle nach ihm suchen" stand seit Phase 27 als Gegenmaßnahme im Plan — und niemand suchte.** Jetzt sucht die Automatik, mit Zeugen: Findet sie nicht einmal den erlaubten Schlüssel, ist sie blind und wird rot (31.5).

### 11.2 Dauerhafte Lehren & Fallstricke

⚠️ **Die Lehren 1–5 und 7 betreffen einen Rechner und Plattformen, die es in diesem Projekt nicht mehr gibt** (Phase 28/29). Sie sind **historisch** und mit 🕰️ gekennzeichnet — nicht gelöscht, weil ihre *Denkweise* trägt und weil ein Log, der sich nachträglich glattbügelt, wertlos ist. Wer heute etwas nachschlägt, fängt bei 6 an.

1. 🕰️ **iCloud bricht Code-Signing.** Das Flutter-SDK lag auf iCloud Drive; `taskgated` killte die Binaries sporadisch (`SIGKILL`, per Crash-Report belegt). Das war die Wurzel von „Dart compiler exited unexpectedly", `ShaderCompilerException` und den native-asset-Fehlern — **nicht** Arbeitsspeicher. SDKs nach `~/development/`, Projekte nach `~/Projects/`. Bei Build-Abstürzen zuerst `~/Library/Logs/DiagnosticReports/` lesen.
2. 🕰️ **PATH in der Bash-Tool-Shell ist eingefroren.** Flutter/Dart immer mit vollem Pfad aufrufen: `"$HOME/development/flutter/bin/flutter"`.
3. 🕰️ **`keytool`, `java`, `adb` fehlen im PATH.** JDK: `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/`, adb: `~/Library/Android/sdk/platform-tools/adb`.
4. 🕰️ **Systemsprache `fa_AT` kippt den AAB-Build.** Die JVM erbt persische Ziffern, `bundletool` erwartete `classes۲.dex`. Fix steht in `android/gradle.properties`: `-Duser.language=en -Duser.country=US`. Betraf **nur** den Release-AAB.
5. 🕰️ **`INTERNET` gehört ins Haupt-Manifest.** Flutter legt sie nur in Debug/Profile an — im Release schlägt sonst jede Anfrage fehl, still.
6. **`container.read(streamProvider.future)` ohne Zuhörer hängt für immer.** Riverpod verwirft den Provider sofort. Lösung: eine eigene `listen`-Subscription halten. ⚠️ Das Vorbild `_awaitAlive` lag in `home_widget_service.dart` und ist mit Phase 28 entfallen — die Falle nicht.
7. 🕰️ **ARGB-Farben passen nicht in einen Android-`Int`.** Werte über `Int.MAX_VALUE` landen als `Long` → `ClassCastException` in Kotlin. Immer `.toSigned(32)` schreiben.
8. **Der Gerätelauf findet, was Tests nicht finden:** verfügbarer Platz, Drehung, Theme-Wechsel, Überläufe, fehlendes Clipping. Ein Render-Test beweist Geometrie — nicht Benutzbarkeit.
9. **Drift-Details:** `uniqueKeys` auf (habitId, date) nötig; Teil-Updates mit `.write()` statt `.replace()`; Tests gegen eine In-Memory-DB (`test/support/test_database.dart`) plus `disposeAndFlush(tester)`, sonst „Timer is still pending".
10. **`pumpAndSettle()` ist auf der Home-Seite verboten** — die funkelnden Sterne laufen dauerhaft. Stattdessen `pump(duration)`; für Routenwechsel drei aufeinanderfolgende `pump()`.
11. **Nutzerdaten werden nicht mitübersetzt.** Namen von Gewohnheiten und Kategorien speichern den Text der Sprache zum Zeitpunkt des Anlegens; ein späterer Sprachwechsel lässt sie unangetastet.
12. **Play-Formalitäten:** Screenshots höchstens 2:1; In-App-Produkte erst anlegbar, wenn ein Bundle mit Billing in einem Track liegt; `com.example.*` wird abgelehnt; Signaturschlüssel-Verlust = keine Updates mehr.
13. **`file_picker` ist eine Sackgasse** (verlangt `win32 ^5`, `share_plus 13` will `^6`; ein Override bricht `flutter test`). Genutzt wird `flutter_file_dialog` (nur Android/iOS — genau die Zielplattformen).
14. **Vor größeren Android-Builds `df -h /System/Volumes/Data` prüfen** — der Datenträger lief schon einmal während der Verifikation voll.
15. **`sips` schreibt ohne `-s format png` weiterhin JPEG**, auch bei `.png`-Endung; Play weist so eine Datei zurück.
16. **Der Android-Manifest-Merger übernimmt XML-Kommentare wortgetreu.** Ein `grep AD_ID` im zusammengeführten Manifest findet deshalb auch auskommentierte Blöcke — es sieht aus, als wäre nichts entfernt worden. Richtig geprüft wird XML-bewusst oder direkt im AAB unter `base/manifest/AndroidManifest.xml` (Protobuf, ohne Kommentare). Genau daran wäre die Verifikation von Phase 20 fast falsch beantwortet worden.
17. **Eine vollständig auskommentierte Test-Datei ist ein Ladefehler**, kein „keine Tests": `flutter test` verlangt ein `main()`. Wer eine Datei stilllegt statt sie zu löschen, lässt einen mit `skip:` übersprungenen Platzhalter-Fall stehen.
18. **Eine `Row` mit vielen Kennzahlen läuft irgendwann über.** Auf der schmalen Fortschritts-Karte waren es 169 px, unsichtbar in der Vorschau und abgeschnitten im geteilten Bild. `Wrap` statt `Row`, und ein Test, der `tester.takeException()` prüft — gefunden hat es der Test, nicht das Auge.
19. **Drift-Abfragen mitten im Widget-Test hängen.** Drift liefert Stream-Ergebnisse über einen Timer, und im Widget-Test steht die Uhr still — ein blankes `await stream.first` läuft in den Timeout, ohne Fehlermeldung. Lösung: `await tester.runAsync(() async { … })`, oder gleich ein reines `test(...)` mit `ProviderContainer`.
20. **`flutter analyze` löst `gen-l10n` nicht aus.** Neue ARB-Schlüssel erscheinen deshalb als „undefined getter", obwohl die Datei stimmt. Nach jeder ARB-Änderung `flutter gen-l10n` laufen lassen (oder einfach bauen).
21. **`FlutterLocalNotificationsPlugin` lässt sich im Test nicht ersetzen** (privater Konstruktor) und der Plattform-Kanal nicht auflösen. Wer Notification-**Logik** prüfen will, zieht sie in ein reines Wertobjekt heraus (siehe `DailyStatusMessage`); die Zustellung bleibt deklarative Konfiguration für den Gerätedurchgang.
22. **Ein umbenannter `shared_preferences`-Schlüssel ist ein Datenverlust auf Raten.** Beim Umbau von `guide_md_*` auf `repo_content_*` wären die gespeicherten Anleitungs-Texte alter Installationen unerreichbar geworden — sie lägen noch da, nur unter einem Namen, den niemand mehr abfragt. Beim Umbenennen **immer** eine einmalige Übernahme einbauen (alten Wert lesen, umhängen, alten Schlüssel räumen).
23. **`Duration(days: n)` ist keine Datumsarithmetik — auch nicht im Test.** Über eine Sommerzeit-Umstellung hinweg landet `start.add(const Duration(days: 91))` um 01:00 Uhr statt um Mitternacht und trifft **keinen** Schlüssel einer nach Tagen indizierten Map. Im App-Code gilt `addDays` seit Phase 2; in Tests genauso.
24. **fl_chart beschriftet immer zusätzlich den Achsenrand.** `interval` steuert nur die Zwischenschritte; `maxY` bekommt in jedem Fall ein Label. Wer bestimmte Werte an der Achse haben will, filtert in `getTitlesWidget`. `interval` darf außerdem nie 0 sein.
25. **Rund um ein Diagramm ist „links" nie „start".** fl_chart kennt keine Textrichtung und zeichnet die Y-Achse immer physisch links; die Diagramme bleiben auf Persisch bewusst links-läufig. Beschriftungen daneben deshalb mit `Alignment.centerRight`/`TextAlign.right`, **nicht** richtungsabhängig — sonst landet der Text auf Persisch auf der Achse (am Gerät gefunden).
26. **Im Web gibt es keinen Code-Schutz, nur Code-Unlesbarkeit.** `--obfuscate` wirkt nicht für Web-Bauten; `dart2js` minimiert, mehr nicht. Was der Browser ausführt, kann der Browser lesen — auch bei WebAssembly. Ein `--dart-define` ist keine Verschlüsselung, sondern nur ein Weg, den Wert aus dem Repository zu halten. **Was geheim bleiben muss, gehört hinter einen Server.**
27. **Ein Browser-Datei-Dialog meldet den Abbruch nicht über `change`.** Bricht der Nutzer ab, feuert nur `cancel` — ohne dieses Ereignis bleibt das Future für immer offen und die Oberfläche hängt in einem Ladezustand ohne Ende.
28. **`--base-href` entscheidet auf GitHub Pages über weiß oder App.** Die Seite liegt unter `/<repository>/`, nicht im Wurzelverzeichnis; mit dem Standardwert sucht sie ihre Dateien eine Ebene zu hoch und zeigt nichts an — ohne Fehlermeldung.
29. **`--no-test-assets` gehört NICHT in die Automatik.** Das Flag ist eine lokale Abkürzung. Ein CI-Lauf startet immer mit einem frischen Checkout — das entspricht `flutter clean`, und dann fehlen die Assets ganz: 11 Widget-Tests scheitern an `Asset 'shaders/ink_sparkle.frag' not found`. **Daran ist der allererste Veröffentlichungslauf gescheitert.** Bitter dabei: Der Kommentar im Arbeitsablauf berief sich auf genau die Lehre, die den Fehler beschreibt, und zog daraus den umgekehrten Schluss. **Eine Lehre zu zitieren ist nicht dasselbe, wie sie anzuwenden.**
30. **`dart:io` übersetzt für den Browser und wirft dann zur Laufzeit.** Für Web-Bauten liefert das SDK eine Attrappe: Der Import ist gültig, `flutter analyze` schweigt, `flutter build web` läuft durch — und der erste Aufruf wirft `UnsupportedError`. Besonders tückisch bei `HttpClient`: **schon `HttpClient()` wirft**, weil das Feld `userAgent` beim Erzeugen `Platform.version` liest. Wer die Zeile — wie üblich — vor das `try` stellt, hat seinen sorgfältig gebauten Offline-Fallback wirkungslos gemacht. **Kein `dart:io` in `lib/`**, außer in Dateien, die ein bedingter Import auswählt (`*_io.dart`) — `test/unit/no_dart_io_in_lib_test.dart` hält die Regel fest. Für Netzzugriffe `package:http`.
31. **„Im Browser getestet" sagt nichts über den Umfang.** Der Durchgang aus Phase 26.7 bestand acht Prüfungen und übersah drei kaputte Seiten — er hatte **keinen einzigen Reiter angetippt**. Ein Gerätelauf beweist nur, was er anfasst; was er nicht anfasst, ist ungeprüft, nicht in Ordnung. Beim Schreiben eines solchen Durchgangs zuerst aufzählen, welche Seiten es gibt, und dann jede besuchen.
32. **Ein Oberflächen-Test muss am kaputten Stand rot werden — sonst prüft er nichts.** Beim Erweitern des Browser-Durchgangs meldeten vier Fassungen nacheinander „bestanden", ohne die Seite je gesehen zu haben: Ein Wisch scrollte nicht (Flutter zieht Listen im Desktop-Browser nicht), ein Tipp fand sein Element und öffnete trotzdem nichts, eine Abfrage suchte einen Text, den der Semantik-Baum gar nicht führt (reine Texte fehlen dort oft, Knöpfe nie), und eine feste Wartezeit reichte über das Netz nicht. Gemeinsamer Nenner: **Prüfungen auf eine Abwesenheit werden grün, wenn gar nichts da ist.** Deshalb jede Abwesenheits-Prüfung an eine positive Zustandsprüfung koppeln — und **den neuen Test einmal gegen den kaputten Stand laufen lassen**.
33. **Ein Fehler, der von selbst verschwindet, ist nicht behoben — er ist unbeobachtet.** Bei „Knöpfe im Erststart reagieren nicht" waren drei plausible Erklärungen falsch, alle drei **messbar** widerlegt, bevor eine Zeile Code angefasst wurde. Richtig ist dann: **nichts auf Verdacht ändern**, aber die Messwerte vollständig aufschreiben. Ein spekulativer „Fix" hätte eine echte Layout-Änderung für alle Plattformen bedeutet — gegen eine Ursache, die es womöglich nie gab. Bei einer PWA gehört das Aktualisierungsfenster des Service Workers zu den ersten Verdächtigen: **beide Zugänge (Browser und Home-Bildschirm) teilen sich denselben Speicher**.
34. **Eine abgelegte Web-Fassung ist ein eigener Betriebsmodus, kein hübscherer Browser.** `viewport-fit=cover` und `apple-mobile-web-app-status-bar-style: black-translucent` wirken **nur** dort — in Safari sind sie folgenlos. Beide ziehen die Seite unter Statusleiste und Home-Indikator, und weil **Flutter im Web die iOS-Schutzabstände nicht auswertet** (`MediaQuery.padding` bleibt null, `SafeArea` reserviert nichts), liegen gezeichnete und berührte Fläche um die Höhe der Statusleiste auseinander: Man muss über einen Knopf tippen, damit er reagiert. Für eine Flutter-PWA auf iOS deshalb **beide Angaben meiden**. Und allgemeiner: Wer eine Web-Fassung zum Ablegen anbietet, hat **zwei** Betriebsmodi zu prüfen — der Browser-Durchgang sieht den zweiten prinzipiell nicht.
35. **Eine Regel, die nur im Dokument steht, hält niemanden auf.** Lehre 32 („nach Knöpfen fragen, nicht nach Überschriften") stand ausformuliert in diesem Plan — und ist beim Bauen von Phase 27 trotzdem ein **drittes** Mal zugeschnappt: Jedes Mal suchte eine Prüfung einen Titel im Semantik-Baum, meldete „nicht da", und das Gesuchte stand deutlich sichtbar auf dem Bildschirmfoto. Ein Plan wird beim Planen gelesen, nicht beim Tippen. **Wer eine Regel wirklich durchsetzen will, bringt sie an die Stelle, an der man gegen sie verstößt** — in den Docstring der Funktion (`shows()`), in den Kommentar neben dem Schlüssel, in einen Test. Dasselbe galt für die Zusammenstoß-Regel aus 27.6: Sie stand als hübsche Tabelle im Kopf der Datei und wurde von nichts gehalten, bis sie sieben Testfälle bekam.
36. **Ein Prüfwerkzeug, das eine Ursache als sechzehn Fehler meldet, schickt dich in die falsche Richtung.** Direkt nach einer Veröffentlichung meldete `webtest.py` 16 rote Prüfungen. Keine einzige stimmte: Die App war tadellos, GitHub Pages hatte nur noch nicht überall ausgeliefert. Der Schaden entstand durch den **Aufbau des Werkzeugs** — bleibt der Semantik-Baum leer, findet jede Text-Prüfung nichts und jede Prüfung auf eine **Abwesenheit** besteht. Das Ergebnis liest sich wie „die halbe App ist kaputt" statt wie „sie ist nicht hochgekommen". Drei Regeln daraus: **(a)** Scheitert der Start, wird **abgebrochen** — Folgeprüfungen ohne laufende App messen nichts. **(b)** Prüfungen auf eine Abwesenheit brauchen einen Zeugen dafür, dass überhaupt etwas da ist (im Durchgang: die UND-Verknüpfung mit `on_guide`). **(c)** Nach einer Veröffentlichung **nicht sofort messen**. ⚠️ Und die teuerste Einzelheit: `document.querySelectorAll('canvas')` liefert bei Flutter **immer 0** — die Zeichenfläche liegt im **Schatten-DOM** von `flt-glass-pane`. Diese eine Fehlmessung trug die falsche These „die App zeichnet gar nichts" durch mehrere Bauten hindurch, bis eine leere Vergleichs-App **denselben** Wert lieferte. Eine Messung, die am gesunden Vergleichsfall genauso ausschlägt wie am kranken, misst nichts — **der Vergleichsfall hätte an den Anfang gehört, nicht ans Ende.**

37. **Vor dem Löschen zählt nicht, was gepusht ist, sondern was nie gepusht wurde.** Als das Projekt vom Rechner verschwinden sollte, war die naheliegende Frage „ist alles committet?" — und die Antwort war ja. Sie war trotzdem die falsche Frage. Ein `git status` sieht **gitignorierte Dateien nicht**: `meine/` lag mit 24 Dateien im Projekt, davon 0 versioniert — die Design-Vorlagen, 20 Screenshots und die Quelle des App-Symbols. Alles bewusst ausgeschlossen, alles unwiederbringlich. Die richtige Prüfung ist eine andere: für jeden Ordner `find` gegen `git ls-files` halten und die Differenz ansehen. Was dabei auftaucht, ist entweder wertlos (dann ist es egal) oder wertvoll (dann ist es die einzige Kopie). **Und der Fund gehört dem Nutzer:** Material, das absichtlich draußen ist, wandert nicht „zur Sicherheit" in ein öffentliches Repository — man sagt Bescheid und lässt ihn entscheiden.

38. **Ein Prüfstand kann müde werden — und sagt es nicht.** Am Ende von Phase 28 meldete `tool/webtest.py` dreimal hintereinander „nichts gezeichnet", gegen die veröffentlichte Seite **und** gegen jeden lokalen Bau. Die Suche ging erst durch die Bau-Schalter (`--csp`, `-O4`), dann durch den `--base-href`, dann durch die Datenbank-Migration — alles plausibel, alles falsch. **Die Gegenprobe hat es entschieden:** Derselbe Durchgang gegen den Stand **vor** Phase 28 scheiterte identisch, und die exakt gleiche Kombination aus Bau und Adresse hatte eine Stunde zuvor 20/20 bestanden. Damit war die einzige Größe, die sich geändert hatte, der **Rechner**: safaridriver hört nach vielen Sitzungen auf zu zeichnen, ohne Fehlermeldung. ⚠️ Die Lehre ist nicht „safaridriver ist schlecht", sondern: **Wenn ein Werkzeug plötzlich alles rot meldet, ist die erste Messung nicht am Verdächtigen, sondern an einem bekannt guten Vergleichsfall.** Das ist dieselbe Regel wie in Lehre 36, nur eine Ebene höher — dort war die *Messmethode* schuld, hier der *Prüfstand*. Und dass die App in Wahrheit lief, bewies kein Test, sondern ein Bildschirmfoto aus echtem iOS-Safari.

39. **Wer den Rechner abschafft, schafft auch die Hälfte seiner Beweise ab — und merkt es erst, wenn er sie braucht.** Beim Umzug auf „nur noch GitHub" war der erste Gedanke, welche *Befehle* fehlen würden. Die richtige Frage war eine andere: **welche Aussagen** danach niemand mehr treffen kann. Die Antwort war unangenehm: `flutter analyze` und 205 Tests laufen weiter in der Automatik, aber **kein einziger davon öffnet einen Browser** — und Root-in ist eine Web-App. Der Prüfstand, der als einziger „die Seite startet und ist bedienbar" belegen konnte, hing an macOS. ⚠️ Vor jeder Werkzeug-Abschaffung deshalb nicht die Werkzeuge auflisten, sondern die **Zusagen**: Was behaupte ich heute über dieses Projekt, und welches Werkzeug trägt diese Behauptung? Fällt das Werkzeug weg, fällt die Behauptung mit — bis ein Ersatz steht, ist sie eine Hoffnung. Und: **Ein Werkzeug, das nur auf einem Rechner läuft, ist geliehen.** Was tragen soll, gehört dorthin, wo das Projekt lebt.

40. **Eine Bibliothek kann einen Fehlerzustand verstecken — und `pumpAndSettle` versteckt, dass sie es tut.** Mit Riverpod 3 kam still eine automatische Wiederholung fehlgeschlagener Provider dazu: bis zu zehn Versuche, rund 40 Sekunden „lädt" statt „Fehler". Jede Seite mit „Kein Internet" und „Erneut versuchen" zeigte offline stattdessen einen Ladekreis — und alle Widget-Tests blieben grün, weil `pumpAndSettle` die Pausen in virtueller Zeit vorspult und am Ende den Knopf findet. Zwei Regeln daraus: **(a)** Ein Test für einen Fehlerzustand wartet **eine kurze, feste Zeit** und zählt die Versuche — nicht „bis Ruhe ist". **(b)** Nach einem großen Versionssprung einer Kern-Bibliothek nicht nur „baut, Tests grün" prüfen, sondern ihr **neues Standardverhalten** nachlesen. Abgeschaltet an einer Stelle: `lib/core/utils/no_retry.dart`; ein neuer Provider mit eigenem Fehlerzustand bekommt `retry: noAutomaticRetry`.

41. **Eine Gegenprobe prüft nicht nur den Test, sondern auch die App.** Die Gegenprobe des Browser-Durchgangs (31.2) sollte belegen, dass sechs neue Prüfungen rot werden können. Eine blieb grün — und der Grund lag nicht im Test, sondern in der App (Lehre 40). Deshalb läuft sie bei **jedem** Push, nicht nur bei Änderungen am Test: Ob die App ihren Fehlerzustand noch zeigt, kann jede Code-Änderung neu in Frage stellen. ⚠️ **Und die Form zählt:** Sie ist nur grün, wenn **genau** die erwarteten Prüfungen rot sind. „Irgendetwas ist rot" hätte den Fund verschluckt — fünf von sechs sehen aus wie Erfolg.

## 12. Offene Fragen

- **Zwei Geräte, zwei Datenbestände.** ✅ **Mit Phase 27 halb gelöst, und das ist Absicht:** Wer sich auf beiden anmeldet, kann seinen Bestand übertragen (sichern hier, wiederherstellen dort). Ein **stiller Abgleich** in beide Richtungen ist es nicht. Ein echter Abgleich bräuchte Zeitstempel je Zeile und Grabsteine für Löschungen — eine eigene Phase.
- ~~**Erinnerungen im Web: bauen oder als Grenze benennen?**~~ ✅ **Entschieden am 2026-08-17: als Grenze benannt.** Der Nutzer: *„یاد آور ها رو کلا حذف کن چون نسخه وب نمیتونه الارم داشته باشه."* Sie sind **entfernt**, nicht ausgeblendet (Phase 28). ⚠️ Wer sie je zurückholen will, holt sich mehr als einen Schalter zurück: Web-Push braucht Service Worker, Push-Anmeldungen je Gerät, Erinnerungszeiten als abfragbare Zeilen **samt Zeitzone** auf dem Server und einen Wecker, der jede Minute nachsieht — und es ginge **nur mit Konto**, das heute freiwillig ist. Die Begründung steht im Docstring von `platform_support.dart`, dort wird sie gelesen.
- ~~**Wie wird die veröffentlichte Seite künftig geprüft?**~~ ✅ **Seit 29.3 durch einen echten Chrome in der Automatik**, vor jeder Veröffentlichung und blockierend — seit 31.2 mit einer Gegenprobe bei jedem Push. Offen bleibt, was Chrome nicht sieht: Safari und die abgelegte Fassung — dafür das iPhone des Nutzers.
- ⚠️ **Ein Konto für Root-in und Vox** — die Anweisung steht, die Voraussetzungen sind offen (Phase 30). Die wichtigste Frage ist nicht technisch, sondern zeitlich: **vor** dem ersten echten Nutzer ist der Umbau billig, danach nicht mehr.
- ~~**Vollständige Kontolöschung**~~ ✅ **In 31.3 gebaut** (Datenbank-Funktion statt Edge Function). Offen bleibt nur, dass der Nutzer `schema.sql` einspielt.
- **Sollen neue Beiträge in „موارد دیگر" gemeldet werden?** Möglich wäre ein stiller Vergleich beim App-Start (neue Einträge im `index.json` gegenüber dem gespeicherten Stand) und ein Punkt am Einstellungs-Eintrag.
- **Die persische Übersetzung ist ein Entwurf** — alle Schlüssel sind gefüllt, gelesen hat sie noch kein Muttersprachler. Korrekturen betreffen nur `lib/l10n/app_fa.arb`.
- **Farbe je Kategorie?** Heute trägt die Gewohnheit die Farbe. Kategorie-Farben würden Diagramme klarer machen, kosten aber eine DB-Spalte — und damit eine Migration (Abschnitt 9).
- **Direkt in die Telegram-Gruppe teilen?** Das System-Share-Sheet deckt es ab; offen, ob ein eigener Knopf den Sonderweg wert ist.
- **Home-Animation als Lottie-Datei:** Der Slot ist verdrahtet, ein Nutzer-Asset liegt nicht vor.
- **Eigener Hoster statt GitHub Pages?** Pages kann `Cross-Origin-Opener-Policy`/`Embedder-Policy` nicht setzen; Drift nutzt deshalb nicht die schnellste Speicherart. **Kein Datenverlust, eine Frage der Geschwindigkeit** — bisher ist niemandem etwas aufgefallen.
- Genaues Farbschema/Branding, Punkte-Gewichtung je Habit, App-Name final, weitere Sprachen über DE/EN/FA hinaus — weiterhin offen.

⚠️ **Gestrichen mit Phase 28** (standen hier, sind gegenstandslos): iOS-Bundle-Identifier · Sicherungskopie des Signaturschlüssels · persische Store-Sprache · Widget-Labels in der Launcher-Auswahl · Piktogramm auf der Farbkachel.

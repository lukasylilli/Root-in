# Root-in — Projekt-Map (Ordner- & Datei-Übersicht)

> Lebendiges Dokument. Wird bei jeder Struktur-Änderung (neue/verschobene/gelöschte Dateien) aktualisiert.
>
> **Stand 2026-09-13.** **Root-in ist eine Web-App** — live unter `lukasylilli.github.io/Root-in/`. **224 Tests grün**, Browser-Durchgang 23/23 in der Automatik, Gegenprobe bei jedem Push, 13/13 Zugriffsregeln am Server (18, sobald `schema.sql` nach 31.3 eingespielt ist).
>
> ⚠️ **Es gibt keinen Entwicklungsrechner mehr** (PLAN.md Phase 29). Alles, was nicht in diesem Repository liegt, ist gelöscht — auch VS Code. **Diese Datei beschreibt damit nicht mehr „was auf dem Rechner liegt", sondern „was das Repository enthält".** Wer etwas sucht, das hier nicht steht, sucht etwas, das es nicht gibt.
>
> ⚠️ **Phase 28 hat das Projekt auf Web-only zurückgebaut.** Entfernt: `android/`, `ios/`, `macos/`, `linux/`, `windows/` (153 Dateien), `home_widget_service.dart` samt den neun Startbildschirm-Widgets, `notification_service.dart` und `reminders_page.dart` samt allem, was daran hing (bis hinunter in die Datenbank — Schema 4), das Play-Material unter `store/`. Pakete raus: `flutter_local_notifications`, `timezone`, `flutter_timezone`, `home_widget`, `flutter_file_dialog`. **Die Versionsgeschichte behält alles.**
>
> ✅ **Phase 27: Nutzerkonten & Cloud (Supabase).** `supabase/schema.sql`, `core/services/{auth_service, cloud_backup_service, cloud_auto_backup, profile_cloud_sync, username_rules}.dart`, `features/auth/presentation/`, `tool/rls_check.sh`. ⚠️ **Ohne Supabase-Schlüssel im Bau verhält sich die App exakt wie vorher** — keine Anmeldung, keine Rubrik, kein Netzverkehr (`supportsCloudSync`).
>
> ✅ **Phase 29: Arbeiten und Prüfen ohne Rechner.** `tool/webtest_ci.py` (echter Chrome, blockiert die Veröffentlichung), `.github/workflows/rls-check.yml` (Server-Prüfung, von Hand), `tool/build_privacy_page.py` → `privacy.html`, `meine/` jetzt im Repository, `Root-in.code-workspace` entfernt.
>
> ✅ **Phase 31: Was ohne den Nutzer geht.** `auth_sheet.dart` mit Nur-Name-Modus, `accountUsernameProvider`, „Konto löschen" (`delete_own_account()` in `schema.sql`, `AuthService.deleteAccount()`), `tool/webtest_serve.sh`, `.github/workflows/webtest-gegenprobe.yml`, `lib/core/utils/no_retry.dart`, `tool/check_bundle_secrets.py`, Actions auf Node 24.
>
> 📄 **Datenschutzerklärung:** Text in `store/PRIVACY_POLICY.md` → bei jedem Bau online unter `https://lukasylilli.github.io/Root-in/privacy.html` → in der App unter *Einstellungen → Datenschutzerklärung*. **Ändern = die Datei auf GitHub bearbeiten**, sonst nichts. Schritt für Schritt im Abschnitt [Datenschutzerklärung](#datenschutzerklärung).

## Inhaltsverzeichnis
1. [Legende](#legende)
2. [Root-Verzeichnis](#root-verzeichnis)
3. [lib/ (App-Code)](#lib-app-code)
4. [test/](#test)
5. [Web-Fassung & Automatik](#web-fassung--automatik)
6. [Nutzerkonten & Cloud (Supabase)](#nutzerkonten--cloud-supabase)
7. [Inhalts-Repository (GitHub)](#inhalts-repository-github)
8. [Datenschutzerklärung](#datenschutzerklärung)
9. [Hinweise](#hinweise)

## Legende
- ✅ im Repository vorhanden
- ⚙️ generiert (nie von Hand ändern) bzw. beim Bau geholt
- ⛔ **nicht im Repository** — existiert also nicht mehr
- 🕰️ vorhanden, beschreibt aber eine Arbeitsweise, die es nicht mehr gibt (siehe PLAN.md 29.4)
- 🕯️ **stillgelegt in Phase 20** — vollständig auskommentiert, nicht gelöscht. Jede Stelle trägt den Marker
  `PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.`
  Das Wiedereinschalten ist damit ein `grep`, keine Suche.

## Root-Verzeichnis

⚠️ **Das ist der Inhalt von `github.com/lukasylilli/Root-in`, Zweig `main`** — nicht der eines Ordners auf einer Festplatte. Seit Phase 29 gibt es keinen zweiten Ort.

```
github.com/lukasylilli/Root-in  (öffentlich, Zweig main)
├── PLAN.md                          ✅ Gesamtplan/Roadmap der App
├── MAP.md                           ✅ Diese Datei — Struktur-Übersicht
├── README.md                        ✅ Standard-Flutter-README
├── pubspec.yaml                     ✅ Paket-Definition & Dependencies (am Dateiende: flutter_launcher_icons,
│                                        seit Phase 28 nur noch mit `web:`)
├── pubspec.lock                     ✅ Gesperrte Dependency-Versionen
├── analysis_options.yaml            ✅ Lint-Regeln
├── .metadata                        ⚙️ Von Flutter gepflegt (Projekt-Herkunft, migrierte Plattformen) —
│                                        nie von Hand ändern. Nennt noch die entfernten Plattformen; das
│                                        ist folgenlos und wird beim nächsten Flutter-Werkzeuglauf richtig
├── l10n.yaml                        ✅ gen-l10n: ARB in lib/l10n, Ausgabe lib/l10n/gen, Vorlage Deutsch
├── assets/icon/app_icon.png         ✅ EINZIGE Quelle des App-Symbols (1024×1024). Favicon und PWA-Symbole
│                                        entstehen daraus per `dart run flutter_launcher_icons`.
│                                        Nicht in der `assets:`-Liste — wird nur beim Generieren gelesen.
│                                        ⚠️ Versioniert; die Vorlage `meine/Logo.jpeg` ist es NICHT
├── lib/                             ✅ App-Quellcode (siehe unten)
├── test/                            ✅ Tests (siehe unten)
├── store/                           ✅ Begleitende Dokumente — kein Code
│   ├── PRIVACY_POLICY.md                ✅ Datenschutzerklärung DE+EN, aus dem tatsächlichen Verhalten der App
│   │                                    abgeleitet. **EINZIGE Quelle** — bei jedem Bau wird daraus
│   │                                    `privacy.html` (PLAN.md 29.5, Abschnitt „Datenschutzerklärung"
│   │                                    unten). Ändern = diese Datei bearbeiten, sonst nichts.
│   │                                    Stand Phase 28: Web-only. Abschnitte zu Android-Sicherung und
│   │                                    Benachrichtigungen sind GESTRICHEN, neu ist Punkt 5 „Wo deine
│   │                                    Daten im Browser liegen" (Website-Daten löschen, Safaris
│   │                                    Sieben-Tage-Regel, jedes Gerät ein eigener Bestand).
│   │                                    ⚠️ Die INTERNE NOTIZ am Dateiende landet NICHT auf der Seite
│   ├── OTHERS_CONTENT.md                Pflege-Anleitung für die Rubrik „موارد دیگر" (Phase 22): wo die
│   │                                    Dateien liegen, Felder des Manifests, was der Nutzer sieht, wenn
│   │                                    etwas fehlt, häufige Fehler
│   └── others_index_beispiel.json       Gültige Vorlage zum Hochladen — ein Test prüft sie mit, damit die
│                                        Anleitung nicht in die Irre führt
├── meine/                           ✅ **Referenzmaterial des Nutzers — seit 2026-09-12 im Repository**
│                                        (auf seine Entscheidung; vorher bewusst ausgeschlossen und damit
│                                        die letzte Kopie, PLAN.md 28.0). 23 Dateien: 19 Vorlagen-Bilder
│                                        für Diagramme/Widgets, `Berg-Animation` (React/SVG, Phase 8.6),
│                                        zwei Design-Specs als JSON (Phase 10.6) und `Logo.jpeg` — die
│                                        Quelle von `assets/icon/app_icon.png`.
│                                        ⚠️ Nur Vorlage, kein Code: Die App liest nichts daraus. Das
│                                        Ergebnis steckt in Symbol, Design-Tokens und
│                                        `ascent_scene_painter.dart`
├── web/                             ✅ **Die App** (PLAN.md Phase 26/28) — seit Phase 28 die einzige
│   │                                    Plattform des Projekts
│   ├── index.html                   ✅ Einstiegsseite, Markenfarbe schon vor dem ersten Frame + iOS-Meta-Tags.
│   │                                    ⚠️ Safari liest fürs Ablegen apple-mobile-web-app-*, NICHT
│   │                                    manifest.json — ohne sie öffnet die Verknüpfung eine Browser-Seite
│   │                                    mit Adressleiste statt einer App.
│   │                                    ⚠️ KEIN `viewport-fit=cover`, Statusleiste `default` (Phase 26.13):
│   │                                    beides zieht die Seite unter die Statusleiste, und Flutter wertet
│   │                                    im Web die Schutzabstände nicht aus → Bild und Berührung liegen
│   │                                    auseinander. Nicht „zur Verschönerung" zurückdrehen (Lehre 34)
│   ├── manifest.json                ✅ PWA-Manifest (Root-in, Markengrün #2E7D5B, Symbole)
│   ├── sqlite3.wasm                 ⚙️ NICHT versioniert — tool/fetch_web_db_assets.sh holt sie. Ohne diese
│   │                                    Datei wirft driftDatabase() im Browser, die App startet gar nicht
│   ├── drift_worker.js              ⚙️ NICHT versioniert — dieselbe Quelle, Version aus pubspec.lock
│   ├── favicon.png, icons/          ⚙️ Aus assets/icon/app_icon.png erzeugt (Phase 26.11) — EINE Quelle,
│   │                                    `dart run flutter_launcher_icons` (seit Phase 28 nur noch Web).
│   │                                    Bis dahin lagen hier die Symbole der Flutter-Vorlage: das blaue
│   │                                    „F" stand als App-Symbol auf dem Home-Bildschirm (PLAN.md 26.10).
│   │                                    ⚠️ favicon.png ist 16 px — von der Strichzeichnung bleibt dort
│   │                                    fast nichts. Deshalb nennt index.html zusätzlich Icon-192.png
│   └── .gitignore                   ✅ Hält die beiden erzeugten Dateien aus der Versionierung
├── content/                         ✅ Die Anleitungs-Texte (Phase 17.1/22) — seit Phase 26.2 IM PROJEKT,
│   └── de|en|fa/                        vorher ein eigenes GitHub-Repository. Sie werden zur Laufzeit
│                                        geladen, wirken also weiterhin OHNE App-Update. Einzelheiten im
│                                        Abschnitt „Inhalts-Repository (GitHub)"
├── tool/                            ✅ Bau-Skripte (siehe Abschnitt „Web-Fassung & Automatik")
├── .github/workflows/deploy-web.yml ✅ Push auf main → analyze + test → build_web.sh → Browser-Durchgang → GitHub Pages
├── .github/workflows/rls-check.yml  ✅ Server-Zugriffsregeln von außen — NUR von Hand (Actions → Run workflow)
├── .github/workflows/webtest-gegenprobe.yml ✅ Gegenprobe: baut absichtlich beschädigt und muss GENAU die
│                                        erwarteten Prüfungen rot sehen — bei jedem Push, veröffentlicht nichts
├── .env.example                     ✅ Vorlage für --dart-define-from-file (die echte .env ist ausgeschlossen);
│                                        seit Phase 27.3 mit SUPABASE_URL und SUPABASE_ANON_KEY
├── supabase/schema.sql              ✅ Phase 27.4 — Server-Schema + Zugriffsregeln, versioniert
├── .claude/
│   ├── settings.json                🕰️ Freigabeliste für Claude Code (Phase 26.9): weniger Rückfragen bei
│   │                                    flutter-/git-Befehlen, `defaultMode: acceptEdits`.
│   │                                    ⚠️ Gilt für Claude Code auf einem Rechner — in der Cloud greift
│   │                                    sie nicht (29.4)
│   │                                    ⚠️ Bewusst OHNE Muster wie `for *`/`awk *` — die sähen eng aus,
│   │                                    erlauben aber jeden beliebigen Befehl. Wer gar keine Rückfrage
│   │                                    will, nimmt den Modus-Umschalter, nicht eine getarnte Liste
│   └── settings.local.json          ⛔ war maschinenlokal — mit dem Rechner verschwunden
└── .env                             ⛔ war die lokale Vorlage-Kopie — mit dem Rechner verschwunden.
                                         **Kein Verlust:** Beide Werte liegen als GitHub-Actions-Secrets
                                         (`SUPABASE_URL`, `SUPABASE_ANON_KEY`), und der `anon`-Schlüssel
                                         steht ohnehin lesbar im veröffentlichten Bundle (Lehre 26)
```

## lib/ (App-Code)

**Funktionsstand:** Home mit Berg-Animation, individualisierbarem Dashboard und Teilen-Knopf · Heute-Seite mit Tagesring, Abhaken, Bearbeiten/Löschen · View mit vier Tabs (Woche/Übersicht/Monat/Jahr, Übersicht zusätzlich im Vollbild) · Konto mit **Rubrik „Konto & Cloud"**, Profil, Achievements, lebenslanger Statistik und Fortschritt-Teilen · Kategorien: sieben Standard-Kategorien beim Erststart, danach frei verwaltbar · Sicherung exportieren/importieren **und optional in die Cloud** · Rubrik „Root-in Anleitung" mit vier Seiten aus dem Repository · Darstellungsmodus, Farb-Variante und Sprache (**DE/EN/FA, Persisch inkl. RTL**) über je **einen** Schalter · dreiteilige Erststart-Erklärung · Fortschritts-Karte mit Übersicht-Block und QR-Code · **keine Werbung, keine In-App-Käufe** (🕯️ Phase 20).

⚠️ **Was es NICHT gibt (PLAN.md Phase 28):** Erinnerungen, Tagesstand-Meldung, Startbildschirm-Widgets, Querformat-Sperre. Nicht „im Browser ausgeblendet" — **entfernt**, bis hinunter in die Datenbank (Schema 4).

**Freiwilliges Nutzerkonto (Phase 27):** E-Mail + Passwort + Benutzername, Cloud-Sicherung im vorhandenen Backup-Format. ⚠️ **Ohne Konto und ohne Schlüssel im Bau ändert sich nichts** — die App bleibt vollständig lokal benutzbar.

```
lib/
├── main.dart                                 ✅ Einstiegspunkt: SharedPreferences, Bitte um dauerhaften
│                                                 Browser-Speicher, Supabase-Start (nur mit Schlüsseln),
│                                                 Standard-Kategorien in der gespeicherten Sprache, dann
│                                                 UncontrolledProviderScope (expliziter ProviderContainer,
│                                                 weil der Kategorie-Seed vor dem ersten Frame laufen muss).
│                                                 ⚠️ Der Container trägt `retry: noAutomaticRetry` (31.2b)
│                                                 🕯️ Enthält den Start des Werbe-SDKs (Phase 14)
├── main_seed.dart                            ✅ Zweiter Einstiegspunkt, NUR für Store-Screenshots und um eine
│                                                 Seite mit echtem Bestand anzusehen: sät ~400 Tage (je
│                                                 Gewohnheit nur an ihren Wochentagen, daraus folgt timesPerWeek),
│                                                 setzt Sprache (de, oder en via --dart-define=SEED_LANG=en),
│                                                 onboarding_seen und remove_ads_purchased (kein Werbe-SDK),
│                                                 ruft danach main.dart. Säht in einem eigenen Container, der vor
│                                                 dem App-Start geschlossen wird. Nie in einen Release-Build
├── app.dart                                  ✅ MaterialApp.router; ThemeMode/Farb-Variante/Sprache aus Providern.
│                                                 Vier Listener an genau EINER Stelle: Fortschritt und
│                                                 Gewohnheiten → Cloud-Sicherung (entprellt), Anmelden →
│                                                 Namensabgleich, lokaler Namenswechsel → hochladen.
│                                                 ⚠️ Bis Phase 28 hingen hier auch Startbildschirm-Widget und
│                                                 Tagesstand-Meldung („ein Sender, mehrere Empfänger",
│                                                 Phase 10/23). Der Gedanke trägt weiter, die zwei Empfänger
│                                                 sind weg
├── l10n/
│   ├── app_de.arb                            ✅ Vorlage-Sprache, 276 Schlüssel. Neue Strings **hier zuerst**
│   ├── app_en.arb                            ✅ Englische Fassung derselben Schlüssel
│   ├── app_fa.arb                            ✅ Persisch (Phase 18) — alle 276 Schlüssel, Reihenfolge wie
│   │                                             app_de.arb. Fehlt einer, fällt gen-l10n STILL auf Deutsch
│   │                                             zurück; `persian_ui_test.dart` prüft das stichprobenartig.
│   │                                             ⚠️ Entwurf — der Nutzer geht ihn als Muttersprachler durch
│   └── gen/                                  ⚙️ AppLocalizations — gitignored, entsteht bei jedem Build
├── core/
│   ├── theme/
│   │   ├── app_colors.dart                   ✅ Einzige Quelle für Farbwerte (u. a. Standard-Habit-Farbe)
│   │   ├── app_theme_tokens.dart             ✅ Design-Tokens nach Spec (accent/cardBg/ringTrack/… + heat());
│   │   │                                         appTokensProvider je Variante+Helligkeit
│   │   ├── app_theme_variant.dart            ✅ Farbthemes (Grün/Blau/Lila/Orange), tokens(brightness)
│   │   ├── app_fonts.dart                    ✅ Einzige Quelle für die Schriftart. Bewusst `null` = Plattform-
│   │   │                                         Schrift, auch für Persisch (Android bringt Noto Naskh Arabic
│   │   │                                         mit; Begründung in der Datei). Zeigt ein Gerät Kästchen, ist
│   │   │                                         DIESE Zeile der eine Ort für eine arabische Schrift
│   │   ├── app_text_styles.dart              ✅ Text-Styles, bauen auf AppFonts auf
│   │   ├── app_spacing.dart                  ✅ Einzige Quelle für Abstände/Radien
│   │   └── app_theme.dart                    ✅ Light-/Dark-ThemeData aus vollen Tokens (Scaffold-/Card-/AppBar-
│   │                                             Flächen kommen von dort → alle Seiten ziehen automatisch nach)
│   ├── routing/
│   │   ├── app_routes.dart                   ✅ Einzige Quelle für Routen-Pfade (/account, /categories,
│   │   │                                         /onboarding, /view/overview-fullscreen,
│   │   │                                         /guide-Präfix — die vier Themen-Pfade baut GuideTopic)
│   │   └── app_router.dart                   ✅ go_router: ShellRoute (4 Hauptseiten) + Detailseiten außerhalb
│   │                                             der Shell. Bewusst eine Funktion createAppRouter(showOnboarding:)
│   │                                             statt einer Konstante — EINMALIG in app.dart bauen
│   ├── l10n/
│   │   ├── app_language.dart                 ✅ Wählbare Sprachen (System/فارسی/Deutsch/Englisch). Seit Phase 18
│   │   │                                         ist Persisch vollwertig: `locale` liefert `fa` für Oberfläche
│   │   │                                         UND Inhalte, der Zwischenstands-Begriff `contentLanguageCode`
│   │   │                                         ist ersatzlos entfallen. Dazu resolveLocale() für Texte ohne
│   │   │                                         BuildContext (Standard-Kategorien, Teilen-Texte)
│   │   │                                         `fallbackLocale` = **en** seit 31.6 (2026-09-16; vorher de)
│   │   └── app_numbers.dart                  ✅ Einzige Zahlen-Formatierung (Phase 18.4). Hält die Entscheidung
│   │                                             fest: **westliche Ziffern in allen Sprachen**, mit vier
│   │                                             Gründen. Eine Umstellung auf persische Ziffern betrifft nur
│   │                                             diese Datei — vorausgesetzt, niemand baut Prozente selbst
│   ├── constants/
│   │   ├── habit_templates.dart              ✅ 11 Vorlagen mit stabiler id, Name über name(l10n) und seit
│   │   │                                         Phase 21 ein Feld `categoryId` je Vorlage — der Kategorie-Name
│   │   │                                         kommt aus default_categories.dart, also aus EINER Quelle
│   │   ├── default_categories.dart           ✅ Die sieben Fertigkeiten als Standard-Kategorien (Phase 21.1):
│   │   │                                         stabile IDs + Name je Sprache + Symbol. iconForName() ordnet
│   │   │                                         das Symbol über den NAMEN zu (die DB kennt keine Symbol-
│   │   │                                         Spalte) — wer umbenennt, verliert es. Richtig so
│   │   ├── achievements.dart                 ✅ 11 Achievements; Titel/Beschreibung über l10n, Liste sprachneutral
│   │   ├── dashboard_defaults.dart           ✅ Standard-Widget-Listen je Seite (benannte const-Listen — stabile
│   │   │                                         Family-Schlüssel, siehe Kommentar in der Datei)
│   │   ├── contact_info.dart                 ✅ Kontaktziel für „Kontakt uns"
│   │   ├── app_config.dart                   ✅ Werte, die beim BAUEN hereinkommen (String.fromEnvironment):
│   │   │                                         versionName, buildNumber, fullVersion (Phase 26.5/26.6).
│   │   │                                         ⚠️ Trägt die Warnung, dass ein --dart-define KEINE
│   │   │                                         Verschlüsselung ist — der Wert steht im Bundle. Sie steht
│   │   │                                         dort, wo jemand den ersten Schlüssel eintragen würde
│   │   ├── app_links.dart                    ✅ Einzige Quelle der öffentlichen Adressen (Phase 19).
│   │   │                                         Drei Leser: QR-Code auf der Karte, Share-Begleittext,
│   │   │                                         „App teilen" in den Einstellungen. Sie lesen
│   │   │                                         `appShareUrl` = `webAppUrl`.
│   │   │                                         ⚠️ `appShareUrl` ist bewusst eine EIGENE Konstante,
│   │   │                                         obwohl identisch: Ihr Name sagt, wofür die Adresse da
│   │   │                                         ist. Bis 27.11 zeigte sie auf eine Play-Seite mit
│   │   │                                         HTTP 404 — jeder geteilte QR-Code lief ins Leere.
│   │   │                                         `playStoreUrl`/`appPackageName` sind mit Phase 28 weg.
│   │   │                                         `privacyPolicyUrl` = `webAppUrl` + `privacy.html` (29.5)
│   │   ├── ad_config.dart                    🕯️ Ad-Unit-IDs + Test-Geräte + Not-Schalter adsDisabledForEveryone
│   │   └── app_assets.dart                   ✅ Asset-Pfade; AppAssets.homeAnimation = Lottie-Slot (null →
│   │                                             eingebaute gemalte Animation)
│   ├── utils/
│   │   ├── date_utils.dart                   ✅ dateOnly, addDays (DST-sicher), weekStartOf
│   │   ├── streak_calculator.dart            ✅ Reine Streak-Logik inkl. 1-Frei-Tag/Woche (unit-getestet)
│   │   ├── achievement_evaluator.dart        ✅ Reine Freischalt-Logik (unit-getestet)
│   │   ├── no_retry.dart                     ✅ noAutomaticRetry (PLAN.md 31.2b) — schaltet Riverpods
│   │   │                                         automatische Wiederholung ab. Ohne sie zeigte eine Seite
│   │   │                                         ohne Netz ~40 s einen Ladekreis statt „Kein Internet".
│   │   │                                         Gilt am Container in main.dart UND an jedem Provider mit
│   │   │                                         eigenem Fehlerzustand (Tests sehen den Container nie)
│   │   └── platform_support.dart             ✅ **Die einzige Stelle im Projekt, an der `kIsWeb` steht.**
│   │                                             Nach Phase 28 nur noch vier Abfragen:
│   │                                             usesBrowserStorage (26.8), supportsOrientationLock,
│   │                                             canReadForeignResponseHeaders (26.11 — fremde Kopfzeilen
│   │                                             gibt der Browser nur soweit frei, wie CORS es erlaubt,
│   │                                             und `Date` gehört nicht dazu),
│   │                                             supportsCloudSync (Phase 27 — nur true, wenn BEIDE
│   │                                             Supabase-Werte gesetzt sind; ein Bau ohne Schlüssel
│   │                                             verhält sich exakt wie vor Phase 27).
│   │                                             ⚠️ supportsReminders und supportsHomeScreenWidgets sind
│   │                                             mit Phase 28 ENTFALLEN — es gibt nichts mehr abzufragen.
│   │                                             Die Regel bleibt trotzdem: nach FÄHIGKEIT benennen, nicht
│   │                                             nach Plattform, und `kIsWeb` steht nur hier
│   │                                             🕯️ isStorePlatform ist mit Phase 20 auskommentiert
│   ├── services/
│   │   ├── time_service.dart                 ✅ Aktuelles Datum (HTTP-Date-Header + Offline-Fallback), über
│   │   │                                         `package:http` (Lehre 30). ⚠️ Im Browser wird die EIGENE
│   │   │                                         Adresse gefragt (Uri.base + Zeitstempel gegen den
│   │   │                                         Zwischenspeicher) — fremde Kopfzeilen sind dort nicht lesbar
│   │   ├── settings_service.dart             ✅ Persistiert ThemeMode, AppThemeVariant, AppLanguage, AscentSource,
│   │   │                                         onboarding_seen, share_include_overview (Phase 19) und
│   │   │                                         share_include_overview;
│   │   │                                         dazu appLocaleProvider (MaterialApp.locale) und
│   │   │                                         resolvedLocaleProvider (Texte ohne BuildContext)
│   │   ├── profile_service.dart              ✅ Persistiert UserProfile (Name). Phase 27.6 spiegelt ihn
│   │   │                                         auf den Server — lokal bleibt er die Quelle der Anzeige
│   │   ├── auth_service.dart                 ✅ **Phase 27.5** — die EINZIGE Stelle für `supabase_flutter`
│   │   │                                         (Bauart wie share_service). Anmelden,
│   │   │                                         Registrieren, Abmelden, Sitzungs-Zustand, Benutzername.
│   │   │                                         ⚠️ Fehler kommen als Grund-Code heraus, nicht als
│   │   │                                         englischer Server-Text (Muster: backup_data.dart)
│   │   ├── cloud_backup_service.dart         ✅ **Phase 27.7** — Bestand als Backup-JSON hoch/runter.
│   │   │                                         ⚠️ Nutzt `backup_data.dart` UNVERÄNDERT — ein zweites
│   │   │                                         Serialisierungs-Format wäre die verbotene Doppelung.
│   │   │                                         Hochladen automatisch, Herunterladen nur auf Nachfrage
│   │   ├── cloud_auto_backup.dart            ✅ **Phase 27.7** — entprellte automatische Sicherung (20 s)
│   │   ├── profile_cloud_sync.dart           ✅ **Phase 27.6** — Anzeigename Gerät ↔ Server
│   │   ├── username_rules.dart               ✅ **Phase 27.5** — was ein gültiger Benutzername ist
│   │   ├── share_service.dart                ✅ Einzige Stelle für share_plus: shareApp (Text) und
│   │   │                                         shareProgressImage (Bytes → Share-Sheet). Beide Texte tragen
│   │   │                                         `appShareUrl` aus app_links.dart — seit 27.11 die
│   │   │                                         Web-Fassung, vorher der tote Play-Link (27.11).
│   │   │                                         Seit Phase 26.1 OHNE dart:io/path_provider: XFile.fromData
│   │   │                                         übergibt die Bytes direkt, share_plus legt selbst eine
│   │   │                                         Temp-Datei an. Dadurch auf allen drei Plattformen ein Weg.
│   │   │                                         ⚠️ fileNameOverrides ist Pflicht — XFile.fromData reicht
│   │   │                                         `name` außerhalb des Webs nicht durch
│   │   ├── backup_service.dart               ✅ Sicherung schreiben und einlesen; Serialisierung in
│   │   │                                         backup_data.dart. Ebenfalls seit Phase 26.1 plattformfrei:
│   │   │                                         Export über XFile.fromData mit downloadFallbackEnabled
│   │   │                                         (im Browser = Download), Import über file_pick/
│   │   ├── file_pick/                        ✅ Datei auswählen und deren INHALT liefern (nicht den Pfad —
│   │   │   │                                     im Browser gibt es keine Pfade). Bedingter Import, damit in
│   │   │   │                                     keinem Bau Code der anderen Plattform steckt (Phase 26.1)
│   │   │   ├── pick_text_file.dart               Weiche: export io … if (dart.library.js_interop) web
│   │   │   ├── pick_text_file_io.dart            ⚠️ Seit Phase 28 ein STUB, der `null` liefert — und zwar
│   │   │   │                                      mit Absicht: `flutter test` läuft auf der Dart-VM und
│   │   │   │                                      wählt genau diesen Zweig. Ohne ihn liesse sich
│   │   │   │                                      backup_service.dart nicht übersetzen
│   │   │   └── pick_text_file_web.dart           Browser: <input type="file"> + FileReader.
│   │   │                                         ⚠️ `oncancel` ist Pflicht: Bricht der Nutzer ab, feuert
│   │   │                                         `onchange` NIE — das Future bliebe für immer offen
│   │   ├── web_storage/                      ✅ Bittet den Browser, den Speicher DAUERHAFT zu behalten
│   │   │   │                                     (Phase 26.8). Dieselbe Bauart wie file_pick/.
│   │   │   │                                     ⚠️ Eine Bitte, keine Garantie — der Browser entscheidet
│   │   │   ├── request_persistent_storage.dart      Weiche (bedingter Export)
│   │   │   ├── …_io.dart                            Nicht-Web: sofort `false` (nur die Dart-VM im Test)
│   │   │   └── …_web.dart                           navigator.storage.persisted() → persist()
│   │   ├── repo_content_service.dart         ✅ **Einziger** Weg an Repository-Inhalte (Anleitung + „موارد دیگر").
│   │   │                                         Lädt jeden Pfad unter `content/` als Text und legt
│   │   │                                         sie in shared_preferences ab → offline lesbar. Zeigt erst den
│   │   │                                         gespeicherten Stand und lädt daneben nach; meldet NUR bei
│   │   │                                         geändertem Text (sonst Endlosschleife). 404 → „Inhalt folgt".
│   │   │                                         Netzzugriff hinter RepoFetcher (in Tests ersetzbar); seit
│   │   │                                         Phase 26.11 `package:http` statt `dart:io` — letzteres warf
│   │   │                                         im Browser, weshalb alle fünf Anleitungs-Seiten „kein
│   │   │                                         Internet" zeigten (PLAN.md 26.10, Lehre 30)
│   │   ├── dashboard_layout_service.dart     ✅ Persistiert je Seite (pageId) die aktive Widget-Liste;
│   │   │                                         dashboardLayoutProvider (Family), toggle/reorder
│   │   ├── ads_service.dart                  🕯️ Einzige Stelle für google_mobile_ads (idempotenter Start,
│   │   │                                         adaptives Banner; Fehler werden geschluckt und geloggt)
│   │   └── purchase_service.dart             🕯️ Einzige Stelle für in_app_purchase/Play Billing + adsRemovedProvider
│   └── widgets/
│       ├── main_shell.dart                   ✅ Bottom-Nav-Rahmen (Home/Heute/View/Einstellungen). 🕯️ Der
│       │                                         BannerAdSlot darüber ist mit Phase 20 entfallen; die Column,
│       │                                         die ihn trug, ebenso (kein leerer Streifen mehr)
│       ├── banner_ad_slot.dart               🕯️ Das eine Banner am unteren Rand (Phase 14)
│       ├── markdown_view.dart                ✅ **Einzige** Markdown-Darstellung (Phase 22 aus guide_page.dart
│       │                                         herausgezogen): MarkdownView + ContentLoading/
│       │                                         ContentLoadFailed/ContentComingSoon/ContentPanel. Anleitung
│       │                                         UND „موارد دیگر" nutzen sie — zwei Stylesheets wären zwei
│       │                                         Stellen für jeden Design-Wechsel
│       ├── app_button.dart                   ✅ Einzige Button-Komponente der App
│       ├── web_storage_hint.dart             ✅ maybeShowWebStorageHint(...) — einmaliger Dialog NUR im
│       │                                         Browser (Phase 26.8): warum Root-in auf den Home-Bildschirm
│       │                                         gehört und warum die Sicherung hier wichtiger ist.
│       │                                         ⚠️ Safari löscht den Speicher einer Website nach SIEBEN
│       │                                         TAGEN ohne Besuch; für eine auf dem Home-Bildschirm
│       │                                         abgelegte Seite gilt das nicht. Das Ablegen ist damit
│       │                                         keine Bequemlichkeit, sondern Datenerhalt.
│       │                                         Aufgerufen von der Home-Seite (nicht vom Onboarding —
│       │                                         das läuft nur bei frischer Installation und erreichte
│       │                                         bestehende Web-Nutzer nie). Eigener Prefs-Merker
│       │                                         `web_storage_hint_seen`; erst merken, dann zeigen
│       ├── text_prompt_dialog.dart           ✅ Einziger „Text eingeben"-Dialog (Kategorie anlegen/umbenennen)
│       ├── stat_column.dart                  ✅ Einzige Label+Wert-Spalte
│       ├── progress_ring.dart                ✅ Einziger Fortschritts-Ring; Werte+Tokens statt Provider →
│       │                                         auch offscreen nutzbar
│       ├── week_checklist.dart               ✅ Wochen-Checkliste Mo–So (Widget-Familie „checklist")
│       ├── progress_summary_header.dart      ✅ Prozent- & Punkte-Anzeige (Heute + Home)
│       ├── matrix_grid.dart                  ✅ Matrix-/Heatmap-Grid; fitToWidth skaliert Zelle **und** Rand auf
│       │                                         die verfügbare Breite; optional tokens → Heatfarbe aus dem Theme
│       ├── section_card.dart                 ✅ Geteilte Titel+Inhalt-Karte
│       ├── chart_card.dart                   ✅ Einziger fl_chart-Wrapper: CategoryBarChart, ProgressTrendChart,
│       │                                         CategoryPieChart, DayGridLineChart/DayGridBarChart (ein Wert je
│       │                                         Rasterspalte, ohne Achsen/Innenabstand — Voraussetzung für die
│       │                                         spaltengenaue Übersicht), categoryPalette(scheme).
│       │                                         Seit Phase 13 zusätzlich trendBucketDays(dayCount) und
│       │                                         trendSeries(start, end, intensities) — reine Funktionen, damit die
│       │                                         Bündelung ohne Rendern prüfbar ist. `axisLabelInterval` ist mit
│       │                                         Phase 13 entfallen (die Y-Achse zeigt jetzt nur noch 0 und den
│       │                                         Höchstwert, ein Intervall genügte nicht: fl_chart beschriftet
│       │                                         zusätzlich immer den Rand maxY).
│       │                                         _chartHeight = 180 ist fest. ⚠️ Der Grund dafür ist mit
│       │                                         Phase 28 entfallen (die Widgets rendern dieselben
│       │                                         Diagramme nicht mehr in 320×200) — die feste Höhe bleibt,
│       │                                         weil die Seiten darauf ausgelegt sind.
│       │                                         ⚠️ Beschriftungen neben einem Diagramm IMMER mit
│       │                                         Alignment.centerRight/TextAlign.right, nie richtungsabhängig:
│       │                                         fl_chart kennt keine Textrichtung, die Y-Achse liegt in jeder
│       │                                         Sprache physisch links (siehe PLAN.md Lehre 25)
│       ├── monthly_bar_chart.dart            ✅ Horizontale Monats-Balken, bewusst kein fl_chart
│       ├── share_card.dart                   ✅ Einzige Fortschritts-Karte (Phase 19 überarbeitet): Kopfzeile
│       │                                         mit Profilname + Datum, sechs Kennzahlen als **Wrap** (eine
│       │                                         Row lief um 169 px über), optionaler Übersicht-Block,
│       │                                         Jahres-Matrix, Fußzeile mit QR-Code zum Store. Reine Werte +
│       │                                         AppThemeTokens statt Provider, KEIN eigener Farbwert.
│       │                                         **Feste Breite** (440 px schmal / ~1334 px mit Übersicht) —
│       │                                         das geteilte Bild soll überall gleich aussehen. Den
│       │                                         Übersicht-Block bekommt sie als fertiges Widget, damit core/
│       │                                         nichts aus features/ importieren muss
│       └── dashboard/                        ✅ Individualisierbares Widget-Dashboard
│           ├── dashboard_widget_type.dart        Katalog-Enum (5 Typen) + Label
│           ├── dashboard_widget_builder.dart     Einzige Typ+Zeitraum → Widget-Zuordnung
│           └── dashboard_section.dart            Anpassen-Modus: ReorderableListView, Hinzufügen/Entfernen-Chips
├── data/
│   ├── local/
│   │   ├── database.dart                     ✅ AppDatabase (Drift) + appDatabaseProvider; forTesting(executor);
│   │   │                                         schemaVersion 3, onCreate (nur Tabellen — Kategorien legt der
│   │   │                                         App-Start sprachabhängig an), onUpgrade 1→2 / 2→3
│   │   ├── database.g.dart                   ⚙️ build_runner
│   │   ├── tables/{habits,habit_completions,categories}_table.dart ✅ Habits,
│   │   │                                         HabitCompletions (unique habitId+date), Categories (name unique).
│   │   │                                         ⚠️ Die zwei Reminder-Spalten sind mit Phase 28 (Schema 4) weg
│   │   └── daos/
│   │       ├── habit_dao.dart                ✅ CRUD/Watch inkl. updateHabit (Teil-Update via `.write()`,
│   │       │                                     bewusst kein `.replace()`), deleteHabit (transaktional),
│   │       │                                     archiveHabit
│   │       ├── habit_completion_dao.dart     ✅ CRUD/Watch + watchAllCompletions (lebenslang)
│   │       ├── category_dao.dart             ✅ getOrCreateCategory, renameCategory (kaskadiert auf Habits),
│   │       │                                     deleteCategory → DeleteCategoryOutcome (Status + Anzahl der
│   │       │                                     blockierenden Gewohnheiten), ensureDefaultCategories (die
│   │       │                                     sieben, NUR wenn die Tabelle leer ist) und
│   │       │                                     addMissingCategories (Nachrüsten für Bestandsnutzer)
│   │       └── backup_dao.dart               ✅ Liest den kompletten Bestand (inkl. archivierter Habits) und
│   │                                             schreibt ihn per replaceAll in EINER Transaktion zurück
│   ├── models/
│   │   ├── habit_goal_type.dart              ✅ Enum: checkbox vs. duration
│   │   ├── habit_with_day_status.dart        ✅ Habit + Status **an einem bestimmten Tag** (View-Model).
│   │   │                                         Hieß bis Phase 24 habit_with_today_status.dart — seit die
│   │   │                                         Heute-Seite jedes Datum zeigen kann, wäre „today" falsch
│   │   ├── daily_progress.dart               ✅ Prozent/Punkte für den Tageskontext (+ `empty` für den Zustand,
│   │   │                                         solange das Datum noch lädt)
│   │   ├── category_breakdown.dart           ✅ Erledigungen je Kategorie
│   │   ├── user_profile.dart                 ✅ Lokales Nutzerprofil (Name)
│   │   ├── lifetime_stats.dart               ✅ Lebenslange Statistik
│   │   ├── monthly_breakdown.dart            ✅ Erledigungen je Kalendermonat
│   │   ├── habit_period_stats.dart           ✅ Kennzahlen je Gewohnheit über einen Zeitraum (erledigt/offen/
│   │   │                                         Prozent aus EINER Rechnung + aktuelle/längste Serie) —
│   │   │                                         Datenquelle der Übersicht-Seite (und ab Phase 19 der Karte)
│   │   └── backup_data.dart                  ✅ Inhalt einer Sicherung + toJson/fromJson (ohne Datei-/Plattform-
│   │                                             Zugriff → ohne Emulator testbar); wirft BackupFormatException
│   │                                             mit Grund-Code statt Text → sprachneutral
│   └── repositories/
│       └── habit_repository.dart             ✅ Einzige Zugriffsschicht + alle Riverpod-Provider.
│                                                 **Phase 24:** selectedDateOverrideProvider (null = heute) →
│                                                 selectedDateProvider; die Tages-Provider sind Families über
│                                                 ein Datum (completionsForDate, habitsWithStatusForDate,
│                                                 dayProgress). todayProgressProvider = Family(heute) für
│                                                 Widget/Karte, selectedDayProgressProvider = Family(gewählt)
│                                                 für die Heute-Seite. Dazu: heutige Habits,
│                                                 Status, Tagesfortschritt, completionsInRange,
│                                                 dailyCompletionCount, dailyIntensity, categoryBreakdown,
│                                                 habitDaysInRange, habitPeriodStats, weeksInRange,
│                                                 monthlyBreakdown, allCompletions, firstActivityDate,
│                                                 lifetimeStats, unlockedAchievementIds, categoriesProvider;
│                                                 add/update/deleteHabit, add/rename/deleteCategory,
│                                                 ensureDefaultCategory, habitTileData
├── features/
│   ├── home/presentation/
│   │   ├── home_page.dart                    ✅ Berg-Animation + Fortschritts-Header + Knopf „Fortschritt
│   │   │                                         teilen" (Phase 19, ruft showShareProgressSheet) + Dashboard
│   │   │                                         (16 Wochen, pageId „home")
│   │   ├── home_progress_animation.dart      ✅ Karte + HUD (Prozent, „Noch X % bis Camp Y %"), weicher Übergang;
│   │   │                                         rendert Lottie, sobald AppAssets.homeAnimation gesetzt ist
│   │   ├── ascent_scene_painter.dart         ✅ Malt die Szene nach Nutzer-Vorlage (Himmel, Sterne, Sonne,
│   │   │                                         Bergketten, Serpentinen-Pfad, Camps in Prozent, Figur, Fahne)
│   │   └── ascent_source.dart                ✅ Wählbare Kennzahl der Animation (heute/Woche/Monat/Jahr)
│   ├── today/presentation/today_page.dart    ✅ **Datumszeile** (Pfeile, Datumsauswahl, zurück auf heute —
│   │                                             Zukunft gesperrt, Phase 24), Tagesring-Kopf, Liste, Abhaken,
│   │                                             „+"-FAB, Menü Bearbeiten/Löschen
│   ├── view/
│   │   ├── presentation/
│   │   │   ├── view_page.dart                ✅ Tab-Container (Woche/Übersicht/Monat/Jahr; overviewTabIndex für
│   │   │   │                                     die Querformat-Sperre)
│   │   │   └── range_matrix_tab.dart         ✅ Geteilte Tab-Basis (Titel + Zeitraum → Dashboard); Tabs
│   │   │                                         konfigurieren nur pageId/availableTypes/defaultTypes
│   │   ├── week/week_tab.dart                ✅ Aktuelle Kalenderwoche (pageId „week")
│   │   ├── overview/                         ✅ Letzte 4 Kalenderwochen als EINE feste, quer liegende Bühne —
│   │   │   │                                     bewusst KEIN Dashboard, das gemeinsame Raster ist der Sinn
│   │   │   ├── overview_metrics.dart         ✅ Einzige Quelle ALLER Maße (dayWidth/rowHeight/matrixTop/…) →
│   │   │   │                                     jeder Tag steht überall in derselben Spalte
│   │   │   ├── overview_board.dart           ✅ Das Board (Linie, Wochen-Köpfe, Wochentage, Balken, Gesamtziel,
│   │   │   │                                     Habit×Tag-Matrix, Wochen-Kreise, Detail-Tabelle). Stack mit
│   │   │   │                                     festen Koordinaten; nimmt Werte+Tokens statt Provider →
│   │   │   │                                     ab Phase 19 auch auf der Teilen-Karte einsetzbar
│   │   │   ├── overview_board_view.dart      ✅ Verdrahtung + Skalierung als Ganzes (FittedBox in
│   │   │   │                                     InteractiveViewer) + Vollbild-Knopf; von Tab UND Vollbild genutzt
│   │   │   ├── overview_tab.dart             ✅ Querformat-Sperre solange der Tab gewählt ist (verzögert, sonst
│   │   │   │                                     schnappt das TabBarView zurück auf Seite 0)
│   │   │   └── overview_fullscreen_page.dart ✅ Dieselbe Bühne ohne AppBar/TabBar/Bottom-Nav und ohne System-
│   │   │                                         Leisten — im Tab blieben von 411 dp nur ~190 dp
│   │   ├── month/month_tab.dart              ✅ Aktueller Kalendermonat (pageId „month")
│   │   └── year/year_tab.dart                ✅ Letzte 52 Wochen (pageId „year", einzige Seite mit Monatsübersicht)
│   ├── habits/presentation/habit_form_sheet.dart ✅ Bottom Sheet für Anlegen **und** Bearbeiten (ein Formular):
│   │                                             Vorlage/eigene Gewohnheit, Kategorie-Dropdown mit „+ Neue
│   │                                             Kategorie", Löschen
│   ├── settings/presentation/
│   │   ├── settings_page.dart                ✅ Darstellungsmodus, Farb-Variante, Animations-Quelle, Sprache;
│   │   │                                         Links zu Konto/Kategorien, App teilen, Sicherung
│   │   │                                         exportieren/importieren, Kontakt uns, Rubrik „Root-in Anleitung"
│   │   │                                         (Einträge kommen aus GuideTopic), „Datenschutzerklärung"
│   │   │                                         (öffnet privacyPolicyUrl, Phase 29.5); 🕯️ Abschnitt „Werbung"
│   │   └── remove_ads_tile.dart              🕯️ Kauf-Kachel + „Käufe wiederherstellen" (Phase 14, stillgelegt)
│   ├── guide/presentation/                   ✅ Rubrik „Root-in Anleitung" — vier Seiten, Inhalt im Repository
│   │   ├── guide_topic.dart                  ✅ Enum der vier Themen mit Titel, Untertitel, Symbol, Route **und**
│   │   │                                         Markdown-Dateiname JE SPRACHE (fileName(languageCode) — die
│   │   │                                         Dateien im Repository heißen uneinheitlich; Umbenennung dort =
│   │   │                                         neue App-Version, Textänderung nicht). EINZIGE Aufzählung
│   │   ├── guide_document.dart               ✅ guideDocumentProvider (Family) + Sprachcode der Inhalts-Adresse +
│   │   │                                         Laufrichtung (RTL bei fa/ar/he/ur). Hängt seit Phase 18 ohne
│   │   │                                         Sonderweg an der App-Sprache — der Persisch-Sonderfall aus
│   │   │                                         Phase 17.2 ist ersatzlos entfallen. `retry: noAutomaticRetry`
│   │   └── guide_page.dart                   ✅ EINE Seite für alle vier Themen: Kopf mit Akzent-Verlauf, darunter
│   │                                             Markdown bzw. Ladekreis, Offline-Hinweis oder „Inhalt folgt"
│   ├── account/presentation/
│   │   ├── account_page.dart                 ✅ **Ganz oben die Rubrik „Konto & Cloud"** (Phase 27.5,
│   │   │                                         aus features/auth/) — nur wenn eine Cloud
│   │   │                                         eingerichtet ist. Darunter unverändert:
│   │   │                                         Achievements, „Fortschritt teilen" (⚠️ bleibt erhalten — die
│   │   │                                         Anleitung „Lernplanung" verweist ausdrücklich auf diesen Weg)
│   │   ├── achievements_grid.dart            ✅ Einziges Achievement-Grid (3 Spalten, gesperrt/freigeschaltet)
│   │   └── share_progress_sheet.dart         ✅ **Einziger** Weg zur Teilen-Vorschau — showShareProgressSheet()
│   │                                             rufen Konto- UND Home-Seite. Baut den Übersicht-Block
│   │                                             (OverviewBoard) und die Karte, hält den Schalter „Übersicht
│   │                                             ein/aus". ⚠️ Der Screenshot-Knoten liegt INNERHALB der
│   │                                             Vorschau-FittedBox und behält so die volle Auflösung
│   ├── categories/presentation/categories_page.dart ✅ Kategorien: anlegen, umbenennen, löschen (Hinweis nennt
│   │                                             die Zahl der blockierenden Gewohnheiten), Symbol je
│   │                                             Standard-Kategorie, Knopf „Standard-Kategorien anlegen"
│   │                                             (Phase 21.1, steht bewusst OHNE Bedingung dort)
│   ├── others/                               ✅ Rubrik „موارد دیگر" (Phase 22) — einseitiger Kanal, Struktur und
│   │   │                                         Texte kommen aus dem GitHub-Repository, ohne App-Update
│   │   ├── domain/others_manifest.dart       ✅ OthersManifest/OthersFolder/OthersEntry mit fromJson. Parst
│   │   │                                         FREMDE, handgepflegte Daten → OthersManifestException mit
│   │   │                                         Grund-Code statt Absturz (Muster wie backup_data.dart).
│   │   │                                         Sortiert nach `order`, bei Gleichstand stabil nach Datei-Reihenfolge
│   │   └── presentation/
│   │       ├── others_providers.dart         ✅ Pfade (others/<sprache>/…), Manifest-Provider, Ordner-Nachschlag,
│   │       │                                     Text-Provider. Sprache = die der Anleitungen.
│   │       │                                     Manifest- und Text-Provider: `retry: noAutomaticRetry`
│   │       ├── others_folders_page.dart      ✅ Ordner als Karten; unterscheidet kein Netz / fehlendes Manifest /
│   │       │                                     kaputtes Manifest sichtbar voneinander
│   │       └── others_folder_page.dart       ✅ Beiträge eines Ordners, klappen an Ort und Stelle auf — der Text
│   │                                             wird ERST beim Aufklappen geladen. Verkraftet einen Ordner,
│   │                                             den es im Repository nicht mehr gibt
│   ├── onboarding/presentation/onboarding_page.dart ✅ Erststart-Erklärung in vier Schritten; erscheint nur,
│   │                                             solange onboardingSeenProvider false ist (Startroute, kein
│   │                                             Redirect); liegt außerhalb der ShellRoute → ohne Bottom-Nav
│   └── auth/presentation/                    ✅ **Phase 27.5** — zwei Dateien:
│       ├── auth_sheet.dart                       EIN Sheet für Anmelden UND Registrieren (Muster wie
│       │                                         showShareProgressSheet). Enthält die Übersetzung der
│       │                                         sprachneutralen Gründe. KEIN „Passwort vergessen" —
│       │                                         das geht erst mit eigenem SMTP (27.2).
│       │                                         Seit 31.1: fragt VOR der Registrierung, ob der Name frei
│       │                                         ist, und hat einen Nur-Name-Modus (`usernameOnly`) — für
│       │                                         ein Konto, dessen Name beim Anlegen vergeben war
│       └── account_cloud_card.dart               Die Rubrik „Konto & Cloud" auf der Konto-Seite.
│                                                 ⚠️ VERSCHWINDET vollständig, wenn supportsCloudSync
│                                                 falsch ist — ehrlich abschalten statt Knöpfe ohne
│                                                 Wirkung. Ohne Benutzernamen: Knopf „Benutzernamen festlegen" (31.1)
│                                                 „Konto löschen" statt „Daten auf dem Server löschen" (31.3)
```

## test/

```
test/
├── widget_test.dart                 ✅ 5 Fälle: Start mit deutschen Nav-Labels, gespeicherte Sprache Englisch
│                                        schlägt durch, Erststart zeigt die Erklärung, „Überspringen" → Home +
│                                        Merker, „Weiter" blättert durch. ACHTUNG: setzt onboarding_seen explizit
├── unit/
│   ├── streak_calculator_test.dart      ✅ 5 Fälle (Serie, Frei-Tag, Bruch, heute offen, längste Serie)
│   ├── repo_content_service_test.dart   ✅ 8 Fälle (laden+ablegen, Offline, Fehler ohne Speicher, 404, genau EINE
│   │                                        Änderungs-Meldung [Endlosschleifen-Regression], getrennte Sprachen;
│   │                                        Phase 22: Übernahme des alten Zwischenspeicher-Schlüssels, und dass
│   │                                        neue Pfade KEINEN alten Schlüssel erben)
│   ├── achievement_evaluator_test.dart  ✅ 4 Fälle (keine ohne Aktivität, drei Meilenstein-Arten, Schwelle >=)
│   ├── habit_tile_data_test.dart        ✅ 2 Fälle (Kachel-Daten, archivierte ausgeschlossen)
│   ├── others_manifest_test.dart        ✅ 10 Fälle (Phase 22): Ordner/Dateien lesen, Sortierung nach `order`
│   │                                        (stabil bei Gleichstand), fehlendes `order`, leerer Ordner, vier
│   │                                        Fehlerformen mit Grund-Code — und „das mitgelieferte Beispiel ist
│   │                                        gültig", damit store/others_index_beispiel.json nie verrottet
│   ├── database_migration_test.dart     ✅ 4 Fälle (Phase 25): Schema 1 und 2 hochziehen, Bestand bleibt MIT
│   │                                        denselben IDs · aktuelles Schema öffnet ohne Migration · eine
│   │                                        Bremse, die bei erhöhter schemaVersion rot wird
│   ├── category_dao_test.dart           ✅ 8 Fälle (anlegen ohne Duplikat, Umbenennen kaskadiert, Löschen
│   │                                        blockiert/gelingt inkl. Anzahl; Phase 21: Erststart legt genau
│   │                                        sieben an, zweiter Start nichts, Sprachwechsel nichts,
│   │                                        Nachrüsten ergänzt nur Fehlendes)
│   ├── dashboard_layout_test.dart       ✅ 4 Fälle (Standard, toggle, reorder, überlebt neuen Container)
│   ├── backup_data_test.dart            ✅ 5 Fälle (verlustfreie Runde, neuere Version/Fremd-JSON/beschädigt
│   │                                        abgelehnt — geprüft wird der Grund-Code, fehlende Listen als leer)
│   ├── backup_restore_test.dart         ✅ 2 Fälle (replaceAll erhält habitId-Verweise, archivierte dabei)
│   ├── remove_ads_test.dart             🕯️ 8 Fälle (Phase 14), stillgelegt — plus EIN aktiver, mit `skip:`
│   │                                        übersprungener Platzhalter: ohne `main()` meldet flutter test
│   │                                        die Datei als Ladefehler
│   ├── app_theme_tokens_test.dart       ✅ 3 Fälle (Tokens je Variante+Helligkeit, heat(), Clamping)
│   ├── no_dart_io_in_lib_test.dart      ✅ 1 Fall (Phase 26.11): kein `dart:io` in lib/, außer in Dateien
│   │                                        auf `_io.dart` (die lädt der Web-Bau nie).
│   │                                        ⚠️ Prüft QUELLTEXT, nicht Verhalten — und das mit Absicht:
│   │                                        Tests laufen auf der Dart-VM, wo `dart:io` funktioniert. Kein
│   │                                        Verhaltenstest hätte den Fehler aus 26.10 finden können
│   ├── privacy_page_test.dart           ✅ 4 Fälle (Phase 29.5), ruft das ECHTE tool/build_privacy_page.py:
│   │                                        tragende Abschnitte stehen auf der Seite · die INTERNE NOTIZ
│   │                                        nicht · vollständige eigenständige Seite · Tabellen und
│   │                                        Auszeichnungen umgewandelt statt durchgereicht
│   └── bundle_secrets_test.dart         ✅ 5 Fälle (Phase 31.5), ruft das ECHTE tool/check_bundle_secrets.py
│                                            mit gefälschten Schlüsseln: anon grün · service_role rot und nicht
│                                            ausgegeben · sb_secret_ rot · blinder Suchlauf rot · ohne
│                                            Erwartung grün
├── widget/
│   ├── matrix_grid_test.dart        ✅ 2 Fälle (eine Zelle je Tag; fitToWidth passt ein Jahr ohne Überlauf)
│   ├── progress_ring_test.dart      ✅ 3 Fälle (Prozent, Clamping, centerLabel)
│   ├── today_page_test.dart         ✅ 6 Fälle: Kopfbereich (Ring-Prozent, Punkte, Erledigt-Zähler, Liste) +
│   │                                     5 Randfälle aus Phase 13 — leerer Bestand (keine Division durch
│   │                                     null im Ring), alles erledigt = 100 %, sehr langer Name ohne
│   │                                     Überlauf, 20 Gewohnheiten bleiben scrollbar, Abhaken schlägt
│   │                                     sofort auf Ring und Zähler durch
│   ├── today_date_test.dart         ✅ 6 Fälle (Phase 24): Start auf heute · Tag zurück zeigt gestern ·
│   │                                     **Abhaken schreibt auf den gewählten Tag, heute bleibt leer** ·
│   │                                     Zukunft gesperrt · „Heute" springt zurück · Widget/Karte bleiben
│   │                                     auf heute. ⚠️ DB-Abfragen im Widget-Test brauchen
│   │                                     `tester.runAsync` — sonst hängt Drifts Stream (siehe Hinweise)
│   ├── week_checklist_test.dart     ✅ 3 Fälle (7 Kreise, Häkchen, Initialen folgen der Sprache)
│   ├── chart_card_test.dart         ✅ 18 Fälle: 5 Grundfälle (Labels, Leer-Zustand, Legende) + Phase 13 —
│   │                                     Y-Achse zeigt nur 0 und den Höchstwert, X-Label bleibt in seiner
│   │                                     Spaltenbreite (echte Geometrie-Prüfung), trendBucketDays je Stufe,
│   │                                     trendSeries inkl. angebrochenem letzten Bündel, Hinweis
│   │                                     „Wochenmittel" erscheint bzw. schweigt, Hinweis steht AUCH AUF
│   │                                     PERSISCH rechts (am Gerät gefunden: TextAlign.end legte ihn auf
│   │                                     die Y-Beschriftung), Höhe bleibt 180.
│   │                                     ⚠️ Datumsarithmetik im Test mit addDays, nie Duration(days:) —
│   │                                     über die Sommerzeit hinweg trifft die Dauer keinen Tagesschlüssel
│   ├── overview_board_test.dart     ✅ 4 Fälle (28 Spalten ab Montag; ein Tag steht überall in derselben Spalte;
│   │                                     Tabellen-Zeile auf Matrix-Höhe; Kreis mittig unter seiner Woche)
│   ├── view_page_test.dart          ✅ 8 Fälle (Tab-Reihenfolge + Index, Board mit den richtigen Tagen,
│   │                                     Vollbild-Knopf, Vollbild ohne TabBar, Leer-Hinweis) + Phase 13:
│   │                                     Navigation durch alle vier Tabs, leerer Bestand bricht keinen
│   │                                     davon, Jahr-Tab zeigt den Trend als Wochenmittel
│   ├── monthly_bar_chart_test.dart  ✅ 3 Fälle (Monatsnamen+Werte, Kürzel folgen der Sprache, Leer-Zustand)
│   ├── others_page_test.dart        ✅ 9 Fälle (Phase 22): Reihenfolge aus dem Manifest, kaputtes Manifest
│   │                                     meldet den Grund (nicht „kein Internet"), 404 = leerer Kanal, ohne
│   │                                     Netz Wiederholen-Knopf, Text lädt ERST beim Aufklappen, unbekannter
│   │                                     Ordner bricht nicht, Eintrag steht UNTER „Wichtige Links".
│   │                                     31.2b: Knopf kommt SOFORT, genau ein Abrufversuch — ohne pumpAndSettle
│   ├── guide_page_test.dart         ✅ 9 Fälle (Rubrik, vier Routen, vier Dateinamen JE SPRACHE + Rückfall auf
│   │                                     Deutsch, Ladekreis → Text, Offline-Hinweis, 404, persisch = RTL)
│   │                                     31.2b: Knopf kommt SOFORT, genau ein Abrufversuch — ohne pumpAndSettle
│   ├── settings_theme_test.dart     ✅ 5 Fälle (Modus, Farbe, Sprache, Animations-Quelle persistiert; Kontakt).
│   │                                     Der Persisch-Fall prüft seit Phase 18 Oberfläche UND Inhalte auf `fa`
│   ├── remove_ads_tile_test.dart    🕯️ 2 Fälle (Phase 14), stillgelegt — mit demselben Platzhalter wie oben
│   ├── account_page_test.dart       ✅ 3 Fälle (Profil/Statistik/Achievements, Name persistiert, Teilen öffnet)
│   ├── categories_page_test.dart    ✅ Kategorie anlegen, umbenennen, löschen
│   ├── habit_form_sheet_test.dart   ✅ 1 Fall (Bearbeiten-Modus zeigt die Werte und kann löschen)
│   ├── share_card_test.dart         ✅ 6 Fälle (heute/Monat/Jahr; Kopfzeile mit Name+Datum, Punkte/Streak/
│   │                                     Achievements; Grid ohne Überlauf; QR + Store-Link; Übersicht-Block
│   │                                     ohne Überlauf bei fester Breite; ohne Block bleibt sie schmal)
│   ├── home_share_test.dart         ✅ 2 Fälle (Home-Knopf öffnet DASSELBE Sheet; leerer Bestand lässt den
│   │                                     Übersicht-Block weg und bricht nicht) — Phase 19
│   ├── persian_ui_test.dart         ✅ 5 Fälle (Oberfläche persisch + Directionality.rtl, Sprachauswahl selbst
│   │                                     persisch, persische Standard-Kategorien, Schlüssel-Stichprobe quer
│   │                                     durch die App, fa als unterstützte Locale) — Phase 18
│   ├── home_progress_animation_test.dart ✅ 4 Fälle (Prozent + Quelle, Gipfel bei 100 %, nächstes Camp, Clamping)
│   ├── dashboard_section_test.dart  ✅ Anpassen-Modus: hinzufügen, entfernen, beides persistiert
│   └── web_storage_hint_test.dart   ✅ 4 Fälle (Phase 26.8). ⚠️ Laufen auf der Dart-VM, also NIE im
│                                        Browser — prüfbar ist deshalb, dass der Hinweis dort NICHT
│                                        erscheint und den Merker NICHT verbraucht. Der ursprüngliche
│                                        Anlass (ein Nutzer startet auf Android und verliert den
│                                        Hinweis im Web) ist mit Phase 28 weg, die Zusage bleibt
└── support/
    ├── test_database.dart           ✅ Isolierte In-Memory-Test-DB — nie die echte App-DB
    ├── test_time_service.dart       ✅ Festes Datum, kein Netzwerkzugriff in Tests
    ├── fake_auth_service.dart       ✅ **Phase 27.5** — Anmeldung ohne Server. ⚠️ KEIN Test spricht mit
    │                                    dem echten Supabase-Projekt: Tests müssen ohne Netz und ohne
    │                                    Schlüssel laufen (derselbe Grund wie bei RepoFetcher)
    ├── fake_purchase_service.dart   🕯️ offlinePurchaseService(prefs) + FakePurchaseService (Phase 14),
    │                                    stillgelegt. Keine *_test.dart-Datei → kein Platzhalter nötig
    ├── localized_app.dart           ✅ localizedApp(...) — **Pflicht-Rahmen** für Widget-Tests; ein blankes
    │                                     MaterialApp lässt jedes Widget werfen, das AppLocalizations liest.
    │                                     Dazu testL10n() für Dienste, die AppLocalizations als Parameter nehmen
    └── dispose_and_flush.dart       ✅ Räumt den Widget-Baum ab und flusht Drifts Nulldauer-Timer
```

## Web-Fassung & Automatik

✅ **Gebaut in PLAN.md Phase 26 — und seit dem 2026-08-17 die HAUPTPLATTFORM** (PLAN.md Abschnitt 2). Nicht mehr „der Zugang zum iPhone, solange es keine Store-Veröffentlichung gibt": Sie **ist** das Ziel, weil sie jeden ohne Store, ohne Installation und ohne Konto bei Google oder Apple erreicht.

⚠️ **Was fehlt, und zwar endgültig:** Erinnerungen und Startbildschirm-Widgets. Sie sind mit Phase 28 **entfernt**, nicht ausgeblendet — ein Browser stellt keinen Wecker, und eine Website kann kein Widget stellen. Für eine Habit-App ist das erste kein Detail; der Nutzer hat den Preis bewusst bezahlt (PLAN.md Abschnitt 2).

```
tool/                                ✅ Skripte — von Hand UND von der Automatik aufgerufen
├── fetch_web_db_assets.sh           ✅ Holt sqlite3.wasm + drift_worker.js aus der drift-
│                                        Veröffentlichung. Liest die Version aus pubspec.lock, damit
│                                        Worker und Bibliothek nicht auseinanderlaufen.
│                                        ⚠️ `dart run drift_dev make-worker` ist mit drift 2.34.2 /
│                                        drift_dev 2.34.0 KAPUTT — nicht erneut versuchen
├── webtest_ci.py                    ✅ **Browser-Durchgang in der Automatik** (PLAN.md 29.3): echter
│                                        Chrome über ChromeDriver, WebDriver-Protokoll über `urllib` —
│                                        keine Abhängigkeit. Läuft in deploy-web.yml gegen den GERADE
│                                        gebauten Stand, VOR der Veröffentlichung, und BLOCKIERT sie.
│                                        23 Punkte (31.2): zeichnet · Erststart · Speicher-Hinweis · Merker ·
│                                        Datenbank · drei Reiter MIT Inhalt · Anleitung offen, Text geladen,
│                                        kein „Erneut versuchen" · Neuladen · Konto-Seite, „Anmelden" ·
│                                        privacy.html (erreichbar, beide Sprachen, ohne interne Notiz).
│                                        WEBTEST_EXPECT_CLOUD=1: fehlende Konto-Rubrik ist ein FEHLER.
│                                        --gegenprobe: sperrt raw.githubusercontent.com und ist nur
│                                        grün, wenn GENAU die Prüfungen aus GEGENPROBE_ROT rot sind
│                                        ⚠️ Meldet seine Diagnose als Arbeitsablauf-Anmerkung
│                                        (`::error::`) — die ist ohne Anmeldung lesbar, das Protokoll nicht
│                                        ⚠️ Der Speicher-Hinweis ist modal und MUSS weggeklickt werden,
│                                        sonst ist kein Reiter erreichbar (erster Lauf: 6/10 rot)
│                                        ⚠️ `chrome --headless --screenshot` taugt NICHT als Ersatz:
│                                        blankes Bild bzw. endloser Lauf (PLAN.md 29.3)
├── webtest_serve.sh                 ✅ Liefert build/web unter /<repository>/ aus und startet
│                                        webtest_ci.py dagegen (31.2) — EINE Stelle für deploy-web.yml
│                                        und webtest-gegenprobe.yml
├── webtest.py                       🕰️ **Nicht mehr ausführbar** — braucht safaridriver, also macOS.
│                                        Bleibt als Vorlage, aus der webtest_ci.py entstanden ist, und
│                                        wegen der Erkenntnisse unten, die für beide gelten.
│                                        Was er prüfte — **20 Punkte**:
│                                        Start, Datenerhalt, alle vier Reiter, eine Anleitungs-Seite
│                                        und die Rubrik „Konto & Cloud". Auch gegen einen lokalen Bau:
│                                        `python3 tool/webtest.py http://localhost:8765/`
│                                        ⚠️ Es war der einzige Durchgang, der die Web-Fassung als
│                                        Ganzes angefasst hat — und genau deshalb wiegt sein Wegfall
│                                        so schwer
│                                        ⚠️ Der Durchgang meldet sich NICHT an — ein Oberflächen-Test,
│                                        der Konten anlegt, hinterlässt bei jedem Lauf Datenmüll. Dass
│                                        die Anmeldung trägt, beweist rls_check.sh. Zwei Werkzeuge,
│                                        zwei Zuständigkeiten
│                                        Am kaputten Stand wird er ROT — daran gemessen, nicht nur am
│                                        reparierten (Lehre 32)
│                                        ⚠️ Scheitert der Start, wird ABGEBROCHEN statt weitergeprüft:
│                                        Ohne laufende App messen die übrigen 19 Prüfungen nichts und
│                                        melden eine Ursache als sechzehn Fehler (Lehre 36). `diagnosis()`
│                                        nennt die Lage in Worten — häufigster Fall: zu früh nach der
│                                        Veröffentlichung gemessen
│                                        ⚠️ `painted()` sucht die Zeichenfläche im SCHATTEN-DOM von
│                                        flt-glass-pane. Im hellen DOM findet man sie nie — auch nicht
│                                        bei einer tadellos laufenden App
│                                        ⚠️ `wait_until()` statt fester Wartezeiten: Ein `sleep` nach dem
│                                        Antippen reicht lokal und gegen die veröffentlichte Seite nicht
│                                        ⚠️ **Der Prüfstand kann müde werden** (Lehre 38): safaridriver
│                                        hört nach vielen Sitzungen auf zu zeichnen und meldet dann
│                                        gegen JEDEN Bau „nichts gezeichnet". Erst die GEGENPROBE gegen
│                                        einen bekannt guten Bau, dann im Code suchen. Hilft nichts:
│                                        Rechner neu starten, oder den iOS-Simulator nehmen
│                                        ⚠️ Einmalig nötig: `safaridriver --enable` (Mac-Passwort)
│                                        ⚠️ Jede Sitzung startet mit LEEREM Profil — Persistenz nur
│                                        innerhalb EINER Sitzung prüfbar
│                                        ⚠️ Gescrollt wird mit einem RAD-Ereignis (ein Wisch bewegt eine
│                                        Flutter-Liste im Desktop-Browser nicht, ohne dass etwas
│                                        fehlschlägt); Zustände an KNÖPFEN ablesen, nicht an Texten —
│                                        reine Texte stehen unzuverlässig im Semantik-Baum
├── rls_check.sh                     ✅ Gegenprobe der Server-Zugriffsregeln von AUSSEN (Phase 27.4):
│                                        13 Prüfungen mit zwei echten Testkonten, seit 31.3 18 mit drei:
│                                        Wegwerf-Konto C löscht sich selbst (delete_own_account). Fehlt
│                                        die Funktion auf dem Server, sagt das Skript genau das.
│                                        Läuft seit 29.2 als Action `rls-check.yml` (von Hand). Braucht
│                                        nur `bash`, `curl` und SUPABASE_URL/SUPABASE_ANON_KEY aus den
│                                        Secrets; `.env` liest es nur, FALLS vorhanden
│                                        ⚠️ Ein `select` im SQL-Editor beweist NICHTS — er läuft mit
│                                        erhöhten Rechten und umgeht die Regeln. Nur ein Aufruf mit
│                                        dem öffentlichen Schlüssel prüft, was ein Fremder sieht.
│                                        ⚠️ Nach JEDER Änderung an supabase/schema.sql erneut laufen
│                                        lassen — eine ungeprüfte Regel ist eine Hoffnung
├── check_bundle_secrets.py          ✅ Kein geheimer Supabase-Schlüssel im Bundle (PLAN.md 31.5). Rot bei
│                                        JWT role=service_role und sb_secret_…; anon/sb_publishable_ ist
│                                        erlaubt. --expect-anon: findet es den erlaubten Schlüssel NICHT,
│                                        ist es blind → rot (Lehre 32). Gibt nie einen Schlüssel aus
├── build_web.sh                     ✅ **Einzige Stelle der Bau-Schalter**: --no-source-maps, -O4, --csp,
│                                        --base-href, Version aus pubspec.yaml, Baunummer aus
│                                        GITHUB_RUN_NUMBER. Die Automatik ruft DIESES Skript auf —
│                                        zwei Flag-Listen liefen sonst auseinander. Ruft am Ende
│                                        build_privacy_page.py auf
└── build_privacy_page.py            ✅ store/PRIVACY_POLICY.md → build/web/privacy.html (PLAN.md 29.5).
                                         Abhängigkeitsfrei (sieben Markdown-Elemente, nachgezählt).
                                         ⚠️ Schneidet die INTERNE NOTIZ ab, statt auf den Browser zu
                                         vertrauen. Ein neues Markdown-Element (Bild, Blockzitat)
                                         erscheint als Rohtext — privacy_page_test.dart hält die Zusage

.github/workflows/deploy-web.yml     ✅ Push auf main → pub get → analyze → test → build_web.sh →
                                         GitHub Pages. Prüfung VOR Veröffentlichung; base-href aus dem
                                         Repository-Namen; concurrency bricht ältere Läufe ab.
                                         ⚠️ Der Testschritt läuft OHNE `--no-test-assets`. Das Flag ist
                                         eine lokale Abkürzung; im CI (frischer Checkout = wie nach
                                         `flutter clean`) lässt es 11 Widget-Tests falsch scheitern.
                                         Genau daran ist Lauf 1 gescheitert — siehe PLAN.md Lehre 29.
                                         ⚠️ KEIN gh-pages-Zweig: Pages nimmt das Artefakt direkt
                                         entgegen, damit landet das Bauergebnis nie in der Geschichte
                                         Seit Phase 27.3 reicht der Bau-Schritt SUPABASE_URL und
                                         SUPABASE_ANON_KEY aus den Repository-Secrets durch.
                                         ⚠️ Fehlen sie, baut die Automatik eine Fassung OHNE Konto —
                                         kein Fehler, die App verhält sich dann wie vor Phase 27
                                         Seit 29.3: Schritt „Browser-Durchgang" (webtest_ci.py) nach dem
                                         Bau, VOR der Veröffentlichung — ⚠️ blockierend, OHNE
                                         continue-on-error (mit dieser Zeile meldete er „success" auch
                                         beim Scheitern). Seit 29.5 liegt privacy.html im selben Artefakt.
                                         Seit 31.2 über tool/webtest_serve.sh, mit WEBTEST_EXPECT_CLOUD.
                                         Seit 31.4 Actions auf Node-24-Fassungen (checkout@v7,
                                         configure-pages@v6, upload-pages-artifact@v5, deploy-pages@v5).
                                         Seit 31.5: Schritt „Kein geheimer Schlüssel im Bundle" nach dem
                                         Bau, blockierend, mit --expect-anon, wenn das Secret gesetzt ist

.github/workflows/rls-check.yml      ✅ Server-Zugriffsregeln prüfen (PLAN.md 29.2) — workflow_dispatch,
                                         NICHT bei jedem Push (legt echte Testkonten an). Auslösen nach
                                         jeder Änderung an supabase/schema.sql. Reicht NUR den
                                         anon-Schlüssel durch — mit service_role bewiese sie nichts

.github/workflows/webtest-gegenprobe.yml ✅ Gegenprobe des Browser-Durchgangs (PLAN.md 31.2) — bei JEDEM
                                         Push, veröffentlicht nichts, keine Secrets. Baut ohne Schlüssel,
                                         löscht privacy.html, `--gegenprobe` sperrt die Anleitungs-Texte.
                                         ⚠️ Fand beim ersten Lauf einen echten App-Fehler: 40 s Ladekreis
                                         statt „Kein Internet" (Riverpod-Wiederholung, PLAN.md 31.2b)

.env.example                         ✅ Vorlage für --dart-define-from-file. Die echte `.env` ist
                                         ausgeschlossen. ⚠️ Definierte Werte landen IM BUNDLE und sind
                                         dort auffindbar — kein Ersatz für einen Server
```

**Code-Anteil der Web-Fassung** (die Dateien selbst stehen oben in ihren Abschnitten):

| Was | Wo | Kern |
|---|---|---|
| Plattform-Weichen | `core/utils/platform_support.dart` | `usesBrowserStorage`, `supportsOrientationLock`, `canReadForeignResponseHeaders`, `supportsCloudSync`. **`kIsWeb` steht NUR hier** |
| Datenbank im Browser | `data/local/database.dart` | `DriftWebOptions` — ohne den Parameter wirft `driftDatabase()` im Web |
| Sicherung einlesen | `core/services/file_pick/` | Bedingter Import: mobil Dateipfad, im Browser `<input type="file">` |
| Netzzugriff | `package:http` in `time_service.dart` + `repo_content_service.dart` | **Kein `dart:io`** — es übersetzt für den Browser und wirft dort (Lehre 30) |
| Werte vom Bau | `core/constants/app_config.dart` | `String.fromEnvironment` + die Warnung, was das **nicht** leistet |

✅ **Die vier gemeldeten Web-Fehler sind behoben und an der veröffentlichten Seite nachgewiesen** (PLAN.md 26.10–26.13). Zwei Ursachen hinter vier Beobachtungen: die Web-Symbole waren die der Flutter-Vorlage, und `dart:io` warf im Browser (Lehre 30) — dadurch blieben „Heute" und „Ansicht" leer und die fünf Anleitungs-Seiten meldeten „kein Internet". Am alten Stand fielen genau die vier zugehörigen Prüfungen durch; am reparierten Bau und an der veröffentlichten Seite sind alle 17 grün.

⬜ **Noch offen:** App-Symbol und die Behebung aus 26.13 auf einem echten iPhone bestätigen (das Ablegen auf dem Home-Bildschirm lässt sich hier nicht nachstellen).

⛔ **Prüfstand iOS-Simulator — mit dem Rechner entfallen.** Er war seit 2026-08-16 der Weg, die Web-Fassung in **echtem iOS-Safari** anzusehen (`xcrun simctl`), und hat zuletzt den Beweis geliefert, dass die veröffentlichte Seite nach Phase 28 läuft. ⚠️ **Was an seine Stelle tritt, ist das echte iPhone des Nutzers** — der einzige verbliebene Blick auf die tatsächliche Oberfläche (PLAN.md Abschnitt 9).

**Wo die Daten der Web-Fassung liegen** (PLAN.md Phase 26.8) — zwei getrennte Orte, beide überstehen Schließen und Neuöffnen:

| Was | Wo im Browser | Beispiele |
|---|---|---|
| Einzelwerte | `localStorage` (über `shared_preferences`) | Profilname, Sprache, Theme + Farbe, Erststart-Merker, Dashboard-Layout, gespeicherte Anleitungs-Texte |
| Die Datenbank | OPFS **oder** IndexedDB (Drift wählt selbst) | Gewohnheiten, Kategorien, alle Erledigungen |

Die **Serie wird nirgends gespeichert** — sie entsteht bei jedem Aufruf neu aus den Erledigungen (`StreakCalculator`). ⚠️ Beide Orte gehören zu **einem Browser auf einem Gerät**: Ein zweites Gerät hat einen eigenen Bestand, und „Website-Daten löschen" räumt beides ab. Deshalb der Hinweis aus 26.8 und die Bitte um dauerhaften Speicher beim Start.

**Was es nicht gibt** (PLAN.md Phase 28): Erinnerungen, Tagesstand-Meldung, Startbildschirm-Widgets, Querformat-Sperre. Bis Phase 26.1 waren sie im Browser nur **ausgeblendet** und die gespeicherte Erinnerungs-Uhrzeit blieb in der Datenbank stehen, damit dieselbe Sicherung auf Android wieder vollständig wäre. Dieses Argument ist mit dem Wegfall von Android hinfällig — die Spalten sind mit Schema 4 entfernt.

## Nutzerkonten & Cloud (Supabase)

✅ **Gebaut in PLAN.md Phase 27** (2026-08-17). Dieser Abschnitt hält die Teile an **einer** Stelle zusammen; im Baum oben stehen sie zusätzlich an ihrem Platz.

```
supabase/schema.sql                  ✅ Tabellen `profiles` (mit `username`) + `backups`, ZWEI
                                         Zugriffsschichten (Rechte + RLS je Vorgang), Trigger für
                                         updated_at, Funktionen `username_available()` und
                                         `delete_own_account()` (31.3: security definer, KEIN Parameter,
                                         löscht nur auth.uid(), nur für authenticated ausführbar).
                                         Mehrfach ausführbar (SQL Editor).
                                         ⚠️ Die Rechte stehen AUSDRÜCKLICH im SQL und gehen nur an
                                         `authenticated`, nie an `anon`. Damit hängt die Datei nicht
                                         am Schalter „Automatically expose new tables" — steht der
                                         auf aus, bekäme die App sonst „permission denied", ohne
                                         dass man es dem SQL ansieht
                                         ⚠️ Bei `backups` ist user_id der PRIMÄRSCHLÜSSEL — eine
                                         Sicherung ist ein Stand, keine Historie
                                         ⚠️ updated_at setzt der SERVER, nicht die App: eine
                                         Geräteuhr kann falsch gestellt sein
                                         ⚠️ Eindeutiger Index auf `lower(username)` — die App
                                         normalisiert mit derselben Regel; weichen die beiden
                                         Seiten ab, hält eine von ihnen die Eindeutigkeit nicht
                                         ⚠️ E-Mail wird hier NICHT wiederholt (liegt in auth.users) —
                                         eine zweite Kopie könnte veralten und auslaufen
lib/core/constants/app_config.dart   ✅ supabaseUrl / supabaseAnonKey / hasSupabaseConfig (27.3)
lib/core/utils/platform_support.dart ✅ supportsCloudSync — die einzige Fähigkeit dort, die NICHT
                                         an der Plattform hängt, sondern an der Konfiguration
test/unit/cloud_config_test.dart     ✅ 4 Fälle: ohne Schlüssel keine Cloud (27.3)
lib/core/services/username_rules.dart ✅ Die EINZIGE Stelle, die festlegt, was ein gültiger
                                         Benutzername ist (27.5). Reines Dart, kein Paket.
                                         ⚠️ Normalisiert IMMER (klein, ohne Leerraum) — sonst wären
                                         „Ali" und „ali" zwei Namen und die Eindeutigkeit eine
                                         Illusion. Sagt NICHTS darüber, ob ein Name frei ist
test/unit/username_rules_test.dart   ✅ 8 Fälle
lib/core/services/auth_service.dart  ✅ Einzige Stelle für supabase_flutter (27.5). Registrieren,
                                         Anmelden (mit E-Mail), Abmelden, Benutzernamen belegen/laden.
                                         `accountUsernameProvider` (31.1): der Name zum Konto — wer
                                         ihn schreibt, invalidiert ihn.
                                         `deleteAccount()` (31.3): deleted · unavailable (Funktion
                                         fehlt, PGRST202) · failed
                                         Gibt IMMER ein AuthResult zurück statt zu werfen — eine
                                         fehlgeschlagene Anmeldung ist ein erwarteter Verlauf.
                                         ⚠️ Fehler werden über den `code` zugeordnet, NIE über die
                                         englische Meldung: Der Text ändert sich ohne Ankündigung,
                                         und eine gebrochene Zuordnung fällt nicht auf — die App
                                         läuft weiter, nur die Auskunft wird nutzlos
                                         ⚠️ Ohne Schlüssel meldet jeder Aufruf notConfigured; es
                                         wird nichts gestartet und nichts gesendet
test/unit/auth_issue_test.dart       ✅ 7 Fälle: Code-Zuordnung, unbekannter Code, Verhalten ohne
                                         Konfiguration
test/unit/profile_cloud_sync_test.dart ✅ 7 Fälle — die GANZE Zusammenstoß-Tabelle aus 27.6.
                                         ⚠️ Vorher stand sie nur als Prosa in der Datei und wurde
                                         von nichts gehalten (PLAN.md Lehre 35)
test/unit/cloud_backup_service_test.dart ✅ 4 Fälle: ohne Konto meldet alles notAvailable, ohne zu
                                         werfen und ohne zu senden
test/unit/app_links_test.dart        ✅ 3 Fälle: geteilt wird die Web-Fassung, nicht der Store
lib/core/services/cloud_backup_service.dart ✅ Bestand als Backup-JSON hoch/runter (27.7): upload,
                                         fetch, restore, lastBackupAt.
                                         ⚠️ fetch und restore sind GETRENNT — die Oberfläche muss
                                         vorher sagen können, was überschrieben wird
                                         ⚠️ lastBackupAt holt NUR den Zeitstempel; sonst lüde jeder
                                         Aufbau der Konto-Seite den ganzen Bestand herunter
lib/core/services/profile_cloud_sync.dart ✅ Anzeigename zwischen Geraet und Server (27.6).
                                         ⚠️ Die Regel fuer den Zusammenstoss steht dort AUSDRUECKLICH
                                         in einer Tabelle: bei Gleichstand gewinnt das GERAET, weil
                                         es die Quelle der Wahrheit ist
lib/core/services/cloud_auto_backup.dart ✅ Sichert von selbst (27.7), ENTPRELLT (20 s) — sonst
                                         schickte eine Morgenrunde mit acht Häkchen achtmal den
                                         ganzen Bestand. Scheitern bleibt stumm und folgenlos
lib/features/auth/presentation/
  auth_sheet.dart                    ✅ EIN Sheet für Anmelden und Registrieren (27.5), Muster wie
                                         showShareProgressSheet. Enthält die Übersetzung der
                                         sprachneutralen Gründe — der Dienst kennt keine Sprache.
                                         Seit 31.1: Vorab-Frage „Name frei?" und Nur-Name-Modus
  account_cloud_card.dart            ✅ Rubrik „Konto & Cloud" auf der BESTEHENDEN Konto-Seite,
                                         nicht daneben. Verschwindet ganz ohne Cloud. Ohne
                                         Benutzernamen: Knopf „Benutzernamen festlegen" (31.1).
                                         „Konto löschen" (31.3): fehlt die Server-Funktion, löscht er
                                         die Daten, MELDET AB und sagt ehrlich, was bleibt
test/support/fake_auth_service.dart  ✅ Anmeldung ohne Server (27.5). `signUp` wie der echte Dienst:
                                         ERST Konto, DANN Name. `takenUsernames` und
                                         `availabilityCheckSeesTaken: false` stellen den Wettlauf nach
test/widget/account_cloud_card_test.dart ✅ 10 Fälle, u. a. „ohne Cloud ist die Rubrik gar nicht da",
                                         „ohne Benutzername lässt er sich nachtragen" und drei zu
                                         „Konto löschen" (Rückfrage/Abbrechen · Funktion fehlt · kein Netz)
test/widget/auth_sheet_test.dart     ✅ 3 Fälle (31.1): vergebener Name legt KEIN Konto an · Name erst
                                         nach dem Anlegen vergeben → nur noch das Namensfeld,
                                         claimUsername schreibt nach · Namensregeln vor jedem Senden
```

**Registrierung: echte E-Mail + Passwort + Benutzername** (Entscheidung des Nutzers, PLAN.md 27.0b — **geändert am 2026-08-16**, vorher war eine künstliche Adresse aus dem Benutzernamen geplant). E-Mail und Passwort verwaltet Supabase, der Benutzername ist der Name *in* der App. Angemeldet wird mit der **E-Mail**; ob später auch mit dem Benutzernamen, ist offen (es bräuchte eine Edge Function — eine öffentliche Zuordnung Name → Adresse würde fremde E-Mails verraten).

⚠️ **Der eingebaute Mail-Versand von Supabase ist für echte Nutzer unbrauchbar:** 2 Nachrichten pro Stunde, nur an vorab freigegebene Adressen des eigenen Teams. Deshalb bleibt „Confirm email" vorerst AUS und **Passwort-Zurücksetzen gibt es erst mit eigenem SMTP** — dann aber rückwirkend für alle, deren Adresse schon gespeichert ist. Ein Knopf, der es vorher anbietet, darf nicht dastehen.

**Die vier Regeln dieser Phase** (Begründungen in PLAN.md 27.0–27.4):

| Regel | Warum |
|---|---|
| **Ohne Schlüssel verhält sich die App wie heute** (`supportsCloudSync`) | Tests, lokale Bauten und der Notfall „Server weg" brauchen keine Sonderbehandlung |
| **Der `anon`-Schlüssel ist kein Geheimnis** — er steht im Bundle und ist auslesbar (Lehre 26) | Der Schutz kommt **ausschließlich** aus den Zugriffsregeln der Datenbank |
| **Der `service_role`-Schlüssel darf nie in App oder Repository** | Er umgeht jede Zugriffsregel — vollständiger Datenbank-Zugriff für jeden, der ihn findet |
| **RLS auf jeder Tabelle, im selben Schritt wie das Anlegen** | Eine Tabelle ohne RLS ist mit dem `anon`-Schlüssel für jeden les- und schreibbar |

⚠️ **Das Format der Cloud-Sicherung ist das vorhandene `backup_data.dart`-JSON** — dieselbe Serialisierung wie Export/Import, dieselben Tests. Ein zweites Format wäre genau die Doppelung, die PLAN.md Abschnitt 9 verbietet.

⚠️ **Sicherung, kein Abgleich.** Hochladen geschieht automatisch, **Herunterladen nur auf Nachfrage** — zwei Geräte ohne Zusammenführungs-Logik löschen sich sonst gegenseitig Daten. „Datenerhalt geht vor" ist die älteste Regel des Projekts.

## Inhalts-Repository (GitHub)

⚠️ **Seit Phase 26.2 ist das DASSELBE Repository wie der Quellcode.** Bis dahin lag unter `lukasylilli/Root-in` ausschließlich der Ordner `content/`. Beim Anlegen des lokalen Git-Repositories fiel auf: Ein Push des Quellcodes hätte diese Dateien überschrieben — und die App lädt sie zur Laufzeit von genau dieser Adresse. Beide Historien wurden deshalb zusammengeführt; `content/` liegt jetzt im Projekt und wird mitversioniert.

**Die Inhalte wirken weiterhin ohne App-Update** — sie werden zur Laufzeit geladen, nicht mitgeliefert. Neu ist nur, dass sie auch lokal im Projekt liegen und über denselben Push aktualisiert werden:

```
github.com/lukasylilli/Root-in  (öffentlich, Branch main)
└── content/
    ├── de|en|fa/                     ✅ Die vier Anleitungs-Texte je Sprache (Phase 17.1).
    │                                    Dateinamen sind uneinheitlich → GuideTopic.fileName()
    │                                    zählt sie ausdrücklich auf; Umbenennen = neue App-Version
    └── others/                       ✅ Phase 22 — die Rubrik „موارد دیگر"
        │                              ⬜ **Der Nutzer legt die Dateien noch an** — bis dahin
        │                              zeigt die Rubrik „Inhalt folgt" (kein Fehler).
        │                              Vorlage + Anleitung: store/others_index_beispiel.json
        │                              und store/OTHERS_CONTENT.md
        └── de|en|fa/
            ├── index.json                Manifest: Ordner, Titel, Reihenfolge, Dateien.
            │                             EINZIGE Quelle der Struktur — GitHub-Rohdateien können
            │                             keine Ordner auflisten, und die GitHub-API ist auf
            │                             60 Abrufe/Stunde je IP begrenzt (PLAN.md Phase 22)
            └── <ordner>/<datei>.md       Die Texte; `file_path` im Manifest zeigt relativ zum
                                          Sprachordner darauf, inklusive Ordnername
```

Abgerufen wird über `raw.githubusercontent.com` (nicht die API), zwischengespeichert in
`shared_preferences` → alles bleibt offline lesbar. Der Abruf braucht `INTERNET` im **Haupt**-
Manifest (siehe Hinweise).

## Datenschutzerklärung

📄 **Wo sie steht und wie man sie ändert** (PLAN.md 29.5). Der Text selbst steht bewusst **nicht** hier — siehe die Warnung unten.

| | |
|---|---|
| **Text (einzige Quelle)** | `store/PRIVACY_POLICY.md` — Deutsch und Englisch in einer Datei |
| **Online** | `https://lukasylilli.github.io/Root-in/privacy.html` |
| **In der App** | Einstellungen → Datenschutzerklärung (öffnet die Adresse oben) |
| **Wer die Seite baut** | `tool/build_privacy_page.py`, aufgerufen von `tool/build_web.sh` bei jedem Bau |
| **Geprüft von** | `test/unit/privacy_page_test.dart` |

**Ändern — alles auf github.com, kein Rechner nötig:**
1. `github.com/lukasylilli/Root-in/blob/main/store/PRIVACY_POLICY.md` öffnen → Stift-Symbol („Edit this file").
2. Text ändern und **das Datum („Stand" / „Last updated") in beiden Sprachen mitziehen** → „Commit changes".
3. Etwa fünf Minuten warten, bis unter *Actions* „Web bauen und veröffentlichen" grün ist — dann steht die neue Fassung online.

⚠️ **Die Seite geht nur zusammen mit einem grünen Bau online.** Fällt ein Test oder der Browser-Durchgang durch, bleibt die alte Fassung stehen. Gewollt: Erklärung und App passen so immer zueinander.

⚠️ **Nicht in PLAN.md oder MAP.md abschreiben.** Der alte Gist war genau so eine zweite Kopie und ist zweimal veraltet. Hier steht nur, **wo** der Text liegt.

⚠️ **Die INTERNE NOTIZ** am Dateiende (HTML-Kommentar `<!-- … -->`) wird beim Bau abgeschnitten und erscheint nicht online — dort ist Platz für Änderungsvermerke.

⬜ **Nutzer:** den alten Gist löschen — `gist.github.com/lukasylilli/673c36972d69819d975ffb82a592cca2`.

## Hinweise
- 🔗 **Root-in wird aus Vox verlinkt — in dieser Richtung und sonst nirgends** (2026-09-15). Vox (`github.com/lukasylilli/vox`, Flutter-Web auf GitHub Pages) öffnet unter *Selbstlernen* eine Karte „Routine", die auf `https://lukasylilli.github.io/Root-in/` zeigt. **In diesem Repository gibt es dafür keine Datei und keinen Code** — Root-in weiß von dem Link nichts. ⚠️ Wer die Adresse von Root-in ändert (Repo umbenennen, eigene Domain), muss `lib/core/constants/app_links.dart` **im Vox-Repo** nachziehen, sonst zeigt die Karte ins Leere. Kein Code-Merge — bewusste Entscheidung, damit Root-in eigenständig nutzbar bleibt (PLAN.md, Kopf).
- 🔒 **Gemeinsames Supabase-Projekt mit Vox (Stand 2026-09-16):** Vox hat eigene Tabellen (`vox_backups`, Datei `supabase/vox_tables.sql` im **Vox**-Repo) und fasst `profiles`/`backups` von Root-in nie an. Vox-Änderungen an seiner Nutzlast (zuletzt S.6, Fassung 3) und an seinen Wortdaten (V.2 Wortindex, L.1a id-Wächter) brauchen hier **keine** Anpassung; `version` in der Hülle zählt je App getrennt.
- 🌐 **Startsprache (PLAN.md 31.6, 2026-09-16):** Ohne eigene Wahl gilt die erste Gerätesprache, die Root-in kann (de/en/fa); sonst **Englisch** — `fallbackLocale` in `lib/core/l10n/app_language.dart`. ⚠️ Das ist nicht die ARB-Vorlage (`app_de.arb`, `l10n.yaml`) — die bestimmt nur, woher fehlende Texte kommen.
- Diese Datei bildet **nur die Struktur** ab (was liegt wo) — Fortschritt und Feature-Details stehen in PLAN.md.
- Bei jeder neuen Datei/jedem neuen Ordner: hier ergänzen. Bei Löschung/Umbenennung: hier korrigieren.
- `*.g.dart` sind generiert (`dart run build_runner build`) und werden hier nicht einzeln aufgeführt. ⚠️ **Sie sind versioniert, und das ist seit Phase 29 lebenswichtig:** Die Automatik ruft `build_runner` **nicht** auf. Wer eine Drift-Tabelle oder `database.dart` ändert, ohne die passende `.g.dart` mitzuliefern, bekommt einen roten Lauf — und kann ihn ohne Rechner nur beheben, indem er die generierte Datei von Hand nachzieht.
- ⚠️ **Es gibt keine Kommandozeile mehr** (PLAN.md Phase 29). `flutter analyze`, `flutter test`, `flutter build web` und `tool/build_web.sh` laufen **nur noch in der Automatik**, bei jedem Push auf `main`. Wer eine Änderung prüfen will, pusht sie und liest den Lauf. ⚠️ Das heißt auch: **`flutter gen-l10n` und `build_runner` laufen niemand mehr von Hand.** `gen-l10n` startet beim Bau von selbst; **`build_runner` NICHT** — wer `database.dart` oder eine Tabelle ändert, muss `database.g.dart` mitliefern, sonst bricht der Bau (siehe unten).
- **Eine Seite wirklich ansehen:** pushen, den Lauf abwarten, `lukasylilli.github.io/Root-in/` im Browser öffnen. ⚠️ **Nicht sofort nach dem Lauf messen** — GitHub Pages liefert nicht überall gleichzeitig aus (Lehre 36). Für einen Blick mit echten Daten gäbe es `lib/main_seed.dart`; der braucht aber einen Bau von Hand und ist damit vorerst unerreichbar.
- Jeder Widget-Test, der DB-gestützte Provider berührt, überschreibt `appDatabaseProvider` und `timeServiceProvider` und ruft `disposeAndFlush(tester)` als letzte Zeile. Die früheren Overrides für `notificationServiceProvider` (Phase 28) und `purchaseServiceProvider` (Phase 20) sind entfallen.
- Tests, die die Home-Seite rendern, dürfen **kein** `pumpAndSettle()` verwenden — die funkelnden Sterne laufen dauerhaft. Stattdessen `tester.pump(const Duration(seconds: 1))`; für einen **Wechsel** auf Home braucht es drei aufeinanderfolgende `pump()` (Tipp → Speichern → Routen-Übergang, siehe `settleNavigation`).
- ⚠️ **Fehlerzustände nie nur mit `pumpAndSettle` prüfen** (PLAN.md Lehre 40). Riverpod 3 wiederholt fehlgeschlagene Provider von selbst; `pumpAndSettle` spult die Pausen vor und findet am Ende den Knopf, den ein Nutzer erst nach 40 Sekunden sähe. Abgeschaltet ist das in `lib/core/utils/no_retry.dart` — **ein neuer Provider mit eigenem Fehlerzustand bekommt `retry: noAutomaticRetry`**, sonst sieht sein Test etwas anderes als die App.
- Tests, die die ganze App starten, müssen `onboarding_seen` in den gemockten Prefs setzen — sonst landen sie auf der Erststart-Erklärung.
- Widgets am unteren Ende einer `ListView`/`GridView` sind im Test-Viewport noch nicht gemountet — erst `tester.scrollUntilVisible(...)`. Bei mehreren verschachtelten Scrollables `find.byType(Scrollable).first` nehmen.
- **Datenbank-Abfragen mitten im Widget-Test** brauchen `await tester.runAsync(() async { … })`. Drift liefert Stream-Ergebnisse über einen Timer, und im Widget-Test steht die Uhr still — ein blankes `await stream.first` hängt bis zum Timeout (dieselbe Ursache wie bei `disposeAndFlush`). Wo kein Widget-Baum nötig ist, ist ein reines `test(...)` mit `ProviderContainer` der einfachere Weg.
- Ein **Render-Test** beweist Geometrie und Ausrichtung, aber **nicht** den verfügbaren Platz auf einem echten Gerät und nichts, was an einem Konfigurationswechsel hängt (Drehung, Theme). Wer ein Bild erzeugt: `FontLoader` und `boundary.toImage()` **müssen** in `tester.runAsync(...)` laufen, sonst hängt der Test bis zum Timeout.
- **Kein `dart:io` in `lib/`** — es übersetzt für den Browser und wirft dort erst zur Laufzeit (PLAN.md Lehre 30). Netzzugriffe über `package:http`; was wirklich Plattform braucht, kommt hinter einen bedingten Import (`*_io.dart` / `*_web.dart`, Vorbild `core/services/file_pick/`). `test/unit/no_dart_io_in_lib_test.dart` hält die Regel.
- **Provider abwarten:** `container.read(streamProvider.future)` **ohne** gleichzeitigen Zuhörer hängt für immer (Riverpod verwirft den Provider und bricht die Drift-Subscription ab). Außerhalb des Widget-Baums selbst eine `container.listen`-Subscription halten. ⚠️ Das Vorbild `_awaitAlive` lag in `home_widget_service.dart` und ist mit Phase 28 entfallen — die Falle nicht.
- **Neue UI-Texte** gehören in **alle drei** ARB-Dateien — `app_de.arb` (Vorlage), `app_en.arb`, `app_fa.arb` —, nie als Literal in den Code. Nach dem Ändern `flutter gen-l10n` laufen lassen (oder einfach bauen). ⚠️ **`flutter analyze` löst gen-l10n NICHT aus**: Wer nur analysiert, sieht neue Schlüssel als „undefined getter", obwohl die ARB stimmt. Fehlt ein Schlüssel in einer Nicht-Vorlage-Sprache, fällt er **still** auf Deutsch zurück — die App liefe, sähe aber gemischt aus; `persian_ui_test.dart` prüft das stichprobenartig. Texte außerhalb des Widget-Baums (Standard-Kategorien beim Erststart) bekommen die Sprache übergeben.
- **Prozentwerte** kommen aus `core/l10n/app_numbers.dart`, nicht aus `'${x * 100}%'` im Widget. Dort steht auch die Entscheidung, in allen Sprachen westliche Ziffern zu verwenden. Einzige bewusste Ausnahme: das Übersicht-Board, dessen Spaltenbreiten auf seine eigene Schreibweise (mit Leerzeichen) ausgelegt sind.
- **Werbung wieder einschalten** (Phase 20 rückgängig): `grep -rn "PHASE 20 (2026-08-01)"` über `lib/`, `test/` und `pubspec.yaml` findet jede Stelle. ⚠️ Beide Pakete gibt es nur für Android/iOS — ohne diese Plattformen (Phase 28) ist das kein `grep` mehr, sondern eine neue Phase.
- ⚠️ **Nach dem Entfernen eines Plugins einmal `flutter clean`.** Der generierte `web_plugin_registrant.dart` bleibt sonst stehen und der Web-Bau bricht mit „Couldn't resolve package" ab. Im CI fällt das nie auf (frischer Checkout) — nur lokal.

# Root-in — Projekt-Map (Ordner- & Datei-Übersicht)

> Lebendiges Dokument. Wird bei jeder Struktur-Änderung (neue/verschobene/gelöschte Dateien) aktualisiert.
> ✅ **2026-08-14: Die vier Web-Fehler sind behoben, veröffentlicht und an der veröffentlichten Seite nachgeprüft** (17/17 Browser-Prüfungen grün, Commit `bec572a`). Offen bleibt nur das App-Symbol auf einem echten iPhone. Siehe PLAN.md 26.11.
> Zuletzt aktualisiert: 2026-08-14 (nachmittags) — **Phase 26.11: die vier gemeldeten Web-Fehler behoben.** `dart:io` ist aus `lib/` verschwunden (`time_service.dart` und `repo_content_service.dart` nehmen jetzt `package:http` — die Attrappe von `dart:io` warf im Browser und legte drei der vier Hauptseiten lahm, PLAN.md 26.10). Neu: `test/unit/no_dart_io_in_lib_test.dart` (Wächter über die Regel), Fähigkeit `canReadForeignResponseHeaders` in `platform_support.dart`, direkte Abhängigkeiten `http` + `http_parser`, Web-Symbole aus `assets/icon/app_icon.png` erzeugt (`flutter_launcher_icons` mit `web:`).
> Zuvor 2026-08-14 — **Phase 26 gebaut: Web-Fassung (PWA) und Veröffentlichung über GitHub**, einschließlich 26.8 und 26.9. Neu im Root-Baum: `content/` (aus dem früheren Inhalts-Repository), `.claude/settings.json`. Neu: `tool/` (zwei Skripte), `.github/workflows/deploy-web.yml`, `.env.example`, `core/constants/app_config.dart`, `core/services/file_pick/` (drei Dateien), `core/services/web_storage/` (drei Dateien), `core/widgets/web_storage_hint.dart`, `test/widget/web_storage_hint_test.dart`, `web/` überarbeitet. Entfallen als direkte Abhängigkeit: `path_provider`. Das Projekt ist ein Git-Repository — Quellcode und Inhalts-Repository sind darin zusammengeführt. Einzelheiten im Abschnitt „Web-Fassung & Automatik".
> Zuvor 2026-08-07 — **Phase 13 gebaut** (Diagramm-Feinschliff & Tests): keine neuen Dateien, geändert sind `core/widgets/chart_card.dart`, die drei ARB-Dateien und drei Test-Dateien.
> Zuvor 2026-08-02 — Phasen 25, 24, 23 und 22 gebaut; der Abschnitt „Geplante Dateien" ist entfallen.

## Inhaltsverzeichnis
1. [Legende](#legende)
2. [Root-Verzeichnis](#root-verzeichnis)
3. [lib/ (App-Code)](#lib-app-code)
4. [test/](#test)
5. [Release-Artefakte (Android)](#release-artefakte-android)
6. [Web-Fassung & Automatik](#web-fassung--automatik) 🚧 *(Phase 26)*
7. [Inhalts-Repository (GitHub)](#inhalts-repository-github)
8. [Hinweise](#hinweise)

## Legende
- ✅ vorhanden
- 🚧 geplant, noch nicht angelegt
- ⚙️ generiert (nie von Hand ändern)
- 🕯️ **stillgelegt in Phase 20** — vollständig auskommentiert, nicht gelöscht. Jede Stelle trägt den Marker
  `PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.`
  Das Wiedereinschalten ist damit ein `grep`, keine Suche.

## Root-Verzeichnis
```
/Users/lukasaliramezani/Projects/Root-in/
├── PLAN.md                          ✅ Gesamtplan/Roadmap der App
├── MAP.md                           ✅ Diese Datei — Struktur-Übersicht
├── README.md                        ✅ Standard-Flutter-README
├── pubspec.yaml                     ✅ Paket-Definition & Dependencies (am Dateiende: flutter_launcher_icons —
│                                        seit Phase 26.11 mit `web:`, erzeugt also auch die Web-Symbole)
├── pubspec.lock                     ✅ Gesperrte Dependency-Versionen
├── analysis_options.yaml            ✅ Lint-Regeln
├── .metadata                        ⚙️ Von Flutter gepflegt (Projekt-Herkunft, migrierte Plattformen) —
│                                        nie von Hand ändern
├── Root-in.code-workspace           ✅ VS-Code-Arbeitsbereich
├── l10n.yaml                        ✅ gen-l10n: ARB in lib/l10n, Ausgabe lib/l10n/gen, Vorlage Deutsch
├── assets/icon/app_icon.png         ✅ EINZIGE Quelle des App-Symbols (1024×1024). Alle Android-Auflösungen +
│                                        Adaptive Icon entstehen daraus per `dart run flutter_launcher_icons`.
│                                        Nicht in der `assets:`-Liste — wird nur beim Generieren gelesen
├── lib/                             ✅ App-Quellcode (siehe unten)
├── test/                            ✅ Tests (siehe unten)
├── store/                           ✅ Material für die Veröffentlichung (PLAN.md Phase 15) — kein Code
│   ├── PRIVACY_POLICY.md                Datenschutzerklärung DE+EN, aus dem tatsächlichen Verhalten der App
│   │                                    abgeleitet. **Quelle** der veröffentlichten Gist-Fassung — Änderungen
│   │                                    müssen dort von Hand nachgezogen werden. Stand Phase 20: ohne AdMob/
│   │                                    Billing, dafür **neu** mit dem GitHub-Abruf der Anleitungs-Texte.
│   │                                    ⚠️ Der Gist ist noch NICHT nachgezogen (PLAN.md Phase 15)
│   ├── OTHERS_CONTENT.md                Pflege-Anleitung für die Rubrik „موارد دیگر" (Phase 22): wo die
│   │                                    Dateien liegen, Felder des Manifests, was der Nutzer sieht, wenn
│   │                                    etwas fehlt, häufige Fehler
│   ├── others_index_beispiel.json       Gültige Vorlage zum Hochladen — ein Test prüft sie mit, damit die
│   │                                    Anleitung nicht in die Irre führt
│   ├── PLAY_LISTING.md                  Store-Texte DE+EN+**FA** (persisch optional, PLAN.md Phase 18.7),
│   │                                    Längen gegen Googles Limits geprüft, Pflichtangaben-Checkliste
│   │                                    (seit Phase 20: Werbung Nein, keine Daten, keine Käufe)
│   ├── feature_graphic_1024x500.png     Store-Banner: weißes Strich-Logo auf Markengrün, ohne Text
│   ├── make_feature_graphic.py          Erzeugt ebendiese Datei aus meine/Logo.jpeg (liest/schreibt PNG selbst,
│   │                                    da weder ImageMagick noch PIL auf dieser Maschine; Helligkeit = Deckkraft)
│   ├── play_store_icon_512.png          Store-Symbol 512×512, echtes 32-Bit-PNG
│   └── screenshots/de|en/               Je 4 Telefon-Screenshots (Home, Heute, Monat, Konto), 1080×2160 —
│                                        Emulator liefert 2,24:1, Play erlaubt höchstens 2:1
├── meine/                           ✅ Referenzmaterial des Nutzers: 20 Screenshots, „Berg-Animation"
│                                        (React/SVG-Vorlage, Phase 8.6), zwei Design-Specs (Phase 10.6),
│                                        Logo.jpeg (Quelle des App-Symbols)
├── android/                         ✅ Android-Plattformcode; zusätzlich zum Standard-Gerüst:
│   └── app/src/main/
│       ├── kotlin/com/rootin/app/        Paketverzeichnis — MUSS zur applicationId passen, weil home_widget
│       │                                 seine Widget-Klassen über context.packageName auflöst (Phase 15.1)
│       │   ├── RootInWidgetProvider.kt       Fortschritts-Widget: Prozent + „x/y erledigt" (Phase 10)
│       │   ├── ChartWidgetProvider.kt        Basis der Bild-Widgets: zeigt das gerenderte PNG (Phase 10.7)
│       │   ├── ChartWidgetProviders.kt       5 Diagramm-Widgets + Ring + Checklist (nur je ein dataKey)
│       │   ├── ColorTileWidgetProvider.kt    Farbkachel je Gewohnheit mit antippbarem Log-Button — einziges
│       │   │                                 Widget mit echten RemoteViews statt PNG (Phase 10.6d)
│       │   └── ColorTileConfigActivity.kt    Auswahl beim Platzieren: welche Gewohnheit? Liest den Katalog aus
│       │                                     den Widget-Preferences → weder Flutter-Engine noch DB nötig
│       ├── AndroidManifest.xml           INTERNET (Phase 17.1 — stand vorher NUR im Debug-/Profile-Manifest),
│       │                                 Notification-Receiver (Phase 7), https-queries für url_launcher
│       │                                 (Phase 6), 9 Widget-Receiver + HomeWidgetBackgroundReceiver,
│       │                                 🕯️ AdMob-meta-data + AD_ID-/BILLING-Berechtigung (Phase 14).
│       │                                 ⚠️ Der Manifest-Merger übernimmt Kommentare wortgetreu — ein
│       │                                 `grep AD_ID` im Merge-Ergebnis findet auch den STILLGELEGTEN Block.
│       │                                 XML-bewusst prüfen oder im AAB (dort ist es Protobuf, ohne Kommentare)
│       ├── res/mipmap-*/, res/drawable-*/, res/values/colors.xml  ⚙️ Generiert (flutter_launcher_icons)
│       └── res/{layout,drawable,xml,values}/  Layouts (Fortschritt, Diagramm, Farbkachel + Konfiguration),
│                                          9 Provider-Infos, Drawables, Texte; values/strings.xml hält
│                                          zusätzlich 🕯️ `admob_app_id`
├── ios/                             ✅ iOS-Plattformcode (Standard-Gerüst; Bundle-ID noch com.example.rootIn)
├── web/                             ✅ Web-Fassung (PLAN.md Phase 26) — seit 2026-08-07 IM UMFANG, nicht mehr
│   │                                    ungenutztes Gerüst. Sie ist der Ersatzweg auf das iPhone
│   ├── index.html                   ✅ Einstiegsseite, Markenfarbe schon vor dem ersten Frame + iOS-Meta-Tags.
│   │                                    ⚠️ Safari liest fürs Ablegen apple-mobile-web-app-*, NICHT
│   │                                    manifest.json — ohne sie öffnet die Verknüpfung eine Browser-Seite
│   │                                    mit Adressleiste statt einer App
│   ├── manifest.json                ✅ PWA-Manifest (Root-in, Markengrün #2E7D5B, Symbole)
│   ├── sqlite3.wasm                 ⚙️ NICHT versioniert — tool/fetch_web_db_assets.sh holt sie. Ohne diese
│   │                                    Datei wirft driftDatabase() im Browser, die App startet gar nicht
│   ├── drift_worker.js              ⚙️ NICHT versioniert — dieselbe Quelle, Version aus pubspec.lock
│   ├── favicon.png, icons/          ⚙️ Aus assets/icon/app_icon.png erzeugt (Phase 26.11) — dieselbe eine
│   │                                    Quelle wie die Android-Symbole, `dart run flutter_launcher_icons`.
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
├── .github/workflows/deploy-web.yml ✅ Push auf main → analyze + test → build_web.sh → GitHub Pages
├── .env.example                     ✅ Vorlage für --dart-define-from-file (die echte .env ist ausgeschlossen)
├── .claude/
│   ├── settings.json                ✅ Freigabeliste für Claude Code (Phase 26.9): weniger Rückfragen bei
│   │                                    flutter-/git-/adb-Befehlen, `defaultMode: acceptEdits`.
│   │                                    ⚠️ Bewusst OHNE Muster wie `for *`/`awk *` — die sähen eng aus,
│   │                                    erlauben aber jeden beliebigen Befehl. Wer gar keine Rückfrage
│   │                                    will, nimmt den Modus-Umschalter, nicht eine getarnte Liste
│   └── settings.local.json          ⛔ NICHT versioniert — maschinenlokal, enthält hunderte absolute
│                                        Pfade unter /Users/<name>/
├── .git/                            ✅ Seit 2026-08-07 ein Git-Repository (Zweig `main`; Quellcode und
│                                        Inhalts-Repository zusammengeführt). ⚠️ NICHT im Repository:
│                                        meine/, .claude/settings.local.json, key.properties, *.jks,
│                                        build/, .env, web/sqlite3.wasm, web/drift_worker.js
└── macos/, linux/, windows/         ✅ Desktop-Gerüst (ungenutzt, nicht im Fokus)
```

## lib/ (App-Code)

**Funktionsstand:** Home mit Berg-Animation, individualisierbarem Dashboard und Teilen-Knopf · Heute-Seite mit Tagesring, Abhaken, Bearbeiten/Löschen · View mit vier Tabs (Woche/Übersicht/Monat/Jahr, Übersicht zusätzlich im Vollbild) · Konto mit Profil, Achievements, lebenslanger Statistik und Fortschritt-Teilen · Kategorien: sieben Standard-Kategorien beim Erststart, danach frei verwaltbar · tägliche Erinnerungen je Gewohnheit inkl. Snooze · Sicherung exportieren/importieren · Rubrik „Root-in Anleitung" mit vier Seiten aus dem Repository · neun Home-Screen-Widgets inkl. antippbarer Farbkachel · Darstellungsmodus, Farb-Variante und Sprache (**DE/EN/FA, Persisch inkl. RTL**) über je **einen** Schalter · Erststart-Erklärung · Fortschritts-Karte mit Übersicht-Block und QR-Code zum Store · **keine Werbung, keine In-App-Käufe** (🕯️ in Phase 20 stillgelegt).

```
lib/
├── main.dart                                 ✅ Einstiegspunkt: SharedPreferences, Notification-Init mit der
│                                                 gespeicherten Sprache, Startkategorie in ebendieser Sprache,
│                                                 dann UncontrolledProviderScope (expliziter ProviderContainer,
│                                                 weil der Kategorie-Seed vor dem ersten Frame laufen muss).
│                                                 🕯️ Enthält den Start des Werbe-SDKs (Phase 14)
├── main_seed.dart                            ✅ Zweiter Einstiegspunkt, NUR für Store-Screenshots und um eine
│                                                 Seite mit echtem Bestand anzusehen: sät ~400 Tage (je
│                                                 Gewohnheit nur an ihren Wochentagen, daraus folgt timesPerWeek),
│                                                 setzt Sprache (de, oder en via --dart-define=SEED_LANG=en),
│                                                 onboarding_seen und remove_ads_purchased (kein Werbe-SDK),
│                                                 ruft danach main.dart. Säht in einem eigenen Container, der vor
│                                                 dem App-Start geschlossen wird. Nie in einen Release-Build
├── app.dart                                  ✅ MaterialApp.router; ThemeMode/Farb-Variante/Sprache aus Providern.
│                                                 Zwei Listener an genau einer Stelle: Fortschritt →
│                                                 Home-Screen-Widget **und** Tagesstand-Meldung (Phase 23 — ein
│                                                 Sender, zwei Empfänger; dazu ein dritter Listener auf den
│                                                 Tagesstand-Schalter), Sprachwechsel → Erinnerungen neu planen +
│                                                 iOS-Kategorie + Widgets. Dazu ein AppLifecycleListener, der beim
│                                                 Zurückkehren die Drift-Streams neu lesen lässt (sonst bliebe ein
│                                                 Abhaken über die Widget-Kachel unsichtbar)
├── l10n/
│   ├── app_de.arb                            ✅ Vorlage-Sprache, 259 Schlüssel. Neue Strings **hier zuerst**
│   ├── app_en.arb                            ✅ Englische Fassung derselben Schlüssel
│   ├── app_fa.arb                            ✅ Persisch (Phase 18) — alle 259 Schlüssel, Reihenfolge wie
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
│   │   │                                         /reminders, /onboarding, /view/overview-fullscreen,
│   │   │                                         /guide-Präfix — die vier Themen-Pfade baut GuideTopic)
│   │   └── app_router.dart                   ✅ go_router: ShellRoute (4 Hauptseiten) + Detailseiten außerhalb
│   │                                             der Shell. Bewusst eine Funktion createAppRouter(showOnboarding:)
│   │                                             statt einer Konstante — EINMALIG in app.dart bauen
│   ├── l10n/
│   │   ├── app_language.dart                 ✅ Wählbare Sprachen (System/فارسی/Deutsch/Englisch). Seit Phase 18
│   │   │                                         ist Persisch vollwertig: `locale` liefert `fa` für Oberfläche
│   │   │                                         UND Inhalte, der Zwischenstands-Begriff `contentLanguageCode`
│   │   │                                         ist ersatzlos entfallen. Dazu resolveLocale() für Texte ohne
│   │   │                                         BuildContext (Notifications)
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
│   │   ├── app_links.dart                    ✅ Einzige Quelle des Play-Store-Links (Phase 19), abgeleitet aus
│   │   │                                         `appPackageName`. Drei Leser: QR-Code auf der Karte,
│   │   │                                         Share-Begleittext, „App teilen" in den Einstellungen
│   │   ├── ad_config.dart                    🕯️ Ad-Unit-IDs + Test-Geräte + Not-Schalter adsDisabledForEveryone
│   │   └── app_assets.dart                   ✅ Asset-Pfade; AppAssets.homeAnimation = Lottie-Slot (null →
│   │                                             eingebaute gemalte Animation)
│   ├── utils/
│   │   ├── date_utils.dart                   ✅ dateOnly, addDays (DST-sicher), weekStartOf
│   │   ├── streak_calculator.dart            ✅ Reine Streak-Logik inkl. 1-Frei-Tag/Woche (unit-getestet)
│   │   ├── achievement_evaluator.dart        ✅ Reine Freischalt-Logik (unit-getestet)
│   │   └── platform_support.dart             ✅ **Die einzige Stelle im Projekt, an der `kIsWeb` steht.**
│   │                                             isMobilePlatform + seit Phase 26 fünf nach FÄHIGKEIT
│   │                                             benannte Abfragen: supportsReminders,
│   │                                             supportsHomeScreenWidgets, supportsOrientationLock,
│   │                                             usesBrowserStorage (Phase 26.8),
│   │                                             canReadForeignResponseHeaders (Phase 26.11 — im Browser
│   │                                             gibt eine fremde Adresse ihre Kopfzeilen nur soweit frei,
│   │                                             wie CORS es erlaubt, und `Date` gehört nicht dazu).
│   │                                             ⚠️ usesBrowserStorage NICHT durch
│   │                                             supportsHomeScreenWidgets ersetzen: Im Browser liefern
│   │                                             beide dasselbe, sie MEINEN aber Verschiedenes — auf einem
│   │                                             Desktop-Bau erschiene sonst der Safari-Hinweis
│   │                                             Bewusst nicht nach Plattform benannt — der Aufrufer will
│   │                                             wissen „gibt es hier Erinnerungen?", nicht „wo laufe ich?".
│   │                                             🕯️ isStorePlatform ist mit Phase 20 auskommentiert
│   ├── services/
│   │   ├── time_service.dart                 ✅ Aktuelles Datum (HTTP-Date-Header + Offline-Fallback).
│   │   │                                         Seit Phase 26.11 über `package:http` statt `dart:io` —
│   │   │                                         letzteres warf im Browser schon beim `HttpClient()` und
│   │   │                                         riss damit todayProvider und die Heute-/Ansicht-Seite
│   │   │                                         mit sich (PLAN.md 26.10, Lehre 30).
│   │   │                                         ⚠️ Im Browser wird die EIGENE Adresse gefragt (Uri.base
│   │   │                                         + Zeitstempel gegen den Zwischenspeicher), weil fremde
│   │   │                                         Kopfzeilen dort nicht lesbar sind
│   │   ├── settings_service.dart             ✅ Persistiert ThemeMode, AppThemeVariant, AppLanguage, AscentSource,
│   │   │                                         onboarding_seen, share_include_overview (Phase 19) und
│   │   │                                         status_notification_enabled (Phase 23);
│   │   │                                         dazu appLocaleProvider (MaterialApp.locale) und
│   │   │                                         resolvedLocaleProvider (Texte ohne BuildContext)
│   │   ├── profile_service.dart              ✅ Persistiert UserProfile (Name)
│   │   ├── share_service.dart                ✅ Einzige Stelle für share_plus: shareApp (Text) und
│   │   │                                         shareProgressImage (Bytes → Share-Sheet). Beide Texte tragen
│   │   │                                         seit Phase 19 den Store-Link aus app_links.dart.
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
│   │   │   ├── pick_text_file_io.dart            Android/iOS: flutter_file_dialog + dart:io
│   │   │   └── pick_text_file_web.dart           Browser: <input type="file"> + FileReader.
│   │   │                                         ⚠️ `oncancel` ist Pflicht: Bricht der Nutzer ab, feuert
│   │   │                                         `onchange` NIE — das Future bliebe für immer offen
│   │   ├── web_storage/                      ✅ Bittet den Browser, den Speicher DAUERHAFT zu behalten
│   │   │   │                                     (Phase 26.8). Dieselbe Bauart wie file_pick/.
│   │   │   │                                     ⚠️ Eine Bitte, keine Garantie — der Browser entscheidet
│   │   │   ├── request_persistent_storage.dart      Weiche (bedingter Export)
│   │   │   ├── …_io.dart                            Android/iOS: sofort `false`, es gibt nichts zu erbitten
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
│   │   ├── home_widget_service.dart          ✅ Einzige Stelle für home_widget: Fortschritt schreiben, 7 PNGs
│   │   │                                         rendern (5 Diagramme + Ring + Checkliste) und die Farbkachel-
│   │   │                                         Werte setzen. Schlüssel müssen zu den Kotlin-Klassen passen.
│   │   │                                         Setzt Localizations von Hand (offscreen gibt es keine
│   │   │                                         MaterialApp). Enthält colorTileInteractionCallback (eigenes
│   │   │                                         Isolate) und _awaitAlive (siehe Hinweise)
│   │   ├── dashboard_layout_service.dart     ✅ Persistiert je Seite (pageId) die aktive Widget-Liste;
│   │   │                                         dashboardLayoutProvider (Family), toggle/reorder
│   │   ├── ads_service.dart                  🕯️ Einzige Stelle für google_mobile_ads (idempotenter Start,
│   │   │                                         adaptives Banner; Fehler werden geschluckt und geloggt)
│   │   ├── purchase_service.dart             🕯️ Einzige Stelle für in_app_purchase/Play Billing + adsRemovedProvider
│   │   └── notification_service.dart         ✅ Einzige Stelle für flutter_local_notifications: initialize (inkl.
│   │                                             Zeitzone), requestPermission, scheduleForHabit (täglich, seit
│   │                                             Phase 23 mit dem Serien-Stand im Text), cancelForHabit;
│   │                                             Snooze über Top-Level-Handler (Background-Isolate) — die
│   │                                             Sprache reist im Payload mit.
│   │                                             **Phase 23:** showDailyStatus/cancelDailyStatus (dauerhafte
│   │                                             Meldung, eigener Kanal, leise) + DailyStatusMessage — ein
│   │                                             reines Wertobjekt, das entscheidet OB gemahnt wird und WAS
│   │                                             dort steht (null = abräumen). Herausgezogen, weil der Plugin-
│   │                                             Konstruktor privat und der Kanal im Test nicht auflösbar ist
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
│       │                                         ⚠️ _chartHeight = 180 ist FEST — das Home-Screen-Widget rendert
│       │                                         dieselben Diagramme in 320×200 (home_widget_service.dart); ein
│       │                                         mitwachsendes Diagramm wäre dort abgeschnitten.
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
│           ├── dashboard_widget_type.dart        Katalog-Enum (5 Typen) + Label + androidWidgetProvider
│           ├── dashboard_widget_builder.dart     Einzige Typ+Zeitraum → Widget-Zuordnung
│           └── dashboard_section.dart            Anpassen-Modus: ReorderableListView, Hinzufügen/Entfernen-Chips
├── data/
│   ├── local/
│   │   ├── database.dart                     ✅ AppDatabase (Drift) + appDatabaseProvider; forTesting(executor);
│   │   │                                         schemaVersion 3, onCreate (nur Tabellen — Kategorien legt der
│   │   │                                         App-Start sprachabhängig an), onUpgrade 1→2 / 2→3
│   │   ├── database.g.dart                   ⚙️ build_runner
│   │   ├── tables/{habits,habit_completions,categories}_table.dart ✅ Habits (inkl. Reminder-Spalten),
│   │   │                                         HabitCompletions (unique habitId+date), Categories (name unique)
│   │   └── daos/
│   │       ├── habit_dao.dart                ✅ CRUD/Watch inkl. updateHabit (Teil-Update via `.write()`,
│   │       │                                     bewusst kein `.replace()`), deleteHabit (transaktional),
│   │       │                                     setReminder, habitsWithReminder
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
│                                                 setHabitReminder (DB + Notification an einer Stelle),
│                                                 ensureDefaultCategory, rescheduleAllReminders, habitTileData
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
│   │                                             Kategorie", Erinnerungs-Schalter + Time-Picker, Löschen
│   ├── settings/presentation/
│   │   ├── settings_page.dart                ✅ Darstellungsmodus, Farb-Variante, Animations-Quelle, Sprache;
│   │   │                                         Links zu Konto/Kategorien/Erinnerungen, App teilen, Sicherung
│   │   │                                         exportieren/importieren, Kontakt uns, Rubrik „Root-in Anleitung"
│   │   │                                         (Einträge kommen aus GuideTopic); 🕯️ Abschnitt „Werbung"
│   │   ├── remove_ads_tile.dart              🕯️ Kauf-Kachel + „Käufe wiederherstellen" (Phase 14, stillgelegt)
│   │   └── reminders_page.dart               ✅ Alle Gewohnheiten mit Uhrzeit, direkt änderbar/abschaltbar
│   ├── guide/presentation/                   ✅ Rubrik „Root-in Anleitung" — vier Seiten, Inhalt im Repository
│   │   ├── guide_topic.dart                  ✅ Enum der vier Themen mit Titel, Untertitel, Symbol, Route **und**
│   │   │                                         Markdown-Dateiname JE SPRACHE (fileName(languageCode) — die
│   │   │                                         Dateien im Repository heißen uneinheitlich; Umbenennung dort =
│   │   │                                         neue App-Version, Textänderung nicht). EINZIGE Aufzählung
│   │   ├── guide_document.dart               ✅ guideDocumentProvider (Family) + Sprachcode der Inhalts-Adresse +
│   │   │                                         Laufrichtung (RTL bei fa/ar/he/ur). Hängt seit Phase 18 ohne
│   │   │                                         Sonderweg an der App-Sprache — der Persisch-Sonderfall aus
│   │   │                                         Phase 17.2 ist ersatzlos entfallen
│   │   └── guide_page.dart                   ✅ EINE Seite für alle vier Themen: Kopf mit Akzent-Verlauf, darunter
│   │                                             Markdown bzw. Ladekreis, Offline-Hinweis oder „Inhalt folgt"
│   ├── account/presentation/
│   │   ├── account_page.dart                 ✅ Profil, Gesamt-Statistik, Dashboard (gesamter Verlauf),
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
│   │       │                                     Text-Provider. Sprache = die der Anleitungen
│   │       ├── others_folders_page.dart      ✅ Ordner als Karten; unterscheidet kein Netz / fehlendes Manifest /
│   │       │                                     kaputtes Manifest sichtbar voneinander
│   │       └── others_folder_page.dart       ✅ Beiträge eines Ordners, klappen an Ort und Stelle auf — der Text
│   │                                             wird ERST beim Aufklappen geladen. Verkraftet einen Ordner,
│   │                                             den es im Repository nicht mehr gibt
│   └── onboarding/presentation/onboarding_page.dart ✅ Erststart-Erklärung in vier Schritten; erscheint nur,
│                                                 solange onboardingSeenProvider false ist (Startroute, kein
│                                                 Redirect); liegt außerhalb der ShellRoute → ohne Bottom-Nav
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
│   ├── habit_tile_data_test.dart        ✅ 2 Fälle (Farbkachel-Daten, archivierte ausgeschlossen)
│   ├── reschedule_reminders_test.dart   ✅ 3 Fälle (neue Sprache, ohne Erinnerung unangetastet, archivierte)
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
│   ├── home_widget_service_test.dart    ✅ 7 Fälle: mockt den MethodChannel und hält den Vertrag zur Kotlin-Seite
│   │                                        fest (Schlüssel/Werte, Provider-Namen, chartKeyFor, Farbe vorzeichenbeh.);
│   │                                        seit Phase 23 auch der Untertitel „Noch N offen"/„alles erledigt"
│   ├── daily_status_notification_test.dart ✅ 9 Fälle (Phase 23): Serie landet im geplanten Erinnerungstext,
│   │                                        Neuplanen zieht sie nach; DailyStatusMessage mahnt bei offenen und
│   │                                        schweigt bei erledigten/keinen Gewohnheiten; Schalter persistiert
│   ├── remove_ads_test.dart             🕯️ 8 Fälle (Phase 14), stillgelegt — plus EIN aktiver, mit `skip:`
│   │                                        übersprungener Platzhalter: ohne `main()` meldet flutter test
│   │                                        die Datei als Ladefehler
│   ├── app_theme_tokens_test.dart       ✅ 3 Fälle (Tokens je Variante+Helligkeit, heat(), Clamping)
│   └── no_dart_io_in_lib_test.dart      ✅ 1 Fall (Phase 26.11): kein `dart:io` in lib/, außer in Dateien
│                                            auf `_io.dart` (die lädt der Web-Bau nie).
│                                            ⚠️ Prüft QUELLTEXT, nicht Verhalten — und das mit Absicht:
│                                            Tests laufen auf der Dart-VM, wo `dart:io` funktioniert. Kein
│                                            Verhaltenstest hätte den Fehler aus 26.10 finden können
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
│   ├── others_page_test.dart        ✅ 8 Fälle (Phase 22): Reihenfolge aus dem Manifest, kaputtes Manifest
│   │                                     meldet den Grund (nicht „kein Internet"), 404 = leerer Kanal, ohne
│   │                                     Netz Wiederholen-Knopf, Text lädt ERST beim Aufklappen, unbekannter
│   │                                     Ordner bricht nicht, Eintrag steht UNTER „Wichtige Links"
│   ├── guide_page_test.dart         ✅ 8 Fälle (Rubrik, vier Routen, vier Dateinamen JE SPRACHE + Rückfall auf
│   │                                     Deutsch, Ladekreis → Text, Offline-Hinweis, 404, persisch = RTL)
│   ├── settings_theme_test.dart     ✅ 5 Fälle (Modus, Farbe, Sprache, Animations-Quelle persistiert; Kontakt).
│   │                                     Der Persisch-Fall prüft seit Phase 18 Oberfläche UND Inhalte auf `fa`
│   ├── remove_ads_tile_test.dart    🕯️ 2 Fälle (Phase 14), stillgelegt — mit demselben Platzhalter wie oben
│   ├── account_page_test.dart       ✅ 3 Fälle (Profil/Statistik/Achievements, Name persistiert, Teilen öffnet)
│   ├── categories_page_test.dart    ✅ Kategorie anlegen, umbenennen, löschen
│   ├── habit_form_sheet_test.dart   ✅ 2 Fälle (Bearbeiten/Löschen inkl. Notification-Cancel, Erinnerung setzen)
│   ├── share_card_test.dart         ✅ 6 Fälle (heute/Monat/Jahr; Kopfzeile mit Name+Datum, Punkte/Streak/
│   │                                     Achievements; Grid ohne Überlauf; QR + Store-Link; Übersicht-Block
│   │                                     ohne Überlauf bei fester Breite; ohne Block bleibt sie schmal)
│   ├── home_share_test.dart         ✅ 2 Fälle (Home-Knopf öffnet DASSELBE Sheet; leerer Bestand lässt den
│   │                                     Übersicht-Block weg und bricht nicht) — Phase 19
│   ├── persian_ui_test.dart         ✅ 5 Fälle (Oberfläche persisch + Directionality.rtl, Sprachauswahl selbst
│   │                                     persisch, persische Standard-Kategorien, Schlüssel-Stichprobe quer
│   │                                     durch die App, fa als unterstützte Locale inkl. Notification) — Phase 18
│   ├── reminders_page_test.dart     ✅ 3 Fälle (keine Erinnerung, Uhrzeit sichtbar, Abschalten cancelt)
│   ├── home_progress_animation_test.dart ✅ 4 Fälle (Prozent + Quelle, Gipfel bei 100 %, nächstes Camp, Clamping)
│   ├── dashboard_section_test.dart  ✅ Anpassen-Modus: hinzufügen, entfernen, beides persistiert
│   └── web_storage_hint_test.dart   ✅ 4 Fälle (Phase 26.8). ⚠️ Laufen auf der Dart-VM, also NIE im
│                                        Browser — prüfbar ist deshalb das Wichtigste: dass der Hinweis
│                                        auf Android/iOS NICHT erscheint und den Merker dort NICHT
│                                        verbraucht. Sonst verlöre ein Nutzer, der zuerst auf Android
│                                        startet, den Hinweis in der Web-Fassung stillschweigend
└── support/
    ├── test_database.dart           ✅ Isolierte In-Memory-Test-DB — nie die echte App-DB
    ├── test_time_service.dart       ✅ Festes Datum, kein Netzwerkzugriff in Tests
    ├── fake_notification_service.dart ✅ Protokolliert geplante/abgebrochene Erinnerungen + zuletzt genutzte Sprache
    ├── fake_purchase_service.dart   🕯️ offlinePurchaseService(prefs) + FakePurchaseService (Phase 14),
    │                                    stillgelegt. Keine *_test.dart-Datei → kein Platzhalter nötig
    ├── localized_app.dart           ✅ localizedApp(...) — **Pflicht-Rahmen** für Widget-Tests; ein blankes
    │                                     MaterialApp lässt jedes Widget werfen, das AppLocalizations liest.
    │                                     Dazu testL10n() für Dienste, die AppLocalizations als Parameter nehmen
    └── dispose_and_flush.dart       ✅ Räumt den Widget-Baum ab und flusht Drifts Nulldauer-Timer
```

## Release-Artefakte (Android)

Zwei Dateien liegen **bewusst außerhalb des Projekts** — sie enthalten Geheimnisse und dürfen nie in ein Repository oder in die iCloud-Synchronisierung geraten:
```
~/development/keys/root-in-upload.jks   ✅ Upload-Signaturschlüssel (Alias `upload`, gültig bis 2053).
                                           Geht die Datei verloren, lässt sich die veröffentlichte App nie wieder
                                           aktualisieren — Sicherheitskopie im Passwortmanager steht noch aus

android/
├── key.properties.example           ✅ Vorlage mit den vier Feldern — darf im Repository liegen
├── key.properties                   ✅ Die Kopie mit den ECHTEN Werten; in .gitignore (mit *.jks/*.keystore)
├── gradle.properties                ✅ `-Duser.language=en -Duser.country=US` in org.gradle.jvmargs — die
│                                        Systemsprache fa_AT gab der JVM persische Ziffern, wodurch bundletool
│                                        `classes۲.dex` erwartete und NUR der AAB-Release-Build abbrach
└── app/build.gradle.kts             ✅ applicationId + namespace = com.rootin.app; signingConfigs liest
                                         key.properties, sonst Debug-Schlüssel mit sichtbarer Warnung

build/app/outputs/bundle/release/app-release.aab  ⚙️ DAS ist die Datei für die Play Console
build/app/outputs/flutter-apk/app-debug.apk       ⚙️ Nur zum lokalen Prüfen
```

## Web-Fassung & Automatik

✅ **Gebaut in PLAN.md Phase 26.** Die Web-Fassung ist der Zugang zum iPhone, solange es keine App-Store-Veröffentlichung gibt.

```
tool/                                ✅ Skripte — von Hand UND von der Automatik aufgerufen
├── fetch_web_db_assets.sh           ✅ Holt sqlite3.wasm + drift_worker.js aus der drift-
│                                        Veröffentlichung. Liest die Version aus pubspec.lock, damit
│                                        Worker und Bibliothek nicht auseinanderlaufen.
│                                        ⚠️ `dart run drift_dev make-worker` ist mit drift 2.34.2 /
│                                        drift_dev 2.34.0 KAPUTT — nicht erneut versuchen
├── webtest.py                       ✅ Echter Browser-Durchgang der veröffentlichten Seite über
│                                        safaridriver (PLAN.md 26.7). 8 Prüfungen bis hin zu
│                                        „Daten überleben das Neuladen". Auch gegen einen lokalen
│                                        Bau nutzbar: `python3 tool/webtest.py http://localhost:8765/`
│                                        ⚠️ Einmalig nötig: `safaridriver --enable` (Mac-Passwort).
│                                        ⚠️ Jede Sitzung startet mit LEEREM Profil — Persistenz nur
│                                        innerhalb EINER Sitzung prüfbar, sonst misst man nichts
│                                        Seit Phase 26.11: **17 Prüfungen**, darunter alle vier Reiter
│                                        und eine Anleitungs-Seite. Am kaputten Stand wird er rot —
│                                        daran gemessen, nicht nur am reparierten (PLAN.md Lehre 32)
│                                        ⚠️ Gescrollt wird mit einem RAD-Ereignis: Ein Wisch bewegt
│                                        eine Flutter-Liste im Desktop-Browser nicht, ohne dass etwas
│                                        fehlschlägt. ⚠️ Reine Texte stehen unzuverlässig im
│                                        Semantik-Baum (von einer vollen Anleitungs-Seite nur ~190
│                                        Zeichen), Knöpfe immer — Zustände deshalb an Knöpfen ablesen
└── build_web.sh                     ✅ **Einzige Stelle der Bau-Schalter**: --no-source-maps, -O4, --csp,
                                         --base-href, Version aus pubspec.yaml, Baunummer aus
                                         GITHUB_RUN_NUMBER. Die Automatik ruft DIESES Skript auf —
                                         zwei Flag-Listen liefen sonst auseinander

.github/workflows/deploy-web.yml     ✅ Push auf main → pub get → analyze → test → build_web.sh →
                                         GitHub Pages. Prüfung VOR Veröffentlichung; base-href aus dem
                                         Repository-Namen; concurrency bricht ältere Läufe ab.
                                         ⚠️ Der Testschritt läuft OHNE `--no-test-assets`. Das Flag ist
                                         eine lokale Abkürzung; im CI (frischer Checkout = wie nach
                                         `flutter clean`) lässt es 11 Widget-Tests falsch scheitern.
                                         Genau daran ist Lauf 1 gescheitert — siehe PLAN.md Lehre 29.
                                         ⚠️ KEIN gh-pages-Zweig: Pages nimmt das Artefakt direkt
                                         entgegen, damit landet das Bauergebnis nie in der Geschichte

.env.example                         ✅ Vorlage für --dart-define-from-file. Die echte `.env` ist
                                         ausgeschlossen. ⚠️ Definierte Werte landen IM BUNDLE und sind
                                         dort auffindbar — kein Ersatz für einen Server
```

**Code-Anteil der Web-Fassung** (die Dateien selbst stehen oben in ihren Abschnitten):

| Was | Wo | Kern |
|---|---|---|
| Plattform-Weichen | `core/utils/platform_support.dart` | `supportsReminders`, `supportsHomeScreenWidgets`, `supportsOrientationLock`, `usesBrowserStorage`, `canReadForeignResponseHeaders`. **`kIsWeb` steht NUR hier** |
| Datenbank im Browser | `data/local/database.dart` | `DriftWebOptions` — ohne den Parameter wirft `driftDatabase()` im Web |
| Sicherung einlesen | `core/services/file_pick/` | Bedingter Import: mobil Dateipfad, im Browser `<input type="file">` |
| Netzzugriff | `package:http` in `time_service.dart` + `repo_content_service.dart` | **Kein `dart:io`** — es übersetzt für den Browser und wirft dort (Lehre 30) |
| Werte vom Bau | `core/constants/app_config.dart` | `String.fromEnvironment` + die Warnung, was das **nicht** leistet |

✅ **DIE VIER GEMELDETEN FEHLER SIND BEHOBEN** (PLAN.md 26.10/26.11, gemeldet und behoben am 2026-08-14) — zwei Ursachen hinter vier Beobachtungen:

| Beobachtung | Ursache | Behoben durch |
|---|---|---|
| App-Symbol stimmt nicht | Web-Symbole waren die der Flutter-Vorlage | `flutter_launcher_icons` mit `web: generate: true` |
| „Heute" leer (gemeldet als „kein Internetzugang") | `HttpClient()` aus `dart:io` warf im Browser → `todayProvider` im Fehler → kein Datum | `package:http` in `time_service.dart` |
| „Ansicht" leer (dieselbe Meldung) | dieselbe | dieselbe |
| Fünf Anleitungs-Seiten „kein Internet" | `HttpClient()` warf → `load()` warf | `package:http` in `repo_content_service.dart` |

**Nachgewiesen, nicht behauptet:** `tool/webtest.py` deckt jetzt alle vier Reiter und eine Anleitungs-Seite ab. Am **alten** Stand fielen genau die vier Prüfungen durch, die den gemeldeten Fehlern entsprechen; am reparierten Bau und **an der veröffentlichten Seite** sind alle 17 grün.

⬜ **Noch offen:** App-Symbol auf einem echten iPhone ansehen (Safari am Mac kann das Ablegen auf dem Home-Bildschirm nicht prüfen).

**Wo die Daten der Web-Fassung liegen** (PLAN.md Phase 26.8) — zwei getrennte Orte, beide überstehen Schließen und Neuöffnen:

| Was | Wo im Browser | Beispiele |
|---|---|---|
| Einzelwerte | `localStorage` (über `shared_preferences`) | Profilname, Sprache, Theme + Farbe, Erststart-Merker, Dashboard-Layout, gespeicherte Anleitungs-Texte |
| Die Datenbank | OPFS **oder** IndexedDB (Drift wählt selbst) | Gewohnheiten, Kategorien, alle Erledigungen |

Die **Serie wird nirgends gespeichert** — sie entsteht bei jedem Aufruf neu aus den Erledigungen (`StreakCalculator`). ⚠️ Beide Orte gehören zu **einem Browser auf einem Gerät**: Ein zweites Gerät hat einen eigenen Bestand, und „Website-Daten löschen" räumt beides ab. Deshalb der Hinweis aus 26.8 und die Bitte um dauerhaften Speicher beim Start.

**Was im Browser bewusst fehlt** (PLAN.md Phase 26.1): Erinnerungen und Tagesstand-Meldung, Startbildschirm-Widgets, die Querformat-Sperre der Übersicht. Die zugehörigen Bedienelemente verschwinden dort ganz — ein Schalter, der nichts bewirkt, ist schlimmer als kein Schalter. Eine gespeicherte Erinnerungs-Uhrzeit bleibt in der Datenbank **unangetastet**, damit dieselbe Sicherung auf Android wieder vollständig ist.

## Inhalts-Repository (GitHub)

⚠️ **Seit Phase 26.2 ist das DASSELBE Repository wie der Quellcode.** Bis dahin lag unter `lukasylilli/Root-in` ausschließlich der Ordner `content/`. Beim Anlegen des lokalen Git-Repositories fiel auf: Ein Push des Quellcodes hätte diese Dateien überschrieben — und die **bereits veröffentlichte Android-App** lädt sie zur Laufzeit von genau dieser Adresse. Beide Historien wurden deshalb zusammengeführt; `content/` liegt jetzt im Projekt und wird mitversioniert.

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

## Hinweise
- Diese Datei bildet **nur die Struktur** ab (was liegt wo) — Fortschritt und Feature-Details stehen in PLAN.md.
- Bei jeder neuen Datei/jedem neuen Ordner: hier ergänzen. Bei Löschung/Umbenennung: hier korrigieren.
- `*.g.dart` sind generiert (`dart run build_runner build`) und werden hier nicht einzeln aufgeführt.
- **Kommando-Aufruf auf dieser Maschine:** immer den vollen SDK-Pfad, `"$HOME/development/flutter/bin/flutter" analyze` / `test` / … — die Bash-Tool-Shell sourct `~/.zshenv`/`~/.zshrc` nicht neu und zeigt sonst auf die alte iCloud-SDK-Kopie (PLAN.md Abschnitt 11, Lehre 1–2).
- `adb` ist ebenfalls **nicht im PATH**: `"$HOME/Library/Android/sdk/platform-tools/adb"`. Eine Seite wirklich ansehen: `flutter run -t lib/main_seed.dart`, dann `adb shell input tap X Y` / `swipe` und `adb exec-out screencap -p > bild.png`. Koordinaten gelten für die **aktuelle** Ausrichtung; ein `input tap` auf einen Tab kommt gelegentlich nicht an — ein `swipe` über den Inhalt wechselt zuverlässig.
- `keytool`, `jarsigner` und `java` sind nicht im PATH — das JDK gehört zu Android Studio: `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/`.
- Jeder Widget-Test, der DB-gestützte Provider berührt, überschreibt `appDatabaseProvider` und `timeServiceProvider` und ruft `disposeAndFlush(tester)` als letzte Zeile. Tests, die Gewohnheiten anlegen/löschen oder Erinnerungen setzen, überschreiben zusätzlich `notificationServiceProvider`. Der frühere `purchaseServiceProvider`-Override ist mit Phase 20 entfallen.
- Tests, die die Home-Seite rendern, dürfen **kein** `pumpAndSettle()` verwenden — die funkelnden Sterne laufen dauerhaft. Stattdessen `tester.pump(const Duration(seconds: 1))`; für einen **Wechsel** auf Home braucht es drei aufeinanderfolgende `pump()` (Tipp → Speichern → Routen-Übergang, siehe `settleNavigation`).
- Tests, die die ganze App starten, müssen `onboarding_seen` in den gemockten Prefs setzen — sonst landen sie auf der Erststart-Erklärung.
- Widgets am unteren Ende einer `ListView`/`GridView` sind im Test-Viewport noch nicht gemountet — erst `tester.scrollUntilVisible(...)`. Bei mehreren verschachtelten Scrollables `find.byType(Scrollable).first` nehmen.
- **Datenbank-Abfragen mitten im Widget-Test** brauchen `await tester.runAsync(() async { … })`. Drift liefert Stream-Ergebnisse über einen Timer, und im Widget-Test steht die Uhr still — ein blankes `await stream.first` hängt bis zum Timeout (dieselbe Ursache wie bei `disposeAndFlush`). Wo kein Widget-Baum nötig ist, ist ein reines `test(...)` mit `ProviderContainer` der einfachere Weg.
- Ein **Render-Test** beweist Geometrie und Ausrichtung, aber **nicht** den verfügbaren Platz auf einem echten Gerät und nichts, was an einem Konfigurationswechsel hängt (Drehung, Theme). Wer ein Bild erzeugt: `FontLoader` und `boundary.toImage()` **müssen** in `tester.runAsync(...)` laufen, sonst hängt der Test bis zum Timeout.
- **Kein `dart:io` in `lib/`** — es übersetzt für den Browser und wirft dort erst zur Laufzeit (PLAN.md Lehre 30). Netzzugriffe über `package:http`; was wirklich Plattform braucht, kommt hinter einen bedingten Import (`*_io.dart` / `*_web.dart`, Vorbild `core/services/file_pick/`). `test/unit/no_dart_io_in_lib_test.dart` hält die Regel.
- **Netzzugriff braucht `INTERNET` im *Haupt*-Manifest.** Flutter legt sie nur in `src/debug/` und `src/profile/` an — neue Netz-Funktionen deshalb **im Release-Build** gegenprüfen.
- `AndroidManifest.xml` hat einen `<queries>`-Eintrag für `https`-`VIEW`-Intents (Android-11-Package-Visibility) — nötig für `url_launcher`.
- **Provider abwarten:** `container.read(streamProvider.future)` **ohne** gleichzeitigen Zuhörer hängt für immer (Riverpod verwirft den Provider und bricht die Drift-Subscription ab). Außerhalb des Widget-Baums `_awaitAlive` aus `home_widget_service.dart` nehmen oder selbst eine `container.listen`-Subscription halten.
- **Zahlen an Android-Widgets:** Werte über `Int.MAX_VALUE` (ARGB-Farben) landen als `Long` in den Preferences und lassen Kotlins `getInt` abstürzen — immer `.toSigned(32)` schreiben.
- **Neue UI-Texte** gehören in **alle drei** ARB-Dateien — `app_de.arb` (Vorlage), `app_en.arb`, `app_fa.arb` —, nie als Literal in den Code. Nach dem Ändern `flutter gen-l10n` laufen lassen (oder einfach bauen). ⚠️ **`flutter analyze` löst gen-l10n NICHT aus**: Wer nur analysiert, sieht neue Schlüssel als „undefined getter", obwohl die ARB stimmt. Fehlt ein Schlüssel in einer Nicht-Vorlage-Sprache, fällt er **still** auf Deutsch zurück — die App liefe, sähe aber gemischt aus; `persian_ui_test.dart` prüft das stichprobenartig. Texte außerhalb des Widget-Baums (Notifications, Home-Screen-Widgets) bekommen die Sprache übergeben.
- **Prozentwerte** kommen aus `core/l10n/app_numbers.dart`, nicht aus `'${x * 100}%'` im Widget. Dort steht auch die Entscheidung, in allen Sprachen westliche Ziffern zu verwenden. Einzige bewusste Ausnahme: das Übersicht-Board, dessen Spaltenbreiten auf seine eigene Schreibweise (mit Leerzeichen) ausgelegt sind.
- **Werbung wieder einschalten** (Phase 20 rückgängig): `grep -rn "PHASE 20 (2026-08-01)"` über `lib/`, `test/`, `pubspec.yaml` und `android/` findet jede Stelle. Danach `flutter pub get` und den Marker entfernen.

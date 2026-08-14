# Root-in — Habit Maker / Routine Tracker — Projektplan

> Lebendiges Dokument. Wird bei jeder relevanten Änderung am Projekt aktualisiert.
> Zuletzt aktualisiert: 2026-08-14 — **Phase 26 gebaut: Web-Fassung (PWA) und Veröffentlichung über GitHub**, einschließlich 26.8 (Daten im Browser sichern). Die App läuft im Browser (Drift auf WebAssembly, vier Plattform-Weichen an **einer** Stelle), das Projekt ist ein Git-Repository, eine GitHub-Action baut und veröffentlicht bei jedem Push auf `main`, und die Web-Fassung erklärt beim ersten Start, warum sie auf den Home-Bildschirm gehört. **188 Tests grün**, `flutter analyze` sauber, Web- und Android-Bau laufen. ⚠️ **Im Browser noch nicht ausgeführt** — auf dieser Maschine fehlt Chrome; Einzelheiten in Phase 26.7. Offen bleiben die Schritte des Nutzers: pushen und Pages einschalten.
> Zuvor 2026-08-07 — **Phase 13 gebaut** (Diagramm-Feinschliff & Tests): Fortschritts-Trend bündelt im Jahr-Bereich auf Wochen-/Monatsmittel, Balkendiagramm-Achsen aufgeräumt, Tests für Tab-Navigation und Heute-Randfälle. **184 Tests grün** (+2 übersprungen), `flutter analyze` sauber, am Emulator deutsch **und persisch** angesehen (dabei ein RTL-Fehler gefunden und behoben). Damit sind die beiden ältesten offenen Fragen aus Abschnitt 12 geschlossen.
> Zuvor 2026-08-02 — Phasen 25, 24, 23 und 22 gebaut (Datenerhalt beim Update, beliebiges Datum nachtragen, eindringlichere Erinnerungen, Rubrik „موارد دیگر" aus GitHub). Die am 2026-08-01 gebauten Phasen 18–21.2 sind auf Abschnitt 10.2 eingedampft.
> **Was jetzt noch offen ist:** der Gerätedurchgang aus Phase 21.3, die Veröffentlichung (Phase 15, führt der Nutzer selbst durch), Phase 12 (iOS) — und die Inhalte, die der Nutzer selbst ins Repository legt.

> ⚠️ **Umgebungs-Grundregel dieser Maschine:** Nie Code/SDKs/Dev-Tools unter `~/Desktop` oder `~/Documents` speichern — iCloud „Schreibtisch & Dokumente"-Sync ist hier aktiv und bricht Code-Signing für Binaries (siehe Abschnitt 11, Lehre 1). Immer `~/Projects/<name>` für Projekte, `~/development/<tool>` für SDKs — beide liegen außerhalb der iCloud-Synchronisierung.

## Inhaltsverzeichnis
1. [Vision](#1-vision)
2. [Zielplattformen](#2-zielplattformen)
3. [Datenhaltung](#3-datenhaltung)
4. [Tech-Stack](#4-tech-stack-entscheidungsstand)
5. [App-Struktur / Seiten](#5-app-struktur--seiten)
6. [Vorlagen & Standard-Kategorien](#6-vorlagen--standard-kategorien)
7. [Kern-Konzepte (Cross-Cutting)](#7-kern-konzepte-cross-cutting)
8. [Architektur-Prinzip](#8-architektur-prinzip)
9. [Arbeitsweise & Konventionen](#9-arbeitsweise--konventionen)
10. [Roadmap / Phasen](#10-roadmap--phasen)
    - 10.1 [Erledigte Phasen (Kurzfassung)](#101-erledigte-phasen-kurzfassung) — Phasen 0–11.6, 14 (Code), 15.1, 16/16.1, 17–17.3, 18, 19, 20, 21.1/21.2 ✅
    - 10.2 [Wichtige Festlegungen aus den Phasen 18–21](#102-wichtige-festlegungen-aus-den-phasen-1821)
    - [Phase 21 — Endkontrolle](#phase-21--endkontrolle--standard-kategorien-) 🔄 (21.1/21.2 ✅, **21.3 Gerätedurchgang offen**)
    - **Neu am 2026-08-02, in dieser Reihenfolge umzusetzen:**
      - [Phase 25 — Daten überleben jedes Update](#phase-25--daten-überleben-jedes-update-) ✅
      - [Phase 24 — Beliebiges Datum wählen und nachtragen](#phase-24--beliebiges-datum-wählen-und-nachtragen-) ✅
      - [Phase 23 — Erinnerungen, die wirklich erinnern](#phase-23--erinnerungen-die-wirklich-erinnern-) ✅
      - [Phase 22 — Rubrik „موارد دیگر"](#phase-22--rubrik-موارد-دیگر-weitere-themen-) ✅
    - [Phase 15 — Veröffentlichung im Google Play Store](#phase-15--veröffentlichung-im-google-play-store-android-) 🔄 (wartet auf Google)
    - [Phase 13 — Diagramm-Feinschliff & Tests](#phase-13--diagramm-feinschliff--tests-) ✅ (2026-08-07)
    - **Neu am 2026-08-07:** [Phase 26 — Web-Version (PWA) und Veröffentlichung über GitHub](#phase-26--web-version-pwa-und-veröffentlichung-über-github-) 🔄
      - [26.1 Lauffähig im Browser](#261-lauffähig-im-browser-) · [26.2 Repository & .gitignore](#262-repository--gitignore-) · [26.3 Automatischer Bau & Veröffentlichung](#263-automatischer-bau--veröffentlichung-cicd-)
      - [26.4 Was „Code-Schutz" im Web wirklich heißt](#264-was-code-schutz-im-web-wirklich-heißt-) · [26.5 Geheimnisse & Umgebungsvariablen](#265-geheimnisse--umgebungsvariablen-) · [26.6 Versionierung](#266-versionierung-)
      - [26.8 Daten im Browser sichern](#268-daten-im-browser-sichern-) ✅ — wo die Daten liegen, Safaris Sieben-Tage-Regel, einmaliger Hinweis
      - [26.7 Was noch offen ist](#267-was-noch-offen-ist-) ⬜ — **Code fertig, im Browser noch nicht ausgeführt**
    - [Phase 12 — iOS-Portierung](#phase-12--ios-portierung--feinschliff-) ⬜
11. [Entscheidungs-Log & dauerhafte Lehren](#11-entscheidungs-log--dauerhafte-lehren)
12. [Offene Fragen](#12-offene-fragen)

## 1. Vision
App zum Aufbauen und Verfolgen von Gewohnheiten/Routinen. Nutzer legen Habits an, haken sie täglich ab, sehen Streaks/Statistiken, bekommen Erinnerungen und werden durch kleine Gamification-Elemente motiviert, dranzubleiben. Inhaltlicher Schwerpunkt: Sprachenlernen (siehe Anleitungs-Rubrik und Standard-Kategorien).

## 2. Zielplattformen
- Phase 1: Android (primäres Zielsystem für Entwicklung & Tests)
- **Phase 1b (neu, 2026-08-07): Web als PWA** — der Ersatzweg auf das iPhone, solange keine Veröffentlichung im App Store möglich ist (Phase 26). Der Nutzer öffnet die Seite in Safari und legt sie über „Zum Home-Bildschirm" ab.
- Phase 2: iOS nativ (Portierung/Feinschliff) — bleibt das Ziel, die Web-Fassung ist die Überbrückung
- Desktop-Ordner (macos/, linux/, windows/) bleiben ungenutzt; **web/ ist seit Phase 26 im Umfang**

## 3. Datenhaltung
- Vollständig lokal, kein Backend, keine Nutzerkonten
- Internetzugriff nur für: Datums-Verifikation (Anti-Cheat gegen verstellte Geräteuhr) und die Anleitungs-Texte aus dem Repository. Ohne Internet: Systemzeit bzw. gespeicherter Textstand
- Profil-Infos (Name u. Ä.) bleiben lokal und werden **nicht** gesendet
- Lokale Datenbank: Drift (SQLite); Key-Value (Profil, Settings): shared_preferences
- Backup/Export: JSON über Dateisystem/Share-Sheet
- „Wettkampf" zwischen Nutzern läuft **nicht** über einen Server, sondern über geteilte **Bilder** des Fortschritts (Telegram-Gruppe, siehe Anleitung „Lernplanung"). Bestätigt 2026-07-19, unverändert gültig.

## 4. Tech-Stack (Entscheidungsstand)
| Bereich | Wahl | Begründung |
|---|---|---|
| State Management | flutter_riverpod | Testbar, kein BuildContext nötig |
| Navigation | go_router | Deklarative Routen, Bottom-Nav + verschachtelte Tabs |
| Lokale DB | drift + drift_flutter + sqlite3 | SQL für Streaks/Statistik. `sqlite3_flutter_libs` bewusst nicht (end-of-life) |
| Key-Value | shared_preferences | Profil, Settings |
| Diagramme | fl_chart | Balken/Linie/Kreis; Wrapper ausschließlich in `chart_card.dart` |
| Matrix-Grid | eigene Komponente | Volle Design-Kontrolle, überall wiederverwendbar |
| Home-Animation | eigener CustomPainter (+ lottie als Slot) | Berg-Szene ohne Asset-Abhängigkeit |
| Teilen | share_plus + screenshot | Share-Sheet für App-Link und Fortschritts-Bild |
| QR-Code | qr_flutter | Store-Link auf der Fortschritts-Karte (Phase 19). Reines Dart, kein Platform-Channel — läuft im Widget-Test und offscreen |
| Externe Links | url_launcher | Kontakt, Anleitungs-Links |
| Datei-Auswahl | flutter_file_dialog | **bewusst nicht `file_picker`** (win32-Konflikt mit share_plus, siehe Lehre 13) |
| Notifications | flutter_local_notifications (+ timezone, flutter_timezone) | Lokale Erinnerungen |
| Home-Screen-Widget | home_widget | Android App Widgets & später iOS WidgetKit |
| Lokalisierung | flutter gen-l10n (ARB) + flutter_localizations | Deutsch/Englisch/**Persisch** (seit Phase 18, inkl. RTL), 233 Schlüssel je Sprache. `intl` bleibt auf `^0.20.2` (SDK-Pin) |
| Markdown | flutter_markdown_plus | Anleitungs-Texte; Vorgänger `flutter_markdown` ist discontinued |
| Werbung | ~~google_mobile_ads~~ | **Seit Phase 20 vollständig auskommentiert** — Veröffentlichung erfolgt ohne Werbung |
| In-App-Kauf | ~~in_app_purchase~~ | **Seit Phase 20 mit auskommentiert** — der Kauf „Werbung entfernen" hat ohne Werbung keinen Gegenstand |
| Design | Material 3 | Konsistent mit Flutter-Standard |
| Tests | flutter_test, mocktail | Unit- und Widget-Tests |

## 5. App-Struktur / Seiten

### 5.1 Home
- Berg-Fortschritts-Animation (Kennzahl in den Einstellungen wählbar: heute/Woche/Monat/Jahr)
- Fortschritt in Prozent & Punkte
- Individualisierbares Widget-Dashboard (Matrix-Grid, Diagramme)
- Knopf „Fortschritt teilen" (Phase 19) — öffnet dasselbe Sheet wie die Konto-Seite

### 5.2 Heute
- Tagesring-Kopf (Prozent, Punkte, „x/y erledigt")
- **Datum wählbar** (Phase 24): Pfeile, Datumsauswahl, Weg zurück auf heute — Zukunft gesperrt
- Liste der an diesem Tag anstehenden Gewohnheiten, Abhaken bzw. Minuten eintragen
- „+"-Button: Vorlage oder eigene Gewohnheit; pro Gewohnheit Menü Bearbeiten/Löschen

### 5.3 View (Tabs: Woche / Übersicht / Monat / Jahr)
- **Woche/Monat/Jahr**: je individualisierbares Dashboard (Matrix-Grid, Balken-, Kreis-, Trend-, Monats-Diagramm)
- **Übersicht**: die letzten vier Kalenderwochen als **eine** quer liegende Bühne mit festem Raster (Linie, Balken, Gesamtziel, Habit×Tag-Matrix, Wochen-Kreise, Detail-Tabelle); Vollbild-Knopf, Querformat-Sperre

### 5.4 Einstellungen
- Sprache (System / فارسی / Deutsch / Englisch), Darstellungsmodus, Farb-Variante, Quelle der Berg-Animation
- Konto-Infos, Kategorien, Erinnerungen
- App teilen, Sicherung exportieren/importieren, Kontakt uns
- Rubrik **Root-in Anleitung**: Lernplanung, Lernquellen, Lernmethode, Wichtige Links
- Eintrag **موارد دیگر** direkt darunter (Phase 22) — Ordner und Texte aus dem Repository
- ~~Rubrik „Werbung"~~ — entfallen mit Phase 20

### 5.5 Konto
- Profil-Infos (lokal), Achievements-Grid, längste Serie, Gesamt-Statistik, Dashboard über den gesamten Verlauf
- „Fortschritt teilen" (bleibt hier erhalten — die Anleitung „Lernplanung" verweist ausdrücklich auf diesen Weg)

### 5.6 Kategorien
- Liste aller Kategorien, anlegen, umbenennen (kaskadiert auf alle Gewohnheiten), löschen (blockiert, solange eine Gewohnheit sie nutzt)
- Standard-Kategorien beim Erststart, dazu ein Knopf, sie nachträglich anzulegen (Phase 21.1)
- Symbol je Standard-Kategorie; der Lösch-Hinweis nennt die Zahl der blockierenden Gewohnheiten

## 6. Vorlagen & Standard-Kategorien

**Habit-Vorlagen** (`core/constants/habit_templates.dart`, 11 Stück): YouTube, Kursbuch, Arbeitsbuch, Wörter 10 Min, Wörter 1 Stunde, Grammatik aktiv, Schreiben, Lesen, Sprechen, Hören, Auswendiglernen. Ziel-Typ je Vorlage: Abhaken **oder** Dauer/Menge. Jede Vorlage trägt seit Phase 21 ein Feld `categoryId`, das auf eine der sieben Kategorien unten zeigt.

**Standard-Kategorien** (`core/constants/default_categories.dart`, seit Phase 21). Sie folgen den **sieben Fertigkeiten** aus der Anleitung (identisch in „Lernplanung" und „Lernquellen" im Repository):

| Deutsch | Englisch | Persisch |
|---|---|---|
| Grammatik | Grammar | دستور زبان |
| Wortschatz | Vocabulary | واژگان |
| Auswendiglernen | Memorization | حفظ کردن |
| Lesen | Reading | خواندن |
| Schreiben | Writing | نوشتن |
| Sprechen | Speaking | صحبت کردن |
| Hören | Listening | شنیدن |

Sie werden beim Erststart in der gewählten Sprache angelegt und sind danach **Nutzerdaten**: frei umbenennbar, löschbar, erweiterbar — nichts im Code schützt sie. Kurs- und Videounterricht zählen laut Anleitung zu **Grammatik** — dafür braucht es keine eigene Kategorie.

## 7. Kern-Konzepte (Cross-Cutting)

**Punkte & Prozent** — Jede Seite zeigt Fortschritt in Prozent und Punkten.

**Matrix-Grid** — Wiederverwendbare Heatmap (GitHub-Stil): Zellen = Tage, Farbintensität = Erledigungsgrad; Zeitspanne kontextabhängig.

**Diagramme** — Typ-Diagramm (je Kategorie) + Fortschritts-Trend, via `chart_card.dart`.

**Streak** — Aktuelle + längste Serie; Regel: 1 Tag pro Woche darf ausgelassen werden.

**Achievements** — 11 vordefinierte, auf der Konto-Seite als Grid.

**Teilen** — App teilen (Text + Store-Link) und Fortschritt teilen (Bild). Seit Phase 19: Knopf auf **Home und Konto** (ein Sheet für beide), Karte mit Kopfzeile, Kennzahlen, wählbarem Übersicht-Raster, Jahres-Matrix und QR-Code zum Store. Die Karte hat eine **feste Breite**, damit das Bild auf jedem Gerät gleich aussieht.

**Store-Link** — `core/constants/app_links.dart` ist die einzige Quelle; QR-Code, Share-Begleittext und „App teilen" lesen alle dort.

**Home-Animation** — Berg-Aufstieg als Fortschritts-Metapher; über `AppAssets.homeAnimation` gegen ein Lottie-Asset austauschbar.

**Gewohnheiten & Kategorien verwalten** — Jede Gewohnheit gehört zu genau einer Kategorie; Kategorien sind eine vom Nutzer verwaltete Liste, keine Konstanten.

## 8. Architektur-Prinzip
Feature-first (Details in MAP.md):
- `core/` — Services, Theme, Utils, Konstanten, geteilte Widgets
- `data/` — Drift-Datenbank, DAOs, Repository, Modelle
- `features/<feature>/` — Screens, Widgets, Provider (home, today, view, habits, settings, guide, account, categories, onboarding)

## 9. Arbeitsweise & Konventionen

**Schrittweiser Aufbau** — Phasenweise, nicht alles auf einmal. Nach jedem wesentlichen Schritt werden PLAN.md und MAP.md aktualisiert.

**Inhaltsverzeichnis-Pflicht** — Jede .md-Datei beginnt mit einem Inhaltsverzeichnis. Gilt **nicht** für .dart-Dateien (eine Datei = eine Verantwortung, Navigation über MAP.md).

**„Puzzling" / DRY** — Für jede wiederkehrende Sache genau **eine** Datei/Klasse (Farben, Styles, Buttons, Dialoge, Diagramme, Services). Andere Stellen referenzieren sie, statt sie zu duplizieren.

**Design-Token-Prinzip — ein Schalter ändert das ganze Aussehen** — Jeder Design-Aspekt hat eine eigene Datei: `app_colors`, `app_theme_tokens`, `app_theme_variant`, `app_fonts`, `app_text_styles`, `app_spacing`, `app_theme`, `app_button`; der Nutzer-Zustand (ThemeMode, Farbvariante, Sprache, Animations-Quelle, Onboarding-Merker) liegt in `settings_service.dart`, die Sprachen in `core/l10n/app_language.dart`. Eine Änderung an einer Datei zieht durch die ganze App.

**Datenerhalt geht vor** (Phase 25) — Die Datenbank ist Nutzereigentum. **Jede Änderung an `schemaVersion` braucht im selben Schritt einen `onUpgrade`-Zweig und einen Migrations-Test.** Fehlt er, startet die App nach dem Update nicht mehr auf dem alten Bestand — vom Nutzer aus gesehen dasselbe wie Datenverlust.

**Verifizieren statt annehmen** — „Build erfolgreich" ist kein Beweis. Ergebnisse werden gegengeprüft (Signatur des Bundles, Inhalt geschriebener Widget-Daten, Screenshot vom Emulator). Der Sichtcheck auf dem Gerät findet regelmäßig Dinge, die kein Test findet (siehe Lehre 8).

## 10. Roadmap / Phasen

### 10.1 Erledigte Phasen (Kurzfassung)

| Phase | Ergebnis | fertig |
|---|---|---|
| 0 Setup | Abhängigkeiten, Ordnerstruktur, Theme-Gerüst, Router + Bottom-Nav-Shell | 07-19 |
| 1 Datenmodell & Heute | Drift-Tabellen (Habits/Completions), Vorlagen, Abhaken, Punkte/Prozent, Streak inkl. 1-Frei-Tag-Regel, TimeService | 07-19 |
| 2 Navigation & Matrix-Grid | View-Tabs, wiederverwendbares `MatrixGrid`, Fortschritts-Header, DST-sichere Datumsarithmetik | 07-20 |
| 3 Statistik-Seiten | Kategorie-Balken + Fortschritts-Trend je Zeitraum, **ein** fl_chart-Wrapper | 07-20 |
| 4 Konto | Profil lokal, 11 Achievements + reine Freischalt-Logik, lebenslange Statistik | 07-20 |
| 4.5 Kategorien & Habits verwalten | `Categories`-Tabelle (Referenz per Name), anlegen/umbenennen/löschen, **ein** Formular für Anlegen + Bearbeiten | 07-20 |
| 5 Teilen | App teilen (Text), Fortschritts-Karte als Screenshot über das Share-Sheet | 07-20 |
| 5.5 Diagramme & Dashboard | 5 Diagrammtypen, volles Drag-and-Drop-Dashboard je Seite, Layout persistiert | 07-21 |
| 6 Einstellungen | Hell/Dunkel/System, Farbvarianten, Kontakt uns (Telegram) | 07-21 |
| 7 Erinnerungen | Tägliche Notification je Gewohnheit, Uhrzeit wählbar, Snooze, Berechtigungen | 07-21 |
| 8 + 8.6 Home-Animation | Berg-Szene nach Nutzer-Vorlage (Sonnenaufgang, Serpentinen-Pfad, Camps in Prozent, Kletterfigur, HUD); Kennzahl wählbar; Lottie-Slot verdrahtet | 07-21 |
| 8.5 Nachbesserungen | Karte mit heute/Monat/Jahr + Grid, `fitToWidth`, Erinnerungs-Übersicht | 07-21 |
| 9 Backup & Export | JSON-Export/-Import, IDs bleiben erhalten, Erinnerungen werden neu geplant | 07-21 |
| 10 + 10.5 + 10.7 Home-Screen-Widgets | Fortschritts-Widget + **fünf eigenständige** Diagramm-Widgets (Auswahl auf dem Startbildschirm, nicht in der App) | 07-23 |
| 10.6a–d Erscheinungsbild nach Spec | Design-Tokens, Spec-Look auf allen Seiten, Widget-Familien ring/checklist/color_tile (antippbare Farbkachel mit `RemoteViews`) — **9 Home-Screen-Widgets** | 07-26 |
| 11 + 11.5 Lokalisierung | DE/EN über ARB (~190 Schlüssel), **ein** Sprach-Schalter; ein Wechsel zieht Startkategorie, Erinnerungen und Widgets sofort nach | 07-26 |
| 11.6 Onboarding | Vierteilige Erststart-Erklärung, Merker `onboarding_seen`, Startroute statt Redirect | 07-26 |
| 14 Monetarisierung (Code) | AdMob-Banner + Einmalkauf „Werbung entfernen"; seit 2026-08-01 per Not-Schalter für alle aus → **wird in Phase 20 vollständig auskommentiert** | 07-26 |
| 15.1 Paketname & Signatur | `com.rootin.app` (inkl. Kotlin-Paketumzug), Upload-Schlüssel, Release-Bundle signiert und verifiziert | 07-26 |
| 15.2 Store-Material | App-Symbol (512 + Adaptive), Feature-Grafik, je 4 Screenshots DE/EN, Store-Texte, Datenschutzerklärung (öffentlich gehostet) | 07-26 |
| 16 + 16.1 Übersicht-Seite | 28 Tagesspalten in **einem** festen Raster (alle Maße in einer Datei, Stack statt Flex), Vollbild-Route, Querformat-Sperre | 07-30 |
| 17 → 17.3 Root-in Anleitung | Vier Seiten, Inhalte als Markdown aus dem Repository (ohne App-Update änderbar), DE/EN/FA, RTL nach **Inhalts**-Sprache, alle vier gefüllt | 08-01 |
| 20 Werbung auskommentiert | Werbe- und Kauf-Code stillgelegt (nicht gelöscht), Pakete und Manifest-Einträge ebenso; App **formal** werbefrei, Datenschutzerklärung und Store-Texte nachgezogen | 08-01 |
| 21.1/21.2 Standard-Kategorien | Die sieben Fertigkeiten beim Erststart, Nachrüst-Knopf für Bestandsnutzer, Vorlagen je Kategorie zugeordnet, Lösch-Hinweis nennt die Anzahl | 08-01 |
| 19 Teilen überarbeitet | Knopf auf Home (**ein** Sheet für beide Wege), Karte mit Übersicht-Block, QR-Code zum Store, feste Bildbreite, Auswahl persistiert | 08-01 |
| 18 Persisch vollständig | 233 Schlüssel in `app_fa.arb`, Persisch als echte Oberflächen-Sprache inkl. RTL, Sonderweg `contentLanguageCode` entfallen | 08-01 |

| 13 Diagramm-Feinschliff | Trend bündelt auf Wochen-/Monatsmittel, Balken-Achsen aufgeräumt, Tests für Tab-Navigation und Heute-Randfälle | 08-07 |

Der Stand nach diesen Phasen (einschließlich 22–25): **184 Tests grün** (+2 bewusst übersprungen), `flutter analyze` sauber, Release-Bundle signiert und hochladbar. Details zu Entscheidungen und Fallstricken stehen kompakt in Abschnitt 11, die Datei-Struktur in MAP.md.

---

### 10.2 Wichtige Festlegungen aus den Phasen 18–21

Die vier Phasen sind erledigt (Tabelle oben); ihre Langfassungen sind hier zu dem eingedampft, was man später noch wissen muss. Der Rest steht im Code und in Abschnitt 11.

**Phase 18 — Persisch.** Persisch ist eine vollwertige Oberflächen-Sprache; der Zwischenstands-Begriff `contentLanguageCode` ist ersatzlos entfallen, Oberfläche und Inhalte kommen aus **einem** Schalter.
- **Ziffern bleiben westlich, auch auf Persisch** — Begründung in `core/l10n/app_numbers.dart`, dort liegt auch die einzige Prozent-Formatierung. Eine Umstellung betrifft nur diese Datei.
- **Die Übersicht bleibt links-läufig**: Ein Kalender Mo–So läuft auch in persischen Kalendern so, und ein Spiegeln würde jede Koordinate in `overview_metrics.dart` umkehren. Diagramme und Berg-Animation ebenso (Achsenlogik bzw. Metapher).
- **Schriftart bleibt die Plattform-Schrift** — Android bringt Arabisch mit. Zeigt ein Gerät Kästchen, ist `app_fonts.dart` der eine Ort für eine Ersatzschrift.
- ⬜ Die Übersetzung ist ein **Entwurf** — der Nutzer geht sie als Muttersprachler durch (`lib/l10n/app_fa.arb`).

**Phase 19 — Teilen.** Knopf auf Home **und** Konto, beide öffnen `showShareProgressSheet()` — den einzigen Weg zur Vorschau. Der Konto-Weg musste bleiben, weil die Anleitung „Lernplanung" ihn wörtlich beschreibt.
- Die Karte hat eine **feste Breite** (440 px schmal, ~1334 px mit Übersicht-Block) — ein geteiltes Bild soll überall gleich aussehen. Der `Screenshot`-Knoten liegt **innerhalb** der Vorschau-`FittedBox`, sonst wäre das Bild so klein wie die Vorschau.
- Den Übersicht-Block bekommt die Karte als **fertiges Widget**, nicht als sechs Datenfelder — so importiert `core/` nichts aus `features/`.
- `core/constants/app_links.dart` ist die einzige Quelle des Store-Links (QR-Code, Share-Text, „App teilen").

**Phase 20 — Werbung stillgelegt.** Alles auskommentiert, nichts gelöscht; jede Stelle trägt den Marker `PHASE 20 (2026-08-01)`. Wiedereinschalten ist ein `grep`.
- Kaufmerker in `shared_preferences` bleiben unangetastet — ein früherer Käufer ist sofort wieder werbefrei.
- ⬜ **Der veröffentlichte Gist der Datenschutzerklärung ist noch nicht nachgezogen** (siehe Phase 15).

**Phase 21.1/21.2 — Standard-Kategorien.** Die sieben Fertigkeiten entstehen beim Erststart in der gewählten Sprache (`ensureDefaultCategories`, nur bei leerer Tabelle); `addMissingCategories` rüstet Bestandsnutzer über einen Knopf nach.
- Sie sind **Nutzerdaten** — nichts im Code schützt sie. Das Symbol wird über den **Namen** zugeordnet; wer umbenennt, verliert es.
- Jede Vorlage trägt ein `categoryId`-Feld; die Namen kommen aus `default_categories.dart`, also aus einer Quelle.

---

### Phase 21 — Endkontrolle & Standard-Kategorien 🔄
**Vom Nutzer am 2026-08-01 beauftragt:** letzte Kontrolle der App vor der Veröffentlichung — sie darf nicht abstürzen, Kategorien müssen vom Nutzer einstellbar sein, und die Standard-Kategorien werden nach Lernplanung/Lernquellen angelegt.
**Stand: 21.1 und 21.2 fertig ✅, 21.3 zur Hälfte — die Werkzeug-Prüfungen sind durch, der Gerätedurchgang steht aus.**

#### 21.1 Standard-Kategorien anlegen ✅
- [x] **Neue Datei `core/constants/default_categories.dart`** — **eine** Quelle: stabile IDs (`grammar`, `vocabulary`, `memorization`, `reading`, `writing`, `speaking`, `listening`), Name je Sprache über `l10n` (Muster wie `habit_templates.dart`), Symbol je Kategorie.
- [x] **Beim Erststart angelegt** — `CategoryDao.ensureDefaultCategory` (eine Kategorie) ist zu `ensureDefaultCategories` (die sieben) geworden und gibt jetzt die **Anzahl** statt eines Bool zurück. Die Regel „nur wenn die Tabelle leer ist" gilt unverändert: Ein späterer Sprachwechsel schiebt keinen zweiten Satz hinterher (Grund siehe Phase 11.5), Bestandsnutzer behalten ihre Kategorien.
- [x] **Bestandsnutzer:** Knopf „Standard-Kategorien anlegen" unten auf der Kategorien-Seite (`addMissingCategories`) — legt nur an, was fehlt, und meldet die Anzahl. Er steht **ohne Bedingung** dort: Wäre er nur sichtbar, solange etwas fehlt, wäre unklar, warum er verschwindet — stattdessen meldet er „sind schon alle da".
- [x] **Vorlagen den Kategorien zugeordnet:** `HabitTemplate` hat jetzt ein Feld `categoryId`, das auf `DefaultCategory.id` zeigt — YouTube/Kursbuch/Arbeitsbuch/Grammatik aktiv → Grammatik, Wörter 10 Min/1 Stunde → Wortschatz, die übrigen gleichnamig. Der Name kommt aus `default_categories.dart`, also aus **einer** Quelle: Eine per Vorlage angelegte Gewohnheit landet damit in genau der Kategorie, die beim Erststart schon existiert.
- [x] Namen in **allen drei** ARB-Dateien; `templateCategoryLanguageLearning` und `defaultCategoryName` sind entfernt. Bei der Gelegenheit sind drei weitere tote Schlüssel gefallen (`overviewTabTitle`, `guideOpenLink`, `shareCardAchievements`) — sie hätten sonst nur Übersetzungsarbeit in Phase 18 gekostet.
- [x] Tests: `category_dao_test.dart` prüft Erststart legt genau sieben an, zweiter Start legt nichts nach, Sprachwechsel legt nichts nach, Nachrüsten ergänzt nur Fehlendes und meldet 0, wenn alles da ist; `categories_page_test.dart` prüft den Knopf mit Meldung.

#### 21.2 Kategorien vom Nutzer einstellbar ✅
Anlegen, Umbenennen (kaskadiert) und Löschen (blockiert, solange in Benutzung) gibt es seit Phase 4.5. Nachgezogen wurde:
- [x] Umbenennen/Löschen gilt auch für die Standard-Kategorien — sie sind Nutzerdaten, nichts im Code schützt sie. Erkennbar sind sie nur am Symbol, das `DefaultCategory.iconForName` über den **Namen** zuordnet; wer eine umbenennt, verliert das Symbol. Richtig so — sie ist ab dann eine eigene.
- [x] Der Lösch-Hinweis nennt jetzt, **wie viele** Gewohnheiten blockieren. Dafür gibt `deleteCategory` statt des Enums ein `DeleteCategoryOutcome` (Status + Anzahl) zurück; ohne das müsste die Oberfläche ein zweites Mal in der Datenbank nachzählen. Der ARB-Text ist ein Plural.
- [x] Reihenfolge ist stabil und nachvollziehbar: alphabetisch nach Namen (`watchAllCategories`) — sie sortiert sich beim Anlegen und Umbenennen nicht überraschend um.
- [ ] Optional (offene Frage, Abschnitt 12): **Farbe** je Kategorie — heute trägt die Farbe die Gewohnheit. Das Symbol gibt es seit dieser Phase, die Farbe kostet eine DB-Spalte und bleibt offen.

#### 21.3 Absturz- und Vollständigkeits-Kontrolle 🔄
Reihenfolge: erst Werkzeuge, dann Gerät. **Die Werkzeuge sind durch:**
- [x] `flutter analyze` sauber · **125 Tests grün** (+2 übersprungen: die ruhenden Werbe-Fälle) · `flutter build appbundle --release` und `--release apk` laufen · Bundle mit dem Upload-Schlüssel signiert (gültig bis 2053) · Manifest ohne `AD_ID`/`BILLING`/AdMob.
**Der Gerätedurchgang steht noch aus** (Stand 2026-08-01 abends). Er ist der Teil, den Tests nicht ersetzen können — siehe Lehre 8. Reihenfolge der offenen Punkte:

- [ ] **Release-Build auf einem echten Gerät** (nicht nur Emulator) — Debug und Release unterscheiden sich hier nachweislich (Lehre 5: fehlende `INTERNET`-Berechtigung fiel nur im Release auf). Die Datei liegt unter `build/app/outputs/flutter-apk/app-release.apk`.
- [ ] **Frische Installation** (`pm clear`): Onboarding → **sieben** Standard-Kategorien da → Gewohnheit aus einer Vorlage anlegen (landet sie in der passenden Kategorie?) → abhaken → alle Seiten. **Leerer Zustand** ist der häufigste Absturz-Kandidat: alle Diagramme, die Übersicht und die Teilen-Karte ohne einen einzigen Eintrag öffnen.
- [ ] **Kein Werbe-Streifen** unten auf allen vier Hauptseiten, und die Einstellungen ohne Rubrik „Werbung" (Phase 20).
- [ ] **Teilen-Ablauf mit Bild-Kontrolle** (Phase 19): Karte **mit** und **ohne** Übersicht-Block teilen und das **erzeugte Bild** öffnen — nicht nur die Vorschau. Der QR-Code muss sich mit einem zweiten Gerät scannen lassen und auf `play.google.com/store/apps/details?id=com.rootin.app` führen.
- [ ] **Voller Bestand** über `lib/main_seed.dart` (~400 Tage): alle vier View-Tabs, Übersicht im Vollbild, Jahr-Ansicht, Konto.
- [ ] **Alle vier Sprachen** (System/فارسی/Deutsch/Englisch) × **hell und dunkel** × alle vier Farbvarianten stichprobenartig. **Persisch vollständig durchklicken** (Phase 18): Laufen alle Seiten rechtsläufig? Steht irgendwo noch deutscher Text? Zeigt ein Gerät leere Kästchen statt persischer Schrift (dann `AppFonts` — siehe Phase 18, Punkt 5)? Läuft in der Übersicht oder auf der Teilen-Karte Text über, weil persische Wörter länger sind?
- [ ] **Drehen** auf jeder Seite (die Übersicht sperrt bewusst Querformat — beim Verlassen muss die Sperre fallen).
- [ ] **Alle 9 Home-Screen-Widgets** platzieren und antippen (Farbkachel: Abhaken aus fremdem Isolate, danach zurück in die App).
- [ ] Erinnerungen: setzen, auslösen, Snooze, abschalten; Sicherung: exportieren, importieren, App danach neu starten.
- [ ] Anleitungs-Seiten **offline** (gespeicherter Stand) und bei fehlendem Text (404 → „Inhalt folgt"); auf Persisch prüfen, dass die persischen Dateien geladen werden (`guideLanguageProvider` hängt seit Phase 18 an der Oberflächen-Sprache).
- [ ] Nachrüst-Knopf „Standard-Kategorien anlegen" an einer Installation mit Bestand (Phase 21.1).
- [ ] Bekannte Risikostellen gezielt prüfen: `read(provider.future)` ohne Zuhörer (Lehre 6), Farbwerte an Android-Widgets (Lehre 7), Kategorie-Dropdown im Ladezustand, Import einer beschädigten Sicherung.
- [ ] Gefundene Abstürze werden **hier** als Unterpunkte protokolliert, nicht stillschweigend behoben.

---

### Phase 25 — Daten überleben jedes Update ✅
**Vom Nutzer am 2026-08-02 beauftragt:** Mit jedem Update dürfen Konto-Infos und Fortschritt nicht verloren gehen. **Zuerst umgesetzt**, obwohl zuletzt genannt — sie schützt das, was die anderen drei Phasen anfassen.

**Stand der Prüfung (2026-08-02): Ein Update löscht heute schon nichts.** Die Datenbank liegt über `drift_flutter` in `getApplicationDocumentsDirectory()`, die Einstellungen in `shared_preferences` — beides sind App-Daten, die Android bei einem Update unangetastet lässt. Geleert wird nur bei Deinstallation oder „Daten löschen" durch den Nutzer. **Es gibt also nichts zu reparieren; es gibt etwas abzusichern**, denn die eigentliche Gefahr sieht für den Nutzer genauso aus wie Datenverlust:

- [x] **Jede Schema-Änderung braucht einen `onUpgrade`-Zweig.** Fehlt er, öffnet Drift die alte Datei nicht mehr — die App startet nach dem Update nicht, und für den Nutzer ist das von „alles weg" nicht zu unterscheiden. Als Regel in Abschnitt 9 aufnehmen, nicht nur als Kommentar in `database.dart`.
- [x] **Migrations-Test** (`test/unit/database_migration_test.dart`), 4 Fälle grün: eine Datenbank im Schema 1 bzw. 2 von Hand anlegen, füllen, hochziehen — und prüfen, dass Gewohnheiten, Erledigungen und Kategorien vollständig und mit **denselben IDs** dastehen. Dieser Test ist der eigentliche Gegenstand der Phase; ohne ihn ist die Zusage „Daten bleiben" nur eine Behauptung.
- [x] **`android:allowBackup="true"` ausdrücklich gesetzt** statt es dem Standard zu überlassen. Damit steht schriftlich, ob Root-in in Googles automatische Sicherung geht — das ist der einzige Weg, wie Daten einen **Gerätewechsel** überstehen. ⚠️ Zusammenhang mit Phase 20: Im Datensicherheitsformular ist „keine Daten erhoben" angegeben; Auto-Backup widerspricht dem nicht (die Sicherung gehört dem Nutzer, nicht uns), sollte aber in der Datenschutzerklärung stehen.
- [x] **Sicherung sichtbarer gemacht:** Der Untertitel von „Sicherung exportieren" sagt jetzt in allen drei Sprachen genau das, was der Nutzer wissen wollte — *„Ein Update löscht nichts. Eine Sicherung hilft bei Geräteverlust oder Neuinstallation."* Dort sucht man, nicht in der Erststart-Erklärung.
- [ ] ⬜ **Am Gerät prüfen** (offen, gehört zum Durchgang aus 21.3): Version in `pubspec.yaml` erhöhen, Bestand anlegen, die neue Fassung **über** die installierte drüber installieren (nicht deinstallieren!), Bestand kontrollieren.

**Wie der Migrations-Test gebaut ist** — der Trick lohnt das Festhalten: Statt das alte Schema von Hand zu tippen (und dabei vom echten abzuweichen), lässt der Test **Drift den aktuellen Stand anlegen** und baut ihn dann gezielt zurück — Spalten weg, Kategorien-Tabelle weg, `user_version` zurück. Was dabei entsteht, ist per Konstruktion genau das, was frühere App-Versionen auf dem Gerät hinterlassen haben. Geprüft wird nicht nur die Anzahl der Zeilen, sondern dass **dieselben IDs** dastehen: `HabitCompletions.habitId` verweist darauf, und eine Migration, die Gewohnheiten neu anlegt statt sie zu behalten, würde jede Erledigung von ihrer Gewohnheit trennen.

**Der vierte Testfall ist eine Bremse, kein Beweis:** Er hält `schemaVersion` auf dem Wert fest, für den die Migration geprüft ist. Wer die Zahl erhöht, ohne die Tests zu erweitern, bekommt einen roten Test statt eines Nutzers mit einer App, die nicht startet.

---

### Phase 24 — Beliebiges Datum wählen und nachtragen ✅
**Vom Nutzer am 2026-08-02 beauftragt, am selben Tag gebaut.** Die Heute-Seite zeigt jetzt einen **wählbaren** Tag; ein alter Bestand lässt sich damit nachtragen (Beispiel des Nutzers: 28. März 2018).

Die Datenbank konnte das längst — `HabitCompletions.date` und `watchCompletionsForDate` gibt es seit Phase 1. Fest verdrahtet war nur die Oberfläche.

- [x] **`selectedDateProvider`** — der eine Schalter dafür, welchen Tag die Seite zeigt. Dahinter liegt bewusst ein **Override** (`selectedDateOverrideProvider`, `null` = heute) statt eines festen Datums: So springt die Seite über Mitternacht von selbst weiter, solange der Nutzer nichts anderes gewählt hat.
- [x] **Datumszeile** über dem Tagesring: Pfeil zurück / vor, Datum antippen öffnet die Auswahl (ab dem Jahr 2000), und sobald ein anderer Tag gewählt ist, erscheint ein Weg zurück auf heute. Statt eines nackten Datums steht dort „Heute" bzw. „Gestern", wo das zutrifft.
- [x] **Zukunft gesperrt** — der Vorwärts-Pfeil ist auf heute abgeschaltet (`onPressed: null`, kein Knopf der nichts tut), die Datumsauswahl endet ebenfalls bei heute.
- [x] **Alle aktiven Gewohnheiten sind für jedes vergangene Datum eintragbar**, auch solche, die es damals noch nicht gab. Die Alternative — nur ab `createdAt` — würde genau den Fall unmöglich machen, um den es geht.
- [x] **Startbildschirm-Widget, Home-Seite und Fortschritts-Karte bleiben auf heute.** Dafür sind die Provider getrennt: `dayProgressProvider(date)` rechnet, `todayProgressProvider` fragt mit heute, `selectedDayProgressProvider` mit dem gewählten Tag. Ein eigener Test hält genau das fest — wandert der Widget-Wert mit, zeigt der Startbildschirm irgendwann 2018.
- [x] Tests (`test/widget/today_date_test.dart`, 6 Fälle): Start auf heute · ein Tag zurück zeigt den Stand von gestern · **Abhaken schreibt auf den gewählten Tag und heute bleibt leer** · Zukunft gesperrt · „Heute" springt zurück · Widget/Karte bleiben auf heute.

**Umbenannt dabei:** `HabitWithTodayStatus` → `HabitWithDayStatus`, Feld `isDoneToday` → `isDone`. „Today" im Namen wäre ab jetzt schlicht falsch gewesen — der Status gehört zu dem Tag, den der Aufrufer angefragt hat.

⚠️ **Zwei Folgen, bewusst so:**
1. **Ein Nachtrag verlängert die Serie rückwirkend** und kann Achievements freischalten. Serien und Statistiken rechnen aus den Erledigungen; das ist gewollt und steht hier, damit es später niemand für einen Fehler hält.
2. **Die Datums-Prüfung im Netz bleibt unangetastet** (Anti-Cheat, Abschnitt 3): Sie bestimmt weiterhin, welcher Tag **heute** ist. Nachtragen ist erlaubt, das Vordatieren von „heute" nicht.

⬜ **Offen:** Gerätedurchgang (Teil von 21.3) — vor allem die Datumsauswahl auf Persisch und im Querformat.

---

### Phase 23 — Erinnerungen, die wirklich erinnern ✅
**Vom Nutzer am 2026-08-02 beauftragt, am selben Tag gebaut.** Sperrbildschirm, Benachrichtigungsleiste und Startbildschirm-Widget sollen zum Handeln bewegen.

**Die technische Einsicht, die den Aufbau bestimmt:** `flutter_local_notifications` legt den Text **beim Planen** fest, nicht beim Anzeigen. „Noch 3 von 5 offen" kann deshalb nicht in einer Erinnerung stehen, die morgen früh von selbst auslöst — sie wüsste den Stand von morgen nicht. Daraus folgen zwei getrennte Bausteine:

- [x] **1. Die tägliche Erinnerung nennt die Serie, die auf dem Spiel steht** — „Deine Serie von 12 Tagen endet um Mitternacht." statt „Vergiss deine Gewohnheit nicht." Der Wert kommt beim Planen aus `currentStreakForHabit`; `rescheduleAllReminders` zieht ihn bei jedem Anlass nach (App-Start, Sprachwechsel, Erinnerung ändern).
- [x] **2. Dauerhafte Tagesstand-Meldung** „Heute: 2 von 5 erledigt / 3 Gewohnheiten sind noch offen." — `ongoing`, lässt sich nicht wegwischen, verschwindet von selbst, sobald alles erledigt ist. Aktualisiert wird sie am **selben** Auslöser wie das Startbildschirm-Widget (`ref.listen(todayProgressProvider…)` in `app.dart`): **ein Sender, zwei Empfänger**. Eine zweite Beobachtungsstelle wäre früher oder später auseinandergelaufen.
- [x] **3. Sperrbildschirm:** beide Meldungen mit `visibility: public` — sonst steht dort nur „Benachrichtigung". Der Erinnerungs-Kanal bekommt `Importance.high` (kommt als Einblendung), der Tagesstand `Importance.low`.
- [x] **4. Widget:** zeigt den **offenen Rest** („Noch 2 offen") statt des Stands, und meldet den erledigten Tag ausdrücklich („Heute alles erledigt").
- [x] **5. Schalter in den Einstellungen** direkt neben den Erinnerungen; er wirkt sofort in beide Richtungen (eigener Listener, kein Warten auf die nächste Fortschritts-Änderung).
- [x] Tests (`test/unit/daily_status_notification_test.dart`, 9 Fälle): Serie landet im geplanten Text · ohne Serie steht der neutrale Text · Neuplanen zieht die gewachsene Serie nach · Meldung bei offenen, keine bei erledigten/keinen Gewohnheiten · Singular/Plural · Schalter persistiert. Dazu 2 Fälle im Widget-Dienst.

**Zwei Entscheidungen, die beim Bauen fielen:**
1. **Der Tagesstand ist leise** (`Importance.low`, `onlyAlertOnce`). Er ist dauernd da; ein Ton bei jeder Änderung wäre nicht eindringlich, sondern unerträglich. **Der Druck kommt aus der Zahl, nicht aus dem Geräusch.**
2. **Eigener Benachrichtigungs-Kanal** für den Tagesstand. Android lässt Kanäle einzeln abschalten — wer den dauerhaften Hinweis nicht will, soll dabei nicht die Erinnerungen verlieren.

**Neu herausgezogen:** `DailyStatusMessage` im Notification-Dienst — ein reines Wertobjekt, das entscheidet, **ob** gemahnt wird und **was** dort steht (`null` = abräumen). Grund: `FlutterLocalNotificationsPlugin` hat einen privaten Konstruktor und lässt sich im Dart-VM-Test weder ersetzen noch auflösen. Dieselbe Bauart wie `StreakCalculator` — die Entscheidung ist prüfbar, die Zustellung bleibt deklarative Konfiguration.

⚠️ **Maß halten.** Der Ton bleibt bei „X ist noch offen, deine Serie endet heute" — wahr und konkret — statt bei Beschimpfung. Android darf einer App die Benachrichtigungen entziehen, wenn Nutzer sie als störend melden, und eine App, die nervt statt hilft, wird deinstalliert.

⬜ **Offen (Gerätedurchgang, 21.3):** `ongoing`, Sperrbildschirm-Sichtbarkeit und Kanal-Wichtigkeit lassen sich nur am Gerät prüfen — im Test ist das deklarative Konfiguration.

---

### Phase 22 — Rubrik „موارد دیگر" (Weitere Themen) ✅
**Vom Nutzer am 2026-08-02 beauftragt, am selben Tag gebaut.** Ein **einseitiger Kanal** an die Nutzer — wie ein Telegram-Kanal, aber nur in eine Richtung, und die Beiträge bleiben dauerhaft und in Ordnern sortiert stehen. Der Nutzer pflegt alles im GitHub-Repository; ändert er dort Texte oder Ordner, ändert sich die Rubrik in der App **ohne App-Update**.

In der App: Einstellungen → Eintrag „موارد دیگر" **direkt unter „Wichtige Links"** → Ordner als Karten (Reihenfolge aus dem Manifest) → je Ordner die Beiträge, die sich an Ort und Stelle aufklappen.

#### Zwei Entscheidungen des Nutzers (2026-08-02)
1. **Die Struktur kommt aus einer `index.json`**, nicht aus der GitHub-API. Die API könnte Ordner von selbst auflisten, erlaubt aber nur **60 Abrufe pro Stunde und IP-Adresse** ohne Anmeldung — mehrere Nutzer hinter derselben Mobilfunk-Adresse sähen die Rubrik zeitweise leer. Preis: Ein neuer Text kostet zwei Zeilen im Manifest.
2. **Je Sprache ein eigener Satz**: `content/others/fa|en|de/`. Es gibt **keinen Rückfall** zwischen den Sprachen — fehlt eine, bleibt die Rubrik dort leer („Inhalt folgt"), statt fremdsprachige Beiträge zu zeigen.

#### Aufbau im Repository
```
content/others/<sprache>/index.json
content/others/<sprache>/<ordner>/<datei>.md
```
Vollständige Vorlage und Pflege-Anleitung: `store/others_index_beispiel.json` und `store/OTHERS_CONTENT.md`. `file_path` ist **relativ zum Sprachordner und enthält den Ordnernamen** — so setzt die App nichts zusammen, und ein Beitrag kann später umziehen, ohne dass das Schema bricht.

#### Was gebaut wurde
- [x] **`GuideContentService` → `RepoContentService` verallgemeinert.** Er lädt jetzt **jeden** Pfad unter `content/`, mit demselben Zwischenspeicher, derselben 404-Behandlung und derselben Regel „gespeicherten Stand sofort zeigen, im Hintergrund nachladen, nur bei echter Änderung melden". Zwei Dienste nebeneinander wären genau die Doppelung, die Abschnitt 9 verbietet.
- [x] ⚠️ **Mit Übernahme des alten Zwischenspeichers.** Der Schlüssel hieß bis Phase 17.1 `guide_md_<sprache>_<name>`. Ohne Übernahme stünde ein Nutzer nach dem Update **offline vor einer leeren Anleitung** — der Text wäre noch da, nur unter einem Namen, den niemand mehr abfragt. Beim ersten Zugriff wird er umgehängt und der alte Schlüssel geräumt. Derselbe Gedanke wie Phase 25: Ein Update darf nichts wegnehmen.
- [x] **Modelle** `OthersManifest`/`OthersFolder`/`OthersEntry` mit `fromJson`. Sie parsen **fremde, handgepflegte** Daten — jeder Fehler kommt als `OthersManifestException` mit **Grund-Code** heraus (sprachneutral, Muster wie `backup_data.dart`), nie als Absturz tief im Widget-Baum. Die Detail-Angabe nennt die Stelle, damit der Autor nicht blind in einer langen Datei sucht.
- [x] **Sortierung stabil:** nach `order`, bei Gleichstand nach Reihenfolge in der Datei. Dart sortiert nicht stabil — ohne das zweite Kriterium sprängen gleich eingeordnete Ordner bei jedem Laden.
- [x] **Zwei Seiten + Routen** (`/others`, `/others/:folderId`). Anders als bei den Anleitungs-Themen kann **kein Enum** die Routen aufzählen — welche Ordner es gibt, steht erst im Repository. Deshalb ein Pfad-Parameter, und deshalb verkraftet die Ordner-Seite den Fall „gibt es nicht mehr" (der Verlauf bleibt stehen, während der Autor umbenennt).
- [x] **Markdown-Darstellung geteilt:** `core/widgets/markdown_view.dart` — herausgezogen aus `guide_page.dart`, jetzt von beiden Rubriken genutzt. Zwei Stylesheets wären zwei Stellen für jeden Design-Wechsel gewesen. Die RTL-Erkennung wanderte dabei nach `core/l10n/app_language.dart` (`textDirectionForLanguage`), weil `core/` nicht aus `features/` lesen darf.
- [x] **Beiträge laden erst beim Aufklappen** — ein Ordner mit zwanzig Beiträgen würde sonst zwanzig Abrufe auf einmal auslösen. Test hält das fest.
- [x] **Vier Fehlerfälle sichtbar unterschieden:** kein Netz und nichts gespeichert („Kein Internet" + Wiederholen) · Manifest fehlt (404 → leerer Kanal, kein Fehler) · Manifest kaputt („Inhalt nicht lesbar" — der Autor soll erfahren, dass **seine Datei** das Problem ist, nicht die Verbindung des Nutzers) · einzelner Text fehlt („Inhalt folgt", der Rest bleibt lesbar).
- [x] Texte in **allen drei** ARB-Dateien.
- [x] Tests: `others_manifest_test.dart` (10 Fälle, inkl. „das mitgelieferte Beispiel ist gültig" — wäre die Vorlage fehlerhaft, führte die Anleitung in die Irre) und `others_page_test.dart` (8 Fälle, inkl. „Eintrag steht unter Wichtige Links").

⚠️ **Was diese Phase ausdrücklich nicht ist:** kein Rückkanal, keine Kommentare, keine Push-Benachrichtigung bei neuen Beiträgen. Beides wäre ein Server — und Abschnitt 3 sagt: kein Backend. Ob neue Beiträge gemeldet werden sollen, steht als offene Frage in Abschnitt 12.

⚠️ **GitHub liefert mit `max-age=300`:** Bis zu fünf Minuten nach dem Hochladen kann die App den alten Stand zeigen. Das ist kein Fehler und steht so in `store/OTHERS_CONTENT.md`.

⬜ **Offen:** Der Nutzer legt `content/others/<sprache>/index.json` im Repository an — bis dahin zeigt die Rubrik „Inhalt folgt". Dazu der Gerätedurchgang (21.3).

---

### Phase 15 — Veröffentlichung im Google Play Store (Android) 🔄
**Führt der Nutzer selbst durch**; Claude liefert Code-Anteile auf Zuruf und erklärt den jeweils nächsten Schritt auf Persisch. Läuft fast vollständig außerhalb des Codes.

**Stand:** Code fertig und signiert ✅ · Store-Material vollständig ✅ · Play-Entwicklerkonto angelegt, **Identitätsprüfung läuft** ⏳ · alles ab 15.2 wartet darauf. Der gesamte AdMob-Zweig ist mit Phase 20 entfallen (siehe dort).

⚠️ **Seit Phase 20 ist die veröffentlichte Datenschutzerklärung veraltet.** `store/PRIVACY_POLICY.md` ist nachgezogen, der **Gist nicht** — er aktualisiert sich nicht von selbst. Das muss **vor** dem Ausfüllen des Datensicherheitsformulars passieren, sonst widersprechen sich Formular und verlinkter Text.

#### Wichtige Kennungen (Nachschlagetabelle)
| Was | Wert | Wo im Projekt |
|---|---|---|
| Paketname (`applicationId`) | `com.rootin.app` ⚠️ nach Veröffentlichung unveränderlich | `android/app/build.gradle.kts` |
| Store-Link (ab Veröffentlichung gültig) | `https://play.google.com/store/apps/details?id=com.rootin.app` | `lib/core/constants/app_links.dart` (seit Phase 19) |
| Datenschutzerklärung (öffentlich) | https://gist.github.com/lukasylilli/673c36972d69819d975ffb82a592cca2 | Quelle: `store/PRIVACY_POLICY.md` |
| Signaturschlüssel | `~/development/keys/root-in-upload.jks`, Alias `upload`, gültig bis 2053 | `android/key.properties` |
| Kontakt | alirzsaleh@gmail.com · https://t.me/LukasAlmani | `lib/core/constants/contact_info.dart` |
| Anleitungs-Inhalte | `raw.githubusercontent.com/lukasylilli/Root-in/main/content/<sprache>/<datei>.md` | `guide_topic.dart` / `guide_content_service.dart` |
| AdMob-App-ID / Ad-Unit / Produkt-ID | `ca-app-pub-7806974290921501~9284147977` · `…/5672206027` · `remove_ads` | **seit Phase 20 auskommentiert**, hier nur zum Wiedereinschalten aufbewahrt |

⚠️ Ändert sich die App-Funktionalität, muss `store/PRIVACY_POLICY.md` angepasst **und der Gist neu gespeichert** werden — die veröffentlichte Fassung aktualisiert sich nicht von selbst. Phase 20 löst genau das aus.

#### Offene Schritte
- [ ] **15.0** Play-Identitätsprüfung abwarten (läuft seit 2026-07-26). ~~AdMob-Zahlungsprofil, Bankverbindung, W-8BEN~~ → mit Phase 20 nicht mehr nötig für die Veröffentlichung.
- [ ] **15.2** App in der Console anlegen, Store-Eintrag aus `store/PLAY_LISTING.md` füllen, Datenschutz-URL eintragen, Inhaltseinstufung + Zielgruppe, **Datensicherheit: keine Daten erhoben**, **Werbung: Nein**, **In-App-Käufe: Nein**. ⚠️ Vorher den Gist der Datenschutzerklärung auf den Stand von Phase 20 bringen.
- [ ] **15.2b** *(nicht blockierend)* Launcher-Symbol nachschärfen — die Strichzeichnung hat nur 4,6 % Tintenanteil und verschmiert bei 48 px. Per Update jederzeit austauschbar.
- [ ] **15.3** `flutter build appbundle --release` → Bundle in *Testen → Interner Test* hochladen.
- [ ] **15.3b** **12-Tester-Regel**: 12 Tester müssen die App **installiert** haben, danach 14 zusammenhängende Tage. Kein Engpass (über 200 Schüler), aber die Uhr startet erst nach Googles Build-Freigabe. Realistisch 4–5 Wochen bis zur Produktion.
- [ ] ~~15.4 Produkt `remove_ads`~~ · ~~15.5 Kauf-/Werbetest~~ · ~~15.7 AdMob verknüpfen~~ — entfallen mit Phase 20.
- [ ] **15.6** Produktion: Versionsnummer in `pubspec.yaml` erhöhen (jeder Upload braucht einen höheren `versionCode` — steht noch auf `1.0.0+1`), Bundle bauen, Release erstellen, zur Überprüfung einreichen (Prüfdauer: Stunden bis 7 Tage).
- [ ] **15.8** *(optional, neu mit Phase 18)* Persische Store-Sprache anlegen — Texte liegen in `store/PLAY_LISTING.md`, es fehlen noch persische Screenshots.

---

### Phase 26 — Web-Version (PWA) und Veröffentlichung über GitHub 🔄
**Vom Nutzer am 2026-08-07 beauftragt.** Ziel: **Root-in im Browser**, veröffentlicht über GitHub, damit iPhone-Nutzer die App benutzen können, solange eine Veröffentlichung im App Store nicht möglich ist. Auf dem iPhone wird die Seite über Safari → „Zum Home-Bildschirm" abgelegt und läuft dann wie eine App (eigenes Symbol, kein Browser-Rahmen).

⚠️ **Eine Zusage, die vorab klargestellt gehört, weil der Auftrag sie enthält:** *„der Nutzer soll den Code nicht nachbauen können"* ist im Web **nicht erreichbar** — die Begründung steht in 26.4. Was erreichbar ist: minimierter Code ohne Source-Maps, keine Geheimnisse im Bundle, und alles wirklich Schützenswerte auf einem Server. Diese Phase liefert genau das und benennt die Grenze, statt eine Sicherheit zu behaupten, die es nicht gibt.

#### Ausgangslage (geprüft am 2026-08-07)
- `flutter build web --release` **läuft bereits durch** — der Bau ist nicht das Problem.
- Das Projekt ist **noch kein Git-Repository** (`git status` → „not a git repository"). Auf GitHub liegt bisher nur das **Inhalts**-Repository mit den Markdown-Texten (Phase 17/22).
- **Die App würde im Browser sofort abstürzen:** `driftDatabase(name:)` wirft auf Web ohne den Parameter `web:` (`ArgumentError`, nachgelesen in `drift_flutter/src/web.dart`). Ohne Datenbank keine Seite.
- Vier Dienste sprechen mit Plattform-Bausteinen, die es im Web nicht gibt. Dass jeder davon **genau eine** Datei ist (Abschnitt 9), macht diese Phase überhaupt bezahlbar — es sind vier Weichen, nicht vierzig.

| Baustein | Datei | Im Browser |
|---|---|---|
| Drift/SQLite | `data/local/database.dart` | nur mit `sqlite3.wasm` + `drift_worker.js` |
| Erinnerungen | `core/services/notification_service.dart` | **nicht vorhanden** |
| Startbildschirm-Widget | `core/services/home_widget_service.dart` | **nicht vorhanden** |
| Sicherung importieren | `core/services/backup_service.dart` | anderer Weg (Browser-Download/Upload) |
| Bild teilen | `core/services/share_service.dart` | `path_provider` fehlt |

#### 26.1 Lauffähig im Browser ✅
- [x] **Drift auf WebAssembly**: `DriftWebOptions` in `database.dart`; `sqlite3.wasm` und `drift_worker.js` liegen in `web/`. Drift wählt im Browser selbst zwischen OPFS und IndexedDB — beides bleibt **auf dem Gerät**, Abschnitt 3 gilt unverändert.
- [x] ⚠️ **`dart run drift_dev make-worker` ist kaputt** (drift 2.34.2 gegen drift_dev 2.34.0: *„The getter 'allSchemaEntities' isn't defined"*). Die fertigen Dateien liegen der drift-Veröffentlichung bei; `tool/fetch_web_db_assets.sh` holt sie und liest die **Version aus `pubspec.lock`**, damit Worker und Bibliothek nicht auseinanderlaufen.
- [x] **Plattform-Weichen als Fähigkeiten benannt**, nicht als Plattformen: `supportsReminders`, `supportsHomeScreenWidgets`, `supportsOrientationLock` in `core/utils/platform_support.dart`. **`kIsWeb` steht damit an genau einer Stelle im ganzen Projekt.**
- [x] **Zwei Dienste sind plattformfrei geworden, statt eine Weiche zu bekommen.** `share_plus` nimmt mit `XFile.fromData` die Bytes direkt und legt selbst eine temporäre Datei an; `downloadFallbackEnabled` macht daraus im Browser einen Download. Damit fielen `dart:io` **und** `path_provider` aus `backup_service.dart` und `share_service.dart` heraus — auf allen drei Plattformen jetzt derselbe Weg statt drei Sonderfällen. `path_provider` ist als direkte Abhängigkeit entfallen.
- [x] **Sicherung einlesen** über einen bedingten Import (`core/services/file_pick/`): mobil `flutter_file_dialog` + `dart:io`, im Browser ein `<input type="file">` mit `FileReader`. Der Rückgabewert ist der **Inhalt**, kein Pfad — so bleibt `BackupService` frei von Plattform-Wissen und weiter testbar.
- [x] ⚠️ **`oncancel` nicht vergessen:** Bricht der Nutzer den Datei-Dialog im Browser ab, feuert `onchange` nie. Ohne das zusätzliche Ereignis bliebe das Future **für immer** offen und die App zeigte einen Ladezustand ohne Ende.
- [x] **Ehrlich abschalten statt still scheitern:** Ohne Erinnerungen verschwinden die Rubrik in den Einstellungen, der Tagesstand-Schalter und der Erinnerungs-Schalter im Gewohnheits-Formular ganz. Eine **gespeicherte Uhrzeit bleibt in der Datenbank unangetastet** — wer dieselbe Sicherung später auf Android einspielt, findet seine Erinnerungen wieder (derselbe Gedanke wie Phase 25).
- [x] **PWA-Feinschliff**: `manifest.json` und `index.html` tragen Namen, Beschreibung und Markenfarbe statt der Flutter-Vorlage („A new Flutter project", Flutter-Blau). Dazu die iOS-Meta-Tags — **Safari liest fürs Ablegen auf dem Home-Bildschirm nicht das Manifest**, ohne sie öffnete die Verknüpfung eine gewöhnliche Browser-Seite mit Adressleiste.

#### 26.2 Repository & .gitignore ✅
- [x] `git init` auf `main`, erster Commit (**348 Dateien**). Das Verbinden mit GitHub und der erste Push bleiben beim Nutzer — das ist der Schritt, der Code nach außen gibt.
- [x] **Kein `gh-pages`-Zweig.** Ursprünglich so geplant, beim Bauen verworfen: GitHub Pages nimmt heute ein **Artefakt** direkt aus der Automatik entgegen (`upload-pages-artifact`/`deploy-pages`). Ein zweiter Zweig würde das gebaute Ergebnis doch wieder in die Versionsgeschichte schreiben — genau das, was der Auftrag ausschließt. Quelle und Ergebnis sind so **strenger** getrennt als mit dem Zweig.
- [x] `.gitignore` um Web-Artefakte, `.env` und zwei Fundstücke ergänzt (siehe unten).
- [x] ⚠️ **Die Kontrolle vor dem ersten Commit hat sich gelohnt** — zwei Dinge wären mitgegangen:
  - `meine/` (Screenshots, Design-Specs, Logo-Quelle) — Arbeitsmaterial, kein Quellcode.
  - `.claude/settings.local.json` — maschinenlokale Einstellungen mit **hunderten absoluten Pfaden unter `/Users/<name>/`**. In einem öffentlichen Repository wäre die Ordnerstruktur des Rechners für jeden lesbar.
- [x] Geprüft, dass `key.properties`, `*.jks`, `build/` und die beiden Web-Datenbank-Dateien **nicht** im Commit stehen.

#### 26.3 Automatischer Bau & Veröffentlichung (CI/CD) ✅
- [x] `.github/workflows/deploy-web.yml`: Push auf `main` → `flutter pub get` → **`analyze` + `test`** → `tool/build_web.sh` → GitHub Pages. Die Prüfung steht bewusst **vor** der Veröffentlichung: Eine Fassung mit roten Tests soll gar nicht erst online gehen.
- [x] `--base-href` kommt aus `github.event.repository.name` statt fest eingetragen — ein umbenanntes Repository bricht den Bau damit nicht. ⚠️ Ohne den richtigen Wert bleibt die Seite unter der GitHub-Adresse **weiß**, weil sie ihre Dateien eine Ebene zu hoch sucht.
- [x] **`tool/build_web.sh` ist die einzige Stelle der Bau-Schalter** — die Automatik ruft dasselbe Skript auf, das der Nutzer lokal benutzt. Zwei Listen von Flags wären früher oder später auseinandergelaufen, und der veröffentlichte Bau wäre ein anderer als der geprüfte.
- [x] `concurrency: cancel-in-progress` — ein Push während eines laufenden Baus bricht den alten ab, statt zwei Veröffentlichungen um dieselbe Seite streiten zu lassen.

#### 26.4 Was „Code-Schutz" im Web wirklich heißt ✅
- [x] `--no-source-maps`, `-O4`, `--csp` stehen im Bau-Skript, jede Zeile mit dem Grund daneben. Am gebauten Ergebnis nachgeprüft: **keine `.map`-Datei** in `build/web`.
- [x] **`--obfuscate` gibt es für Web nicht** — der Schalter gilt der nativen Übersetzung (Android/iOS). `dart2js` liefert bereits minimierten Code mit unkenntlichen Namen; mehr ist nicht vorgesehen.
- [x] **Die Grenze, schriftlich:** Alles, was der Browser ausführt, muss der Browser lesen können. `main.dart.js` lässt sich herunterladen und analysieren — **das ist nicht verhinderbar**, auch nicht mit WebAssembly (dort ist es nur unbequemer). Wer die Web-Fassung veröffentlicht, gibt die Logik der Oberfläche aus der Hand. Das ist der Preis dafür, ohne App Store auf das iPhone zu kommen.
- [x] Daraus die einzige belastbare Regel, die auch in `app_config.dart` steht: **Was geheim bleiben muss, darf nicht in die App.** Es gehört hinter einen Server, der es nie herausgibt.

#### 26.5 Geheimnisse & Umgebungsvariablen ✅
- [x] `core/constants/app_config.dart` als **eine** Stelle für Werte, die beim Bauen hereinkommen (`String.fromEnvironment`), plus `.env.example` als Vorlage für `--dart-define-from-file`. Die echte `.env` ist ausgeschlossen.
- [x] ⚠️ **Ein `--dart-define` ist keine Verschlüsselung.** Der Wert wird einkompiliert und ist im Bundle auffindbar. Er hält Werte aus dem Repository heraus und lässt sie je Umgebung tauschen — mehr nicht. Die Warnung steht dort, wo jemand den ersten Schlüssel eintragen würde.
- [x] **Root-in hat heute keine Geheimnisse** (kein Backend, keine Konten, Werbung seit Phase 20 stillgelegt). Das Gerüst steht trotzdem, damit ein späterer Server-Anteil nicht improvisiert wird.

#### 26.6 Versionierung ✅
- [x] Versionsname aus `pubspec.yaml` gelesen (nicht im Skript wiederholt), Baunummer aus `GITHUB_RUN_NUMBER`, lokal `0`.
- [x] Beides zusätzlich als `--dart-define`: `--build-name`/`--build-number` landen im Web nur in `version.json` und wären für den Dart-Code unsichtbar.
- [x] Die Version steht am Fuß der Einstellungen. Bei einer Web-Fassung, die sich beim nächsten Laden **unbemerkt** aktualisiert, ist sie der einzige verlässliche Anhaltspunkt für „welchen Stand siehst du gerade?".

#### 26.7 Was noch offen ist ⬜
**Der Code ist fertig; was fehlt, sind Schritte außerhalb dieses Rechners und eine Prüfung, die hier nicht möglich war.**

- [ ] ⚠️ **Im Browser noch nicht ausgeführt.** Geprüft sind: `flutter analyze` sauber, **184 Tests grün**, `flutter build web --release` läuft, der Android-Bau läuft weiterhin, `sqlite3.wasm` und `drift_worker.js` werden ausgeliefert, keine Source-Maps im Ergebnis. **Nicht geprüft ist der Start im Browser** — auf dieser Maschine ist kein Chrome installiert (Flutter braucht ihn für `-d chrome`), und ein Bildschirmfoto von Safari scheitert an der fehlenden Berechtigung zur Bildschirmaufnahme. Der erste echte Aufruf ist damit der erste Test. **Der wahrscheinlichste Stolperstein ist die Datenbank** — sie ist der einzige Teil, der im Browser einen völlig anderen Weg geht.
- [ ] **Der Nutzer pusht** (Anleitung folgt im Chat). Bewusst nicht automatisiert: Es ist der Schritt, der den Code nach außen gibt.
- [x] ⚠️ **Beinahe-Datenverlust abgewendet: Das Repository gab es schon.** `lukasylilli/Root-in` existiert seit Phase 17.1 — öffentlich, Zweig `main`, Inhalt: **nur** der Ordner `content/` mit den zwölf Anleitungs-Texten. Genau diese Adresse fragt die **bereits veröffentlichte Android-App zur Laufzeit** ab. Ein `git push` des reinen Quellcodes wäre abgelehnt worden (fremde Historie); ein erzwungener Push hätte die zwölf Dateien gelöscht und die Anleitung in der ausgelieferten App auf „Inhalt folgt" gesetzt — **ohne dass es hier aufgefallen wäre**, denn lokal ändert sich nichts. Beide Historien sind deshalb zusammengeführt (`--allow-unrelated-histories`); `content/` liegt jetzt neben dem Quellcode und wird mitversioniert.
- [x] **Folge für die Adresse:** Die Web-Fassung landet unter `lukasylilli.github.io/Root-in/`, also genau dem `--base-href /Root-in/`, das bereits geprüft ist. Ein zweites Repository für den Quellcode hätte die Anleitungs-Adressen ungültig gemacht — und die ließen sich nur mit einem **App-Update** nachziehen (siehe Phase 17.3: Umbenennungen kosten eine App-Version).
- [ ] **GitHub Pages einschalten** (Settings → Pages → Source: *GitHub Actions*). Ohne das läuft der Arbeitsablauf und veröffentlicht nichts.
- [ ] ⚠️ **GitHub Pages kann die Kopfzeilen `Cross-Origin-Opener-Policy`/`Embedder-Policy` nicht setzen.** Drift nutzt dann nicht die schnellste Speicherart (OPFS mit gemeinsamem Speicher), sondern fällt auf eine andere zurück. **Die Daten bleiben erhalten** — es ist eine Frage der Geschwindigkeit, kein Datenverlust. Wer das ändern will, braucht einen Hoster, der eigene Kopfzeilen erlaubt.
- [ ] **Auf einem echten iPhone durchgehen**: Seite in Safari öffnen → **erscheint der Speicher-Hinweis aus 26.8 genau einmal?** → „Zum Home-Bildschirm" → startet sie ohne Adressleiste? Bleiben die Daten nach dem Schließen erhalten? Funktionieren Teilen und Sicherung?

#### 26.8 Daten im Browser sichern ✅
**Vom Nutzer am 2026-08-07 beauftragt**, nachdem er gefragt hatte, wo die Daten der Web-Fassung eigentlich liegen. Die Antwort hat eine Lücke aufgedeckt, die vorher niemand auf dem Zettel hatte.

**Wo die Daten liegen** — es sind zwei getrennte Orte, und beide überstehen Schließen und Neuöffnen:

| Was | Wo im Browser | Beispiele |
|---|---|---|
| Einzelwerte | `localStorage` (über `shared_preferences`) | Profilname, Sprache, Theme + Farbe, Erststart-Merker, Dashboard-Layout, gespeicherte Anleitungs-Texte |
| Die Datenbank | OPFS **oder** IndexedDB (Drift wählt selbst) | Gewohnheiten, Kategorien, alle Erledigungen |

**Die Serie wird nirgends gespeichert** — sie entsteht bei jedem Aufruf neu aus den Erledigungen (`StreakCalculator`, seit Phase 1). Solange die Erledigungen da sind, stimmt sie. Das gilt im Browser genauso wie auf Android.

⚠️ **Die Lücke: Safari löscht den Speicher einer Website nach sieben Tagen ohne Besuch.** Für eine Seite, die auf dem **Home-Bildschirm** abgelegt wurde, gilt diese Regel nicht. Damit ist das Ablegen im Browser **keine Frage der Bequemlichkeit, sondern die Bedingung dafür, dass der Verlauf erhalten bleibt** — und das stand vorher nirgends. Ein Nutzer, der die Adresse nur als Lesezeichen behält, hätte nach zwei Wochen Urlaub einen leeren Bestand vorgefunden, ohne je gewarnt worden zu sein.

- [x] **Um dauerhaften Speicher bitten** (`core/services/web_storage/`): `navigator.storage.persist()` beim Start, über denselben bedingten Import wie das Datei-Auswählen. Steht **vor** dem ersten Datenbank-Zugriff — die Bitte gilt dem ganzen Ursprung, und manche Browser fragen dafür beim Nutzer nach. ⚠️ Es ist eine **Bitte, keine Garantie**: Browser entscheiden selbst, manche stellen die Frage nie. Eine zusätzliche Schicht, kein Ersatz für die Sicherung.
- [x] **Einmaliger Hinweis in der Web-Fassung** (`core/widgets/web_storage_hint.dart`): warum Root-in auf den Home-Bildschirm gehört, wie das in Safari geht, und dass die Sicherung hier wichtiger ist als auf Android. Texte in allen drei Sprachen.
- [x] **Bewusst ein Dialog, kein wegwischbarer Streifen.** Wer diesen Hinweis übersieht, verliert im ungünstigsten Fall seinen ganzen Bestand — dafür ist ein Streifen am Seitenrand zu leise.
- [x] **Eigener Merker statt fünfter Onboarding-Seite.** Das Onboarding läuft nur bei einer frischen Installation. Wer die Web-Fassung schon benutzt, hat es hinter sich — und wäre genau der Nutzer, der den Hinweis nie sähe, obwohl seine Daten betroffen sind.
- [x] **Erst merken, dann zeigen.** Andersherum sähe ein Nutzer, der den Dialog wegdreht statt ihn zu bestätigen, den Hinweis bei jedem Start erneut.
- [x] **Neue Fähigkeit `usesBrowserStorage`** statt den Hinweis an `supportsHomeScreenWidgets` zu hängen. Beim Schreiben zuerst falsch gemacht: Die beiden Abfragen liefern im Browser dasselbe, meinen aber Verschiedenes — auf einem Desktop-Bau wäre der Safari-Hinweis erschienen, obwohl er dort unsinnig ist.
- [x] Tests (`test/widget/web_storage_hint_test.dart`, 4 Fälle). ⚠️ Sie laufen auf der Dart-VM, also **nie im Browser** — prüfbar ist deshalb genau das Wichtigste: dass der Hinweis auf Android/iOS **nicht** erscheint und den Merker dort **nicht verbraucht**. Täte er es, hätte ein Nutzer, der die App zuerst auf Android startet, seinen Hinweis in der Web-Fassung stillschweigend verloren — die Sicherung wandert per Import zwischen beiden Fassungen.

**Stand danach: 188 Tests grün**, `flutter analyze` sauber, Web- und Android-Bau laufen.

#### Offene Fragen dieser Phase
- **Repository öffentlich oder privat?** GitHub Pages aus einem **privaten** Repository ist ein kostenpflichtiges Merkmal. Öffentlich heißt: der Quellcode ist für jeden lesbar. ⚠️ Das ist die eigentliche Entscheidung hinter dem Wunsch „niemand soll meinen Code nachbauen können" — und sie ist keine technische, sondern eine des Nutzers. Anmerkung: Auch bei einem **privaten** Repository bleibt die veröffentlichte Web-Fassung analysierbar (siehe 26.4); privat schützt die Quelle, nicht das Ergebnis.
- **Erinnerungen im Web:** Web-Push wäre technisch möglich, bräuchte aber einen Server — das widerspricht Abschnitt 3. Vorerst entfallen sie im Browser. Damit ist die Web-Fassung ausdrücklich **nicht gleichwertig** zur Android-App; sie ist der Zugang, nicht der Ersatz.
- **Browser-Speicher kann geleert werden.** Anders als eine installierte App liegen die Daten im Speicher der Website. Löscht der Nutzer die Website-Daten, sind sie weg. Die Sicherung (Export/Import) ist im Web deshalb **wichtiger** als auf Android — offen ist, ob die App im Browser aktiv darauf hinweisen soll.
- **Zwei Fassungen, zwei Datenbestände.** Wer Root-in auf Android **und** im Browser benutzt, hat zwei getrennte Bestände; abgeglichen wird nur über Export/Import von Hand. Ein Abgleich bräuchte einen Server.

---

### Phase 12 — iOS-Portierung & Feinschliff ⬜
- [ ] Bundle-Identifier weg von `com.example.rootIn` (siehe Abschnitt 12)
- [ ] iOS-spezifisches Testing, Cupertino-Anpassungen wo sinnvoll
- [ ] iOS Home-Screen-Widget (WidgetKit) — auf Android seit Phase 10 fertig
- [ ] App-Icons, Splash Screen

### Phase 13 — Diagramm-Feinschliff & Tests ✅
**Gebaut am 2026-08-07.** Die beiden kosmetischen Mängel, die seit dem 2026-07-26 als offene Fragen standen, sind behoben; dazu die fehlenden Widget-Tests. Alles blieb in `core/widgets/chart_card.dart` — dem einen fl_chart-Wrapper.

- [x] **Fortschritts-Trend im Jahr-Bereich lesbar gemacht.** Ab 90 Punkten bündelt die Linie: bis 90 Tage ein Punkt je Tag, darüber Wochenmittel, ab 631 Tagen Monatsmittel. Bewusst **drei benennbare Stufen** statt einer stufenlosen Rechnung — ein Bündel aus 13 Tagen ließe sich nicht beschriften, und **ohne Beschriftung wüsste niemand, dass er keine Tageswerte mehr sieht**. Deshalb steht der Hinweis „Wochenmittel"/„Monatsmittel" im Diagramm, sobald gebündelt wird (zwei neue Schlüssel in allen drei ARB-Dateien).
- [x] **Das angebrochene letzte Bündel wird durch seine tatsächliche Länge geteilt**, nicht durch die Bündelbreite. Sonst fiele die Linie am rechten Rand grundlos ab — der laufende Teil einer Woche würde mit Tagen verdünnt, die es noch nicht gibt. Ein eigener Testfall hält das fest.
- [x] **Y-Achse des Balkendiagramms zeigt nur noch 0 und den Höchstwert.** Ein größeres Intervall allein genügte nicht: fl_chart beschriftet **zusätzlich** zum Intervall immer den oberen Rand (`maxY = maxCount + 1`), weshalb zwei Zahlen dicht übereinander standen. Erst das Verwerfen aller anderen Werte in `getTitlesWidget` löst es. `axisLabelInterval()` ist damit samt seinen zwei Tests entfallen.
- [x] **X-Beschriftungen laufen nicht mehr ineinander.** Jede Kategorie bekommt über einen `LayoutBuilder` genau ihre Spaltenbreite, zweizeilig mit Kürzung. Der Test prüft die **tatsächliche Breite** des gerenderten Labels gegen die Spaltenbreite, nicht nur, dass es da ist.
- [x] **Die Diagramm-Höhe bleibt fest bei 180** — der Hinweis steht **im** Diagramm, nicht darüber. Grund: Das Home-Screen-Widget rendert dieselben Widgets in eine Bildfläche von 320×200 (`home_widget_service.dart`); ein mitwachsendes Diagramm wäre dort abgeschnitten. Ein Testfall misst die Höhe.
- [x] **Weitere Widget-Tests** — `view_page_test.dart` (Navigation durch alle vier Tabs, leerer Bestand bricht keinen davon, Jahr-Tab zeigt den Trend als Wochenmittel) und `today_page_test.dart` (leerer Bestand, alles erledigt = 100 %, sehr langer Name ohne Überlauf, 20 Gewohnheiten bleiben scrollbar, Abhaken schlägt sofort auf Ring und Zähler durch).

**Stand danach: 184 Tests grün** (+2 übersprungen), `flutter analyze` sauber.

#### Was der Emulator-Durchgang fand (Lehre 8, schon wieder)
Nach grünen Tests wurde die Phase am Emulator mit dem vollen Bestand aus `lib/main_seed.dart` (~400 Tage) angesehen — Woche und Jahr, deutsch und persisch. Beide Diagramme sahen im Test korrekt aus; **einen echten Fehler hat erst der Blick auf das Gerät gezeigt:**

- [x] ⚠️ **Der Hinweis „میانگین هفتگی" lag auf Persisch genau auf der Beschriftung „100 %".** Ursache: `textAlign: TextAlign.end` ist **richtungsabhängig** und heißt auf Persisch links — dort steht aber die Y-Achse. fl_chart kennt keine Textrichtung, und die Diagramme bleiben auf Persisch bewusst links-läufig (Phase 18); die Achse liegt also in **jeder** Sprache physisch links. Jetzt `Alignment.centerRight` statt einer richtungsabhängigen Ausrichtung. Ein eigener Testfall in persischer Sprache misst nach, dass der Hinweis in der rechten Hälfte liegt.
- [x] **Y-Achse mit dreistelligem Wert am Gerät bestätigt:** Der Jahr-Tab zeigt `608` und `0` — sonst nichts. Genau der Fall, an dem die alte Beschriftung beim Erstellen der Store-Screenshots aufgefallen war.
- [x] **Bündelung sichtbar geprüft:** 52 Wochenpunkte statt ~365 Tagespunkten; der Aufwärtstrend im gesäten Bestand ist jetzt erkennbar statt verrauscht.
- [x] **Nebenbefund X-Achse:** Zwei lange Namen („Sprachenlernen"/„Achtsamkeit") stehen dicht beieinander. Sie überlappen **nicht** — kurze Beschriftungen stehen ohnehin in ihrer eigenen Breite mittig unter dem Balken. Vorsorglich bekommt eine Beschriftung 12 px weniger als ihre Spalte, damit ein **gekürzter** Name nicht bündig an den Nachbarn stößt.

⚠️ **Beim Schreiben der Tests aufgefallen:** `start.add(Duration(days: 91))` traf über die Sommerzeit-Umstellung hinweg **keinen** Tagesschlüssel — die Dauer landet um 01:00 Uhr statt um Mitternacht. In Tests gilt dieselbe Regel wie im Code: `addDays` statt `Duration` (siehe Phase 2). Der Test schlug deshalb zuerst fehl und hat damit genau das gezeigt, wofür er da ist.

⬜ **Offen:** Der Durchgang lief auf dem **Emulator** im Debug-Build. Ein Release-Build auf einem echten Gerät bleibt Teil von 21.3.

## 11. Entscheidungs-Log & dauerhafte Lehren

### 11.1 Log (Kurzfassung, chronologisch)
- **2026-07-19** — Projekt-Setup, Tech-Stack festgelegt, vollständig lokale Datenhaltung, Wettkampf nur per geteiltem Bild. Arbeitsweise beschlossen: phasenweise, PLAN/MAP nach jedem Schritt, Inhaltsverzeichnis-Pflicht, DRY. Phasen 0 und 1 gebaut. `sqlite3_flutter_libs` als end-of-life erkannt → `drift_flutter` + `sqlite3`. `flutter_local_notifications` verlangt Core Library Desugaring.
- **2026-07-20** — Phasen 2, 3, 4, 4.5. Matrix-Grid nimmt bewusst nur Zeitraum + Intensitäts-Map (kein DB-Zugriff) → überall wiederverwendbar. Kategorien referenzieren per **Name** statt Fremdschlüssel (kein Migrationsrisiko). Design-Token-Prinzip ausformuliert und umgesetzt. **Ursache aller Build-Abstürze gefunden: iCloud** (siehe Lehre 1).
- **2026-07-21** — Phasen 5, 5.5, 6, 7, 8, 8.5, 8.6, 9, 10. Nutzer wählt volles Drag-and-Drop-Dashboard statt Checkbox-Auswahl. Berg-Animation nach gelieferter React/SVG-Vorlage nachgebaut (Prozent statt Sprachniveaus, Kennzahl wählbar). Backup: IDs bleiben erhalten, Erinnerungen werden neu geplant; `file_picker` scheitert an win32 (Lehre 13).
- **2026-07-22/23** — Phase 10.5, dann Korrektur des Nutzers → **10.7**: fünf eigenständige Diagramm-Widgets, Auswahl auf dem Startbildschirm statt in der App. Zwei Design-Specs (~340 KB) ausgewertet; die vier Grundsatzfragen dem Nutzer vorgelegt → binäres Zustandsmodell (keine DB-Änderung), mehrere volle Farbthemes, einzelne Zellen, Intensität statt Grün/Rot. Phase 10.6a: Design-Tokens.
- **2026-07-24/25** — 10.6b (Spec-Look über `AppTheme`, dadurch alle Seiten auf einmal) und 10.6c (Ring- und Checklist-Widget).
- **2026-07-26** — Phasen 11, 11.5, 10.6d, 11.6, 14 (Code) und 15.1 abgeschlossen; Phase 15 als eigene Phase ausformuliert. Lokalisierung: Enum-Labels wurden Methoden, Achievements/Vorlagen bekamen stabile IDs, Notification-Texte bekommen die Sprache injiziert; **Nutzerdaten werden nicht mitübersetzt**. Farbkachel-Widget als einziges mit echten `RemoteViews`. Werbung: echte Anzeigen **nur** im Release-Build, Banner **einmal** in der Shell, Sichtbarkeit über **einen** Provider, bewusst keine serverseitige Kaufprüfung. `applicationId` = `com.rootin.app` inkl. Kotlin-Paketumzug. Store-Material erstellt; dabei zwei echte Fehler gefunden (Balkendiagramm-Achse bei dreistelligen Werten, Screenshot-Seitenverhältnis 2,24:1 > Play-Limit 2:1).
- **2026-07-29/30** — Phase 16 + 16.1: Übersicht-Seite. Tragende Entscheidungen: alle Maße in **einer** Datei, `Stack` mit festen Koordinaten statt Flex, Skalierung nur des Boards als Ganzes, **keine** Lücke zwischen den Wochen (sonst verrutschen fl_chart-Punkte gegen ihre Matrix-Spalte), Achsen außerhalb der Diagramme. Der Gerätelauf brachte Vollbild-Route, verzögerte Querformat-Sperre und Luft über der Y-Achse.
- **2026-07-30** — Phase 17 („Others" → Rubrik „Root-in Anleitung") und 17.1 (Texte als Markdown aus dem Repository, ohne App-Update änderbar). Dabei gefunden: **`INTERNET` stand nur im Debug-Manifest** (Lehre 5). 17.2: Persisch wählbar für Inhalte, Oberfläche vorerst deutsch — zwei getrennte Begriffe im Enum statt Sonderfällen quer durch den Code.
- **2026-08-01** — Werbung per Konstante `AdConfig.adsDisabledForEveryone` für alle aus (Vorstufe zu Phase 20). Phase 17.3: alle vier Anleitungs-Seiten gefüllt; die Dateien im Repository heißen uneinheitlich, deshalb `GuideTopic.fileName(languageCode)` mit ausdrücklicher Zuordnung statt einer Regel — eine Regel würde beim nächsten Ausreißer still die falsche Adresse bauen, und ein 404 sieht in der App aus wie „Inhalt folgt", nicht wie ein Fehler. Preis: Umbenennungen kosten eine App-Version, Textänderungen weiterhin nicht (GitHub liefert mit `max-age=300`).
- **2026-08-01 (vormittags)** — Vier neue Aufgaben aufgenommen: Persisch vollständig (18), Teilen überarbeiten (19), Werbung auskommentieren (20), Endkontrolle & Standard-Kategorien (21). Erledigte Phasen in diesem Dokument auf Kurzfassungen zusammengezogen.
- **2026-08-01 (abends, dieser Stand)** — Phasen 20, 21.1/21.2, 19 und 18 gebaut. Bewusst **in dieser Reihenfolge**: Phase 20 nimmt Code und Schlüssel weg, 21 und 19 legen neue an, und Phase 18 übersetzt zuletzt — so wurde `app_fa.arb` genau einmal geschrieben statt dreimal nachgezogen. Tragende Entscheidungen:
  - **Werbung wird auskommentiert, nicht gelöscht** (Nutzerwunsch), mit einem einheitlichen Marker als Wiederfinde-Anker. Der Kaufmerker in `shared_preferences` bleibt unangetastet, damit ein früherer Käufer beim Wiedereinschalten sofort wieder werbefrei ist.
  - **QR-Code auf der Teilen-Karte: ja** (offene Frage geschlossen). Ein Bild ist nicht anklickbar; `qr_flutter` ist reines Dart und kostet keinen Platform-Channel.
  - **Die Teilen-Karte bekommt eine feste Breite** statt der Bildschirmbreite — ein geteiltes Bild soll überall gleich aussehen. Der `Screenshot`-Knoten liegt **innerhalb** der Vorschau-`FittedBox`, sonst wäre das Bild so klein wie die Vorschau.
  - **Der Übersicht-Block kommt als fertiges Widget in die Karte**, nicht als sechs Datenfelder — so muss `core/` nichts aus `features/` importieren und das Raster entsteht weiter an einer Stelle.
  - **Ziffern bleiben westlich, auch auf Persisch** (offene Frage geschlossen, Begründung in `core/l10n/app_numbers.dart`): Das Übersicht-Board rechnet mit Textbreiten, fl_chart beschriftet selbst, die Home-Screen-Widgets folgen der Gerätesprache — und persische Ziffern haben hier schon einmal den Build gekippt (Lehre 4).
  - **Die Übersicht bleibt auch auf Persisch links-läufig.** Ein Kalender Mo–So läuft auch in persischen Kalendern links nach rechts; ein Spiegeln würde jede Koordinate in `overview_metrics.dart` umkehren.
  - **Standard-Kategorien sind Nutzerdaten.** Nichts im Code schützt sie; erkennbar sind sie nur am Symbol, das über den **Namen** zugeordnet wird — wer umbenennt, verliert es. Der Nachrüst-Knopf für Bestandsnutzer steht ohne Bedingung auf der Seite, damit er nicht unerklärt verschwindet.
  - Fünf tote ARB-Schlüssel entfernt, bevor sie Übersetzungsarbeit gekostet hätten.

- **2026-08-02** — Vier neue Aufgaben des Nutzers als Phasen 22–25 aufgenommen. Zwei Entscheidungen dabei vom Nutzer getroffen: Die Rubrik „موارد دیگر" liest ihre Struktur aus einer **`index.json`** statt aus der GitHub-API (die API listet Ordner zwar selbst auf, erlaubt aber nur 60 Abrufe pro Stunde und IP — hinter einer geteilten Mobilfunk-Adresse bliebe die Rubrik leer), und die Texte liegen **je Sprache getrennt** unter `content/others/<sprache>/`. Umsetzungsreihenfolge bewusst 25 → 24 → 23 → 22: Datenerhalt schützt, was die anderen anfassen; die größte Phase kommt zuletzt. Beim Planen geprüft und festgehalten: Ein App-Update löscht **heute schon** nichts (Drift liegt in `getApplicationDocumentsDirectory()`), die reale Gefahr ist eine Schema-Änderung ohne Migration.

- **2026-08-02 (abends)** — Phasen 25, 24, 23 und 22 gebaut, in dieser Reihenfolge. Tragende Entscheidungen:
  - **Datenerhalt ist kein Umbau, sondern ein Beweis.** Ein Update löschte noch nie etwas (Drift liegt in `getApplicationDocumentsDirectory()`); die Gefahr war eine Schema-Änderung ohne Migration. Der Migrations-Test zieht deshalb echte Bestände aus Schema 1 und 2 hoch — und prüft, dass **dieselben IDs** dastehen, nicht nur dieselbe Anzahl. `android:allowBackup` steht jetzt ausdrücklich im Manifest, damit auch ein Gerätewechsel den Verlauf mitnimmt.
  - **Getrennte Provider für „heute" und „gewählter Tag".** Die Heute-Seite darf zurückblättern, das Startbildschirm-Widget nicht — es ist eine Tagesansicht, kein Archiv. Beide rechnen über dieselbe Family (`dayProgressProvider(date)`), fragen sie aber mit verschiedenen Tagen.
  - **Ein Nachtrag verlängert die Serie rückwirkend.** Gewollt: Serien und Statistiken rechnen aus den Erledigungen. Die Datums-Prüfung im Netz bleibt unangetastet — nachtragen ja, „heute" vordatieren nein.
  - **Erinnerungstexte stehen beim Planen fest, nicht beim Anzeigen.** Deshalb zwei Bausteine statt einem: die geplante Erinnerung nennt die Serie (bei jedem Anlass neu geplant), die dauerhafte Tagesstand-Meldung ist immer aktuell. Sie hängt am **selben** Auslöser wie das Widget — ein Sender, zwei Empfänger.
  - **Der Druck kommt aus der Zahl, nicht aus dem Geräusch.** Der Tagesstand ist bewusst leise und liegt auf einem eigenen Kanal, damit man ihn abschalten kann, ohne die Erinnerungen zu verlieren.
  - **`index.json` statt GitHub-API** für „موارد دیگر" (Entscheidung des Nutzers): Die API listet Ordner zwar selbst auf, erlaubt aber nur 60 Abrufe pro Stunde und IP.
  - **Beim Verallgemeinern des Inhalts-Dienstes fiel eine Falle auf:** Der neue Zwischenspeicher-Schlüssel hätte alte Installationen offline vor eine leere Anleitung gestellt. Eine einmalige Übernahme hängt den alten Eintrag um — derselbe Gedanke wie Phase 25.

- **2026-08-07** — Phase 13 (Diagramm-Feinschliff & Tests). Damit sind die beiden ältesten offenen Fragen aus Abschnitt 12 geschlossen. Tragende Entscheidungen:
  - **Gebündelt wird in benennbaren Stufen** (Tag, Woche, Monat), nicht stufenlos. Eine Rechnung „Punktzahl durch 90" hätte Bündel aus 13 Tagen ergeben — korrekt, aber nicht beschriftbar. **Was der Nutzer nicht benennen kann, kann er nicht einordnen**, deshalb steht der Hinweis „Wochenmittel" im Diagramm, sobald es nicht mehr Tageswerte sind.
  - **Die Diagramm-Höhe bleibt fest.** Der Hinweis steht innerhalb der 180 px, weil dieselben Widgets offscreen in ein Bild von 320×200 für den Startbildschirm gerendert werden. Ein Diagramm, das mit seinem Inhalt wächst, wäre dort abgeschnitten — sichtbar erst auf dem Startbildschirm, nicht in der App.
  - **Die Y-Achse ließ sich nicht über das Intervall lösen.** fl_chart beschriftet immer zusätzlich den Rand `maxY`; erst das Filtern in `getTitlesWidget` lässt genau die zwei Zahlen stehen, die etwas aussagen. Die vorherige Lösung `axisLabelInterval()` ist ersatzlos entfallen.
  - **Geometrie wird gemessen, nicht behauptet.** Der Test zur X-Beschriftung prüft die tatsächliche Breite des gerenderten Labels gegen die Spaltenbreite. „Das Label ist da" hätte auch der überlappende Zustand bestanden.
  - **Der Emulator-Durchgang fand trotz 183 grüner Tests einen echten Fehler:** Der neue Hinweis lag auf Persisch auf der Y-Beschriftung, weil `TextAlign.end` richtungsabhängig ist, die Achse aber in jeder Sprache physisch links liegt. **Bei fl_chart ist „links" nie „start"** — die Bibliothek kennt keine Textrichtung. Lehre 8 hat sich damit zum wiederholten Mal bestätigt.

- **2026-08-07 (Phase 26)** — Web-Fassung als PWA, veröffentlicht über GitHub. Tragende Entscheidungen:
  - **Die Grenze wurde vorab benannt, nicht hinterher.** Der Auftrag verlangte „niemand soll den Code nachbauen können". Im Web ist das unerreichbar, und eine Zusage, die nicht hält, wäre schlimmer als eine klare Absage. Der Plan sagt es im Kopf der Phase, das Bau-Skript sagt es an jedem Schalter, `app_config.dart` sagt es dort, wo jemand den ersten Schlüssel eintragen würde. **Geliefert ist das Erreichbare; behauptet wird nichts darüber hinaus.**
  - **Plattform-Weichen heißen nach Fähigkeiten, nicht nach Plattformen.** `supportsReminders` statt `!kIsWeb`. Der Aufrufer will wissen, ob es Erinnerungen gibt — nicht, wo er läuft. Ergebnis: `kIsWeb` steht an **einer** Stelle im ganzen Projekt.
  - **Die beste Weiche ist keine Weiche.** Sicherung und Bild-Teilen bekamen keinen Web-Sonderfall, sondern verloren ihren Plattform-Anteil ganz: `share_plus` nimmt mit `XFile.fromData` die Bytes direkt. `dart:io` und `path_provider` fielen dabei aus zwei Dateien heraus, und alle drei Plattformen gehen jetzt denselben Weg. **Der Web-Auftrag hat den mobilen Code vereinfacht, nicht verkompliziert.**
  - **Kein `gh-pages`-Zweig, obwohl so geplant.** GitHub Pages nimmt heute ein Artefakt direkt aus der Automatik; ein zweiter Zweig hätte das Bauergebnis doch wieder in die Versionsgeschichte geschrieben — genau das, was vermieden werden sollte.
  - **Ein Bau-Skript, das beide benutzen.** Automatik und Nutzer rufen dasselbe `tool/build_web.sh`. Zwei Listen von Flags laufen auseinander, und dann ist der veröffentlichte Bau nicht der geprüfte.
  - **Die Kontrolle vor dem ersten Commit hat zwei Dinge gefunden**, die mitgegangen wären: das Arbeitsmaterial in `meine/` und `.claude/settings.local.json` mit hunderten absoluten Pfaden unter `/Users/<name>/`. Bei einem ersten Commit lohnt der Blick in die Dateiliste — danach steht alles dauerhaft in der Geschichte.

### 11.2 Dauerhafte Lehren & Fallstricke
1. **iCloud bricht Code-Signing.** Das Flutter-SDK lag auf iCloud Drive; `taskgated` killte die Binaries sporadisch (`SIGKILL`, per Crash-Report belegt). Das war die Wurzel von „Dart compiler exited unexpectedly", `ShaderCompilerException` und den native-asset-Fehlern — **nicht** Arbeitsspeicher. SDKs nach `~/development/`, Projekte nach `~/Projects/`. Bei Build-Abstürzen zuerst `~/Library/Logs/DiagnosticReports/` lesen.
2. **PATH in der Bash-Tool-Shell ist eingefroren.** Flutter/Dart immer mit vollem Pfad aufrufen: `"$HOME/development/flutter/bin/flutter"`.
3. **`keytool`, `java`, `adb` fehlen im PATH.** JDK: `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/`, adb: `~/Library/Android/sdk/platform-tools/adb`.
4. **Systemsprache `fa_AT` kippt den AAB-Build.** Die JVM erbt persische Ziffern, `bundletool` erwartete `classes۲.dex`. Fix steht in `android/gradle.properties`: `-Duser.language=en -Duser.country=US`. Betraf **nur** den Release-AAB.
5. **`INTERNET` gehört ins Haupt-Manifest.** Flutter legt sie nur in Debug/Profile an — im Release schlägt sonst jede Anfrage fehl, still.
6. **`container.read(streamProvider.future)` ohne Zuhörer hängt für immer.** Riverpod verwirft den Provider sofort. Lösung: `_awaitAlive` in `home_widget_service.dart` bzw. eine eigene `listen`-Subscription.
7. **ARGB-Farben passen nicht in einen Android-`Int`.** Werte über `Int.MAX_VALUE` landen als `Long` → `ClassCastException` in Kotlin. Immer `.toSigned(32)` schreiben.
8. **Der Gerätelauf findet, was Tests nicht finden:** verfügbarer Platz, Drehung, Theme-Wechsel, Überläufe, fehlendes Clipping. Ein Render-Test beweist Geometrie — nicht Benutzbarkeit.
9. **Drift-Details:** `uniqueKeys` auf (habitId, date) nötig; Teil-Updates mit `.write()` statt `.replace()`; Tests gegen eine In-Memory-DB (`test/support/test_database.dart`) plus `disposeAndFlush(tester)`, sonst „Timer is still pending".
10. **`pumpAndSettle()` ist auf der Home-Seite verboten** — die funkelnden Sterne laufen dauerhaft. Stattdessen `pump(duration)`; für Routenwechsel drei aufeinanderfolgende `pump()`.
11. **Nutzerdaten werden nicht mitübersetzt.** Namen von Gewohnheiten und Kategorien speichern den Text der Sprache zum Zeitpunkt des Anlegens; ein späterer Sprachwechsel lässt sie unangetastet.
12. **Play-Formalitäten:** Screenshots höchstens 2:1; In-App-Produkte erst anlegbar, wenn ein Bundle mit Billing in einem Track liegt; `com.example.*` wird abgelehnt; Signaturschlüssel-Verlust = keine Updates mehr.
13. **`file_picker` ist eine Sackgasse** (verlangt `win32 ^5`, `share_plus 13` will `^6`; ein Override bricht `flutter test`). Genutzt wird `flutter_file_dialog` (nur Android/iOS — genau die Zielplattformen).
14. **Vor größeren Android-Builds `df -h /System/Volumes/Data` prüfen** — der Datenträger lief schon einmal während der Verifikation voll.
15. **`sips` schreibt ohne `-s format png` weiterhin JPEG**, auch bei `.png`-Endung; Play weist so eine Datei zurück.
16. **Der Android-Manifest-Merger übernimmt XML-Kommentare wortgetreu.** Ein `grep AD_ID` im zusammengeführten Manifest findet deshalb auch auskommentierte Blöcke — es sieht aus, als wäre nichts entfernt worden. Richtig geprüft wird XML-bewusst (Kommentare verwerfen, `uses-permission`/`meta-data` auslesen) oder direkt im AAB unter `base/manifest/AndroidManifest.xml`: Das ist Protobuf und enthält gar keine Kommentare mehr. Genau daran wäre die Verifikation von Phase 20 fast falsch beantwortet worden.
17. **Eine vollständig auskommentierte Test-Datei ist ein Ladefehler**, kein „keine Tests": `flutter test` verlangt ein `main()`. Wer eine Datei stilllegt statt sie zu löschen, lässt einen mit `skip:` übersprungenen Platzhalter-Fall stehen — der hält den Grund im Testlauf sichtbar.
18. **Eine `Row` mit vielen Kennzahlen läuft irgendwann über.** Auf der schmalen Fortschritts-Karte waren es 169 px, unsichtbar in der Vorschau und abgeschnitten im geteilten Bild. `Wrap` statt `Row`, und ein Test, der `tester.takeException()` prüft — gefunden hat es der Test, nicht das Auge.
19. **Drift-Abfragen mitten im Widget-Test hängen.** Drift liefert Stream-Ergebnisse über einen Timer, und im Widget-Test steht die Uhr still — ein blankes `await stream.first` läuft in den Timeout, ohne Fehlermeldung. Lösung: `await tester.runAsync(() async { … })`, oder gleich ein reines `test(...)` mit `ProviderContainer`, wo kein Widget-Baum nötig ist.
20. **`flutter analyze` löst `gen-l10n` nicht aus.** Neue ARB-Schlüssel erscheinen deshalb als „undefined getter", obwohl die Datei stimmt. Nach jeder ARB-Änderung `flutter gen-l10n` laufen lassen (oder einfach bauen) — sonst sucht man den Fehler an der falschen Stelle.
21. **`FlutterLocalNotificationsPlugin` lässt sich im Test nicht ersetzen** (privater Konstruktor) und der Plattform-Kanal nicht auflösen. Wer Notification-**Logik** prüfen will, zieht sie in ein reines Wertobjekt heraus (siehe `DailyStatusMessage`); die Zustellung bleibt deklarative Konfiguration für den Gerätedurchgang.
22. **Ein umbenannter `shared_preferences`-Schlüssel ist ein Datenverlust auf Raten.** Beim Umbau von `guide_md_*` auf `repo_content_*` (Phase 22) wären die gespeicherten Anleitungs-Texte alter Installationen unerreichbar geworden — sie lägen noch da, nur unter einem Namen, den niemand mehr abfragt, und der Nutzer stünde offline vor einer leeren Seite. Beim Umbenennen von Prefs-Schlüsseln **immer** eine einmalige Übernahme einbauen (alten Wert lesen, umhängen, alten Schlüssel räumen).
23. **`Duration(days: n)` ist keine Datumsarithmetik — auch nicht im Test.** Über eine Sommerzeit-Umstellung hinweg landet `start.add(const Duration(days: 91))` um 01:00 Uhr statt um Mitternacht und trifft damit **keinen** Schlüssel einer nach Tagen indizierten Map. Der Testfall zu Phase 13 fiel genau darauf herein. Im App-Code galt die Regel seit Phase 2 (`addDays`); in Tests gilt sie genauso.
24. **fl_chart beschriftet immer zusätzlich den Achsenrand.** `interval` steuert nur die Zwischenschritte; `maxY` bekommt in jedem Fall ein Label. Wer genau bestimmte Werte an der Achse haben will, filtert in `getTitlesWidget` und verlässt sich nicht auf das Intervall (Phase 13). `interval` darf außerdem nie 0 sein.
25. **Rund um ein Diagramm ist „links" nie „start".** fl_chart kennt keine Textrichtung und zeichnet die Y-Achse immer physisch links; die Diagramme bleiben auf Persisch bewusst links-läufig (Phase 18). Beschriftungen daneben deshalb mit `Alignment.centerRight`/`TextAlign.right` setzen, **nicht** mit den richtungsabhängigen Varianten — sonst landet der Text auf Persisch auf der Achse (am Gerät gefunden, Phase 13).
26. **Im Web gibt es keinen Code-Schutz, nur Code-Unlesbarkeit.** `--obfuscate` wirkt nicht für Web-Bauten; `dart2js` minimiert, mehr nicht. Was der Browser ausführt, kann der Browser lesen — auch bei WebAssembly. Ein `--dart-define` ist keine Verschlüsselung, sondern nur ein Weg, den Wert aus dem Repository zu halten. **Was geheim bleiben muss, gehört hinter einen Server** (Phase 26.4/26.5).
27. **Ein Browser-Datei-Dialog meldet den Abbruch nicht über `change`.** Bricht der Nutzer ab, feuert nur `cancel` — ohne dieses Ereignis bleibt das Future für immer offen und die Oberfläche hängt in einem Ladezustand ohne Ende (Phase 26.1).
28. **`--base-href` entscheidet auf GitHub Pages über weiß oder App.** Die Seite liegt unter `/<repository>/`, nicht im Wurzelverzeichnis; mit dem Standardwert sucht sie ihre Dateien eine Ebene zu hoch und zeigt nichts an — ohne Fehlermeldung (Phase 26.3).

## 12. Offene Fragen
- ~~Balkendiagramm: Y-Achse doppelt beschriftet, X-Beschriftungen überlappen~~ · ~~Fortschritts-Trend im Jahr unlesbar~~ — **beide mit Phase 13 am 2026-08-07 erledigt.**
- **iOS-Bundle-Identifier ist weiterhin `com.example.rootIn`** — wird in Phase 12 entschieden, sinnvollerweise passend zu `com.rootin.app`.
- **Sicherungskopie des Signaturschlüssels steht aus.** Die `.jks` existiert nur einmal auf diesem Mac. Datei **und** Passwort gehören in den Passwortmanager.
- **Sollen neue Beiträge in „موارد دیگر" gemeldet werden?** Eine Push-Benachrichtigung bräuchte einen Server und widerspricht Abschnitt 3. Möglich wäre ein stiller Vergleich beim App-Start (neue Einträge im `index.json` gegenüber dem gespeicherten Stand) und ein Punkt am Einstellungs-Eintrag — ohne Server, ohne Push. Offen, ob gewünscht.
- **Direkt in die Telegram-Gruppe teilen?** Die Anleitung nennt eine Gruppe (`https://t.me/+HWnUGduPj840OGQ0`). Ein eigener Knopf „In die Gruppe teilen" wäre möglich; das System-Share-Sheet deckt es aber ab. Offen, ob es den Sonderweg wert ist.
- **Farbe je Kategorie?** Heute trägt die Gewohnheit die Farbe. Kategorie-Farben würden Diagramme und Übersicht klarer machen, kosten aber eine DB-Spalte. Das **Symbol** gibt es seit Phase 21 — allerdings nur für die sieben Standard-Kategorien und nur über den Namen zugeordnet; eigene Kategorien bekommen ein neutrales Symbol.
- Preis für „Werbung entfernen" — mit Phase 20 gegenstandslos, wird erst beim Wiedereinschalten gebraucht.
- **Die persische Übersetzung ist ein Entwurf.** Alle 233 Schlüssel sind gefüllt und der Generator meldet nichts, aber gelesen hat sie noch kein Muttersprachler. Der Nutzer geht sie durch; Korrekturen betreffen nur `lib/l10n/app_fa.arb`.
- **Persische Store-Sprache anlegen?** Die Texte stehen in `store/PLAY_LISTING.md`. Nötig nur, wenn in persischsprachigen Ländern beworben wird — dann fehlen zusätzlich vier persische Screenshots.
- Genaues Farbschema/Branding und die konkrete Punkte-Gewichtung je Habit (fix vs. nach Dauer/Schwierigkeit) sind weiterhin offen.
- App-Name „Root-in" final? (interner Paketname: `root_in`, applicationId `com.rootin.app` ist festgelegt)
- **Widget-Labels in der Launcher-Auswahl** folgen der **Geräte**-Sprache, nicht der App-Sprache (Android-Ressourcen). Eine `values-en/`-Variante hülfe englischen Geräten, eine `values-fa/` persischen; die in der App gewählte Sprache erreicht sie erst über die Per-App-Language-API (Android 13+). **Bewusst offen gelassen (2026-08-01):** Es lohnt sich nur zusammen — eine einzelne Sprache nachzurüsten macht die Uneinheitlichkeit sichtbarer, nicht kleiner. Die Entscheidung gehört dem Nutzer.
- **Piktogramm auf der Farbkachel ist für alle Gewohnheiten gleich** — ein Mapping `iconKey` → Android-Vektor müsste doppelt gepflegt werden. Alternative: Anfangsbuchstabe oder ein vom Nutzer gewähltes Emoji.
- **Home-Animation als Lottie-Datei:** Slot ist verdrahtet (`AppAssets.homeAnimation`), ein Nutzer-Asset liegt nicht vor — bis dahin läuft die gemalte Berg-Szene.
- Weitere Sprachen über DE/EN/FA hinaus? Das Gerüst trägt sie (neue `app_<code>.arb` + Eintrag in `AppLanguage`), Bedarf gibt es noch nicht.

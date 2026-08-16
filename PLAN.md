# Root-in — Habit Maker / Routine Tracker — Projektplan

> Lebendiges Dokument. Wird bei jeder relevanten Änderung am Projekt aktualisiert.
>
> **Stand 2026-08-16.** Android-Code fertig und signiert · Web-Fassung live unter `lukasylilli.github.io/Root-in/` · **189 Tests grün**, `flutter analyze` sauber.
>
> 🔄 **Aktuell in Arbeit: [Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-).** Vom Nutzer am 2026-08-16 beauftragt. ⚠️ **Diese Phase kehrt Abschnitt 3 um** — Root-in war von Tag eins „vollständig lokal, kein Backend, keine Nutzerkonten". Was daran hängt, steht in 27.0.
>
> ⬜ **Sonst offen:** Gerätedurchgang (21.3) · Play-Veröffentlichung (15, führt der Nutzer selbst durch) · iOS nativ (12) · Bestätigung der Behebung aus 26.13 auf einem echten iPhone.

> ⚠️ **Umgebungs-Grundregel dieser Maschine:** Nie Code/SDKs/Dev-Tools unter `~/Desktop` oder `~/Documents` speichern — iCloud „Schreibtisch & Dokumente"-Sync ist hier aktiv und bricht Code-Signing für Binaries (Lehre 1). Immer `~/Projects/<name>` für Projekte, `~/development/<tool>` für SDKs.

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
    - 10.1 [Erledigte Phasen (Kurzfassung)](#101-erledigte-phasen-kurzfassung) — Phasen 0–11.6, 13, 14, 15.1/15.2, 16–26 ✅
    - 10.2 [Festlegungen aus erledigten Phasen, die man noch braucht](#102-festlegungen-aus-erledigten-phasen-die-man-noch-braucht)
    - **Offene Phasen:**
      - [Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-) 🔄 **aktuell**
      - [Phase 21.3 — Gerätedurchgang](#phase-213--gerätedurchgang-) ⬜
      - [Phase 15 — Veröffentlichung im Google Play Store](#phase-15--veröffentlichung-im-google-play-store-android-) 🔄
      - [Phase 26 — Web-Fassung: was noch offen ist](#phase-26--web-fassung-was-noch-offen-ist-) 🔄
      - [Phase 12 — iOS-Portierung](#phase-12--ios-portierung-) ⬜
11. [Entscheidungs-Log & dauerhafte Lehren](#11-entscheidungs-log--dauerhafte-lehren)
    - 11.1 [Log (Kurzfassung)](#111-log-kurzfassung) · 11.2 [Dauerhafte Lehren & Fallstricke](#112-dauerhafte-lehren--fallstricke) (1–34)
12. [Offene Fragen](#12-offene-fragen)

## 1. Vision
App zum Aufbauen und Verfolgen von Gewohnheiten/Routinen. Nutzer legen Habits an, haken sie täglich ab, sehen Streaks/Statistiken, bekommen Erinnerungen und werden durch kleine Gamification-Elemente motiviert, dranzubleiben. Inhaltlicher Schwerpunkt: Sprachenlernen (siehe Anleitungs-Rubrik und Standard-Kategorien).

## 2. Zielplattformen
- **Android** — primäres Zielsystem, Code fertig und signiert
- **Web als PWA** (seit Phase 26) — der Ersatzweg auf das iPhone, solange keine App-Store-Veröffentlichung möglich ist. Über Safari → „Zum Home-Bildschirm" ablegen
- **iOS nativ** (Phase 12) — bleibt das Ziel, die Web-Fassung ist die Überbrückung
- Desktop-Ordner (`macos/`, `linux/`, `windows/`) bleiben ungenutzt

## 3. Datenhaltung

⚠️ **Dieser Abschnitt ändert sich mit Phase 27.** Bis dahin gilt die linke Spalte; sie beschreibt den **gebauten** Stand.

| | Bis Phase 26 (gebaut) | Ab Phase 27 (geplant) |
|---|---|---|
| Ort der Daten | ausschließlich auf dem Gerät | Gerät **bleibt die Quelle der Wahrheit**, zusätzlich eine Kopie auf dem Server |
| Nutzerkonten | keine | **freiwillig** — ohne Konto läuft die App unverändert weiter |
| Backend | keins | Supabase (Postgres + Auth), kostenloser Tarif |
| Netzzugriff | Datums-Verifikation, Anleitungs-Texte | zusätzlich Anmeldung und Cloud-Sicherung |

**Unverändert gültig, auch nach Phase 27:**
- **Lokal zuerst.** Die App muss ohne Internet und ohne Konto vollständig benutzbar bleiben. Der Server ist eine **Kopie**, keine Voraussetzung.
- Lokale Datenbank: Drift (SQLite); Key-Value (Profil, Einstellungen): `shared_preferences`
- Sicherung/Export: JSON über Dateisystem bzw. Share-Sheet
- „Wettkampf" zwischen Nutzern läuft **nicht** über einen Server, sondern über geteilte **Bilder** des Fortschritts (Telegram-Gruppe, siehe Anleitung „Lernplanung"). Bestätigt 2026-07-19, unverändert.

## 4. Tech-Stack
| Bereich | Wahl | Begründung |
|---|---|---|
| State Management | flutter_riverpod | Testbar, kein BuildContext nötig |
| Navigation | go_router | Deklarative Routen, Bottom-Nav + verschachtelte Tabs |
| Lokale DB | drift + drift_flutter + sqlite3 | SQL für Streaks/Statistik. `sqlite3_flutter_libs` bewusst nicht (end-of-life) |
| Key-Value | shared_preferences | Profil, Einstellungen |
| **Backend** | **supabase_flutter** 🚧 | **Phase 27** — Postgres + Auth + RLS, kostenloser Tarif. Einzelheiten und Risiken dort |
| Netzzugriff | http + http_parser | **Kein `dart:io`** (Lehre 30) — es übersetzt für den Browser und wirft dort |
| Diagramme | fl_chart | Balken/Linie/Kreis; Wrapper ausschließlich in `chart_card.dart` |
| Matrix-Grid | eigene Komponente | Volle Design-Kontrolle, überall wiederverwendbar |
| Home-Animation | eigener CustomPainter (+ lottie als Slot) | Berg-Szene ohne Asset-Abhängigkeit |
| Teilen | share_plus + screenshot | Share-Sheet für App-Link und Fortschritts-Bild |
| QR-Code | qr_flutter | Store-Link auf der Fortschritts-Karte. Reines Dart, kein Platform-Channel |
| Externe Links | url_launcher | Kontakt, Anleitungs-Links |
| Datei-Auswahl | flutter_file_dialog | **bewusst nicht `file_picker`** (Lehre 13) |
| Notifications | flutter_local_notifications (+ timezone, flutter_timezone) | Lokale Erinnerungen (nicht im Web) |
| Home-Screen-Widget | home_widget | Android App Widgets, später iOS WidgetKit |
| Lokalisierung | flutter gen-l10n (ARB) + flutter_localizations | DE/EN/**FA** inkl. RTL, 259 Schlüssel je Sprache. `intl` bleibt auf `^0.20.2` (SDK-Pin) |
| Markdown | flutter_markdown_plus | Anleitungs-Texte; Vorgänger ist discontinued |
| Werbung / In-App-Kauf | ~~google_mobile_ads~~ · ~~in_app_purchase~~ | **Seit Phase 20 vollständig auskommentiert** |
| Design | Material 3 | Konsistent mit Flutter-Standard |
| Tests | flutter_test, mocktail | Unit- und Widget-Tests |

## 5. App-Struktur / Seiten

**5.1 Home** — Berg-Fortschritts-Animation (Kennzahl wählbar), Prozent & Punkte, individualisierbares Widget-Dashboard, Knopf „Fortschritt teilen".

**5.2 Heute** — Tagesring-Kopf, **wählbares Datum** (Pfeile, Auswahl, zurück auf heute; Zukunft gesperrt), Liste der Gewohnheiten mit Abhaken/Minuten, „+"-Button, Menü Bearbeiten/Löschen.

**5.3 View** (Tabs Woche / Übersicht / Monat / Jahr) — Woche/Monat/Jahr je ein individualisierbares Dashboard; **Übersicht** = die letzten vier Kalenderwochen als **eine** quer liegende Bühne mit festem Raster, Vollbild-Knopf, Querformat-Sperre.

**5.4 Einstellungen** — Sprache, Darstellungsmodus, Farb-Variante, Quelle der Berg-Animation · Konto, Kategorien, Erinnerungen · App teilen, Sicherung exportieren/importieren, Kontakt · Rubrik **Root-in Anleitung** (vier Themen) · Eintrag **موارد دیگر** direkt darunter. 🚧 **Phase 27 ergänzt hier die Rubrik „Konto & Cloud".**

**5.5 Konto** — Profil (heute nur ein Name, lokal), Achievements-Grid, längste Serie, Gesamt-Statistik, Dashboard über den gesamten Verlauf, „Fortschritt teilen" (bleibt hier — die Anleitung „Lernplanung" verweist ausdrücklich darauf).

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

**Punkte & Prozent** — jede Seite zeigt Fortschritt in beidem. **Matrix-Grid** — wiederverwendbare Heatmap (Zellen = Tage, Intensität = Erledigungsgrad). **Diagramme** — Typ-Diagramm je Kategorie + Fortschritts-Trend, via `chart_card.dart`. **Streak** — aktuelle + längste Serie, 1 Tag pro Woche darf ausgelassen werden. **Achievements** — 11 vordefinierte. **Teilen** — App teilen (Text + Store-Link) und Fortschritt teilen (Bild mit fester Breite, Übersicht-Block, QR-Code). **Store-Link** — `core/constants/app_links.dart` ist die einzige Quelle. **Home-Animation** — Berg-Aufstieg, über `AppAssets.homeAnimation` gegen ein Lottie-Asset tauschbar. **Kategorien** — jede Gewohnheit gehört zu genau einer; die Liste verwaltet der Nutzer.

## 8. Architektur-Prinzip
Feature-first (Dateien im Einzelnen: MAP.md):
- `core/` — Services, Theme, Utils, Konstanten, geteilte Widgets
- `data/` — Drift-Datenbank, DAOs, Repository, Modelle
- `features/<feature>/` — Screens, Widgets, Provider (home, today, view, habits, settings, guide, account, categories, others, onboarding; 🚧 Phase 27: `auth`)

## 9. Arbeitsweise & Konventionen

**Schrittweiser Aufbau** — phasenweise, nicht alles auf einmal. Nach jedem wesentlichen Schritt werden PLAN.md und MAP.md aktualisiert.

**Inhaltsverzeichnis-Pflicht** — jede `.md`-Datei beginnt mit einem Inhaltsverzeichnis. Gilt **nicht** für `.dart`-Dateien (eine Datei = eine Verantwortung, Navigation über MAP.md).

**„Puzzling" / DRY** — für jede wiederkehrende Sache genau **eine** Datei/Klasse (Farben, Styles, Buttons, Dialoge, Diagramme, Services). Andere Stellen referenzieren sie.

**Design-Token-Prinzip** — jeder Design-Aspekt hat seine eigene Datei (`app_colors`, `app_theme_tokens`, `app_theme_variant`, `app_fonts`, `app_text_styles`, `app_spacing`, `app_theme`, `app_button`); der Nutzer-Zustand liegt in `settings_service.dart`, die Sprachen in `core/l10n/app_language.dart`. Eine Änderung zieht durch die ganze App.

**Plattform-Weichen heißen nach Fähigkeiten, nicht nach Plattformen** — `supportsReminders` statt `!kIsWeb`. **`kIsWeb` steht an genau einer Stelle**: `core/utils/platform_support.dart`.

**Datenerhalt geht vor** — die Datenbank ist Nutzereigentum. **Jede Änderung an `schemaVersion` braucht im selben Schritt einen `onUpgrade`-Zweig und einen Migrations-Test.** Fehlt er, startet die App nach dem Update nicht mehr auf dem alten Bestand — vom Nutzer aus gesehen dasselbe wie Datenverlust.

**Verifizieren statt annehmen** — „Build erfolgreich" ist kein Beweis. Ergebnisse werden gegengeprüft (Signatur des Bundles, Inhalt geschriebener Widget-Daten, Bildschirmfoto vom Gerät). Ein neuer Oberflächen-Test wird **einmal gegen den kaputten Stand gehalten** (Lehre 32).

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

**Stand danach: 189 Tests grün** (+2 bewusst übersprungen), `flutter analyze` sauber, Release-Bundle signiert und hochladbar, Web-Fassung veröffentlicht.

### 10.2 Festlegungen aus erledigten Phasen, die man noch braucht

Die Langfassungen sind eingedampft; was hier steht, braucht man beim Weiterbauen. Alles Übrige steht im Code und in Abschnitt 11.

**Persisch (18).** Persisch ist vollwertige Oberflächen-Sprache. **Ziffern bleiben westlich** (Begründung in `core/l10n/app_numbers.dart`, dort liegt auch die einzige Prozent-Formatierung). **Übersicht, Diagramme und Berg-Animation bleiben links-läufig** — ein Kalender Mo–So läuft auch in persischen Kalendern so, und ein Spiegeln würde jede Koordinate in `overview_metrics.dart` umkehren. Schriftart bleibt die Plattform-Schrift; zeigt ein Gerät Kästchen, ist `app_fonts.dart` der eine Ort. ⬜ Die Übersetzung ist ein **Entwurf** — der Nutzer geht sie als Muttersprachler durch.

**Teilen (19).** Knopf auf Home **und** Konto, beide öffnen `showShareProgressSheet()`. Der Konto-Weg musste bleiben, weil die Anleitung „Lernplanung" ihn wörtlich beschreibt. Die Karte hat eine **feste Breite**; der `Screenshot`-Knoten liegt **innerhalb** der Vorschau-`FittedBox`, sonst wäre das Bild so klein wie die Vorschau. Den Übersicht-Block bekommt sie als **fertiges Widget**, damit `core/` nichts aus `features/` importiert.

**Werbung stillgelegt (20).** Alles auskommentiert, nichts gelöscht; jede Stelle trägt den Marker `PHASE 20 (2026-08-01)`. Wiedereinschalten ist ein `grep`. Der Kaufmerker in `shared_preferences` bleibt unangetastet. ⬜ **Der veröffentlichte Gist der Datenschutzerklärung ist noch nicht nachgezogen** (Phase 15).

**Standard-Kategorien (21).** Entstehen beim Erststart in der gewählten Sprache (`ensureDefaultCategories`, nur bei leerer Tabelle); `addMissingCategories` rüstet Bestandsnutzer nach. Sie sind **Nutzerdaten** — nichts im Code schützt sie; das Symbol wird über den **Namen** zugeordnet, wer umbenennt verliert es.

**„موارد دیگر" (22).** Struktur aus `content/others/<sprache>/index.json`, **nicht** aus der GitHub-API (60 Abrufe/Stunde je IP — hinter einer geteilten Mobilfunk-Adresse bliebe die Rubrik leer). **Kein Rückfall zwischen Sprachen.** Vier Fehlerfälle sichtbar unterschieden: kein Netz · Manifest fehlt · Manifest kaputt (der Autor soll erfahren, dass **seine Datei** das Problem ist) · einzelner Text fehlt. Pflege-Anleitung: `store/OTHERS_CONTENT.md`. ⚠️ GitHub liefert mit `max-age=300` — bis zu fünf Minuten Verzögerung nach dem Hochladen.

**Erinnerungen (23).** `flutter_local_notifications` legt den Text **beim Planen** fest, nicht beim Anzeigen — deshalb **zwei** Bausteine: die geplante Erinnerung nennt die Serie (bei jedem Anlass neu geplant), die dauerhafte Tagesstand-Meldung ist immer aktuell und hängt am **selben** Auslöser wie das Startbildschirm-Widget (ein Sender, zwei Empfänger). Der Tagesstand ist bewusst leise und liegt auf einem eigenen Kanal: **Der Druck kommt aus der Zahl, nicht aus dem Geräusch.**

**Datum nachtragen (24).** `selectedDateProvider` ist der eine Schalter; dahinter ein **Override** (`null` = heute), damit die Seite über Mitternacht von selbst weiterspringt. Startbildschirm-Widget und Karte bleiben auf heute (getrennte Provider über dieselbe Family). ⚠️ **Ein Nachtrag verlängert die Serie rückwirkend** — gewollt. Die Datums-Prüfung im Netz bleibt unangetastet: nachtragen ja, „heute" vordatieren nein.

**Datenerhalt (25).** Ein Update löschte noch nie etwas (Drift liegt in `getApplicationDocumentsDirectory()`); die Gefahr war eine Schema-Änderung ohne Migration. Der Migrations-Test zieht echte Bestände aus Schema 1 und 2 hoch und prüft, dass **dieselben IDs** dastehen — eine Migration, die Gewohnheiten neu anlegt statt sie zu behalten, würde jede Erledigung von ihrer Gewohnheit trennen. Der vierte Testfall ist eine **Bremse**: Er hält `schemaVersion` auf dem geprüften Wert fest.

**Web-Fassung (26).** Drift auf WebAssembly (`sqlite3.wasm` + `drift_worker.js`, von `tool/fetch_web_db_assets.sh` geholt). **Die beste Weiche ist keine Weiche** — Sicherung und Bild-Teilen verloren ihren Plattform-Anteil ganz, statt einen Web-Sonderfall zu bekommen. **Ehrlich abschalten statt still scheitern**: Ohne Erinnerungen verschwinden die zugehörigen Bedienelemente ganz. Bau-Schalter stehen ausschließlich in `tool/build_web.sh` — die Automatik ruft dasselbe Skript. **Kein `gh-pages`-Zweig**: Pages nimmt das Artefakt direkt entgegen, damit landet das Bauergebnis nie in der Versionsgeschichte.

**Was die vier Web-Fehler waren (26.10–26.13)** — die Ursachen stehen als Lehren 30–34; hier nur das Ergebnis: `dart:io` ist vollständig aus `lib/` verschwunden (`package:http` überall), die Web-Symbole kommen aus derselben Quelle wie die Android-Symbole, und `web/index.html` trägt **kein** `viewport-fit=cover` und `default` statt `black-translucent`. `tool/webtest.py` prüft seither **17 Punkte** inklusive aller vier Reiter und einer Anleitungs-Seite — und wurde am kaputten Stand rot gemessen, bevor er am reparierten grün wurde.

---

### Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase) 🔄
**Vom Nutzer am 2026-08-16 beauftragt:** *„اطلاعات حساب کاربر اینجا ذخیره بشه — Supabase … اینجوری ی سرور داریم که رایگان و اتوماتیک اطلاعات کاربران رو ذخیره میکنه."* Ein Server, der die Nutzerdaten kostenlos und automatisch aufbewahrt.

#### 27.0 Was diese Phase umkehrt — vor dem ersten Handgriff lesen

⚠️ **Root-in war von Tag eins „vollständig lokal, kein Backend, keine Nutzerkonten".** Dieser Satz steht nicht nur in Abschnitt 3, sondern trägt eine Kette von Entscheidungen. Was daran hängt:

| Betroffen | Heute | Nach Phase 27 |
|---|---|---|
| Abschnitt 3 | „kein Backend, keine Nutzerkonten" | Server als **Kopie**, Konto **freiwillig** |
| `store/PRIVACY_POLICY.md` | „Daten verlassen das Gerät nicht" | muss die Server-Speicherung nennen — **und der Gist muss nachgezogen werden** (er aktualisiert sich nicht von selbst) |
| Play-Datensicherheitsformular | „keine Daten erhoben" | **wird falsch** — Konto und Nutzerdaten sind zu deklarieren |
| Phase 22 | „kein Rückkanal, das wäre ein Server" | der Server existiert dann; die Entscheidung bleibt trotzdem, siehe Abschnitt 12 |
| Phase 26.5 | „Root-in hat heute keine Geheimnisse" | der `anon`-Schlüssel kommt ins Bundle (kein Geheimnis, siehe 27.3), der `service_role`-Schlüssel **niemals** |

⚠️ **Die Datenschutz-Anpassung ist nicht der letzte Schritt, sondern eine Bedingung der Veröffentlichung.** Ein Store-Eintrag mit „keine Daten erhoben" und einer App, die Daten hochlädt, ist eine Falschangabe gegenüber Google. **Phase 15 darf erst weitergehen, wenn 27.8 erledigt ist.**

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
- [ ] `tool/build_web.sh` und der Android-Bau reichen die Werte durch; als **GitHub-Actions-Secrets** hinterlegen. *(Erst nach 27.2 — vorher gibt es nichts durchzureichen.)*

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
- [ ] ⚠️ **Offen und nicht zu vergessen:** „Konto löschen" kann der `anon`-Schlüssel nicht auslösen — der Eintrag in `auth.users` braucht erhöhte Rechte (Edge Function). Solange es die nicht gibt, löscht die App nur Daten und meldet ab; der leere Auth-Eintrag bleibt. **Für 27.8 zu klären.**

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
- [ ] `features/auth/presentation/` — Registrieren (drei Felder), Anmelden (zwei), Zustands-Provider.
- [ ] ⚠️ **Reihenfolge bei der Registrierung, und was schiefgehen kann:** Erst `signUp(email, password)`, **dann** die Profilzeile mit dem Benutzernamen (die braucht die Kennung, die es erst danach gibt). Ist der Name schon vergeben, existiert das Konto bereits, die Profilzeile aber nicht — **kein kaputter Zustand, aber einer, der behandelt werden muss**: Die Oberfläche fragt nach einem anderen Namen, `claimUsername()` schreibt ihn nach. Das Konto darf dabei **nicht** gelöscht werden; nur der Name fehlt.
- [ ] **Verfügbarkeit vorab prüfen** über `username_available()` — reine Höflichkeit. ⚠️ **Die Wahrheit ist der eindeutige Index der Datenbank**: Zwischen Frage und Absenden kann ein anderer denselben Namen nehmen. Bei Zweifeln antwortet die Abfrage „frei" — ein Formular, das wegen einer wackligen Verbindung „vergeben" behauptet, hält jemanden von seinem eigenen Namen ab.
- [ ] **„Passwort vergessen" ist vorgesehen**, funktioniert aber erst mit eigenem SMTP (27.2). ⚠️ Solange es das nicht gibt, darf der Knopf **nicht** dastehen und ins Leere greifen — dieselbe Regel wie bei den Erinnerungen im Browser (26.1).
- [ ] Rubrik **„Konto & Cloud"** in den Einstellungen: angemeldet als … (Benutzername), **die hinterlegte E-Mail sichtbar und änderbar** (Gegenmaßnahme zum Tippfehler, 27.0b), Abmelden, Stand der letzten Sicherung, Konto löschen. Verschwindet ganz, wenn `supportsCloudSync` falsch ist.
- [ ] Texte in **allen drei** ARB-Dateien, danach `flutter gen-l10n` (Lehre 20).
- [ ] ⚠️ **Fehlermeldungen sprachneutral herausreichen** (Grund-Code statt Text): Supabase meldet auf Englisch. Zu unterscheiden sind mindestens: E-Mail schon registriert · Benutzername vergeben · E-Mail oder Passwort falsch · Passwort zu kurz · E-Mail-Format ungültig · kein Netz.
- [ ] Tests mit `test/support/fake_auth_service.dart`. ⚠️ **Kein Test spricht mit dem echten Server** — Tests müssen ohne Netz und ohne Schlüssel laufen.

#### 27.6 Profil in der Cloud
- [ ] Beim Anmelden Profil laden; beim Ändern hochladen. Lokal bleibt `profile_service.dart` die Quelle für die Anzeige — der Server ist die Kopie.
- [ ] ⚠️ **Regel für den ersten Zusammenstoß:** Es gibt schon einen lokalen Namen **und** vielleicht einen auf dem Server. Ohne ausdrückliche Regel gewinnt der Zufall. Festzulegen und hier zu notieren, **bevor** die erste Zeile geschrieben wird.

#### 27.7 Cloud-Sicherung des ganzen Bestands
- [ ] **Format ist das vorhandene Backup-JSON** (`backup_data.dart`) — dieselbe Serialisierung wie Export/Import, dieselben fünf Tests, dieselbe Versions-Prüfung. Kein zweites Format.
- [ ] **Hochladen automatisch** (entprellt, nach Änderungen und beim App-Start), **Herunterladen nur auf Nachfrage** mit klarer Ansage, was überschrieben wird. Begründung in 27.0b, Punkt 4.
- [ ] Sichtbarer Stand: „zuletzt gesichert vor …" in der Rubrik „Konto & Cloud". Eine Sicherung, deren Alter man nicht sieht, ist eine Vermutung.
- [ ] ⚠️ **Scheitern muss folgenlos bleiben.** Kein Netz, Server pausiert, Land blockiert die Adresse — die App arbeitet lokal weiter und versucht es später. **Kein Ladezustand ohne Ende, kein Dialog, der den Start blockiert.**
- [ ] ⚠️ **Die Grenze aussprechen:** Das ist eine **Sicherung**, kein Abgleich. Wer auf zwei Geräten gleichzeitig arbeitet, hat zwei Bestände; die Wiederherstellung überschreibt. Ein echter Abgleich braucht Zeitstempel je Zeile und Grabsteine für Löschungen — eine eigene Phase, keine Fußnote.

#### 27.8 Datenschutz nachziehen *(blockiert Phase 15)*

⚠️ **Mit der Entscheidung für echte E-Mails wiegt dieser Abschnitt schwerer als geplant.** Eine E-Mail-Adresse ist ein personenbezogenes Datum; damit werden auch Gewohnheiten und Erledigungen personenbezogen, weil sie einer identifizierbaren Person zugeordnet sind. Das ist keine Formalie mehr.

- [ ] `store/PRIVACY_POLICY.md` überarbeiten: **welche** Daten (E-Mail, Benutzername, Gewohnheiten, Erledigungen), **wo** gespeichert (Supabase, gewählte Region), **wie lange**, **wie löschbar**, und dass ein Konto **freiwillig** ist. **Und den Gist neu speichern** — er zieht nicht von selbst nach (⚠️ steht seit Phase 20 offen).
- [ ] **Konto löschen** muss möglich sein — nicht nur abmelden. ⚠️ Der `anon`-Schlüssel kann den Eintrag in `auth.users` **nicht** entfernen (27.4); dafür braucht es eine Edge Function. Bis dahin löscht die App Profil und Sicherung und meldet ab — **das ist noch kein vollständiges Löschen** und darf in der Datenschutzerklärung nicht als solches beschrieben werden.
- [ ] Play-Datensicherheitsformular neu ausfüllen: **nicht mehr „keine Daten erhoben"**. Zu deklarieren sind mindestens E-Mail-Adresse und App-Aktivität, jeweils mit Zweck und Übertragung.
- [ ] Die Datenschutz-Aussage in der **Erststart-Erklärung** prüfen — dort steht heute wörtlich, dass alle Daten auf dem Gerät bleiben. Das stimmt weiterhin für alle **ohne** Konto; der Satz muss diese Bedingung nennen.
- [ ] Abschnitt 3 dieses Plans und die Datenschutz-Aussage im Onboarding prüfen — dort steht heute wörtlich, dass alles auf dem Gerät bleibt.

#### 27.9 Prüfen
- [ ] Tests grün, `flutter analyze` sauber, **und der Bau ohne Schlüssel verhält sich wie vorher** (eigener Testfall).
- [ ] `tool/webtest.py` erweitern: Anmelden im Browser, Sicherung sichtbar, Abmelden. ⚠️ Der Durchgang darf **keine** echten Zugangsdaten enthalten — Testkonto über Umgebungsvariablen.
- [ ] Gerätedurchgang: anmelden, Bestand anlegen, App löschen und neu installieren, wiederherstellen. **Das ist die eigentliche Prüfung dieser Phase** — alles davor ist Vorbereitung.
- [ ] ⚠️ **Flugmodus-Durchgang:** vollständige Benutzung ohne Netz, danach mit Netz die Sicherung nachziehen.

#### 27.10 Risiken, die diese Phase mitbringt
| Risiko | Folge | Umgang |
|---|---|---|
| Server im Zielland nicht erreichbar | Anmeldung und Sicherung scheitern | App bleibt ohne Server voll benutzbar (27.7); Scheitern ist folgenlos |
| Kostenloses Projekt pausiert nach **1 Woche ohne Zugriff** | Sicherungen laufen ins Leere | Nach der Verteilung kein Thema (tägliche Nutzung); **während der Bauzeit einplanen**. Alter der Sicherung sichtbar machen |
| Kein tägliches Server-Backup im freien Tarif | Serverdaten könnten verloren gehen | tragbar, **weil** das Gerät die Quelle der Wahrheit bleibt — der Bestand wandert wieder hoch |
| **Kein eigener SMTP-Dienst** | Passwort-Zurücksetzen unmöglich; eingebauter Versand schafft **2 Nachrichten/Stunde** und nur an eigene Team-Adressen | E-Mail jetzt schon erfassen, „Confirm email" aus; SMTP nachrüsten — wirkt rückwirkend für alle (27.0b/27.2) |
| **Tippfehler in der E-Mail** (weil unbestätigt) | fällt erst beim Zurücksetzen auf, also im schlechtesten Moment | Adresse sichtbar und änderbar in „Konto & Cloud" (27.5) |
| **E-Mail = personenbezogenes Datum** | Datenschutzerklärung und Play-Formular werden falsch | 27.8 ist Bedingung für Phase 15, nicht Nacharbeit |
| RLS vergessen oder falsch | **fremde Daten für jeden lesbar** | RLS im selben Schritt wie die Tabelle, Gegenprobe in 27.4 |
| `service_role`-Schlüssel gerät in die App | vollständiger Datenbank-Zugriff für jeden | Schlüssel nie ins Repository; im Bundle nach ihm suchen |
| Zwei Geräte, ein Konto | ein Bestand überschreibt den anderen | Sicherung statt Abgleich, Wiederherstellung nur auf Nachfrage |

---

### Phase 21.3 — Gerätedurchgang ⬜
Die Werkzeug-Prüfungen sind durch (`analyze` sauber, Tests grün, Bundle signiert, Manifest ohne `AD_ID`/`BILLING`). **Der Durchgang auf einem echten Gerät steht aus** — er ist der Teil, den Tests nicht ersetzen (Lehre 8).

- [ ] **Release-Build auf einem echten Gerät** (nicht nur Emulator) — Debug und Release unterscheiden sich nachweislich (Lehre 5).
- [ ] **Frische Installation** (`pm clear`): Onboarding → **sieben** Standard-Kategorien → Gewohnheit aus einer Vorlage (landet sie in der passenden Kategorie?) → abhaken → alle Seiten. **Leerer Zustand** ist der häufigste Absturz-Kandidat: alle Diagramme, Übersicht und Teilen-Karte ohne einen einzigen Eintrag öffnen.
- [ ] **Kein Werbe-Streifen** auf allen vier Hauptseiten, Einstellungen ohne Rubrik „Werbung".
- [ ] **Teilen mit Bild-Kontrolle:** Karte **mit** und **ohne** Übersicht-Block teilen und das **erzeugte Bild** öffnen — nicht nur die Vorschau. QR-Code mit einem zweiten Gerät scannen.
- [ ] **Voller Bestand** über `lib/main_seed.dart` (~400 Tage): alle vier View-Tabs, Übersicht im Vollbild, Jahr, Konto.
- [ ] **Alle vier Sprachen × hell/dunkel × vier Farbvarianten** stichprobenartig; **Persisch vollständig durchklicken**: rechtsläufig? irgendwo deutscher Text? leere Kästchen statt Schrift? Überlauf, weil persische Wörter länger sind?
- [ ] **Drehen** auf jeder Seite (die Übersicht sperrt Querformat — beim Verlassen muss die Sperre fallen).
- [ ] **Alle 9 Home-Screen-Widgets** platzieren und antippen (Farbkachel: Abhaken aus fremdem Isolate, danach zurück in die App).
- [ ] Erinnerungen setzen, auslösen, snoozen, abschalten; Sicherung exportieren, importieren, App neu starten.
- [ ] Anleitungs-Seiten **offline** und bei fehlendem Text (404 → „Inhalt folgt"); auf Persisch prüfen, dass die persischen Dateien geladen werden.
- [ ] **Update über eine bestehende Installation** (nicht deinstallieren!) mit erhöhter Version — Bestand muss vollständig bleiben (Phase 25).
- [ ] Risikostellen gezielt: `read(provider.future)` ohne Zuhörer (Lehre 6), Farbwerte an Android-Widgets (Lehre 7), Kategorie-Dropdown im Ladezustand, Import einer beschädigten Sicherung.
- [ ] Gefundene Abstürze werden **hier** protokolliert, nicht stillschweigend behoben.

---

### Phase 15 — Veröffentlichung im Google Play Store (Android) 🔄
**Führt der Nutzer selbst durch**; Claude liefert Code-Anteile auf Zuruf und erklärt den nächsten Schritt auf Persisch.

**Stand:** Code fertig und signiert ✅ · Store-Material vollständig ✅ · Play-Konto angelegt, **Identitätsprüfung läuft** ⏳.

⚠️ **Zwei Blocker vor 15.2:** Der Gist der Datenschutzerklärung ist seit Phase 20 veraltet — **und Phase 27 macht ihn erneut falsch.** Erst 27.8, dann der Gist, dann das Formular.

#### Wichtige Kennungen (Nachschlagetabelle)
| Was | Wert | Wo im Projekt |
|---|---|---|
| Paketname (`applicationId`) | `com.rootin.app` ⚠️ nach Veröffentlichung unveränderlich | `android/app/build.gradle.kts` |
| Store-Link | `https://play.google.com/store/apps/details?id=com.rootin.app` | `lib/core/constants/app_links.dart` |
| Datenschutzerklärung (öffentlich) | https://gist.github.com/lukasylilli/673c36972d69819d975ffb82a592cca2 | Quelle: `store/PRIVACY_POLICY.md` |
| Signaturschlüssel | `~/development/keys/root-in-upload.jks`, Alias `upload`, gültig bis 2053 | `android/key.properties` |
| Kontakt | alirzsaleh@gmail.com · https://t.me/LukasAlmani | `lib/core/constants/contact_info.dart` |
| Anleitungs-Inhalte | `raw.githubusercontent.com/lukasylilli/Root-in/main/content/<sprache>/<datei>.md` | `guide_topic.dart` |
| Web-Fassung | `https://lukasylilli.github.io/Root-in/` | `tool/build_web.sh` |
| AdMob-IDs / Produkt-ID | `ca-app-pub-7806974290921501~9284147977` · `…/5672206027` · `remove_ads` | **seit Phase 20 auskommentiert**, nur zum Wiedereinschalten aufbewahrt |

#### Offene Schritte
- [ ] **15.0** Play-Identitätsprüfung abwarten (läuft seit 2026-07-26).
- [ ] **15.2** App anlegen, Store-Eintrag aus `store/PLAY_LISTING.md`, Datenschutz-URL, Inhaltseinstufung, **Datensicherheit** (⚠️ nach Phase 27 **nicht** mehr „keine Daten erhoben"), Werbung: Nein, In-App-Käufe: Nein.
- [ ] **15.2b** *(nicht blockierend)* Launcher-Symbol nachschärfen — die Strichzeichnung hat nur 4,6 % Tintenanteil und verschmiert bei 48 px. **Betrifft auch das Web-Favicon** (16 px); ein neues `assets/icon/app_icon.png` zieht beide Plattformen in einem Lauf nach.
- [ ] **15.3** `flutter build appbundle --release` → *Testen → Interner Test*.
- [ ] **15.3b** **12-Tester-Regel**: 12 Tester müssen die App **installiert** haben, danach 14 zusammenhängende Tage. Realistisch 4–5 Wochen bis zur Produktion.
- [ ] **15.6** Produktion: `versionCode` erhöhen (steht auf `1.0.0+1`), Bundle bauen, einreichen.
- [ ] **15.8** *(optional)* Persische Store-Sprache — Texte in `store/PLAY_LISTING.md`, es fehlen persische Screenshots.

---

### Phase 26 — Web-Fassung: was noch offen ist 🔄
Die Fassung ist gebaut, veröffentlicht und geprüft (10.1/10.2). Offen bleiben:

- [ ] **Auf einem echten iPhone durchgehen:** Seite in Safari öffnen → Speicher-Hinweis erscheint genau einmal? → „Zum Home-Bildschirm" → startet sie ohne Adressleiste? Bleiben die Daten? Funktionieren Teilen und Sicherung?
- [ ] **Bestätigung der Behebung aus 26.13:** Symbol vom Home-Bildschirm löschen, in Safari neu laden, **erneut ablegen**, Erststart durchtippen — reagieren die Knöpfe dort, wo sie stehen? ⚠️ Ohne das Löschen startet die abgelegte Fassung weiter mit der alten `index.html`.
- [ ] **App-Symbol** auf dem Home-Bildschirm ansehen (Safari am Mac kann das Ablegen nicht prüfen).
- [ ] ⚠️ **GitHub Pages kann `Cross-Origin-Opener-Policy`/`Embedder-Policy` nicht setzen.** Drift nutzt dann nicht die schnellste Speicherart. **Die Daten bleiben erhalten** — eine Frage der Geschwindigkeit, kein Datenverlust.

---

### Phase 12 — iOS-Portierung ⬜
- [ ] Bundle-Identifier weg von `com.example.rootIn` (sinnvollerweise passend zu `com.rootin.app`)
- [ ] iOS-spezifisches Testing, Cupertino-Anpassungen wo sinnvoll
- [ ] iOS Home-Screen-Widget (WidgetKit) — auf Android seit Phase 10 fertig
- [ ] App-Icons, Splash Screen

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
- **2026-08-16 (Phase 27 beauftragt)** — Nutzerdaten sollen auf einem Server liegen (Supabase). Damit fällt die älteste Festlegung des Projekts („kein Backend, keine Nutzerkonten"). Vor dem ersten Handgriff festgehalten, **was daran hängt** (27.0) — insbesondere, dass die Datenschutzerklärung und das Play-Formular keine Nacharbeit sind, sondern eine **Bedingung der Veröffentlichung**.

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

## 12. Offene Fragen
**Entschieden werden in Phase 27** (siehe 27.0b): Anmeldeverfahren · Umfang der Cloud-Daten · Pflicht oder freiwillig · Richtung des Abgleichs.

- **Zwei Fassungen, zwei Datenbestände.** Wer Root-in auf Android **und** im Browser benutzt, hat heute zwei getrennte Bestände. **Phase 27 kann das lösen** — aber nur als Sicherung/Wiederherstellung, nicht als stiller Abgleich (27.7).
- **Erinnerungen im Web** entfallen (Web-Push bräuchte einen Server). ⚠️ Mit Phase 27 gibt es einen Server — die Entscheidung ist damit **wieder offen**, aber Push ist ein eigenes Thema und keine Nebensache.
- **Sollen neue Beiträge in „موارد دیگر" gemeldet werden?** Möglich wäre ein stiller Vergleich beim App-Start (neue Einträge im `index.json` gegenüber dem gespeicherten Stand) und ein Punkt am Einstellungs-Eintrag — ohne Server, ohne Push.
- ~~Repository öffentlich oder privat?~~ — **entschieden 2026-08-16: öffentlich, das Projekt ist Open Source.** ⚠️ Folge für Phase 27: Die Zugriffsregeln des Servers sind für jeden lesbar, müssen also wirklich stimmen; der `service_role`-Schlüssel darf nirgends im Repository auftauchen.
- **iOS-Bundle-Identifier ist weiterhin `com.example.rootIn`** — wird in Phase 12 entschieden.
- **Sicherungskopie des Signaturschlüssels steht aus.** Die `.jks` existiert nur einmal auf diesem Mac. Datei **und** Passwort gehören in den Passwortmanager.
- **Die persische Übersetzung ist ein Entwurf** — alle Schlüssel sind gefüllt, gelesen hat sie noch kein Muttersprachler. Korrekturen betreffen nur `lib/l10n/app_fa.arb`.
- **Farbe je Kategorie?** Heute trägt die Gewohnheit die Farbe. Kategorie-Farben würden Diagramme klarer machen, kosten aber eine DB-Spalte.
- **Direkt in die Telegram-Gruppe teilen?** Das System-Share-Sheet deckt es ab; offen, ob ein eigener Knopf den Sonderweg wert ist.
- **Widget-Labels in der Launcher-Auswahl** folgen der **Geräte**-Sprache, nicht der App-Sprache. Lohnt sich nur für alle Sprachen zusammen — eine einzelne nachzurüsten macht die Uneinheitlichkeit sichtbarer, nicht kleiner.
- **Piktogramm auf der Farbkachel ist für alle Gewohnheiten gleich** — ein Mapping `iconKey` → Android-Vektor müsste doppelt gepflegt werden.
- **Home-Animation als Lottie-Datei:** Slot ist verdrahtet, ein Nutzer-Asset liegt nicht vor.
- **Persische Store-Sprache?** Texte stehen in `store/PLAY_LISTING.md`; es fehlen vier persische Screenshots.
- Genaues Farbschema/Branding, Punkte-Gewichtung je Habit, App-Name final, weitere Sprachen über DE/EN/FA hinaus — weiterhin offen.

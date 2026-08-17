# Root-in — Habit Maker / Routine Tracker — Projektplan

> Lebendiges Dokument. Wird bei jeder relevanten Änderung am Projekt aktualisiert.
>
> **Stand 2026-08-17.** Android-Code fertig und signiert · Web-Fassung live unter `lukasylilli.github.io/Root-in/` · **Nutzerkonten und Cloud-Sicherung laufen** · **228 Tests grün**, `flutter analyze` sauber, 20/20 im echten Browser, 13/13 Zugriffsregeln am Server.
>
> ✅ **[Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-) ist codeseitig fertig.** ⚠️ Sie kehrt Abschnitt 3 um — Root-in war von Tag eins „vollständig lokal, kein Backend, keine Nutzerkonten". Was daran hängt, steht in 27.0.
>
> ⚠️ **Ziel neu gesetzt am 2026-08-17: die Web-Fassung ist das Ziel** — „alle sollen sie ohne App Store oder Google Play nutzen können". Android und iOS nativ sind **zurückgestellt**, nicht gestrichen. Was das ändert, steht in [Abschnitt 2](#2-zielplattformen).
>
> ⬜ **Was noch offen ist — nach der neuen Zielsetzung sortiert:**
>
> | Offen | Wer | Dringlichkeit |
> |---|---|---|
> | **Durchgang der Web-Fassung auf einem echten iPhone** (26 + Konto/Sicherung) | Nutzer | **hoch** — das ist jetzt die Hauptplattform |
> | **Gist der Datenschutzerklärung nachziehen** (zweifach veraltet) | Nutzer | **hoch** — echte Nutzer, echte E-Mails; unabhängig von jedem Store |
> | Erinnerungen im Web: bauen oder als Grenze benennen? | Entscheidung | **hoch** — die primäre Plattform hat sie nicht |
> | Eigener SMTP-Dienst → Passwort-Zurücksetzen (27.2) | Nutzer | mittel |
> | Konto → Sicherung → Gerät wechseln → Wiederherstellen einmal durchspielen | Nutzer | mittel |
> | Android-Gerätedurchgang (21.3) · Play-Formular · Play-Veröffentlichung (15) · iOS nativ (12) | — | **zurückgestellt** |

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
    - 10.1 [Erledigte Phasen (Kurzfassung)](#101-erledigte-phasen-kurzfassung) — Phasen 0–11.6, 13, 14, 15.1/15.2, 16–27 ✅
    - 10.2 [Festlegungen aus erledigten Phasen, die man noch braucht](#102-festlegungen-aus-erledigten-phasen-die-man-noch-braucht)
    - [Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase)](#phase-27--nutzerkonten--cloud-speicher-supabase-) ✅ *(Code fertig, Datenschutz-Formalitäten offen)*
    - **Offene Phasen** *(nach der Zielsetzung vom 2026-08-17 sortiert):*
      - [Phase 26 — Web-Fassung: was noch offen ist](#phase-26--web-fassung-was-noch-offen-ist-) 🔄 **die Hauptplattform**
      - [Phase 21.3 — Gerätedurchgang](#phase-213--gerätedurchgang--zurückgestellt) ⬜ zurückgestellt (Android)
      - [Phase 15 — Veröffentlichung im Google Play Store](#phase-15--veröffentlichung-im-google-play-store-android-) ⏸️ zurückgestellt
      - [Phase 12 — iOS-Portierung](#phase-12--ios-portierung-) ⏸️ zurückgestellt
11. [Entscheidungs-Log & dauerhafte Lehren](#11-entscheidungs-log--dauerhafte-lehren)
    - 11.1 [Log (Kurzfassung)](#111-log-kurzfassung) · 11.2 [Dauerhafte Lehren & Fallstricke](#112-dauerhafte-lehren--fallstricke) (1–35)
12. [Offene Fragen](#12-offene-fragen)

## 1. Vision
App zum Aufbauen und Verfolgen von Gewohnheiten/Routinen. Nutzer legen Habits an, haken sie täglich ab, sehen Streaks/Statistiken, bekommen Erinnerungen und werden durch kleine Gamification-Elemente motiviert, dranzubleiben. Inhaltlicher Schwerpunkt: Sprachenlernen (siehe Anleitungs-Rubrik und Standard-Kategorien).

## 2. Zielplattformen

⚠️ **Am 2026-08-17 vom Nutzer neu gesetzt:** *„ziel ist web app, dass alle ohne app store oder google play das nutzen können."* Die Web-Fassung ist damit **das Ziel**, nicht mehr die Überbrückung. Bis dahin stand hier das Gegenteil — Android „primär", Web „Ersatzweg, solange keine Store-Veröffentlichung möglich ist", iOS nativ „bleibt das Ziel". Alle drei Sätze sind hinfällig.

| Plattform | Rolle | Stand |
|---|---|---|
| **Web (PWA)** | **das Ziel** — jeder erreicht sie über eine Adresse, ohne Store, ohne Installation, ohne Konto bei Google oder Apple | live unter `lukasylilli.github.io/Root-in/` |
| Android (APK/Play) | **zurückgestellt.** Der Code bleibt lauffähig und signiert; eine Veröffentlichung ist möglich, aber kein Ziel mehr | Phase 15 pausiert |
| iOS nativ | **zurückgestellt.** Die Web-Fassung erreicht iPhones bereits über „Zum Home-Bildschirm" | Phase 12 pausiert |
| Desktop (`macos/`, `linux/`, `windows/`) | ungenutzt | — |

**Was diese Entscheidung wert ist:** Kein Store-Konto, keine Prüfzeiten, keine 12-Tester-Regel, keine Altersfreigabe-Formulare — und ein Update ist ein `git push`. Genau der Grund, warum Phase 26 überhaupt gebaut wurde.

⚠️ **Was sie kostet, und das gehört ausgesprochen:** Zwei Funktionen gibt es im Browser **nicht** und sie fehlen damit auf der *primären* Plattform:

- **Erinnerungen** (`flutter_local_notifications` hat keine Web-Umsetzung). Web-Push wäre möglich — seit Phase 27 gibt es sogar einen Server dafür —, ist aber ein eigenes Vorhaben (Service Worker, Berechtigungen, Versanddienst; auf iOS nur in der abgelegten Fassung). Siehe Abschnitt 12.
- **Startbildschirm-Widgets** (9 Stück auf Android). Eine Website kann kein Widget stellen; das bleibt so.

Beide verschwinden im Browser **sichtbar** statt wirkungslos dazustehen (Phase 26.1) — aber ein Nutzer, der nur die Web-Fassung kennt, bekommt eine Habit-App **ohne Erinnerungen**. Das ist die eigentliche offene Frage dieser Neuausrichtung, nicht eine Fußnote.

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

Lokale Datenbank: Drift (SQLite); Key-Value (Profil, Einstellungen): `shared_preferences`; Export: JSON über Dateisystem bzw. Share-Sheet — **dasselbe JSON, das auch in die Cloud geht.**

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

**5.4 Einstellungen** — Sprache, Darstellungsmodus, Farb-Variante, Quelle der Berg-Animation · Konto, Kategorien, Erinnerungen · App teilen, Sicherung exportieren/importieren, Kontakt · Rubrik **Root-in Anleitung** (vier Themen) · Eintrag **موارد دیگر** direkt darunter.

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

**Punkte & Prozent** — jede Seite zeigt Fortschritt in beidem. **Matrix-Grid** — wiederverwendbare Heatmap (Zellen = Tage, Intensität = Erledigungsgrad). **Diagramme** — Typ-Diagramm je Kategorie + Fortschritts-Trend, via `chart_card.dart`. **Streak** — aktuelle + längste Serie, 1 Tag pro Woche darf ausgelassen werden. **Achievements** — 11 vordefinierte. **Teilen** — App teilen (Text + Store-Link) und Fortschritt teilen (Bild mit fester Breite, Übersicht-Block, QR-Code). **Store-Link** — `core/constants/app_links.dart` ist die einzige Quelle. **Home-Animation** — Berg-Aufstieg, über `AppAssets.homeAnimation` gegen ein Lottie-Asset tauschbar. **Kategorien** — jede Gewohnheit gehört zu genau einer; die Liste verwaltet der Nutzer.

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
| 27 Nutzerkonten & Cloud | Supabase: freiwilliges Konto (E-Mail + Passwort + Benutzername), Cloud-Sicherung im vorhandenen Backup-Format, Profil-Abgleich, Datenschutzerklärung neu · Zugriffsregeln von außen mit echten Konten geprüft | 08-17 |
| 27.11 Geteilter Link | QR-Code und Share-Text zeigten auf eine Play-Seite mit **HTTP 404**; jetzt auf die Web-Fassung | 08-17 |

**Stand danach: 228 Tests grün** (+2 bewusst übersprungen), `flutter analyze` sauber, 20/20 im echten Browser gegen die veröffentlichte Seite, 13/13 Zugriffsregeln am Server, Release-Bundle signiert und hochladbar.

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

### Phase 27 — Nutzerkonten & Cloud-Speicher (Supabase) ✅
**Code fertig am 2026-08-17.** Offen bleiben nur zwei Formalitäten beim Nutzer (27.8) — die aber Phase 15 blockieren.
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
- [x] **`tool/build_web.sh` reicht die Werte durch** und liest lokal `.env`. ⚠️ Eine vorhandene Umgebungsvariable gewinnt gegen die Datei — sonst überschriebe eine vergessene `.env` auf dem Entwicklungsrechner still die Werte der Automatik. Leer bleibt zulässig: Dann hat die Web-Fassung schlicht keine Cloud.
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
- [x] **`features/auth/presentation/auth_sheet.dart`** — Anmelden und Registrieren in **einem** Sheet, umgeschaltet über einen Segment-Knopf. Dasselbe Muster wie `showShareProgressSheet()`: eine Funktion, ein Einstieg. Zwei Seiten mit fast gleichem Formular wären zwei Stellen für jede spätere Änderung.
- [x] **Die Übersetzung der Gründe steht in der Oberfläche, nicht im Dienst** (`authIssueText`, `usernameIssueText`). Der Dienst kennt keine Sprache, die Oberfläche keine Server-Codes. Wer das vermischt, braucht `BuildContext` in einem Dienst — und kann ihn nicht mehr testen.
- [x] **Der Benutzername wird geprüft, BEVOR ein Konto entsteht.** Sonst legte eine ungültige Eingabe erst das Konto an und scheiterte dann am Namen.
- [x] **`cloudSyncEnabledProvider`** statt eines direkten Zugriffs auf `supportsCloudSync` in der Oberfläche. ⚠️ Ohne ihn wäre die halbe Oberfläche dieser Phase **unprüfbar**: Im Testlauf gibt es keine Schlüssel, also verstecken sich die Widgets grundsätzlich.
- [ ] ⚠️ **Reihenfolge bei der Registrierung, und was schiefgehen kann:** Erst `signUp(email, password)`, **dann** die Profilzeile mit dem Benutzernamen (die braucht die Kennung, die es erst danach gibt). Ist der Name schon vergeben, existiert das Konto bereits, die Profilzeile aber nicht — **kein kaputter Zustand, aber einer, der behandelt werden muss**: Die Oberfläche fragt nach einem anderen Namen, `claimUsername()` schreibt ihn nach. Das Konto darf dabei **nicht** gelöscht werden; nur der Name fehlt.
- [ ] **Verfügbarkeit vorab prüfen** über `username_available()` — reine Höflichkeit. ⚠️ **Die Wahrheit ist der eindeutige Index der Datenbank**: Zwischen Frage und Absenden kann ein anderer denselben Namen nehmen. Bei Zweifeln antwortet die Abfrage „frei" — ein Formular, das wegen einer wackligen Verbindung „vergeben" behauptet, hält jemanden von seinem eigenen Namen ab.
- [ ] **„Passwort vergessen" ist vorgesehen**, funktioniert aber erst mit eigenem SMTP (27.2). ⚠️ Solange es das nicht gibt, darf der Knopf **nicht** dastehen und ins Leere greifen — dieselbe Regel wie bei den Erinnerungen im Browser (26.1).
- [x] **Rubrik „Konto & Cloud" auf der bestehenden Konto-Seite** (`account_cloud_card.dart`) — **nicht** in einer eigenen Rubrik daneben. ⚠️ Entscheidung des Nutzers und die richtige: Ein Konto ist genau das, worum es auf dieser Seite ohnehin geht; ein zweiter Ort für dasselbe Thema wäre die verbotene Doppelung, und der Nutzer müsste sich merken, welcher der beiden Orte was kann.
- [x] Zeigt: angemeldet als … · die hinterlegte E-Mail **sichtbar** samt Hinweis (Gegenmaßnahme zum Tippfehler, 27.0b) · Stand der letzten Sicherung · Sichern · Wiederherstellen · Abmelden. **Verschwindet vollständig ohne Cloud.**
- [x] Texte in **allen drei** ARB-Dateien, `flutter gen-l10n` gelaufen (Lehre 20).
- [x] **Fehlermeldungen sprachneutral** durchgereicht und erst in der Oberfläche übersetzt.
- [x] `test/support/fake_auth_service.dart` + `test/widget/account_cloud_card_test.dart` (6 Fälle, darunter **„ohne Cloud ist die Rubrik gar nicht da"**, das Konto ohne Benutzernamen und die persische Fassung). ⚠️ **Kein Test spricht mit dem echten Server.**
- [ ] „Konto löschen" — hängt an 27.8 (der `anon`-Schlüssel kann `auth.users` nicht löschen).

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

#### 27.8 Datenschutz nachziehen 🔄

⚠️ **Mit der Entscheidung für echte E-Mails wiegt dieser Abschnitt schwerer als geplant.** Eine E-Mail-Adresse ist ein personenbezogenes Datum; damit werden auch Gewohnheiten und Erledigungen personenbezogen, weil sie einer identifizierbaren Person zugeordnet sind. Das ist keine Formalie mehr.

⚠️ **Und seit dem 2026-08-17 hängt es nicht mehr an Phase 15.** Bisher stand hier „blockiert die Play-Veröffentlichung" — das war die schwächere Begründung, und mit dem Zurückstellen von Phase 15 wäre sie ganz weggefallen. **Die Pflicht bleibt trotzdem:** Wer die Web-Adresse an 200 Schüler gibt und deren E-Mail speichert, schuldet ihnen eine zutreffende Datenschutzerklärung — ganz ohne Store. Ein Formular bei Google war nie der Grund, sondern nur der Anlass.

- [x] **`store/PRIVACY_POLICY.md` überarbeitet, beide Sprachfassungen.** Neuer Punkt 4 („Konto und Sicherung auf dem Server") nennt in einer Tabelle **welche** Daten, **wozu**, **wo** (Supabase, EU/Frankfurt), **wer sie sieht** (nur der Eigentümer, technisch über RLS), **wann** hochgeladen wird und **wie** man sie loswird. Die Kurzfassung sagt in beiden Sprachen zuerst: **ohne Konto verlässt nichts das Gerät.**
- [x] **Punkt 9 (Rechte) neu geschrieben** — der alte Satz „wir speichern nichts, also gibt es nichts herauszugeben" ist mit Konto schlicht falsch. Jetzt: Auskunft/Übertragbarkeit über den vorhandenen Export, Berichtigung in der App, Löschung, Rechtsgrundlage Einwilligung, Aufsichtsbehörde.
- [x] **Die Erststart-Erklärung sagt es jetzt richtig** (alle drei Sprachen): „Deine Daten bleiben auf diesem Gerät; ein Konto ist freiwillig und legt zusätzlich eine Sicherung an." Der alte Satz behauptete das Gegenteil dessen, was die App seit heute kann.
- [x] **„Daten auf dem Server löschen"** in der Rubrik „Konto & Cloud" (`deleteServerData()`): löscht Sicherung und Profilzeile, lässt den lokalen Bestand unangetastet. ⚠️ **Das ist bewusst nicht als „Konto löschen" beschriftet** — der Eintrag in `auth.users` bleibt, weil der öffentliche Schlüssel ihn nicht entfernen darf. Die Datenschutzerklärung nennt dafür den Weg über eine Nachricht; sie darf den Knopf **nicht** als vollständige Löschung ausgeben.
- [ ] ⬜ **Den Gist neu speichern** — er zieht nicht von selbst nach (steht seit Phase 20 offen und ist jetzt **zweifach** veraltet). Muss der Nutzer tun; Quelle ist `store/PRIVACY_POLICY.md`.
- [ ] ⏸️ **Play-Datensicherheitsformular** — nur relevant, falls Phase 15 je wieder aufgenommen wird. Dann: **nicht mehr „keine Daten erhoben"**, sondern mindestens E-Mail-Adresse und App-Aktivität mit Zweck und Übertragung.
- [ ] ⬜ *(später, nicht blockierend)* Vollständige Kontolöschung über eine Edge Function, damit der Weg nicht über eine Nachricht laufen muss.
- [ ] Abschnitt 3 dieses Plans und die Datenschutz-Aussage im Onboarding prüfen — dort steht heute wörtlich, dass alles auf dem Gerät bleibt.

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
- [x] `playStoreUrl` **bleibt** (aus dem Paketnamen abgeleitet) — er wird gebraucht, sobald veröffentlicht wird. Ein Wechsel ist dann **eine Zeile**, und alle drei Leser ziehen mit.
- [x] ⚠️ **Der bestehende Test hat den Fehler mitgetragen.** Er prüfte, dass `playStoreUrl` korrekt gebildet ist — das war es. Es war nur die **falsche** Adresse. Geprüft wird jetzt `appShareUrl`, dazu `test/unit/app_links_test.dart` mit der ausdrücklichen Regel „geteilt wird die Web-Fassung, nicht der Store".

⬜ **Offen bleibt die Entscheidung des Nutzers, ob überhaupt in den Play Store veröffentlicht wird.** Sie ändert an dieser Behebung nichts: Die Web-Adresse funktioniert in jedem Fall, und der Store-Link ist eine Zeile entfernt.

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

### Phase 21.3 — Gerätedurchgang ⬜ *(zurückgestellt)*

⏸️ **Seit dem 2026-08-17 nicht mehr vordringlich.** Diese Liste prüft die **Android**-Fassung für eine Play-Veröffentlichung; das Ziel ist jetzt die Web-Fassung (Abschnitt 2). Sie bleibt vollständig stehen — der Android-Code ist lauffähig und signiert, und wenn die Veröffentlichung je kommt, ist das hier die Vorbereitung.

⚠️ **Ein Teil der Liste gilt weiter, nur woanders:** Leerer Zustand, alle Sprachen, Persisch, Teilen, Import/Export und der Datenerhalt sind **plattformunabhängig** — sie gehören jetzt in den iPhone-Durchgang aus Phase 26. Rein Android sind: die 9 Startbildschirm-Widgets, Erinnerungen, Drehung, APK-Installation und das Update über eine bestehende Installation.

Die Werkzeug-Prüfungen sind durch (`analyze` sauber, Tests grün, Bundle signiert, Manifest ohne `AD_ID`/`BILLING`). Am 2026-08-17 zusätzlich geprüft: Ein **Release-APK mit Cloud-Schlüsseln** baut und installiert sich auf einem frischen Emulator (Android 17). Der eigentliche Durchgang steht aus — er ist der Teil, den Tests nicht ersetzen (Lehre 8).

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

### Phase 15 — Veröffentlichung im Google Play Store (Android) ⏸️

⏸️ **Zurückgestellt am 2026-08-17.** Das Ziel ist die Web-Fassung — „alle sollen sie ohne App Store oder Google Play nutzen können" (Abschnitt 2). Diese Phase wird **nicht gestrichen**: Das Material ist fertig, der Schlüssel gültig bis 2053, und der Weg steht hier vollständig, falls die Entscheidung je zurückgedreht wird.

**Stand:** Code fertig und signiert ✅ · Store-Material vollständig ✅ · Play-Konto angelegt, Identitätsprüfung ⏳.

⚠️ **Was NICHT mit dieser Phase pausiert: die Datenschutzerklärung.** Der veraltete Gist war bisher als „Play-Blocker" notiert — das war schon immer die schwächere Begründung. Seit Phase 27 speichert die App **E-Mail-Adressen echter Nutzer**; der veröffentlichte Text muss stimmen, ob ein Store beteiligt ist oder nicht. Der Punkt wandert deshalb aus dieser Phase heraus und steht in 27.8.

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
**Seit dem 2026-08-17 die Hauptplattform** (Abschnitt 2). Die Fassung ist gebaut, veröffentlicht und geprüft (10.1/10.2, 20/20 im Browser). Was offen ist, wiegt damit schwerer als zuvor — es betrifft nicht mehr einen Nebenweg, sondern **den** Weg.

**Der Durchgang auf einem echten iPhone** — das ist der eine Test, den weder Safari am Mac noch der Simulator ersetzen können (in beiden lässt sich das Ablegen nicht nachstellen, 26.12):

- [ ] Seite in Safari öffnen → erscheint der Speicher-Hinweis genau **einmal**?
- [ ] „Zum Home-Bildschirm" → startet sie **ohne Adressleiste**? Stimmt das App-Symbol?
- [ ] **Bestätigung von 26.13:** Erststart durchtippen — reagieren die Knöpfe **dort, wo sie stehen**? ⚠️ Vorher das alte Symbol **löschen** und neu ablegen, sonst startet die abgelegte Fassung weiter mit der alten `index.html` aus dem Zwischenspeicher.
- [ ] Konto anlegen, Gewohnheit anlegen, „Jetzt sichern" → liegt in Supabase eine Zeile in `backups`?
- [ ] App vom Home-Bildschirm löschen, neu ablegen, anmelden, **wiederherstellen** — ist der Bestand zurück?
- [ ] Bleiben die Daten nach dem Schließen? Funktionieren Teilen und Export?

⬜ **Und die Frage, die aus der Neuausrichtung folgt:** Auf der Hauptplattform gibt es **keine Erinnerungen**. Web-Push ist möglich (der Server steht seit Phase 27), aber ein eigenes Vorhaben. Zu entscheiden: bauen — oder als bewusste Grenze benennen und die App als „ohne Erinnerungen" verstehen. Siehe Abschnitt 12.

⚠️ **GitHub Pages kann `Cross-Origin-Opener-Policy`/`Embedder-Policy` nicht setzen.** Drift nutzt dann nicht die schnellste Speicherart. **Die Daten bleiben erhalten** — eine Frage der Geschwindigkeit, kein Datenverlust. Wer das ändern will, braucht einen Hoster mit eigenen Kopfzeilen.

---

### Phase 12 — iOS-Portierung ⏸️

⏸️ **Zurückgestellt am 2026-08-17.** Die Web-Fassung erreicht iPhones bereits über „Zum Home-Bildschirm" und braucht dafür weder Apple-Entwicklerkonto (99 $/Jahr) noch App-Store-Prüfung. Eine native Fassung brächte vor allem die zwei Dinge, die dem Browser fehlen: **Erinnerungen** und **Widgets**. Solange die nicht gebraucht werden, lohnt sie nicht.

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

- **2026-08-17 (Phase 27 gebaut)** — Konto, Cloud-Sicherung, Datenschutz. Tragende Entscheidungen:
  - **Das Anmeldeverfahren wurde einmal umgeworfen — rechtzeitig.** Zuerst „Benutzername ohne E-Mail" (Supabase kann das nicht von sich aus, also künstliche Adressen), dann auf Wunsch des Nutzers **echte E-Mail**. Der halbe Tag Arbeit war nicht verloren: Die Umrechnung fiel **ersatzlos** weg statt als toter Code liegen zu bleiben, und die Namensregeln blieben. **Vor dem ersten echten Nutzer ist ein Umwurf billig** — danach verwaist er Konten.
  - **Nachgelesen statt geraten, dreimal.** Tarifgrenzen (`supabase.com/pricing`), Mail-Grenze (**2 Nachrichten/Stunde und nur an eigene Team-Adressen** — damit war „E-Mail-Bestätigung an" von vornherein unmöglich) und die Fehler-Codes der Anmeldung. Alle drei hätten aus dem Gedächtnis falsch geraten werden können, und zwei davon hätten die Phase in eine Sackgasse geführt.
  - **Zwei unabhängige Schutzschichten am Server**, ausgelöst durch eine Frage des Nutzers zu den Data-API-Schaltern: Rechte (nur `authenticated`, nie `anon`) **und** RLS. Dabei fiel auf, dass `schema.sql` sich auf einen Schalter in einer Weboberfläche verlassen hatte — jetzt trägt die Datei ihre Rechte selbst.
  - **Geprüft wurde von außen, mit echten Konten** (`tool/rls_check.sh`, 13/13). Ein `select` im SQL-Editor läuft mit erhöhten Rechten und beweist nichts.
  - **Der geteilte QR-Code führte seit Phase 19 auf HTTP 404** — gemeldet vom Nutzer, nachgemessen, behoben. Der bestehende Test hatte den Fehler mitgetragen: Er prüfte, dass die Play-Adresse *korrekt gebildet* war. War sie. War nur die falsche.
  - **Lehre 35 entstand aus dreimaligem Rückfall in Lehre 32.** Eine Regel gehört an die Stelle, an der man gegen sie verstößt — in den Docstring, in den Kommentar, in einen Test. Nicht nur in dieses Dokument.

- **2026-08-17 (Ziel neu gesetzt)** — *„ziel ist web app, dass alle ohne app store oder google play das nutzen können."* Damit kehrt sich Abschnitt 2 um: **Web ist das Ziel**, Android und iOS nativ sind zurückgestellt. Was das bedeutet:
  - **Phase 15 und 12 werden pausiert, nicht gestrichen.** Material, Signaturschlüssel und Wege bleiben vollständig stehen — eine zurückgedrehte Entscheidung soll nicht bei null anfangen.
  - **Die Datenschutzerklärung war als „Play-Blocker" begründet — das trug nicht.** Mit dem Zurückstellen von Phase 15 wäre die Begründung weggefallen, die Pflicht aber nicht: Wer 200 Schülern eine Adresse gibt und ihre E-Mail speichert, schuldet ihnen einen zutreffenden Text, ganz ohne Store. Der Punkt ist deshalb aus Phase 15 heraus nach 27.8 gewandert. **Ein Grund, der beim ersten Gegenwind verschwindet, war der falsche Grund.**
  - **Der Preis steht jetzt ausdrücklich in Abschnitt 2:** Die Hauptplattform hat **keine Erinnerungen** und keine Startbildschirm-Widgets. Bei einer Habit-App ist das erste kein Detail — es ist die offene Frage dieser Neuausrichtung und steht als solche in Abschnitt 12.
  - **Der Android-Durchgang (21.3) wurde mittendrin angehalten** — Release-APK mit Cloud-Schlüsseln gebaut und auf einem frischen Emulator installiert, dann kam die neue Zielsetzung. Der plattformunabhängige Teil der Liste (leerer Zustand, Sprachen, Persisch, Teilen, Datenerhalt) gilt weiter, nur gehört er jetzt in den iPhone-Durchgang.

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
35. **Eine Regel, die nur im Dokument steht, hält niemanden auf.** Lehre 32 („nach Knöpfen fragen, nicht nach Überschriften") stand ausformuliert in diesem Plan — und ist beim Bauen von Phase 27 trotzdem ein **drittes** Mal zugeschnappt: Jedes Mal suchte eine Prüfung einen Titel im Semantik-Baum, meldete „nicht da", und das Gesuchte stand deutlich sichtbar auf dem Bildschirmfoto. Ein Plan wird beim Planen gelesen, nicht beim Tippen. **Wer eine Regel wirklich durchsetzen will, bringt sie an die Stelle, an der man gegen sie verstößt** — in den Docstring der Funktion (`shows()`), in den Kommentar neben dem Schlüssel, in einen Test. Dasselbe galt für die Zusammenstoß-Regel aus 27.6: Sie stand als hübsche Tabelle im Kopf der Datei und wurde von nichts gehalten, bis sie sieben Testfälle bekam.

## 12. Offene Fragen
**Entschieden werden in Phase 27** (siehe 27.0b): Anmeldeverfahren · Umfang der Cloud-Daten · Pflicht oder freiwillig · Richtung des Abgleichs.

- **Zwei Fassungen, zwei Datenbestände.** ✅ **Mit Phase 27 gelöst — aber nur halb, und das ist Absicht:** Wer sich auf beiden Geräten anmeldet, kann seinen Bestand übertragen (sichern hier, wiederherstellen dort). Ein **stiller Abgleich** in beide Richtungen ist es nicht und soll es vorerst nicht sein (27.7). Ein echter Abgleich bräuchte Zeitstempel je Zeile und Grabsteine für Löschungen — eine eigene Phase.
- ⚠️ **Erinnerungen im Web — die wichtigste offene Frage seit der Neuausrichtung.** Sie entfallen dort (`flutter_local_notifications` hat keine Web-Umsetzung). Solange Web der *Ersatzweg* war, war das ein hinnehmbarer Abstrich; seit Web **das Ziel** ist (Abschnitt 2), fehlt einer Habit-App ihre Erinnerungsfunktion auf der Hauptplattform. Drei Wege: **(a)** Web-Push bauen — möglich, der Server steht seit Phase 27, kostet aber Service Worker, Berechtigungen und einen Versanddienst, und auf iOS wirkt es **nur in der abgelegten Fassung**; **(b)** als bewusste Grenze benennen und die App als „ohne Erinnerungen" führen; **(c)** Android-Fassung für alle, die Erinnerungen wollen, per APK weitergeben (ohne Store). **Entscheidung des Nutzers.**
- **Vollständige Kontolöschung** braucht eine Edge Function (der öffentliche Schlüssel darf `auth.users` nicht anfassen). Heute löscht die App die Server-Daten und meldet ab; die vollständige Löschung läuft über eine Nachricht. Offen, ob das reicht.
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

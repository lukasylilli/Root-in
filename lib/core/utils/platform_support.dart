import 'package:flutter/foundation.dart';

import '../constants/app_config.dart';

// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// /// Ob auf dieser Plattform Werbung und In-App-Käufe überhaupt möglich sind.
// ///
// /// Beide Bausteine (`google_mobile_ads`, `in_app_purchase`) gibt es nur für
// /// Android und iOS — die Desktop-/Web-Ordner des Projekts sind laut PLAN.md
// /// Abschnitt 2 zwar vorhanden, aber nicht im Umfang. Ohne diese Abfrage würde
// /// dort schon der Zugriff auf `InAppPurchase.instance` die fehlende
// /// Plattform-Implementierung anfordern und werfen.
// ///
// /// Eine Stelle für beide Dienste (siehe PLAN.md Abschnitt 9, „Puzzling"/DRY)
// /// — `core/services/ads_service.dart` und `core/services/purchase_service.dart`
// /// fragen hier, statt die Plattform-Prüfung je selbst zu schreiben.
// bool get isStorePlatform => isMobilePlatform;

/// Ob die App auf einem Mobilgerät (Android/iOS) läuft — dieselbe Prüfung,
/// aber für Fälle, in denen es nicht um Store-Dienste geht: die Übersicht-
/// Seite sperrt dort die Ausrichtung auf Querformat (siehe PLAN.md Phase 16),
/// während auf Desktop/Web das Fenster die Größe bestimmt.
bool get isMobilePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

// ---------------------------------------------------------------------------
// Was die Plattform **kann** (PLAN.md Phase 26.1)
//
// Bewusst nach Fähigkeit benannt, nicht nach Plattform: Der Aufrufer will
// wissen „gibt es hier Erinnerungen?", nicht „läuft das im Browser?". Kommt
// eine Plattform dazu, ändert sich diese Datei — und sonst keine. Deshalb
// steht `kIsWeb` **nur hier** und nirgends sonst im Code.
// ---------------------------------------------------------------------------

/// Ob geplante Erinnerungen möglich sind.
///
/// `flutter_local_notifications` hat keine Web-Umsetzung. Echte Web-Push-
/// Benachrichtigungen bräuchten einen Server, der Nachrichten zustellt — das
/// widerspricht Abschnitt 3 („kein Backend"). Im Browser entfallen sie
/// deshalb **sichtbar**: Die Rubrik verschwindet aus den Einstellungen,
/// statt Schalter anzubieten, die nichts auslösen.
bool get supportsReminders => !kIsWeb;

/// Ob es Startbildschirm-Widgets gibt (`home_widget` — nur Android/iOS).
///
/// Auf dem iPhone-Startbildschirm liegt bei der Web-Fassung nur die
/// Verknüpfung zur Seite; ein Widget kann eine Website nicht stellen.
bool get supportsHomeScreenWidgets => isMobilePlatform;

/// Ob die Daten im Speicher **des Browsers** liegen statt in einem
/// App-Verzeichnis (PLAN.md Phase 26.8).
///
/// Der Unterschied ist keine Feinheit: Ein App-Verzeichnis löscht nur der
/// Nutzer selbst. Den Speicher einer Website darf der Browser aufräumen —
/// **Safari löscht ihn nach sieben Tagen ohne Besuch**, sofern die Seite
/// nicht auf dem Home-Bildschirm liegt. Daran hängen der einmalige Hinweis
/// (`core/widgets/web_storage_hint.dart`) und die Bitte um dauerhaften
/// Speicher beim Start.
bool get usesBrowserStorage => kIsWeb;

/// Ob die App die Bildschirmausrichtung festlegen darf.
///
/// Im Browser gehört die Ausrichtung dem Gerät, nicht der Seite — die
/// Übersicht kann dort kein Querformat erzwingen (PLAN.md Phase 16).
bool get supportsOrientationLock => isMobilePlatform;

/// Ob sich die Kopfzeilen einer **fremden** Adresse lesen lassen
/// (PLAN.md Phase 26.11).
///
/// Auf Android/iOS ja — dort ist eine HTTP-Antwort einfach eine HTTP-Antwort.
/// Im Browser gibt eine fremde Adresse nur das frei, was sie per CORS
/// ausdrücklich erlaubt, und `Date` gehört **nicht** zu den ohne Zutun
/// sichtbaren Kopfzeilen. Die Uhr-Prüfung fragt deshalb im Browser die
/// **eigene** Adresse (siehe `core/services/time_service.dart`).
///
/// ⚠️ Betrifft nur die **Kopfzeilen**: Den *Inhalt* fremder Adressen liest
/// der Browser sehr wohl, sofern sie es erlauben — die Anleitungs-Texte von
/// `raw.githubusercontent.com` kommen genau so an.
bool get canReadForeignResponseHeaders => !kIsWeb;

/// Ob es in diesem Bau ein Nutzerkonto und eine Cloud-Sicherung gibt
/// (PLAN.md Phase 27).
///
/// Anders als die Abfragen darüber hängt diese **nicht an der Plattform**,
/// sondern daran, ob beim Bauen ein Supabase-Projekt hereingereicht wurde.
/// Sie steht trotzdem hier: Der Aufrufer stellt dieselbe Art von Frage
/// („gibt es das hier?") und soll dafür nicht zwei Orte kennen müssen.
///
/// ⚠️ **Ohne Schlüssel verhält sich die App exakt wie vor Phase 27** — keine
/// Anmelde-Seite, keine Rubrik „Konto & Cloud", kein einziger Netzaufruf zu
/// Supabase. Das ist kein Nebeneffekt, sondern der Zweck: Tests laufen ohne
/// Netz, ein lokaler Bau braucht keine Zugangsdaten, und fällt der Server
/// weg, bleibt die App vollständig benutzbar. **Wer eine Cloud-Funktion
/// baut, hängt sie an diese Abfrage** — sonst entsteht ein Knopf, der ins
/// Leere greift (dieselbe Regel wie bei den Erinnerungen im Browser).
bool get supportsCloudSync => AppConfig.hasSupabaseConfig;

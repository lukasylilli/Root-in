import 'package:flutter/foundation.dart';

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

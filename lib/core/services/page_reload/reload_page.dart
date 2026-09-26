/// Lädt die Seite im Browser neu (PLAN.md 31.7).
///
/// Gebraucht von der Fehlerseite (`core/widgets/app_error_view.dart`): Wer
/// dort landet, soll mit einem Tipp neu starten können, statt die Adresse
/// von Hand neu laden zu müssen.
///
/// Außerhalb des Browsers (nur noch die Tests) gibt es nichts neu zu laden;
/// dort tut die Funktion nichts.
library;

export 'reload_page_io.dart'
    if (dart.library.js_interop) 'reload_page_web.dart';

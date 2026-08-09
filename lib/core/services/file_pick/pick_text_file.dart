/// Lässt den Nutzer **eine Textdatei auswählen** und gibt deren Inhalt
/// zurück — `null`, wenn er abbricht.
///
/// Gebraucht von `core/services/backup_service.dart` beim Einlesen einer
/// Sicherung (PLAN.md Phase 9 und 26.1). Die Trennung besteht, weil Android/
/// iOS und der Browser dafür grundverschiedene Wege haben und sich
/// **gegenseitig nicht übersetzen lassen**:
///
/// - Mobil: `flutter_file_dialog` liefert einen **Pfad**, den `dart:io` liest.
/// - Browser: Es gibt keine Pfade. Ein verstecktes `<input type="file">`
///   liefert den Inhalt, `dart:io` gibt es dort nicht.
///
/// Die Wahl trifft der Compiler über den bedingten Export unten; deshalb kommt
/// in keiner der beiden Fassungen Code der anderen Plattform vor — `dart:io`
/// im Web-Bau würde beim Aufruf werfen, `dart:js_interop` im mobilen Bau
/// gar nicht erst übersetzen.
///
/// Der Rückgabewert ist bewusst der **Inhalt** und kein Pfad: So bleibt
/// `BackupService` frei von Plattform-Wissen und lässt sich weiter ohne
/// Gerät testen.
library;

export 'pick_text_file_io.dart'
    if (dart.library.js_interop) 'pick_text_file_web.dart';

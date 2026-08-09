import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser-Fassung von `pickTextFileContent` — siehe `pick_text_file.dart`
/// für den Grund der Aufteilung.
///
/// Im Browser gibt es keine Dateipfade. Der einzige Weg zu einer Datei des
/// Nutzers führt über ein `<input type="file">`, das angeklickt wird; erst
/// dessen `FileReader` liefert den Inhalt.
Future<String?> pickTextFileContent() {
  final input =
      web.document.createElement('input') as web.HTMLInputElement
        ..type = 'file'
        // Hinweis für den Datei-Dialog, keine Garantie: Der Nutzer kann die
        // Einschränkung in jedem Browser abwählen. Geprüft wird der Inhalt
        // deshalb weiterhin beim Auswerten (`BackupData.fromJson`).
        ..accept = 'application/json,.json';

  final completer = Completer<String?>();

  // Genau einmal abschließen. Manche Browser feuern `cancel` **und**
  // anschließend `change`; ein zweites `complete` wäre ein Fehler.
  void finish(String? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  void fail(Object error) {
    if (!completer.isCompleted) completer.completeError(error);
  }

  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      finish(null);
      return;
    }

    final reader = web.FileReader();
    reader.onload = ((web.Event _) {
      // `result` ist nach `readAsText` ein String; bei einer leeren Datei
      // kann er auch null sein.
      finish((reader.result as JSString?)?.toDart);
    }).toJS;
    reader.onerror = ((web.Event _) {
      fail(StateError('Die Datei konnte nicht gelesen werden.'));
    }).toJS;
    reader.readAsText(files.item(0)!);
  }).toJS;

  // Ohne `cancel` bliebe das Future nach einem Abbruch **für immer** offen —
  // der Nutzer sähe einen Ladezustand, der nie endet. Das Ereignis gibt es in
  // allen aktuellen Browsern einschließlich Safari.
  input.oncancel = ((web.Event _) => finish(null)).toJS;

  input.click();
  return completer.future;
}

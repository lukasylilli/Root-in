import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wächter gegen den Fehler aus PLAN.md Phase 26.10/26.11 (Lehre 30).
///
/// `import 'dart:io'` ist im Browser **kein Übersetzungsfehler**. Die
/// Bibliothek existiert dort als Attrappe: Sie baut mit, und erst der erste
/// Aufruf wirft `UnsupportedError`. Weder `flutter analyze` noch
/// `flutter build web` noch ein Testlauf auf der Dart-VM sehen davon etwas —
/// aufgefallen ist es erst dem Nutzer an der veröffentlichten Seite, wo drei
/// von vier Hauptseiten leer blieben.
///
/// Deshalb dieser Test: Er prüft nicht Verhalten, sondern eine **Regel**, die
/// sich sonst nirgends prüfen lässt. `dart:io` gehört in `lib/` nur in
/// Dateien, die über einen bedingten Import ausgewählt werden — die tragen
/// die Endung `_io.dart` und werden im Browser nie geladen.
void main() {
  test('lib/ enthält dart:io nur in bedingt geladenen *_io.dart-Dateien', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('_io.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('//')) continue;
        if (line.contains("'dart:io'") || line.contains('"dart:io"')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'dart:io läuft im Browser nicht. Diese Stellen würden dort erst zur '
          'Laufzeit werfen — und zwar still:\n${offenders.join('\n')}\n'
          'Ersatz: package:http für Netzzugriffe, ein bedingter Import '
          '(*_io.dart / *_web.dart) für alles, was wirklich Plattform braucht.',
    );
  });
}

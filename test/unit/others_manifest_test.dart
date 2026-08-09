import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/features/others/domain/others_manifest.dart';

/// PLAN.md Phase 22. Das Manifest ist **von Hand gepflegtes, fremdes JSON** —
/// ein Tippfehler im Repository landet ungefiltert in der App. Geprüft wird
/// deshalb vor allem, dass Fehler als klare Gründe herauskommen statt als
/// Absturz irgendwo tief im Widget-Baum.
OthersManifest _parse(String json) =>
    OthersManifest.fromJson(jsonDecode(json));

void main() {
  test('liest Ordner und Dateien', () {
    final manifest = _parse('''
      {
        "version": 1,
        "folders": [
          {
            "id": "news",
            "title": "📣 خبرها",
            "folder_path": "news",
            "order": 1,
            "files": [
              { "title": "شروع دوره", "file_path": "news/start.md" }
            ]
          }
        ]
      }
    ''');

    final folder = manifest.folders.single;
    expect(folder.id, 'news');
    // Emoji und persische Schrift kommen unverändert durch.
    expect(folder.title, '📣 خبرها');
    expect(folder.entries.single.title, 'شروع دوره');
    expect(folder.entries.single.filePath, 'news/start.md');
  });

  test('sortiert nach order, nicht nach Reihenfolge in der Datei', () {
    final manifest = _parse('''
      {"folders": [
        {"id": "c", "title": "C", "order": 30},
        {"id": "a", "title": "A", "order": 10},
        {"id": "b", "title": "B", "order": 20}
      ]}
    ''');

    expect(manifest.folders.map((f) => f.id), ['a', 'b', 'c']);
  });

  test('gleiche order behält die Reihenfolge der Datei', () {
    // Dart sortiert nicht stabil — ohne Zusatz-Kriterium sprängen gleich
    // eingeordnete Ordner bei jedem Laden.
    final manifest = _parse('''
      {"folders": [
        {"id": "erst", "title": "Erst", "order": 5},
        {"id": "dann", "title": "Dann", "order": 5},
        {"id": "zuletzt", "title": "Zuletzt", "order": 5}
      ]}
    ''');

    expect(manifest.folders.map((f) => f.id), ['erst', 'dann', 'zuletzt']);
  });

  test('fehlendes order stellt den Ordner hinten an, statt zu werfen', () {
    final manifest = _parse('''
      {"folders": [
        {"id": "ohne", "title": "Ohne"},
        {"id": "mit", "title": "Mit", "order": 1}
      ]}
    ''');

    expect(manifest.folders.map((f) => f.id), ['mit', 'ohne']);
  });

  test('Ordner ohne files ist gültig und leer', () {
    final manifest = _parse('{"folders": [{"id": "leer", "title": "Leer"}]}');

    expect(manifest.folders.single.entries, isEmpty);
  });

  test('kein Objekt an der Wurzel', () {
    expect(
      () => _parse('[]'),
      throwsA(
        isA<OthersManifestException>().having(
          (e) => e.reason,
          'reason',
          OthersManifestError.invalidFormat,
        ),
      ),
    );
  });

  test('folders fehlt', () {
    expect(
      () => _parse('{"version": 1}'),
      throwsA(
        isA<OthersManifestException>().having(
          (e) => e.reason,
          'reason',
          OthersManifestError.invalidFormat,
        ),
      ),
    );
  });

  test('Ordner ohne id', () {
    expect(
      () => _parse('{"folders": [{"title": "Ohne id"}]}'),
      throwsA(
        isA<OthersManifestException>().having(
          (e) => e.reason,
          'reason',
          OthersManifestError.incompleteEntry,
        ),
      ),
    );
  });

  test('Datei ohne file_path', () {
    expect(
      () => _parse('''
        {"folders": [
          {"id": "a", "title": "A", "files": [{"title": "Ohne Pfad"}]}
        ]}
      '''),
      throwsA(
        isA<OthersManifestException>()
            .having(
              (e) => e.reason,
              'reason',
              OthersManifestError.incompleteEntry,
            )
            // Der Grund nennt die Stelle — sonst sucht der Autor in einer
            // langen Datei blind.
            .having((e) => e.detail, 'detail', contains('Ohne Pfad')),
      ),
    );
  });

  test('das mitgelieferte Beispiel ist gültig', () async {
    // `store/others_index_beispiel.json` ist die Vorlage, die der Nutzer
    // hochlädt. Wäre sie fehlerhaft, führte die Anleitung in die Irre.
    final file = await _readExample();
    final manifest = OthersManifest.fromJson(jsonDecode(file));

    expect(manifest.folders.map((f) => f.id), ['news', 'tips', 'archive']);
    expect(manifest.folders.first.entries, hasLength(2));
    expect(manifest.folders.last.entries, isEmpty);
  });
}

Future<String> _readExample() async {
  // Pfad relativ zum Projekt-Wurzelverzeichnis; `flutter test` läuft dort.
  final file = File('store/others_index_beispiel.json');
  return file.readAsString();
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/repo_content_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/features/others/presentation/others_folder_page.dart';
import 'package:root_in/features/others/presentation/others_folders_page.dart';
import 'package:root_in/features/others/presentation/others_providers.dart';
import 'package:root_in/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/localized_app.dart';

/// PLAN.md Phase 22 — die Rubrik „موارد دیگر".
///
/// Der Netzzugriff wird über den [RepoFetcher] ersetzt; so lässt sich jeder
/// Fall stellen, der im Repository wirklich vorkommt: gültiges Manifest,
/// kaputtes JSON, fehlende Datei, kein Netz.
const _manifest = '''
{
  "version": 1,
  "folders": [
    {
      "id": "tips",
      "title": "💡 Tipps",
      "order": 2,
      "files": [{ "title": "Wörter lernen", "file_path": "tips/woerter.md" }]
    },
    {
      "id": "news",
      "title": "📣 Neuigkeiten",
      "order": 1,
      "files": [{ "title": "Kursstart", "file_path": "news/start.md" }]
    }
  ]
}
''';

/// Antwortet je nach angefragter Adresse.
RepoFetcher _server(Map<String, RepoFetchResult> routes) {
  return (Uri url) async {
    for (final entry in routes.entries) {
      if (url.path.endsWith(entry.key)) return entry.value;
    }
    throw const SocketException('kein Netz');
  };
}

Future<Widget> _wrap(Widget page, {required RepoFetcher fetch}) async {
  SharedPreferences.setMockInitialValues({'app_language': 'german'});
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      repoContentServiceProvider.overrideWithValue(
        RepoContentService(prefs, fetcher: fetch),
      ),
    ],
    child: localizedApp(page),
  );
}

void main() {
  testWidgets('zeigt die Ordner in der Reihenfolge aus dem Manifest', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrap(
        const OthersFoldersPage(),
        fetch: _server({'index.json': (status: 200, body: _manifest)}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('📣 Neuigkeiten'), findsOneWidget);
    expect(find.text('💡 Tipps'), findsOneWidget);
    // `order` schlägt die Reihenfolge in der Datei: news (1) vor tips (2).
    final positions = tester.getTopLeft(find.text('📣 Neuigkeiten')).dy;
    expect(positions, lessThan(tester.getTopLeft(find.text('💡 Tipps')).dy));
    // Die Zahl der Beiträge steht unter dem Titel.
    expect(find.text('1 Beitrag'), findsNWidgets(2));
  });

  testWidgets('kaputtes Manifest meldet den Grund statt abzustürzen', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrap(
        const OthersFoldersPage(),
        fetch: _server({'index.json': (status: 200, body: '{ kaputt ')}),
      ),
    );
    await tester.pumpAndSettle();

    // Der Autor soll erfahren, dass **seine Datei** das Problem ist — nicht
    // die Verbindung des Nutzers.
    expect(find.text('Inhalt nicht lesbar'), findsOneWidget);
    expect(find.text('Kein Internet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fehlendes Manifest ist ein leerer Kanal, kein Fehler', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrap(
        const OthersFoldersPage(),
        fetch: _server({'index.json': (status: 404, body: null)}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inhalt folgt'), findsOneWidget);
    expect(find.text('Inhalt nicht lesbar'), findsNothing);
  });

  testWidgets('ohne Netz und ohne Speicher kommt der Wiederholen-Knopf', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrap(const OthersFoldersPage(), fetch: _server(const {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kein Internet'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });

  testWidgets('ein Ordner zeigt seine Beiträge und lädt den Text erst beim '
      'Aufklappen', (tester) async {
    var textCalls = 0;
    await tester.pumpWidget(
      await _wrap(
        const OthersFolderPage(folderId: 'news'),
        fetch: (url) async {
          if (url.path.endsWith('index.json')) {
            return (status: 200, body: _manifest);
          }
          if (url.path.endsWith('news/start.md')) {
            textCalls++;
            return (status: 200, body: '# Kursstart\n\nAb Montag.');
          }
          throw const SocketException('kein Netz');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kursstart'), findsOneWidget);
    // Ein Ordner mit zwanzig Beiträgen soll nicht zwanzig Abrufe auslösen.
    expect(textCalls, 0);

    await tester.tap(find.text('Kursstart'));
    await tester.pumpAndSettle();

    expect(textCalls, 1);
    expect(find.textContaining('Ab Montag'), findsOneWidget);
  });

  testWidgets('ein unbekannter Ordner bricht nicht', (tester) async {
    // Die Route bleibt im Verlauf stehen, während der Autor den Ordner im
    // Repository umbenennt.
    await tester.pumpWidget(
      await _wrap(
        const OthersFolderPage(folderId: 'gibt-es-nicht'),
        fetch: _server({'index.json': (status: 200, body: _manifest)}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inhalt folgt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Einstellungen führen unter „Wichtige Links" zur Rubrik', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: localizedApp(const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Weitere Themen'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    // Der Nutzer wollte den Eintrag ausdrücklich **unter** „Wichtige Links".
    expect(
      tester.getTopLeft(find.text('Wichtige Links')).dy,
      lessThan(tester.getTopLeft(find.text('Weitere Themen')).dy),
    );
  });

  test('Pfade zeigen in den Sprachordner', () {
    expect(othersManifestPath('fa'), 'others/fa/index.json');
    expect(
      othersEntryPath('fa', 'news/start.md'),
      'others/fa/news/start.md',
    );
  });
}

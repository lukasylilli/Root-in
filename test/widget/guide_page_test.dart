import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/repo_content_service.dart';
// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// import 'package:root_in/core/services/purchase_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/features/guide/presentation/guide_document.dart';
import 'package:root_in/features/guide/presentation/guide_page.dart';
import 'package:root_in/features/guide/presentation/guide_topic.dart';
import 'package:root_in/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../support/fake_purchase_service.dart';
import '../support/localized_app.dart';

/// Baut die Seite mit einem Dienst, der statt des Netzes [fetch] befragt.
Future<Widget> _wrapGuide(
  GuideTopic topic, {
  required RepoFetcher fetch,
  String? language,
  Locale locale = const Locale('de'),
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      repoContentServiceProvider.overrideWithValue(
        RepoContentService(prefs, fetcher: fetch),
      ),
      // Persisch ist (noch) keine wählbare App-Sprache — für den
      // Laufrichtungs-Test wird die Inhalts-Sprache direkt gesetzt.
      if (language != null) guideLanguageProvider.overrideWithValue(language),
    ],
    child: localizedApp(GuidePage(topic: topic), locale: locale),
  );
}

Future<Widget> _wrapSettings() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: localizedApp(const SettingsPage()),
  );
}

void main() {
  testWidgets('Einstellungen zeigen die Rubrik mit allen vier Anleitungen', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrapSettings());

    await tester.scrollUntilVisible(
      find.text('Wichtige Links'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Root-in Anleitung'), findsOneWidget);
    expect(find.text('Lernplanung'), findsOneWidget);
    expect(find.text('Lernquellen'), findsOneWidget);
    expect(find.text('Lernmethode'), findsOneWidget);
    expect(find.text('Wichtige Links'), findsOneWidget);

    // Der alte Platzhalter ist weg.
    expect(find.text('Others — noch offen'), findsNothing);
  });

  testWidgets('Jedes Thema hat eine eigene Route und je Sprache eine Datei', (
    tester,
  ) async {
    final routes = {for (final topic in GuideTopic.values) topic.route};

    expect(routes.length, GuideTopic.values.length);
    expect(routes, everyElement(startsWith('/guide/')));

    // Diese Namen stehen so im Inhalts-Repository und folgen bewusst keinem
    // Muster. Ein Tippfehler fiele sonst erst in der veröffentlichten App
    // auf — und zwar als „Inhalt folgt", also nicht als Fehler.
    expect(GuideTopic.studyPlanning.fileName('de'), 'lernplanung');
    expect(GuideTopic.studyPlanning.fileName('fa'), 'lernplanung');
    expect(GuideTopic.studyResources.fileName('de'), 'lernquellen_a1');
    expect(GuideTopic.studyResources.fileName('en'), 'lernquellen_a1_en');
    expect(GuideTopic.studyMethod.fileName('fa'), 'lernmethode_fa');
    expect(GuideTopic.essentialLinks.fileName('en'), 'links_en');

    // Je Sprache müssen die vier Themen auf vier verschiedene Dateien zeigen.
    for (final language in guideContentLanguages) {
      final files = {
        for (final topic in GuideTopic.values) topic.fileName(language),
      };
      expect(files.length, GuideTopic.values.length, reason: language);
    }

    // Unbekannte Sprache → deutscher Text statt leerer Seite (wie
    // `guideLanguageCode`).
    expect(GuideTopic.studyMethod.fileName('tr'), 'lernmethode_de');
  });

  testWidgets('erst Ladekreis, dann der geladene Text', (tester) async {
    final response = Completer<RepoFetchResult>();

    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyPlanning,
        fetch: (_) => response.future,
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Anleitung wird geladen …'), findsOneWidget);

    response.complete((status: 200, body: '# Titel\n\nEin Absatz.'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('Ein Absatz.'), findsOneWidget);
  });

  testWidgets('ohne Netz und ohne gespeicherten Stand: Hinweis + Knopf', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyPlanning,
        fetch: (_) => throw const SocketException('kein Netz'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kein Internet'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
  });

  testWidgets('404 zeigt weiterhin „Inhalt folgt"', (tester) async {
    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyResources,
        fetch: (_) async => (status: 404, body: null),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inhalt folgt'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
  });

  testWidgets('persischer Text läuft von rechts nach links', (tester) async {
    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyPlanning,
        language: 'fa',
        fetch: (_) async => (status: 200, body: '# برنامه‌ریزی مطالعه'),
      ),
    );
    await tester.pumpAndSettle();

    // Die Laufrichtung hängt am Text, nicht an der App: Der Rahmen bleibt
    // deutsch (LTR), der Inhalt wird trotzdem rechtsläufig gesetzt.
    final direction = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.byType(MarkdownBody),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(direction.textDirection, TextDirection.rtl);
  });

  testWidgets('die Sprache bestimmt die Adresse des Textes', (tester) async {
    final urls = <Uri>[];

    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyPlanning,
        locale: const Locale('en'),
        fetch: (url) async {
          urls.add(url);
          return (status: 200, body: 'content');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(urls.single.toString(), endsWith('/content/en/lernplanung.md'));
  });

  testWidgets('die Sprache bestimmt auch den Dateinamen', (tester) async {
    final urls = <Uri>[];

    // Anders als bei Lernplanung heißt die Datei je Sprache anders — der
    // Sprachcode muss also bis in den Dateinamen durchschlagen, nicht nur in
    // den Ordner.
    await tester.pumpWidget(
      await _wrapGuide(
        GuideTopic.studyResources,
        language: 'fa',
        fetch: (url) async {
          urls.add(url);
          return (status: 200, body: 'محتوا');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(
      urls.single.toString(),
      endsWith('/content/fa/lernquellen_a1_fa.md'),
    );
  });
}

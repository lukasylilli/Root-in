import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/features/today/presentation/today_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

final _today = DateTime(2026, 7, 23);

Future<void> _pumpTodayPage(WidgetTester tester, AppDatabase db) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        timeServiceProvider.overrideWithValue(TestTimeService(_today)),
      ],
      child: localizedApp(const TodayPage()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _addHabits(AppDatabase db, List<String> names) async {
  for (final name in names) {
    await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: 0xFF000000,
        category: const Value('Allgemein'),
        goalType: HabitGoalType.checkbox,
      ),
    );
  }
}

void main() {
  testWidgets('Kopfbereich zeigt Tagesring, Punkte und Erledigt-Zähler', (
    tester,
  ) async {
    final db = createTestDatabase();
    await _addHabits(db, ['Laufen', 'Lesen']);
    await db.habitCompletionDao.setCompleted(1, _today);

    await _pumpTodayPage(tester, db);

    // 1 von 2 erledigt → Ring zeigt 50, Punkte 10, Erledigt 1/2.
    expect(find.text('50'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Laufen'), findsOneWidget);
    expect(find.text('Lesen'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  group('Randfälle (PLAN.md Phase 13)', () {
    testWidgets('ohne Gewohnheiten steht ein Hinweis statt einer Liste', (
      tester,
    ) async {
      // Leerer Bestand ist der häufigste Absturz-Kandidat (PLAN.md Phase
      // 21.3) — hier zusätzlich die Division durch null im Tagesring:
      // `DailyProgress.percent` fängt `totalCount == 0` ab.
      final db = createTestDatabase();
      await _pumpTodayPage(tester, db);

      expect(
        find.text('Noch keine Gewohnheiten. Mit + eine hinzufügen.'),
        findsOneWidget,
      );
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('0'), findsWidgets); // Ring und Punkte
      expect(find.text('0/0'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeAndFlush(tester);
    });

    testWidgets('alles erledigt zeigt 100 %', (tester) async {
      // Der Ring rechnet in Prozent; 100 ist der einzige dreistellige Wert,
      // der dort je steht — er muss in den Ring passen, nicht daneben.
      final db = createTestDatabase();
      await _addHabits(db, ['Laufen', 'Lesen']);
      await db.habitCompletionDao.setCompleted(1, _today);
      await db.habitCompletionDao.setCompleted(2, _today);

      await _pumpTodayPage(tester, db);

      expect(find.text('100'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeAndFlush(tester);
    });

    testWidgets('sehr langer Name läuft nicht über', (tester) async {
      // Lehre 18: Ein Überlauf ist in der Vorschau unsichtbar und fällt erst
      // am Gerät auf. Persische und deutsche Namen sind teils deutlich
      // länger als die englischen Vorlagen.
      const longName =
          'Jeden Morgen dreißig Minuten unregelmäßige Verben wiederholen '
          'und danach den Wortschatz des Vortages abfragen';
      final db = createTestDatabase();
      await _addHabits(db, [longName]);

      await _pumpTodayPage(tester, db);

      expect(find.text(longName), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeAndFlush(tester);
    });

    testWidgets('viele Gewohnheiten bleiben scrollbar', (tester) async {
      // Die Seite ist eine ListView — ein Raster fester Höhe wäre bei
      // zwanzig Einträgen übergelaufen. Der letzte Eintrag ist erst nach
      // dem Scrollen sichtbar, aber er ist erreichbar.
      final db = createTestDatabase();
      await _addHabits(db, [for (var i = 1; i <= 20; i++) 'Gewohnheit $i']);

      await _pumpTodayPage(tester, db);

      expect(find.text('Gewohnheit 20'), findsNothing);
      await tester.scrollUntilVisible(find.text('Gewohnheit 20'), 200);
      expect(find.text('Gewohnheit 20'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeAndFlush(tester);
    });

    testWidgets('Abhaken schlägt sofort auf Ring und Zähler durch', (
      tester,
    ) async {
      final db = createTestDatabase();
      await _addHabits(db, ['Laufen', 'Lesen']);

      await _pumpTodayPage(tester, db);
      expect(find.text('0/2'), findsOneWidget);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });
}

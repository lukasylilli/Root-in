import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/data/repositories/habit_repository.dart';
import 'package:root_in/features/today/presentation/today_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// PLAN.md Phase 24: Die Heute-Seite zeigt einen **wählbaren** Tag. Geprüft
/// wird, was dabei schiefgehen kann — dass das Häkchen auf dem falschen Tag
/// landet, dass die Zukunft eintragbar wird, und dass Widget/Karte
/// versehentlich mitwandern.
final _today = DateTime(2026, 7, 23);
final _yesterday = DateTime(2026, 7, 22);

Future<(AppDatabase, Widget)> _setUp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = createTestDatabase();

  for (final name in ['Laufen', 'Lesen']) {
    await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: 0xFF000000,
        category: const Value('Allgemein'),
        goalType: HabitGoalType.checkbox,
      ),
    );
  }
  // Nur gestern erledigt — heute ist damit leer.
  await db.habitCompletionDao.setCompleted(1, _yesterday);

  return (
    db,
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        timeServiceProvider.overrideWithValue(TestTimeService(_today)),
      ],
      child: localizedApp(const TodayPage()),
    ),
  );
}

void main() {
  testWidgets('startet auf heute und zeigt den heutigen Stand', (tester) async {
    final (_, app) = await _setUp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Heute'), findsWidgets);
    // Heute ist nichts erledigt, gestern schon — der Zähler muss 0/2 zeigen.
    expect(find.text('0/2'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('ein Tag zurück zeigt die Erledigungen von gestern', (
    tester,
  ) async {
    final (_, app) = await _setUp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Gestern'), findsOneWidget);
    // Der Stand von gestern, nicht der von heute.
    expect(find.text('1/2'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('Abhaken schreibt auf den gewählten Tag, nicht auf heute', (
    tester,
  ) async {
    final (db, app) = await _setUp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    // „Lesen" (Habit 2) für gestern nachtragen.
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    // ⚠️ `runAsync`: Drift liefert Stream-Ergebnisse über einen Timer, und im
    // Widget-Test steht die Uhr still — ein blankes `await …first` hängt hier
    // bis zum Timeout (dieselbe Ursache wie bei `disposeAndFlush`).
    final days = await tester.runAsync(() async {
      return (
        gestern: await db.habitCompletionDao
            .watchCompletionsForDate(_yesterday)
            .first,
        heute: await db.habitCompletionDao
            .watchCompletionsForDate(_today)
            .first,
      );
    });
    final gestern = days!.gestern;
    final heute = days.heute;

    expect(gestern.map((c) => c.habitId), containsAll(<int>[1, 2]));
    // Der springende Punkt: Heute darf davon nichts abbekommen haben.
    expect(heute, isEmpty);

    await disposeAndFlush(tester);
  });

  testWidgets('die Zukunft ist gesperrt', (tester) async {
    final (_, app) = await _setUp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Auf heute führt der Vorwärts-Pfeil nirgendwohin — was noch nicht war,
    // kann nicht erledigt sein.
    final forward = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.chevron_right),
        matching: find.byType(IconButton),
      ),
    );
    expect(forward.onPressed, isNull);

    await disposeAndFlush(tester);
  });

  testWidgets('„Heute" springt zurück', (tester) async {
    final (_, app) = await _setUp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Gestern'), findsOneWidget);

    // Der Zurück-Knopf erscheint erst, wenn ein anderer Tag gewählt ist.
    await tester.tap(find.widgetWithText(TextButton, 'Heute').last);
    await tester.pumpAndSettle();

    expect(find.text('Gestern'), findsNothing);
    expect(find.text('0/2'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  // Bewusst `test` statt `testWidgets`: Ohne Widget-Baum braucht es keinen
  // und der echte Event-Loop lässt Drifts Streams von selbst liefern.
  test('Widget und Karte bleiben auf heute', () async {
    // `todayProgressProvider` speist Startbildschirm-Widget, Home-Seite und
    // Fortschritts-Karte. Wandert er mit dem gewählten Datum mit, zeigt das
    // Widget irgendwann 2018 — genau das darf nicht passieren.
    final (db, _) = await _setUp();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        timeServiceProvider.overrideWithValue(TestTimeService(_today)),
      ],
    );
    addTearDown(container.dispose);

    // Provider am Leben halten, sonst verwirft Riverpod die Drift-Streams.
    container.listen(todayProgressProvider, (_, _) {});
    container.listen(selectedDayProgressProvider, (_, _) {});
    await container.read(todayProvider.future);
    await pumpEventQueue();

    container.read(selectedDateOverrideProvider.notifier).select(_yesterday);
    await pumpEventQueue();

    expect(container.read(selectedDayProgressProvider).completedCount, 1);
    expect(container.read(todayProgressProvider).completedCount, 0);
  });
}

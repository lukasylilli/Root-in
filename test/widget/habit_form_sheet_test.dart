import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/features/habits/presentation/habit_form_sheet.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';

void main() {
  testWidgets(
    'Bearbeiten-Modus zeigt vorhandene Werte und kann löschen',
    (tester) async {
      final db = createTestDatabase();
      await db.categoryDao.getOrCreateCategory('Sport');
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Laufen',
          colorValue: 0xFF000000,
          category: const Value('Sport'),
          goalType: HabitGoalType.checkbox,
        ),
      );
      final habit = (await db.habitDao.habitById(habitId))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: localizedApp(
            Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => HabitFormSheet(existing: habit),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Laufen'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Speichern'), findsOneWidget);
      expect(find.text('Gewohnheit löschen'), findsOneWidget);

      await tester.tap(find.text('Gewohnheit löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(await db.habitDao.habitById(habitId), isNull);

      await disposeAndFlush(tester);
    },
  );

  Future<void> openSheet(
    WidgetTester tester,
    AppDatabase db, {
    Habit? existing,
  }) async {
    // Hoch genug, dass das ganze Formular ohne Scrollen sichtbar ist.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: localizedApp(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => HabitFormSheet(existing: existing),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // PLAN.md Phase 32: Wochenplan im Formular.
  group('Wochenplan', () {
    testWidgets('bestimmte Tage wählen und speichern', (tester) async {
      final db = createTestDatabase();
      await db.categoryDao.getOrCreateCategory('Sport');
      await openSheet(tester, db);

      await tester.enterText(find.byType(TextField), 'Yoga');
      await tester.tap(find.text('Bestimmte Tage'));
      await tester.pumpAndSettle();

      // Noch kein Tag gewählt: Der Grund steht da, „Hinzufügen" ist aus.
      expect(find.text('Wähle mindestens einen Tag.'), findsOneWidget);
      final addButton = find.widgetWithText(FilledButton, 'Hinzufügen');
      expect(tester.widget<FilledButton>(addButton).onPressed, isNull);

      await tester.tap(find.widgetWithText(FilterChip, 'Di'));
      await tester.tap(find.widgetWithText(FilterChip, 'Do'));
      await tester.pumpAndSettle();

      expect(find.text('Wähle mindestens einen Tag.'), findsNothing);
      expect(tester.widget<FilledButton>(addButton).onPressed, isNotNull);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final habits = await db.select(db.habits).get();
      expect(habits, hasLength(1));
      expect(habits.single.name, 'Yoga');
      // Dienstag = Bit 1, Donnerstag = Bit 3 → 2 + 8; Wochen-Soll = 2.
      expect(habits.single.scheduleDays, 10);
      expect(habits.single.timesPerWeek, 2);

      await disposeAndFlush(tester);
    });

    testWidgets('x-mal pro Woche speichert das Soll und lässt alle Tage offen', (
      tester,
    ) async {
      final db = createTestDatabase();
      await db.categoryDao.getOrCreateCategory('Sport');
      await openSheet(tester, db);

      await tester.enterText(find.byType(TextField), 'Lesen');
      await tester.tap(find.text('Anzahl pro Woche'));
      await tester.pumpAndSettle();

      // Voreinstellung 3; der Wert steht neben dem Regler.
      expect(find.text('3× pro Woche'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Hinzufügen'));
      await tester.pumpAndSettle();

      final habit = (await db.select(db.habits).get()).single;
      expect(habit.scheduleDays, 127);
      expect(habit.timesPerWeek, 3);

      await disposeAndFlush(tester);
    });

    testWidgets('ohne Änderung bleibt es „jeden Tag"', (tester) async {
      final db = createTestDatabase();
      await db.categoryDao.getOrCreateCategory('Sport');
      await openSheet(tester, db);

      await tester.enterText(find.byType(TextField), 'Wörter');
      await tester.tap(find.widgetWithText(FilledButton, 'Hinzufügen'));
      await tester.pumpAndSettle();

      final habit = (await db.select(db.habits).get()).single;
      expect(habit.scheduleDays, 127);
      expect(habit.timesPerWeek, 7);

      await disposeAndFlush(tester);
    });

    testWidgets('Bearbeiten zeigt den vorhandenen Plan und speichert Änderungen', (
      tester,
    ) async {
      final db = createTestDatabase();
      await db.categoryDao.getOrCreateCategory('Sport');
      final id = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Yoga',
          colorValue: 0xFF000000,
          category: const Value('Sport'),
          goalType: HabitGoalType.checkbox,
          scheduleDays: const Value(10), // Di + Do
          timesPerWeek: const Value(2),
        ),
      );
      final habit = (await db.habitDao.habitById(id))!;
      await openSheet(tester, db, existing: habit);

      // Der Modus und die zwei Tage sind vorbelegt.
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bestimmte Tage'))
            .selected,
        isTrue,
      );
      FilterChip chip(String label) =>
          tester.widget<FilterChip>(find.widgetWithText(FilterChip, label));
      expect(chip('Di').selected, isTrue);
      expect(chip('Do').selected, isTrue);
      expect(chip('Mi').selected, isFalse);

      await tester.tap(find.widgetWithText(FilterChip, 'Fr'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Speichern'));
      await tester.pumpAndSettle();

      final saved = (await db.habitDao.habitById(id))!;
      // Di + Do + Fr = 2 + 8 + 16; Soll = 3.
      expect(saved.scheduleDays, 26);
      expect(saved.timesPerWeek, 3);

      await disposeAndFlush(tester);
    });
  });
}

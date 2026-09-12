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
}

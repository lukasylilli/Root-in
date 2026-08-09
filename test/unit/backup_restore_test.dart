import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('replaceAll ersetzt den Bestand und erhält die Verweise', () async {
    // Vorhandener Bestand, der überschrieben werden soll.
    await db.categoryDao.getOrCreateCategory('Alt');
    final oldId = await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: 'Alte Gewohnheit',
        colorValue: 0xFF000000,
        category: const Value('Alt'),
        goalType: HabitGoalType.checkbox,
      ),
    );
    await db.habitCompletionDao.setCompleted(oldId, DateTime(2026, 7, 1));

    final restoredHabit = Habit(
      id: 42,
      name: 'Laufen',
      iconKey: 'task_alt',
      colorValue: 0xFF112233,
      category: 'Sport',
      goalType: HabitGoalType.checkbox,
      targetMinutes: null,
      timesPerWeek: 7,
      startDate: DateTime(2026, 7, 1),
      createdAt: DateTime(2026, 7, 1),
      archived: false,
      reminderEnabled: false,
      reminderMinuteOfDay: null,
    );

    await db.backupDao.replaceAll(
      newCategories: [const Category(id: 5, name: 'Sport')],
      newHabits: [restoredHabit],
      newCompletions: [
        HabitCompletion(
          id: 9,
          habitId: 42,
          date: DateTime(2026, 7, 20),
          valueMinutes: null,
          completedAt: DateTime(2026, 7, 20),
        ),
      ],
    );

    final habits = await db.backupDao.allHabits();
    expect(habits.map((h) => h.name), ['Laufen']);
    // ID erhalten, damit die Erledigung weiterhin auf die Gewohnheit zeigt.
    expect(habits.single.id, 42);

    final completions = await db.backupDao.allCompletions();
    expect(completions.single.habitId, 42);

    final categories = await db.backupDao.allCategories();
    expect(categories.map((c) => c.name), ['Sport']);
  });

  test('allHabits liefert auch archivierte Gewohnheiten', () async {
    final id = await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: 'Archiviert',
        colorValue: 0xFF000000,
        goalType: HabitGoalType.checkbox,
      ),
    );
    await db.habitDao.archiveHabit(id);

    // watchActiveHabits blendet sie aus — eine Sicherung muss sie behalten.
    expect(await db.habitDao.watchActiveHabits().first, isEmpty);
    expect(await db.backupDao.allHabits(), hasLength(1));
  });
}

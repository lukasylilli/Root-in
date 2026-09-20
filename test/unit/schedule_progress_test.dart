import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/data/models/habit_schedule.dart';
import 'package:root_in/data/repositories/habit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// PLAN.md Phase 32: Was der Wochenplan an den Zahlen ändert, die die App
/// zeigt — Nenner der Heatmap und des Zeitraum-Prozents, gespeicherte Spalten
/// und Streak-Werte am Repository. Reine Container-Tests ohne Widget-Baum.
void main() {
  // Woche: Montag 20.07.2026 bis Sonntag 26.07.2026.
  final monday = DateTime(2026, 7, 20);
  final sunday = DateTime(2026, 7, 26);
  DateTime day(int offset) => DateTime(2026, 7, 20 + offset);

  late AppDatabase db;
  late ProviderContainer container;

  Future<int> addHabit(String name, HabitSchedule schedule) {
    return db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: 0xFF000000,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
        scheduleDays: Value(schedule.dayMask),
        timesPerWeek: Value(schedule.weeklyTarget),
      ),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = createTestDatabase();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        timeServiceProvider.overrideWithValue(TestTimeService(sunday)),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  /// Hält die Stream-Provider am Leben und wartet auf ihren ersten Wert —
  /// ohne Zuhörer verwirft Riverpod sie sofort und `.future` hängt für immer
  /// (PLAN.md Lehre 6).
  Future<void> settle(DateRange range) async {
    container.listen(activeHabitsProvider, (_, _) {});
    container.listen(allCompletionsProvider, (_, _) {});
    container.listen(completionsInRangeProvider(range), (_, _) {});
    await container.read(activeHabitsProvider.future);
    await container.read(allCompletionsProvider.future);
    await container.read(completionsInRangeProvider(range).future);
  }

  group('Repository speichert den Wochenplan', () {
    test('addHabit ohne Plan ist „jeden Tag"', () async {
      final repo = container.read(habitRepositoryProvider);

      final id = await repo.addHabit(
        name: 'Wörter',
        colorValue: 0xFF000000,
        iconKey: 'task_alt',
        category: 'Sport',
        goalType: HabitGoalType.checkbox,
      );

      final habit = (await db.habitDao.habitById(id))!;
      expect(habit.scheduleDays, 127);
      expect(habit.timesPerWeek, 7);
      expect(habit.schedule, const HabitSchedule.everyDay());
    });

    test('addHabit schreibt Maske und Wochen-Soll aus einer Quelle', () async {
      final repo = container.read(habitRepositoryProvider);

      final id = await repo.addHabit(
        name: 'Yoga',
        colorValue: 0xFF000000,
        iconKey: 'task_alt',
        category: 'Sport',
        goalType: HabitGoalType.checkbox,
        schedule: HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );

      final habit = (await db.habitDao.habitById(id))!;
      expect(habit.scheduleDays, 10);
      expect(habit.timesPerWeek, 2);
      expect(habit.schedule.weekdays, [2, 4]);
    });

    test('updateHabit ändert den Plan — und ohne Plan lässt er ihn stehen', () async {
      final repo = container.read(habitRepositoryProvider);
      final id = await addHabit(
        'Yoga',
        HabitSchedule.onDays([DateTime.tuesday]),
      );

      // Ein Bearbeiten, das den Plan nicht erwähnt, darf ihn nicht
      // zurücksetzen (dasselbe Prinzip wie beim Teil-Update im DAO).
      await repo.updateHabit(
        id: id,
        name: 'Yoga neu',
        category: 'Sport',
        goalType: HabitGoalType.checkbox,
      );
      var habit = (await db.habitDao.habitById(id))!;
      expect(habit.name, 'Yoga neu');
      expect(habit.scheduleDays, 2);

      await repo.updateHabit(
        id: id,
        name: 'Yoga neu',
        category: 'Sport',
        goalType: HabitGoalType.checkbox,
        schedule: HabitSchedule.countPerWeek(4),
      );
      habit = (await db.habitDao.habitById(id))!;
      expect(habit.scheduleDays, 127);
      expect(habit.timesPerWeek, 4);
      expect(habit.schedule, HabitSchedule.countPerWeek(4));
    });

    test('die Serie einer Gewohnheit folgt ihrem Plan', () async {
      final repo = container.read(habitRepositoryProvider);
      final id = await addHabit(
        'Yoga',
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );
      // Di + Do der Vorwoche und dieser Woche.
      for (final offset in [-6, -4, 1, 3]) {
        await db.habitCompletionDao.setCompleted(id, day(offset));
      }

      // Sonntag, heute kein Termin: Beide Wochen zählen, nichts bricht.
      final streak = await repo.currentStreakForHabit(
        id,
        sunday,
        schedule: HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );
      expect(streak, 4);
    });
  });

  group('Nenner von Heatmap und Prozent', () {
    test('Fälligkeit je Tag: „jeden Tag" immer, feste Tage nur an ihren', () async {
      final range = (start: monday, end: sunday);
      await addHabit('Laufen', const HabitSchedule.everyDay());
      await addHabit(
        'Yoga',
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );
      await settle(range);

      final due = container.read(dailyDueCountProvider(range));

      expect(due[day(0)], 1); // Montag: nur Laufen
      expect(due[day(1)], 2); // Dienstag: Laufen + Yoga
      expect(due[day(2)], 1);
      expect(due[day(3)], 2); // Donnerstag
      expect(due[day(6)], 1);
    });

    test('Intensität rechnet gegen die fälligen Gewohnheiten, nicht gegen alle', () async {
      final range = (start: monday, end: sunday);
      final laufen = await addHabit('Laufen', const HabitSchedule.everyDay());
      final yoga = await addHabit(
        'Yoga',
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );
      // Montag: nur Laufen (1 von 1). Dienstag: beide (2 von 2).
      await db.habitCompletionDao.setCompleted(laufen, day(0));
      await db.habitCompletionDao.setCompleted(laufen, day(1));
      await db.habitCompletionDao.setCompleted(yoga, day(1));
      await settle(range);

      final intensity = container.read(dailyIntensityProvider(range));

      // Vor Phase 32 wäre der Montag 1 von 2 = 0,5 gewesen — obwohl an diesem
      // Tag nichts anderes anstand.
      expect(intensity[day(0)], 1.0);
      expect(intensity[day(1)], 1.0);
      expect(intensity[day(2)], isNull);
    });

    test('Zeitraum-Prozent zählt nur Tage, an denen etwas ansteht', () async {
      final range = (start: monday, end: sunday);
      final yoga = await addHabit(
        'Yoga',
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      );
      // Dienstag erledigt, Donnerstag nicht.
      await db.habitCompletionDao.setCompleted(yoga, day(1));
      await settle(range);

      final percent = container.read(rangeProgressPercentProvider(range));

      // Zwei fällige Tage (Di, Do), einer davon voll: 1 / 2. Sieben Tage als
      // Nenner ergäben 1 / 7 und bestraften jeden freien Tag.
      expect(percent, closeTo(0.5, 1e-9));
    });

    test('mit „jeden Tag" bleibt alles wie vor Phase 32', () async {
      final range = (start: monday, end: sunday);
      final laufen = await addHabit('Laufen', const HabitSchedule.everyDay());
      await db.habitCompletionDao.setCompleted(laufen, day(0));
      await db.habitCompletionDao.setCompleted(laufen, day(1));
      await settle(range);

      // Zwei volle Tage von sieben.
      expect(
        container.read(rangeProgressPercentProvider(range)),
        closeTo(2 / 7, 1e-9),
      );
    });
  });
}

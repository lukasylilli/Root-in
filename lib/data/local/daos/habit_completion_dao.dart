import 'package:drift/drift.dart';

import '../../../core/utils/date_utils.dart';
import '../database.dart';
import '../tables/habit_completions_table.dart';

part 'habit_completion_dao.g.dart';

@DriftAccessor(tables: [HabitCompletions])
class HabitCompletionDao extends DatabaseAccessor<AppDatabase>
    with _$HabitCompletionDaoMixin {
  HabitCompletionDao(super.db);

  Stream<List<HabitCompletion>> watchCompletionsForDate(DateTime date) {
    final day = dateOnly(date);
    return (select(
      habitCompletions,
    )..where((c) => c.date.equals(day))).watch();
  }

  /// Alle Erledigungen (über alle Habits) im Zeitraum [from]–[to] inklusive.
  /// Grundlage für Matrix-Grid und Statistik-Seiten.
  Stream<List<HabitCompletion>> watchCompletionsInRange(
    DateTime from,
    DateTime to,
  ) {
    return (select(habitCompletions)..where(
          (c) => c.date.isBetweenValues(dateOnly(from), dateOnly(to)),
        ))
        .watch();
  }

  /// Alle Erledigungen über die gesamte Lebenszeit der App — Grundlage für
  /// die lebenslange Statistik/Achievements auf der Konto-Seite.
  Stream<List<HabitCompletion>> watchAllCompletions() {
    return select(habitCompletions).watch();
  }

  Stream<List<HabitCompletion>> watchCompletionsForHabit(int habitId) {
    return (select(
      habitCompletions,
    )..where((c) => c.habitId.equals(habitId))).watch();
  }

  Future<List<HabitCompletion>> completionsForHabitSince(
    int habitId,
    DateTime since,
  ) {
    final sinceDay = dateOnly(since);
    return (select(habitCompletions)..where(
          (c) => c.habitId.equals(habitId) & c.date.isBiggerOrEqualValue(sinceDay),
        ))
        .get();
  }

  Future<bool> isCompleted(int habitId, DateTime date) async {
    final day = dateOnly(date);
    final row =
        await (select(habitCompletions)..where(
              (c) => c.habitId.equals(habitId) & c.date.equals(day),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> setCompleted(
    int habitId,
    DateTime date, {
    bool completed = true,
    int? valueMinutes,
  }) async {
    final day = dateOnly(date);
    if (completed) {
      await into(habitCompletions).insert(
        HabitCompletionsCompanion.insert(
          habitId: habitId,
          date: day,
          valueMinutes: Value(valueMinutes),
        ),
        mode: InsertMode.insertOrReplace,
      );
    } else {
      await (delete(habitCompletions)..where(
            (c) => c.habitId.equals(habitId) & c.date.equals(day),
          ))
          .go();
    }
  }
}

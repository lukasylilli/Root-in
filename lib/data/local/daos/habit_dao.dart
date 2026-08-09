import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/habit_completions_table.dart';
import '../tables/habits_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitCompletions])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<Habit>> watchActiveHabits() {
    return (select(
      habits,
    )..where((h) => h.archived.equals(false))).watch();
  }

  Future<Habit?> habitById(int id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  /// Alle nicht archivierten Gewohnheiten mit aktiver Erinnerung — Grundlage
  /// fürs Neuplanen nach einem Sprachwechsel (siehe PLAN.md Phase 11.5).
  Future<List<Habit>> habitsWithReminder() {
    return (select(habits)..where(
      (h) => h.archived.equals(false) & h.reminderEnabled.equals(true),
    )).get();
  }

  Future<int> addHabit(HabitsCompanion entry) => into(habits).insert(entry);

  /// Teil-Update per `where`-Klausel statt `.replace()`: `.replace()` würde
  /// bei jedem in [changes] fehlenden Feld mit eigenem Default-Wert (z. B.
  /// `iconKey`, `timesPerWeek`, `createdAt`) diesen Default zurückschreiben
  /// statt den bestehenden Wert zu erhalten — für ein Bearbeiten-Formular,
  /// das nur einzelne Felder ändert, ist das falsch.
  Future<void> updateHabit(int id, HabitsCompanion changes) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(changes);
  }

  Future<int> archiveHabit(int id) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      const HabitsCompanion(archived: Value(true)),
    );
  }

  /// Setzt/entfernt die Erinnerungszeit einer Gewohnheit (siehe PLAN.md
  /// Phase 7). [minuteOfDay] null = Erinnerung aus.
  Future<void> setReminder(int id, int? minuteOfDay) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        reminderEnabled: Value(minuteOfDay != null),
        reminderMinuteOfDay: Value(minuteOfDay),
      ),
    );
  }

  /// Löscht eine Gewohnheit endgültig, inklusive all ihrer
  /// Erledigungs-Einträge (siehe PLAN.md Phase 4.5).
  Future<void> deleteHabit(int id) async {
    await transaction(() async {
      await (delete(
        habitCompletions,
      )..where((c) => c.habitId.equals(id))).go();
      await (delete(habits)..where((h) => h.id.equals(id))).go();
    });
  }
}

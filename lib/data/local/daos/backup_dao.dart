import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/categories_table.dart';
import '../tables/habit_completions_table.dart';
import '../tables/habits_table.dart';

part 'backup_dao.g.dart';

/// Einzige Stelle, die den **kompletten** Datenbestand für Sicherungen
/// liest und zurückschreibt (siehe PLAN.md Phase 9). Bewusst ein eigener
/// Accessor über alle drei Tabellen, damit das Wiederherstellen in genau
/// einer Transaktion läuft.
@DriftAccessor(tables: [Habits, HabitCompletions, Categories])
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.db);

  /// Alle Gewohnheiten — **inklusive archivierter**, damit eine Sicherung
  /// den Bestand vollständig abbildet.
  Future<List<Habit>> allHabits() => select(habits).get();

  Future<List<HabitCompletion>> allCompletions() =>
      select(habitCompletions).get();

  Future<List<Category>> allCategories() => select(categories).get();

  /// Ersetzt den gesamten Bestand durch den gesicherten. Läuft in einer
  /// Transaktion: bricht etwas ab, bleibt der alte Bestand erhalten, statt
  /// halb überschrieben zu werden.
  ///
  /// Die IDs aus der Sicherung werden bewusst **beibehalten** — sonst
  /// zeigten die `habitId`-Verweise der Erledigungen ins Leere.
  Future<void> replaceAll({
    required List<Habit> newHabits,
    required List<HabitCompletion> newCompletions,
    required List<Category> newCategories,
  }) async {
    await transaction(() async {
      // Erledigungen zuerst löschen: sie referenzieren Habits.
      await delete(habitCompletions).go();
      await delete(habits).go();
      await delete(categories).go();

      await batch((batch) {
        batch.insertAll(categories, newCategories);
        batch.insertAll(habits, newHabits);
        batch.insertAll(habitCompletions, newCompletions);
      });
    });
  }
}

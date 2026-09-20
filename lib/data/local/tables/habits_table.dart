import 'package:drift/drift.dart';

import '../../models/habit_goal_type.dart';

@DataClassName('Habit')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconKey => text().withDefault(const Constant('task_alt'))();
  IntColumn get colorValue => integer()();
  TextColumn get category => text().withDefault(const Constant('Allgemein'))();
  IntColumn get goalType => intEnum<HabitGoalType>()();

  /// Nur relevant bei [HabitGoalType.duration], z. B. 10 oder 60 (Minuten).
  IntColumn get targetMinutes => integer().nullable()();

  /// Wochen-Soll (1–7) — **in jedem Modus des Wochenplans** (siehe
  /// `HabitSchedule`, PLAN.md Phase 32): bei „jeden Tag" 7, bei festen Tagen
  /// deren Anzahl, bei „x-mal pro Woche" das x. Die Statistik rechnet damit
  /// `Soll = timesPerWeek × Wochen`. Zusätzlich gilt die Frei-Tag-Regel bei
  /// der Streak-Berechnung.
  IntColumn get timesPerWeek => integer().withDefault(const Constant(7))();

  DateTimeColumn get startDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Wochentags-Maske des Wochenplans (PLAN.md Phase 32): Bit 0 = Montag …
  /// Bit 6 = Sonntag, 127 = jeden Tag. Zusammen mit [timesPerWeek] ergibt sich
  /// der Modus — siehe `HabitSchedule.fromColumns`.
  ///
  /// ⚠️ Bewusst als **letzte** Spalte: `onUpgrade` legt sie mit `addColumn` an,
  /// und die hängt ans Ende. So stimmt die Spaltenreihenfolge einer migrierten
  /// Datenbank mit der einer frisch angelegten überein.
  IntColumn get scheduleDays => integer().withDefault(const Constant(127))();
}

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

  /// Wie oft pro Woche die Gewohnheit ansteht (1–7). Zusätzlich zur
  /// Frequenz gilt die generelle Frei-Tag-Regel bei der Streak-Berechnung.
  IntColumn get timesPerWeek => integer().withDefault(const Constant(7))();

  DateTimeColumn get startDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Erinnerung an (siehe PLAN.md Phase 7). Nur relevant, wenn
  /// [reminderMinuteOfDay] gesetzt ist.
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Uhrzeit der täglichen Erinnerung als Minuten seit Mitternacht (0–1439),
  /// z. B. 8:30 Uhr = 510. Ein einzelner Int statt Stunde+Minute hält die
  /// Umrechnung von/zu `TimeOfDay` in der Präsentationsschicht einfach.
  IntColumn get reminderMinuteOfDay => integer().nullable()();
}

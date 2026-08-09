import 'package:drift/drift.dart';

import 'habits_table.dart';

@DataClassName('HabitCompletion')
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();

  /// Datum der Erledigung, immer auf Mitternacht normalisiert (siehe
  /// core/utils/date_utils.dart), damit ein Tag genau einem Eintrag
  /// pro Habit entspricht.
  DateTimeColumn get date => dateTime()();

  /// Nur bei Dauer-Zielen befüllt: tatsächlich investierte Minuten.
  IntColumn get valueMinutes => integer().nullable()();

  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();

  // Genau ein Eintrag pro Habit und Tag, sonst würde `insertOrReplace` beim
  // mehrfachen Abhaken Duplikate statt eines Updates erzeugen.
  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_completion_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitCompletionDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitCompletionsTable get habitCompletions =>
      attachedDatabase.habitCompletions;
  HabitCompletionDaoManager get managers => HabitCompletionDaoManager(this);
}

class HabitCompletionDaoManager {
  final _$HabitCompletionDaoMixin _db;
  HabitCompletionDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.habitCompletions,
      );
}

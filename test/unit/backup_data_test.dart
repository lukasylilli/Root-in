import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/backup_data.dart';
import 'package:root_in/data/models/habit_goal_type.dart';

void main() {
  BackupData sample() => BackupData(
    version: BackupData.currentVersion,
    exportedAt: DateTime(2026, 7, 21),
    categories: [const Category(id: 1, name: 'Sport')],
    habits: [
      Habit(
        id: 7,
        name: 'Laufen',
        iconKey: 'task_alt',
        colorValue: 0xFF112233,
        category: 'Sport',
        goalType: HabitGoalType.duration,
        targetMinutes: 30,
        timesPerWeek: 5,
        startDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 7, 1),
        archived: false,
        reminderEnabled: true,
        reminderMinuteOfDay: 450,
      ),
    ],
    completions: [
      HabitCompletion(
        id: 3,
        habitId: 7,
        date: DateTime(2026, 7, 20),
        valueMinutes: 32,
        completedAt: DateTime(2026, 7, 20, 18, 5),
      ),
    ],
  );

  test('überlebt eine Runde durch JSON verlustfrei', () {
    final original = sample();

    final restored = BackupData.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored.version, original.version);
    expect(restored.exportedAt, original.exportedAt);
    expect(restored.categories.single.name, 'Sport');

    final habit = restored.habits.single;
    // IDs müssen erhalten bleiben, sonst zeigen die Erledigungen ins Leere.
    expect(habit.id, 7);
    expect(habit.name, 'Laufen');
    expect(habit.goalType, HabitGoalType.duration);
    expect(habit.targetMinutes, 30);
    expect(habit.timesPerWeek, 5);
    expect(habit.archived, isFalse);
    expect(habit.reminderEnabled, isTrue);
    expect(habit.reminderMinuteOfDay, 450);

    final completion = restored.completions.single;
    expect(completion.habitId, 7);
    expect(completion.date, DateTime(2026, 7, 20));
    expect(completion.valueMinutes, 32);
  });

  // Geprüft wird der Grund-Code, nicht ein Text: `BackupData` bleibt seit
  // Phase 11 sprachneutral, den Satz bildet erst der BackupService.
  test('lehnt eine Sicherung aus einer neueren App-Version ab', () {
    final json = sample().toJson()..['version'] = BackupData.currentVersion + 1;

    expect(
      () => BackupData.fromJson(json),
      throwsA(
        isA<BackupFormatException>()
            .having((e) => e.problem, 'problem', BackupFormatProblem.tooNew)
            .having(
              (e) => e.fileVersion,
              'fileVersion',
              BackupData.currentVersion + 1,
            ),
      ),
    );
  });

  test('lehnt Fremd-JSON ohne Versionsfeld ab', () {
    expect(
      () => BackupData.fromJson(const {'irgendwas': 1}),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.problem,
          'problem',
          BackupFormatProblem.notABackup,
        ),
      ),
    );
  });

  test('lehnt eine beschädigte Liste ab', () {
    expect(
      () => BackupData.fromJson({
        'version': BackupData.currentVersion,
        'exportedAt': DateTime(2026, 7, 21).toIso8601String(),
        'habits': 'keine Liste',
      }),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.problem,
          'problem',
          BackupFormatProblem.corrupted,
        ),
      ),
    );
  });

  test('behandelt fehlende Listen als leer', () {
    final restored = BackupData.fromJson({
      'version': BackupData.currentVersion,
      'exportedAt': DateTime(2026, 7, 21).toIso8601String(),
    });

    expect(restored.habits, isEmpty);
    expect(restored.completions, isEmpty);
    expect(restored.categories, isEmpty);
  });
}

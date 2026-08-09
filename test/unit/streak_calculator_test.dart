import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/utils/date_utils.dart';
import 'package:root_in/core/utils/streak_calculator.dart';

void main() {
  final week1Start = weekStartOf(DateTime(2026, 7, 19)); // Montag
  DateTime day(int offset) => week1Start.add(Duration(days: offset));

  group('StreakCalculator.currentStreak', () {
    test('zaehlt durchgehende Tage bis heute', () {
      final today = day(9);
      final completed = {for (var i = 0; i <= 9; i++) day(i)};

      expect(
        StreakCalculator.currentStreak(completedDates: completed, today: today),
        10,
      );
    });

    test('ein Frei-Tag pro Woche unterbricht die Serie nicht', () {
      final today = day(6); // Sonntag Woche 1
      final completed = {
        for (var i = 0; i <= 6; i++)
          if (i != 2) day(i), // Mittwoch fehlt
        for (var i = -7; i <= -1; i++) day(i), // volle Vorwoche
      };

      expect(
        StreakCalculator.currentStreak(completedDates: completed, today: today),
        13,
      );
    });

    test('zwei fehlende Tage in derselben Woche brechen die Serie', () {
      final today = day(6); // Sonntag
      final completed = {
        for (var i = 0; i <= 6; i++)
          if (i != 1 && i != 2) day(i), // Dienstag & Mittwoch fehlen
      };

      expect(
        StreakCalculator.currentStreak(completedDates: completed, today: today),
        4,
      );
    });

    test('heute noch offen bricht die Serie nicht, zaehlt aber nicht mit', () {
      final today = day(6); // Sonntag, heute nicht erledigt
      final completed = {for (var i = 0; i <= 5; i++) day(i)};

      expect(
        StreakCalculator.currentStreak(completedDates: completed, today: today),
        6,
      );
    });
  });

  group('StreakCalculator.longestStreak', () {
    test('findet die laengste Serie inkl. Frei-Tag-Regel', () {
      final habitStart = day(0);
      final today = day(13); // Sonntag Woche 2, heute nicht erledigt

      final completed = {
        for (var i = 0; i <= 12; i++)
          if (i != 9) day(i), // Mittwoch Woche 2 fehlt (Frei-Tag)
      };

      expect(
        StreakCalculator.longestStreak(
          completedDates: completed,
          habitStartDate: habitStart,
          today: today,
        ),
        12,
      );
    });
  });
}

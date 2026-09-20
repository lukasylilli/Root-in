import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/utils/date_utils.dart';
import 'package:root_in/core/utils/streak_calculator.dart';
import 'package:root_in/data/models/habit_schedule.dart';

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

  // -------------------------------------------------------------------------
  // PLAN.md Phase 32: Wochenpläne. `week1Start` ist ein Montag; `d(0)` =
  // Montag, `d(6)` = Sonntag dieser Woche, `d(-7)` = Montag der Vorwoche.
  // -------------------------------------------------------------------------
  DateTime d(int offset) => addDays(week1Start, offset);

  group('bestimmte Tage', () {
    final dienstagDonnerstag = HabitSchedule.onDays([
      DateTime.tuesday,
      DateTime.thursday,
    ]);

    test('Tage ohne Termin sind neutral: sie zählen nicht und brechen nichts', () {
      final today = d(6); // Sonntag, heute kein Termin und nicht erledigt
      final completed = {d(-6), d(-4), d(1), d(3)}; // Di + Do, zwei Wochen

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: dienstagDonnerstag,
        ),
        4,
      );
    });

    test('ein verpasster Termin bricht die Serie — Frei-Tag erst ab vier Terminen', () {
      final today = d(6);
      // Diese Woche fehlt der Dienstag, die Vorwoche war vollständig.
      final completed = {d(-6), d(-4), d(3)};

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: dienstagDonnerstag,
        ),
        1,
      );
    });

    test('ab vier Terminen pro Woche gilt der Frei-Tag', () {
      final montagBisFreitag = HabitSchedule.onDays([1, 2, 3, 4, 5]);
      final today = d(6);
      final completed = {d(0), d(1), d(3), d(4)}; // Mittwoch fehlt

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: montagBisFreitag,
        ),
        4,
      );
    });

    test('zwei verpasste Termine in einer Woche brechen auch dann', () {
      final montagBisFreitag = HabitSchedule.onDays([1, 2, 3, 4, 5]);
      final today = d(6);
      final completed = {d(0), d(4)}; // Mittwoch und Donnerstag fehlen

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: montagBisFreitag,
        ),
        1,
      );
    });

    test('längste Serie: Tage ohne Termin unterbrechen nichts', () {
      final completed = {d(1), d(3), d(8), d(10)};

      expect(
        StreakCalculator.longestStreak(
          completedDates: completed,
          habitStartDate: d(0),
          today: d(13),
          schedule: dienstagDonnerstag,
        ),
        4,
      );
    });

    test('längste Serie: ein verpasster Termin setzt sie zurück', () {
      final completed = {d(1), d(3), d(10)}; // Dienstag der 2. Woche fehlt

      expect(
        StreakCalculator.longestStreak(
          completedDates: completed,
          habitStartDate: d(0),
          today: d(13),
          schedule: dienstagDonnerstag,
        ),
        2,
      );
    });

    test('ohne Plan bricht derselbe Bestand — der Plan macht den Unterschied', () {
      final completed = {d(-6), d(-4), d(1), d(3)};

      expect(
        StreakCalculator.currentStreak(completedDates: completed, today: d(6)),
        0,
      );
    });
  });

  group('x-mal pro Woche', () {
    final dreiMal = HabitSchedule.countPerWeek(3);

    test('die Serie läuft über Wochen, in denen das Soll erreicht wurde', () {
      final today = d(2); // Mittwoch
      final completed = {d(-7), d(-5), d(-3), d(0)}; // Vorwoche 3×, jetzt 1×

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: dreiMal,
        ),
        4,
      );
    });

    test('eine verfehlte Vorwoche beendet die Serie', () {
      final today = d(2);
      // Vorvorwoche 3×, Vorwoche nur 2×, jetzt 1×.
      final completed = {d(-14), d(-12), d(-10), d(-7), d(-5), d(0)};

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: dreiMal,
        ),
        1,
      );
    });

    test('die laufende Woche bricht nie — sie ist noch nicht vorbei', () {
      final today = d(6); // Sonntag, diese Woche noch nichts
      final completed = {d(-7), d(-5), d(-3)};

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: today,
          schedule: dreiMal,
        ),
        3,
      );
    });

    test('längste Serie: eine verfehlte Woche setzt zurück', () {
      // Woche −3: 3×, Woche −2: 1× (verfehlt), Woche −1: 3×, jetzt: 2×.
      final completed = {
        d(-21), d(-19), d(-17),
        d(-14),
        d(-7), d(-5), d(-3),
        d(0), d(1),
      };

      expect(
        StreakCalculator.longestStreak(
          completedDates: completed,
          habitStartDate: d(-21),
          today: d(6),
          schedule: dreiMal,
        ),
        5,
      );
    });
  });

  group('gemeinsame Serie (isRequiredDay)', () {
    test('Tage, an denen nichts ansteht, brechen die Gesamt-Serie nicht', () {
      final completed = {d(-6), d(-4), d(1), d(3)};
      final required = requiredDaysOf([
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
      ]);

      expect(
        StreakCalculator.currentStreak(
          completedDates: completed,
          today: d(6),
          isRequiredDay: required,
        ),
        4,
      );
    });
  });
}

import 'date_utils.dart';

/// Reine Streak-Berechnung ohne Datenbankzugriff (gut testbar). Pro
/// Kalenderwoche (Montag–Sonntag) darf ein Tag ausgelassen werden, ohne die
/// Serie zu brechen; dieser Frei-Tag zählt selbst nicht zur Serienlänge.
abstract final class StreakCalculator {
  /// Aktuelle Serie, rückwärts ab [today] gezählt. Ist [today] selbst noch
  /// nicht erledigt, bricht das die Serie nicht — der Tag wird nur nicht
  /// mitgezählt.
  static int currentStreak({
    required Set<DateTime> completedDates,
    required DateTime today,
  }) {
    var cursor = dateOnly(today);
    if (!completedDates.contains(cursor)) {
      cursor = addDays(cursor, -1);
    }

    var streakDays = 0;
    final usedFreeDayForWeek = <DateTime>{};

    while (true) {
      if (completedDates.contains(cursor)) {
        streakDays++;
      } else {
        final weekStart = weekStartOf(cursor);
        if (usedFreeDayForWeek.contains(weekStart)) {
          break;
        }
        usedFreeDayForWeek.add(weekStart);
      }
      cursor = addDays(cursor, -1);
    }

    return streakDays;
  }

  /// Längste je erreichte Serie zwischen [habitStartDate] und [today]
  /// (inklusive), unter Anwendung derselben Frei-Tag-Regel.
  static int longestStreak({
    required Set<DateTime> completedDates,
    required DateTime habitStartDate,
    required DateTime today,
  }) {
    if (completedDates.isEmpty) return 0;

    var longest = 0;
    var current = 0;
    final usedFreeDayForWeek = <DateTime>{};

    var day = dateOnly(habitStartDate);
    final end = dateOnly(today);

    while (!day.isAfter(end)) {
      if (completedDates.contains(day)) {
        current++;
        if (current > longest) longest = current;
      } else {
        final weekStart = weekStartOf(day);
        if (usedFreeDayForWeek.contains(weekStart)) {
          current = 0;
        } else {
          usedFreeDayForWeek.add(weekStart);
        }
      }
      day = addDays(day, 1);
    }

    return longest;
  }
}

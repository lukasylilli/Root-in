import '../../data/models/habit_schedule.dart';
import 'date_utils.dart';

/// Reine Streak-Berechnung ohne Datenbankzugriff (gut testbar). Pro
/// Kalenderwoche (Montag–Sonntag) darf ein Tag ausgelassen werden, ohne die
/// Serie zu brechen; dieser Frei-Tag zählt selbst nicht zur Serienlänge.
///
/// **Seit Phase 32 kennt die Rechnung Wochenpläne** (siehe [HabitSchedule]):
///
/// - **Jeden Tag:** unverändert — jeder Tag ist ein Termin, ein Frei-Tag je
///   Woche.
/// - **Bestimmte Tage:** Nur die gewählten Wochentage sind Termine. Ein Tag
///   ohne Termin ist **neutral**: Er zählt nicht mit und bricht nichts. Ein
///   verpasster Termin verhält sich wie ein verpasster Tag oben — nur gilt
///   die Frei-Tag-Regel erst ab [HabitSchedule.minDaysForFreeDay] Terminen
///   pro Woche (sonst wäre eine Serie mit einem Termin pro Woche unbrechbar).
/// - **x-mal pro Woche:** Die Serie läuft über **Wochen**: Eine Woche mit
///   erreichtem Soll setzt sie fort, eine verfehlte beendet sie. Gezählt
///   werden die erledigten **Tage** in diesen Wochen, wie sonst auch. Die
///   laufende Woche bricht nie — sie ist ja noch nicht vorbei.
///
/// ⚠️ Der Plan gilt für den **gesamten Verlauf**: Ändert jemand ihn, wird die
/// Vergangenheit nach dem neuen Plan gelesen. Es gibt keine Planhistorie.
abstract final class StreakCalculator {
  /// Aktuelle Serie, rückwärts ab [today] gezählt. Ist [today] selbst noch
  /// nicht erledigt, bricht das die Serie nicht — der Tag wird nur nicht
  /// mitgezählt.
  ///
  /// [isRequiredDay] überschreibt die Tage-Frage des [schedule] — für die
  /// gemeinsame Serie über mehrere Gewohnheiten (siehe [requiredDaysOf]).
  static int currentStreak({
    required Set<DateTime> completedDates,
    required DateTime today,
    HabitSchedule schedule = const HabitSchedule.everyDay(),
    bool Function(DateTime day)? isRequiredDay,
  }) {
    if (completedDates.isEmpty) return 0;
    if (isRequiredDay == null && schedule.mode == ScheduleMode.countPerWeek) {
      return _currentStreakByWeeks(
        completedDates: completedDates,
        today: today,
        weeklyTarget: schedule.weeklyTarget,
      );
    }

    final isRequired =
        isRequiredDay ?? (day) => schedule.includesWeekday(day.weekday);
    final earliest = _earliest(completedDates);

    var cursor = dateOnly(today);
    if (!completedDates.contains(cursor)) {
      cursor = addDays(cursor, -1);
    }

    var streakDays = 0;
    final usedFreeDayForWeek = <DateTime>{};

    // Vor der ersten Erledigung kann die Serie nicht mehr wachsen — dort
    // hört die Suche auf, statt sich durch leere Wochen zu tasten.
    while (!cursor.isBefore(earliest)) {
      if (completedDates.contains(cursor)) {
        streakDays++;
      } else if (isRequired(cursor)) {
        final weekStart = weekStartOf(cursor);
        if (!schedule.allowsFreeDay || usedFreeDayForWeek.contains(weekStart)) {
          break;
        }
        usedFreeDayForWeek.add(weekStart);
      }
      cursor = addDays(cursor, -1);
    }

    return streakDays;
  }

  /// Längste je erreichte Serie zwischen [habitStartDate] und [today]
  /// (inklusive), unter Anwendung derselben Regeln wie [currentStreak].
  static int longestStreak({
    required Set<DateTime> completedDates,
    required DateTime habitStartDate,
    required DateTime today,
    HabitSchedule schedule = const HabitSchedule.everyDay(),
    bool Function(DateTime day)? isRequiredDay,
  }) {
    if (completedDates.isEmpty) return 0;
    if (isRequiredDay == null && schedule.mode == ScheduleMode.countPerWeek) {
      return _longestStreakByWeeks(
        completedDates: completedDates,
        habitStartDate: habitStartDate,
        today: today,
        weeklyTarget: schedule.weeklyTarget,
      );
    }

    final isRequired =
        isRequiredDay ?? (day) => schedule.includesWeekday(day.weekday);

    var longest = 0;
    var current = 0;
    final usedFreeDayForWeek = <DateTime>{};

    var day = dateOnly(habitStartDate);
    final end = dateOnly(today);

    while (!day.isAfter(end)) {
      if (completedDates.contains(day)) {
        current++;
        if (current > longest) longest = current;
      } else if (isRequired(day)) {
        final weekStart = weekStartOf(day);
        if (!schedule.allowsFreeDay || usedFreeDayForWeek.contains(weekStart)) {
          current = 0;
        } else {
          usedFreeDayForWeek.add(weekStart);
        }
      }
      day = addDays(day, 1);
    }

    return longest;
  }

  static DateTime _earliest(Set<DateTime> dates) =>
      dates.reduce((a, b) => a.isBefore(b) ? a : b);

  /// Erledigte Tage der Woche, die am Montag [weekStart] beginnt.
  static int _countInWeek(Set<DateTime> completedDates, DateTime weekStart) {
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (completedDates.contains(addDays(weekStart, i))) count++;
    }
    return count;
  }

  static int _currentStreakByWeeks({
    required Set<DateTime> completedDates,
    required DateTime today,
    required int weeklyTarget,
  }) {
    final earliestWeek = weekStartOf(_earliest(completedDates));

    // Die laufende Woche zählt immer mit — sie kann noch voll werden.
    var week = weekStartOf(today);
    var streakDays = _countInWeek(completedDates, week);

    week = addDays(week, -7);
    while (!week.isBefore(earliestWeek)) {
      final count = _countInWeek(completedDates, week);
      if (count < weeklyTarget) break;
      streakDays += count;
      week = addDays(week, -7);
    }
    return streakDays;
  }

  static int _longestStreakByWeeks({
    required Set<DateTime> completedDates,
    required DateTime habitStartDate,
    required DateTime today,
    required int weeklyTarget,
  }) {
    final thisWeek = weekStartOf(today);
    var week = weekStartOf(habitStartDate);

    var longest = 0;
    var current = 0;
    while (!week.isAfter(thisWeek)) {
      final count = _countInWeek(completedDates, week);
      if (count >= weeklyTarget || week == thisWeek) {
        current += count;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
      week = addDays(week, 7);
    }
    return longest;
  }
}

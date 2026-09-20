import '../../../data/models/habit_schedule.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Kurzname eines Wochentags (1 = Montag … 7 = Sonntag) in der App-Sprache.
///
/// Die **eine** Stelle dafür: Formular (Auswahl-Chips) und Heute-Seite
/// (Untertitel) nehmen beide diese Funktion, damit ein Tag überall gleich
/// heißt. Auf Persisch ist es der volle Name — die Ein-Buchstaben-Kürzel
/// (`weekdayInitial*`) sind dort und im Deutschen mehrdeutig (D/D, S/S).
String weekdayShortLabel(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.weekdayShortMonday,
    DateTime.tuesday => l10n.weekdayShortTuesday,
    DateTime.wednesday => l10n.weekdayShortWednesday,
    DateTime.thursday => l10n.weekdayShortThursday,
    DateTime.friday => l10n.weekdayShortFriday,
    DateTime.saturday => l10n.weekdayShortSaturday,
    _ => l10n.weekdayShortSunday,
  };
}

/// Kurzbeschreibung eines Wochenplans für den Untertitel einer Gewohnheit:
/// „Jeden Tag", „Di, Do" oder „3× pro Woche · 1/3 diese Woche".
///
/// [weekDone] (Erledigungen der Woche bis zum angezeigten Tag) ergänzt bei
/// „x-mal pro Woche" den Stand — ohne ihn steht dort nur das Soll.
String scheduleSummary(
  AppLocalizations l10n,
  HabitSchedule schedule, {
  int? weekDone,
}) {
  if (schedule.mode == ScheduleMode.specificDays) {
    return schedule.weekdays
        .map((weekday) => weekdayShortLabel(l10n, weekday))
        .join(l10n.scheduleDaySeparator);
  }
  if (schedule.mode == ScheduleMode.countPerWeek) {
    final target = l10n.overviewGoalPerWeek(schedule.weeklyTarget);
    if (weekDone == null) return target;
    final progress = l10n.scheduleWeekProgress(weekDone, schedule.weeklyTarget);
    return '$target · $progress';
  }
  return l10n.scheduleModeEveryDay;
}

/// Beschriftung eines Modus im Formular.
String scheduleModeLabel(AppLocalizations l10n, ScheduleMode mode) {
  return switch (mode) {
    ScheduleMode.everyDay => l10n.scheduleModeEveryDay,
    ScheduleMode.specificDays => l10n.scheduleModeSpecificDays,
    ScheduleMode.countPerWeek => l10n.scheduleModeCountPerWeek,
  };
}

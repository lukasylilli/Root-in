import '../local/database.dart';

/// Verbindet eine [Habit] mit ihrem Erledigungsstatus **an einem bestimmten
/// Tag**. Wird von der Heute-Seite verwendet, statt Habit- und
/// Completion-Daten getrennt zu verarbeiten.
///
/// Hieß bis Phase 24 `HabitWithTodayStatus` und meinte immer den heutigen
/// Tag. Seit die Seite ein beliebiges Datum zeigen kann (PLAN.md Phase 24),
/// wäre „today" im Namen irreführend — der Status gehört zu dem Tag, den der
/// Aufrufer angefragt hat.
class HabitWithDayStatus {
  const HabitWithDayStatus({
    required this.habit,
    required this.isDone,
    this.isDue = true,
    this.weekDoneCount = 0,
  });

  final Habit habit;
  final bool isDone;

  /// Steht die Gewohnheit an diesem Tag laut Wochenplan an (PLAN.md Phase 32,
  /// `HabitSchedule.isDueOn`)? Nur solche Einträge zählen für Tagesring,
  /// Prozent und Punkte. Ein Eintrag mit [isDone] ist immer fällig — ein
  /// gesetztes Häkchen verschwindet nie aus der Liste.
  final bool isDue;

  /// Erledigungen dieser Gewohnheit von Montag bis zu diesem Tag (inklusive)
  /// — für die Anzeige „2/3 diese Woche" bei „x-mal pro Woche".
  final int weekDoneCount;
}

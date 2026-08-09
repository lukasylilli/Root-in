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
  const HabitWithDayStatus({required this.habit, required this.isDone});

  final Habit habit;
  final bool isDone;
}

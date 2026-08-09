/// Lebenslange Gesamt-Statistik über alle Habits/Tage hinweg — Grundlage für
/// die Konto-Seite (Punkte, Erledigungen, längste Serie) und für die
/// Achievement-Freischalt-Logik (siehe `core/utils/achievement_evaluator.dart`).
class LifetimeStats {
  const LifetimeStats({
    required this.totalPoints,
    required this.totalCompletions,
    required this.longestStreakOverall,
    required this.categoriesUsed,
  });

  final int totalPoints;
  final int totalCompletions;
  final int longestStreakOverall;

  /// Anzahl unterschiedlicher Kategorien, in denen mindestens einmal etwas
  /// erledigt wurde (Grundlage für „Kategorie-Vollständigkeit"-Achievements).
  final int categoriesUsed;

  static const empty = LifetimeStats(
    totalPoints: 0,
    totalCompletions: 0,
    longestStreakOverall: 0,
    categoriesUsed: 0,
  );
}

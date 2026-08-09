/// Kennzahlen **einer** Gewohnheit über einen Zeitraum — Datenquelle der
/// beiden Tabellen auf der Übersicht-Seite (siehe PLAN.md Phase 16).
///
/// Bewusst ein eigenes Modell statt lose Werte: Erledigt/Offen/Prozent müssen
/// überall aus derselben Rechnung kommen, sonst zeigen Balken, Prozentzahl und
/// Rest-Spalte irgendwann unterschiedliche Stände.
class HabitPeriodStats {
  const HabitPeriodStats({
    required this.habitId,
    required this.name,
    required this.category,
    required this.doneCount,
    required this.targetCount,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int habitId;
  final String name;

  /// Kategorie der Gewohnheit — bestimmt auf der Übersicht-Seite die Farbe
  /// der Matrix-Zeile, damit sie zur Kategorie-Farbe der Wochen-Kreise passt.
  final String category;

  /// Erledigungen **im Zeitraum**.
  final int doneCount;

  /// Soll im Zeitraum: `timesPerWeek` × Anzahl Wochen des Zeitraums.
  final int targetCount;

  /// Aktuelle bzw. längste Serie über den **gesamten** Verlauf — eine Serie
  /// endet nicht dadurch, dass der angezeigte Zeitraum endet.
  final int currentStreak;
  final int longestStreak;

  /// Noch offene Erledigungen; nie negativ (Übererfüllung zählt als 0 offen).
  int get remainingCount {
    final open = targetCount - doneCount;
    return open < 0 ? 0 : open;
  }

  /// Erfüllungsgrad 0..1. Ohne Ziel (`targetCount == 0`) gilt 0, sonst würde
  /// eine Division durch null den ganzen Balken zerstören.
  double get percent =>
      targetCount == 0 ? 0 : (doneCount / targetCount).clamp(0.0, 1.0);
}

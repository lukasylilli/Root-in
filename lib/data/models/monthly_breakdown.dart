/// Erledigungen je Kalendermonat im Zeitraum — Datenquelle für die
/// Monatsübersicht (horizontale Balken, siehe PLAN.md Phase 5.5).
class MonthlyBreakdown {
  const MonthlyBreakdown({required this.month, required this.count});

  /// Erster Tag des Monats (Jahr+Monat identifizieren den Zeitraum).
  final DateTime month;
  final int count;
}

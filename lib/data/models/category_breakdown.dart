/// Erledigungen je Kategorie in einem Zeitraum — Datenquelle für das
/// „Typ von Gewohnheit"-Diagramm (siehe PLAN.md Abschnitt 7).
class CategoryBreakdown {
  const CategoryBreakdown({required this.category, required this.count});

  final String category;
  final int count;
}

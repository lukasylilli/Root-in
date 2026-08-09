/// Fortschritt (Prozent + Punkte) für einen Tageskontext. Einzige Quelle für
/// diese Berechnung — Home/Heute/View/Konto zeigen alle dasselbe Modell an.
class DailyProgress {
  const DailyProgress({
    required this.completedCount,
    required this.totalCount,
    required this.points,
  });

  final int completedCount;
  final int totalCount;
  final int points;

  /// Stand, solange das Datum noch nicht feststeht (siehe `todayProvider`) —
  /// besser ein leerer Ring als ein Ladekreis an einer Stelle, die gleich
  /// wieder Zahlen zeigt.
  static const empty = DailyProgress(
    completedCount: 0,
    totalCount: 0,
    points: 0,
  );

  double get percent => totalCount == 0 ? 0 : completedCount / totalCount;
}

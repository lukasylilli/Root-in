/// Einzige Quelle für Abstände der App. Andere Dateien importieren diese
/// Klasse, statt Abstandswerte erneut zu definieren.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Einzige Quelle für Eckenradien der App.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

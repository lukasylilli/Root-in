/// Feste Bühne der Übersicht-Seite (siehe PLAN.md Phase 16).
///
/// **Alle** Maße der Seite stehen hier als Konstanten; das Board wird als
/// Ganzes skaliert (siehe `overview_tab.dart`), nie umgebrochen. Nur so liegt
/// jeder Tag auf jedem Gerät in derselben Spalte: Linie, Balken, Wochentag,
/// Matrix-Zelle und Wochen-Kreis teilen sich [dayWidth] bzw. [weekWidth], und
/// Matrix-Zeile und Tabellen-Zeile teilen sich [matrixTop] und [rowHeight].
///
/// Wer hier etwas ändert, verschiebt die ganze Seite gleichmäßig — genau das
/// ist der Zweck. Einzelne Blöcke dürfen **keine** eigenen Maße erfinden.
library;

abstract final class OverviewMetrics {
  static const int weekCount = 4;
  static const int dayCount = weekCount * 7;

  static const double pad = 16;
  static const double gap = 10;

  /// Beschriftungs-Spalte links: Achsen-Titel, Zeilen-Titel, Habit-Namen.
  static const double labelWidth = 170;

  /// Eine Tages-Spalte. Die 28 Spalten liegen bewusst lückenlos nebeneinander
  /// (Wochen werden nur farblich getrennt): fl_chart verteilt Punkte und
  /// Balken gleichmäßig über die Chart-Breite — mit Lücken zwischen den
  /// Wochen träfe kein Datenpunkt mehr seine Matrix-Spalte.
  static const double dayWidth = 23;
  static const double weekWidth = dayWidth * 7;
  static const double gridWidth = dayWidth * dayCount;

  /// Höhe einer Matrix-/Tabellen-Zeile (eine Gewohnheit).
  static const double rowHeight = 23;

  /// Abstand der Zelle zum Spaltenrand — hält die Zelle quadratisch.
  static const double cellInset = 2.5;

  static const double lineHeight = 118;
  static const double weekHeaderHeight = 22;
  static const double weekdayHeight = 18;
  static const double barHeight = 104;
  static const double goalHeight = 58;
  static const double pieHeight = 132;
  static const double pieSize = 96;

  /// Spalten der rechten Tabelle (in dieser Reihenfolge).
  static const double colDone = 54;
  static const double colOpen = 54;
  static const double colPercent = 56;
  static const double colProgress = 132;
  static const double colStreak = 62;
  static const double colBest = 62;
  static const double tableWidth =
      colDone + colOpen + colPercent + colProgress + colStreak + colBest;

  static const double gridLeft = pad + labelWidth;
  static const double tableLeft = gridLeft + gridWidth + gap * 2;
  static const double boardWidth = tableLeft + tableWidth + pad;

  /// Oberkante der ersten Zeile — Matrix **und** rechte Tabelle beginnen
  /// hier, deshalb genau eine Konstante dafür.
  static const double matrixTop =
      pad +
      lineHeight +
      weekHeaderHeight +
      weekdayHeight +
      barHeight +
      gap +
      goalHeight +
      gap;

  /// Oberkante des Wochen-Kreis-Bereichs bei [habitCount] Gewohnheiten.
  static double pieTop(int habitCount) =>
      matrixTop + rowHeight * habitCount + gap;

  /// Gesamthöhe des Boards. Wächst nur mit der Anzahl Gewohnheiten — die
  /// Breite ist auf jedem Gerät gleich, damit sich die Proportionen der Seite
  /// nie ändern.
  static double boardHeight(int habitCount) =>
      pieTop(habitCount) + pieHeight + pad;

  /// Linke Kante der Tages-Spalte [dayIndex] (0..27), relativ zum Board.
  static double dayLeft(int dayIndex) => gridLeft + dayWidth * dayIndex;

  /// Linke Kante des Wochen-Blocks [weekIndex] (0..3), relativ zum Board.
  static double weekLeft(int weekIndex) => gridLeft + weekWidth * weekIndex;
}

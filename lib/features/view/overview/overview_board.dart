import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../data/models/category_breakdown.dart';
import '../../../data/models/habit_period_stats.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'overview_metrics.dart';

/// Das Board der Übersicht-Seite: vier Wochen à sieben Tage (ab Montag) als
/// **eine** feste, quer liegende Bühne (siehe PLAN.md Phase 16).
///
/// Von oben nach unten: Linien-Diagramm, Wochen-Köpfe, Wochentage,
/// Balken-Diagramm, Gesamtziel, Habit×Tag-Matrix, Wochen-Kreise. Rechts oben
/// die Namensliste mit Prozent, darunter — Zeile für Zeile auf gleicher Höhe
/// wie die Matrix — die Detail-Tabelle.
///
/// Prozentwerte setzt das Board bewusst selbst zusammen (mit Leerzeichen
/// vor dem Zeichen) statt über `AppNumbers.percent` — die Spaltenbreiten
/// in [OverviewMetrics] sind auf genau diese Textbreite ausgelegt. Die
/// Ziffern-Entscheidung für alle Sprachen steht in `core/l10n/app_numbers.dart`.
///
/// Alle Maße kommen aus [OverviewMetrics]; das Board legt sie mit einem
/// [Stack] auf feste Koordinaten, statt sie aus Flex-Layouts entstehen zu
/// lassen. Dadurch steht jeder Tag in jeder Zeile in derselben Spalte —
/// unabhängig von Bildschirmgröße, Textlänge oder Anzahl Gewohnheiten.
/// Skaliert wird nur das Board als Ganzes (siehe `overview_tab.dart`).
///
/// Nimmt fertige Werte + Tokens entgegen (keine Provider), damit es sich wie
/// [WeekChecklist] auch ohne laufende App rendern und in Tests direkt füttern
/// lässt.
class OverviewBoard extends StatelessWidget {
  const OverviewBoard({
    super.key,
    required this.start,
    required this.today,
    required this.stats,
    required this.doneDays,
    required this.dailyCounts,
    required this.weekCategories,
    required this.tokens,
  });

  /// Montag der ersten der vier Wochen.
  final DateTime start;

  /// Heutiger Tag — markiert seine Spalte, spätere Tage gelten als offen.
  final DateTime today;

  /// Kennzahlen je Gewohnheit; Reihenfolge = Zeilen-Reihenfolge.
  final List<HabitPeriodStats> stats;

  /// Erledigte Tage je Gewohnheit (Schlüssel: Habit-ID).
  final Map<int, Set<DateTime>> doneDays;

  /// Erledigungen je Tag — Werte der beiden Tages-Diagramme.
  final Map<DateTime, int> dailyCounts;

  /// Kategorie-Aufteilung je Woche (genau [OverviewMetrics.weekCount] Listen)
  /// — Datenbasis der Wochen-Kreise.
  final List<List<CategoryBreakdown>> weekCategories;

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final firstDay = dateOnly(start);
    final todayOnly = dateOnly(today);
    final days = [
      for (var i = 0; i < OverviewMetrics.dayCount; i++) addDays(firstDay, i),
    ];
    final values = [
      for (final day in days) (dailyCounts[day] ?? 0).toDouble(),
    ];
    // Eine Erledigung Luft über dem Höchstwert: ohne sie liegt der Spitzentag
    // genau auf der Oberkante, und von seinem Punkt (samt der Rundung der
    // Kurve) wird die obere Hälfte abgeschnitten.
    final peak = values.fold<double>(0, (max, v) => v > max ? v : max);
    final axisMax = peak + 1;

    final categories = _orderedCategories();
    final palette = categoryPalette(scheme);
    Color colorOf(String category) {
      final index = categories.indexOf(category);
      return palette[(index < 0 ? 0 : index) % palette.length];
    }

    final totalTarget = stats.fold<int>(0, (sum, s) => sum + s.targetCount);
    final totalDone = stats.fold<int>(0, (sum, s) => sum + s.doneCount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        width: OverviewMetrics.boardWidth,
        height: OverviewMetrics.boardHeight(stats.length),
        child: Stack(
          children: [
            // Hintergründe zuerst: Wochen-Bänder und Zeilen-Streifen laufen
            // durch alle Blöcke hindurch und machen die gemeinsame Spalten-
            // bzw. Zeilen-Achse sichtbar.
            ..._weekBands(),
            _todayColumn(days, todayOnly),
            ..._rowStripes(),

            _lineChart(l10n, values, axisMax, days.indexOf(todayOnly)),
            ..._weekHeader(l10n),
            _weekdayRow(l10n, days, todayOnly),
            _barChart(values, axisMax),
            _goalBlock(l10n, totalDone, totalTarget),
            ..._matrixRows(days, todayOnly, colorOf),
            _namesTable(l10n, colorOf),
            _tableHeader(l10n),
            ..._tableRows(colorOf),
            ..._weekPies(categories),
            _categoryLegend(l10n, categories, palette),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- Daten

  /// Feste Kategorie-Reihenfolge für die ganze Seite. Ohne sie bekäme jede
  /// Woche ihre Farben nach der eigenen Häufigkeit — dieselbe Kategorie wäre
  /// in Woche 1 blau und in Woche 2 grün.
  List<String> _orderedCategories() {
    final totals = <String, int>{};
    for (final week in weekCategories) {
      for (final entry in week) {
        totals.update(
          entry.category,
          (v) => v + entry.count,
          ifAbsent: () => entry.count,
        );
      }
    }

    final ordered = totals.keys.toList()
      ..sort((a, b) {
        final byCount = totals[b]!.compareTo(totals[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    // Kategorien ohne Erledigung im Zeitraum hinten anhängen, damit auch
    // deren Matrix-Zeilen eine feste Farbe haben.
    for (final stat in stats) {
      if (!ordered.contains(stat.category)) ordered.add(stat.category);
    }
    return ordered;
  }

  /// Kategorie-Werte einer Woche in der Reihenfolge [categories] — inklusive
  /// Nullen, damit Segment `i` in allen vier Kreisen dieselbe Kategorie ist.
  List<CategoryBreakdown> _pieData(int week, List<String> categories) {
    final counts = {
      for (final entry in weekCategories[week]) entry.category: entry.count,
    };
    if (counts.values.fold<int>(0, (sum, v) => sum + v) == 0) return const [];

    return [
      for (final category in categories)
        CategoryBreakdown(category: category, count: counts[category] ?? 0),
    ];
  }

  int _weekDone(int week) => weekCategories[week].fold<int>(
    0,
    (sum, entry) => sum + entry.count,
  );

  // --------------------------------------------------------------- Styles

  TextStyle get _labelStyle =>
      AppTextStyles.caption.copyWith(color: tokens.textSecondary);

  TextStyle get _valueStyle =>
      AppTextStyles.caption.copyWith(color: tokens.textPrimary);

  TextStyle get _microStyle => AppTextStyles.caption.copyWith(
    fontSize: 10,
    color: tokens.textSecondary,
  );

  // ----------------------------------------------------------- Hintergrund

  /// Abwechselnd getönte Wochen-Bänder über die volle Board-Höhe: Sie ersetzen
  /// Lücken zwischen den Wochen, die das Tagesraster zerreißen würden.
  List<Widget> _weekBands() {
    return [
      for (var week = 0; week < OverviewMetrics.weekCount; week++)
        if (week.isEven)
          Positioned(
            left: OverviewMetrics.weekLeft(week),
            top: OverviewMetrics.pad / 2,
            width: OverviewMetrics.weekWidth,
            height:
                OverviewMetrics.boardHeight(stats.length) - OverviewMetrics.pad,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.ringTrack.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
    ];
  }

  Widget _todayColumn(List<DateTime> days, DateTime todayOnly) {
    final index = days.indexOf(todayOnly);
    if (index < 0) return const SizedBox.shrink();

    return Positioned(
      left: OverviewMetrics.dayLeft(index),
      top: OverviewMetrics.pad / 2,
      width: OverviewMetrics.dayWidth,
      height: OverviewMetrics.boardHeight(stats.length) - OverviewMetrics.pad,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm / 2),
        ),
      ),
    );
  }

  /// Zeilen-Streifen über Matrix **und** Tabelle: der Streifen ist das, was
  /// das Auge von der Zelle links zur Zahl rechts führt.
  List<Widget> _rowStripes() {
    return [
      for (var row = 0; row < stats.length; row++)
        if (row.isOdd)
          Positioned(
            left: OverviewMetrics.pad,
            top: OverviewMetrics.matrixTop + OverviewMetrics.rowHeight * row,
            width: OverviewMetrics.boardWidth - OverviewMetrics.pad * 2,
            height: OverviewMetrics.rowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.ringTrack.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.sm / 2),
              ),
            ),
          ),
    ];
  }

  // -------------------------------------------------------------- Blöcke

  Widget _lineChart(
    AppLocalizations l10n,
    List<double> values,
    double axisMax,
    int todayIndex,
  ) {
    // Die Linie endet heute: liefe sie über die restlichen Spalten weiter,
    // fiele sie dort auf null und läse sich wie ein Einbruch statt wie ein
    // Tag, der noch vor einem liegt.
    final plotted = todayIndex < 0
        ? values
        : values.sublist(0, todayIndex + 1);

    return Positioned(
      left: OverviewMetrics.pad,
      top: OverviewMetrics.pad,
      width: OverviewMetrics.labelWidth + OverviewMetrics.gridWidth,
      height: OverviewMetrics.lineHeight,
      child: Row(
        children: [
          SizedBox(
            width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
            child: _axisGutter(l10n.overviewActivity, axisMax),
          ),
          const SizedBox(width: OverviewMetrics.gap),
          SizedBox(
            width: OverviewMetrics.gridWidth,
            child: DayGridLineChart(
              values: plotted,
              columnCount: OverviewMetrics.dayCount,
              maxValue: axisMax,
              color: tokens.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart(List<double> values, double axisMax) {
    return Positioned(
      left: OverviewMetrics.pad,
      top:
          OverviewMetrics.pad +
          OverviewMetrics.lineHeight +
          OverviewMetrics.weekHeaderHeight +
          OverviewMetrics.weekdayHeight,
      width: OverviewMetrics.labelWidth + OverviewMetrics.gridWidth,
      height: OverviewMetrics.barHeight,
      child: Row(
        children: [
          SizedBox(
            width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
            child: _axisGutter(null, axisMax),
          ),
          const SizedBox(width: OverviewMetrics.gap),
          SizedBox(
            width: OverviewMetrics.gridWidth,
            child: DayGridBarChart(
              values: values,
              maxValue: axisMax,
              color: tokens.accentSecondary,
              barWidth: OverviewMetrics.dayWidth * 0.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Achsen-Beschriftung links vom Diagramm: oben der Höchstwert, unten die
  /// Null. Beide Diagramme teilen sich denselben Höchstwert.
  Widget _axisGutter(String? title, double axisMax) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (title != null) Text(title, style: _labelStyle),
        Text('${axisMax.toInt()}', style: _microStyle),
        const Spacer(),
        Text('0', style: _microStyle),
      ],
    );
  }

  List<Widget> _weekHeader(AppLocalizations l10n) {
    return [
      for (var week = 0; week < OverviewMetrics.weekCount; week++)
        Positioned(
          left: OverviewMetrics.weekLeft(week),
          top: OverviewMetrics.pad + OverviewMetrics.lineHeight,
          width: OverviewMetrics.weekWidth,
          height: OverviewMetrics.weekHeaderHeight,
          child: Center(
            child: Text(
              l10n.overviewWeekLabel(week + 1),
              style: _valueStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
    ];
  }

  Widget _weekdayRow(
    AppLocalizations l10n,
    List<DateTime> days,
    DateTime todayOnly,
  ) {
    final initials = [
      l10n.weekdayInitialMonday,
      l10n.weekdayInitialTuesday,
      l10n.weekdayInitialWednesday,
      l10n.weekdayInitialThursday,
      l10n.weekdayInitialFriday,
      l10n.weekdayInitialSaturday,
      l10n.weekdayInitialSunday,
    ];

    return Positioned(
      left: OverviewMetrics.gridLeft,
      top:
          OverviewMetrics.pad +
          OverviewMetrics.lineHeight +
          OverviewMetrics.weekHeaderHeight,
      width: OverviewMetrics.gridWidth,
      height: OverviewMetrics.weekdayHeight,
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            SizedBox(
              width: OverviewMetrics.dayWidth,
              child: Center(
                child: Text(
                  initials[i % 7],
                  style: days[i] == todayOnly
                      ? _microStyle.copyWith(
                          color: tokens.accent,
                          fontWeight: FontWeight.bold,
                        )
                      : _microStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gesamtziel aller Gewohnheiten: wie oft pro Woche insgesamt etwas ansteht
  /// und wie viel davon im Zeitraum erledigt ist.
  Widget _goalBlock(AppLocalizations l10n, int totalDone, int totalTarget) {
    final percent = totalTarget == 0 ? 0.0 : totalDone / totalTarget;
    final perWeek = totalTarget ~/ OverviewMetrics.weekCount;

    return Positioned(
      left: OverviewMetrics.pad,
      top: OverviewMetrics.matrixTop - OverviewMetrics.gap -
          OverviewMetrics.goalHeight,
      width: OverviewMetrics.labelWidth + OverviewMetrics.gridWidth,
      height: OverviewMetrics.goalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
            child: Text(
              l10n.overviewTotalGoal,
              textAlign: TextAlign.end,
              style: AppTextStyles.title.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: OverviewMetrics.gap),
          SizedBox(
            width: OverviewMetrics.gridWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.overviewGoalPerWeek(perWeek),
                        style: AppTextStyles.title.copyWith(
                          fontSize: 16,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(percent * 100).round()} %',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 18,
                          color: tokens.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                _ProgressBar(
                  value: percent,
                  color: tokens.accent,
                  trackColor: tokens.ringTrack,
                  height: 10,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.overviewGoalInPeriod(
                    totalDone,
                    totalTarget,
                    OverviewMetrics.weekCount,
                  ),
                  style: _microStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Eine Matrix-Zeile je Gewohnheit: links der Name, rechts 28 Tages-Zellen.
  List<Widget> _matrixRows(
    List<DateTime> days,
    DateTime todayOnly,
    Color Function(String) colorOf,
  ) {
    final rows = <Widget>[];

    for (var row = 0; row < stats.length; row++) {
      final stat = stats[row];
      final color = colorOf(stat.category);
      final done = doneDays[stat.habitId] ?? const <DateTime>{};
      final top = OverviewMetrics.matrixTop + OverviewMetrics.rowHeight * row;

      rows.add(
        Positioned(
          left: OverviewMetrics.pad,
          top: top,
          width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
          height: OverviewMetrics.rowHeight,
          child: Row(
            children: [
              _Dot(color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  stat.name,
                  style: _valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );

      rows.add(
        Positioned(
          left: OverviewMetrics.gridLeft,
          top: top,
          width: OverviewMetrics.gridWidth,
          height: OverviewMetrics.rowHeight,
          child: Row(
            children: [
              for (final day in days)
                _MatrixCell(
                  key: ValueKey('cell-${stat.habitId}-${day.toIso8601String()}'),
                  done: done.contains(day),
                  isFuture: day.isAfter(todayOnly),
                  color: color,
                  trackColor: tokens.ringTrack,
                ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  /// Rechts oben, bündig mit Board-Rand: nur Name und Prozent je Gewohnheit.
  Widget _namesTable(AppLocalizations l10n, Color Function(String) colorOf) {
    return Positioned(
      left: OverviewMetrics.tableLeft,
      top: OverviewMetrics.pad,
      width: OverviewMetrics.tableWidth,
      height:
          OverviewMetrics.matrixTop -
          OverviewMetrics.rowHeight -
          OverviewMetrics.pad -
          OverviewMetrics.gap,
      child: FittedBox(
        // Bei vielen Gewohnheiten schrumpft **nur** diese Liste, statt die
        // Bühne zu verschieben: die feste Geometrie bleibt unangetastet.
        fit: BoxFit.scaleDown,
        alignment: Alignment.topRight,
        child: SizedBox(
          width: OverviewMetrics.tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.overviewHabits,
                textAlign: TextAlign.end,
                style: AppTextStyles.title.copyWith(
                  fontSize: 15,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final stat in stats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      _Dot(color: colorOf(stat.category)),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          stat.name,
                          style: _valueStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(stat.percent * 100).round()} %',
                        style: _valueStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(AppLocalizations l10n) {
    return Positioned(
      left: OverviewMetrics.tableLeft,
      top: OverviewMetrics.matrixTop - OverviewMetrics.rowHeight,
      width: OverviewMetrics.tableWidth,
      height: OverviewMetrics.rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _headerCell(OverviewMetrics.colDone, l10n.overviewColDone),
          _headerCell(OverviewMetrics.colOpen, l10n.overviewColOpen),
          _headerCell(OverviewMetrics.colPercent, l10n.overviewColPercent),
          _headerCell(OverviewMetrics.colProgress, l10n.overviewColProgress),
          _headerCell(OverviewMetrics.colStreak, l10n.overviewColStreak),
          _headerCell(OverviewMetrics.colBest, l10n.overviewColBest),
        ],
      ),
    );
  }

  Widget _headerCell(double width, String text) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _microStyle,
        ),
      ),
    );
  }

  /// Detail-Tabelle rechts — Zeile `i` liegt exakt auf Matrix-Zeile `i`.
  List<Widget> _tableRows(Color Function(String) colorOf) {
    return [
      for (var row = 0; row < stats.length; row++)
        Positioned(
          left: OverviewMetrics.tableLeft,
          top: OverviewMetrics.matrixTop + OverviewMetrics.rowHeight * row,
          width: OverviewMetrics.tableWidth,
          height: OverviewMetrics.rowHeight,
          child: Row(
            children: [
              _valueCell(OverviewMetrics.colDone, '${stats[row].doneCount}'),
              _valueCell(
                OverviewMetrics.colOpen,
                '${stats[row].remainingCount}',
              ),
              _valueCell(
                OverviewMetrics.colPercent,
                '${(stats[row].percent * 100).round()} %',
              ),
              SizedBox(
                width: OverviewMetrics.colProgress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  child: _ProgressBar(
                    value: stats[row].percent,
                    color: colorOf(stats[row].category),
                    trackColor: tokens.ringTrack,
                  ),
                ),
              ),
              _valueCell(
                OverviewMetrics.colStreak,
                '${stats[row].currentStreak}',
              ),
              _valueCell(
                OverviewMetrics.colBest,
                '${stats[row].longestStreak}',
              ),
            ],
          ),
        ),
    ];
  }

  Widget _valueCell(double width, String text) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(text, style: _valueStyle, maxLines: 1),
      ),
    );
  }

  /// Ein Kreisdiagramm je Woche, exakt unter „seiner" Woche.
  List<Widget> _weekPies(List<String> categories) {
    final perWeekTarget = stats.fold<int>(0, (sum, s) => sum + s.targetCount) ~/
        OverviewMetrics.weekCount;

    return [
      for (var week = 0; week < OverviewMetrics.weekCount; week++)
        Positioned(
          left: OverviewMetrics.weekLeft(week),
          top: OverviewMetrics.pieTop(stats.length),
          width: OverviewMetrics.weekWidth,
          height: OverviewMetrics.pieHeight,
          child: Column(
            children: [
              CategoryPieChart(
                data: _pieData(week, categories),
                showLegend: false,
                size: OverviewMetrics.pieSize,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                perWeekTarget == 0
                    ? '${_weekDone(week)}'
                    : '${(_weekDone(week) / perWeekTarget * 100).round()} % · '
                          '${_weekDone(week)}',
                style: _labelStyle,
              ),
            ],
          ),
        ),
    ];
  }

  Widget _categoryLegend(
    AppLocalizations l10n,
    List<String> categories,
    List<Color> palette,
  ) {
    return Positioned(
      left: OverviewMetrics.pad,
      top: OverviewMetrics.pieTop(stats.length),
      width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
      height: OverviewMetrics.pieHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: OverviewMetrics.labelWidth - OverviewMetrics.gap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.overviewCategories, style: _labelStyle),
              const SizedBox(height: AppSpacing.xs),
              for (var i = 0; i < categories.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      _Dot(color: palette[i % palette.length]),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          categories[i],
                          style: _microStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Farbpunkt vor einem Namen — verbindet Zeile, Kreis-Segment und Legende.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Eine Tages-Zelle der Habit×Tag-Matrix.
class _MatrixCell extends StatelessWidget {
  const _MatrixCell({
    super.key,
    required this.done,
    required this.isFuture,
    required this.color,
    required this.trackColor,
  });

  final bool done;

  /// Tage nach heute sind nicht „verpasst", sondern noch offen — sie bleiben
  /// als leerer Umriss stehen.
  final bool isFuture;

  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: OverviewMetrics.dayWidth,
      height: OverviewMetrics.rowHeight,
      child: Padding(
        padding: const EdgeInsets.all(OverviewMetrics.cellInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: done
                ? color
                : (isFuture ? Colors.transparent : trackColor),
            borderRadius: BorderRadius.circular(AppRadius.sm / 2),
            border: !done && isFuture
                ? Border.all(color: trackColor, width: 1)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Waagerechter Fortschrittsbalken der Tabelle und des Gesamtziels.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.color,
    required this.trackColor,
    this.height = 8,
  });

  /// 0..1.
  final double value;
  final Color color;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: trackColor,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: color),
          ),
        ),
      ),
    );
  }
}

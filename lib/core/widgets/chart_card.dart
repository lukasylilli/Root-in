import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/category_breakdown.dart';
import '../../l10n/gen/app_localizations.dart';
import '../l10n/app_numbers.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_utils.dart';

/// Gesamthöhe der Diagramme dieser Datei — Zeichenbereich **einschließlich**
/// Achsenbeschriftung. Sie ist bewusst fest: Das Home-Screen-Widget rendert
/// dieselben Widgets in eine Bildfläche von 320×200 (siehe
/// `core/services/home_widget_service.dart`), und ein Diagramm, das je nach
/// Inhalt wächst, würde dort abgeschnitten.
const double _chartHeight = 180;

/// Breite der Y-Achsen-Beschriftung von [CategoryBarChart].
const double _barChartLeftAxisWidth = 34;

/// Höhe der X-Achsen-Beschriftung von [CategoryBarChart]: zwei Zeilen
/// [AppTextStyles.caption] plus Abstand zur Achse.
const double _barChartBottomAxisHeight = 38;

/// Abstand zwischen Achse und Beschriftung, für beide Achsen derselbe Wert.
const double _barChartLabelSpace = 6;

/// Schmalste Breite, die einer X-Beschriftung zugestanden wird. Darunter
/// bringt auch der Umbruch nichts mehr, und die Kürzung mit „…" ist ehrlicher
/// als übereinanderliegender Text.
const double _barChartMinSlotWidth = 24;

/// Luft, die einer X-Beschriftung von ihrer Spalte abgezogen wird. Sie wirkt
/// **nur auf gekürzte** Namen: Kürzere Texte stehen ohnehin in ihrer eigenen
/// Breite mittig unter dem Balken. Ein Name, der die Spalte ausfüllen würde,
/// endet dadurch 12 px früher und stößt nicht bündig an den Nachbarn.
const double _barChartLabelGap = 12;

/// Einzige fl_chart-Wrapper der App (siehe PLAN.md Abschnitt 7): Verteilung
/// nach Gewohnheits-Typ (Balken/Kreis) und Fortschritts-Trend (Linie).
/// Andere Dateien bauen keine eigenen BarChart-/LineChart-/PieChart-
/// Konfigurationen.
class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({super.key, required this.data});

  final List<CategoryBreakdown> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyChart();

    final scheme = Theme.of(context).colorScheme;
    final maxCount = data.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: _chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Breite, die einer Kategorie unter ihrem Balken zusteht. Ohne diese
          // Begrenzung setzt fl_chart die Beschriftung ungekürzt mittig unter
          // den Balken, und ab drei Kategorien laufen die Namen ineinander
          // (gemeldet 2026-07-26, siehe PLAN.md Phase 13).
          final slotWidth = constraints.maxWidth.isFinite
              ? ((constraints.maxWidth - _barChartLeftAxisWidth) / data.length -
                        _barChartLabelGap)
                    .clamp(_barChartMinSlotWidth, double.infinity)
              : _barChartMinSlotWidth * 2;

          return BarChart(
            BarChartData(
              maxY: maxCount + 1,
              barTouchData: BarTouchData(enabled: true),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _barChartLeftAxisWidth,
                    // fl_chart beschriftet **zusätzlich** zum Intervall immer
                    // den oberen Rand (`maxY`). Ein größeres Intervall allein
                    // ließ deshalb weiterhin zwei Zahlen dicht übereinander
                    // stehen; erst das Verwerfen aller Werte außer 0 und dem
                    // Höchstwert lässt genau die zwei stehen, die etwas
                    // aussagen. `interval` darf dabei nie 0 sein.
                    interval: maxCount <= 0 ? 1 : maxCount.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final label = value.round();
                      if (label != 0 && label != maxCount) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: _barChartLabelSpace,
                        child: Text('$label', style: AppTextStyles.caption),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _barChartBottomAxisHeight,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: _barChartLabelSpace,
                        child: SizedBox(
                          width: slotWidth,
                          child: Text(
                            data[index].category,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].count.toDouble(),
                        color: scheme.primary,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Farbfolge der Kategorie-Segmente, zyklisch aus den Material-Schema-Rollen.
/// Einzige Quelle dafür: Kreisdiagramm **und** die Legende der Übersicht-Seite
/// leiten die Farbe aus derselben Reihenfolge ab, damit dieselbe Kategorie
/// überall (und über Neu-Builds hinweg) dieselbe Farbe hat.
List<Color> categoryPalette(ColorScheme scheme) => [
  scheme.primary,
  scheme.secondary,
  scheme.tertiary,
  scheme.error,
  scheme.primaryContainer,
  scheme.secondaryContainer,
];

/// Verteilung nach Gewohnheits-Typ als Kreisdiagramm — alternative Ansicht
/// zu [CategoryBarChart] auf denselben Daten (siehe PLAN.md Phase 5.5).
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.data,
    this.showLegend = true,
    this.size = 180,
  });

  final List<CategoryBreakdown> data;

  /// Ohne Legende bleibt nur der Kreis übrig — für Raster mit **einer**
  /// gemeinsamen Legende daneben, etwa die vier Wochen-Kreise der
  /// Übersicht-Seite (siehe PLAN.md Phase 16).
  final bool showLegend;

  /// Kantenlänge des Kreis-Bereichs.
  final double size;

  /// Unter diesem Anteil wird die Prozent-Beschriftung im Segment weggelassen
  /// — in den kleinen Wochen-Kreisen überlagern sich sonst die Zahlen.
  static const double _minLabelShare = 0.12;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return showLegend ? const _EmptyChart() : _EmptyPie(size: size);
    }

    final scheme = Theme.of(context).colorScheme;
    final colors = categoryPalette(scheme);
    final total = data.fold<int>(0, (sum, d) => sum + d.count);

    final pie = PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: showLegend ? 32 : size * 0.2,
        sections: [
          for (var i = 0; i < data.length; i++)
            PieChartSectionData(
              value: data[i].count.toDouble(),
              color: colors[i % colors.length],
              radius: showLegend ? 50 : size * 0.28,
              title: _sectionTitle(data[i].count, total),
              titleStyle: AppTextStyles.caption.copyWith(
                fontSize: showLegend ? null : 10,
                color: scheme.onPrimary,
              ),
            ),
        ],
      ),
    );

    if (!showLegend) {
      return SizedBox(width: size, height: size, child: pie);
    }

    return SizedBox(
      height: size,
      child: Row(
        children: [
          Expanded(child: pie),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < data.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          color: colors[i % colors.length],
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            data[i].category,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(int count, int total) {
    if (total == 0) return '';
    final share = count / total;
    if (!showLegend && share < _minLabelShare) return '';
    return AppNumbers.percent(share);
  }
}

/// Leerer Platzhalter-Kreis für [CategoryPieChart] ohne Legende — in einem
/// schmalen Raster-Feld hätte der Text von [_EmptyChart] keinen Platz.
class _EmptyPie extends StatelessWidget {
  const _EmptyPie({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: size * 0.56,
          height: size * 0.56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wie viele Punkte der Fortschritts-Trend höchstens zeichnet, bevor er
/// bündelt. Ein Punkt je Tag ergab auf der Jahr-Seite ~365 Punkte auf rund
/// 700 px — der Nutzer beschrieb das Ergebnis am 2026-07-26 als „Herz-
/// Vorhofflimmern". Bei 90 Punkten bleibt je Punkt genügend Breite, damit
/// eine Bewegung als Bewegung lesbar ist.
const int _trendMaxPoints = 90;

/// Breite eines Bündels in Tagen für einen Zeitraum von [dayCount] Tagen.
///
/// Bewusst nur drei Stufen mit **benennbarer** Bedeutung — Tag, Woche, Monat
/// — statt einer stufenlosen Rechnung: Ein Bündel aus 13 Tagen ließe sich
/// nicht beschriften, und ohne Beschriftung wüsste niemand, dass er nicht
/// mehr Tageswerte sieht.
int trendBucketDays(int dayCount) {
  if (dayCount <= _trendMaxPoints) return 1;
  if (dayCount <= _trendMaxPoints * 7) return 7;
  return 30;
}

/// Punkte des Fortschritts-Trends zwischen [start] und [end] (beide
/// einschließlich), in Prozent (0–100), zusammen mit der verwendeten
/// Bündelbreite.
///
/// Herausgezogen als reine Funktion, damit die Bündelung prüfbar ist, ohne
/// ein Diagramm zu rendern (dieselbe Bauart wie [trendBucketDays]).
({List<double> values, int bucketDays}) trendSeries(
  DateTime start,
  DateTime end,
  Map<DateTime, double> intensities,
) {
  final days = <DateTime>[];
  final last = dateOnly(end);
  for (var d = dateOnly(start); !d.isAfter(last); d = addDays(d, 1)) {
    days.add(d);
  }

  final bucketDays = trendBucketDays(days.length);
  if (bucketDays == 1) {
    return (
      values: [for (final d in days) (intensities[d] ?? 0) * 100],
      bucketDays: 1,
    );
  }

  final values = <double>[];
  for (var i = 0; i < days.length; i += bucketDays) {
    final size = (days.length - i).clamp(0, bucketDays);
    var sum = 0.0;
    for (var j = i; j < i + size; j++) {
      sum += intensities[days[j]] ?? 0;
    }
    // Durch die **tatsächliche** Länge geteilt, nicht durch [bucketDays]: Ein
    // angebrochenes letztes Bündel würde sonst mit fehlenden Tagen verdünnt
    // und fiele am rechten Rand grundlos ab.
    values.add(sum / size * 100);
  }
  return (values: values, bucketDays: bucketDays);
}

/// Fortschritts-Trend als Linie: Erledigungs-Prozent je Tag im Zeitraum,
/// bei langen Zeiträumen als Wochen- bzw. Monatsmittel (siehe [trendSeries]).
/// Nutzt dieselbe Intensitäts-Map wie das Matrix-Grid (siehe
/// `dailyIntensityProvider`) — keine eigene Aggregation der Rohdaten.
class ProgressTrendChart extends StatelessWidget {
  const ProgressTrendChart({
    super.key,
    required this.start,
    required this.end,
    required this.intensities,
  });

  final DateTime start;
  final DateTime end;
  final Map<DateTime, double> intensities;

  @override
  Widget build(BuildContext context) {
    final series = trendSeries(start, end, intensities);
    if (series.values.isEmpty) return const _EmptyChart();

    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final spots = [
      for (var i = 0; i < series.values.length; i++)
        FlSpot(i.toDouble(), series.values[i]),
    ];

    return SizedBox(
      height: _chartHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Der Hinweis steht **im** Diagramm statt darüber, damit die
          // Gesamthöhe unverändert bleibt (siehe [_chartHeight]).
          //
          // ⚠️ `Alignment.centerRight`, **nicht** `AlignmentDirectional`: Die
          // Y-Achse liegt in jeder Sprache physisch links (fl_chart kennt
          // keine Textrichtung, und die Diagramme bleiben auf Persisch
          // bewusst links-läufig — siehe PLAN.md Phase 18). Mit einer
          // richtungsabhängigen Ausrichtung landete der Hinweis auf Persisch
          // genau auf der Beschriftung „100 %". Am Gerät gefunden.
          if (series.bucketDays > 1)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                series.bucketDays == 7
                    ? l10n.chartTrendWeeklyAverage
                    : l10n.chartTrendMonthlyAverage,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    // Nach einem Null-Tag zieht eine gekrümmte Linie sonst
                    // unter die Achse — negative Erledigungen gibt es nicht
                    // (derselbe Grund wie in [DayGridLineChart]).
                    preventCurveOverShooting: true,
                    color: scheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tages-Verlauf als Linie über ein **festes** Tagesraster: Wert `i` liegt
/// exakt in der Mitte der Rasterspalte `i`. Für die Übersicht-Seite, auf der
/// Linie, Balken und Habit-Matrix spaltengenau übereinanderliegen müssen
/// (siehe `features/view/overview/overview_board.dart`).
///
/// Bewusst ohne Achsen, Beschriftung und Innenabstand: jede reservierte
/// Achsenbreite würde den Zeichenbereich schmaler machen als das Raster und
/// die Spalten gegeneinander verschieben. Die Beschriftung liefert die Seite.
class DayGridLineChart extends StatelessWidget {
  const DayGridLineChart({
    super.key,
    required this.values,
    required this.maxValue,
    required this.color,
    this.columnCount,
  });

  /// Ein Wert je Rasterspalte (Tag), beginnend bei Spalte 0. Kürzer als
  /// [columnCount] heißt: die restlichen Spalten bleiben leer.
  final List<double> values;

  /// Breite des Rasters in Spalten — bestimmt, wie breit eine Spalte ist.
  /// Ohne Angabe füllen die Werte das ganze Raster. Getrennt von
  /// `values.length`, damit eine Linie, die heute endet, die Spalten nicht
  /// breiter zieht: künftige Tage sollen leer bleiben, nicht auf null fallen.
  final int? columnCount;

  /// Oberes Ende der Y-Achse — für Linie und Balken derselbe Wert, sonst
  /// zeigten die beiden Diagramme denselben Tag unterschiedlich hoch.
  final double maxValue;

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        minX: -0.5,
        maxX: (columnCount ?? values.length) - 0.5,
        minY: 0,
        maxY: maxValue <= 0 ? 1 : maxValue,
        clipData: const FlClipData.all(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            // Ohne Überschwing-Schutz zieht die Kurve nach einem Null-Tag
            // unter die Achse — dort gibt es keine negativen Erledigungen.
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(radius: 2, color: color, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dasselbe Tagesraster wie [DayGridLineChart], nur als Balken. `spaceAround`
/// mit gleich breiten Balken setzt Balken `i` genau in die Mitte von Spalte
/// `i` — die Voraussetzung dafür, dass Balken, Linie und Matrix-Zelle eines
/// Tages exakt übereinanderstehen.
class DayGridBarChart extends StatelessWidget {
  const DayGridBarChart({
    super.key,
    required this.values,
    required this.maxValue,
    required this.color,
    required this.barWidth,
  });

  final List<double> values;
  final double maxValue;
  final Color color;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 0,
        minY: 0,
        maxY: maxValue <= 0 ? 1 : maxValue,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          AppLocalizations.of(context).chartNoData,
          style: AppTextStyles.caption,
        ),
      ),
    );
  }
}

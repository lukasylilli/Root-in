import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/habit_repository.dart';
import '../../services/settings_service.dart';
import '../../utils/date_utils.dart';
import '../chart_card.dart';
import '../matrix_grid.dart';
import '../monthly_bar_chart.dart';
import 'dashboard_widget_type.dart';

/// Ab dieser Zeitraum-Länge wird das Matrix-Grid auf die verfügbare Breite
/// verkleinert, statt horizontal scrollbar zu sein (siehe PLAN.md Phase 8.5
/// — auf der Jahr-/Konto-Seite soll man nicht seitwärts scrollen müssen).
/// Kürzere Zeiträume (Woche/Monat/Home) behalten die feste, gut greifbare
/// Zellengröße.
const int _fitToWidthWeekThreshold = 20;

bool _shouldFitToWidth(DateRange range) {
  final weeks =
      range.end.difference(weekStartOf(range.start)).inDays / 7;
  return weeks > _fitToWidthWeekThreshold;
}

/// Baut die konkrete Widget-Instanz zu einem [DashboardWidgetType] für
/// einen Zeitraum — einzige Stelle, die Typ und Zeitraum auf ein
/// tatsächliches Chart-/Grid-Widget abbildet, damit Home, View-Unterseiten,
/// Konto **und** das Home-Screen-Widget dieselbe Zuordnung nutzen, statt
/// sie zu duplizieren. Fürs Home-Screen-Widget wird der Aufruf in einen
/// `Consumer` innerhalb eines `UncontrolledProviderScope` gehängt (siehe
/// `core/services/home_widget_service.dart`), damit hier nichts dupliziert
/// werden muss.
Widget buildDashboardWidget(
  WidgetRef ref,
  DashboardWidgetType type,
  DateRange range,
) {
  switch (type) {
    case DashboardWidgetType.matrixGrid:
      return Builder(
        builder: (context) => MatrixGrid(
          start: range.start,
          end: range.end,
          intensities: ref.watch(dailyIntensityProvider(range)),
          fitToWidth: _shouldFitToWidth(range),
          tokens: ref.watch(
            appTokensProvider(Theme.of(context).brightness),
          ),
        ),
      );
    case DashboardWidgetType.categoryBar:
      return CategoryBarChart(data: ref.watch(categoryBreakdownProvider(range)));
    case DashboardWidgetType.categoryPie:
      return CategoryPieChart(data: ref.watch(categoryBreakdownProvider(range)));
    case DashboardWidgetType.progressTrend:
      return ProgressTrendChart(
        start: range.start,
        end: range.end,
        intensities: ref.watch(dailyIntensityProvider(range)),
      );
    case DashboardWidgetType.monthlyBar:
      return MonthlyBarChart(data: ref.watch(monthlyBreakdownProvider(range)));
  }
}

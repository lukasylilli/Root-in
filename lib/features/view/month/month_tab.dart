import 'package:flutter/material.dart';

import '../../../core/constants/dashboard_defaults.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../presentation/range_matrix_tab.dart';

const List<DashboardWidgetType> _monthAvailableWidgets = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.categoryPie,
];

/// Unterseite „Monat": aktueller Kalendermonat (1. bis heute).
class MonthTab extends StatelessWidget {
  const MonthTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RangeMatrixTab(
      title: AppLocalizations.of(context).monthTabTitle,
      pageId: 'month',
      availableTypes: _monthAvailableWidgets,
      defaultTypes: weekMonthDashboardDefaults,
      rangeFor: (today) =>
          (start: DateTime(today.year, today.month, 1), end: today),
    );
  }
}

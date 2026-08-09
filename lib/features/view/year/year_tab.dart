import 'package:flutter/material.dart';

import '../../../core/constants/dashboard_defaults.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../presentation/range_matrix_tab.dart';

const List<DashboardWidgetType> _yearAvailableWidgets = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.categoryPie,
  DashboardWidgetType.monthlyBar,
];

/// Unterseite „Jahr": letzte 52 Kalenderwochen (GitHub-Jahresansicht).
class YearTab extends StatelessWidget {
  const YearTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RangeMatrixTab(
      title: AppLocalizations.of(context).yearTabTitle,
      pageId: 'year',
      availableTypes: _yearAvailableWidgets,
      defaultTypes: yearDashboardDefaults,
      rangeFor: (today) =>
          (start: addDays(weekStartOf(today), -7 * 51), end: today),
    );
  }
}

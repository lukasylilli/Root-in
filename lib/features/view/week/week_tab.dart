import 'package:flutter/material.dart';

import '../../../core/constants/dashboard_defaults.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../presentation/range_matrix_tab.dart';

const List<DashboardWidgetType> _weekAvailableWidgets = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.categoryPie,
];

/// Unterseite „Woche": aktuelle Kalenderwoche (Mo bis heute).
class WeekTab extends StatelessWidget {
  const WeekTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RangeMatrixTab(
      title: AppLocalizations.of(context).weekTabTitle,
      pageId: 'week',
      availableTypes: _weekAvailableWidgets,
      defaultTypes: weekMonthDashboardDefaults,
      rangeFor: (today) => (start: weekStartOf(today), end: today),
    );
  }
}

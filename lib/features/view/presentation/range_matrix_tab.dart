import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../data/repositories/habit_repository.dart';

/// Gemeinsame Basis der View-Unterseiten (Woche/Monat/Jahr): individuali-
/// sierbares Dashboard (siehe PLAN.md Phase 5.5) für einen aus „heute"
/// berechneten Zeitraum. Die drei Tabs konfigurieren nur Titel, Zeitraum
/// und verfügbare Widget-Typen, statt das Layout dreifach zu bauen.
class RangeMatrixTab extends ConsumerWidget {
  const RangeMatrixTab({
    super.key,
    required this.title,
    required this.pageId,
    required this.availableTypes,
    required this.defaultTypes,
    required this.rangeFor,
  });

  final String title;
  final String pageId;
  final List<DashboardWidgetType> availableTypes;
  final List<DashboardWidgetType> defaultTypes;
  final DateRange Function(DateTime today) rangeFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider).value;
    if (today == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final range = rangeFor(today);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(title, style: AppTextStyles.headline),
        const SizedBox(height: AppSpacing.md),
        DashboardSection(
          pageId: pageId,
          availableTypes: availableTypes,
          defaultTypes: defaultTypes,
          range: range,
        ),
      ],
    );
  }
}

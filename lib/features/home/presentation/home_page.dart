import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/dashboard_defaults.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/progress_summary_header.dart';
import '../../../core/widgets/web_storage_hint.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../account/presentation/share_progress_sheet.dart';
import 'ascent_source.dart';
import 'home_progress_animation.dart';

/// Wie viele Wochen das Dashboard auf der Home-Seite rückblickend zeigt.
const int _homeMatrixWeeks = 16;

const List<DashboardWidgetType> _homeAvailableWidgets = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.categoryPie,
  DashboardWidgetType.progressTrend,
];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Der Speicher-Hinweis der Web-Fassung (PLAN.md Phase 26.8). Er hängt
    // an der Home-Seite und nicht am Onboarding, weil er auch Nutzer
    // erreichen muss, die die Web-Fassung schon benutzen — die Erklärung
    // steht bei `SettingsService.loadWebStorageHintSeen`.
    //
    // Nach dem ersten Frame: Vorher gibt es keinen Navigator, der einen
    // Dialog aufnehmen könnte.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowWebStorageHint(context, ref);
    });
  }

  /// Zeitraum, aus dem die Berg-Animation ihren Prozentwert zieht — je
  /// nachdem, welche Kennzahl der Nutzer gewählt hat (siehe PLAN.md
  /// Phase 8.6).
  DateRange _rangeFor(AscentSource source, DateTime today) => switch (source) {
    AscentSource.today => (start: today, end: today),
    AscentSource.week => (start: weekStartOf(today), end: today),
    AscentSource.month => (
      start: DateTime(today.year, today.month, 1),
      end: today,
    ),
    AscentSource.year => (start: DateTime(today.year, 1, 1), end: today),
  };

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(todayProgressProvider);
    final today = ref.watch(todayProvider).value;
    final ascentSource = ref.watch(ascentSourceProvider);

    // „Heute" kommt aus dem Tagesfortschritt (identisch zum Header), alle
    // anderen Zeiträume aus dem gemittelten Zeitraum-Fortschritt.
    final ascentPercent = today == null
        ? 0.0
        : ascentSource == AscentSource.today
        ? progress.percent
        : ref.watch(
            rangeProgressPercentProvider(_rangeFor(ascentSource, today)),
          );

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          HomeProgressAnimation(
            percent: ascentPercent,
            sourceLabel: ascentSource.label(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          ProgressSummaryHeader(progress: progress),
          const SizedBox(height: AppSpacing.md),
          // „Routine teilen" (Phase 19): Das Teilen ist der einzige
          // Wettkampf-Weg der App — es gehört auf die erste Seite, nicht nur
          // ans Ende der Konto-Seite. Öffnet dasselbe Sheet wie dort.
          AppButton(
            label: l10n.shareProgress,
            icon: Icons.share_outlined,
            onPressed: () => showShareProgressSheet(context),
          ),
          const SizedBox(height: AppSpacing.md),
          if (today != null)
            DashboardSection(
              pageId: 'home',
              availableTypes: _homeAvailableWidgets,
              defaultTypes: homeDashboardDefaults,
              range: (
                start: addDays(weekStartOf(today), -7 * (_homeMatrixWeeks - 1)),
                end: today,
              ),
            ),
        ],
      ),
    );
  }
}

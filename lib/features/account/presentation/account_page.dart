import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/dashboard_defaults.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/platform_support.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/dashboard/dashboard_section.dart';
import '../../../core/widgets/dashboard/dashboard_widget_type.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/stat_column.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/presentation/account_cloud_card.dart';
import 'achievements_grid.dart';
import 'share_progress_sheet.dart';

const List<DashboardWidgetType> _accountAvailableWidgets = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.categoryPie,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.monthlyBar,
];

/// Konto-Seite (siehe PLAN.md Abschnitt 5.5): lokales Profil, lebenslange
/// Statistik + Matrix-Grid über den gesamten Verlauf, Achievements-Grid.
/// Erreichbar über Einstellungen → Konto-Infos.
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  late final TextEditingController _nameController = TextEditingController(
    text: ref.read(profileProvider).name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    ref.read(profileProvider.notifier).setName(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(lifetimeStatsProvider);
    final unlockedIds = ref.watch(unlockedAchievementIdsProvider);
    final today = ref.watch(todayProvider).value;
    final firstActivityDate = ref.watch(firstActivityDateProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageAccountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Steht ganz oben und nur, wenn ein Server konfiguriert ist
          // (PLAN.md 27.5) — das Konto ist das Thema dieser Seite.
          const AccountCloudCard(),
          if (supportsCloudSync) const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: l10n.accountProfile,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.fieldName),
              onSubmitted: (_) => _saveName(),
              onEditingComplete: _saveName,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: l10n.accountTotalStats,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatColumn(
                  label: l10n.statPoints,
                  value: '${stats.totalPoints}',
                ),
                StatColumn(
                  label: l10n.statCompletions,
                  value: '${stats.totalCompletions}',
                ),
                StatColumn(
                  label: l10n.statLongestStreak,
                  value: '${stats.longestStreakOverall}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (today != null && firstActivityDate != null)
            DashboardSection(
              pageId: 'account',
              availableTypes: _accountAvailableWidgets,
              defaultTypes: accountDashboardDefaults,
              range: (start: weekStartOf(firstActivityDate), end: today),
            ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: l10n.accountAchievements,
            child: AchievementsGrid(unlockedIds: unlockedIds),
          ),
          const SizedBox(height: AppSpacing.md),
          // ⚠️ Dieser Weg bleibt erhalten: Die Anleitung „Lernplanung" im
          // Repository beschreibt ausdrücklich „Konto → ganz nach unten →
          // Fortschritt teilen". Der zweite Einstieg auf der Home-Seite
          // (Phase 19) kommt daneben, nicht an seine Stelle.
          AppButton(
            label: l10n.shareProgress,
            icon: Icons.share_outlined,
            onPressed: () => showShareProgressSheet(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/constants/achievements.dart' show achievements;
import '../../../core/services/profile_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/share_card.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../view/overview/overview_board.dart';
import '../../view/overview/overview_metrics.dart';

/// Öffnet die Teilen-Vorschau. **Einziger** Weg dorthin — sowohl der Knopf
/// auf der Konto-Seite als auch der auf der Home-Seite ruft diese Funktion,
/// statt sich ein eigenes Sheet zu bauen (PLAN.md Abschnitt 9, Phase 19).
Future<void> showShareProgressSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ShareProgressSheet(),
  );
}

/// Bottom Sheet zum Teilen des Fortschritts (siehe PLAN.md Abschnitt 5.5 und
/// Phase 19): zeigt die Fortschritts-Karte als Vorschau, „Fortschritt teilen"
/// screenshottet sie und öffnet das System-Share-Sheet.
class ShareProgressSheet extends ConsumerStatefulWidget {
  const ShareProgressSheet({super.key});

  @override
  ConsumerState<ShareProgressSheet> createState() => _ShareProgressSheetState();
}

class _ShareProgressSheetState extends ConsumerState<ShareProgressSheet> {
  final _screenshotController = ScreenshotController();
  bool _sharing = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    // Der Screenshot greift die Karte in ihrer **natürlichen** Größe ab: Die
    // `FittedBox` in der Vorschau skaliert nur beim Malen, die Karte selbst
    // wird darunter in voller Breite ausgelegt (siehe `build`). Ohne diesen
    // Aufbau wäre das geteilte Bild so klein wie die Vorschau.
    final bytes = await _screenshotController.capture(pixelRatio: 2);
    if (bytes != null) {
      await ref.read(shareServiceProvider).shareProgressImage(bytes, l10n);
    }
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider).value;

    if (today == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = ref.watch(todayProgressProvider);
    final stats = ref.watch(lifetimeStatsProvider);
    final unlocked = ref.watch(unlockedAchievementIdsProvider);
    final tokens = ref.watch(appTokensProvider(Theme.of(context).brightness));
    final includeOverview = ref.watch(shareIncludeOverviewProvider);

    // Monats-/Jahres-Zeitraum wie auf den View-Unterseiten (Phase 8.5).
    final monthRange = (
      start: DateTime(today.year, today.month, 1),
      end: today,
    );
    final yearRange = (start: DateTime(today.year, 1, 1), end: today);

    final overview = includeOverview ? _buildOverview(today) : null;

    final card = ShareCard(
      tokens: tokens,
      profileName: ref.watch(profileProvider).name,
      date: today,
      percentToday: progress.percent,
      percentMonth: ref.watch(rangeProgressPercentProvider(monthRange)),
      percentYear: ref.watch(rangeProgressPercentProvider(yearRange)),
      points: stats.totalPoints,
      longestStreak: stats.longestStreakOverall,
      achievementsUnlocked: unlocked.length,
      achievementsTotal: achievements.length,
      gridStart: yearRange.start,
      gridEnd: yearRange.end,
      gridIntensities: ref.watch(dailyIntensityProvider(yearRange)),
      overview: overview,
      width: overview == null
          ? ShareCard.narrowWidth
          : OverviewMetrics.boardWidth + 2 * ShareCard.padding,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: FittedBox(
                // Die Karte hat eine feste Breite (bis ~1300 px mit
                // Übersicht) — hier wird sie nur zum Ansehen verkleinert.
                // Der `Screenshot`-Knoten liegt **innerhalb** der FittedBox
                // und behält damit seine natürliche Größe.
                child: Screenshot(
                  controller: _screenshotController,
                  child: card,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverviewSwitch(value: includeOverview),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: _sharing ? l10n.shareInProgress : l10n.shareProgress,
            icon: Icons.share_outlined,
            onPressed: _sharing ? null : _share,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  /// Baut den Übersicht-Block genau wie die Übersicht-Seite (`OverviewBoard`
  /// ist die eine Stelle dafür) — oder `null`, solange es keine Gewohnheiten
  /// gibt. Ohne diese Prüfung stünde auf der Karte ein leeres Raster.
  Widget? _buildOverview(DateTime today) {
    final start = addDays(
      weekStartOf(today),
      -7 * (OverviewMetrics.weekCount - 1),
    );
    final range = (
      start: start,
      end: addDays(start, OverviewMetrics.dayCount - 1),
    );

    final stats = ref.watch(habitPeriodStatsProvider(range));
    if (stats.isEmpty) return null;

    return OverviewBoard(
      start: start,
      today: today,
      stats: stats,
      doneDays: ref.watch(habitDaysInRangeProvider(range)),
      dailyCounts: ref.watch(dailyCompletionCountProvider(range)),
      weekCategories: [
        for (var week = 0; week < OverviewMetrics.weekCount; week++)
          ref.watch(
            categoryBreakdownProvider((
              start: addDays(start, week * 7),
              end: addDays(start, week * 7 + 6),
            )),
          ),
      ],
      tokens: ref.watch(appTokensProvider(Theme.of(context).brightness)),
    );
  }
}

/// „Vollständiger": eine Reihe Schalter dafür, was auf der Karte landet
/// (PLAN.md Phase 19). Bewusst klein gehalten — bisher genau einer.
class _OverviewSwitch extends ConsumerWidget {
  const _OverviewSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.shareOptionsTitle),
      subtitle: Text(l10n.shareOptionOverview),
      value: value,
      onChanged: (next) =>
          ref.read(shareIncludeOverviewProvider.notifier).set(next),
    );
  }
}

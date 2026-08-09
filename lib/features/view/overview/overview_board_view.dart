import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'overview_board.dart';
import 'overview_metrics.dart';

/// Verdrahtung der Übersicht-Bühne: Zeitraum aus „heute" ableiten, Provider
/// lesen, [OverviewBoard] als Ganzes auf den verfügbaren Platz skalieren.
///
/// Wird vom Tab **und** vom Vollbild genutzt (siehe `overview_tab.dart` und
/// `overview_fullscreen_page.dart`) — die beiden unterscheiden sich nur im
/// Knopf oben rechts, nicht im Inhalt. Deshalb liegt die Verdrahtung hier und
/// nicht in einer der beiden Seiten.
class OverviewBoardView extends ConsumerWidget {
  const OverviewBoardView({super.key, this.onExpand, this.onClose});

  /// Öffnet das Vollbild (nur im Tab gesetzt).
  final VoidCallback? onExpand;

  /// Beendet das Vollbild (nur dort gesetzt).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider).value;
    if (today == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Vier volle Wochen, die letzte ist die laufende: die Spalten stehen damit
    // immer an derselben Stelle, egal welcher Wochentag heute ist.
    final start = addDays(
      weekStartOf(today),
      -7 * (OverviewMetrics.weekCount - 1),
    );
    final range = (
      start: start,
      end: addDays(start, OverviewMetrics.dayCount - 1),
    );

    final stats = ref.watch(habitPeriodStatsProvider(range));
    if (stats.isEmpty) {
      return Center(child: Text(l10n.overviewEmpty, style: AppTextStyles.body));
    }

    final board = OverviewBoard(
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

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: InteractiveViewer(
              // Die Bühne selbst bleibt starr; zoomen darf man trotzdem, weil
              // 28 Spalten auf einem Telefon-Display auch im Vollbild klein
              // bleiben.
              maxScale: 5,
              child: FittedBox(child: board),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: onClose != null
              ? IconButton(
                  onPressed: onClose,
                  tooltip: l10n.overviewFullscreenExit,
                  icon: const Icon(Icons.close_fullscreen),
                )
              : IconButton(
                  onPressed: onExpand,
                  tooltip: l10n.overviewFullscreen,
                  icon: const Icon(Icons.open_in_full),
                ),
        ),
      ],
    );
  }
}

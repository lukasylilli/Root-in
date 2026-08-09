import 'package:flutter/material.dart';

import '../../data/models/daily_progress.dart';
import '../../l10n/gen/app_localizations.dart';
import '../l10n/app_numbers.dart';
import '../theme/app_spacing.dart';
import 'stat_column.dart';

/// Einzige Prozent-/Punkte-Anzeige der App. Home, Heute, View-Unterseiten
/// und Konto binden dieses Widget ein, statt eigene Prozent-/Punkte-UI zu
/// bauen.
class ProgressSummaryHeader extends StatelessWidget {
  const ProgressSummaryHeader({super.key, required this.progress});

  final DailyProgress progress;

  @override
  Widget build(BuildContext context) {
    final percentText = AppNumbers.percent(progress.percent);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatColumn(label: l10n.statProgress, value: percentText),
            StatColumn(label: l10n.statPoints, value: '${progress.points}'),
            StatColumn(
              label: l10n.statDone,
              value: '${progress.completedCount}/${progress.totalCount}',
            ),
          ],
        ),
      ),
    );
  }
}

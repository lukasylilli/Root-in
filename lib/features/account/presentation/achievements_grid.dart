import 'package:flutter/material.dart';

import '../../../core/constants/achievements.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Rasterdarstellung aller vordefinierten Achievements auf der Konto-Seite.
/// Freigeschaltete Achievements ([unlockedIds]) erscheinen farbig, gesperrte
/// ausgegraut. Einzige Achievement-Grid-Darstellung der App.
class AchievementsGrid extends StatelessWidget {
  const AchievementsGrid({super.key, required this.unlockedIds});

  final Set<String> unlockedIds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final unlocked = unlockedIds.contains(achievement.id);

        return Tooltip(
          message: achievement.description(l10n),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: unlocked
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                child: Icon(
                  achievement.icon,
                  color: unlocked ? scheme.primary : scheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                achievement.title(l10n),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: unlocked ? null : scheme.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

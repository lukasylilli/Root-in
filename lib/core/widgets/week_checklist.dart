import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_tokens.dart';
import '../utils/date_utils.dart';

/// Wochen-Checkliste (siehe PLAN.md Phase 10.6c; Widget-Spec-Familie
/// „checklist", SCREEN_12/14): sieben Tageskreise Mo–So mit
/// Wochentags-Initialen. Gefüllte Kreise zeigen den Erfüllungsgrad des
/// Tages ([AppThemeTokens.heat]), zukünftige Tage bleiben als leerer Ring
/// gedämpft.
///
/// Nimmt Werte + Tokens entgegen (keine Provider), damit sie auch beim
/// Offscreen-Rendern fürs Home-Screen-Widget nutzbar bleibt.
class WeekChecklist extends StatelessWidget {
  const WeekChecklist({
    super.key,
    required this.weekStart,
    required this.today,
    required this.intensities,
    required this.tokens,
    this.circleSize = 28,
  });

  /// Montag der dargestellten Woche (auf Mitternacht normalisiert).
  final DateTime weekStart;

  /// Heutiger Tag — Tage danach gelten als „noch offen".
  final DateTime today;

  /// Erledigungs-Intensität je Tag (Schlüssel: Mitternacht-normalisiert).
  final Map<DateTime, double> intensities;

  final AppThemeTokens tokens;
  final double circleSize;

  /// Wochentags-Initialen ab Montag.
  static List<String> _weekdayInitials(AppLocalizations l10n) => [
    l10n.weekdayInitialMonday,
    l10n.weekdayInitialTuesday,
    l10n.weekdayInitialWednesday,
    l10n.weekdayInitialThursday,
    l10n.weekdayInitialFriday,
    l10n.weekdayInitialSaturday,
    l10n.weekdayInitialSunday,
  ];

  @override
  Widget build(BuildContext context) {
    final monday = dateOnly(weekStart);
    final todayOnly = dateOnly(today);
    final initials = _weekdayInitials(AppLocalizations.of(context));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          _day(addDays(monday, i), initials[i], todayOnly),
      ],
    );
  }

  Widget _day(DateTime day, String initial, DateTime todayOnly) {
    final isFuture = day.isAfter(todayOnly);
    final intensity = intensities[day] ?? 0;
    final done = !isFuture && intensity > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: ValueKey(day),
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? tokens.heat(intensity) : Colors.transparent,
            border: done
                ? null
                : Border.all(
                    color: isFuture
                        ? tokens.ringTrack.withValues(alpha: 0.5)
                        : tokens.ringTrack,
                    width: 2,
                  ),
          ),
          child: done
              ? Icon(
                  Icons.check,
                  size: circleSize * 0.55,
                  color: tokens.textPrimary,
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          initial,
          style: AppTextStyles.caption.copyWith(
            color: isFuture
                ? tokens.textSecondary.withValues(alpha: 0.5)
                : tokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

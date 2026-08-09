import 'package:flutter/material.dart';

import '../../data/models/monthly_breakdown.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Horizontale Monats-Balken, z. B. für die Jahr-Seite (siehe PLAN.md
/// Phase 5.5). Bewusst kein fl_chart: fl_chart bietet kein natives
/// horizontales Balkendiagramm ohne Achsentausch-Klimmzüge, ein einfacher
/// Balken pro Monat reicht hier — ein Farbton (Theme-Primärfarbe), dünne
/// Balken, abgerundete Enden (Dataviz-Grundregeln).
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.data});

  final List<MonthlyBreakdown> data;

  /// Monatskürzel in der Reihenfolge Januar … Dezember.
  static List<String> _monthNames(AppLocalizations l10n) => [
    l10n.monthShortJan,
    l10n.monthShortFeb,
    l10n.monthShortMar,
    l10n.monthShortApr,
    l10n.monthShortMay,
    l10n.monthShortJun,
    l10n.monthShortJul,
    l10n.monthShortAug,
    l10n.monthShortSep,
    l10n.monthShortOct,
    l10n.monthShortNov,
    l10n.monthShortDec,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (data.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(l10n.chartNoData, style: AppTextStyles.caption),
        ),
      );
    }

    final monthNames = _monthNames(l10n);

    final scheme = Theme.of(context).colorScheme;
    final maxCount = data.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final entry in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    monthNames[entry.month.month - 1],
                    style: AppTextStyles.caption,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fraction = maxCount == 0
                          ? 0.0
                          : entry.count / maxCount;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 14,
                          width:
                              constraints.maxWidth * fraction.clamp(0.02, 1.0),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                SizedBox(
                  width: 24,
                  child: Text('${entry.count}', style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

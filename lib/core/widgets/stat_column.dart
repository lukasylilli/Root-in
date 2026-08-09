import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Einzige Label+Wert-Spalten-Darstellung der App (z. B. für Prozent/Punkte
/// in [ProgressSummaryHeader] und die lebenslange Statistik auf der
/// Konto-Seite). Andere Stellen importieren dies, statt Label/Wert-Spalten
/// erneut zu bauen.
class StatColumn extends StatelessWidget {
  const StatColumn({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

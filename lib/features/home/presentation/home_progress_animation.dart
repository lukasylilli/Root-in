import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'ascent_scene_painter.dart';

/// Berg-Aufstieg als Fortschritts-Metapher auf der Home-Seite (siehe
/// PLAN.md Phase 8/8.6, Vorlage `meine/Berg-Animation`): Die Figur steigt
/// den Serpentinen-Pfad hinauf, Sterne verblassen und die Sonne geht auf,
/// je weiter der Fortschritt ist.
///
/// Steht in [AppAssets.homeAnimation] ein Lottie-Pfad, wird stattdessen
/// dieses Asset gerendert — der Slot bleibt für ein späteres Nutzer-Asset
/// erhalten, ohne dass hier Code geändert werden muss.
class HomeProgressAnimation extends StatefulWidget {
  const HomeProgressAnimation({
    super.key,
    required this.percent,
    required this.sourceLabel,
  });

  /// Fortschritt 0..1 der vom Nutzer gewählten Kennzahl.
  final double percent;

  /// Woher der Wert stammt (z. B. „heute") — für die Statuszeile.
  final String sourceLabel;

  /// Camps entlang des Pfads, als Anteil (= 20 %, 40 %, … 100 %).
  static const List<double> campFractions = [0.2, 0.4, 0.6, 0.8, 1.0];

  static const double _height = 260;

  @override
  State<HomeProgressAnimation> createState() => _HomeProgressAnimationState();
}

class _HomeProgressAnimationState extends State<HomeProgressAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = AppAssets.homeAnimation;
    final clamped = widget.percent.clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      // Ohne Clipping ragt die gemalte Szene über die abgerundeten
      // Karten-Ecken hinaus (Card clippt standardmäßig nicht).
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: HomeProgressAnimation._height,
        width: double.infinity,
        child: asset == null
            ? _AscentScene(
                percent: clamped,
                sourceLabel: widget.sourceLabel,
                twinkle: _twinkleController,
              )
            : Lottie.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

class _AscentScene extends StatelessWidget {
  const _AscentScene({
    required this.percent,
    required this.sourceLabel,
    required this.twinkle,
  });

  final double percent;
  final String sourceLabel;
  final Animation<double> twinkle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Bei Fortschritts-Änderung wandert die Figur weich den Pfad hinauf,
      // statt zu springen.
      tween: Tween<double>(end: percent),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: twinkle,
              builder: (context, _) => CustomPaint(
                painter: AscentScenePainter(
                  progress: value,
                  twinkle: twinkle.value,
                  campFractions: HomeProgressAnimation.campFractions,
                ),
              ),
            ),
            // Breite begrenzt: sonst läuft die Statuszeile quer über die
            // Szene und kollidiert mit den Camp-Beschriftungen. 170 px, damit
            // auch die dreistellige „100 %"-Anzeige noch hineinpasst.
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              width: 170,
              child: _Hud(percent: value, sourceLabel: sourceLabel),
            ),
          ],
        );
      },
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.percent, required this.sourceLabel});

  final double percent;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final rounded = (percent * 100).round();
    final summit = percent >= 0.999;
    final nextCamp = HomeProgressAnimation.campFractions
        .where((fraction) => fraction > percent + 0.0001)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rounded',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                height: 1,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
              ),
            ),
            const Text(
              '%',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          summit
              ? AppLocalizations.of(context).ascentSummitReached
              : nextCamp == null
              ? sourceLabel
              : AppLocalizations.of(context).ascentToNextCamp(
                  ((nextCamp - percent) * 100).round(),
                  (nextCamp * 100).round(),
                ),
          style: const TextStyle(
            color: Color(0xFFD6DEF3),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
        Text(
          sourceLabel,
          style: const TextStyle(
            color: Color(0xFF9FB0D6),
            fontSize: 11,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import '../theme/app_text_styles.dart';

/// Kreisförmiger Tagesfortschritt (siehe PLAN.md Phase 10.6a; Spec
/// `meine/…APP_SCREEN_specs.json`, SCREEN_13 „daily_progress_ring"): ein
/// Ring, dessen gefüllter Bogen den Anteil erledigter Gewohnheiten zeigt,
/// mit Prozentzahl in der Mitte. Einzige Ring-Komponente der App — Screens
/// und Widgets binden sie ein, statt eigene Ringe zu malen.
///
/// Nimmt Werte + Tokens entgegen (keine Provider), damit sie auch beim
/// Offscreen-Rendern fürs Home-Screen-Widget nutzbar bleibt.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    required this.tokens,
    this.diameter = 96,
    this.strokeWidth = 9,
    this.centerLabel,
  });

  /// Fortschritt 0..1.
  final double percent;
  final AppThemeTokens tokens;
  final double diameter;
  final double strokeWidth;

  /// Ersetzt die Prozentzahl in der Mitte (z. B. eine Streak-Anzeige). Null
  /// = „NN %".
  final Widget? centerLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clamped,
          trackColor: tokens.ringTrack,
          progressColor: tokens.accent,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: centerLabel ??
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${(clamped * 100).round()}',
                    style: AppTextStyles.headline.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '%',
                    style: AppTextStyles.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Voller Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    if (progress <= 0) return;

    // Fortschritts-Bogen: bei -90° (oben) beginnen, im Uhrzeigersinn, mit
    // abgerundeten Enden (Spec: stroke_cap round).
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = progressColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.strokeWidth != strokeWidth;
}

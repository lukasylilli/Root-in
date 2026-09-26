import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ascent_scene_palette.dart';

/// Malt die Berg-Aufstiegs-Szene der Home-Seite (siehe PLAN.md Phase 33).
/// Geometrie und Wirkung sind aus der Nutzer-Vorlage
/// `mountain_progress_ios.html` portiert: ein gläserner Berg mit Lichtkante,
/// eine Linie vom Fuß bis zum Gipfel, die sich mit dem Fortschritt füllt,
/// Glas-Perlen an den Camps, ein Glas-Pin an der aktuellen Stelle und ein
/// Funkeln auf dem Gipfel bei 100 %.
///
/// Die Vorlage rechnet in einem Feld von 0..100 auf beiden Achsen und
/// streckt es auf die Fläche (`preserveAspectRatio="none"`). Genau so hier:
/// Berg und Pfad werden auf die tatsächliche Größe gemappt, Linienbreiten,
/// Perlen, Pin und Funkeln dagegen in echten Pixeln gezeichnet, damit sie
/// unverzerrt bleiben.
///
/// Die Vorlage ist für Rechts-nach-links gebaut (Pfad beginnt rechts unten,
/// Gipfel links). Bei Links-nach-rechts wird die Szene gespiegelt
/// ([mirrored]), damit der Aufstieg in Leserichtung verläuft.
///
/// Bewusst ein reiner Painter ohne Provider-Zugriff: bekommt alle Werte von
/// außen und bleibt dadurch testbar.
class AscentScenePainter extends CustomPainter {
  const AscentScenePainter({
    required this.progress,
    required this.campFractions,
    required this.palette,
    required this.mirrored,
    required this.spark,
  });

  /// Fortschritt 0..1 — steuert Linie, Pin, Perlen und warmen Schein.
  final double progress;

  /// Positionen der Camps als Anteil am Pfad (0..1). Das Camp bei 100 % ist
  /// der Gipfel und bekommt keine Perle, sondern das Funkeln.
  final List<double> campFractions;

  /// Farben für hell bzw. dunkel.
  final AscentScenePalette palette;

  /// `true` bei Links-nach-rechts: Szene horizontal spiegeln.
  final bool mirrored;

  /// 0..1 — Zeitachse des Gipfel-Funkelns (0 = unsichtbar, 1 = Endzustand).
  final double spark;

  /// Ab diesem Wert gilt der Gipfel als erreicht (wie in der Statuszeile).
  static const double summit = 0.999;

  // Pixelmaße, aus der Vorlage (1 Einheit ≈ 3,8 px auf dem Telefon).
  static const double _trailWidth = 1.7;
  static const double _progressWidth = 3.0;
  static const double _glowWidth = 9.9;
  static const double _glowSigma = 3.8;
  static const double _markRadius = 5.5;
  static const double _pinRadius = 15;
  static const double _pinDotRadius = 6;
  static const double _sparkSize = 34;

  /// Grat des Bergs (Vorlage: `.rim`), im Feld 0..100.
  static Path _ridge() => Path()
    ..moveTo(-2, 78)
    ..cubicTo(8, 60, 19, 38, 25.5, 27.5)
    ..cubicTo(28, 23.5, 31.5, 22.5, 34.5, 25.5)
    ..cubicTo(52, 42, 76, 58, 102, 70);

  /// Fläche des Bergs (Vorlage: `.peak-glass`).
  static Path _peak() => _ridge()
    ..lineTo(102, 100)
    ..lineTo(-2, 100)
    ..close();

  /// Pfad vom Fuß bis zum Gipfel (Vorlage: `#route`), im Feld 0..100.
  static Path buildTrail() => Path()
    ..moveTo(82, 90)
    ..cubicTo(60, 90, 56, 74, 68, 66)
    ..cubicTo(80, 58, 58, 50, 48, 45)
    ..cubicTo(40, 41, 36, 32, 30.2, 25);

  /// Vierzackiger Stern des Funkelns (Vorlage: `#spark`), 24×24.
  static Path _sparkShape() => Path()
    ..moveTo(12, 0)
    ..cubicTo(12.9, 7.6, 16.4, 11.1, 24, 12)
    ..cubicTo(16.4, 12.9, 12.9, 16.4, 12, 24)
    ..cubicTo(11.1, 16.4, 7.6, 12.9, 0, 12)
    ..cubicTo(7.6, 11.1, 11.1, 7.6, 12, 0)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final sx = size.width / 100;
    final sy = size.height / 100;
    final toSize = Matrix4.diagonal3Values(sx, sy, 1).storage;
    final atSummit = progress >= summit;
    final lineColor = palette.progressColor(atSummit: atSummit);

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    _paintAmbient(canvas, size);
    _paintPeak(
      canvas,
      _peak().transform(toSize),
      _ridge().transform(toSize),
      sy,
    );

    final trail = buildTrail().transform(toSize);
    final metrics = trail.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      _paintTrail(canvas, trail, metric, lineColor);
      _paintMarks(canvas, metric, lineColor);
      _paintPin(canvas, metric, lineColor);
      _paintSpark(canvas, metric);
    }

    canvas.restore();
  }

  /// Grundfläche und drei weiche Farbflecken (Vorlage: `.ambient`) — geben
  /// dem Glas etwas, das durchscheint.
  void _paintAmbient(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.background);
    final m = math.max(size.width, size.height);
    void blob(Offset center, double radius, Color color, double opacity) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }

    blob(
      Offset(size.width * 0.08, size.height * 0.02),
      m * 0.5,
      palette.blob1,
      0.85,
    );
    blob(
      Offset(size.width * 1.02, size.height * 0.5),
      m * 0.4,
      palette.blob2,
      0.85,
    );
    blob(
      Offset(size.width * 0.25, size.height * 1.08),
      m * 0.38,
      palette.blob3,
      0.55,
    );
  }

  /// Gläserner Berg: Verlauf, warmer Schein je nach Fortschritt, weiche
  /// innere Kante (Dicke des Glases) und helle Lichtkante.
  void _paintPeak(Canvas canvas, Path peak, Path ridge, double sy) {
    final bounds = peak.getBounds();
    canvas.drawPath(
      peak,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.peakTop,
            palette.peakTop,
            palette.peakBottom,
            palette.peakBottom.withValues(alpha: 0),
          ],
          stops: const [0, 0.2, 0.65, 1],
        ).createShader(bounds),
    );

    final warm = progress.clamp(0.0, 1.0) * 0.5;
    if (warm > 0) {
      final top = palette.warmTop.withValues(alpha: palette.warmTop.a * warm);
      canvas.drawPath(
        peak,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, top, top.withValues(alpha: 0)],
            stops: const [0, 0.2, 0.8],
          ).createShader(bounds),
      );
    }

    Shader rimFade(double shift, double opacity) => ui.Gradient.linear(
      Offset(0, 20 * sy + shift),
      Offset(0, 85 * sy + shift),
      [
        palette.rim.withValues(alpha: palette.rim.a * opacity),
        palette.rim.withValues(alpha: 0),
      ],
    );

    final innerShift = 1.6 * sy;
    canvas.drawPath(
      ridge.shift(Offset(0, innerShift)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = rimFade(innerShift, 0.28),
    );
    canvas.drawPath(
      ridge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = rimFade(0, 1),
    );
  }

  /// Ganzer Pfad gedämpft, darüber der zurückgelegte Teil mit Schein.
  void _paintTrail(
    Canvas canvas,
    Path trail,
    ui.PathMetric metric,
    Color lineColor,
  ) {
    canvas.drawPath(
      trail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _trailWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = palette.trail.withValues(alpha: palette.trail.a * 0.45),
    );

    if (progress <= 0) return;
    final done = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowSigma),
    );
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _progressWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );
  }

  /// Glas-Perlen an den Camps unterhalb des Gipfels; erreichte Camps sind
  /// in der Farbe der Linie gefüllt.
  void _paintMarks(Canvas canvas, ui.PathMetric metric, Color lineColor) {
    for (final fraction in campFractions) {
      if (fraction >= summit) continue;
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null) continue;
      final center = tangent.position;
      final reached = progress >= fraction - 0.0001;

      canvas.drawCircle(
        center.translate(0, 2),
        _markRadius,
        Paint()
          ..color = const Color(0x14000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        center,
        _markRadius,
        Paint()..color = reached ? lineColor : palette.glassStrong,
      );
      canvas.drawCircle(
        center,
        _markRadius - 0.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.glassRim,
      );
    }
  }

  /// Glas-Pin an der aktuellen Stelle des Pfads (Vorlage: `.pin`).
  void _paintPin(Canvas canvas, ui.PathMetric metric, Color lineColor) {
    final tangent = metric.getTangentForOffset(
      metric.length * progress.clamp(0.0, 1.0),
    );
    if (tangent == null) return;
    final center = tangent.position;

    canvas.drawCircle(
      center.translate(0, 4),
      _pinRadius,
      Paint()
        ..color = const Color(0x2E002878)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      center,
      _pinRadius,
      Paint()..color = const Color(0x4DFFFFFF),
    );
    // Heller Schimmer an der Oberkante des Glases.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: _pinRadius - 2),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x99FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
    canvas.drawCircle(
      center,
      _pinRadius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xE6FFFFFF),
    );
    canvas.drawCircle(center, _pinDotRadius, Paint()..color = lineColor);
  }

  /// Funkeln auf dem Gipfel, sobald er erreicht ist (Vorlage: `@keyframes
  /// spark`: 0 % unsichtbar → 35 % voll und etwas zu groß → 100 % ruhig).
  void _paintSpark(Canvas canvas, ui.PathMetric metric) {
    if (spark <= 0 || progress < summit) return;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;
    final frame = sparkFrame(spark);
    if (frame.scale <= 0 || frame.opacity <= 0) return;

    canvas.save();
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(frame.turn);
    final factor = frame.scale * _sparkSize / 24;
    canvas.scale(factor, factor);
    canvas.translate(-12, -12);
    final shape = _sparkShape();
    canvas.drawPath(
      shape,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * frame.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 / factor),
    );
    canvas.drawPath(
      shape,
      Paint()..color = Colors.white.withValues(alpha: frame.opacity),
    );
    canvas.restore();
  }

  /// Zustand des Funkelns zum Zeitpunkt [t] (0..1), mit der Feder-Kurve der
  /// Vorlage (`cubic-bezier(.32,.72,0,1)`) je Abschnitt.
  static ({double opacity, double scale, double turn}) sparkFrame(double t) {
    const spring = Cubic(0.32, 0.72, 0, 1);
    final clamped = t.clamp(0.0, 1.0);
    if (clamped < 0.35) {
      final u = spring.transform(clamped / 0.35);
      return (opacity: u, scale: 1.15 * u, turn: -math.pi / 4 * (1 - u));
    }
    final u = spring.transform((clamped - 0.35) / 0.65);
    return (opacity: 1 - 0.1 * u, scale: 1.15 - 0.35 * u, turn: 0.0);
  }

  @override
  bool shouldRepaint(AscentScenePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.spark != spark ||
      oldDelegate.mirrored != mirrored ||
      oldDelegate.palette != palette ||
      oldDelegate.campFractions != campFractions;
}

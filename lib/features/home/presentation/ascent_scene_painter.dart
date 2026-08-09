import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Malt die Berg-Aufstiegs-Szene (siehe PLAN.md Phase 8.6). Geometrie und
/// Farbwelt sind aus der Nutzer-Vorlage `meine/Berg-Animation` portiert
/// (React/SVG, viewBox 380×540) — alle Koordinaten hier sind daher auf
/// dieses Bezugssystem bezogen und werden beim Malen auf die tatsächliche
/// Widget-Größe skaliert.
///
/// Bewusst ein reiner Painter ohne Provider-Zugriff: bekommt Fortschritt
/// (0..1) und Sternen-Funkeln als Werte, damit er testbar bleibt und auch
/// für die Fortschritts-Karte wiederverwendet werden könnte.
class AscentScenePainter extends CustomPainter {
  const AscentScenePainter({
    required this.progress,
    required this.twinkle,
    required this.campFractions,
  });

  /// Fortschritt 0..1 — steuert Pfad-Leuchten, Figur-Position, Sonnenaufgang
  /// und das Ausblenden der Sterne.
  final double progress;

  /// 0..1, läuft dauerhaft im Kreis — lässt die Sterne funkeln.
  final double twinkle;

  /// Positionen der Camps als Anteil am Pfad (0..1).
  final List<double> campFractions;

  static const Size _viewBox = Size(380, 540);

  /// Stützpunkte des Serpentinen-Pfads (Vorlage: WAYPOINTS, unten → oben).
  static const List<Offset> _waypoints = [
    Offset(190, 500),
    Offset(100, 448),
    Offset(280, 412),
    Offset(92, 356),
    Offset(286, 320),
    Offset(112, 268),
    Offset(276, 236),
    Offset(138, 192),
    Offset(252, 160),
    Offset(176, 122),
    Offset(200, 88),
    Offset(190, 66),
  ];

  /// Sterne als (x, y, Radius) — Vorlage: STARS.
  static const List<(double, double, double)> _stars = [
    (60, 90, 1.2),
    (110, 60, 0.9),
    (300, 80, 1.3),
    (250, 130, 0.8),
    (40, 150, 1.0),
    (330, 160, 1.1),
    (180, 70, 0.9),
    (150, 130, 0.7),
    (210, 180, 0.8),
    (90, 200, 0.9),
    (320, 220, 0.8),
  ];

  /// Catmull-Rom → kubische Bézier, wie `smoothPath` in der Vorlage: macht
  /// aus den Stützpunkten einen weich geschwungenen Serpentinen-Pfad.
  static Path buildTrail() {
    final path = Path()..moveTo(_waypoints.first.dx, _waypoints.first.dy);
    for (var i = 0; i < _waypoints.length - 1; i++) {
      final p0 = i == 0 ? _waypoints[i] : _waypoints[i - 1];
      final p1 = _waypoints[i];
      final p2 = _waypoints[i + 1];
      final p3 = i + 2 < _waypoints.length ? _waypoints[i + 2] : p2;
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Die Vorlage ist hochformatig (380×540), die Karte auf der Home-Seite
    // ein breites Banner. Gleichmäßiges Skalieren würde entweder Gipfel und
    // Pfadanfang abschneiden oder große leere Ränder lassen. Deshalb wird
    // die Szene auf das tatsächliche Seitenverhältnis **gemappt**: Himmel,
    // Bergketten und Berg dürfen dabei mitgehen (bei Landschaft fällt das
    // nicht auf), während Pfadbreite, Camps, Figur und Beschriftung in
    // echten Pixeln gezeichnet werden und dadurch unverzerrt bleiben.
    final sx = size.width / _viewBox.width;
    final sy = size.height / _viewBox.height;
    Offset map(Offset p) => Offset(p.dx * sx, p.dy * sy);

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    _paintSky(canvas, size);
    _paintStars(canvas, map);
    _paintSun(canvas, map, sx);
    _paintRidges(canvas, map);
    _paintMountain(canvas, map);

    final trail = buildTrail().transform(
      Matrix4.diagonal3Values(sx, sy, 1).storage,
    );
    _paintTrail(canvas, trail, size);
    _paintCamps(canvas, trail);
    _paintClimber(canvas, trail);

    canvas.restore();
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF4A96A),
            Color(0xFFB0729E),
            Color(0xFF3C4877),
            Color(0xFF0A1029),
          ],
          stops: [0, 0.16, 0.42, 1],
        ).createShader(rect),
    );
  }

  void _paintStars(Canvas canvas, Offset Function(Offset) map) {
    // Sterne verblassen, je weiter der Aufstieg — die Morgendämmerung kommt.
    final baseOpacity = 0.9 * (1 - progress);
    if (baseOpacity <= 0) return;

    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r) = _stars[i];
      // Versetzte Phase je Stern (Vorlage: animationDelay).
      final phase = (twinkle + i * 0.13) % 1;
      final flicker = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
      canvas.drawCircle(
        map(Offset(x, y)),
        r,
        Paint()
          ..color = const Color(0xFFEAF0FB).withValues(
            alpha: baseOpacity * flicker,
          ),
      );
    }
  }

  void _paintSun(Canvas canvas, Offset Function(Offset) map, double sx) {
    // Sonne steigt mit dem Fortschritt und wird kräftiger. Die Deckkraft
    // steckt direkt in den Gradient-Farben: ein `Paint.color` wirkt nicht,
    // sobald ein Shader gesetzt ist.
    final center = map(Offset(250, 120 - progress * 18));
    final radius = 120 * sx;
    final intensity = 0.2 + 0.8 * progress;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          const Color(0xFFFFE7B3).withValues(alpha: intensity),
          const Color(0xFFFFC066).withValues(alpha: intensity),
          const Color(0xFFFF9E5E).withValues(alpha: 0),
        ], [0, 0.45, 1]),
    );
  }

  void _paintRidges(Canvas canvas, Offset Function(Offset) map) {
    canvas.drawPath(
      _pathFrom([
        const Offset(0, 540),
        const Offset(0, 372),
        const Offset(90, 322),
        const Offset(180, 366),
        const Offset(262, 318),
        const Offset(380, 374),
        const Offset(380, 540),
      ], map),
      Paint()..color = const Color(0xFF2A3766).withValues(alpha: 0.55),
    );
    canvas.drawPath(
      _pathFrom([
        const Offset(0, 540),
        const Offset(0, 416),
        const Offset(74, 356),
        const Offset(150, 408),
        const Offset(232, 348),
        const Offset(322, 398),
        const Offset(380, 356),
        const Offset(380, 540),
      ], map),
      Paint()..color = const Color(0xFF212C55).withValues(alpha: 0.8),
    );
  }

  void _paintMountain(Canvas canvas, Offset Function(Offset) map) {
    final mountain = _pathFrom([
      const Offset(-10, 545),
      const Offset(26, 350),
      const Offset(78, 402),
      const Offset(128, 300),
      const Offset(190, 62),
      const Offset(252, 300),
      const Offset(302, 402),
      const Offset(352, 350),
      const Offset(392, 545),
    ], map);
    final bounds = mountain.getBounds();
    canvas.drawPath(
      mountain,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3B4A80), Color(0xFF161E3C)],
        ).createShader(bounds),
    );

    // Schneekappe
    canvas.drawPath(
      _pathFrom([
        const Offset(190, 62),
        const Offset(150, 168),
        const Offset(172, 150),
        const Offset(190, 178),
        const Offset(210, 150),
        const Offset(232, 168),
      ], map),
      Paint()..color = const Color(0xFFEAF1FB).withValues(alpha: 0.92),
    );
    canvas.drawPath(
      _pathFrom([
        const Offset(190, 62),
        const Offset(172, 110),
        const Offset(190, 128),
        const Offset(210, 110),
      ], map),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _paintTrail(Canvas canvas, Path trail, Size size) {
    // Gesamter Pfad, gedämpft.
    canvas.drawPath(
      trail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF0C1330).withValues(alpha: 0.55),
    );

    // Zurückgelegter Teil, leuchtend (Vorlage: strokeDashoffset-Reveal).
    final metrics = trail.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    if (progress <= 0) return;

    final done = metric.extractPath(0, metric.length * progress);
    // Weicher Schein unter der Linie.
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFC24D).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFC24D), Color(0xFFFFE9A8)],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintCamps(Canvas canvas, Path trail) {
    final metrics = trail.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    for (final fraction in campFractions) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null) continue;
      final reached = progress >= fraction - 0.0001;
      final center = tangent.position;

      canvas.drawCircle(
        center,
        reached ? 6.5 : 4.5,
        Paint()
          ..color = reached ? const Color(0xFFFFD37E) : const Color(0xFF141C3A),
      );
      canvas.drawCircle(
        center,
        reached ? 6.5 : 4.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = reached ? const Color(0xFFFFF3D6) : const Color(0xFF5C6B96),
      );
      if (reached) {
        canvas.drawCircle(
          center,
          2.4,
          Paint()..color = const Color(0xFF7A4E12),
        );
      }

      // Prozent-Beschriftung statt der Sprachniveaus der Vorlage. Das
      // Gipfel-Camp bleibt unbeschriftet: dort liegt die Schneekappe (weiß
      // auf weiß) und bei 100 % markiert ohnehin die Fahne den Gipfel.
      if (fraction < 0.999) {
        _paintLabel(
          canvas,
          '${(fraction * 100).round()} %',
          Offset(center.dx, center.dy - 16),
          reached ? const Color(0xFFFFF3D6) : const Color(0xFF8293BC),
        );
      }
    }

    // Gipfelfahne bei erreichten 100 %.
    if (progress >= 0.999) {
      final summit = metric.getTangentForOffset(metric.length)!.position;
      canvas.drawLine(
        summit.translate(0, -6),
        summit.translate(0, -26),
        Paint()
          ..color = const Color(0xFFEAF0FB)
          ..strokeWidth = 2,
      );
      canvas.drawPath(
        _pathFrom([
          summit.translate(0, -26),
          summit.translate(16, -21),
          summit.translate(0, -15),
        ]),
        Paint()..color = const Color(0xFFFF7A6B),
      );
    }
  }

  void _paintClimber(Canvas canvas, Path trail) {
    final metrics = trail.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final at = metric.length * progress;
    final tangent = metric.getTangentForOffset(at);
    if (tangent == null) return;

    final position = tangent.position;
    // Blickrichtung: schaut die Figur bergauf nach links, wird sie gespiegelt.
    final ahead = metric.getTangentForOffset(
      math.min(metric.length, at + 4),
    );
    final flip = ahead != null && ahead.position.dx < position.dx;

    // Pulsierender Halo (Vorlage: .halo-Animation).
    final haloPulse = 0.5 + 0.5 * math.sin(twinkle * 2 * math.pi);
    canvas.drawCircle(
      position,
      15 * (1 + 0.5 * haloPulse),
      Paint()
        ..color = const Color(
          0xFFFF7A6B,
        ).withValues(alpha: 0.28 * (1 - haloPulse * 0.8)),
    );

    canvas.save();
    canvas.translate(position.dx, position.dy);
    if (flip) canvas.scale(-1, 1);

    // Rucksack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.5, -13, 7, 9),
        const Radius.circular(2.2),
      ),
      Paint()..color = const Color(0xFFFFB84D),
    );
    // Körper
    canvas.drawPath(
      _pathFrom([
        const Offset(-1, -3),
        const Offset(1.5, -12),
        const Offset(4, -12),
        const Offset(2, -3),
      ]),
      Paint()..color = const Color(0xFFFF7A6B),
    );
    // Kopf
    canvas.drawCircle(
      const Offset(3, -15),
      3.1,
      Paint()..color = const Color(0xFFFFE1C4),
    );
    // Beine
    final legPaint = Paint()
      ..color = const Color(0xFF243056)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-1, -3), const Offset(-2, 4), legPaint);
    canvas.drawLine(const Offset(2, -3), const Offset(4, 4), legPaint);
    // Stock
    canvas.drawLine(
      const Offset(6, -11),
      const Offset(8, 5),
      Paint()
        ..color = const Color(0xFFEAF0FB)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _paintLabel(Canvas canvas, String text, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  /// Polygon aus Punkten; [map] bildet Vorlagen-Koordinaten auf die
  /// tatsächliche Canvas-Größe ab (Standard: unverändert, für Figuren, die
  /// bereits in Pixeln gezeichnet werden).
  static Path _pathFrom(
    List<Offset> points, [
    Offset Function(Offset)? map,
  ]) {
    final mapped = map == null ? points : points.map(map).toList();
    final path = Path()..moveTo(mapped.first.dx, mapped.first.dy);
    for (final point in mapped.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(AscentScenePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.twinkle != twinkle ||
      oldDelegate.campFractions != campFractions;
}

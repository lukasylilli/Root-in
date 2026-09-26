import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'ascent_scene_painter.dart';
import 'ascent_scene_palette.dart';

/// Berg-Aufstieg als Fortschritts-Metapher auf der Home-Seite (siehe
/// PLAN.md Phase 8/8.6; Aussehen seit Phase 33 nach der Nutzer-Vorlage
/// `mountain_progress_ios.html`): Eine Linie füllt sich vom Fuß des gläsernen
/// Bergs bis zum Gipfel, ein Glas-Pin zeigt die aktuelle Stelle, erreichte
/// Camps leuchten, bei 100 % wird alles grün und der Gipfel funkelt.
///
/// ⚠️ Nur das Aussehen stammt aus der Vorlage. **Was** gezeigt wird, bleibt
/// unverändert: [percent] kommt aus der in den Einstellungen gewählten
/// Kennzahl (`ascentSourceProvider`, siehe `home_page.dart`), die Camps aus
/// [campFractions], die Statuszeile aus denselben Texten wie zuvor.
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

  /// Eckenradius der Karte (Vorlage: `.list`, 26 px).
  static const double _radius = 26;

  @override
  State<HomeProgressAnimation> createState() => _HomeProgressAnimationState();
}

class _HomeProgressAnimationState extends State<HomeProgressAnimation>
    with SingleTickerProviderStateMixin {
  /// Dauer, mit der der Pin weich zur neuen Stelle wandert.
  static const Duration _travel = Duration(milliseconds: 900);

  /// Das Funkeln wartet, bis der Pin oben ist (900 ms), und läuft dann
  /// 1,1 s wie in der Vorlage — zusammen 2 s, davon ab 45 % das Funkeln.
  static const Duration _sparkTotal = Duration(milliseconds: 2000);
  static const Interval _sparkWindow = Interval(0.45, 1);

  late final AnimationController _spark;

  bool _isSummit(double percent) =>
      percent.clamp(0.0, 1.0) >= AscentScenePainter.summit;

  @override
  void initState() {
    super.initState();
    // Läuft nur einmal beim Erreichen des Gipfels, nie dauerhaft.
    _spark = AnimationController(vsync: this, duration: _sparkTotal);
    if (_isSummit(widget.percent)) _spark.forward();
  }

  @override
  void didUpdateWidget(HomeProgressAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSummit = _isSummit(oldWidget.percent);
    final isSummit = _isSummit(widget.percent);
    if (isSummit && !wasSummit) {
      _spark.forward(from: 0);
    } else if (!isSummit && wasSummit) {
      _spark.value = 0;
    }
  }

  @override
  void dispose() {
    _spark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = AppAssets.homeAnimation;
    final clamped = widget.percent.clamp(0.0, 1.0);
    final palette = AscentScenePalette.of(Theme.of(context).brightness);
    final radius = BorderRadius.circular(HomeProgressAnimation._radius);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          foregroundPainter: _GlassRimPainter(
            color: palette.glassRim,
            radius: HomeProgressAnimation._radius,
          ),
          child: SizedBox(
            height: HomeProgressAnimation._height,
            width: double.infinity,
            child: asset == null
                ? _AscentScene(
                    percent: clamped,
                    sourceLabel: widget.sourceLabel,
                    palette: palette,
                    spark: _spark,
                    sparkWindow: _sparkWindow,
                    travel: reduceMotion ? Duration.zero : _travel,
                    reduceMotion: reduceMotion,
                  )
                : Lottie.asset(asset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _AscentScene extends StatelessWidget {
  const _AscentScene({
    required this.percent,
    required this.sourceLabel,
    required this.palette,
    required this.spark,
    required this.sparkWindow,
    required this.travel,
    required this.reduceMotion,
  });

  final double percent;
  final String sourceLabel;
  final AscentScenePalette palette;
  final Animation<double> spark;
  final Interval sparkWindow;
  final Duration travel;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    // Die Vorlage ist für Rechts-nach-links gebaut; bei Links-nach-rechts
    // wird die Szene gespiegelt, damit der Aufstieg in Leserichtung läuft.
    // Der Gipfel liegt dann immer auf der Endseite, die Statuszeile oben auf
    // der Startseite — sie überdecken sich nie.
    final mirrored = Directionality.of(context) == TextDirection.ltr;

    return TweenAnimationBuilder<double>(
      // Bei Fortschritts-Änderung wandert der Pin weich den Pfad hinauf,
      // statt zu springen.
      tween: Tween<double>(end: percent),
      duration: travel,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: spark,
              builder: (context, _) => CustomPaint(
                painter: AscentScenePainter(
                  progress: value,
                  campFractions: HomeProgressAnimation.campFractions,
                  palette: palette,
                  mirrored: mirrored,
                  spark: reduceMotion
                      ? (percent >= AscentScenePainter.summit ? 1.0 : 0.0)
                      : sparkWindow.transform(spark.value),
                ),
              ),
            ),
            // Breite begrenzt: rechts davon beginnt der Berg. 170 px, damit
            // auch die dreistellige „100 %"-Anzeige noch hineinpasst.
            PositionedDirectional(
              top: AppSpacing.md,
              start: AppSpacing.md + AppSpacing.xs,
              width: 170,
              child: _Hud(
                percent: value,
                sourceLabel: sourceLabel,
                palette: palette,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.percent,
    required this.sourceLabel,
    required this.palette,
  });

  final double percent;
  final String sourceLabel;
  final AscentScenePalette palette;

  @override
  Widget build(BuildContext context) {
    final rounded = (percent * 100).round();
    final summit = percent >= AscentScenePainter.summit;
    final nextCamp = HomeProgressAnimation.campFractions
        .where((fraction) => fraction > percent + 0.0001)
        .firstOrNull;
    const tabular = [FontFeature.tabularFigures()];

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
              style: TextStyle(
                color: palette.label,
                fontSize: 44,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                fontFeatures: tabular,
              ),
            ),
            Text(
              '%',
              style: TextStyle(
                color: palette.secondaryLabel,
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
          style: TextStyle(
            color: summit ? palette.complete : palette.label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFeatures: tabular,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sourceLabel,
          style: TextStyle(
            color: palette.secondaryLabel,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Feine Lichtkante des Glases rund um die Karte (Vorlage: `.glass::before`,
/// Verlauf unter 160° — oben und unten hell, in der Mitte durchsichtig).
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(0.5);
    final faded = color.withValues(alpha: color.a * 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius - 0.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: const Alignment(-0.342, -0.94),
          end: const Alignment(0.342, 0.94),
          colors: [
            faded,
            faded.withValues(alpha: 0),
            faded.withValues(alpha: 0),
            faded,
          ],
          stops: const [0, 0.38, 0.62, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

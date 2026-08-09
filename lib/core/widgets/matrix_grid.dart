import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme_tokens.dart';
import '../utils/date_utils.dart';

/// Einziges Matrix-/Heatmap-Grid der App (GitHub-Contribution-Stil).
/// Spalten = Kalenderwochen (Mo–So), Farbintensität = Erledigungsgrad des
/// Tages (0..1). Wird auf jeder Seite mit kontextabhängigem Zeitraum
/// eingebunden (Home, Heute, Woche, Monat, Jahr, Konto) — nirgendwo
/// eigene Heatmap-Zellen nachbauen.
class MatrixGrid extends StatelessWidget {
  const MatrixGrid({
    super.key,
    required this.start,
    required this.end,
    required this.intensities,
    this.cellSize = 16,
    this.fitToWidth = false,
    this.tokens,
  });

  /// Erster angezeigter Tag (wird auf Mitternacht normalisiert).
  final DateTime start;

  /// Letzter angezeigter Tag (inklusive).
  final DateTime end;

  /// Erledigungs-Intensität je Tag (Schlüssel: Mitternacht-normalisiert).
  final Map<DateTime, double> intensities;

  /// Zellengröße bei [fitToWidth] == false.
  final double cellSize;

  /// Verkleinert die Zellen so, dass **alle** Wochen in die verfügbare
  /// Breite passen — kein horizontales Scrollen (siehe PLAN.md Phase 8.5).
  /// Für lange Zeiträume (Jahr, Fortschritts-Karte) gedacht; kurze Zeiträume
  /// behalten mit `false` ihre feste, gut greifbare Zellengröße.
  final bool fitToWidth;

  /// Design-Tokens für die Heatmap-Farbe (siehe PLAN.md Phase 10.6a). Ist
  /// keiner gesetzt, greift der Fallback über das Material-`ColorScheme`
  /// (für Aufrufer/Tests, die noch keine Tokens durchreichen).
  final AppThemeTokens? tokens;

  /// Anteil der Spaltenbreite, den die Zelle selbst einnimmt; der Rest ist
  /// Abstand zur Nachbarspalte.
  static const double _cellWidthRatio = 0.82;

  @override
  Widget build(BuildContext context) {
    final firstDay = dateOnly(start);
    final lastDay = dateOnly(end);
    final firstMonday = weekStartOf(firstDay);
    final dayCount = lastDay.difference(firstMonday).inDays + 1;
    final weekCount = (dayCount / 7).ceil();

    if (!fitToWidth) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // neueste Woche zuerst sichtbar
        child: _grid(
          context,
          firstMonday,
          weekCount,
          firstDay,
          lastDay,
          cellSize,
          AppSpacing.xs / 2,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Zelle **und** Rand aus der verfügbaren Breite ableiten: würde nur
        // die Zelle skaliert und der Rand fix bleiben, liefe das Grid bei
        // vielen Wochen trotzdem über (dann greift keine Zellengröße mehr,
        // weil der Rand allein schon zu breit ist).
        final available = constraints.maxWidth - 1; // Rundungs-Puffer
        final perColumn = weekCount == 0 ? available : available / weekCount;
        final cell = (perColumn * _cellWidthRatio).clamp(0.0, cellSize);
        final margin = ((perColumn - cell) / 2).clamp(0.0, AppSpacing.xs / 2);
        return _grid(
          context,
          firstMonday,
          weekCount,
          firstDay,
          lastDay,
          cell,
          margin,
        );
      },
    );
  }

  Widget _grid(
    BuildContext context,
    DateTime firstMonday,
    int weekCount,
    DateTime firstDay,
    DateTime lastDay,
    double size,
    double margin,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var week = 0; week < weekCount; week++)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                _cell(
                  context,
                  addDays(firstMonday, week * 7 + weekday),
                  firstDay,
                  lastDay,
                  size,
                  margin,
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime day,
    DateTime firstDay,
    DateTime lastDay,
    double size,
    double margin,
  ) {
    final inRange = !day.isBefore(firstDay) && !day.isAfter(lastDay);
    if (!inRange) {
      // Unsichtbare Füllzelle, damit die Wochenspalte ausgerichtet bleibt.
      return SizedBox(
        width: size + margin * 2,
        height: size + margin * 2,
      );
    }

    final intensity = intensities[day] ?? 0;

    final Color color;
    if (tokens != null) {
      color = tokens!.heat(intensity);
    } else {
      final scheme = Theme.of(context).colorScheme;
      if (intensity <= 0) {
        color = scheme.surfaceContainerHighest;
      } else {
        // 0.25–1.0, damit auch kleine Intensitäten sichtbar bleiben.
        color = scheme.primary.withValues(alpha: 0.25 + 0.75 * intensity);
      }
    }

    return Container(
      key: ValueKey(day),
      width: size,
      height: size,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm / 2),
      ),
    );
  }
}

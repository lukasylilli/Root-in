import 'package:flutter/material.dart';

/// Zentrale Design-Tokens der App (siehe PLAN.md Phase 10.6a). Struktur und
/// Namen sind aus der Multi-Theme-Spec `meine/habit_tracker_APP_SCREEN_specs.json`
/// (SCREEN_13) übernommen: die Akzentfarbe färbt Tagesring, Habit-Icons,
/// Statusringe und den Aktiv-Zustand der Navigation — sonst nichts.
///
/// Eine Instanz beschreibt **ein** Theme in **einer** Helligkeit. Screens
/// und Widgets lesen die Tokens über `appTokensProvider` (siehe
/// `core/services/settings_service.dart`), statt Farben selbst zu wählen —
/// so ändert der Wechsel von Theme/Helligkeit die ganze App an einer Stelle
/// (Design-Token-Prinzip, PLAN.md Abschnitt 9).
@immutable
class AppThemeTokens {
  const AppThemeTokens({
    required this.accent,
    required this.accentSecondary,
    required this.screenBg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.ringTrack,
  });

  /// Primäre Akzentfarbe — auch Seed für das Material-`ColorScheme`.
  final Color accent;

  /// Hellere Variante des Akzents (z. B. Verläufe, sekundäre Marker).
  final Color accentSecondary;

  final Color screenBg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  /// Unausgefüllter Teil von Fortschrittsringen und leere Heatmap-Zellen.
  final Color ringTrack;

  /// Heatmap-/Intensitätsfarbe (0..1): leere Zellen = [ringTrack], gefüllte
  /// verlaufen von blass zu vollem Akzent. Entspricht der bisherigen
  /// Matrix-Grid-Logik (Farbe = Intensität nach Erfüllung, Nutzerwahl vom
  /// 2026-07-23), jetzt aus den Tokens gespeist.
  Color heat(double intensity) {
    if (intensity <= 0) return ringTrack;
    return Color.lerp(
      accent.withValues(alpha: 0.25),
      accent,
      intensity.clamp(0.0, 1.0),
    )!;
  }
}

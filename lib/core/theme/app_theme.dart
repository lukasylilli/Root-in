import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_spacing.dart';
import 'app_theme_tokens.dart';

/// Baut die Light-/Dark-ThemeData der App aus einem vollständigen
/// [AppThemeTokens]-Satz (siehe `app_theme_variant.dart` — vom Nutzer
/// wählbar, Phase 6/10.6) und [AppFonts]. Screens und Widgets lesen
/// Farben/Styles über `Theme.of(context)` bzw. `appTokensProvider`, statt
/// eigene ThemeData zu erzeugen. Das Button-Theme hier sorgt dafür, dass
/// *jeder* Button (nicht nur [AppButton]) automatisch der App-Optik folgt.
abstract final class AppTheme {
  static ThemeData light(AppThemeTokens tokens) => _themeFrom(
    ColorScheme.fromSeed(seedColor: tokens.accent),
    tokens,
  );

  static ThemeData dark(AppThemeTokens tokens) => _themeFrom(
    ColorScheme.fromSeed(
      seedColor: tokens.accent,
      brightness: Brightness.dark,
    ),
    tokens,
  );

  static ThemeData _themeFrom(ColorScheme colorScheme, AppThemeTokens tokens) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppFonts.primaryFontFamily,
      // Flächen aus den Design-Tokens (Spec SCREEN_13): dunkler
      // Bildschirmgrund, leicht abgesetzte Karten — statt der
      // Material-Standardflächen.
      scaffoldBackgroundColor: tokens.screenBg,
      cardTheme: CardThemeData(
        color: tokens.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.screenBg,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

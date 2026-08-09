import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import 'app_theme_tokens.dart';

/// Auswählbare Farb-Themes der App (siehe PLAN.md Phase 6 + 10.6a). Jede
/// Variante liefert einen vollständigen [AppThemeTokens]-Satz je Helligkeit
/// (nicht mehr nur eine Seed-Farbe). Akzent-/Ring-Track-Werte sind an die
/// Multi-Theme-Spec (`meine/…APP_SCREEN_specs.json`, SCREEN_13) angelehnt;
/// die neutralen Flächen kommen aus derselben Spec.
enum AppThemeVariant {
  green,
  blue,
  purple,
  orange;

  /// Primäre Akzentfarbe — bleibt auch Seed für das Material-`ColorScheme`
  /// (siehe `app_theme.dart`). Über beide Helligkeiten identisch.
  Color get seedColor => switch (this) {
    AppThemeVariant.green => const Color(0xFF2E7D5B),
    AppThemeVariant.blue => const Color(0xFF5B6FE8),
    AppThemeVariant.purple => const Color(0xFF8B5CF6),
    AppThemeVariant.orange => const Color(0xFFF2621F),
  };

  Color get _accentSecondary => switch (this) {
    AppThemeVariant.green => const Color(0xFF5FB98C),
    AppThemeVariant.blue => const Color(0xFF7B8CF0),
    AppThemeVariant.purple => const Color(0xFFA78BFA),
    AppThemeVariant.orange => const Color(0xFFFF8A4C),
  };

  /// Vollständiger Token-Satz für die gewählte [brightness].
  AppThemeTokens tokens(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppThemeTokens(
            accent: seedColor,
            accentSecondary: _accentSecondary,
            screenBg: const Color(0xFF0A0A0C),
            cardBg: const Color(0xFF1A1A1C),
            textPrimary: const Color(0xFFFFFFFF),
            textSecondary: const Color(0xFF8E8E93),
            ringTrack: const Color(0xFF2A2A2C),
          )
        : AppThemeTokens(
            accent: seedColor,
            accentSecondary: _accentSecondary,
            screenBg: const Color(0xFFFFFFFF),
            cardBg: const Color(0xFFF5F5F7),
            textPrimary: const Color(0xFF1C1C1E),
            textSecondary: const Color(0xFF8E8E93),
            ringTrack: const Color(0xFFE5E5EA),
          );
  }

  String label(AppLocalizations l10n) => switch (this) {
    AppThemeVariant.green => l10n.colorGreen,
    AppThemeVariant.blue => l10n.colorBlue,
    AppThemeVariant.purple => l10n.colorPurple,
    AppThemeVariant.orange => l10n.colorOrange,
  };
}

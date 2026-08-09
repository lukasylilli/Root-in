import 'dart:ui' show PlatformDispatcher, TextDirection;

import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

/// Vom Nutzer wählbare App-Sprache (siehe PLAN.md Phase 11). Einzige Quelle
/// dafür, welche Sprachen es gibt — die Einstellungen-Seite iteriert über
/// `values`, statt eine eigene Liste zu pflegen (Design-Token-Prinzip,
/// PLAN.md Abschnitt 9).
enum AppLanguage {
  /// Folgt der Systemsprache des Geräts; fällt auf Deutsch zurück, wenn das
  /// System keine unterstützte Sprache meldet.
  system,

  /// Seit Phase 18 eine **vollwertige** dritte Sprache: Oberfläche und
  /// Anleitungs-Texte laufen beide auf Persisch, die Laufrichtung dreht
  /// Flutter über `Directionality` mit. Bis Phase 17.2 schaltete sie nur die
  /// Anleitungen um; der dafür nötige zweite Begriff (`contentLanguageCode`)
  /// ist damit ersatzlos entfallen.
  persian,
  german,
  english;

  /// Sprache der **Oberfläche**. `null` bei [AppLanguage.system] — genau das
  /// erwartet `MaterialApp.locale`, um die Systemsprache selbst aufzulösen.
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.persian => const Locale('fa'),
    AppLanguage.german => const Locale('de'),
    AppLanguage.english => const Locale('en'),
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.system => l10n.languageSystem,
    AppLanguage.persian => l10n.languagePersian,
    AppLanguage.german => l10n.languageGerman,
    AppLanguage.english => l10n.languageEnglish,
  };
}

/// Sprache der ARB-Vorlage — Rückfallebene, wenn das Gerät keine der
/// unterstützten Sprachen meldet.
const Locale fallbackLocale = Locale('de');

/// Sprachen, die von rechts nach links laufen. Bislang nur Persisch;
/// Arabisch, Hebräisch und Urdu stehen gleich mit, damit die Erweiterung
/// später nichts kostet.
const Set<String> rtlLanguageCodes = {'fa', 'ar', 'he', 'ur'};

/// Laufrichtung für [languageCode].
///
/// Liegt in `core/`, weil sie zwei Rubriken betrifft: die Anleitung und
/// „موارد دیگر" (PLAN.md Phase 17.1 und 22). Sie hängt an der **Sprache des
/// Inhalts**, nicht an der des Geräts — ein persischer Text bleibt
/// rechtsläufig, auch wenn die App sonst links läuft.
TextDirection textDirectionForLanguage(String languageCode) =>
    rtlLanguageCodes.contains(languageCode)
    ? TextDirection.rtl
    : TextDirection.ltr;

/// Löst [language] zu einer **konkreten** Sprache auf. Nötig für Texte
/// außerhalb des Widget-Baums (Notifications, siehe
/// `core/services/notification_service.dart`): dort gibt es keinen
/// `BuildContext`, aus dem Flutter die Systemsprache ableiten könnte.
Locale resolveLocale(AppLanguage language) {
  final explicit = language.locale;
  if (explicit != null) return explicit;

  for (final deviceLocale in PlatformDispatcher.instance.locales) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == deviceLocale.languageCode) return supported;
    }
  }
  return fallbackLocale;
}

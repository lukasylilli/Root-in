import 'package:flutter/material.dart';
import 'package:root_in/l10n/gen/app_localizations.dart';

/// Rahmen für Widget-Tests (siehe PLAN.md Phase 11): `MaterialApp` mit den
/// Übersetzungs-Delegates und fest eingestellter Sprache.
///
/// Ein blankes `MaterialApp` reicht seit Phase 11 nicht mehr — jedes Widget,
/// das `AppLocalizations.of(context)` liest, wirft dort. Die Sprache ist
/// standardmäßig Deutsch, damit die Tests die deutschen Texte prüfen können;
/// mit [locale] lässt sich gezielt die englische Fassung testen.
Widget localizedApp(Widget home, {Locale locale = const Locale('de')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

/// Übersetzungen ohne Widget-Baum — für Tests von Diensten, die
/// [AppLocalizations] als Parameter nehmen (z. B. `HomeWidgetService`).
AppLocalizations testL10n([Locale locale = const Locale('de')]) =>
    lookupAppLocalizations(locale);

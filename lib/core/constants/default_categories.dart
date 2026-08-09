import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// Eine Standard-Kategorie der Erstinstallation (siehe PLAN.md Abschnitt 6 und
/// Phase 21.1).
///
/// Die sieben Einträge sind **die sieben Fertigkeiten** aus der Anleitung
/// („Lernplanung" und „Lernquellen" im Repository) — nicht frei erfunden,
/// damit App und Anleitung dieselbe Sprache sprechen. Kurs- und
/// Videounterricht zählen dort zu **Grammatik**; eine eigene Kategorie dafür
/// gibt es bewusst nicht.
///
/// Aufbau wie bei `habit_templates.dart`: stabile, sprachunabhängige [id] im
/// Code, sichtbarer Name über [AppLocalizations]. Angelegt werden sie beim
/// Erststart in der gewählten Sprache; ab dann sind es **Nutzerdaten** — frei
/// umbenennbar, löschbar, erweiterbar. Nichts im Code schützt sie.
class DefaultCategory {
  const DefaultCategory({required this.id, required this.icon});

  /// Stabiler, sprachunabhängiger Schlüssel. Auch `HabitTemplate.categoryId`
  /// verweist hierauf — so gibt es für die sieben Namen genau eine Quelle.
  final String id;

  /// Symbol für die Kategorien-Liste. Die Datenbank kennt keine Symbol-Spalte
  /// (offene Frage in PLAN.md Abschnitt 12) — [iconForName] ordnet es deshalb
  /// über den Namen zu.
  final IconData icon;

  /// Eine neue Kategorie braucht hier **und** in allen drei ARB-Dateien einen
  /// Eintrag; ohne passenden Fall bliebe sonst die rohe [id] sichtbar.
  String name(AppLocalizations l10n) => switch (id) {
    'grammar' => l10n.categoryGrammar,
    'vocabulary' => l10n.categoryVocabulary,
    'memorization' => l10n.categoryMemorization,
    'reading' => l10n.categoryReading,
    'writing' => l10n.categoryWriting,
    'speaking' => l10n.categorySpeaking,
    'listening' => l10n.categoryListening,
    _ => id,
  };

  /// Symbol zu einem gespeicherten Kategorie-Namen — oder das neutrale
  /// Ersatz-Symbol, wenn der Name zu keiner Standard-Kategorie passt.
  ///
  /// Bewusst über den **Namen**: Kategorien werden als Text referenziert
  /// (siehe PLAN.md, Entscheidung vom 2026-07-20), eine Kategorie kennt ihre
  /// Herkunfts-[id] also nicht. Wer eine Standard-Kategorie umbenennt,
  /// verliert damit ihr Symbol — richtig so, sie ist ab dann eine eigene.
  static IconData iconForName(String name, AppLocalizations l10n) {
    for (final category in defaultCategories) {
      if (category.name(l10n) == name) return category.icon;
    }
    return Icons.label_outline;
  }
}

/// Einzige Quelle für die Standard-Kategorien (siehe PLAN.md Abschnitt 6).
const List<DefaultCategory> defaultCategories = [
  DefaultCategory(id: 'grammar', icon: Icons.rule_outlined),
  DefaultCategory(id: 'vocabulary', icon: Icons.style_outlined),
  DefaultCategory(id: 'memorization', icon: Icons.psychology_outlined),
  DefaultCategory(id: 'reading', icon: Icons.chrome_reader_mode_outlined),
  DefaultCategory(id: 'writing', icon: Icons.create_outlined),
  DefaultCategory(id: 'speaking', icon: Icons.record_voice_over_outlined),
  DefaultCategory(id: 'listening', icon: Icons.headphones_outlined),
];

/// Die sieben Namen in der Reihenfolge oben — das, was Datenbank und
/// Nachrüst-Knopf brauchen.
List<String> defaultCategoryNames(AppLocalizations l10n) => [
  for (final category in defaultCategories) category.name(l10n),
];

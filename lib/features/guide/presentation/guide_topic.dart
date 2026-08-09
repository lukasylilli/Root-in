import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Die Themen der Rubrik „Root-in Anleitung" (siehe PLAN.md Phase 17) —
/// einzige Quelle dafür, welche Anleitungs-Seiten es gibt.
///
/// Titel, Untertitel, Symbol, Routen-Schnipsel **und** die Dateinamen im
/// Inhalts-Repository hängen hier zusammen: Einstellungen-Liste, Router und
/// Seite lesen alle aus diesem Enum, statt die vier Themen je selbst
/// aufzuzählen. Ein neues Thema ergänzt man an genau einer Stelle — hier —
/// plus seinen Texten in `app_de.arb`/`app_en.arb`.
enum GuideTopic {
  studyPlanning('study-planning', Icons.event_note_outlined, {
    'de': 'lernplanung',
    'en': 'lernplanung',
    'fa': 'lernplanung',
  }),
  studyResources('study-resources', Icons.menu_book_outlined, {
    'de': 'lernquellen_a1',
    'en': 'lernquellen_a1_en',
    'fa': 'lernquellen_a1_fa',
  }),
  studyMethod('study-method', Icons.psychology_outlined, {
    'de': 'lernmethode_de',
    'en': 'lernmethode_en',
    'fa': 'lernmethode_fa',
  }),
  essentialLinks('links', Icons.link_outlined, {
    'de': 'links_de',
    'en': 'links_en',
    'fa': 'links_fa',
  });

  const GuideTopic(this.slug, this.icon, this._fileNames);

  /// Letzter Pfad-Abschnitt der Route, z. B. `study-planning`.
  final String slug;

  final IconData icon;

  /// Dateiname im Inhalts-Repository **je Sprache**, ohne `.md` — der Text
  /// liegt dort unter `content/<sprache>/<name>.md` (siehe
  /// `core/services/repo_content_service.dart`).
  final Map<String, String> _fileNames;

  /// Name der Markdown-Datei für [languageCode].
  ///
  /// Die Namen folgen **absichtlich keinem Muster**: Sie heißen im
  /// Inhalts-Repository so, wie sie heißen (`lernplanung.md` überall,
  /// `lernmethode_de.md` je Sprache, `lernquellen_a1.md` nur im Deutschen ohne
  /// Sprachkürzel). Deshalb stehen sie hier ausdrücklich Zeile für Zeile statt
  /// als zusammengesetzte Regel — eine Regel würde beim nächsten Namen, der
  /// nicht dazu passt, still die falsche Adresse bauen.
  ///
  /// **Preis dieser Lösung:** Wird eine Datei im Repository umbenannt, braucht
  /// es eine neue App-Version. Das gilt nur für Namen — der **Inhalt** der
  /// Dateien wird weiterhin ohne App-Update übernommen.
  ///
  /// Bewusst getrennt vom [slug]: Die Route ist Teil der App, der Dateiname
  /// Teil des Repositories, und beide sollen sich unabhängig ändern dürfen.
  String fileName(String languageCode) =>
      // Fehlt eine Sprache, wird Deutsch geladen — dieselbe Entscheidung wie
      // in `guideLanguageCode`: besser ein Text in der falschen Sprache als
      // eine leere Seite.
      _fileNames[languageCode] ?? _fileNames['de']!;

  /// Vollständiger Routen-Pfad. Das Präfix kommt aus [AppRoutes], damit
  /// Pfade weiterhin nur an einer Stelle stehen.
  String get route => '${AppRoutes.guide}/$slug';

  String label(AppLocalizations l10n) => switch (this) {
    GuideTopic.studyPlanning => l10n.guidePlanning,
    GuideTopic.studyResources => l10n.guideResources,
    GuideTopic.studyMethod => l10n.guideMethod,
    GuideTopic.essentialLinks => l10n.guideLinks,
  };

  /// Eine Zeile darunter — in der Einstellungen-Liste und im Seitenkopf.
  String subtitle(AppLocalizations l10n) => switch (this) {
    GuideTopic.studyPlanning => l10n.guidePlanningSubtitle,
    GuideTopic.studyResources => l10n.guideResourcesSubtitle,
    GuideTopic.studyMethod => l10n.guideMethodSubtitle,
    GuideTopic.essentialLinks => l10n.guideLinksSubtitle,
  };
}

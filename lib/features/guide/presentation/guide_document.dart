import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/repo_content_service.dart';
import '../../../core/services/settings_service.dart';
import 'guide_topic.dart';

/// Sprachen, in denen es die Anleitungs-Texte im Repository gibt. Meldet die
/// App eine andere Sprache, wird auf [_fallbackContentLanguage] gelesen —
/// besser ein Text in der falschen Sprache als eine leere Seite.
const Set<String> guideContentLanguages = {'de', 'en', 'fa'};

const String _fallbackContentLanguage = 'de';

/// Sprachcode für die Inhalts-Adresse, abgeleitet aus der **in der App
/// gewählten** Sprache (siehe `resolvedLocaleProvider`).
String guideLanguageCode(Locale locale) {
  return guideContentLanguages.contains(locale.languageCode)
      ? locale.languageCode
      : _fallbackContentLanguage;
}

/// Sprache, in der die Anleitungen geladen werden: **die der Oberfläche**.
///
/// Bis Phase 17.2 gab es hier einen Sonderweg für Persisch, weil es die
/// Oberfläche noch nicht auf Persisch gab. Mit Phase 18 ist Persisch eine
/// vollwertige App-Sprache — der Sonderweg ist ersatzlos entfallen und
/// `resolvedLocaleProvider` liefert die Antwort für alle drei Sprachen gleich.
final guideLanguageProvider = Provider<String>((ref) {
  return guideLanguageCode(ref.watch(resolvedLocaleProvider));
});

/// Der Text einer Anleitungs-Seite: geladen, aus dem Speicher oder `null`,
/// wenn es die Seite in dieser Sprache noch nicht gibt (siehe PLAN.md
/// Phase 17.1).
///
/// Hängt an [guideLanguageProvider] — ein Sprachwechsel in den Einstellungen
/// lädt die Seite damit von selbst in der neuen Sprache neu.
final guideDocumentProvider = FutureProvider.family<String?, GuideTopic>((
  ref,
  topic,
) async {
  final service = ref.watch(repoContentServiceProvider);
  final language = ref.watch(guideLanguageProvider);

  // Die Nachlade-Meldung kommt aus einem Aufruf, der die Seite überleben kann
  // (der Nutzer blättert weiter, während geladen wird). Ohne diese Sperre
  // liefe `invalidateSelf` dann auf einen bereits verworfenen Provider.
  var disposed = false;
  ref.onDispose(() => disposed = true);

  return service.load(
    // Der Dateiname hängt an der Sprache: Die Dateien heißen im
    // Inhalts-Repository je Sprache unterschiedlich (siehe GuideTopic).
    RepoContentService.guidePath(topic.fileName(language), language),
    // Der Dienst zeigt erst den gespeicherten Stand und lädt daneben nach;
    // kam dabei ein **anderer** Text heraus, wird die Seite neu aufgebaut.
    onUpdated: () {
      if (!disposed) ref.invalidateSelf();
    },
  );
});

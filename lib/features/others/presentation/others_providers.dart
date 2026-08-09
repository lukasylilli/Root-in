import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/repo_content_service.dart';
import '../../guide/presentation/guide_document.dart';
import '../domain/others_manifest.dart';

/// Ordner im Inhalts-Repository, unter dem die Rubrik „موارد دیگر" liegt —
/// einzige Stelle mit diesem Namen (siehe PLAN.md Phase 22).
const String othersFolder = 'others';

/// Pfad des Manifests für [languageCode], relativ zu `content/`.
String othersManifestPath(String languageCode) =>
    '$othersFolder/$languageCode/index.json';

/// Pfad eines Textes, relativ zu `content/`. [filePath] kommt aus dem
/// Manifest und ist bereits relativ zum Sprachordner.
String othersEntryPath(String languageCode, String filePath) =>
    '$othersFolder/$languageCode/$filePath';

/// Die Sprache, in der die Rubrik geladen wird — dieselbe wie bei den
/// Anleitungen (siehe [guideLanguageProvider]). Damit folgt sie der
/// App-Sprache und fällt auf Deutsch zurück, wenn es die Sprache im
/// Repository nicht gibt.
final othersLanguageProvider = Provider<String>(
  (ref) => ref.watch(guideLanguageProvider),
);

/// Struktur der Rubrik: Ordner und ihre Texte, nach `order` sortiert.
///
/// Lädt `content/<ordner>/<sprache>/index.json` über den gemeinsamen
/// [RepoContentService] — also mit demselben Zwischenspeicher wie die
/// Anleitungen: Der zuletzt geladene Stand steht sofort da, im Hintergrund
/// wird nachgeladen, und **nur bei echter Änderung** baut sich die Seite neu
/// auf (sonst Endlosschleife, siehe Phase 17.1).
///
/// Wirft [OthersManifestException], wenn die Datei fehlt oder kaputt ist —
/// die Seite unterscheidet die Gründe und zeigt sie verständlich an.
final othersManifestProvider = FutureProvider<OthersManifest>((ref) async {
  final service = ref.watch(repoContentServiceProvider);
  final language = ref.watch(othersLanguageProvider);

  // Die Nachlade-Meldung kann die Seite überleben (der Nutzer blättert
  // weiter, während geladen wird). Ohne diese Sperre liefe `invalidateSelf`
  // auf einen bereits verworfenen Provider.
  var disposed = false;
  ref.onDispose(() => disposed = true);

  final raw = await service.load(
    othersManifestPath(language),
    onUpdated: () {
      if (!disposed) ref.invalidateSelf();
    },
  );

  // 404: Die Rubrik gibt es in dieser Sprache (noch) nicht — das ist kein
  // Fehler, sondern ein leerer Kanal.
  if (raw == null) return OthersManifest.empty;

  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (error) {
    throw OthersManifestException(
      OthersManifestError.invalidJson,
      error.toString(),
    );
  }
  return OthersManifest.fromJson(decoded);
});

/// Ein einzelner Ordner aus dem Manifest — `null`, wenn es ihn (nicht mehr)
/// gibt. Der Fall ist real: Die Route bleibt im Verlauf stehen, während der
/// Autor den Ordner im Repository umbenennt.
final othersFolderProvider = Provider.family<OthersFolder?, String>((ref, id) {
  final manifest = ref.watch(othersManifestProvider).value;
  if (manifest == null) return null;
  for (final folder in manifest.folders) {
    if (folder.id == id) return folder;
  }
  return null;
});

/// Der Markdown-Text eines Eintrags. `null` = die Datei steht zwar im
/// Manifest, liegt aber (noch) nicht im Repository → „Inhalt folgt".
final othersEntryProvider = FutureProvider.family<String?, String>((
  ref,
  filePath,
) async {
  final service = ref.watch(repoContentServiceProvider);
  final language = ref.watch(othersLanguageProvider);

  var disposed = false;
  ref.onDispose(() => disposed = true);

  return service.load(
    othersEntryPath(language, filePath),
    onUpdated: () {
      if (!disposed) ref.invalidateSelf();
    },
  );
});

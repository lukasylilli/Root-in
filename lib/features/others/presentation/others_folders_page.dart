import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/widgets/markdown_view.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/others_manifest.dart';
import 'others_providers.dart';

/// Einstieg in die Rubrik „موارد دیگر" (siehe PLAN.md Phase 22): die Ordner
/// als Knöpfe, in der Reihenfolge, die der Autor im Repository festlegt.
///
/// **Ein einseitiger Kanal.** Der Nutzer der App liest hier nur; geschrieben
/// wird ausschließlich im GitHub-Repository. Ändert der Autor dort etwas,
/// ändert sich diese Seite ohne App-Update.
class OthersFoldersPage extends ConsumerWidget {
  const OthersFoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = ref.watch(appTokensProvider(Theme.of(context).brightness));
    final manifest = ref.watch(othersManifestProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.othersTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          manifest.when(
            loading: () => ContentLoading(tokens: tokens),
            error: (error, _) => ContentLoadFailed(
              tokens: tokens,
              onRetry: () => ref.invalidate(othersManifestProvider),
              // Ein kaputtes Manifest ist etwas anderes als fehlendes Netz —
              // der Autor soll erfahren, dass **seine Datei** das Problem
              // ist, nicht die Verbindung des Nutzers.
              title: error is OthersManifestException
                  ? l10n.othersBrokenTitle
                  : null,
              body: error is OthersManifestException
                  ? l10n.othersBrokenBody
                  : null,
            ),
            data: (data) => data.folders.isEmpty
                ? ContentComingSoon(tokens: tokens)
                : Column(
                    children: [
                      for (final folder in data.folders)
                        _FolderTile(folder: folder, tokens: tokens),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Ein Ordner als Knopf. Der Titel kommt roh aus dem Manifest — Emoji und
/// persische Schrift ausdrücklich erlaubt, deshalb hier kein eigenes Symbol
/// davor: Der Autor setzt es selbst in den Titel, wenn er eines will.
class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder, required this.tokens});

  final OthersFolder folder;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(
          folder.title,
          style: AppTextStyles.title.copyWith(color: tokens.textPrimary),
        ),
        subtitle: Text(
          l10n.othersEntryCount(folder.entries.length),
          style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.othersFolder(folder.id)),
      ),
    );
  }
}

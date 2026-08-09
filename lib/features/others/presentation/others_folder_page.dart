import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/widgets/markdown_view.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/others_manifest.dart';
import 'others_providers.dart';

/// Die Texte **eines** Ordners der Rubrik „موارد دیگر" (PLAN.md Phase 22).
///
/// Der Text wird nicht auf einer weiteren Seite geöffnet, sondern hier
/// aufgeklappt: Ein Kanal-Beitrag ist meist kurz, und ein Sprung auf eine
/// dritte Ebene für drei Zeilen wäre mehr Weg als Inhalt.
class OthersFolderPage extends ConsumerWidget {
  const OthersFolderPage({super.key, required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = ref.watch(appTokensProvider(Theme.of(context).brightness));
    final folder = ref.watch(othersFolderProvider(folderId));

    return Scaffold(
      appBar: AppBar(title: Text(folder?.title ?? l10n.othersTitle)),
      body: folder == null
          // Die Route bleibt im Verlauf stehen, während der Autor den Ordner
          // im Repository umbenennt oder löscht — dann ist er hier weg.
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ContentComingSoon(tokens: tokens),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (folder.entries.isEmpty)
                  ContentComingSoon(tokens: tokens)
                else
                  for (final entry in folder.entries)
                    _EntryTile(entry: entry, tokens: tokens),
              ],
            ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry, required this.tokens});

  final OthersEntry entry;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        title: Text(
          entry.title,
          style: AppTextStyles.title.copyWith(color: tokens.textPrimary),
        ),
        // Erst beim Aufklappen laden: Ein Ordner mit zwanzig Beiträgen würde
        // sonst zwanzig Abrufe auf einmal auslösen.
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _EntryBody(filePath: entry.filePath, tokens: tokens),
          ),
        ],
      ),
    );
  }
}

class _EntryBody extends ConsumerWidget {
  const _EntryBody({required this.filePath, required this.tokens});

  final String filePath;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(othersEntryProvider(filePath));

    return document.when(
      loading: () => ContentLoading(tokens: tokens),
      error: (_, _) => ContentLoadFailed(
        tokens: tokens,
        onRetry: () => ref.invalidate(othersEntryProvider(filePath)),
      ),
      // Steht im Manifest, liegt aber (noch) nicht im Repository.
      data: (markdown) => markdown == null
          ? ContentComingSoon(tokens: tokens)
          : MarkdownView(
              markdown: markdown,
              language: ref.watch(othersLanguageProvider),
              tokens: tokens,
            ),
    );
  }
}

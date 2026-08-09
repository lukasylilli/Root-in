import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/widgets/markdown_view.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'guide_document.dart';
import 'guide_topic.dart';

/// Eine Anleitungs-Seite der Rubrik „Root-in Anleitung" (siehe PLAN.md
/// Phase 17/17.1). **Eine** Seite für alle vier Themen: sie unterscheiden sich
/// in Titel, Symbol und Text, nicht im Aufbau — vier nahezu gleiche Dateien
/// wären vier Stellen, an denen ein Design-Wechsel nachgezogen werden müsste.
///
/// Der Text kommt als Markdown aus dem Inhalts-Repository (siehe
/// `core/services/repo_content_service.dart`), wird lokal gespeichert und
/// steht danach auch ohne Netz zur Verfügung. Persische Texte laufen von
/// rechts nach links, unabhängig von der Laufrichtung der übrigen App.
class GuidePage extends ConsumerWidget {
  const GuidePage({super.key, required this.topic});

  final GuideTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = ref.watch(appTokensProvider(Theme.of(context).brightness));
    final document = ref.watch(guideDocumentProvider(topic));

    return Scaffold(
      appBar: AppBar(title: Text(topic.label(l10n))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          _Header(topic: topic, tokens: tokens),
          const SizedBox(height: AppSpacing.lg),
          document.when(
            loading: () => ContentLoading(tokens: tokens),
            error: (_, _) => ContentLoadFailed(
              tokens: tokens,
              onRetry: () => ref.invalidate(guideDocumentProvider(topic)),
            ),
            data: (markdown) => markdown == null
                ? ContentComingSoon(tokens: tokens)
                : MarkdownView(
                    markdown: markdown,
                    language: ref.watch(guideLanguageProvider),
                    tokens: tokens,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Kopfbereich: Symbol, Rubrik, Titel, Einordnung. Der Verlauf nimmt die
/// Akzentfarbe des gewählten Themes auf, damit die Seite zur restlichen App
/// gehört, statt eine eigene Farbwelt aufzumachen.
class _Header extends StatelessWidget {
  const _Header({required this.topic, required this.tokens});

  final GuideTopic topic;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.accent.withValues(alpha: 0.20),
            tokens.accentSecondary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tokens.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(topic.icon, size: 26, color: scheme.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsGuide.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: tokens.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  topic.label(l10n),
                  style: AppTextStyles.headline.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  topic.subtitle(l10n),
                  style: AppTextStyles.body.copyWith(
                    color: tokens.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

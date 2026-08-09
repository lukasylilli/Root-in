import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';
import '../l10n/app_language.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_tokens.dart';

/// **Einzige** Markdown-Darstellung der App (siehe PLAN.md Abschnitt 9,
/// „Puzzling"/DRY). Zwei Rubriken zeigen Repository-Texte an — die „Root-in
/// Anleitung" (Phase 17) und „موارد دیگر" (Phase 22). Zwei Stylesheets
/// nebeneinander wären zwei Stellen, an denen ein Design-Wechsel nachgezogen
/// werden müsste, und sie liefen garantiert auseinander.
///
/// Die Laufrichtung hängt an der **Inhalts**-Sprache, nicht am Gerät: Ein
/// persischer Text bleibt rechtsläufig, auch wenn die App sonst von links
/// nach rechts läuft.
class MarkdownView extends StatelessWidget {
  const MarkdownView({
    super.key,
    required this.markdown,
    required this.language,
    required this.tokens,
  });

  final String markdown;

  /// Sprachcode des **Textes** (nicht der Oberfläche).
  final String language;

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final direction = textDirectionForLanguage(language);
    final body = AppTextStyles.body.copyWith(
      color: tokens.textPrimary,
      height: 1.6,
    );

    return Directionality(
      textDirection: direction,
      child: MarkdownBody(
        data: markdown,
        onTapLink: (text, href, title) {
          if (href == null) return;
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        },
        styleSheet: MarkdownStyleSheet(
          p: body,
          listBullet: body,
          h1: AppTextStyles.headline.copyWith(color: tokens.textPrimary),
          h2: AppTextStyles.title.copyWith(
            color: tokens.textPrimary,
            fontSize: 20,
          ),
          h3: AppTextStyles.title.copyWith(color: tokens.textPrimary),
          h1Padding: const EdgeInsets.only(top: AppSpacing.sm),
          h2Padding: const EdgeInsets.only(top: AppSpacing.md),
          h3Padding: const EdgeInsets.only(top: AppSpacing.sm),
          blockSpacing: AppSpacing.sm,
          a: body.copyWith(
            color: tokens.accent,
            decoration: TextDecoration.underline,
            decorationColor: tokens.accent,
          ),
          strong: body.copyWith(fontWeight: FontWeight.w700),
          blockquote: body.copyWith(color: tokens.textSecondary),
          blockquotePadding: const EdgeInsets.all(AppSpacing.sm),
          blockquoteDecoration: BoxDecoration(
            color: tokens.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          code: AppTextStyles.caption.copyWith(color: tokens.textPrimary),
          codeblockDecoration: BoxDecoration(
            color: tokens.ringTrack.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: tokens.ringTrack)),
          ),
          tableHead: body.copyWith(fontWeight: FontWeight.w700),
          tableBody: body.copyWith(height: 1.3),
          tableBorder: TableBorder.all(color: tokens.ringTrack, width: 1),
          tableCellsPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textAlign: direction == TextDirection.rtl
              ? WrapAlignment.end
              : WrapAlignment.start,
        ),
      ),
    );
  }
}

/// Während der erste Abruf läuft — nur, wenn noch nichts gespeichert ist.
class ContentLoading extends StatelessWidget {
  const ContentLoading({super.key, required this.tokens});

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.of(context).guideLoading,
            style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Kein Netz **und** nichts gespeichert.
class ContentLoadFailed extends StatelessWidget {
  const ContentLoadFailed({
    super.key,
    required this.tokens,
    required this.onRetry,
    this.title,
    this.body,
  });

  final AppThemeTokens tokens;
  final VoidCallback onRetry;

  /// Abweichende Texte — die Rubrik „موارد دیگر" nennt beim kaputten
  /// Manifest einen anderen Grund als „kein Internet".
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentPanel(
      tokens: tokens,
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 44, color: tokens.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            title ?? l10n.guideOfflineTitle,
            style: AppTextStyles.title.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body ?? l10n.guideOfflineBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: tokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.guideRetry),
          ),
        ],
      ),
    );
  }
}

/// Den Text gibt es in dieser Sprache noch nicht (Server meldet 404).
class ContentComingSoon extends StatelessWidget {
  const ContentComingSoon({super.key, required this.tokens});

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentPanel(
      tokens: tokens,
      child: Column(
        children: [
          Icon(Icons.edit_note_outlined, size: 44, color: tokens.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.guideComingSoonTitle,
            style: AppTextStyles.title.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.guideComingSoonBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: tokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gemeinsamer Rahmen der Hinweis-Zustände.
class ContentPanel extends StatelessWidget {
  const ContentPanel({
    super.key,
    required this.tokens,
    required this.child,
  });

  final AppThemeTokens tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tokens.ringTrack),
      ),
      child: child,
    );
  }
}

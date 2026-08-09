import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// import '../../../core/constants/ad_config.dart';
// import 'remove_ads_tile.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/contact_info.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_variant.dart';
import '../../../core/utils/platform_support.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../guide/presentation/guide_topic.dart';
import '../../home/presentation/ascent_source.dart';

/// Einstellungen-Seite. Aktuell: Darstellungsmodus (Hell/Dunkel/System),
/// Farb-Variante und Sprache (siehe PLAN.md Abschnitt 9
/// „Design-Token-Prinzip" — je Aspekt genau ein Schalter), Links zu Konto-,
/// Kategorien- und Erinnerungs-Seite, „App teilen" (Phase 5), „Kontakt uns"
/// (öffnet [contactUrl]), Sicherung exportieren/importieren (Phase 9) und die
/// Rubrik „Root-in Anleitung" (Phase 17) — deren vier Themen kommen aus
/// [GuideTopic], nicht aus einer hier gepflegten Liste.
///
/// Die Rubrik „Werbung" (Phase 14) ist mit Phase 20 auskommentiert.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final data = await ref.read(habitRepositoryProvider).createBackup();
      await ref.read(backupServiceProvider).exportToShareSheet(data, l10n);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupExportFailed('$error'))),
      );
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final data = await ref.read(backupServiceProvider).pickAndRead(l10n);
      if (data == null || !context.mounted) return;

      // Import ersetzt den gesamten Bestand — deshalb erst bestätigen lassen.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupRestoreTitle),
          content: Text(
            l10n.backupRestoreBody(data.habits.length, data.completions.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.backupRestoreConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      await ref.read(habitRepositoryProvider).restoreBackup(data);
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
    } on FormatException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupImportFailed('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeVariant = ref.watch(themeVariantProvider);
    final ascentSource = ref.watch(ascentSourceProvider);
    final language = ref.watch(appLanguageProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          _SectionLabel(l10n.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeSystem),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(selection.first),
            ),
          ),
          _SectionLabel(l10n.settingsColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final variant in AppThemeVariant.values)
                  ChoiceChip(
                    label: Text(variant.label(l10n)),
                    avatar: CircleAvatar(backgroundColor: variant.seedColor),
                    selected: variant == themeVariant,
                    onSelected: (_) => ref
                        .read(themeVariantProvider.notifier)
                        .setThemeVariant(variant),
                  ),
              ],
            ),
          ),
          _SectionLabel(l10n.settingsLanguage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final option in AppLanguage.values)
                  ChoiceChip(
                    label: Text(option.label(l10n)),
                    selected: option == language,
                    onSelected: (_) => ref
                        .read(appLanguageProvider.notifier)
                        .setLanguage(option),
                  ),
              ],
            ),
          ),
          _SectionLabel(l10n.settingsAscentSource),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final source in AscentSource.values)
                  ChoiceChip(
                    label: Text(source.label(l10n)),
                    selected: source == ascentSource,
                    onSelected: (_) => ref
                        .read(ascentSourceProvider.notifier)
                        .setSource(source),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(l10n.settingsAccountTitle),
            subtitle: Text(l10n.settingsAccountSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.account),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l10n.pageCategoriesTitle),
            subtitle: Text(l10n.settingsCategoriesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.categories),
          ),
          // PLAN.md Phase 26.1: Im Browser gibt es keine Erinnerungen. Beide
          // Einträge verschwinden dann ganz, statt ins Leere zu führen — ein
          // Schalter, der nichts bewirkt, ist schlimmer als kein Schalter.
          if (supportsReminders) ...[
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.pageRemindersTitle),
              subtitle: Text(l10n.settingsRemindersSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.reminders),
            ),
            // Phase 23: Der Tagesstand ist der einzige Hinweis, der dauerhaft
            // stehen bleibt — deshalb bekommt er einen eigenen Schalter direkt
            // neben den Erinnerungen.
            SwitchListTile(
              secondary: const Icon(Icons.push_pin_outlined),
              title: Text(l10n.settingsStatusNotification),
              subtitle: Text(l10n.settingsStatusNotificationSubtitle),
              value: ref.watch(statusNotificationProvider),
              onChanged: (next) =>
                  ref.read(statusNotificationProvider.notifier).set(next),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: Text(l10n.settingsShareApp),
            onTap: () => ref.read(shareServiceProvider).shareApp(l10n),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: Text(l10n.settingsExport),
            subtitle: Text(l10n.settingsExportSubtitle),
            onTap: () => _exportBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text(l10n.settingsImport),
            subtitle: Text(l10n.settingsImportSubtitle),
            onTap: () => _importBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(l10n.settingsContact),
            onTap: () => launchUrl(
              Uri.parse(contactUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          // PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
          // Ohne Werbung gibt es nichts zu entfernen — die Kauf-Rubrik würde
          // sonst Geld für eine Leistung verlangen, die ohnehin schon gilt.
          // if (!AdConfig.adsDisabledForEveryone) ...[
          //   const Divider(),
          //   _SectionLabel(l10n.settingsAds),
          //   const RemoveAdsTile(),
          // ],
          const Divider(),
          _SectionLabel(l10n.settingsGuide),
          for (final topic in GuideTopic.values)
            ListTile(
              leading: Icon(topic.icon),
              title: Text(topic.label(l10n)),
              subtitle: Text(topic.subtitle(l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(topic.route),
            ),
          // „موارد دیگر" (Phase 22) steht bewusst **hier**, direkt unter
          // „Wichtige Links" — so hat der Nutzer es verlangt. Anders als die
          // vier Themen darüber kommt der Inhalt nicht aus einem Enum,
          // sondern aus dem `index.json` im Repository.
          ListTile(
            leading: const Icon(Icons.inbox_outlined),
            title: Text(l10n.othersTitle),
            subtitle: Text(l10n.othersSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.others),
          ),
          const _VersionFooter(),
        ],
      ),
    );
  }
}

/// Version am Fuß der Einstellungen (PLAN.md Phase 26.6).
///
/// Bewusst **ohne** ARB-Schlüssel: Dort steht nur der App-Name und eine Zahl
/// — nichts, was sich übersetzen ließe. Der Grund für die Anzeige ist die
/// Web-Fassung: Sie aktualisiert sich beim nächsten Laden von selbst, ohne
/// dass der Nutzer etwas merkt. Ohne sichtbare Version wäre „bei mir sieht es
/// anders aus" nicht zu beantworten.
class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          'Root-in ${AppConfig.fullVersion}',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Überschrift einer Einstellungs-Gruppe — an sechs Stellen gebraucht, daher
/// einmal hier statt sechsmal dasselbe `Padding` (siehe PLAN.md Abschnitt 9,
/// „Puzzling"/DRY).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(text),
    );
  }
}

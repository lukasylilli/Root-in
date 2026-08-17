import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/cloud_backup_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'auth_sheet.dart';

/// Die Rubrik „Konto & Cloud" — sie sitzt auf der **bestehenden Konto-Seite**
/// (Einstellungen → Konto), nicht in einer eigenen Rubrik daneben.
///
/// So gewollt: Ein Konto ist genau das, worum es auf dieser Seite ohnehin
/// geht. Ein zweiter Ort für dasselbe Thema wäre die Doppelung, die PLAN.md
/// Abschnitt 9 verbietet — und der Nutzer müsste sich merken, welcher der
/// beiden Orte was kann.
///
/// ⚠️ **Ohne Server ist diese Karte gar nicht da** (`supportsCloudSync`).
/// Kein Knopf, der ins Leere greift — dieselbe Regel, nach der im Browser
/// die Erinnerungen verschwinden statt wirkungslos dazustehen (Phase 26.1).
class AccountCloudCard extends ConsumerWidget {
  const AccountCloudCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(cloudSyncEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final account = ref.watch(authAccountProvider).value;

    return SectionCard(
      title: l10n.cloudSectionTitle,
      child: account == null
          ? _SignedOut(l10n: l10n)
          : _SignedIn(account: account, l10n: l10n),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cloudSignedOutBody,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.cloudSignIn,
          onPressed: () => showAuthSheet(context),
        ),
      ],
    );
  }
}

class _SignedIn extends ConsumerStatefulWidget {
  const _SignedIn({required this.account, required this.l10n});

  final AuthAccount account;
  final AppLocalizations l10n;

  @override
  ConsumerState<_SignedIn> createState() => _SignedInState();
}

class _SignedInState extends ConsumerState<_SignedIn> {
  bool _busy = false;

  AppLocalizations get l10n => widget.l10n;

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _textFor(CloudSyncStatus status) => switch (status) {
    CloudSyncStatus.ok => l10n.cloudBackupDone,
    CloudSyncStatus.nothingStored => l10n.cloudNothingStored,
    CloudSyncStatus.tooNew => l10n.cloudTooNew,
    // „Nicht verfügbar" darf hier nicht vorkommen — die Karte ist dann
    // unsichtbar. Käme es doch, ist es kein Fehler des Nutzers.
    CloudSyncStatus.notAvailable || CloudSyncStatus.failed =>
      l10n.cloudSyncFailed,
  };

  Future<void> _backupNow() async {
    setState(() => _busy = true);
    final status = await ref.read(cloudBackupServiceProvider).upload();
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(_lastBackupProvider);
    _say(_textFor(status));
  }

  Future<void> _restore() async {
    // ⚠️ Erst fragen, dann holen: Das Einspielen ERSETZT den lokalen Bestand
    // vollständig. Ein Knopf, der das ohne Rückfrage täte, wäre der
    // schnellste Weg, jemandem seine Daten zu nehmen.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cloudRestoreTitle),
        content: Text(l10n.cloudRestoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.cloudRestoreConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final service = ref.read(cloudBackupServiceProvider);
    final snapshot = await service.fetch();
    if (!mounted) return;

    if (snapshot.status != CloudSyncStatus.ok || snapshot.data == null) {
      setState(() => _busy = false);
      _say(_textFor(snapshot.status));
      return;
    }

    final status = await service.restore(snapshot.data!);
    if (!mounted) return;
    setState(() => _busy = false);
    _say(
      status == CloudSyncStatus.ok
          ? l10n.cloudRestoreDone
          : l10n.cloudSyncFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Der Benutzername liegt in `profiles`, nicht in der Sitzung — er wird
    // getrennt geladen. Solange er fehlt, steht das ausdrücklich da, statt
    // die Zeile leer zu lassen: Ein Konto OHNE Namen ist ein möglicher
    // Zustand (PLAN.md 27.5), kein Anzeigefehler.
    final username = ref.watch(_usernameProvider).value;
    final lastBackup = ref.watch(_lastBackupProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          username == null || username.isEmpty
              ? l10n.cloudNoUsernameYet
              : l10n.cloudSignedInAs(username),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(widget.account.email, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.cloudEmailHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        // Eine Sicherung, deren Alter man nicht sieht, ist eine Vermutung.
        Text(
          lastBackup == null
              ? l10n.cloudNeverBackedUp
              : l10n.cloudLastBackup(_formatStamp(lastBackup)),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.cloudBackupNow,
          onPressed: _busy ? null : _backupNow,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: _busy ? null : _restore,
          child: Text(l10n.cloudRestore),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy
              ? null
              : () => ref.read(authServiceProvider).signOut(),
          child: Text(l10n.cloudSignOut),
        ),
      ],
    );
  }
}

/// Datum und Uhrzeit, bewusst schlicht und ohne `intl`-Format: Die App
/// schreibt Ziffern in allen Sprachen westlich (siehe `app_numbers.dart`),
/// und ein Zeitstempel soll überall gleich aussehen.
String _formatStamp(DateTime utc) {
  final t = utc.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.day)}.${two(t.month)}.${t.year} ${two(t.hour)}:${two(t.minute)}';
}

/// Lädt den Benutzernamen zum angemeldeten Konto.
///
/// Hängt bewusst an [authAccountProvider]: Nach einem Kontowechsel darf
/// nicht der Name des vorigen Kontos stehen bleiben.
final _usernameProvider = FutureProvider<String?>((ref) async {
  final account = ref.watch(authAccountProvider).value;
  if (account == null) return null;
  return ref.read(authServiceProvider).loadUsername();
});

/// Zeitpunkt der letzten Sicherung — **vom Server**, nicht von der Geräteuhr.
///
/// Fragt bewusst nur den Zeitstempel ab, nicht die Sicherung selbst: Sonst
/// lüde jeder Aufbau dieser Seite den gesamten Bestand herunter, um eine
/// Zeile Text anzuzeigen.
final _lastBackupProvider = FutureProvider<DateTime?>((ref) async {
  final account = ref.watch(authAccountProvider).value;
  if (account == null) return null;
  return ref.read(cloudBackupServiceProvider).lastBackupAt();
});

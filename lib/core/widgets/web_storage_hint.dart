import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../services/settings_service.dart';
import '../theme/app_spacing.dart';
import '../utils/platform_support.dart';

/// Einmaliger Hinweis der **Web-Fassung**: warum Root-in auf den
/// Home-Bildschirm gehört und warum eine Sicherung hier wichtiger ist als
/// auf Android (PLAN.md Phase 26.8).
///
/// Der Grund für die Deutlichkeit: Auf Android liegen die Daten in einem
/// App-Verzeichnis, das nur der Nutzer selbst löscht. Im Browser liegen sie
/// im Speicher der Website — und **Safari löscht den Speicher einer Seite,
/// die sieben Tage nicht geöffnet wurde.** Für eine als Verknüpfung auf dem
/// Home-Bildschirm abgelegte Web-App gilt diese Regel nicht. Das Ablegen ist
/// im Browser damit keine Frage der Bequemlichkeit, sondern die Bedingung
/// dafür, dass der Verlauf erhalten bleibt.
///
/// Bewusst ein **Dialog** und kein wegwischbarer Streifen: Wer ihn übersieht,
/// verliert im ungünstigsten Fall seinen ganzen Bestand.
///
/// Aufgerufen von der Home-Seite, nicht vom Onboarding — die Begründung
/// steht bei `SettingsService.loadWebStorageHintSeen`.
Future<void> maybeShowWebStorageHint(
  BuildContext context,
  WidgetRef ref,
) async {
  // Auf Android/iOS gibt es weder die Sieben-Tage-Regel noch einen
  // Home-Bildschirm-Umweg — dort ist der Hinweis schlicht falsch.
  if (!usesBrowserStorage) return;

  final settings = ref.read(settingsServiceProvider);
  if (settings.loadWebStorageHintSeen()) return;

  // Erst merken, dann zeigen. Andersherum sähe ein Nutzer, der den Dialog
  // wegdreht statt ihn zu bestätigen, den Hinweis bei jedem Start erneut.
  await settings.saveWebStorageHintSeen();

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        icon: const Icon(Icons.add_to_home_screen_outlined),
        title: Text(l10n.webStorageHintTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.webStorageHintBody),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.webStorageHintSteps,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.webStorageHintBackup),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.webStorageHintUnderstood),
          ),
        ],
      );
    },
  );
}

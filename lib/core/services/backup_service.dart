import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/backup_data.dart';
import '../../l10n/gen/app_localizations.dart';
import 'file_pick/pick_text_file.dart';

/// Einzige Stelle, die eine Sicherung als **Datei** schreibt bzw. liest
/// (siehe PLAN.md Phase 9). Die Serialisierung selbst liegt in
/// `data/models/backup_data.dart` und ist dadurch ohne Plattform-Zugriff
/// testbar.
///
/// Seit Phase 26.1 kommt diese Datei **ohne `dart:io` und ohne
/// `path_provider` aus** und läuft damit auch im Browser: Der Export übergibt
/// die Bytes direkt, das Einlesen liegt hinter `pick_text_file.dart`.
class BackupService {
  const BackupService();

  /// Übergibt [data] als JSON an das System-Share-Sheet, damit der Nutzer sie
  /// ablegen kann (Dateien, Cloud-Speicher, Mail …).
  ///
  /// Die Bytes gehen **ohne Umweg über eine eigene temporäre Datei** hinaus.
  /// `share_plus` legt auf Android/iOS selbst eine an; im Browser gibt es
  /// keine, und `downloadFallbackEnabled` macht daraus einen ganz normalen
  /// Download, wenn der Browser die Web-Share-Schnittstelle nicht anbietet
  /// (auf dem iPhone in Safari tut er es).
  Future<void> exportToShareSheet(
    BackupData data,
    AppLocalizations l10n,
  ) async {
    final stamp = data.exportedAt.toIso8601String().split('T').first;
    final name = 'root-in-sicherung-$stamp.json';
    final bytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'application/json')],
        // `XFile.fromData` trägt seinen Namen nur im Web; auf den anderen
        // Plattformen kommt er ausschließlich hierüber an. Ohne das hieße die
        // Sicherung auf dem Gerät nach einer zufälligen Kennung.
        fileNameOverrides: [name],
        text: l10n.backupShareText(stamp),
        downloadFallbackEnabled: true,
      ),
    );
  }

  /// Lässt den Nutzer eine Sicherungsdatei auswählen und liest sie ein.
  /// Gibt `null` zurück, wenn die Auswahl abgebrochen wurde.
  ///
  /// Wirft [FormatException] bei beschädigten oder zu neuen Dateien — die
  /// aufrufende Seite zeigt die Meldung an.
  Future<BackupData?> pickAndRead(AppLocalizations l10n) async {
    final content = await pickTextFileContent();
    if (content == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw FormatException(l10n.backupInvalidJson);
    }
    if (decoded is! Map) {
      throw FormatException(l10n.backupInvalidFormat);
    }

    try {
      return BackupData.fromJson(Map<String, dynamic>.from(decoded));
    } on BackupFormatException catch (error) {
      // `BackupData` meldet nur *warum* die Datei unlesbar ist und bleibt
      // dadurch sprachneutral — der anzeigbare Satz entsteht hier.
      throw FormatException(_messageFor(error, l10n));
    }
  }

  String _messageFor(BackupFormatException error, AppLocalizations l10n) {
    return switch (error.problem) {
      BackupFormatProblem.notABackup => l10n.backupInvalidFormat,
      BackupFormatProblem.corrupted => l10n.backupCorrupted,
      BackupFormatProblem.tooNew => l10n.backupTooNew(
        error.fileVersion ?? 0,
        BackupData.currentVersion,
      ),
    };
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => const BackupService(),
);

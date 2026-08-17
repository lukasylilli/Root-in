/// Cloud-Sicherung des Bestands (PLAN.md Phase 27.7).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/backup_data.dart';
import '../../data/repositories/habit_repository.dart';
import 'auth_service.dart';

/// Legt den Bestand als **Kopie** auf dem Server ab (PLAN.md Phase 27.7).
///
/// ⚠️ **Sicherung, kein Abgleich.** Hochladen geschieht von selbst,
/// **Herunterladen nur auf Nachfrage** und mit Ansage — es überschreibt den
/// lokalen Bestand vollständig. Zwei Geräte ohne Zusammenführungs-Logik
/// löschen sich sonst gegenseitig Daten, und „Datenerhalt geht vor" ist die
/// älteste Regel dieses Projekts (PLAN.md Abschnitt 9).
///
/// **Das Format ist das vorhandene Backup-JSON** aus `backup_data.dart` —
/// dieselbe Serialisierung wie Export/Import in eine Datei, dieselben Tests,
/// dieselbe Versions-Prüfung. Ein zweites Format wäre genau die Doppelung,
/// die Abschnitt 9 verbietet: Jede spätere Änderung am Datenmodell müsste an
/// zwei Stellen nachgezogen werden, und die zweite würde vergessen.
///
/// ⚠️ **Scheitern ist folgenlos.** Kein Netz, Projekt pausiert, Adresse im
/// Land gesperrt — die App arbeitet lokal weiter und versucht es später.
/// Deshalb geben alle Methoden hier ein Ergebnis zurück, statt zu werfen.

/// Wie eine Cloud-Sicherung ausgegangen ist.
enum CloudSyncStatus {
  /// Geschafft.
  ok,

  /// Kein Server konfiguriert oder niemand angemeldet — kein Fehler,
  /// sondern der Normalfall ohne Konto.
  notAvailable,

  /// Es gibt (noch) keine Sicherung auf dem Server.
  nothingStored,

  /// Server nicht erreichbar oder abgewiesen.
  failed,

  /// Die Sicherung auf dem Server stammt aus einer **neueren** App-Fassung.
  /// ⚠️ Wird bewusst nicht eingespielt: Ein älterer Leser würde Felder
  /// verlieren, die er nicht kennt — und das fiele erst viel später auf.
  tooNew,
}

/// Ergebnis eines Abrufs vom Server.
class CloudBackupSnapshot {
  const CloudBackupSnapshot({
    required this.status,
    this.data,
    this.updatedAt,
  });

  final CloudSyncStatus status;
  final BackupData? data;

  /// Zeitpunkt **vom Server**, nicht vom Gerät (siehe Trigger in
  /// `supabase/schema.sql`). Eine Geräteuhr kann falsch gestellt sein.
  final DateTime? updatedAt;
}

class CloudBackupService {
  const CloudBackupService(this._ref);

  final Ref _ref;

  static const String _table = 'backups';

  SupabaseClient? get _client {
    final account = _ref.read(authServiceProvider).currentAccount;
    if (account == null) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Schreibt den aktuellen Bestand auf den Server.
  ///
  /// Genau **eine** Zeile je Konto (`user_id` ist dort der Primärschlüssel),
  /// deshalb `upsert`: Ein zweiter Aufruf ersetzt den Stand, statt eine
  /// weitere Kopie anzulegen.
  Future<CloudSyncStatus> upload() async {
    final client = _client;
    final account = _ref.read(authServiceProvider).currentAccount;
    if (client == null || account == null) return CloudSyncStatus.notAvailable;

    try {
      final data = await _ref.read(habitRepositoryProvider).createBackup();
      await client.from(_table).upsert({
        'user_id': account.id,
        'payload': data.toJson(),
        'schema_version': BackupData.currentVersion,
        // `updated_at` wird bewusst NICHT mitgeschickt — das setzt der
        // Server (Trigger in schema.sql).
      });
      return CloudSyncStatus.ok;
    } catch (_) {
      return CloudSyncStatus.failed;
    }
  }

  /// Nur der Zeitpunkt der letzten Sicherung — **ohne** den Bestand zu laden.
  ///
  /// Eigene Abfrage, weil die Anzeige „zuletzt gesichert vor …" sonst bei
  /// jedem Aufbau der Seite die vollständige Sicherung herunterlüde. Bei
  /// einem gewachsenen Bestand sind das je Aufruf einige hundert Kilobyte,
  /// für eine einzige Zeile Text.
  Future<DateTime?> lastBackupAt() async {
    final client = _client;
    final account = _ref.read(authServiceProvider).currentAccount;
    if (client == null || account == null) return null;
    try {
      final row = await client
          .from(_table)
          .select('updated_at')
          .eq('user_id', account.id)
          .maybeSingle();
      if (row == null) return null;
      return DateTime.tryParse('${row['updated_at']}');
    } catch (_) {
      return null;
    }
  }

  /// Holt die Sicherung vom Server, **ohne** sie einzuspielen.
  ///
  /// Getrennt von [restore], damit die Oberfläche vorher sagen kann, **was**
  /// überschrieben würde. Ein Wiederherstellen ohne diese Ansage wäre der
  /// schnellste Weg, jemandem seinen Bestand zu nehmen.
  Future<CloudBackupSnapshot> fetch() async {
    final client = _client;
    final account = _ref.read(authServiceProvider).currentAccount;
    if (client == null || account == null) {
      return const CloudBackupSnapshot(status: CloudSyncStatus.notAvailable);
    }

    try {
      final row = await client
          .from(_table)
          .select('payload, schema_version, updated_at')
          .eq('user_id', account.id)
          .maybeSingle();

      if (row == null) {
        return const CloudBackupSnapshot(status: CloudSyncStatus.nothingStored);
      }

      final version = row['schema_version'];
      if (version is int && version > BackupData.currentVersion) {
        return const CloudBackupSnapshot(status: CloudSyncStatus.tooNew);
      }

      final payload = row['payload'];
      if (payload is! Map) {
        return const CloudBackupSnapshot(status: CloudSyncStatus.failed);
      }

      final updatedAt = DateTime.tryParse('${row['updated_at']}');
      return CloudBackupSnapshot(
        status: CloudSyncStatus.ok,
        data: BackupData.fromJson(Map<String, dynamic>.from(payload)),
        updatedAt: updatedAt,
      );
    } on BackupFormatException {
      // Der abgelegte Stand ist unlesbar. Nicht einspielen — lieber gar
      // nichts als ein halber Bestand.
      return const CloudBackupSnapshot(status: CloudSyncStatus.failed);
    } catch (_) {
      return const CloudBackupSnapshot(status: CloudSyncStatus.failed);
    }
  }

  /// Spielt eine zuvor mit [fetch] geholte Sicherung ein.
  ///
  /// ⚠️ **Überschreibt den lokalen Bestand vollständig** — dieselbe
  /// Wirkung wie „Sicherung importieren". Der Aufrufer hat den Nutzer vorher
  /// gefragt.
  Future<CloudSyncStatus> restore(BackupData data) async {
    try {
      await _ref.read(habitRepositoryProvider).restoreBackup(data);
      return CloudSyncStatus.ok;
    } catch (_) {
      return CloudSyncStatus.failed;
    }
  }
}

final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (ref) => CloudBackupService(ref),
);

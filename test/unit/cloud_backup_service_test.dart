import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';
import 'package:root_in/core/services/cloud_backup_service.dart';

import '../support/fake_auth_service.dart';

/// PLAN.md Phase 27.7 — die Cloud-Sicherung **ohne Server**.
///
/// Das ist der Normalzustand in Tests, in lokalen Bauten und überall dort,
/// wo niemand angemeldet ist. Geprüft wird deshalb genau das Wichtigste:
/// **Es wird nichts geworfen, nichts gesendet und nichts stillschweigend
/// als Erfolg gemeldet.**
///
/// ⚠️ Kein Test spricht mit dem echten Server. Was dort passiert, ist mit
/// `tool/rls_check.sh` gegen das laufende Projekt geprüft — von außen, mit
/// echten Konten. Beide Prüfungen zusammen decken den Weg ab; einzeln
/// deckt keine ihn ganz.
void main() {
  ProviderContainer container(FakeAuthService auth) => ProviderContainer(
    overrides: [authServiceProvider.overrideWithValue(auth)],
  );

  test('ohne Anmeldung meldet jeder Aufruf notAvailable', () async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);
    final c = container(auth);
    addTearDown(c.dispose);

    final service = c.read(cloudBackupServiceProvider);

    expect(await service.upload(), CloudSyncStatus.notAvailable);
    expect(await service.deleteServerData(), CloudSyncStatus.notAvailable);
    expect((await service.fetch()).status, CloudSyncStatus.notAvailable);
    expect(await service.lastBackupAt(), isNull);
  });

  test('notAvailable ist KEIN Fehler — der Unterschied zählt', () async {
    // Die Oberfläche unterscheidet beides: „kein Konto" ist der Normalfall
    // und darf keine Fehlermeldung erzeugen, „failed" schon. Würden beide
    // denselben Wert liefern, bekäme jeder Nutzer ohne Konto beim Start
    // eine Fehlermeldung zu sehen.
    expect(CloudSyncStatus.notAvailable, isNot(CloudSyncStatus.failed));
  });

  test('alle Status-Werte sind unterscheidbar', () {
    // Sie steuern verschiedene Sätze in der Oberfläche; ein doppelter Wert
    // würde zwei Lagen zusammenwerfen, die verschiedene Auswege haben.
    expect(CloudSyncStatus.values.toSet().length, CloudSyncStatus.values.length);
    expect(CloudSyncStatus.values, contains(CloudSyncStatus.tooNew));
    expect(CloudSyncStatus.values, contains(CloudSyncStatus.nothingStored));
  });

  test('CloudBackupSnapshot ohne Daten trägt trotzdem einen Status', () {
    // Der Aufrufer prüft immer zuerst den Status; `data` darf null sein,
    // ohne dass etwas rät.
    const snapshot = CloudBackupSnapshot(status: CloudSyncStatus.nothingStored);
    expect(snapshot.data, isNull);
    expect(snapshot.updatedAt, isNull);
    expect(snapshot.status, CloudSyncStatus.nothingStored);
  });
}

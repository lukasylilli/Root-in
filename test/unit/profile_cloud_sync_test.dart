import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';
import 'package:root_in/core/services/profile_cloud_sync.dart';
import 'package:root_in/core/services/profile_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_auth_service.dart';

/// PLAN.md Phase 27.6 — die Regel für den Zusammenstoß beim Anmelden.
///
/// **Warum das einen Test braucht:** Die Regel ist im Kopf der Datei als
/// Tabelle aufgeschrieben, aber nichts hält sie fest. Wer sie beim nächsten
/// Umbau umdreht, bekommt keinen Fehler — nur einen Nutzer, dem beim
/// Anmelden ein alter Name über den gerade eingegebenen gelegt wird. Das
/// sieht aus wie ein verlorener Eintrag und ist kaum zu melden („manchmal
/// heißt es anders").
Future<ProviderContainer> _container(FakeAuthService auth,
    {String localName = ''}) async {
  SharedPreferences.setMockInitialValues(
    localName.isEmpty ? {} : {'profile_name': localName},
  );
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authServiceProvider.overrideWithValue(auth),
    ],
  );
}

void main() {
  const account = AuthAccount(id: 'u1', email: 'a@b.de', username: 'ali');

  test('lokal leer, Server gesetzt → der Server gewinnt', () async {
    // Der Fall „neues Gerät": Der Name soll zurückkommen.
    final auth = FakeAuthService(signedIn: account)
      ..remoteDisplayName = 'Ali vom Server';
    addTearDown(auth.dispose);
    final c = await _container(auth);
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();

    expect(c.read(profileProvider).name, 'Ali vom Server');
  });

  test('lokal gesetzt, Server leer → lokal wandert hoch', () async {
    final auth = FakeAuthService(signedIn: account);
    addTearDown(auth.dispose);
    final c = await _container(auth, localName: 'Ali lokal');
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();

    expect(auth.remoteDisplayName, 'Ali lokal');
    expect(c.read(profileProvider).name, 'Ali lokal');
  });

  test('beide gesetzt und verschieden → das GERÄT gewinnt', () async {
    // Der eigentliche Punkt. Der Nutzer sitzt vor diesem Gerät; ein älterer
    // Name vom Server über dem gerade eingegebenen sähe aus wie Datenverlust.
    final auth = FakeAuthService(signedIn: account)
      ..remoteDisplayName = 'Alter Name';
    addTearDown(auth.dispose);
    final c = await _container(auth, localName: 'Neuer Name');
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();

    expect(c.read(profileProvider).name, 'Neuer Name');
    expect(auth.remoteDisplayName, 'Neuer Name');
  });

  test('beide gleich → es wird nichts geschrieben', () async {
    // Sonst löste jedes Anmelden einen überflüssigen Schreibvorgang aus.
    final auth = FakeAuthService(signedIn: account)
      ..remoteDisplayName = 'Ali';
    addTearDown(auth.dispose);
    final c = await _container(auth, localName: 'Ali');
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();

    expect(auth.calls.where((c) => c.startsWith('saveDisplayName')), isEmpty);
  });

  test('beide leer → nichts zu tun', () async {
    final auth = FakeAuthService(signedIn: account);
    addTearDown(auth.dispose);
    final c = await _container(auth);
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();

    expect(c.read(profileProvider).name, isEmpty);
    expect(auth.calls.where((c) => c.startsWith('saveDisplayName')), isEmpty);
  });

  test('ohne Anmeldung passiert gar nichts', () async {
    // Der Normalfall ohne Konto — er darf weder schreiben noch werfen.
    final auth = FakeAuthService();
    addTearDown(auth.dispose);
    final c = await _container(auth, localName: 'Ali lokal');
    addTearDown(c.dispose);

    await c.read(profileCloudSyncProvider).reconcile();
    await c.read(profileCloudSyncProvider).pushLocalName();

    expect(auth.calls, isEmpty);
    expect(c.read(profileProvider).name, 'Ali lokal');
  });

  test('pushLocalName schiebt eine lokale Änderung hoch', () async {
    final auth = FakeAuthService(signedIn: account);
    addTearDown(auth.dispose);
    final c = await _container(auth);
    addTearDown(c.dispose);

    await c.read(profileProvider.notifier).setName('Geändert');
    await c.read(profileCloudSyncProvider).pushLocalName();

    expect(auth.remoteDisplayName, 'Geändert');
  });
}

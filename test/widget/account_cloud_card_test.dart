import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';
import 'package:root_in/core/services/cloud_backup_service.dart';
import 'package:root_in/features/auth/presentation/account_cloud_card.dart';

import '../support/fake_auth_service.dart';
import '../support/localized_app.dart';

/// PLAN.md Phase 27.5 — die Rubrik „Konto & Cloud" auf der Konto-Seite.
///
/// Geprüft wird vor allem das, was **ohne Server** gelten muss: Die Rubrik
/// ist unsichtbar, wenn keine Cloud eingerichtet ist. Wäre sie es nicht,
/// bekäme jeder bestehende Nutzer einen Anmelde-Knopf, der nirgendwohin
/// führt — genau der „Knopf, der nichts tut", den Phase 26.1 verbietet.
void main() {
  Widget wrap(FakeAuthService auth, {required bool cloudEnabled}) {
    return ProviderScope(
      overrides: [
        cloudSyncEnabledProvider.overrideWithValue(cloudEnabled),
        authServiceProvider.overrideWithValue(auth),
      ],
      child: localizedApp(
        const Scaffold(body: SingleChildScrollView(child: AccountCloudCard())),
      ),
    );
  }

  testWidgets('ohne Cloud ist die Rubrik gar nicht da', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: false));
    await tester.pump();

    expect(find.text('Konto & Cloud'), findsNothing);
    expect(find.text('Anmelden'), findsNothing);
  });

  testWidgets('abgemeldet: erklärt und bietet Anmelden an', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: true));
    await tester.pump();

    expect(find.text('Konto & Cloud'), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
    // Die Freiwilligkeit muss dastehen — sie ist die tragende Zusage der
    // Phase, nicht eine Fußnote (PLAN.md 27.0b).
    expect(find.textContaining('freiwillig'), findsOneWidget);
  });

  testWidgets('angemeldet: zeigt Benutzername, E-Mail und Abmelden', (
    tester,
  ) async {
    final auth = FakeAuthService(
      signedIn: const AuthAccount(
        id: 'u1',
        email: 'ali@example.com',
        username: 'ali',
      ),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: true));
    await tester.pump();
    await tester.pump();

    expect(find.text('Angemeldet als ali'), findsOneWidget);
    expect(find.text('ali@example.com'), findsOneWidget);
    expect(find.text('Abmelden'), findsOneWidget);
    expect(find.text('Benutzernamen festlegen'), findsNothing);
  });

  testWidgets('angemeldet ohne Benutzername sagt das ausdrücklich', (
    tester,
  ) async {
    // Der Zustand nach einer Registrierung, bei der der Name vergeben war:
    // Konto ja, Profilzeile noch nicht (PLAN.md 27.5). Die Karte darf daran
    // nicht scheitern und keine leere Zeile zeigen.
    final auth = FakeAuthService(
      signedIn: const AuthAccount(id: 'u1', email: 'ali@example.com'),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: true));
    await tester.pump();
    await tester.pump();

    expect(find.text('Noch kein Benutzername'), findsOneWidget);
    expect(find.text('Benutzernamen festlegen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ohne Benutzername lässt er sich nachtragen (PLAN.md 31.1)', (
    tester,
  ) async {
    // Vorher stand hier „Noch kein Benutzername" — ohne jeden Weg, das zu
    // ändern.
    final auth = FakeAuthService(
      signedIn: const AuthAccount(id: 'u1', email: 'ali@example.com'),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: true));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Benutzernamen festlegen'));
    await tester.pumpAndSettle();
    // Nur der Name — das Konto besteht ja schon.
    expect(find.widgetWithText(TextField, 'Passwort'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Benutzername'),
      'ali',
    );
    await tester.tap(find.text('Benutzernamen speichern'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(auth.calls, contains('claimUsername:ali'));
    // ⚠️ Die Karte muss den neuen Namen zeigen, ohne dass sich das Konto
    // geändert hätte — dafür invalidiert das Sheet accountUsernameProvider.
    expect(find.text('Angemeldet als ali'), findsOneWidget);
    expect(find.text('Benutzernamen festlegen'), findsNothing);
  });

  testWidgets('Abmelden ruft den Dienst', (tester) async {
    final auth = FakeAuthService(
      signedIn: const AuthAccount(
        id: 'u1',
        email: 'ali@example.com',
        username: 'ali',
      ),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(wrap(auth, cloudEnabled: true));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Abmelden'));
    await tester.pump();

    expect(auth.calls, contains('signOut'));
  });

  testWidgets('auf Persisch steht die Rubrik auf Persisch', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudSyncEnabledProvider.overrideWithValue(true),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: localizedApp(
          const Scaffold(
            body: SingleChildScrollView(child: AccountCloudCard()),
          ),
          locale: const Locale('fa'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('حساب و ابر'), findsOneWidget);
    expect(find.text('ورود'), findsOneWidget);
  });

  group('Konto löschen (PLAN.md 31.3)', () {
    const ali = AuthAccount(
      id: 'u1',
      email: 'ali@example.com',
      username: 'ali',
    );
    const doneText =
        'Dein Konto ist gelöscht. Die Daten auf diesem Gerät sind unberührt.';

    Future<void> openDialog(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Konto löschen'));
      await tester.tap(find.text('Konto löschen'));
      await tester.pumpAndSettle();
    }

    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(find.text('Endgültig löschen'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('fragt nach; Abbrechen löscht nichts, Bestätigen löscht und '
        'meldet ab', (tester) async {
      final auth = FakeAuthService(signedIn: ali);
      addTearDown(auth.dispose);
      await tester.pumpWidget(wrap(auth, cloudEnabled: true));
      await tester.pump();
      await tester.pump();

      await openDialog(tester);
      // Die Rückfrage muss sagen, was BLEIBT — sonst fürchtet jeder um den
      // Bestand auf seinem Gerät.
      expect(
        find.textContaining('Die Daten auf diesem Gerät bleiben unberührt'),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(auth.calls, isNot(contains('deleteAccount')));

      await openDialog(tester);
      await confirm(tester);

      expect(auth.calls, containsAllInOrder(['deleteAccount', 'signOut']));
      expect(find.text('Anmelden'), findsOneWidget);
      expect(find.text(doneText), findsOneWidget);
    });

    testWidgets('Funktion fehlt auf dem Server: löscht die Daten, meldet ab '
        'und sagt, was fehlt', (tester) async {
      final auth = FakeAuthService(
        signedIn: ali,
        deletionResult: AccountDeletion.unavailable,
      );
      addTearDown(auth.dispose);
      late _FakeCloudBackupService backup;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudSyncEnabledProvider.overrideWithValue(true),
            authServiceProvider.overrideWithValue(auth),
            cloudBackupServiceProvider.overrideWith(
              (ref) => backup = _FakeCloudBackupService(ref),
            ),
          ],
          child: localizedApp(
            const Scaffold(
              body: SingleChildScrollView(child: AccountCloudCard()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await openDialog(tester);
      await confirm(tester);

      expect(backup.deleted, isTrue);
      // ⚠️ Ohne Abmelden lüde die automatische Sicherung beim nächsten
      // Häkchen alles wieder hoch.
      expect(auth.calls, containsAllInOrder(['deleteAccount', 'signOut']));
      // Ehrlich: nicht „gelöscht" behaupten, wenn der Anmelde-Eintrag bleibt.
      expect(find.text(doneText), findsNothing);
      expect(find.textContaining('schreib uns'), findsOneWidget);
    });

    testWidgets('Server nicht erreichbar: nichts gelöscht, bleibt angemeldet', (
      tester,
    ) async {
      final auth = FakeAuthService(
        signedIn: ali,
        deletionResult: AccountDeletion.failed,
      );
      addTearDown(auth.dispose);
      await tester.pumpWidget(wrap(auth, cloudEnabled: true));
      await tester.pump();
      await tester.pump();

      await openDialog(tester);
      await confirm(tester);

      expect(auth.calls, isNot(contains('signOut')));
      expect(find.text('Angemeldet als ali'), findsOneWidget);
      expect(find.textContaining('nicht erreichbar'), findsOneWidget);
    });
  });
}

/// Server-Daten löschen ohne Server — für den Rückfall-Weg aus PLAN.md 31.3.
class _FakeCloudBackupService extends CloudBackupService {
  _FakeCloudBackupService(super.ref);

  bool deleted = false;

  @override
  Future<CloudSyncStatus> deleteServerData() async {
    deleted = true;
    return CloudSyncStatus.ok;
  }

  @override
  Future<DateTime?> lastBackupAt() async => null;
}

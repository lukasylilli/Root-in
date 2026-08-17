import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';
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
        const Scaffold(
          body: SingleChildScrollView(child: AccountCloudCard()),
        ),
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
    expect(tester.takeException(), isNull);
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
}

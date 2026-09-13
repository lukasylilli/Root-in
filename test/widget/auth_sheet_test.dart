import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';
import 'package:root_in/core/widgets/app_button.dart';
import 'package:root_in/features/auth/presentation/auth_sheet.dart';

import '../support/fake_auth_service.dart';
import '../support/localized_app.dart';

/// PLAN.md 31.1 — der Benutzername bei der Registrierung.
///
/// ⚠️ Der Zustand, um den es geht, war vorher eine **Sackgasse**: Konto
/// angelegt, Name vergeben, das Formular zeigte „Name vergeben" — und ein
/// zweiter Versuch scheiterte an „E-Mail schon registriert", weil das Konto
/// ja schon stand. Der Dienst konnte den Namen nachtragen, die Oberfläche
/// hat es nie angeboten.
void main() {
  Future<void> openSheet(
    WidgetTester tester,
    FakeAuthService auth, {
    bool usernameOnly = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(auth)],
        child: localizedApp(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () =>
                      showAuthSheet(context, usernameOnly: usernameOnly),
                  child: const Text('öffnen'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('öffnen'));
    await tester.pumpAndSettle();
  }

  Future<void> fillRegistration(WidgetTester tester, String username) async {
    await tester.tap(find.text('Konto anlegen'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'E-Mail'),
      'ali@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Passwort'),
      'geheim123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Benutzername'),
      username,
    );
  }

  // Nach dem Absenden: Die Dienst-Aufrufe sind Microtasks, das Schließen des
  // Sheets eine Animation. ⚠️ Kein pumpAndSettle — ein fokussiertes Textfeld
  // blinkt, und das Sheet bleibt im Fehlerfall offen.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testWidgets('vergebener Name: es wird GAR KEIN Konto angelegt', (
    tester,
  ) async {
    final auth = FakeAuthService(takenUsernames: {'ali'});
    addTearDown(auth.dispose);
    await openSheet(tester, auth);

    await fillRegistration(tester, 'Ali');
    await tester.tap(find.byType(AppButton));
    await settle(tester);

    // Normalisiert gefragt — „Ali" und „ali" sind derselbe Name (27.5).
    expect(auth.calls, contains('isUsernameAvailable:ali'));
    expect(auth.calls.where((c) => c.startsWith('signUp')), isEmpty);
    expect(auth.currentAccount, isNull);
    expect(
      find.text('Dieser Benutzername ist schon vergeben.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Name erst nach dem Anlegen vergeben: das Sheet fragt nur noch nach dem Namen',
    (tester) async {
      // Der Wettlauf: Die Vorab-Frage sagt „frei", beim Schreiben war jemand
      // schneller.
      final auth = FakeAuthService(
        takenUsernames: {'ali'},
        availabilityCheckSeesTaken: false,
      );
      addTearDown(auth.dispose);
      await openSheet(tester, auth);

      await fillRegistration(tester, 'ali');
      await tester.tap(find.byType(AppButton));
      await settle(tester);

      expect(auth.currentAccount, isNotNull, reason: 'das Konto steht bereits');
      expect(
        find.text('Dieser Benutzername ist schon vergeben.'),
        findsOneWidget,
      );
      expect(find.textContaining('fehlt nur noch'), findsOneWidget);
      // Genau das war die Sackgasse: ein zweites Registrieren mit derselben
      // E-Mail. Die Felder dafür sind jetzt weg.
      expect(find.widgetWithText(TextField, 'E-Mail'), findsNothing);
      expect(find.widgetWithText(TextField, 'Passwort'), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextField, 'Benutzername'),
        'ali2',
      );
      await tester.tap(find.byType(AppButton));
      await settle(tester);

      expect(auth.calls.where((c) => c.startsWith('signUp')), hasLength(1));
      expect(auth.calls.last, 'claimUsername:ali2');
      expect(auth.currentAccount!.username, 'ali2');
      expect(
        find.text('Benutzernamen speichern'),
        findsNothing,
        reason: 'nach dem Speichern schließt das Sheet',
      );
    },
  );

  testWidgets('nur Name: die Regeln gelten, bevor etwas gesendet wird', (
    tester,
  ) async {
    final auth = FakeAuthService(
      signedIn: const AuthAccount(id: 'u1', email: 'ali@example.com'),
    );
    addTearDown(auth.dispose);
    await openSheet(tester, auth, usernameOnly: true);

    expect(find.byType(SegmentedButton<bool>), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Benutzername'), 'a');
    await tester.tap(find.byType(AppButton));
    await settle(tester);

    expect(find.text('Mindestens 3 Zeichen.'), findsOneWidget);
    expect(auth.calls, isEmpty);
  });
}

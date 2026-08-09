import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/notification_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:root_in/app.dart';

import 'support/dispose_and_flush.dart';
import 'support/fake_notification_service.dart';
import 'support/test_database.dart';
import 'support/test_time_service.dart';

void main() {
  /// Startet die App mit der in den Einstellungen gespeicherten Sprache.
  ///
  /// Die Sprache wird bewusst explizit gesetzt: ohne Eintrag folgt die App
  /// der Systemsprache, und die ist im Test-Binding en-US. [onboardingSeen]
  /// ist standardmäßig `true` — sonst landete jeder Test auf der
  /// Erststart-Erklärung statt auf Home (siehe PLAN.md Phase 11.6).
  Future<SharedPreferences> pumpApp(
    WidgetTester tester, {
    required String language,
    bool onboardingSeen = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'app_language': language,
      'onboarding_seen': onboardingSeen,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(createTestDatabase()),
          timeServiceProvider.overrideWithValue(
            TestTimeService(DateTime(2026, 7, 20)),
          ),
          // Seit Phase 23 schickt `app.dart` bei jedem Fortschritts-Wechsel
          // den Tagesstand an die Benachrichtigungsleiste — der echte Dienst
          // greift dafür auf einen Plattform-Kanal zu, den es im Test nicht
          // gibt.
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
        ],
        child: const RootInApp(),
      ),
    );
    // pump() statt pumpAndSettle(): die Berg-Animation auf der Home-Seite
    // lässt Sterne dauerhaft funkeln, der Baum kommt also nie zur Ruhe.
    await tester.pump(const Duration(seconds: 1));
    return prefs;
  }

  /// Lässt einen Wechsel auf die Home-Seite fertig laufen.
  ///
  /// `pumpAndSettle()` geht hier nicht: die Berg-Animation funkelt dauerhaft.
  /// Nacheinander verarbeitet werden müssen der Tipp, das asynchrone
  /// Speichern des Merkers und der Routen-Übergang.
  Future<void> settleNavigation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('App startet und zeigt die Home-Seite mit Bottom-Navigation', (
    tester,
  ) async {
    await pumpApp(tester, language: 'german');

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Heute'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('gespeicherte Sprache Englisch schlägt bis in die Navigation '
      'durch', (tester) async {
    await pumpApp(tester, language: 'english');

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Heute'), findsNothing);
    expect(find.text('Einstellungen'), findsNothing);

    await disposeAndFlush(tester);
  });

  testWidgets('Erststart zeigt die Erklärung statt Home', (tester) async {
    await pumpApp(tester, language: 'german', onboardingSeen: false);

    expect(find.text('Willkommen bei Root-in'), findsOneWidget);
    // Keine Bottom-Navigation: die Erklärung liegt außerhalb der Shell.
    expect(find.text('Einstellungen'), findsNothing);

    await disposeAndFlush(tester);
  });

  testWidgets('Überspringen führt zu Home und merkt sich das', (tester) async {
    final prefs = await pumpApp(
      tester,
      language: 'german',
      onboardingSeen: false,
    );

    await tester.tap(find.text('Überspringen'));
    await settleNavigation(tester);

    expect(find.text('Willkommen bei Root-in'), findsNothing);
    expect(find.text('Einstellungen'), findsOneWidget);
    // Beim nächsten Start darf die Erklärung nicht wiederkommen.
    expect(prefs.getBool('onboarding_seen'), isTrue);

    await disposeAndFlush(tester);
  });

  testWidgets('„Weiter" blättert bis zum Start-Knopf durch', (tester) async {
    await pumpApp(tester, language: 'german', onboardingSeen: false);

    // Vier Seiten: dreimal „Weiter", dann steht „Los geht's" da.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Erinnerungen und Widgets'), findsOneWidget);
    expect(find.text('Weiter'), findsNothing);

    await tester.tap(find.text('Los geht\'s'));
    await settleNavigation(tester);

    expect(find.text('Einstellungen'), findsOneWidget);

    await disposeAndFlush(tester);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/features/account/presentation/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

void main() {
  // Lokale Funktion statt Top-Level, damit der Analyzer den Rückgabetyp
  // (List<Override> — der Typ ist über flutter_riverpod nicht exportiert
  // und daher hier nicht explizit benennbar) ohne Extra-Annotation ableiten
  // kann.
  testOverrides(SharedPreferences prefs) => [
    sharedPreferencesProvider.overrideWithValue(prefs),
    appDatabaseProvider.overrideWithValue(createTestDatabase()),
    timeServiceProvider.overrideWithValue(
      TestTimeService(DateTime(2026, 7, 20)),
    ),
  ];

  testWidgets(
    'Konto-Seite zeigt Profil, Statistik und Achievements-Grid',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(prefs),
          child: localizedApp(const AccountPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Gesamt-Statistik'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Achievements'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Achievements'), findsOneWidget);

      await disposeAndFlush(tester);
    },
  );

  testWidgets('Profilname wird über profileProvider persistiert', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(prefs),
        child: localizedApp(const AccountPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Alex');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(prefs.getString('profile_name'), 'Alex');

    await disposeAndFlush(tester);
  });

  testWidgets('„Fortschritt teilen" öffnet die Fortschritts-Karte', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(prefs),
        child: localizedApp(const AccountPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Fortschritt teilen'),
      200,
      // .first, weil MatrixGrid/AchievementsGrid intern eigene Scrollables
      // verschachteln — das äußere ListView-Scrollable wird als erstes im
      // Baum getroffen.
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Fortschritt teilen'));
    await tester.pumpAndSettle();

    expect(find.text('Root-in'), findsOneWidget);
    expect(find.textContaining('Achievements'), findsWidgets);

    await disposeAndFlush(tester);
  });
}

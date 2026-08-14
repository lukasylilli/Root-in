import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/utils/platform_support.dart';
import 'package:root_in/core/widgets/web_storage_hint.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/localized_app.dart';

/// Der Hinweis aus PLAN.md Phase 26.8.
///
/// ⚠️ Diese Tests laufen auf der **Dart-VM**, also nie im Browser:
/// `usesBrowserStorage` ist hier immer `false`. Prüfbar ist damit genau das,
/// was auch das Wichtigste ist — dass der Hinweis auf Android/iOS **nicht**
/// erscheint. Dort wäre er schlicht falsch: Die Sieben-Tage-Regel von Safari
/// gibt es nicht, und einen Home-Bildschirm-Umweg braucht niemand.
/// Das Verhalten im Browser bleibt dem Gerätedurchgang vorbehalten.
Future<void> _pump(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: localizedApp(
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  maybeShowWebStorageHint(context, ref);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('die Plattform-Weiche heißt nach dem, was sie bedeutet', () {
    // Auf der Dart-VM ist der Speicher kein Browser-Speicher. Der Test hält
    // fest, dass die Abfrage existiert und hier `false` liefert — sonst
    // erschiene der Hinweis auf dem Gerät.
    expect(usesBrowserStorage, isFalse);
  });

  testWidgets('auf Android/iOS erscheint kein Hinweis', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await _pump(tester, prefs);

    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('der Merker wird auf Android/iOS nicht verbraucht', (
    tester,
  ) async {
    // Wichtig: Würde die Funktion den Merker setzen, bevor sie die Plattform
    // prüft, hätte ein Nutzer, der die App erst auf Android startet, seinen
    // Hinweis in der Web-Fassung stillschweigend verloren — die Sicherung
    // wandert per Import zwischen beiden Fassungen.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await _pump(tester, prefs);

    expect(SettingsService(prefs).loadWebStorageHintSeen(), isFalse);
  });

  test('ein gesetzter Merker bleibt erhalten', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    expect(settings.loadWebStorageHintSeen(), isFalse);
    await settings.saveWebStorageHintSeen();
    expect(settings.loadWebStorageHintSeen(), isTrue);
  });
}

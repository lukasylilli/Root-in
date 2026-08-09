import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/core/widgets/share_card.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/features/account/presentation/share_progress_sheet.dart';
import 'package:root_in/features/home/presentation/home_page.dart';
import 'package:root_in/features/view/overview/overview_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// Phase 19: Das Teilen ist von der **Home**-Seite aus erreichbar, und der
/// Weg dorthin ist dasselbe Sheet wie auf der Konto-Seite — nicht eine
/// zweite Vorschau (PLAN.md Abschnitt 9, „Puzzling"/DRY).
void main() {
  testOverrides(SharedPreferences prefs) => [
    sharedPreferencesProvider.overrideWithValue(prefs),
    appDatabaseProvider.overrideWithValue(createTestDatabase()),
    timeServiceProvider.overrideWithValue(
      TestTimeService(DateTime(2026, 7, 20)),
    ),
  ];

  Future<void> pumpHome(WidgetTester tester, SharedPreferences prefs) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(prefs),
        child: localizedApp(const HomePage()),
      ),
    );
    // Kein pumpAndSettle auf der Home-Seite — die funkelnden Sterne der
    // Berg-Animation laufen dauerhaft (PLAN.md Lehre 10).
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Home-Knopf öffnet dasselbe Teilen-Sheet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(tester, prefs);

    expect(find.text('Fortschritt teilen'), findsOneWidget);
    expect(find.byType(ShareProgressSheet), findsNothing);

    await tester.tap(find.text('Fortschritt teilen'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Genau das Sheet der Konto-Seite, keine zweite Vorschau.
    expect(find.byType(ShareProgressSheet), findsOneWidget);
    expect(find.byType(ShareCard), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('leerer Bestand bricht die Karte nicht', (tester) async {
    // Der häufigste Absturz-Kandidat (PLAN.md Phase 21.3): keine einzige
    // Gewohnheit. Der Übersicht-Block hat dann nichts zu zeichnen und muss
    // wegfallen, statt ein leeres Raster auf die Karte zu setzen.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(tester, prefs);
    await tester.tap(find.text('Fortschritt teilen'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ShareCard), findsOneWidget);
    expect(find.byType(OverviewBoard), findsNothing);
    // Der Store-Weg steht auch auf der leeren Karte.
    expect(find.byType(QrImageView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await disposeAndFlush(tester);
  });
}

// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Prüft remove_ads_tile.dart, das mit auskommentiert ist.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Alle Fälle dieser Datei sind mit Phase 20 auskommentiert (siehe unten).
  // Dieser eine Platzhalter bleibt aktiv, weil `flutter test` eine Datei ohne
  // `main()` als Ladefehler meldet — und die Datei soll erhalten bleiben,
  // nicht gelöscht werden. Der Übersprungen-Vermerk hält den Grund im
  // Testlauf sichtbar.
  test(
    'Kauf-Kachel — ruht mit Phase 20',
    () {},
    skip: 'PHASE 20 (2026-08-01): Werbung deaktiviert — Fälle einkommentieren, '
        'sobald Werbung und Kauf wieder aktiv sind.',
  );
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:root_in/core/services/purchase_service.dart';
// import 'package:root_in/core/services/settings_service.dart';
// import 'package:root_in/features/settings/presentation/remove_ads_tile.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../support/fake_purchase_service.dart';
// import '../support/localized_app.dart';
//
// /// Kauf-Kachel in den Einstellungen (siehe PLAN.md Phase 14).
// void main() {
//   Future<SharedPreferences> pumpTile(
//     WidgetTester tester, {
//     bool alreadyPurchased = false,
//   }) async {
//     SharedPreferences.setMockInitialValues(
//       alreadyPurchased ? {'remove_ads_purchased': true} : {},
//     );
//     final prefs = await SharedPreferences.getInstance();
//
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           sharedPreferencesProvider.overrideWithValue(prefs),
//           purchaseServiceProvider.overrideWithValue(
//             offlinePurchaseService(prefs),
//           ),
//         ],
//         child: localizedApp(const Scaffold(body: RemoveAdsTile())),
//       ),
//     );
//     await tester.pump();
//     return prefs;
//   }
//
//   testWidgets('ohne Kauf: Kauf- und Wiederherstellen-Eintrag', (tester) async {
//     await pumpTile(tester);
//
//     expect(find.text('Werbung entfernen'), findsOneWidget);
//     expect(find.text('Käufe wiederherstellen'), findsOneWidget);
//     // Ohne erreichbaren Store gibt es keinen Preis — die Kachel bleibt
//     // sichtbar, aber ohne Tipp-Ziel.
//     expect(
//       find.text('Gerade nicht verfügbar — Google Play ist nicht erreichbar.'),
//       findsOneWidget,
//     );
//   });
//
//   testWidgets('nach dem Kauf: Bestätigung statt Kauf-Eintrag', (tester) async {
//     await pumpTile(tester, alreadyPurchased: true);
//
//     expect(find.text('Werbung ist entfernt'), findsOneWidget);
//     expect(find.text('Werbung entfernen'), findsNothing);
//     expect(find.text('Käufe wiederherstellen'), findsNothing);
//   });
// }

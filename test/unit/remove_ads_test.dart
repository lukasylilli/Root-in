// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Prüft purchase_service.dart, das mit auskommentiert ist.
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
    'Kauf „Werbung entfernen“ — ruht mit Phase 20',
    () {},
    skip: 'PHASE 20 (2026-08-01): Werbung deaktiviert — Fälle einkommentieren, '
        'sobald Werbung und Kauf wieder aktiv sind.',
  );
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:root_in/core/constants/ad_config.dart';
// import 'package:root_in/core/services/purchase_service.dart';
// import 'package:root_in/core/services/settings_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../support/fake_purchase_service.dart';
//
// /// Kauf-Zustand „Werbung entfernen" (siehe PLAN.md Phase 14). Geprüft wird
// /// die Dart-Seite: Play liefert Ereignisse, der Notifier macht daraus einen
// /// gemerkten Kaufstatus, und [adsRemovedProvider] macht daraus zusammen mit
// /// [AdConfig.adsDisabledForEveryone] den einen Schalter für die Werbung.
// ///
// /// Die Kauf-Fälle prüfen deshalb `removeAdsProvider.purchased` — der wirkt
// /// unabhängig vom Not-Schalter und bleibt aussagekräftig, wenn dieser wieder
// /// ausgeht.
// void main() {
//   late SharedPreferences prefs;
//   late FakePurchaseService store;
//   late ProviderContainer container;
//
//   Future<void> setUpContainer({bool alreadyPurchased = false}) async {
//     SharedPreferences.setMockInitialValues(
//       alreadyPurchased ? {'remove_ads_purchased': true} : {},
//     );
//     prefs = await SharedPreferences.getInstance();
//     store = FakePurchaseService(prefs);
//     container = ProviderContainer(
//       overrides: [
//         sharedPreferencesProvider.overrideWithValue(prefs),
//         purchaseServiceProvider.overrideWithValue(store),
//       ],
//     );
//     addTearDown(container.dispose);
//     addTearDown(store.dispose);
//   }
//
//   test('ohne Kauf bleibt der Kaufstatus aus und Play wird gefragt', () async {
//     await setUpContainer();
//
//     expect(container.read(removeAdsProvider).purchased, isFalse);
//     // Quelle der Wahrheit ist Play, nicht der lokale Zwischenspeicher.
//     expect(store.restoreCalls, 1);
//   });
//
//   test('gemerkter Kauf gilt schon vor der Play-Antwort', () async {
//     await setUpContainer(alreadyPurchased: true);
//
//     expect(container.read(removeAdsProvider).purchased, isTrue);
//     expect(container.read(adsRemovedProvider), isTrue);
//   });
//
//   test(
//     'Not-Schalter blendet Werbung auch ohne Kauf aus',
//     () async {
//       await setUpContainer();
//
//       expect(container.read(removeAdsProvider).purchased, isFalse);
//       expect(container.read(adsRemovedProvider), isTrue);
//     },
//     skip: !AdConfig.adsDisabledForEveryone,
//   );
//
//   test('abgeschlossener Kauf blendet Werbung aus und wird gemerkt', () async {
//     await setUpContainer();
//     // Ohne Listener würde der Provider den Stream gar nicht erst abonnieren.
//     container.listen(removeAdsProvider, (_, _) {});
//
//     store.emit(PurchaseStatus.purchased);
//     await pumpEventQueue();
//
//     expect(container.read(removeAdsProvider).purchased, isTrue);
//     expect(prefs.getBool('remove_ads_purchased'), isTrue);
//     // Ohne `completePurchase` nimmt Play den Kauf nach drei Tagen zurück.
//     expect(store.completed, hasLength(1));
//   });
//
//   test('wiederhergestellter Kauf zählt genauso', () async {
//     await setUpContainer();
//     container.listen(removeAdsProvider, (_, _) {});
//
//     store.emit(PurchaseStatus.restored);
//     await pumpEventQueue();
//
//     expect(container.read(removeAdsProvider).purchased, isTrue);
//   });
//
//   test('fremdes Produkt lässt den Zustand unberührt', () async {
//     await setUpContainer();
//     container.listen(removeAdsProvider, (_, _) {});
//
//     store.emit(PurchaseStatus.purchased, productId: 'irgendwas_anderes');
//     await pumpEventQueue();
//
//     expect(container.read(removeAdsProvider).purchased, isFalse);
//     expect(store.completed, isEmpty);
//   });
//
//   test('Fehler meldet sich, ohne den Kauf freizuschalten', () async {
//     await setUpContainer();
//     container.listen(removeAdsProvider, (_, _) {});
//
//     store.emit(
//       PurchaseStatus.error,
//       error: IAPError(
//         source: 'google_play',
//         code: 'purchase_error',
//         message: 'Zahlung abgelehnt',
//       ),
//     );
//     await pumpEventQueue();
//
//     expect(container.read(removeAdsProvider).purchased, isFalse);
//     expect(container.read(removeAdsProvider).error, 'Zahlung abgelehnt');
//
//     container.read(removeAdsProvider.notifier).clearError();
//     expect(container.read(removeAdsProvider).error, isNull);
//   });
//
//   test('Abbruch beendet nur den Ladezustand', () async {
//     await setUpContainer();
//     container.listen(removeAdsProvider, (_, _) {});
//
//     store.emit(PurchaseStatus.pending);
//     await pumpEventQueue();
//     expect(container.read(removeAdsProvider).inProgress, isTrue);
//
//     store.emit(PurchaseStatus.canceled);
//     await pumpEventQueue();
//
//     final state = container.read(removeAdsProvider);
//     expect(state.inProgress, isFalse);
//     expect(state.purchased, isFalse);
//     expect(state.error, isNull);
//   });
// }

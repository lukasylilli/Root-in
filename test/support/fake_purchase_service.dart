// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Ersatz für purchase_service.dart, das mit auskommentiert ist.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'dart:async';
//
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:root_in/core/services/purchase_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// /// Kauf-Dienst **ohne** Play-Anbindung — der Normalfall für Widget-Tests:
// /// `purchaseServiceProvider.overrideWithValue(offlinePurchaseService(prefs))`.
// ///
// /// Ohne diesen Override würde der Provider im Test (dort gilt
// /// `defaultTargetPlatform == android`) die echte Play-Billing-Anbindung
// /// aufbauen und über einen nicht vorhandenen Platform-Channel laufen.
// PurchaseService offlinePurchaseService(SharedPreferences prefs) =>
//     PurchaseService(null, prefs);
//
// /// Steuerbarer Ersatz für Tests, die den Kauf-Ablauf selbst auslösen.
// class FakePurchaseService extends PurchaseService {
//   FakePurchaseService(SharedPreferences prefs) : super(null, prefs);
//
//   final _updates = StreamController<List<PurchaseDetails>>.broadcast();
//
//   /// Käufe, für die [completePurchase] gerufen wurde.
//   final completed = <PurchaseDetails>[];
//
//   var restoreCalls = 0;
//
//   @override
//   Stream<List<PurchaseDetails>> get purchaseUpdates => _updates.stream;
//
//   @override
//   Future<bool> isStoreAvailable() async => true;
//
//   @override
//   Future<void> restorePurchases() async => restoreCalls++;
//
//   @override
//   Future<void> completePurchase(PurchaseDetails purchase) async {
//     completed.add(purchase);
//   }
//
//   /// Schiebt ein Play-Ereignis in den Stream.
//   void emit(PurchaseStatus status, {String? productId, IAPError? error}) {
//     final purchase = PurchaseDetails(
//       productID: productId ?? PurchaseService.removeAdsProductId,
//       verificationData: PurchaseVerificationData(
//         localVerificationData: '',
//         serverVerificationData: '',
//         source: 'google_play',
//       ),
//       transactionDate: null,
//       status: status,
//     );
//     purchase.error = error;
//     purchase.pendingCompletePurchase = true;
//     _updates.add([purchase]);
//   }
//
//   Future<void> dispose() => _updates.close();
// }

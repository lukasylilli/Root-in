// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Ohne Werbung hat der Kauf „Werbung entfernen" keinen Gegenstand. Die
// gespeicherten Kaufmerker in shared_preferences bleiben unangetastet — ein
// früherer Käufer ist beim Wiedereinschalten sofort wieder werbefrei.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../constants/ad_config.dart';
// import '../utils/platform_support.dart';
// import 'settings_service.dart';
//
// /// Einzige Stelle, die mit Google Play Billing spricht (siehe PLAN.md
// /// Phase 14). Das Paket `in_app_purchase` kapselt die Play Billing Library —
// /// ein eigener `BillingClient` wird nirgends aufgebaut.
// ///
// /// Die Store-Anbindung ist bewusst nullbar: auf Desktop/Web gibt es keine
// /// Plattform-Implementierung (siehe [isStorePlatform]), und Widget-Tests
// /// setzen `null`, um ohne Play-Anbindung zu laufen. Ohne Store verhält sich
// /// der Dienst wie ein Store, der nichts kennt — der gemerkte Kaufstatus
// /// bleibt trotzdem lesbar.
// class PurchaseService {
//   const PurchaseService(this._store, this._prefs);
//
//   final InAppPurchase? _store;
//   final SharedPreferences _prefs;
//
//   /// Produkt-ID des Nicht-Verbrauchsartikels aus der Play Console
//   /// (Schritt „Google Play Console" in PLAN.md Phase 14). Muss dort **exakt**
//   /// so heißen.
//   static const removeAdsProductId = 'remove_ads';
//
//   static const _removeAdsPurchasedKey = 'remove_ads_purchased';
//
//   /// Zuletzt bekannter Kaufstatus — nur ein Zwischenspeicher, damit die App
//   /// beim Start sofort (und offline) weiß, ob das Banner wegbleibt. Die
//   /// Wahrheit liefert Play über [restorePurchases]; siehe
//   /// [RemoveAdsNotifier].
//   bool loadRemoveAdsPurchased() =>
//       _prefs.getBool(_removeAdsPurchasedKey) ?? false;
//
//   Future<void> saveRemoveAdsPurchased(bool purchased) =>
//       _prefs.setBool(_removeAdsPurchasedKey, purchased);
//
//   /// Kauf-Ereignisse von Play: abgeschlossene, wiederhergestellte, wartende
//   /// und fehlgeschlagene Käufe. Auch ein Kauf, der außerhalb der App
//   /// abgeschlossen wurde (z. B. Zahlung per Überweisung), kommt hier an.
//   Stream<List<PurchaseDetails>> get purchaseUpdates =>
//       _store?.purchaseStream ?? const Stream.empty();
//
//   /// Ob Play erreichbar ist (Store-App vorhanden, Nutzer angemeldet).
//   ///
//   /// Fängt Plattform-Fehler ab: auf Geräten ohne Play-Dienste soll die App
//   /// die Kauf-Option nur ausblenden, nicht abstürzen.
//   Future<bool> isStoreAvailable() async {
//     final store = _store;
//     if (store == null) return false;
//     try {
//       return await store.isAvailable();
//     } catch (error) {
//       debugPrint('Google Play nicht erreichbar: $error');
//       return false;
//     }
//   }
//
//   /// Holt Titel, Beschreibung und **lokalisierten Preis** des Produkts.
//   /// `null`, wenn Play nicht erreichbar ist oder die Produkt-ID (noch) nicht
//   /// veröffentlicht wurde.
//   Future<ProductDetails?> loadRemoveAdsProduct() async {
//     final store = _store;
//     if (store == null || !await store.isAvailable()) return null;
//
//     final response = await store.queryProductDetails({removeAdsProductId});
//     if (response.error != null || response.productDetails.isEmpty) return null;
//     return response.productDetails.first;
//   }
//
//   /// Startet den Kauf-Dialog. Ergebnis kommt **nicht** hier zurück, sondern
//   /// über [purchaseUpdates] — auch wenn der Nutzer abbricht.
//   Future<void> buyRemoveAds(ProductDetails product) async {
//     await _store?.buyNonConsumable(
//       purchaseParam: PurchaseParam(productDetails: product),
//     );
//   }
//
//   /// Fragt frühere Käufe erneut ab (neues Gerät, Neuinstallation). Die
//   /// Treffer kommen über [purchaseUpdates] mit Status `restored`.
//   Future<void> restorePurchases() async {
//     if (!await isStoreAvailable()) return;
//     await _store?.restorePurchases();
//   }
//
//   /// Bestätigt Play, dass die Ware ausgeliefert ist. Ohne diesen Schritt
//   /// macht Play den Kauf nach drei Tagen rückgängig.
//   Future<void> completePurchase(PurchaseDetails purchase) async {
//     if (!purchase.pendingCompletePurchase) return;
//     await _store?.completePurchase(purchase);
//   }
// }
//
// final purchaseServiceProvider = Provider<PurchaseService>((ref) {
//   return PurchaseService(
//     isStorePlatform ? InAppPurchase.instance : null,
//     ref.watch(sharedPreferencesProvider),
//   );
// });
//
// /// Zustand des „Werbung entfernen"-Kaufs für die Oberfläche.
// class RemoveAdsState {
//   const RemoveAdsState({
//     required this.purchased,
//     this.inProgress = false,
//     this.error,
//   });
//
//   /// Ob der Kauf vorliegt — der eine Schalter für die Werbe-Sichtbarkeit.
//   final bool purchased;
//
//   /// Kauf läuft (Play-Dialog offen oder Zahlung noch ausstehend).
//   final bool inProgress;
//
//   /// Meldung des letzten fehlgeschlagenen Kaufs, unübersetzt von Play.
//   final String? error;
//
//   RemoveAdsState copyWith({
//     bool? purchased,
//     bool? inProgress,
//     String? error,
//     bool clearError = false,
//   }) {
//     return RemoveAdsState(
//       purchased: purchased ?? this.purchased,
//       inProgress: inProgress ?? this.inProgress,
//       error: clearError ? null : (error ?? this.error),
//     );
//   }
// }
//
// class RemoveAdsNotifier extends Notifier<RemoveAdsState> {
//   @override
//   RemoveAdsState build() {
//     final service = ref.watch(purchaseServiceProvider);
//
//     final subscription = service.purchaseUpdates.listen(
//       _handlePurchases,
//       // Ein Stream-Fehler darf die App nicht abreißen lassen; ohne
//       // `onError` würde er als unbehandelter Fehler hochblubbern.
//       onError: (Object error) =>
//           state = state.copyWith(inProgress: false, error: '$error'),
//     );
//     ref.onDispose(subscription.cancel);
//
//     // Beim Start einmal bei Play nachfragen (Neuinstallation, Gerätewechsel).
//     // Antworten laufen über den Stream oben.
//     unawaited(service.restorePurchases());
//
//     return RemoveAdsState(purchased: service.loadRemoveAdsPurchased());
//   }
//
//   Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
//     final service = ref.read(purchaseServiceProvider);
//
//     for (final purchase in purchases) {
//       if (purchase.productID != PurchaseService.removeAdsProductId) continue;
//
//       switch (purchase.status) {
//         case PurchaseStatus.pending:
//           state = state.copyWith(inProgress: true, clearError: true);
//           // Noch nichts zu bestätigen — Play meldet sich erneut.
//           continue;
//         case PurchaseStatus.purchased:
//         case PurchaseStatus.restored:
//           state = const RemoveAdsState(purchased: true);
//           await service.saveRemoveAdsPurchased(true);
//         case PurchaseStatus.canceled:
//           state = state.copyWith(inProgress: false, clearError: true);
//         case PurchaseStatus.error:
//           state = state.copyWith(
//             inProgress: false,
//             error: purchase.error?.message ?? purchase.error?.code,
//           );
//       }
//
//       await service.completePurchase(purchase);
//     }
//   }
//
//   /// Startet den Kauf. Der Erfolg landet über den Stream in [state] — hier
//   /// wird nur der Weg dorthin geöffnet.
//   Future<void> buy(ProductDetails product) async {
//     state = state.copyWith(inProgress: true, clearError: true);
//     try {
//       await ref.read(purchaseServiceProvider).buyRemoveAds(product);
//     } catch (error) {
//       state = state.copyWith(inProgress: false, error: '$error');
//     }
//   }
//
//   /// „Käufe wiederherstellen" aus den Einstellungen.
//   Future<void> restore() async {
//     state = state.copyWith(inProgress: true, clearError: true);
//     await ref.read(purchaseServiceProvider).restorePurchases();
//     // Kommt nichts zurück (nie gekauft), bliebe der Ladezustand sonst hängen.
//     state = state.copyWith(inProgress: false);
//   }
//
//   /// Verwirft die Fehlermeldung, nachdem die Oberfläche sie gezeigt hat.
//   void clearError() => state = state.copyWith(clearError: true);
// }
//
// final removeAdsProvider = NotifierProvider<RemoveAdsNotifier, RemoveAdsState>(
//   RemoveAdsNotifier.new,
// );
//
// /// **Der eine Schalter für Werbe-Sichtbarkeit** (siehe PLAN.md Abschnitt 9,
// /// Design-Token-Prinzip): jede Stelle, die Werbung zeigt oder verbirgt, liest
// /// ausschließlich diesen Provider.
// ///
// /// Werbung bleibt weg, wenn der Kauf vorliegt **oder** der vorübergehende
// /// Not-Schalter [AdConfig.adsDisabledForEveryone] gesetzt ist.
// final adsRemovedProvider = Provider<bool>(
//   (ref) =>
//       AdConfig.adsDisabledForEveryone ||
//       ref.watch(removeAdsProvider.select((state) => state.purchased)),
// );
//
// /// Produktdaten (v. a. der lokalisierte Preis) für die Einstellungen-Kachel.
// final removeAdsProductProvider = FutureProvider<ProductDetails?>(
//   (ref) => ref.watch(purchaseServiceProvider).loadRemoveAdsProduct(),
// );

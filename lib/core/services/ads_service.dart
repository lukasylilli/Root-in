// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Kein Start des Werbe-SDKs mehr; das Paket google_mobile_ads ist in
// pubspec.yaml auskommentiert.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import '../constants/ad_config.dart';
// import '../utils/platform_support.dart';
//
// /// Einzige Stelle, die mit dem Google-Mobile-Ads-SDK spricht (siehe PLAN.md
// /// Phase 14). Widgets bauen nie selbst einen [BannerAd] — sie rufen
// /// [loadAnchoredBanner] und kümmern sich nur noch um Lebenszyklus und
// /// Darstellung (`core/widgets/banner_ad_slot.dart`).
// class AdsService {
//   AdsService();
//
//   /// Das SDK darf nur **einmal** initialisiert werden; der Future wird
//   /// gemerkt, damit jeder weitere Aufruf auf denselben Vorgang wartet.
//   Future<void>? _initialization;
//
//   /// Startet das SDK (idempotent). Wird beim App-Start angestoßen
//   /// (`main.dart`) und vor jedem Banner-Abruf erneut abgewartet — so muss der
//   /// Start nicht darauf warten, ein Banner aber sehr wohl.
//   Future<void> initialize() => _initialization ??= _initialize();
//
//   Future<void> _initialize() async {
//     if (!isStorePlatform) return;
//     // Werbung ist Beiwerk: ist das SDK nicht da (Widget-Test, Gerät ohne
//     // Play-Dienste), darf das die App nicht mitreißen.
//     try {
//       if (AdConfig.testDeviceIds.isNotEmpty) {
//         await MobileAds.instance.updateRequestConfiguration(
//           RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
//         );
//       }
//       await MobileAds.instance.initialize();
//     } catch (error) {
//       debugPrint('AdMob-SDK nicht gestartet: $error');
//     }
//   }
//
//   /// Lädt ein „anchored adaptive" Banner in voller Breite [width] (in
//   /// logischen Pixeln). Diese Größe passt sich Gerät und Ausrichtung an und
//   /// ist von Google gegenüber dem starren 320×50-Banner empfohlen.
//   ///
//   /// [onLoaded] kommt nur bei Erfolg; schlägt der Abruf fehl (kein Netz,
//   /// keine Füllung), wird die Anzeige verworfen und [onFailed] gerufen — die
//   /// Oberfläche zeigt dann einfach nichts. Gibt `null` zurück, wenn auf
//   /// dieser Plattform oder für diese Breite keine Anzeige möglich ist.
//   Future<BannerAd?> loadAnchoredBanner({
//     required int width,
//     required void Function(BannerAd ad) onLoaded,
//     required void Function(LoadAdError error) onFailed,
//   }) async {
//     if (!isStorePlatform) return null;
//     await initialize();
//
//     try {
//       final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
//       if (size == null) return null;
//
//       final ad = BannerAd(
//         size: size,
//         adUnitId: AdConfig.bannerAdUnitId(defaultTargetPlatform),
//         request: const AdRequest(),
//         listener: BannerAdListener(
//           onAdLoaded: (ad) => onLoaded(ad as BannerAd),
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//             onFailed(error);
//           },
//         ),
//       );
//       await ad.load();
//       return ad;
//     } catch (error) {
//       debugPrint('Banner nicht geladen: $error');
//       return null;
//     }
//   }
// }
//
// /// Hält die eine [AdsService]-Instanz — wichtig, weil sie sich den
// /// Initialisierungs-Future merkt.
// final adsServiceProvider = Provider<AdsService>((ref) => AdsService());

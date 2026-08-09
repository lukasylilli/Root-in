// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Die App erscheint ohne Werbung; das Google-Konto-Problem blockiert AdMob.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'package:flutter/foundation.dart';
//
// /// Einzige Stelle mit AdMob-Kennungen (siehe PLAN.md Abschnitt 9,
// /// „Puzzling"/DRY). Kein anderer Ort im Dart-Code schreibt eine Ad-Unit-ID
// /// hin — `core/services/ads_service.dart` fragt ausschließlich hier.
// ///
// /// **Zwei Kennungen, zwei Orte:** die *App-ID* (`ca-app-pub-…~…`, mit Tilde)
// /// gehört ins Android-Manifest bzw. in die Info.plist und steht deshalb in
// /// `android/app/src/main/res/values/strings.xml` (`admob_app_id`). Die
// /// *Ad-Unit-ID* (`ca-app-pub-…/…`, mit Schrägstrich) wird zur Laufzeit
// /// gebraucht und steht hier.
// ///
// /// **Echte Anzeigen laufen ausschließlich im Release-Build** (siehe
// /// [usesTestAds]): Debug- und Profile-Builds bekommen immer Googles Test-IDs.
// /// Klicks auf eigene, echte Anzeigen sind ein Sperr-Grund bei AdMob — wer mit
// /// **echten** IDs auf dem Gerät prüfen will, trägt seine Geräte-ID in
// /// [testDeviceIds] ein, statt diese Weiche anzufassen.
// class AdConfig {
//   const AdConfig._();
//
//   // ---------------------------------------------------------------------
//   // Vorübergehender Not-Schalter
//   // ---------------------------------------------------------------------
//
//   /// **Werbung ist für alle Nutzer und alle Builds aus** (gesetzt 2026-08-01).
//   ///
//   /// `true` heißt: jede Installation verhält sich, als wäre „Werbung
//   /// entfernen" gekauft — kein Banner, kein Start des AdMob-SDKs, keine
//   /// Kauf-Rubrik in den Einstellungen. Gelesen wird das an genau einer Stelle,
//   /// dem Schalter `adsRemovedProvider` in
//   /// `core/services/purchase_service.dart`.
//   ///
//   /// Echte Käufe bleiben davon unberührt gespeichert (lokal und bei Play);
//   /// auf `false` zurückstellen bringt Banner und Kauf-Kachel unverändert
//   /// zurück.
//   static const adsDisabledForEveryone = true;
//
//   // ---------------------------------------------------------------------
//   // Produktion — aus der AdMob-Konsole (eingetragen 2026-07-26).
//   // ---------------------------------------------------------------------
//
//   /// Echte Banner-Ad-Unit-ID für Android, Format `ca-app-pub-…/…`.
//   /// Gehört zur App-ID `ca-app-pub-7806974290921501~9284147977` (steht in
//   /// `android/app/src/main/res/values/strings.xml`).
//   static const androidBannerAdUnitId = 'ca-app-pub-7806974290921501/5672206027';
//
//   /// Echte Banner-Ad-Unit-ID für iOS (erst für Phase 12 relevant).
//   static const iosBannerAdUnitId = '';
//
//   // ---------------------------------------------------------------------
//   // Offizielle Test-IDs von Google — geben immer eine Test-Anzeige zurück
//   // und zählen weder als Impression noch als Klick.
//   // https://developers.google.com/admob/android/test-ads
//   // ---------------------------------------------------------------------
//
//   static const testAndroidAppId = 'ca-app-pub-3940256099942544~3347511713';
//   static const testIosAppId = 'ca-app-pub-3940256099942544~1458002511';
//   static const testAndroidBannerAdUnitId =
//       'ca-app-pub-3940256099942544/9214589741';
//   static const testIosBannerAdUnitId = 'ca-app-pub-3940256099942544/2435281174';
//
//   /// Geräte, die auch mit **echten** Ad-Unit-IDs Test-Anzeigen bekommen.
//   ///
//   /// Die ID steht nach dem ersten Anzeigen-Abruf im Logcat („Use
//   /// RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("…"))").
//   /// Nötig, sobald mit echten IDs auf dem eigenen Gerät geprüft wird — siehe
//   /// PLAN.md Phase 14, Schritt „Testen".
//   static const testDeviceIds = <String>[];
//
//   /// Ob die Test-IDs verwendet werden: im Debug-/Profile-Build immer, im
//   /// Release nur, solange keine echte ID hinterlegt ist.
//   static bool get usesTestAds => !kReleaseMode || androidBannerAdUnitId.isEmpty;
//
//   /// Banner-Ad-Unit-ID für die laufende Plattform.
//   static String bannerAdUnitId(TargetPlatform platform) {
//     final isIos = platform == TargetPlatform.iOS;
//     if (usesTestAds) {
//       return isIos ? testIosBannerAdUnitId : testAndroidBannerAdUnitId;
//     }
//     return isIos ? iosBannerAdUnitId : androidBannerAdUnitId;
//   }
// }

// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Kein Banner mehr; der Einhänge-Punkt in core/widgets/main_shell.dart trägt
// denselben Marker.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import '../services/ads_service.dart';
// import '../services/purchase_service.dart';
//
// /// Das dauerhafte Banner am unteren Rand (siehe PLAN.md Phase 14). Einmal in
// /// `core/widgets/main_shell.dart` eingehängt, damit es auf allen vier
// /// Hauptseiten steht und beim Seitenwechsel **nicht** neu geladen wird —
// /// jedes Neuladen kostet eine Anzeigen-Anfrage.
// ///
// /// Zeigt nichts an, solange keine Anzeige geladen ist (kein Netz, keine
// /// Füllung) und sobald „Werbung entfernen" gekauft wurde. Die Prüfung läuft
// /// über [adsRemovedProvider] — dem einen Schalter dafür.
// class BannerAdSlot extends ConsumerStatefulWidget {
//   const BannerAdSlot({super.key});
//
//   @override
//   ConsumerState<BannerAdSlot> createState() => _BannerAdSlotState();
// }
//
// class _BannerAdSlotState extends ConsumerState<BannerAdSlot> {
//   BannerAd? _banner;
//
//   /// Erst nach `onAdLoaded` darf das [AdWidget] in den Baum — vorher hat die
//   /// Anzeige auf der Plattform-Seite noch keine Sicht.
//   bool _isLoaded = false;
//
//   /// Für welche Breite die aktuelle Anzeige geholt wurde. Dreht der Nutzer
//   /// das Gerät, passt die Größe nicht mehr und wir laden neu.
//   int? _loadedForWidth;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadForCurrentWidth();
//   }
//
//   @override
//   void dispose() {
//     _banner?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadForCurrentWidth() async {
//     if (ref.read(adsRemovedProvider)) return;
//
//     final width = MediaQuery.sizeOf(context).width.truncate();
//     if (width == _loadedForWidth) return;
//     _loadedForWidth = width;
//
//     _disposeBanner();
//
//     final banner = await ref
//         .read(adsServiceProvider)
//         .loadAnchoredBanner(
//           width: width,
//           onLoaded: (_) {
//             if (mounted) setState(() => _isLoaded = true);
//           },
//           // Ohne Anzeige bleibt der Platz einfach leer; ein erneuter Versuch
//           // käme sonst in eine Schleife, wenn dauerhaft kein Netz da ist.
//           onFailed: (_) {
//             if (mounted) setState(() => _isLoaded = false);
//           },
//         );
//
//     if (!mounted) {
//       banner?.dispose();
//       return;
//     }
//     _banner = banner;
//   }
//
//   void _disposeBanner() {
//     _banner?.dispose();
//     _banner = null;
//     _isLoaded = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Wird der Kauf während der Laufzeit getätigt, verschwindet das Banner
//     // sofort — inklusive Freigabe der geladenen Anzeige.
//     ref.listen(adsRemovedProvider, (previous, next) {
//       if (next) setState(_disposeBanner);
//     });
//
//     final banner = _banner;
//     if (ref.watch(adsRemovedProvider) || banner == null || !_isLoaded) {
//       return const SizedBox.shrink();
//     }
//
//     return SizedBox(
//       width: banner.size.width.toDouble(),
//       height: banner.size.height.toDouble(),
//       child: AdWidget(ad: banner),
//     );
//   }
// }

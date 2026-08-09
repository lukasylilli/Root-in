// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// Die Rubrik „Werbung" in settings_page.dart trägt denselben Marker.
// Kennungen (AdMob-App-ID, Ad-Unit, Produkt-ID) stehen in PLAN.md Phase 15,
// Nachschlagetabelle — sie werden beim Wiedereinschalten gebraucht.
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../core/services/purchase_service.dart';
// import '../../../l10n/gen/app_localizations.dart';
//
// /// Kauf-Einstieg für „Werbung entfernen" auf der Einstellungen-Seite (siehe
// /// PLAN.md Phase 14). Enthält bewusst auch „Käufe wiederherstellen": Google
// /// verlangt für Nicht-Verbrauchsartikel einen Weg, den Kauf auf einem neuen
// /// Gerät zurückzuholen.
// ///
// /// Die ganze Kauf-Logik liegt in `core/services/purchase_service.dart` — hier
// /// steht nur die Darstellung.
// class RemoveAdsTile extends ConsumerWidget {
//   const RemoveAdsTile({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final l10n = AppLocalizations.of(context);
//     final state = ref.watch(removeAdsProvider);
//
//     ref.listen(removeAdsProvider, (previous, next) {
//       final messenger = ScaffoldMessenger.of(context);
//
//       if (next.purchased && previous?.purchased != true) {
//         messenger.showSnackBar(SnackBar(content: Text(l10n.removeAdsThanks)));
//       }
//
//       final error = next.error;
//       if (error != null && error != previous?.error) {
//         messenger.showSnackBar(
//           SnackBar(content: Text(l10n.removeAdsFailed(error))),
//         );
//         ref.read(removeAdsProvider.notifier).clearError();
//       }
//     });
//
//     if (state.purchased) {
//       return ListTile(
//         leading: const Icon(Icons.verified_outlined),
//         title: Text(l10n.removeAdsPurchasedTitle),
//         subtitle: Text(l10n.removeAdsPurchasedSubtitle),
//       );
//     }
//
//     // Solange der Preis lädt (oder Play nicht erreichbar ist) bleibt die
//     // Kachel sichtbar, aber ohne Preis und ohne Tipp-Ziel.
//     final product = ref.watch(removeAdsProductProvider).value;
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ListTile(
//           leading: const Icon(Icons.block_outlined),
//           title: Text(l10n.removeAdsTitle),
//           subtitle: Text(
//             product == null
//                 ? l10n.removeAdsUnavailable
//                 : l10n.removeAdsSubtitle(product.price),
//           ),
//           trailing: state.inProgress
//               ? const SizedBox.square(
//                   dimension: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : (product == null ? null : const Icon(Icons.chevron_right)),
//           enabled: product != null && !state.inProgress,
//           onTap: product == null
//               ? null
//               : () => ref.read(removeAdsProvider.notifier).buy(product),
//         ),
//         ListTile(
//           leading: const Icon(Icons.restore_outlined),
//           title: Text(l10n.removeAdsRestore),
//           subtitle: Text(l10n.removeAdsRestoreSubtitle),
//           enabled: !state.inProgress,
//           onTap: () => ref.read(removeAdsProvider.notifier).restore(),
//         ),
//       ],
//     );
//   }
// }

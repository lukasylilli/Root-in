import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../routing/app_routes.dart';
// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// import 'banner_ad_slot.dart';

/// Gemeinsamer Rahmen mit Bottom-Navigation für die vier Hauptseiten.
/// [child] ist die vom Router aktuell ausgewählte Seite.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    final index = AppRoutes.bottomNavOrder.indexOf(location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      // PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
      // Das Banner stand **oberhalb** der Navigation und außerhalb von `body`:
      // so steht es auf allen vier Hauptseiten an derselben Stelle, scrollt
      // nicht weg und wird beim Seitenwechsel nicht neu geladen (Phase 14).
      // Zum Wiederaktivieren die `NavigationBar` unten wieder in diese Spalte
      // legen — dann verschwindet auch der leere Streifen nicht mehr von
      // selbst, `BannerAdSlot` nimmt ohne geladene Anzeige aber keinen Platz:
      //
      // bottomNavigationBar: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [const BannerAdSlot(), NavigationBar(…)],
      // ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            context.go(AppRoutes.bottomNavOrder[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navView,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

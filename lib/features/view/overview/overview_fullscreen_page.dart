import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/platform_support.dart';
import 'overview_board_view.dart';

/// Die Übersicht-Bühne im Vollbild (siehe PLAN.md Phase 16).
///
/// Rechnung dahinter: Im Tab bleiben von 411 dp Höhe nach Statusleiste (24),
/// AppBar (56), TabBar (46) und Bottom-Navigation (80) nur rund 190 dp übrig.
/// Weil die Bühne als **Ganzes** skaliert wird — anders wären ihre
/// Proportionen nicht auf jedem Gerät gleich — landet sie damit bei etwa 30 %
/// ihrer Entwurfsgröße und ist nicht mehr lesbar. Diese Seite nimmt alle vier
/// Streifen weg (eigene Route außerhalb der Shell → keine Bottom-Navigation,
/// kein AppBar/TabBar; `immersive` → keine System-Leisten) und verdoppelt
/// damit die Bühne.
///
/// Die View-Seite bleibt darunter liegen, ihr Übersicht-Tab hält also weiter
/// die Querformat-Sperre.
class OverviewFullscreenPage extends StatefulWidget {
  const OverviewFullscreenPage({super.key});

  @override
  State<OverviewFullscreenPage> createState() => _OverviewFullscreenPageState();
}

class _OverviewFullscreenPageState extends State<OverviewFullscreenPage> {
  @override
  void initState() {
    super.initState();
    _setImmersive(true);
  }

  @override
  void dispose() {
    _setImmersive(false);
    super.dispose();
  }

  void _setImmersive(bool immersive) {
    if (!isMobilePlatform) return;
    SystemChrome.setEnabledSystemUIMode(
      immersive ? SystemUiMode.immersive : SystemUiMode.manual,
      overlays: immersive ? const [] : SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Schließen bewusst über den Navigator statt über go_router: dieselbe
    // Seite lässt sich damit auch ohne Router rendern (Widget-Tests), und
    // go_router bekommt das Entfernen der Route trotzdem mit.
    return Scaffold(
      body: SafeArea(
        child: OverviewBoardView(
          onClose: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

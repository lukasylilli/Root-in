import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/platform_support.dart';
import 'overview_board_view.dart';

/// Unterseite „Übersicht" zwischen Woche und Monat (siehe PLAN.md Phase 16):
/// die letzten vier Kalenderwochen (Montag–Sonntag) als **eine** quer liegende
/// Bühne (siehe `overview_board.dart`).
///
/// Drei Dinge macht diese Seite anders als die übrigen View-Unterseiten:
///
/// * Sie sperrt, solange sie der ausgewählte Tab ist, die Ausrichtung auf
///   Querformat — hochkant wäre die Bühne nur noch briefmarkengroß.
/// * Sie führt ins **Vollbild** (`overview_fullscreen_page.dart`), weil im Tab
///   nach AppBar, TabBar und Bottom-Navigation zu wenig Höhe übrig bleibt.
/// * Sie ist bewusst **kein** individualisierbares Dashboard
///   ([RangeMatrixTab]): Diagramme, Matrix und Tabelle sind hier ein
///   gemeinsames Raster; einzelne Karten daraus zu entfernen oder zu
///   verschieben würde genau die Ausrichtung zerstören, die die Seite ausmacht.
class OverviewTab extends ConsumerStatefulWidget {
  const OverviewTab({super.key, required this.tabIndex});

  /// Position dieses Tabs im umgebenden [TabBar] — daran erkennt die Seite,
  /// ob sie gerade sichtbar ist. Die Tabs eines [TabBarView] bleiben alle
  /// gebaut; ohne diese Prüfung bliebe das Querformat auch auf Woche/Monat.
  final int tabIndex;

  @override
  ConsumerState<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<OverviewTab> {
  /// Gedreht wird erst, wenn der Tab-Wechsel fertig ist.
  ///
  /// Auf dem Gerät beobachtet (2026-07-30): dreht die App mitten in der
  /// Seiten-Animation, ändert sich die Breite des [TabBarView]-Viewports,
  /// während dessen Scroll-Animation noch läuft — der Wechsel schnappt dann
  /// sichtbar auf „Woche" zurück, während die Querformat-Sperre stehen bleibt.
  /// Etwas mehr als die Tab-Animation (`kTabScrollDuration`, 300 ms) abwarten
  /// löst das; danach ist das Drehen unkritisch.
  static const Duration _lockDelay = Duration(milliseconds: 450);

  TabController? _tabController;
  Timer? _lockTimer;
  bool _landscapeLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.maybeOf(context);
    if (controller != _tabController) {
      _tabController?.removeListener(_syncOrientation);
      controller?.addListener(_syncOrientation);
      _tabController = controller;
    }
    _syncOrientation();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_syncOrientation);
    _lockTimer?.cancel();
    // Beim Verlassen der View-Seite die Sperre wieder aufheben — sonst bliebe
    // die ganze App im Querformat hängen.
    if (_landscapeLocked) _setLandscapeLock(false);
    super.dispose();
  }

  void _syncOrientation() {
    final isCurrentTab = _tabController?.index == widget.tabIndex;
    if (isCurrentTab == _landscapeLocked) return;

    // Jede weitere Änderung während der Wartezeit setzt sie zurück: wer zwei
    // Tabs weiter wischt, soll nicht kurz zwischendurch gedreht werden.
    _lockTimer?.cancel();
    _lockTimer = Timer(_lockDelay, () {
      if (!mounted) return;
      final stillCurrent = _tabController?.index == widget.tabIndex;
      if (stillCurrent != _landscapeLocked) _setLandscapeLock(stillCurrent);
    });
  }

  void _setLandscapeLock(bool locked) {
    _landscapeLocked = locked;
    if (!isMobilePlatform) return;
    SystemChrome.setPreferredOrientations(
      locked
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          // Leere Liste = wieder alle Ausrichtungen, die Manifest/Info.plist
          // erlauben.
          : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverviewBoardView(
      onExpand: () => context.push(AppRoutes.overviewFullscreen),
    );
  }
}

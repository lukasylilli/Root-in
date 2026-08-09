import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/dashboard/dashboard_widget_type.dart';
import 'settings_service.dart' show sharedPreferencesProvider;

/// Persistiert pro Seite, welche Dashboard-Widgets in welcher Reihenfolge
/// angezeigt werden (siehe PLAN.md Phase 5.5 — individualisierbare Seiten).
/// Einzige Stelle, die dafür `shared_preferences` anfasst.
class DashboardLayoutService {
  const DashboardLayoutService(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String pageId) => 'dashboard_layout_$pageId';

  List<DashboardWidgetType> load(
    String pageId,
    List<DashboardWidgetType> fallback,
  ) {
    final raw = _prefs.getStringList(_key(pageId));
    if (raw == null) return fallback;
    return [
      for (final name in raw)
        ...DashboardWidgetType.values.where((type) => type.name == name),
    ];
  }

  Future<void> save(String pageId, List<DashboardWidgetType> types) {
    return _prefs.setStringList(_key(pageId), [
      for (final type in types) type.name,
    ]);
  }
}

final dashboardLayoutServiceProvider = Provider<DashboardLayoutService>((ref) {
  return DashboardLayoutService(ref.watch(sharedPreferencesProvider));
});

/// Konfiguration für [dashboardLayoutProvider]: welche Seite, welche
/// Widgets standardmäßig aktiv sind, falls noch nichts gespeichert wurde.
/// Immer eine benannte `const`-Liste aus `core/constants/dashboard_defaults.dart`
/// als [defaultTypes] übergeben (siehe Kommentar dort — Stabilität als
/// Family-Schlüssel).
typedef DashboardPageConfig = ({
  String pageId,
  List<DashboardWidgetType> defaultTypes,
});

class DashboardLayoutNotifier extends Notifier<List<DashboardWidgetType>> {
  DashboardLayoutNotifier(this.config);

  final DashboardPageConfig config;

  @override
  List<DashboardWidgetType> build() {
    return ref
        .watch(dashboardLayoutServiceProvider)
        .load(config.pageId, config.defaultTypes);
  }

  Future<void> _persist() {
    return ref.read(dashboardLayoutServiceProvider).save(config.pageId, state);
  }

  void toggle(DashboardWidgetType type) {
    state = state.contains(type)
        ? [for (final t in state) if (t != type) t]
        : [...state, type];
    _persist();
  }

  /// [newIndex] kommt über `ReorderableListView.onReorderItem` bereits
  /// für die Entfernung an [oldIndex] bereinigt an — kein manueller
  /// Offset nötig (anders als beim älteren, inzwischen veralteten
  /// `onReorder`).
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _persist();
  }
}

/// Einziger Zugriffspunkt auf das individualisierbare Seiten-Layout (siehe
/// PLAN.md Abschnitt 9, Design-Token-Prinzip — dasselbe Muster wie
/// `themeModeProvider`/`profileProvider`, hier als Family pro Seite).
final dashboardLayoutProvider =
    NotifierProvider.family<
      DashboardLayoutNotifier,
      List<DashboardWidgetType>,
      DashboardPageConfig
    >(DashboardLayoutNotifier.new);

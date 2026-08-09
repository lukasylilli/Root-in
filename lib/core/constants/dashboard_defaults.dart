import '../widgets/dashboard/dashboard_widget_type.dart';

/// Standard-Widgets je Seite, falls der Nutzer noch kein eigenes Layout
/// gespeichert hat (siehe PLAN.md Phase 5.5). Als benannte `const`-Listen,
/// damit dieselbe Konfiguration bei jedem Build dieselbe Listen-Instanz
/// liefert — [DashboardPageConfig] (Record) dient als Riverpod-Family-
/// Schlüssel, und ein bei jedem Aufruf neu erzeugtes Listen-Literal wäre
/// (da `List` keine strukturelle Gleichheit hat) jedes Mal ein „anderer"
/// Schlüssel und würde unnötig neue Provider-Instanzen anlegen.
const List<DashboardWidgetType> homeDashboardDefaults = [
  DashboardWidgetType.matrixGrid,
];

const List<DashboardWidgetType> weekMonthDashboardDefaults = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.categoryBar,
];

const List<DashboardWidgetType> yearDashboardDefaults = [
  DashboardWidgetType.matrixGrid,
  DashboardWidgetType.progressTrend,
  DashboardWidgetType.categoryBar,
  DashboardWidgetType.monthlyBar,
];

const List<DashboardWidgetType> accountDashboardDefaults = [
  DashboardWidgetType.matrixGrid,
];

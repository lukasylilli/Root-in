import '../../../l10n/gen/app_localizations.dart';

/// Katalog aller Widgets/Diagramme, die eine Seite über das individuali-
/// sierbare Dashboard anzeigen kann (siehe PLAN.md Phase 5.5). Einzige
/// Quelle für „welche Diagramm-Typen gibt es" — Seiten wählen daraus nur
/// aus, statt eigene Typ-Listen zu pflegen.
enum DashboardWidgetType {
  matrixGrid,
  categoryBar,
  categoryPie,
  progressTrend,
  monthlyBar;

  String label(AppLocalizations l10n) => switch (this) {
    DashboardWidgetType.matrixGrid => l10n.widgetMatrixGrid,
    DashboardWidgetType.categoryBar => l10n.widgetCategoryBar,
    DashboardWidgetType.categoryPie => l10n.widgetCategoryPie,
    DashboardWidgetType.progressTrend => l10n.widgetProgressTrend,
    DashboardWidgetType.monthlyBar => l10n.widgetMonthlyBar,
  };

  /// Klassenname des zugehörigen Android-`AppWidgetProvider`s (siehe PLAN.md
  /// Phase 10.7) — muss zu den Klassen in `ChartWidgetProviders.kt` und den
  /// Receivern im `AndroidManifest.xml` passen.
  String get androidWidgetProvider => switch (this) {
    DashboardWidgetType.matrixGrid => 'MatrixGridWidgetProvider',
    DashboardWidgetType.categoryBar => 'CategoryBarWidgetProvider',
    DashboardWidgetType.categoryPie => 'CategoryPieWidgetProvider',
    DashboardWidgetType.progressTrend => 'ProgressTrendWidgetProvider',
    DashboardWidgetType.monthlyBar => 'MonthlyBarWidgetProvider',
  };
}

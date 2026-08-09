package com.rootin.app

/**
 * Die fünf konkreten Diagramm-Widgets (siehe PLAN.md Phase 10.7). Jede
 * Klasse liefert nur ihren Datenschlüssel; die Anzeige-Logik erben sie von
 * [ChartWidgetProvider]. Die Schlüssel entsprechen `chart_<DashboardWidgetType.name>`
 * — dieselbe Bildung wie in `HomeWidgetService.chartKeyFor` (Dart).
 */
class MatrixGridWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "chart_matrixGrid"
}

class CategoryBarWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "chart_categoryBar"
}

class CategoryPieWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "chart_categoryPie"
}

class ProgressTrendWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "chart_progressTrend"
}

class MonthlyBarWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "chart_monthlyBar"
}

/**
 * Widget-Familien aus der Widget-Spec (siehe PLAN.md Phase 10.6c):
 * Tagesring und Wochen-Checkliste. Gleiches Muster wie die Diagramme —
 * die App rendert das PNG, der Provider zeigt es.
 */
class RingWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "extra_ring"
}

class ChecklistWidgetProvider : ChartWidgetProvider() {
    override val dataKey = "extra_checklist"
}

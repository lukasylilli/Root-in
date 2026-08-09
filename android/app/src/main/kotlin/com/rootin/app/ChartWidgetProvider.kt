package com.rootin.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * Gemeinsame Basis der fünf Diagramm-Widgets (siehe PLAN.md Phase 10.7).
 *
 * Jedes Diagramm ist ein **eigenständiges** Home-Screen-Widget, damit alle
 * fünf gleichzeitig platziert und in der Widget-Auswahl des Launchers
 * einzeln ausgewählt werden können — die Auswahl passiert also auf dem
 * Startbildschirm, nicht in der App. Die Unterklassen liefern nur ihren
 * Datenschlüssel; die Anzeige-Logik steht genau hier, nicht fünfmal.
 *
 * Die App rendert jedes Diagramm als PNG und hinterlegt den Pfad unter
 * `chart_<typ>` (siehe `lib/core/services/home_widget_service.dart`).
 */
abstract class ChartWidgetProvider : HomeWidgetProvider() {

    /** Muss zu `HomeWidgetService.chartKeyFor` in Dart passen. */
    abstract val dataKey: String

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views =
                RemoteViews(context.packageName, R.layout.root_in_chart_widget).apply {
                    val bitmap = widgetData.getString(dataKey, null)
                        ?.let { File(it) }
                        ?.takeIf { it.exists() }
                        ?.let { BitmapFactory.decodeFile(it.absolutePath) }
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.chart_image, bitmap)
                        setViewVisibility(R.id.chart_image, View.VISIBLE)
                        setViewVisibility(R.id.chart_placeholder, View.GONE)
                    } else {
                        setViewVisibility(R.id.chart_image, View.GONE)
                        setViewVisibility(R.id.chart_placeholder, View.VISIBLE)
                    }
                }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

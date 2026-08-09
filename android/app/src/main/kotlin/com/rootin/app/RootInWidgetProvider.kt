package com.rootin.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Fortschritts-Widget von Root-in (siehe PLAN.md Phase 10): zeigt den
 * heutigen Fortschritt in Prozent und „x/y erledigt". Die fünf
 * Diagramm-Widgets sind eigene Klassen (siehe [ChartWidgetProvider]).
 *
 * Die Werte kommen aus den SharedPreferences, die die App über
 * `HomeWidget.saveWidgetData` füllt (siehe
 * `lib/core/services/home_widget_service.dart`) — dieselben Schlüssel
 * müssen dort und hier verwendet werden.
 */
class RootInWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.root_in_widget).apply {
                // -1 = noch nie befüllt (App wurde seit Installation nicht
                // geöffnet); dann bleibt der Platzhalter stehen.
                val percent = widgetData.getInt("progress_percent", -1)
                if (percent < 0) {
                    setTextViewText(R.id.widget_percent, context.getString(R.string.widget_placeholder_percent))
                    setTextViewText(
                        R.id.widget_subtitle,
                        context.getString(R.string.widget_placeholder_subtitle),
                    )
                } else {
                    setTextViewText(R.id.widget_percent, "$percent%")
                    setTextViewText(
                        R.id.widget_subtitle,
                        widgetData.getString("progress_subtitle", "") ?: "",
                    )
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

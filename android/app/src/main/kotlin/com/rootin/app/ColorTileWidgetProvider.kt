package com.rootin.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Farbkachel-Widget (siehe PLAN.md Phase 10.6d; Widget-Spec SCREEN_16).
 *
 * Anders als die Diagramm-Widgets ([ChartWidgetProvider]) zeigt diese Kachel
 * **kein gerendertes Bild**, sondern echte `RemoteViews` — nur so lässt sich
 * der Log-Button antippen. Jede platzierte Kachel gehört zu genau einer
 * Gewohnheit; welche das ist, wählt der Nutzer beim Platzieren in
 * [ColorTileConfigActivity].
 *
 * Die Werte je Gewohnheit schreibt die App unter den Schlüsseln aus
 * `lib/core/services/home_widget_service.dart` — dieselben Namen müssen
 * dort und hier stehen.
 */
class ColorTileWidgetProvider : HomeWidgetProvider() {

    companion object {
        /** Muss zu `ColorTileKeys` in Dart passen. */
        fun habitIdKey(appWidgetId: Int) = "tile_widget_$appWidgetId"

        fun nameKey(habitId: Int) = "tile_name_$habitId"
        fun colorKey(habitId: Int) = "tile_color_$habitId"
        fun streakKey(habitId: Int) = "tile_streak_$habitId"
        fun doneKey(habitId: Int) = "tile_done_$habitId"

        /** Wird vom Dart-Background-Callback ausgewertet. */
        const val TOGGLE_HOST = "toggle"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            appWidgetManager.updateAppWidget(
                widgetId,
                buildViews(context, widgetData, widgetId),
            )
        }
    }

    private fun buildViews(
        context: Context,
        widgetData: SharedPreferences,
        appWidgetId: Int,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.root_in_color_tile_widget)
        val habitId = widgetData.getInt(habitIdKey(appWidgetId), -1)
        val name = if (habitId < 0) null else widgetData.getString(nameKey(habitId), null)

        if (name == null) {
            // Entweder noch nicht konfiguriert oder die Gewohnheit wurde in
            // der App gelöscht — dann bleibt die Kachel neutral und stumm.
            views.setTextViewText(
                R.id.tile_name,
                context.getString(R.string.widget_color_tile_unconfigured),
            )
            views.setTextViewText(R.id.tile_streak, "")
            views.setInt(R.id.tile_background, "setColorFilter", 0xFF3A3A3C.toInt())
            views.setViewVisibility(R.id.tile_log_button, android.view.View.GONE)
            return views
        }

        val color = widgetData.intOrDefault(colorKey(habitId), 0xFF2E7D5B.toInt())
        val streak = widgetData.intOrDefault(streakKey(habitId), 0)
        val done = widgetData.getBoolean(doneKey(habitId), false)

        views.setTextViewText(R.id.tile_name, name)
        views.setTextViewText(R.id.tile_streak, context.getString(R.string.widget_color_tile_streak, streak))
        views.setInt(R.id.tile_background, "setColorFilter", color)
        views.setViewVisibility(R.id.tile_log_button, android.view.View.VISIBLE)
        views.setImageViewResource(
            R.id.tile_log_icon,
            if (done) R.drawable.ic_tile_check else R.drawable.ic_tile_plus,
        )

        // Antippen läuft über den Dart-Background-Callback (kein Öffnen der
        // App) — die Habit-ID reist in der URI mit, weil das Callback-Isolate
        // keinen Zugriff auf den App-Zustand hat.
        val intent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("rootin://$TOGGLE_HOST?habitId=$habitId&widgetId=$appWidgetId"),
        )
        views.setOnClickPendingIntent(R.id.tile_log_button, intent)

        return views
    }

    /**
     * Liest eine Zahl, die als `Int` **oder** `Long` abgelegt sein kann.
     *
     * Dart-Zahlen sind 64 Bit: ein ARGB-Wert über `Int.MAX_VALUE` landet als
     * `Long` in den Preferences, und `getInt` würde darauf mit einer
     * ClassCastException abstürzen. Die App schreibt Farben inzwischen
     * vorzeichenbehaftet (siehe `home_widget_service.dart`); diese
     * Toleranz schützt zusätzlich Bestände, die noch von einer älteren
     * Version stammen.
     */
    private fun SharedPreferences.intOrDefault(key: String, fallback: Int): Int =
        when (val raw = all[key]) {
            is Int -> raw
            is Long -> raw.toInt()
            else -> fallback
        }
}

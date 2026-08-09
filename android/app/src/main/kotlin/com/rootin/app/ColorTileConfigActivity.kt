package com.rootin.app

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.TextView
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Auswahl beim Platzieren einer Farbkachel (siehe PLAN.md Phase 10.6d):
 * „eine Kachel = eine Gewohnheit" braucht die Angabe, **welche** Gewohnheit
 * die Kachel zeigen soll.
 *
 * Die Liste kommt aus den Widget-Preferences, die die App füllt (Schlüssel
 * `tile_habit_ids` als CSV plus `tile_name_<id>`) — die Activity spricht
 * also nie selbst mit der Datenbank und braucht keine Flutter-Engine.
 */
class ColorTileConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Bricht der Nutzer ab (Zurück-Taste), darf kein Widget entstehen.
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContentView(R.layout.root_in_color_tile_config)

        val prefs = HomeWidgetPlugin.getData(this)
        val habitIds = prefs.getString("tile_habit_ids", "")
            ?.split(",")
            ?.mapNotNull { it.trim().toIntOrNull() }
            ?: emptyList()

        val names = habitIds.map { id ->
            prefs.getString(ColorTileWidgetProvider.nameKey(id), null) ?: "#$id"
        }

        val list = findViewById<ListView>(R.id.config_list)
        val empty = findViewById<TextView>(R.id.config_empty)

        if (habitIds.isEmpty()) {
            // Kein Katalog vorhanden: die App wurde seit der Installation
            // nicht geöffnet oder es gibt noch keine Gewohnheiten.
            list.visibility = ListView.GONE
            empty.visibility = TextView.VISIBLE
            return
        }

        list.adapter = ArrayAdapter(this, R.layout.root_in_color_tile_config_item, names)
        list.setOnItemClickListener { _, _, position, _ ->
            confirm(habitIds[position])
        }
    }

    private fun confirm(habitId: Int) {
        // Die Zuordnung Widget→Gewohnheit liegt in denselben Preferences wie
        // die übrigen Widget-Daten, damit der Provider sie ohne Umweg liest.
        // `commit()` statt `apply()`: die Auswahl muss auf der Platte stehen,
        // bevor irgendetwas danach schiefgehen kann — sonst stünde am Ende
        // eine Kachel ohne Zuordnung auf dem Startbildschirm.
        HomeWidgetPlugin.getData(this).edit()
            .putInt(ColorTileWidgetProvider.habitIdKey(appWidgetId), habitId)
            .commit()

        // Kachel sofort zeichnen, sonst bliebe sie bis zur nächsten
        // App-Aktualisierung leer. Scheitert das (etwa weil die Widget-ID
        // noch nicht registriert ist), bleibt die Auswahl trotzdem bestehen —
        // das nächste reguläre Update zeichnet sie dann.
        runCatching {
            ColorTileWidgetProvider().onUpdate(
                this,
                AppWidgetManager.getInstance(this),
                intArrayOf(appWidgetId),
                HomeWidgetPlugin.getData(this),
            )
        }

        setResult(
            RESULT_OK,
            Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId),
        )
        finish()
    }
}

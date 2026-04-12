package com.ndclock.nd_clock

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class PrismWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
        ) {
            // home_widget stores data in this SharedPreferences file.
            val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
            val progress = prefs.getFloat("prism_progress", 0f)
            val viewLabel = prefs.getString("prism_view_label", "Prism") ?: "Prism"
            val displayLabel = prefs.getString("prism_display_label", "") ?: ""
            val countdown = prefs.getString("prism_countdown", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.prism_widget)
            views.setTextViewText(R.id.widget_header, "Prism \u2022 $viewLabel")
            views.setProgressBar(
                R.id.widget_progress_bar,
                1000,
                (progress * 1000).toInt(),
                false,
            )
            views.setTextViewText(R.id.widget_display_label, displayLabel)
            views.setTextViewText(R.id.widget_countdown, countdown)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

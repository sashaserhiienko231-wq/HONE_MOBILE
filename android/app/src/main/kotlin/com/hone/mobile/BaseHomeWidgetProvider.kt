package com.hone.mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

abstract class BaseHomeWidgetProvider(
    private val layoutId: Int,
    private val bind: (RemoteViews, SharedPreferences) -> Unit,
) : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutId)
            bind(views, widgetData)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

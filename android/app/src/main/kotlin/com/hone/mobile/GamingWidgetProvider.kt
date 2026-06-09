package com.hone.mobile

import com.hone.mobile.R

class GamingWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.gaming_widget_medium,
    bind = { views, data ->
        views.setTextViewText(R.id.cpu_usage, data.getString("cpu_usage", "0%"))
        views.setTextViewText(R.id.ram_usage, data.getString("ram_usage", "0%"))
        views.setTextViewText(R.id.temp_value, data.getString("temp_value", "0øC"))
        views.setTextViewText(R.id.fps_value, data.getString("fps_value", "0"))
    },
)

class RamWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.widget_ram,
    bind = { views, data ->
        views.setTextViewText(R.id.widget_value, data.getString("ram_usage", "0%"))
    },
)

class StorageWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.widget_storage,
    bind = { views, data ->
        views.setTextViewText(R.id.widget_value, data.getString("storage_percent", "0%"))
    },
)

class FpsWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.widget_fps,
    bind = { views, data ->
        views.setTextViewText(R.id.widget_value, data.getString("fps_value", "0"))
    },
)

class NetworkWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.widget_network,
    bind = { views, data ->
        views.setTextViewText(R.id.widget_value, data.getString("latency_ms", "0 ms"))
    },
)

class GamingModeWidgetProvider : BaseHomeWidgetProvider(
    layoutId = R.layout.widget_gaming_mode,
    bind = { views, data ->
        views.setTextViewText(R.id.widget_value, data.getString("gaming_mode", "OFF"))
    },
)

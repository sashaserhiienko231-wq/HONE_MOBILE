import 'package:flutter/services.dart';
import 'package:hone_mobile/core/compatibility/device_compatibility_engine.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/services/settings_service.dart';
import 'package:hone_mobile/core/utils/logger.dart';

class GamingWidgetService {
  static const _channel = MethodChannel('home_widget');
  static bool _initialized = false;

  static const _androidWidgets = <String, String>{
    'performance': 'GamingWidgetProvider',
    'ram': 'RamWidgetProvider',
    'storage': 'StorageWidgetProvider',
    'fps': 'FpsWidgetProvider',
    'network': 'NetworkWidgetProvider',
    'gaming_mode': 'GamingModeWidgetProvider',
  };

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _channel.invokeMethod<void>('setAppGroupId', {'groupId': 'group.hone.mobile'});
      _initialized = true;
      await _publishFallback();
      Logger.instance.info(
        'Gaming widgets initialized (refresh ${DeviceCompatibilityEngine.widgetRefreshInterval.inMinutes}m)',
        tag: 'GamingWidget',
      );
    } catch (e) {
      Logger.instance.error('Widget init failed', tag: 'GamingWidget', error: e);
      _initialized = true;
    }
  }

  static Future<void> updatePerformanceWidgets(PerformanceStats stats) async {
    if (!SettingsService.homeWidgetsEnabled) return;

    try {
      await _save('cpu_usage', '${stats.cpuUsage.toStringAsFixed(0)}%');
      await _save('ram_usage', '${stats.memoryUsage.toStringAsFixed(0)}%');
      await _save('fps_value', stats.fps.toStringAsFixed(0));
      await _save('temp_value', '${(35 + (stats.cpuUsage / 10)).toStringAsFixed(1)}\u00B0C');
      await _save('storage_percent', '${stats.memoryUsage.toStringAsFixed(0)}%');
      await _save('latency_ms', '${stats.networkLatency.toStringAsFixed(0)} ms');
      await _save('gaming_mode', SettingsService.gameMode ? 'ON' : 'OFF');
      await _updateEnabledWidgets();
    } catch (e) {
      Logger.instance.error('Error updating widgets', tag: 'GamingWidget', error: e);
    }
  }

  static Future<void> _updateEnabledWidgets() async {
    if (SettingsService.widgetPerformanceEnabled) await _updateWidget('performance');
    if (SettingsService.widgetRamEnabled) await _updateWidget('ram');
    if (SettingsService.widgetStorageEnabled) await _updateWidget('storage');
    if (SettingsService.widgetFpsEnabled) await _updateWidget('fps');
    if (SettingsService.widgetNetworkEnabled) await _updateWidget('network');
    if (SettingsService.widgetGamingModeEnabled) await _updateWidget('gaming_mode');
  }

  static Future<void> _updateWidget(String key) async {
    final androidName = _androidWidgets[key];
    if (androidName == null) return;
    await _channel.invokeMethod<void>('updateWidget', {
      'name': androidName,
      'android': androidName,
    });
  }

  static Future<void> _save(String id, String data) async {
    await _channel.invokeMethod<void>('saveWidgetData', {'id': id, 'data': data});
  }

  static Future<void> _publishFallback() async {
    await _save('cpu_usage', '--');
    await _save('ram_usage', '--');
    await _save('fps_value', '--');
    await _save('temp_value', '--\u00B0C');
    await _save('storage_percent', '--');
    await _save('latency_ms', '--');
    await _save('gaming_mode', 'OFF');
    for (final name in _androidWidgets.values) {
      await _channel.invokeMethod<void>('updateWidget', {
        'name': name,
        'android': name,
      });
    }
  }
}

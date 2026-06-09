
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/services/settings_service.dart';

Map<String, bool> _loadSettingsMap() {
  return {
    'auto_optimization': SettingsService.autoOptimization,
    'background_monitoring': SettingsService.backgroundMonitoring,
    'game_mode': SettingsService.gameMode,
    'performance_alerts': SettingsService.performanceAlerts,
    'thermal_alerts': SettingsService.thermalAlerts,
    'neon_effects': SettingsService.neonEffects,
    'animations_enabled': SettingsService.animationsEnabled,
    'animations_premium_mode': SettingsService.animationsPremiumMode,
    'animations_reduce_motion': SettingsService.animationsReduceMotion,

    'battery_alerts': SettingsService.batteryAlerts,
    'home_widgets_enabled': SettingsService.homeWidgetsEnabled,
    'widget_performance_enabled': SettingsService.widgetPerformanceEnabled,
    'widget_ram_enabled': SettingsService.widgetRamEnabled,
    'widget_storage_enabled': SettingsService.widgetStorageEnabled,
    'widget_fps_enabled': SettingsService.widgetFpsEnabled,
    'widget_network_enabled': SettingsService.widgetNetworkEnabled,
    'widget_gaming_mode_enabled': SettingsService.widgetGamingModeEnabled,
  };
}

class SettingsNotifier extends StateNotifier<AsyncValue<Map<String, bool>>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      if (!SettingsService.isInitialized) {
        await SettingsService.initialize();
      }
      state = AsyncValue.data(_loadSettingsMap());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() => _init();

  Future<void> toggleSetting(String key) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newValue = !(current[key] ?? false);
    await SettingsService.setBool(key, newValue);
    state = AsyncValue.data({...current, key: newValue});
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Map<String, bool>>>(
  (ref) => SettingsNotifier(),
);

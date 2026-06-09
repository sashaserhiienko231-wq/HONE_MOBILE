import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    if (!_isInitialized) return defaultValue;
    return _prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Common settings
  static bool get autoOptimization => getBool('auto_optimization', defaultValue: true);
  static bool get backgroundMonitoring => getBool('background_monitoring', defaultValue: true);
  static bool get gameMode => getBool('game_mode', defaultValue: false);
  static bool get performanceAlerts => getBool('performance_alerts', defaultValue: true);
  static bool get thermalAlerts => getBool('thermal_alerts', defaultValue: true);
  static bool get batteryAlerts => getBool('battery_alerts', defaultValue: false);
  static bool get neonEffects => getBool('neon_effects', defaultValue: true);
  static bool get animationsEnabled => getBool('animations_enabled', defaultValue: true);
  static bool get animationsPremiumMode => getBool('animations_premium_mode', defaultValue: true);
  static bool get animationsReduceMotion => getBool('animations_reduce_motion', defaultValue: false);

  static bool get homeWidgetsEnabled => getBool('home_widgets_enabled', defaultValue: true);
  static bool get widgetPerformanceEnabled =>
      getBool('widget_performance_enabled', defaultValue: true);
  static bool get widgetRamEnabled => getBool('widget_ram_enabled', defaultValue: true);
  static bool get widgetStorageEnabled =>
      getBool('widget_storage_enabled', defaultValue: true);
  static bool get widgetFpsEnabled => getBool('widget_fps_enabled', defaultValue: true);
  static bool get widgetNetworkEnabled =>
      getBool('widget_network_enabled', defaultValue: true);
  static bool get widgetGamingModeEnabled =>
      getBool('widget_gaming_mode_enabled', defaultValue: true);
}

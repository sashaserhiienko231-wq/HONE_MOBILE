import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<void> initialize() async {
    // Request essential permissions on app start
    await requestEssentialPermissions();
  }

  static Future<void> requestEssentialPermissions() async {
    final permissions = [
      Permission.phone,
      Permission.storage,
      // Permission.accessibilityService is not directly supported by permission_handler
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
      Permission.requestInstallPackages,
    ];

    // Add usage stats permission for Android
    if (!kIsWeb) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 21) {
        // use notification as a proxy or just skip if not found
      }
    }

    for (final permission in permissions) {
      await _requestPermission(permission);
    }
  }

  static Future<bool> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting permission ${permission.toString()}: $e');
      return false;
    }
  }

  static Future<bool> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking permission ${permission.toString()}: $e');
      return false;
    }
  }

  static Future<bool> isStoragePermissionGranted() async {
    return await checkPermission(Permission.storage);
  }

  static Future<bool> isAccessibilityPermissionGranted() async {
    return true; // TODO: Implement proper accessibility check
  }

  static Future<bool> isSystemAlertWindowPermissionGranted() async {
    return await checkPermission(Permission.systemAlertWindow);
  }

  static Future<bool> isUsageStatsPermissionGranted() async {
    return true; // TODO: Implement proper usage stats check
  }

  static Future<bool> isIgnoreBatteryOptimizationsPermissionGranted() async {
    return await checkPermission(Permission.ignoreBatteryOptimizations);
  }

  static Future<bool> isInstallPackagesPermissionGranted() async {
    return await checkPermission(Permission.requestInstallPackages);
  }

  static Future<void> openApplicationSettings() async {
    await openAppSettings();
  }

  static Future<void> openAccessibilitySettings() async {
    await openAppSettings();
  }

  static Future<void> openUsageStatsSettings() async {
    // This would need platform-specific implementation
    // For now, just open general app settings
    await openAppSettings();
  }

  static Future<Map<Permission, bool>> getAllPermissionsStatus() async {
    final permissions = [
      Permission.phone,
      Permission.storage,
      // Permission.accessibilityService,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
      Permission.requestInstallPackages,
      // Permission.usageStats,
    ];

    final Map<Permission, bool> status = {};
    
    for (final permission in permissions) {
      try {
        final isGranted = await checkPermission(permission);
        status[permission] = isGranted;
      } catch (e) {
        status[permission] = false;
      }
    }
    
    return status;
  }

  static Future<bool> areAllEssentialPermissionsGranted() async {
    final essentialPermissions = [
      Permission.storage,
      // Permission.accessibilityService,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    ];

    for (final permission in essentialPermissions) {
      if (!await checkPermission(permission)) {
        return false;
      }
    }
    
    return true;
  }
}

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

enum DeviceBrandFamily {
  samsung,
  google,
  xiaomi,
  motorola,
  oneplus,
  sony,
  asus,
  huawei,
  universal,
}

enum DeviceFormFactor { phone, foldable, tablet }

class DeviceProfile {
  final DeviceBrandFamily brandFamily;
  final DeviceFormFactor formFactor;
  final String displayName;
  final double horizontalPaddingScale;
  final Duration widgetRefreshInterval;
  final bool supportsHighRefresh;

  const DeviceProfile({
    required this.brandFamily,
    required this.formFactor,
    required this.displayName,
    required this.horizontalPaddingScale,
    required this.widgetRefreshInterval,
    required this.supportsHighRefresh,
  });
}

class DeviceCompatibilityEngine {
  static DeviceProfile? _cached;

  static Duration get widgetRefreshInterval =>
      _cached?.widgetRefreshInterval ?? const Duration(minutes: 30);

  static Future<DeviceProfile> resolve(BuildContext context) async {
    if (_cached != null) return _cached!;

    final width = MediaQuery.sizeOf(context).width;
    final formFactor = width >= 1201
        ? DeviceFormFactor.tablet
        : width >= 901
            ? DeviceFormFactor.foldable
            : DeviceFormFactor.phone;

    var brand = DeviceBrandFamily.universal;
    var displayName = 'Android device';

    if (Platform.isAndroid) {
      final android = await DeviceInfoPlugin().androidInfo;
      displayName = '${android.manufacturer} ${android.model}'.trim();
      final m = android.manufacturer.toLowerCase();
      final model = android.model.toLowerCase();

      if (m.contains('samsung')) {
        brand = DeviceBrandFamily.samsung;
      } else if (m.contains('google')) {
        brand = DeviceBrandFamily.google;
      } else if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
        brand = DeviceBrandFamily.xiaomi;
      } else if (m.contains('motorola')) {
        brand = DeviceBrandFamily.motorola;
      } else if (m.contains('oneplus')) {
        brand = DeviceBrandFamily.oneplus;
      } else if (m.contains('sony')) {
        brand = DeviceBrandFamily.sony;
      } else if (m.contains('asus')) {
        brand = DeviceBrandFamily.asus;
      } else if (m.contains('huawei') || m.contains('honor')) {
        brand = DeviceBrandFamily.huawei;
      }

      if (model.contains('fold') || model.contains('flip')) {
        // keep foldable form factor from width
      }
    }

    _cached = DeviceProfile(
      brandFamily: brand,
      formFactor: formFactor,
      displayName: displayName,
      horizontalPaddingScale: formFactor == DeviceFormFactor.phone ? 1.0 : 1.15,
      widgetRefreshInterval: const Duration(minutes: 30),
      supportsHighRefresh: brand == DeviceBrandFamily.samsung ||
          brand == DeviceBrandFamily.oneplus ||
          brand == DeviceBrandFamily.asus,
    );
    return _cached!;
  }
}

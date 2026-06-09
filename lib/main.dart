import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/app/app.dart';
import 'package:hone_mobile/core/services/gaming_hub_widget_service.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/services/settings_service.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

/// Hone Mobile / Gaming Hub Ultimate entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  await GamingHubStorage.initialize();
  await SettingsService.initialize();
  await PerformanceMonitorService.initialize();
  await GamingWidgetService.initialize();

  runApp(
    const ProviderScope(
      child: HoneMobileApp(),
    ),
  );
}

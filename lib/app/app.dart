import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/locale_provider.dart';
import 'package:hone_mobile/core/navigation/app_router.dart';
import 'package:hone_mobile/core/navigation/navigation_service.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';

class HoneMobileApp extends ConsumerStatefulWidget {
  const HoneMobileApp({super.key});

  @override
  ConsumerState<HoneMobileApp> createState() => _HoneMobileAppState();
}

class _HoneMobileAppState extends ConsumerState<HoneMobileApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (!PerformanceMonitorService.isMonitoring) {
          PerformanceMonitorService.startMonitoring();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (PerformanceMonitorService.isMonitoring) {
          PerformanceMonitorService.stopMonitoring();
        }
        break;
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    PerformanceMonitorService.stopMonitoring();
  }

  Future<void> _initializeApp() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Size _designSize(double width) {
    if (width >= 1201) return const Size(1440, 900);
    if (width >= 901) return const Size(800, 1280);
    if (width >= 721) return const Size(412, 915);
    if (width >= 481) return const Size(375, 812);
    return const Size(360, 800);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final designSize = _designSize(constraints.maxWidth);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Gaming Hub Ultimate',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              locale: locale,
              supportedLocales: LocaleNotifier.supported,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.config(
                navigationService: NavigationService(),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/providers/startup_provider.dart';
import 'package:hone_mobile/core/services/startup_service.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

/// Premium startup screen with animations and progress tracking
/// Provides immediate UI feedback while services initialize in background
/// Optimized for instant first-frame rendering
class StartupPage extends ConsumerStatefulWidget {
  const StartupPage({super.key});

  @override
  ConsumerState<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends ConsumerState<StartupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation - optimized for instant first frame
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced from 800ms
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Start animation immediately
    _logoController.forward();

    // Trigger startup initialization immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(startupInitializerProvider);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(startupStateProvider);
    final isSafeMode = ref.watch(safeModeProvider);
    final isLowMemoryMode = ref.watch(lowMemoryModeProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkSurface,
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Opacity(
                        opacity: _logoAnimation.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 60.h),

                // Progress section
                _buildProgressSection(startupState),

                SizedBox(height: 40.h),

                // Safe mode warning
                if (isSafeMode) _buildSafeModeWarning(),

                // Low memory mode warning
                if (isLowMemoryMode) _buildLowMemoryWarning(),

                SizedBox(height: 40.h),

                // Version info
                _buildVersionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Hone logo placeholder (replace with actual logo)
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppTheme.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'H',
              style: TextStyle(
                fontSize: 60.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'HONE',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Mobile Optimization',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(AsyncValue<StartupState> startupState) {
    return startupState.when(
      data: (state) {
        return Column(
          children: [
            // Current service name
            if (state.currentService != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  _getServiceMessage(state.currentService!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(height: 32.h),

            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: state.progress / 100,
                  backgroundColor: AppTheme.darkSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  minHeight: 4.h,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Progress percentage
            Text(
              '${state.progress.toInt()}%',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(), // No loading spinner for instant first frame
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildSafeModeWarning() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Running in Safe Mode - Some features may be limited',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
        SizedBox(height: 16.h),
        Text(
          'Startup Error',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'App will continue in limited mode',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLowMemoryWarning() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.memory, color: Colors.blue, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Running in low-memory mode - Some features reduced',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 1.0.0',
      style: TextStyle(
        fontSize: 12.sp,
        color: AppTheme.textTertiary,
      ),
    );
  }

  String _getServiceMessage(String serviceName) {
    switch (serviceName) {
      case 'Settings':
        return 'Loading user preferences...';
      case 'Notifications':
        return 'Setting up notifications...';
      case 'Performance Monitor':
        return 'Initializing performance tracking...';
      case 'Optimization':
        return 'Configuring optimization engine...';
      case 'Game Database':
        return 'Loading gaming systems...';
      case 'Advanced Storage':
        return 'Analyzing storage...';
      case 'Scheduled Optimization':
        return 'Setting up background tasks...';
      case 'Manufacturer Integration':
        return 'Configuring device optimizations...';
      case 'Root Service':
        return 'Checking root access...';
      case 'Overlay Service':
        return 'Preparing overlays...';
      case 'AI Recommendation':
        return 'Loading AI systems...';
      default:
        return 'Initializing $serviceName...';
    }
  }
}

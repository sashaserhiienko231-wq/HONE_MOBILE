import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/widgets/premium_animations/animated_metric.dart';

class SystemStatsWidget extends ConsumerWidget {
  final PerformanceStats stats;

  const SystemStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(animationSettingsProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardDark, AppTheme.surfaceDark],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppTheme.neonGreen, size: 24.w),
              SizedBox(width: 12.w),
              Text(
                'System Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          _buildStatItem('CPU Usage', stats.cpuUsage, stats.cpuUsage,
              Icons.memory, _getCpuColor(stats.cpuUsage), settings,
              suffix: '%', fractionDigits: 1),
          SizedBox(height: 16.h),
          _buildStatItem('Memory Usage', stats.memoryUsage, stats.memoryUsage,
              Icons.sd_card, _getMemoryColor(stats.memoryUsage), settings,
              suffix: '%', fractionDigits: 1),
          SizedBox(height: 16.h),
          _buildStatItem('GPU Usage', stats.gpuUsage, stats.gpuUsage,
              Icons.graphic_eq, _getGpuColor(stats.gpuUsage), settings,
              suffix: '%', fractionDigits: 1),
          SizedBox(height: 16.h),
          _buildStatItem('Battery Level', stats.batteryLevel.toDouble(),
              stats.batteryLevel.toDouble(), Icons.battery_full,
              _getBatteryColor(stats.batteryLevel), settings,
              suffix: '%', fractionDigits: 0),
          SizedBox(height: 16.h),
          _buildStatItem(
              'Network Latency',
              stats.networkLatency,
              (100 - (stats.networkLatency / 2)).clamp(0.0, 100.0),
              Icons.network_check,
              _getNetworkColor(stats.networkLatency),
              settings,
              suffix: 'ms',
              fractionDigits: 0),
          SizedBox(height: 16.h),
          _buildStatItem(
              'Frame Rate',
              stats.fps,
              ((stats.fps / 144) * 100).clamp(0.0, 100.0),
              Icons.speed,
              _getFpsColor(stats.fps),
              settings,
              suffix: ' FPS',
              fractionDigits: 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    double rawValue,
    double percentage,
    IconData icon,
    Color color,
    AnimationSettings settings, {
    String suffix = '',
    int fractionDigits = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            AnimatedMetric(
              value: rawValue,
              settings: settings,
              fractionDigits: fractionDigits,
              suffix: suffix,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        AnimatedProgressBar(
          fraction: (percentage / 100).clamp(0.0, 1.0),
          color: color,
          settings: settings,
          height: 6.h,
          borderRadius: 3.r,
          background: AppTheme.surfaceDark,
        ),
      ],
    );
  }

  Color _getCpuColor(double usage) {
    if (usage > 80) return AppTheme.accentRed;
    if (usage > 60) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  Color _getMemoryColor(double usage) {
    if (usage > 85) return AppTheme.accentRed;
    if (usage > 70) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  Color _getGpuColor(double usage) {
    if (usage > 80) return AppTheme.accentRed;
    if (usage > 60) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  Color _getBatteryColor(int level) {
    if (level < 20) return AppTheme.accentRed;
    if (level < 50) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  Color _getNetworkColor(double latency) {
    if (latency > 100) return AppTheme.accentRed;
    if (latency > 60) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  Color _getFpsColor(double fps) {
    if (fps < 30) return AppTheme.accentRed;
    if (fps < 45) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }
}

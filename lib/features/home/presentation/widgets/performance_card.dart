import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';

class PerformanceCard extends ConsumerWidget {
  final PerformanceStats stats;

  const PerformanceCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(animationSettingsProvider);
    final score = stats.performanceScore;
    final grade = stats.performanceGrade;

    Color gradeColor;
    IconData gradeIcon;

    if (score >= 90) {
      gradeColor = AppTheme.neonGreen;
      gradeIcon = Icons.trending_up;
    } else if (score >= 70) {
      gradeColor = AppTheme.neonBlue;
      gradeIcon = Icons.trending_flat;
    } else if (score >= 50) {
      gradeColor = AppTheme.neonOrange;
      gradeIcon = Icons.trending_down;
    } else {
      gradeColor = AppTheme.accentRed;
      gradeIcon = Icons.warning;
    }

    final animEnabled = settings.enabled && !settings.reduceMotion;
    final dur = animEnabled
        ? (settings.premiumMode ? AnimationPresets.premium : AnimationPresets.normal)
        : Duration.zero;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardDark, AppTheme.surfaceDark],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(gradeIcon, color: gradeColor, size: 24.w),
              SizedBox(width: 12.w),
              Text(
                'Performance Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: gradeColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    color: gradeColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Score Display
          Row(
            children: [
              // Animated circular progress
              SizedBox(
                width: 80.w,
                height: 80.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.surfaceDark,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.surfaceDark),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: score / 100),
                      duration: dur,
                      curve: AnimationPresets.easeOutCubic,
                      builder: (_, v, __) => CircularProgressIndicator(
                        value: v,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: score),
                      duration: dur,
                      curve: AnimationPresets.easeOutCubic,
                      builder: (_, v, __) => Text(
                        v.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 20.w),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      'CPU',
                      stats.cpuUsage,
                      '%',
                      1,
                      stats.isCPUHigh ? AppTheme.accentRed : AppTheme.neonGreen,
                      dur,
                    ),
                    SizedBox(height: 8.h),
                    _buildStatRow(
                      'RAM',
                      stats.memoryUsage,
                      '%',
                      1,
                      stats.isMemoryHigh ? AppTheme.accentRed : AppTheme.neonGreen,
                      dur,
                    ),
                    SizedBox(height: 8.h),
                    _buildStatRow(
                      'FPS',
                      stats.fps,
                      '',
                      0,
                      stats.isFPSLow ? AppTheme.accentRed : AppTheme.neonGreen,
                      dur,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildIndicator('CPU', stats.cpuStatus, stats.isCPUHigh),
              _buildIndicator('RAM', stats.memoryStatus, stats.isMemoryHigh),
              _buildIndicator('FPS', stats.fpsStatus, stats.isFPSLow),
              _buildIndicator('Temp', stats.thermalStatus, stats.isThermalHot),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, double value, String suffix, int digits, Color color, Duration dur) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
        const Spacer(),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: dur,
          curve: AnimationPresets.easeOutCubic,
          builder: (_, v, __) => Text(
            '${v.toStringAsFixed(digits)}$suffix',
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, String status, bool isWarning) {
    return SizedBox(
      width: 72.w,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isWarning
              ? AppTheme.accentRed.withValues(alpha: 0.2)
              : AppTheme.neonGreen.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isWarning
                ? AppTheme.accentRed.withValues(alpha: 0.5)
                : AppTheme.neonGreen.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              status,
              style: TextStyle(
                color: isWarning ? AppTheme.accentRed : AppTheme.neonGreen,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

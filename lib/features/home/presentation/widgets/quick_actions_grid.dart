import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';

class QuickActionsGrid extends ConsumerWidget {
  final bool isOptimizing;
  final VoidCallback onOptimizeAll;

  const QuickActionsGrid({
    super.key,
    required this.isOptimizing,
    required this.onOptimizeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GradientButton(
          text: isOptimizing ? 'Optimizing...' : 'Optimize All',
          onPressed: isOptimizing ? null : onOptimizeAll,
          startColor: AppTheme.neonGreen,
          endColor: AppTheme.neonBlue,
          height: 60.h,
          isLoading: isOptimizing,
          child: isOptimizing
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppTheme.primaryDark,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Optimize All',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
        ),
        
        SizedBox(height: 20.h),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.2,
          children: [
            _QuickActionCard(
              icon: Icons.memory,
              label: 'RAM Boost',
              color: AppTheme.neonBlue,
              onTap: () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.ram),
            ),
            _QuickActionCard(
              icon: Icons.delete_sweep,
              label: 'Clean Cache',
              color: AppTheme.neonOrange,
              onTap: () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.cache),
            ),
            _QuickActionCard(
              icon: Icons.battery_charging_full,
              label: 'Battery Saver',
              color: AppTheme.accentGreen,
              onTap: () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.battery),
            ),
            _QuickActionCard(
              icon: Icons.ac_unit,
              label: 'Cool Down',
              color: AppTheme.neonBlue,
              onTap: () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.thermal),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardDark,
              AppTheme.surfaceDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.w,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
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

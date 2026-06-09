import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class OptimizationSummaryWidget extends StatelessWidget {
  const OptimizationSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDark,
            AppTheme.surfaceDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.neonPurple.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.neonPurple,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Recent Optimizations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to optimization history
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Recent Optimizations List
          _buildOptimizationItem(
            'Full System Optimization',
            'Completed successfully',
            '2 minutes ago',
            AppTheme.neonGreen,
            Icons.check_circle,
          ),
          
          SizedBox(height: 16.h),
          
          _buildOptimizationItem(
            'RAM Clean',
            'Freed 1.2 GB of memory',
            '1 hour ago',
            AppTheme.neonBlue,
            Icons.memory,
          ),
          
          SizedBox(height: 16.h),
          
          _buildOptimizationItem(
            'Cache Cleaning',
            'Removed 456 MB of cache',
            '3 hours ago',
            AppTheme.neonOrange,
            Icons.delete_sweep,
          ),
          
          SizedBox(height: 16.h),
          
          _buildOptimizationItem(
            'Battery Optimization',
            'Extended battery life by 12%',
            '5 hours ago',
            AppTheme.accentGreen,
            Icons.battery_charging_full,
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationItem(
    String title,
    String description,
    String time,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';

class OptimizationsPage extends ConsumerWidget {
  const OptimizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optimizationState = ref.watch(optimizationProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.secondaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Optimization Center',
                subtitle: 'Deep tuning for maximum efficiency',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildMainCard(ref, optimizationState.isLoading),
                      SizedBox(height: 24.h),
                      _buildOptimizationList(ref),
                      SizedBox(height: 24.h),
                      _buildHistorySection(optimizationState.value ?? []),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(WidgetRef ref, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.neonGreen.withValues(alpha: 0.2), AppTheme.neonBlue.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, color: AppTheme.neonGreen, size: 32.w),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Tune System', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Text('Full stack optimization engine', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => ref.read(optimizationProvider.notifier).runFullOptimization(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(isLoading ? 'OPTIMIZING...' : 'START FULL OPTIMIZATION', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationList(WidgetRef ref) {
    return Column(
      children: [
        _buildOptItem(ref, 'RAM Management', 'Clean unused memory blocks', Icons.memory, AppTheme.neonBlue, OptimizationType.ram),
        _buildOptItem(ref, 'Cache Scrubber', 'Deep file system cleanup', Icons.storage, AppTheme.neonOrange, OptimizationType.cache),
        _buildOptItem(ref, 'Battery Profiles', 'Efficiency engine tuning', Icons.battery_saver, AppTheme.neonPurple, OptimizationType.battery),
        _buildOptItem(ref, 'Network Stack', 'DNS and latency tuning', Icons.network_ping, AppTheme.neonGreen, OptimizationType.network),
      ],
    );
  }

  Widget _buildOptItem(WidgetRef ref, String title, String subtitle, IconData icon, Color color, OptimizationType type) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(optimizationProvider.notifier).runSingleOptimization(type),
            icon: Icon(Icons.play_arrow_rounded, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<OptimizationResult> results) {
    if (results.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Results',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length.clamp(0, 5),
          itemBuilder: (context, index) {
            final res = results[results.length - 1 - index];
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(res.success ? Icons.check_circle : Icons.error, color: res.success ? AppTheme.neonGreen : AppTheme.accentRed, size: 14.w),
                  SizedBox(width: 8.w),
                  Text(res.typeDisplayName, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                  const Spacer(),
                  Text(res.message, style: TextStyle(color: Colors.white38, fontSize: 10.sp)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

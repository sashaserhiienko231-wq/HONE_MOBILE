import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/navigation/responsive_layout.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class BoostPage extends ConsumerStatefulWidget {
  const BoostPage({super.key});

  @override
  ConsumerState<BoostPage> createState() => _BoostPageState();
}

class _BoostPageState extends ConsumerState<BoostPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isBoosting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startBoost() async {
    setState(() => _isBoosting = true);
    
    try {
      await ref.read(optimizationProvider.notifier).runFullOptimization();
      final results = ref.read(optimizationProvider).value ?? [];
      _showBoostResults(results);
    } finally {
      if (mounted) setState(() => _isBoosting = false);
    }
  }

  void _showBoostResults(List<OptimizationResult> results) {
    final l10n = AppLocalizations.of(context);
    final successCount = results.where((r) => r.success).length;
    final totalOptimizations = results.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          l10n.systemBoosted,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: AppTheme.neonGreen,
                  size: 48.w,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Full optimization cycle complete. $successCount/$totalOptimizations tasks successful.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 24.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white10, height: 1.h),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            result.success ? Icons.check_circle : Icons.error_outline,
                            color: result.success ? AppTheme.neonGreen : AppTheme.accentRed,
                            size: 18.w,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              result.typeDisplayName,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp),
                            ),
                          ),
                          if (result.success)
                            Text(
                              'Optimized',
                              style: TextStyle(color: AppTheme.neonGreen.withValues(alpha: 0.7), fontSize: 12.sp),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          GradientButton(
            text: l10n.finish,
            onPressed: () => Navigator.of(context).pop(),
            width: 120.w,
            height: 44.h,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final buttonSize = isTablet ? 180.0 : 220.w;

    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.secondaryDark,
              AppTheme.surfaceDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: l10n.boostPageTitle,
                subtitle: l10n.boostPageSubtitle,
                applySafeArea: false,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 40 : 60.h),
                      
                      // Adaptive Boost Button
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isBoosting ? 0.95 : _pulseAnimation.value,
                              child: GestureDetector(
                                onTap: _isBoosting ? null : _startBoost,
                                child: Container(
                                  width: buttonSize,
                                  height: buttonSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _isBoosting
                                          ? [Colors.grey.shade800, Colors.grey.shade900]
                                          : [AppTheme.neonGreen, AppTheme.neonBlue],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isBoosting ? Colors.black : AppTheme.neonGreen).withValues(alpha: 0.4),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                      if (!_isBoosting)
                                        BoxShadow(
                                          color: AppTheme.neonBlue.withValues(alpha: 0.2),
                                          blurRadius: 60,
                                          spreadRadius: 10,
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isBoosting)
                                        SizedBox(
                                          width: 60.w,
                                          height: 60.w,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 4,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.rocket_launch,
                                          color: AppTheme.primaryDark,
                                          size: isTablet ? 64 : 80.w,
                                        ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        _isBoosting ? 'TUNING...' : 'BOOST',
                                        style: TextStyle(
                                          color: _isBoosting ? Colors.white : AppTheme.primaryDark,
                                          fontSize: isTablet ? 20 : 24.sp,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 60 : 80.h),
                      
                      // Optimization Status Cards
                      _buildInfoPanel(isTablet),
                      
                      SizedBox(height: 24.h),
                      
                      _buildQuickControls(isTablet),
                      
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoPanel(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENGINE STATUS',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 20.h),
          _buildStatusRow('RAM Optimization', 'Active Path Scanning', Icons.memory, AppTheme.neonBlue),
          _buildStatusRow('Disk Cache', 'Deep File Scrubbing', Icons.cleaning_services, AppTheme.neonOrange),
          _buildStatusRow('Thermal Logic', 'Adaptive Load Balancing', Icons.thermostat, AppTheme.accentRed),
          _buildStatusRow(
            'Network Stack',
            'DNS Response Tuning',
            Icons.wifi_tethering,
            AppTheme.neonPurple,
            onTap: () => context.push('/dns_boost'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, String status, IconData icon, Color color, {VoidCallback? onTap}) {
    final rowContent = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12.w),
            ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppTheme.neonGreen, shape: BoxShape.circle),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: rowContent,
      );
    }
    return rowContent;
  }

  Widget _buildQuickControls(bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.3,
      children: [
        _quickCard('CLEAN', Icons.delete_sweep, AppTheme.neonOrange, () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.cache)),
        _quickCard('COOL', Icons.ac_unit, AppTheme.neonBlue, () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.thermal)),
        _quickCard('SPEED', Icons.bolt, AppTheme.neonGreen, () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.ram)),
        _quickCard('PINGS', Icons.network_check, AppTheme.neonPurple, () => ref.read(optimizationProvider.notifier).runSingleOptimization(OptimizationType.network)),
      ],
    );
  }

  Widget _quickCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.w),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

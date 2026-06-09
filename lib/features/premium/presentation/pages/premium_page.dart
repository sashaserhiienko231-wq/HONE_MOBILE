import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Hone Premium',
                subtitle: 'Unlock elite system performance',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      SizedBox(height: 32.h),
                      _buildFeaturesGrid(),
                      SizedBox(height: 40.h),
                      _buildPricingCard(context),
                      SizedBox(height: 40.h),
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

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.neonPurple.withValues(alpha: 0.1), AppTheme.neonBlue.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.diamond, color: AppTheme.neonPurple, size: 64.w),
          SizedBox(height: 16.h),
          Text(
            'GO ENTERPRISE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The ultimate optimization suite for professional gamers and power users.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      children: [
        _buildFeatureItem('Ultra-Low Latency DNS', 'Global edge network for minimal ping', Icons.public, AppTheme.neonBlue),
        _buildFeatureItem('Kernel-Level Optimization', 'Advanced process priority management', Icons.settings_input_component, AppTheme.neonGreen),
        _buildFeatureItem('Zero Background Noise', 'Deep cleanup of all system bloatware', Icons.volume_off, AppTheme.accentRed),
        _buildFeatureItem('Advanced Analytics', 'Detailed performance history and reports', Icons.insights, AppTheme.neonPurple),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(color: AppTheme.neonGreen.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: -10),
        ],
      ),
      child: Column(
        children: [
          const Text('MONTHLY ACCESS', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, letterSpacing: 2)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
              Text('9.99', style: TextStyle(color: Colors.white, fontSize: 48.sp, fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: Text('/mo', style: TextStyle(color: Colors.white54, fontSize: 16.sp)),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          GradientButton(
            text: 'UPGRADE NOW',
            onPressed: () {
              // TODO: Implement checkout
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Cancel anytime. 7-day free trial included.',
            style: TextStyle(color: Colors.white38, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

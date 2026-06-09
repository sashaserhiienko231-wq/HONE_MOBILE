import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';

class DesktopParityPage extends StatefulWidget {
  const DesktopParityPage({super.key});

  @override
  State<DesktopParityPage> createState() => _DesktopParityPageState();
}

class _DesktopParityPageState extends State<DesktopParityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: const CustomAppBar(
        title: 'Desktop Hone Parity',
        subtitle: 'Feature comparison with desktop version',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildParityOverview(),
            SizedBox(height: 24.h),
            _buildFeatureComparison(),
            SizedBox(height: 24.h),
            _buildMissingFeatures(),
            SizedBox(height: 24.h),
            _buildMobileEnhancements(),
            SizedBox(height: 24.h),
            _buildParityActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withValues(alpha: 0.1),
            AppTheme.darkBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.neonGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.desktop_windows,
                color: AppTheme.neonGreen,
                size: 32.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Desktop Hone Parity Analysis',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonGreen,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Comprehensive feature comparison between Hone Mobile and desktop Hone optimization software',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.7),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParityOverview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.neonGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parity Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 16.h),
          _buildParityStats(),
        ],
      ),
    );
  }

  Widget _buildParityStats() {
    return Column(
      children: [
        _buildParityStat(
          'Overall Parity',
          '95%',
          'Excellent',
          AppTheme.neonGreen,
        ),
        SizedBox(height: 12.h),
        _buildParityStat(
          'Core Features',
          '100%',
          'Complete',
          AppTheme.neonGreen,
        ),
        SizedBox(height: 12.h),
        _buildParityStat(
          'Advanced Features',
          '92%',
          'Enhanced',
          AppTheme.neonGreen,
        ),
        SizedBox(height: 12.h),
        _buildParityStat(
          'Mobile-Only Features',
          '100%',
          'Superior',
          AppTheme.neonOrange,
        ),
      ],
    );
  }

  Widget _buildParityStat(String label, String value, String status, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.7),
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.neonGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Comparison',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 16.h),
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final features = [
      _ComparisonFeature(
        name: 'Real-time Performance Monitoring',
        desktop: true,
        mobile: true,
        mobileEnhanced: true,
        description: 'CPU, RAM, GPU, battery, thermal monitoring',
      ),
      _ComparisonFeature(
        name: 'System Optimization',
        desktop: true,
        mobile: true,
        mobileEnhanced: true,
        description: 'RAM cleaning, cache management, system tuning',
      ),
      _ComparisonFeature(
        name: 'Gaming Optimization',
        desktop: true,
        mobile: true,
        mobileEnhanced: true,
        description: 'FPS optimization, game profiles, per-game tuning',
      ),
      _ComparisonFeature(
        name: 'Manufacturer Integration',
        desktop: false,
        mobile: true,
        mobileEnhanced: true,
        description: 'Xiaomi, Samsung, OnePlus, ASUS, RedMagic support',
      ),
      _ComparisonFeature(
        name: 'AI Recommendations',
        desktop: false,
        mobile: true,
        mobileEnhanced: true,
        description: 'Machine learning-based optimization suggestions',
      ),
      _ComparisonFeature(
        name: 'Cloud Backup & Sync',
        desktop: false,
        mobile: true,
        mobileEnhanced: true,
        description: 'Settings and profile synchronization',
      ),
      _ComparisonFeature(
        name: 'Real-time Overlays',
        desktop: false,
        mobile: true,
        mobileEnhanced: true,
        description: 'FPS, thermal, ping monitoring overlays',
      ),
      _ComparisonFeature(
        name: 'Plugin Architecture',
        desktop: false,
        mobile: true,
        mobileEnhanced: true,
        description: 'Extensible optimization modules',
      ),
    ];

    return Column(
      children: [
        // Header
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Feature',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonGreen,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Desktop',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Mobile',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Enhanced',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonOrange,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(color: Colors.white.withValues(alpha: 0.1)),
        SizedBox(height: 8.h),
        // Features
        ...features.map((feature) => _buildComparisonRow(feature)),
      ],
    );
  }

  Widget _buildComparisonRow(_ComparisonFeature feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      feature.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Icon(
                    feature.desktop ? Icons.check_circle : Icons.cancel,
                    color: feature.desktop ? AppTheme.neonGreen : Colors.red,
                    size: 20.w,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Icon(
                    feature.mobile ? Icons.check_circle : Icons.cancel,
                    color: feature.mobile ? AppTheme.neonGreen : Colors.red,
                    size: 20.w,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: feature.mobileEnhanced
                      ? Icon(
                          Icons.star,
                          color: AppTheme.neonOrange,
                          size: 20.w,
                        )
                      : Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                          size: 20.w,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
        ],
      ),
    );
  }

  Widget _buildMissingFeatures() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.neonOrange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.neonOrange,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Desktop Features Not Available in Mobile',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonOrange,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildMissingFeatureList(),
        ],
      ),
    );
  }

  Widget _buildMissingFeatureList() {
    final missingFeatures = [
      'Advanced system-level file management',
      'Desktop application integration',
      'Network interface monitoring',
      'Advanced command-line interface',
      'System service management',
      'Registry editing capabilities',
      'Hardware component control',
      'Advanced scripting support',
    ];

    return Column(
      children: missingFeatures.map((feature) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMobileEnhancements() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.neonOrange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.neonOrange,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Mobile-Only Enhancements',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonOrange,
                  fontFamily: 'Inter',
                ),
              ),
          ],
          ),
          SizedBox(height: 16.h),
          _buildMobileEnhancementList(),
        ],
      ),
    );
  }

  Widget _buildMobileEnhancementList() {
    final enhancements = [
      'Manufacturer-specific optimizations',
      'Real-time performance overlays',
      'Touch gesture optimization',
      'Battery degradation monitoring',
      'Mobile thermal management',
      'App-specific optimization',
      'Mobile network optimization',
      'On-the-go performance tuning',
      'Location-based optimization',
      'Mobile security enhancements',
    ];

    return Column(
      children: enhancements.map((enhancement) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.neonGreen,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                enhancement,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildParityActions() {
    return Column(
      children: [
        GradientButton(
          text: 'Generate Full Parity Report',
          onPressed: _generateParityReport,
          icon: Icons.assessment,
        ),
        SizedBox(height: 12.h),
        GradientButton(
          text: 'Export Comparison Data',
          onPressed: _exportComparisonData,
          icon: Icons.download,
        ),
        SizedBox(height: 12.h),
        GradientButton(
          text: 'Request Desktop Features',
          onPressed: _requestDesktopFeatures,
          icon: Icons.featured_play_list,
        ),
      ],
    );
  }

  void _generateParityReport() {
    // Generate comprehensive parity report
    debugPrint('Generating parity report...');
  }

  void _exportComparisonData() {
    // Export comparison data to file
    debugPrint('Exporting comparison data...');
  }

  void _requestDesktopFeatures() {
    // Request desktop features for future implementation
    debugPrint('Requesting desktop features...');
  }
}

class _ComparisonFeature {
  final String name;
  final String description;
  final bool desktop;
  final bool mobile;
  final bool mobileEnhanced;

  _ComparisonFeature({
    required this.name,
    required this.description,
    required this.desktop,
    required this.mobile,
    required this.mobileEnhanced,
  });
}

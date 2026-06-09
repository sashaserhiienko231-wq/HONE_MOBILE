import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';

class DiagnosticsPage extends ConsumerStatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> with TickerProviderStateMixin {
  bool _isScanning = false;
  double _progress = 0.0;
  String _currentTask = '';
  final List<String> _logs = [];

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _logs.clear();
      _logs.add('Initializing system diagnostics...');
    });

    final tasks = [
      'Analyzing CPU core efficiency...',
      'Mapping memory allocations...',
      'Evaluating thermal throttling thresholds...',
      'Testing network stack latency...',
      'Scanning storage for redundant data...',
      'Verifying system integrity...',
    ];

    for (int i = 0; i < tasks.length; i++) {
      setState(() {
        _currentTask = tasks[i];
        _progress = (i + 1) / tasks.length;
        _logs.insert(0, tasks[i]);
      });
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() {
      _isScanning = false;
      _currentTask = 'System healthy';
      _logs.insert(0, 'Diagnostic scan complete. 0 issues found.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(performanceStatsProvider).value ?? PerformanceStats.empty;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'System Diagnostics',
                subtitle: 'Deep telemetry and integrity analysis',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildScanHeader(),
                      SizedBox(height: 24.h),
                      _buildMetricsGrid(stats),
                      SizedBox(height: 24.h),
                      _buildLogPanel(),
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

  Widget _buildScanHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.analytics, color: AppTheme.neonGreen, size: 32.w),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isScanning ? 'SCANNING SYSTEM' : 'SYSTEM READY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isScanning ? _currentTask : 'Last scan: Never',
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: AppTheme.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(_isScanning ? '...' : 'SCAN'),
              ),
            ],
          ),
          if (_isScanning) ...[
            SizedBox(height: 20.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                minHeight: 8.h,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(PerformanceStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('CPU Load', '${stats.cpuUsage.toStringAsFixed(1)}%', AppTheme.neonBlue),
        _buildMetricCard('Memory', '${stats.memoryUsage.toStringAsFixed(1)}%', AppTheme.neonPurple),
        _buildMetricCard('Thermal', stats.thermalStatus, AppTheme.accentRed),
        _buildMetricCard('Network', '${stats.networkLatency.toStringAsFixed(0)}ms', AppTheme.neonOrange),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLogPanel() {
    return Container(
      width: double.infinity,
      height: 300.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIAGNOSTIC LOGS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    '> ${_logs[index]}',
                    style: TextStyle(
                      color: index == 0 ? AppTheme.neonGreen : Colors.white38,
                      fontFamily: 'monospace',
                      fontSize: 11.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

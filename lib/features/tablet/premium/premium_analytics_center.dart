import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';

class PremiumAnalyticsCenter extends ConsumerWidget {
  const PremiumAnalyticsCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(performanceStatsProvider).value ?? PerformanceStats.empty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildAICard(ref, stats),
                        const SizedBox(height: 32),
                        _buildAnalyticsGrid(stats),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: _buildPremiumToolbox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Premium Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.verified, color: AppTheme.neonGreen, size: 32),
              ],
            ),
            Text(
              'Enterprise-grade analytics and AI optimization engine',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.stars),
          label: const Text('MANAGE PRO SUBSCRIPTION'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonGreen,
            foregroundColor: AppTheme.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildAICard(WidgetRef ref, PerformanceStats stats) {
    final isOptimizing = ref.watch(optimizationProvider).isLoading;
    final recommendation = stats.isCPUHigh 
        ? 'High CPU load detected. Restricting background processes recommended.'
        : 'System is stable. Ready for high-performance gaming sessions.';

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.neonPurple.withValues(alpha: 0.8), AppTheme.neonBlue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'AI INSIGHT ENGINE',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Optimization Opportunity',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Text(
                  recommendation,
                  style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isOptimizing ? null : () => ref.read(optimizationProvider.notifier).runFullOptimization(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.neonPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(isOptimizing ? 'ANALYZING...' : 'APPLY AI TWEAKS', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 160),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid(PerformanceStats stats) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 2.5,
        children: [
          _buildSummaryItem('Optimization Score', '${stats.performanceScore.toInt()}%', Icons.bolt, AppTheme.neonGreen),
          _buildSummaryItem('Memory Efficiency', '${(100 - stats.memoryUsage).toInt()}%', Icons.memory, AppTheme.neonBlue),
          _buildSummaryItem('Network Stability', '99.8%', Icons.wifi_tethering, AppTheme.neonPurple),
          _buildSummaryItem('Thermal Status', stats.thermalStatus, Icons.thermostat, AppTheme.neonOrange),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumToolbox() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enterprise Suite', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildToolItem('Export Analytics', 'Detailed PDF performance logs', Icons.description),
          _buildToolItem('Cloud Sync', 'Global preset synchronization', Icons.cloud_sync),
          _buildToolItem('Kernel Auditor', 'Hardware level control', Icons.developer_board),
          _buildToolItem('Secure Sandbox', 'Isolated gaming environment', Icons.shield),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppTheme.neonGreen, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Enterprise encryption active. Your data is secure.',
                    style: TextStyle(color: AppTheme.neonGreen, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 16),
          ],
        ),
      ),
    );
  }
}

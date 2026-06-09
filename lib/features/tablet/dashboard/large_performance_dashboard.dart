import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:fl_chart/fl_chart.dart';

class LargePerformanceDashboard extends ConsumerWidget {
  const LargePerformanceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(performanceStatsProvider);
    final stats = statsAsync.value ?? PerformanceStats.empty;
    final historicalStats = ref.watch(historicalStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: 24),
            Expanded(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildMainStatsGrid(stats),
                              const SizedBox(height: 24),
                              Expanded(child: _buildRealTimeGraphs(historicalStats)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildThermalPanel(stats),
                              const SizedBox(height: 24),
                              _buildBatteryPanel(stats),
                              const SizedBox(height: 24),
                              Expanded(child: _buildSystemAlerts(stats)),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMainStatsGrid(stats),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 400,
                            child: _buildRealTimeGraphs(historicalStats),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildThermalPanel(stats)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildBatteryPanel(stats)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: _buildSystemAlerts(stats),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isOptimizing = ref.watch(optimizationProvider).isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enterprise Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Real-time system telemetry and performance analysis',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderButton(Icons.refresh, 'Refresh', () {}),
            const SizedBox(width: 12),
            _buildHeaderButton(Icons.download, 'Export Report', () {}),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: isOptimizing ? null : () => ref.read(optimizationProvider.notifier).runFullOptimization(),
              icon: isOptimizing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDark))
                  : const Icon(Icons.bolt),
              label: Text(isOptimizing ? 'OPTIMIZING...' : 'ULTRA BOOST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildMainStatsGrid(PerformanceStats stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('CPU USAGE', '${stats.cpuUsage.toStringAsFixed(1)}%', AppTheme.neonGreen, Icons.memory, stats.cpuUsage / 100),
        _buildStatCard('RAM USAGE', '${stats.memoryUsage.toStringAsFixed(1)}%', AppTheme.neonBlue, Icons.storage, stats.memoryUsage / 100),
        _buildStatCard('FPS', stats.fps.toStringAsFixed(0), AppTheme.neonPurple, Icons.speed, stats.fps / 60),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeGraphs(List<PerformanceStats> historicalStats) {
    // Convert historical stats to fl_chart spots
    final List<FlSpot> cpuSpots = [];
    final List<FlSpot> fpsSpots = [];
    
    for (int i = 0; i < historicalStats.length; i++) {
      cpuSpots.add(FlSpot(i.toDouble(), historicalStats[i].cpuUsage));
      fpsSpots.add(FlSpot(i.toDouble(), historicalStats[i].fps));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Telemetry Stream', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildLegendItem('CPU', AppTheme.neonGreen),
                  const SizedBox(width: 16),
                  _buildLegendItem('FPS', AppTheme.neonPurple),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1)),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: cpuSpots.isEmpty ? [const FlSpot(0, 0)] : cpuSpots,
                    isCurved: true,
                    color: AppTheme.neonGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.neonGreen.withValues(alpha: 0.05)),
                  ),
                  LineChartBarData(
                    spots: fpsSpots.isEmpty ? [const FlSpot(0, 0)] : fpsSpots,
                    isCurved: true,
                    color: AppTheme.neonPurple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.neonPurple.withValues(alpha: 0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildThermalPanel(PerformanceStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Core Thermals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.thermostat, color: AppTheme.neonOrange),
            ],
          ),
          const SizedBox(height: 16),
          _buildThermalRow('SoC Pack', stats.thermalStatus, (stats.cpuUsage / 100).clamp(0.2, 0.9), stats.isThermalHot ? AppTheme.accentRed : AppTheme.neonGreen),
          _buildThermalRow('GPU Core', 'Stable', (stats.gpuUsage / 100).clamp(0.1, 0.8), AppTheme.neonBlue),
        ],
      ),
    );
  }

  Widget _buildThermalRow(String label, String value, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryPanel(PerformanceStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Energy Management', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.battery_charging_full, color: stats.isBatteryLow ? AppTheme.accentRed : AppTheme.neonGreen, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${stats.batteryLevel}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(stats.batteryStatus, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemAlerts(PerformanceStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Insights', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (stats.isCPUHigh) _buildAlertItem('High CPU load detected', AppTheme.accentRed),
          if (stats.isThermalHot) _buildAlertItem('Device temperature rising', AppTheme.neonOrange),
          if (stats.isFPSLow) _buildAlertItem('Frame drop detected', AppTheme.neonPurple),
          if (!stats.isCPUHigh && !stats.isThermalHot) _buildAlertItem('All systems nominal', AppTheme.neonGreen),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String message, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}

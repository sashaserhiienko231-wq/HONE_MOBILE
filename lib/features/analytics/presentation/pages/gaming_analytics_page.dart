import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';

class GamingAnalyticsPage extends ConsumerStatefulWidget {
  const GamingAnalyticsPage({super.key});

  @override
  ConsumerState<GamingAnalyticsPage> createState() => _GamingAnalyticsPageState();
}

class _GamingAnalyticsPageState extends ConsumerState<GamingAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _chartReveal;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _ctrl = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );
    _chartReveal = CurvedAnimation(parent: _ctrl, curve: AnimationPresets.easeOutCubic);

    if (animEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historicalStatsProvider);
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final spots = <FlSpot>[
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].fps),
    ];

    final minY = (spots.map((s) => s.y).fold<double>(double.infinity, (p, n) => n < p ? n : p) - 5)
        .clamp(0.0, double.infinity);
    final maxY = (spots.map((s) => s.y).fold<double>(0.0, (p, n) => n > p ? n : p) + 5)
        .clamp(10.0, double.infinity);

    final avgFps = history.isNotEmpty
        ? history.map((h) => h.fps).reduce((a, b) => a + b) / history.length
        : 0.0;

    final dur = animEnabled
        ? (settings.premiumMode ? AnimationPresets.premium : AnimationPresets.normal)
        : Duration.zero;

    return Scaffold(
      appBar: AppBar(title: const Text('Gaming Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Summary cards with count-up
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AnimatedSummaryTile(label: 'Avg FPS', value: avgFps, suffix: '', dur: dur),
                    _AnimatedSummaryTile(label: 'Play Time', value: 0, suffix: 'h', dur: dur),
                    _AnimatedSummaryTile(label: 'Achievements', value: 0, suffix: '', dur: dur),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Chart with animated reveal
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedBuilder(
                    animation: _chartReveal,
                    builder: (_, __) {
                      // Interpolate visible spots based on reveal progress
                      final visibleCount = animEnabled
                          ? (spots.length * _chartReveal.value).ceil().clamp(1, spots.length)
                          : spots.length;
                      final visibleSpots = spots.isEmpty
                          ? const [FlSpot(0, 0), FlSpot(1, 0)]
                          : spots.sublist(0, visibleCount.clamp(0, spots.length));

                      return Opacity(
                        opacity: _chartReveal.value,
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: spots.isNotEmpty ? spots.last.x : 6,
                            minY: minY,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: visibleSpots,
                                isCurved: true,
                                barWidth: 2,
                                color: Colors.deepPurple,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSummaryTile extends StatelessWidget {
  final String label;
  final double value;
  final String suffix;
  final Duration dur;

  const _AnimatedSummaryTile({
    required this.label,
    required this.value,
    required this.suffix,
    required this.dur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: dur,
          curve: AnimationPresets.easeOutCubic,
          builder: (_, v, __) => Text(
            value == 0 ? '?' : '${v.toStringAsFixed(0)}$suffix',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

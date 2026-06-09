import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';

class WidgetModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String type;

  WidgetModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.type,
  });
}

final widgetLayoutProvider = StateNotifierProvider<WidgetLayoutNotifier, List<WidgetModel>>((ref) {
  return WidgetLayoutNotifier();
});

class WidgetLayoutNotifier extends StateNotifier<List<WidgetModel>> {
  WidgetLayoutNotifier() : super([
    WidgetModel(id: '1', title: 'RAM Usage', icon: Icons.memory, color: AppTheme.neonBlue, type: 'ram'),
    WidgetModel(id: '2', title: 'Storage Usage', icon: Icons.storage, color: AppTheme.neonGreen, type: 'storage'),
    WidgetModel(id: '3', title: 'FPS Widget', icon: Icons.speed, color: AppTheme.neonPurple, type: 'fps'),
    WidgetModel(id: '4', title: 'CPU Widget', icon: Icons.developer_board, color: AppTheme.neonOrange, type: 'cpu'),
    WidgetModel(id: '5', title: 'Temperature', icon: Icons.thermostat, color: AppTheme.accentRed, type: 'temp'),
    WidgetModel(id: '6', title: 'Network', icon: Icons.wifi, color: AppTheme.primaryDark, type: 'network'),
    WidgetModel(id: '7', title: 'DNS Status', icon: Icons.dns, color: Colors.cyan, type: 'dns'),
  ]);

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    // In a real app, save to SharedPreferences here
  }
}

class TabletWidgetCenter extends ConsumerWidget {
  const TabletWidgetCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgets = ref.watch(widgetLayoutProvider);
    final statsAsync = ref.watch(performanceStatsProvider);
    final stats = statsAsync.value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Widget Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save, color: AppTheme.neonGreen),
            label: const Text('Layout Saved', style: TextStyle(color: AppTheme.neonGreen)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ReorderableGridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            final widgetModel = widgets[index];
            return _buildDraggableWidget(
              key: ValueKey(widgetModel.id),
              model: widgetModel,
              value: _getValueForType(widgetModel.type, stats),
            );
          },
          onReorder: (oldIndex, newIndex) {
            ref.read(widgetLayoutProvider.notifier).reorder(oldIndex, newIndex);
          },
        ),
      ),
    );
  }

  String _getValueForType(String type, dynamic stats) {
    if (stats == null) return 'Loading...';
    switch (type) {
      case 'ram': return '${stats.memoryUsage.toStringAsFixed(1)}%';
      case 'storage': return '128 GB Free';
      case 'fps': return '${stats.fps.toStringAsFixed(0)} FPS';
      case 'cpu': return '${stats.cpuUsage.toStringAsFixed(1)}%';
      case 'temp': return stats.thermalStatus;
      case 'network': return '24 ms';
      case 'dns': return 'Optimized';
      default: return 'N/A';
    }
  }

  Widget _buildDraggableWidget({required Key key, required WidgetModel model, required String value}) {
    return Card(
      key: key,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: model.color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Icon(model.icon, color: model.color, size: 24),
              ],
            ),
            Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.drag_indicator, color: Colors.white.withValues(alpha: 0.2), size: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';

class OptimizationPanel extends ConsumerStatefulWidget {
  const OptimizationPanel({super.key});

  @override
  ConsumerState<OptimizationPanel> createState() => _OptimizationPanelState();
}

class _OptimizationPanelState extends ConsumerState<OptimizationPanel> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Core Tuning', 'icon': Icons.memory, 'type': OptimizationType.ram, 'desc': 'Engine and RAM optimization'},
    {'name': 'Storage Scrub', 'icon': Icons.storage, 'type': OptimizationType.cache, 'desc': 'Cleanup of temporary files'},
    {'name': 'Thermal Logic', 'icon': Icons.thermostat, 'type': OptimizationType.thermal, 'desc': 'Heat management and throttling'},
    {'name': 'Network Stack', 'icon': Icons.network_check, 'type': OptimizationType.network, 'desc': 'Latency and ping optimization'},
    {'name': 'Energy Suite', 'icon': Icons.battery_saver, 'type': OptimizationType.battery, 'desc': 'Battery efficiency profiles'},
  ];

  @override
  Widget build(BuildContext context) {
    final optimizationState = ref.watch(optimizationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(ref),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildCategoryList(),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: _buildTuningDetail(optimizationState),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optimization Center',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Advanced enterprise tuning for maximum hardware efficiency',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(optimizationProvider.notifier).runFullOptimization(),
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('AUTO-OPTIMIZE ALL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonGreen.withValues(alpha: 0.1),
            foregroundColor: AppTheme.neonGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            side: const BorderSide(color: AppTheme.neonGreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedCategoryIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.1) : AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.1) : AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categories[index]['icon'] as IconData,
                      color: isSelected ? AppTheme.neonGreen : Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categories[index]['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        Text(
                          _categories[index]['desc'] as String,
                          style: const TextStyle(color: Colors.white30, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTuningDetail(AsyncValue<List<OptimizationResult>> state) {
    final category = _categories[_selectedCategoryIndex];
    final type = category['type'] as OptimizationType;
    final results = state.value ?? [];
    final lastResult = results.where((r) => r.type == type).lastOrNull;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configuration: ${category['name']}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (state.isLoading)
                const CircularProgressIndicator(strokeWidth: 3, color: AppTheme.neonGreen)
            ],
          ),
          const SizedBox(height: 40),
          _buildTuningOption('Force Garbage Collection', 'Manually trigger memory scrub', true),
          _buildTuningOption('Background Process Limit', 'Restrict non-essential services', true),
          _buildTuningOption('Hardware Performance Mode', 'Maximize silicon clock speed', false),
          const Spacer(),
          if (lastResult != null) _buildResultBanner(lastResult),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () => ref.read(optimizationProvider.notifier).runSingleOptimization(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              child: Text(state.isLoading ? 'PROCESSING...' : 'EXECUTE OPTIMIZATION'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTuningOption(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: (_) {}, activeThumbColor: AppTheme.neonGreen),
        ],
      ),
    );
  }

  Widget _buildResultBanner(OptimizationResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.success ? AppTheme.neonGreen.withValues(alpha: 0.05) : AppTheme.accentRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (result.success ? AppTheme.neonGreen : AppTheme.accentRed).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(result.success ? Icons.check_circle : Icons.error, color: result.success ? AppTheme.neonGreen : AppTheme.accentRed),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.success ? 'Optimization Successful' : 'Optimization Failed',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  result.message,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

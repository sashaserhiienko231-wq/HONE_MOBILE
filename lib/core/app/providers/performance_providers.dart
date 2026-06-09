import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/services/optimization_service.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';

/// Provider for the current performance stats
final performanceStatsProvider = StreamProvider<PerformanceStats>((ref) {
  if (!PerformanceMonitorService.isInitialized) {
    PerformanceMonitorService.initialize();
  }
  
  if (!PerformanceMonitorService.isMonitoring) {
    PerformanceMonitorService.startMonitoring();
  }
  
  ref.onDispose(() {
    // We might not want to stop monitoring globally if other providers use it,
    // but for now, we'll keep it simple.
  });
  
  return PerformanceMonitorService.performanceStats;
});

/// Provider for historical performance stats
final historicalStatsProvider = Provider<List<PerformanceStats>>((ref) {
  // Trigger rebuild when new stats arrive
  ref.watch(performanceStatsProvider);
  return PerformanceMonitorService.historicalStats;
});

/// State notifier for optimization processes
class OptimizationNotifier extends StateNotifier<AsyncValue<List<OptimizationResult>>> {
  OptimizationNotifier() : super(const AsyncValue.data([]));

  Future<void> runFullOptimization() async {
    state = const AsyncValue.loading();
    try {
      final results = await OptimizationService.fullSystemOptimization();
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> runSingleOptimization(OptimizationType type) async {
    // Get current results to append to
    final currentResults = state.value ?? [];
    state = const AsyncValue.loading();
    
    try {
      OptimizationResult result;
      switch (type) {
        case OptimizationType.ram:
          result = await OptimizationService.optimizeRAM();
          break;
        case OptimizationType.cache:
          result = await OptimizationService.cleanCache();
          break;
        case OptimizationType.battery:
          result = await OptimizationService.optimizeBattery();
          break;
        case OptimizationType.thermal:
          result = await OptimizationService.optimizeThermal();
          break;
        case OptimizationType.network:
          result = await OptimizationService.optimizeNetwork();
          break;
        case OptimizationType.storage:
          result = await OptimizationService.optimizeStorage();
          break;
        default:
          result = await OptimizationService.deviceSpecificOptimization();
      }
      
      state = AsyncValue.data([...currentResults, result]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final optimizationProvider = StateNotifierProvider<OptimizationNotifier, AsyncValue<List<OptimizationResult>>>((ref) {
  return OptimizationNotifier();
});

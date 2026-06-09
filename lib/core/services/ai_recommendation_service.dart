import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/models/thermal_state.dart';
import 'package:hone_mobile/core/models/ai_recommendation.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/services/manufacturer_integration_service.dart';
import 'package:battery_plus/battery_plus.dart';

class AIRecommendationService {
  static bool _isInitialized = false;
  static final StreamController<AIRecommendation> _recommendationController = StreamController.broadcast();
  static Timer? _analysisTimer;
  static final List<PerformanceStats> _performanceHistory = [];
  static List<AIRecommendation> _activeRecommendations = [];
  static Map<String, DeviceBehaviorPattern> _behaviorPatterns = {};
  static DateTime _lastAnalysis = DateTime.now();
  
  // AI Configuration
  static Duration _analysisInterval = const Duration(minutes: 5);
  static const int _maxHistorySize = 1000;
  static double _recommendationThreshold = 0.7;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadBehaviorPatterns();
      _startAnalysis();
      _isInitialized = true;
      
      debugPrint('AI Recommendation Service initialized');
    } catch (e) {
      debugPrint('Error initializing AI Recommendation Service: $e');
      _isInitialized = true;
    }
  }

  /// Expose internal diagnostics (read-only).
  /// This also ensures the fields are referenced within this library for the analyzer.
  static Map<String, DeviceBehaviorPattern> get behaviorPatterns => _behaviorPatterns;
  static DateTime get lastAnalysis => _lastAnalysis;

  static Future<void> _loadBehaviorPatterns() async {
    // Load existing behavior patterns from storage
    // For now, initialize with default patterns
    _behaviorPatterns = {
      'gaming_heavy': DeviceBehaviorPattern(
        id: 'gaming_heavy',
        name: 'Heavy Gaming Pattern',
        description: 'User frequently plays intensive games',
        triggers: ['high_cpu_usage', 'high_gpu_usage', 'low_battery'],
        recommendations: [
          'Enable extreme performance mode',
          'Optimize thermal management',
          'Increase CPU frequency limits',
        ],
        confidence: 0.8,
      ),
      'battery_conscious': DeviceBehaviorPattern(
        id: 'battery_conscious',
        name: 'Battery Conscious Pattern',
        description: 'User prioritizes battery life',
        triggers: ['low_battery_level', 'power_saver_mode'],
        recommendations: [
          'Enable power saving mode',
          'Reduce background processes',
          'Optimize screen brightness',
        ],
        confidence: 0.9,
      ),
      'performance_focused': DeviceBehaviorPattern(
        id: 'performance_focused',
        name: 'Performance Focused Pattern',
        description: 'User prioritizes maximum performance',
        triggers: ['high_cpu_usage', 'high_memory_usage', 'thermal_throttling'],
        recommendations: [
          'Enable performance mode',
          'Increase cooling fan speed',
          'Disable thermal throttling',
        ],
        confidence: 0.85,
      ),
    };
  }

  static void _startAnalysis() {
    _analysisTimer = Timer.periodic(_analysisInterval, (timer) {
      _analyzePerformance();
    });
  }

  static void _analyzePerformance() async {
    try {
      final currentStats = PerformanceMonitorService.currentStats;
      _performanceHistory.add(currentStats);
      
      // Keep history size manageable
      if (_performanceHistory.length > _maxHistorySize) {
        _performanceHistory.removeAt(0);
      }
      
      // Analyze patterns and generate recommendations
      final recommendations = await _generateRecommendations(currentStats);
      
      // Update active recommendations
      _updateActiveRecommendations(recommendations);
      
      _lastAnalysis = DateTime.now();
    } catch (e) {
      debugPrint('Error analyzing performance: $e');
    }
  }

  static Future<List<AIRecommendation>> _generateRecommendations(PerformanceStats currentStats) async {
    final recommendations = <AIRecommendation>[];
    
    // Analyze CPU usage patterns
    final cpuRecommendations = _analyzeCPUUsage(currentStats);
    recommendations.addAll(cpuRecommendations);
    
    // Analyze memory usage patterns
    final memoryRecommendations = _analyzeMemoryUsage(currentStats);
    recommendations.addAll(memoryRecommendations);
    
    // Analyze thermal patterns
    final thermalRecommendations = _analyzeThermalPatterns(currentStats);
    recommendations.addAll(thermalRecommendations);
    
    // Analyze battery patterns
    final batteryRecommendations = _analyzeBatteryPatterns(currentStats);
    recommendations.addAll(batteryRecommendations);
    
    // Analyze gaming patterns
    final gamingRecommendations = await _analyzeGamingPatterns(currentStats);
    recommendations.addAll(gamingRecommendations);
    
    // Analyze device-specific patterns
    final deviceRecommendations = await _analyzeDevicePatterns(currentStats);
    recommendations.addAll(deviceRecommendations);
    
    // Filter and prioritize recommendations
    return _prioritizeRecommendations(recommendations);
  }

  static List<AIRecommendation> _analyzeCPUUsage(PerformanceStats currentStats) {
    final recommendations = <AIRecommendation>[];
    
    if (currentStats.cpuUsage > 80) {
      recommendations.add(AIRecommendation(
        id: 'high_cpu_optimization',
        title: 'High CPU Usage Detected',
        description: 'CPU usage is consistently high. Consider optimizing background processes.',
        type: RecommendationType.optimization,
        priority: RecommendationPriority.high,
        confidence: _calculateConfidence(currentStats.cpuUsage, 80, 100),
        actions: [
          'Close background applications',
          'Reduce CPU frequency limits',
          'Enable CPU throttling',
        ],
        impact: RecommendationImpact.high,
        estimatedBenefit: '15-25% CPU usage reduction',
        timestamp: DateTime.now(),
      ));
    }
    
    // Check for CPU throttling patterns
    if (_isCPUThrottling()) {
      recommendations.add(AIRecommendation(
        id: 'cpu_throttling_detected',
        title: 'CPU Throttling Detected',
        description: 'CPU is being throttled due to thermal constraints.',
        type: RecommendationType.thermal,
        priority: RecommendationPriority.medium,
        confidence: 0.8,
        actions: [
          'Improve device cooling',
          'Reduce thermal limits',
          'Enable performance mode',
        ],
        impact: RecommendationImpact.medium,
        estimatedBenefit: '10-20% performance improvement',
        timestamp: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  static List<AIRecommendation> _analyzeMemoryUsage(PerformanceStats currentStats) {
    final recommendations = <AIRecommendation>[];
    
    if (currentStats.memoryUsage > 85) {
      recommendations.add(AIRecommendation(
        id: 'high_memory_usage',
        title: 'High Memory Usage',
        description: 'Memory usage is critically high. System may become unstable.',
        type: RecommendationType.memory,
        priority: RecommendationPriority.critical,
        confidence: _calculateConfidence(currentStats.memoryUsage, 85, 100),
        actions: [
          'Clear app cache',
          'Close unused applications',
          'Restart device',
        ],
        impact: RecommendationImpact.high,
        estimatedBenefit: '20-40% memory freed',
        timestamp: DateTime.now(),
      ));
    } else if (currentStats.memoryUsage > 70) {
      recommendations.add(AIRecommendation(
        id: 'moderate_memory_usage',
        title: 'Moderate Memory Usage',
        description: 'Memory usage is elevated. Consider optimization.',
        type: RecommendationType.memory,
        priority: RecommendationPriority.low,
        confidence: _calculateConfidence(currentStats.memoryUsage, 70, 85),
        actions: [
          'Clear temporary files',
          'Optimize app memory usage',
        ],
        impact: RecommendationImpact.low,
        estimatedBenefit: '10-20% memory freed',
        timestamp: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  static List<AIRecommendation> _analyzeThermalPatterns(PerformanceStats currentStats) {
    final recommendations = <AIRecommendation>[];
    
    if (currentStats.thermalState.index >= ThermalState.hot.index) {
      recommendations.add(AIRecommendation(
        id: 'high_temperature',
        title: 'High Temperature Alert',
        description: 'Device temperature is elevated. Performance may be affected.',
        type: RecommendationType.thermal,
        priority: RecommendationPriority.high,
        confidence: 0.9,
        actions: [
          'Reduce device workload',
          'Improve cooling',
          'Lower performance settings',
        ],
        impact: RecommendationImpact.medium,
        estimatedBenefit: '5-15°C temperature reduction',
        timestamp: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  static List<AIRecommendation> _analyzeBatteryPatterns(PerformanceStats currentStats) {
    final recommendations = <AIRecommendation>[];
    
    if (currentStats.batteryLevel < 20 && currentStats.batteryState == BatteryState.discharging) {
      recommendations.add(AIRecommendation(
        id: 'low_battery',
        title: 'Low Battery Warning',
        description: 'Battery level is critically low. Enable power saving mode.',
        type: RecommendationType.battery,
        priority: RecommendationPriority.critical,
        confidence: 0.95,
        actions: [
          'Enable power saving mode',
          'Reduce screen brightness',
          'Close background apps',
        ],
        impact: RecommendationImpact.high,
        estimatedBenefit: '20-30% longer battery life',
        timestamp: DateTime.now(),
      ));
    } else if (currentStats.batteryLevel < 50) {
      recommendations.add(AIRecommendation(
        id: 'moderate_battery',
        title: 'Battery Optimization',
        description: 'Consider battery optimization to extend usage time.',
        type: RecommendationType.battery,
        priority: RecommendationPriority.low,
        confidence: 0.7,
        actions: [
          'Optimize battery usage',
          'Reduce background activity',
        ],
        impact: RecommendationImpact.low,
        estimatedBenefit: '10-15% longer battery life',
        timestamp: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  static Future<List<AIRecommendation>> _analyzeGamingPatterns(PerformanceStats currentStats) async {
    final recommendations = <AIRecommendation>[];
    
    // Check if user is gaming (high FPS, low latency)
    if (currentStats.fps > 30 && currentStats.networkLatency < 100) {
      recommendations.add(AIRecommendation(
        id: 'gaming_optimization',
        title: 'Gaming Mode Optimization',
        description: 'Gaming activity detected. Optimize for best performance.',
        type: RecommendationType.gaming,
        priority: RecommendationPriority.medium,
        confidence: 0.8,
        actions: [
          'Enable game mode',
          'Optimize network settings',
          'Increase performance limits',
        ],
        impact: RecommendationImpact.high,
        estimatedBenefit: '15-25% gaming performance improvement',
        timestamp: DateTime.now(),
      ));
    }
    
    // Check for FPS drops
    if (_isFPSDropping()) {
      recommendations.add(AIRecommendation(
        id: 'fps_drops',
        title: 'FPS Drops Detected',
        description: 'Frame rate is unstable. Graphics optimization needed.',
        type: RecommendationType.gaming,
        priority: RecommendationPriority.medium,
        confidence: 0.75,
        actions: [
          'Reduce graphics quality',
          'Optimize GPU settings',
          'Increase GPU frequency',
        ],
        impact: RecommendationImpact.medium,
        estimatedBenefit: '10-20% FPS improvement',
        timestamp: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  static Future<List<AIRecommendation>> _analyzeDevicePatterns(PerformanceStats currentStats) async {
    final recommendations = <AIRecommendation>[];
    
    // Get manufacturer-specific recommendations
    final deviceIntegration = ManufacturerIntegrationService.current;
    final availableOptimizations = await deviceIntegration.getAvailableOptimizations();
    
    for (final optimization in availableOptimizations) {
      if (optimization.isAvailable && !optimization.requiresRoot) {
        recommendations.add(AIRecommendation(
          id: 'device_optimization_${optimization.id}',
          title: '${optimization.name} Available',
          description: optimization.description,
          type: RecommendationType.device,
          priority: RecommendationPriority.low,
          confidence: 0.6,
          actions: [
            'Enable ${optimization.name}',
            'Configure ${optimization.name} settings',
          ],
          impact: RecommendationImpact.medium,
          estimatedBenefit: '5-15% performance improvement',
          timestamp: DateTime.now(),
      ));
      }
    }
    
    return recommendations;
  }

  static bool _isCPUThrottling() {
    if (_performanceHistory.length < 10) return false;
    
    // Check if CPU frequency is decreasing while usage is high
    final recentStats = _performanceHistory.sublist(_performanceHistory.length > 10 ? _performanceHistory.length - 10 : 0);
    int decreasingFrequencyCount = 0;
    
    for (int i = 1; i < recentStats.length; i++) {
      if (recentStats[i].cpuUsage > 70 && 
          recentStats[i].cpuUsage < recentStats[i-1].cpuUsage) {
        decreasingFrequencyCount++;
      }
    }
    
    return decreasingFrequencyCount > 5;
  }

  static bool _isFPSDropping() {
    if (_performanceHistory.length < 20) return false;
    
    final recentStats = _performanceHistory.sublist(_performanceHistory.length > 20 ? _performanceHistory.length - 20 : 0);
    final fpsValues = recentStats.map((stat) => stat.fps).toList();
    
    // Calculate FPS variance
    final meanFPS = fpsValues.reduce((a, b) => a + b) / fpsValues.length;
    final variance = fpsValues.map((fps) => pow(fps - meanFPS, 2)).reduce((a, b) => a + b) / fpsValues.length;
    final standardDeviation = sqrt(variance);
    
    return standardDeviation > 10; // High variance indicates FPS drops
  }

  static double _calculateConfidence(double value, double threshold, double max) {
    if (value < threshold) return 0.0;
    return ((value - threshold) / (max - threshold)).clamp(0.0, 1.0);
  }

  static List<AIRecommendation> _prioritizeRecommendations(List<AIRecommendation> recommendations) {
    // Filter by confidence threshold
    final filteredRecommendations = recommendations
        .where((rec) => rec.confidence >= _recommendationThreshold)
        .toList();
    
    // Sort by priority and confidence
    filteredRecommendations.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return b.confidence.compareTo(a.confidence);
    });
    
    // Remove duplicates
    final uniqueRecommendations = <AIRecommendation>[];
    final seenIds = <String>{};
    
    for (final recommendation in filteredRecommendations) {
      if (!seenIds.contains(recommendation.id)) {
        seenIds.add(recommendation.id);
        uniqueRecommendations.add(recommendation);
      }
    }
    
    return uniqueRecommendations;
  }

  static void _updateActiveRecommendations(List<AIRecommendation> newRecommendations) {
    // Remove expired recommendations
    final now = DateTime.now();
    _activeRecommendations.removeWhere((rec) => 
        now.difference(rec.timestamp).inHours > 24);
    
    // Add new recommendations
    for (final recommendation in newRecommendations) {
      if (!_activeRecommendations.any((rec) => rec.id == recommendation.id)) {
        _activeRecommendations.add(recommendation);
        _recommendationController.add(recommendation);
      }
    }
    
    // Keep only top 10 active recommendations
    if (_activeRecommendations.length > 10) {
      _activeRecommendations.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      _activeRecommendations = _activeRecommendations.take(10).toList();
    }
  }

  // Public API
  static Stream<AIRecommendation> get recommendations => _recommendationController.stream;
  static List<AIRecommendation> get activeRecommendations => List.unmodifiable(_activeRecommendations);
  static List<PerformanceStats> get performanceHistory => List.unmodifiable(_performanceHistory);
  static bool get isInitialized => _isInitialized;

  static Future<void> dismissRecommendation(String recommendationId) async {
    _activeRecommendations.removeWhere((rec) => rec.id == recommendationId);
  }

  static Future<void> applyRecommendation(String recommendationId) async {
    final recommendation = _activeRecommendations.firstWhere(
      (rec) => rec.id == recommendationId,
      orElse: () => throw Exception('Recommendation not found'),
    );
    
    // Apply the recommendation actions
    for (final action in recommendation.actions) {
      await _executeAction(action);
    }
    
    // Remove from active recommendations
    _activeRecommendations.remove(recommendation);
  }

  static Future<void> _executeAction(String action) async {
    // Execute the recommended action
    debugPrint('Executing action: $action');
    
    // This would implement the actual action execution
    // For now, we'll just log it
  }

  static Future<void> trainModel(List<PerformanceStats> trainingData, List<AIRecommendation> outcomes) async {
    // Train the AI model with new data
    // This would implement machine learning training
    debugPrint('Training AI model with ${trainingData.length} data points');
  }

  static void setAnalysisInterval(Duration interval) {
    _analysisInterval = interval;
    if (_isInitialized) {
      _analysisTimer?.cancel();
      _startAnalysis();
    }
  }

  static void setRecommendationThreshold(double threshold) {
    _recommendationThreshold = threshold.clamp(0.0, 1.0);
  }

  static void dispose() {
    _analysisTimer?.cancel();
    _recommendationController.close();
  }
}

class DeviceBehaviorPattern {
  final String id;
  final String name;
  final String description;
  final List<String> triggers;
  final List<String> recommendations;
  final double confidence;

  DeviceBehaviorPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.triggers,
    required this.recommendations,
    required this.confidence,
  });
}

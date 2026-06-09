import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hone_mobile/core/services/optimization_service.dart';
import 'package:hone_mobile/core/services/manufacturer_integration_service.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/services/notification_service.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';
import 'package:hone_mobile/core/models/manufacturer_optimization.dart';
import 'package:hone_mobile/core/models/scheduled_optimization.dart';
import 'package:battery_plus/battery_plus.dart';

class ScheduledOptimizationService {
  static bool _isInitialized = false;
  static final StreamController<ScheduledOptimization> _scheduleController = StreamController.broadcast();
  static final StreamController<OptimizationExecution> _executionController = StreamController.broadcast();
  static Timer? _schedulerTimer;
  static List<ScheduledOptimization> _schedules = [];
  static List<OptimizationExecution> _executionHistory = [];
  static bool _isServiceRunning = false;
  static bool _isOptimizing = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadSchedules();
      await _loadExecutionHistory();
      _startScheduler();
      _isInitialized = true;
      
      debugPrint('Scheduled Optimization Service initialized');
      debugPrint('Loaded ${_schedules.length} schedules');
      debugPrint('Service running: $_isServiceRunning');
    } catch (e) {
      debugPrint('Error initializing Scheduled Optimization Service: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('scheduled_optimizations') ?? '[]';
      
      final schedulesList = jsonDecode(schedulesJson) as List;
      _schedules = schedulesList.map((schedule) => ScheduledOptimization.fromJson(schedule)).toList();
      
      // Add default schedules if none exist
      if (_schedules.isEmpty) {
        _schedules = _getDefaultSchedules();
        await _saveSchedules();
      }
    } catch (e) {
      debugPrint('Error loading schedules: $e');
      _schedules = _getDefaultSchedules();
    }
  }

  static Future<void> _loadExecutionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('optimization_execution_history') ?? '[]';
      
      final historyList = jsonDecode(historyJson) as List;
      _executionHistory = historyList.map((execution) => OptimizationExecution.fromJson(execution)).toList();
      
      // Keep only last 100 executions
        _executionHistory = _executionHistory.sublist(_executionHistory.length > 100 ? _executionHistory.length - 100 : 0);
    } catch (e) {
      debugPrint('Error loading execution history: $e');
      _executionHistory = [];
    }
  }

  static List<ScheduledOptimization> _getDefaultSchedules() {
    return [
      ScheduledOptimization(
        id: 'daily_cleanup',
        name: 'Daily Cleanup',
        description: 'Automatically clean cache and temporary files daily',
        type: OptimizationType.storage,
        scheduleType: ScheduleType.daily,
        time: const TimeOfDay(hour: 2, minute: 0),
        createdAt: DateTime.now(),
        optimizations: [
          OptimizationType.cache,
          OptimizationType.storage,
        ],
        conditions: OptimizationConditions(
          requireCharging: true,
          requireWiFi: false,
          minBatteryLevel: 30,
          maxTemperature: 70.0,
        ),
      ),
      ScheduledOptimization(
        id: 'weekly_optimization',
        name: 'Weekly Full Optimization',
        description: 'Comprehensive system optimization every week',
        type: OptimizationType.fullSystem,
        scheduleType: ScheduleType.weekly,
        dayOfWeek: DateTime.sunday,
        time: const TimeOfDay(hour: 3, minute: 0),
        createdAt: DateTime.now(),
        optimizations: [
          OptimizationType.ram,
          OptimizationType.cache,
          OptimizationType.battery,
          OptimizationType.thermal,
          OptimizationType.storage,
        ],
        conditions: OptimizationConditions(
          requireCharging: true,
          requireWiFi: true,
          minBatteryLevel: 50,
          maxTemperature: 65.0,
        ),
      ),
      ScheduledOptimization(
        id: 'gaming_optimization',
        name: 'Gaming Session Optimization',
        description: 'Optimize system before gaming sessions',
        type: OptimizationType.game,
        scheduleType: ScheduleType.trigger,
        createdAt: DateTime.now(),
        optimizations: [
          OptimizationType.ram,
          OptimizationType.thermal,
          OptimizationType.network,
        ],
        conditions: OptimizationConditions(
          requireCharging: false,
          requireWiFi: false,
          minBatteryLevel: 20,
          maxTemperature: 80.0,
        ),
      ),
    ];
  }

  static void _startScheduler() {
    _isServiceRunning = true;
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndExecuteSchedules();
    });
  }

  static void _checkAndExecuteSchedules() async {
    if (_isOptimizing) return;
    
    final now = DateTime.now();
    
    for (final schedule in _schedules) {
      if (!schedule.enabled) continue;
      
      if (await _shouldExecuteSchedule(schedule, now)) {
        await _executeScheduledOptimization(schedule);
      }
    }
  }

  static Future<bool> _shouldExecuteSchedule(ScheduledOptimization schedule, DateTime now) async {
    // Check if already executed recently
    if (_wasRecentlyExecuted(schedule.id)) return false;
    
    // Check conditions
    if (!await _checkConditions(schedule.conditions)) return false;
    
    switch (schedule.scheduleType) {
      case ScheduleType.daily:
        return _isDailyTime(schedule.time ?? const TimeOfDay(hour: 0, minute: 0), now);
      case ScheduleType.weekly:
        return _isWeeklyTime(schedule.dayOfWeek ?? 1, schedule.time ?? const TimeOfDay(hour: 0, minute: 0), now);
      case ScheduleType.monthly:
        return _isMonthlyTime(schedule.dayOfMonth ?? 1, schedule.time ?? const TimeOfDay(hour: 0, minute: 0), now);
      case ScheduleType.interval:
        return _isIntervalTime(schedule.intervalHours ?? 1, now);
      case ScheduleType.trigger:
        return false; // Trigger-based schedules are executed manually
    }
  }

  static bool _isDailyTime(TimeOfDay time, DateTime now) {
    return now.hour == time.hour && now.minute == time.minute;
  }

  static bool _isWeeklyTime(int dayOfWeek, TimeOfDay time, DateTime now) {
    return now.weekday == dayOfWeek && now.hour == time.hour && now.minute == time.minute;
  }

  static bool _isMonthlyTime(int dayOfMonth, TimeOfDay time, DateTime now) {
    return now.day == dayOfMonth && now.hour == time.hour && now.minute == time.minute;
  }

  static bool _isIntervalTime(int intervalHours, DateTime now) {
    final lastExecution = _getLastExecutionTime('interval_$intervalHours');
    if (lastExecution == null) return true;
    
    final hoursSinceLastExecution = now.difference(lastExecution).inHours;
    return hoursSinceLastExecution >= intervalHours;
  }

  static bool _wasRecentlyExecuted(String scheduleId) {
    final lastExecution = _getLastExecutionTime(scheduleId);
    if (lastExecution == null) return false;
    
    final minutesSinceLastExecution = DateTime.now().difference(lastExecution).inMinutes;
    return minutesSinceLastExecution < 5; // Don't execute same schedule within 5 minutes
  }

  static DateTime? _getLastExecutionTime(String scheduleId) {
    try {
      final execution = _executionHistory
          .where((e) => e.scheduleId == scheduleId)
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
      return execution.timestamp;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> _checkConditions(OptimizationConditions conditions) async {
    try {
      final stats = PerformanceMonitorService.currentStats;
      
      // Check battery level
      if (stats.batteryLevel < conditions.minBatteryLevel) {
        return false;
      }
      
      // Check temperature
      final temperature = _getCurrentTemperature();
      if (temperature > conditions.maxTemperature) {
        return false;
      }
      
      // Check charging requirement
      if (conditions.requireCharging && stats.batteryState != BatteryState.charging) {
        return false;
      }
      
      // Check WiFi requirement (simplified)
      if (conditions.requireWiFi && !await _isWiFiConnected()) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking conditions: $e');
      return false;
    }
  }

  static double _getCurrentTemperature() {
    // Simulate temperature based on CPU usage
    final cpuUsage = PerformanceMonitorService.currentStats.cpuUsage;
    return 35.0 + (cpuUsage * 0.4); // 35-75°C range
  }

  static Future<bool> _isWiFiConnected() async {
    // Simplified WiFi check - in real implementation, use connectivity_plus
    return true;
  }

  static Future<void> _executeScheduledOptimization(ScheduledOptimization schedule) async {
    if (_isOptimizing) return;
    
    _isOptimizing = true;
    final execution = OptimizationExecution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduleId: schedule.id,
      scheduleName: schedule.name,
      timestamp: DateTime.now(),
      status: ExecutionStatus.running,
    );
    
    _executionHistory.add(execution);
    _executionController.add(execution);
    
    try {
      debugPrint('Executing scheduled optimization: ${schedule.name}');
      
      // Show notification
      await NotificationService.showOptimizationNotification(
        title: 'Scheduled Optimization',
        body: 'Running ${schedule.name}...',
      );
      
      final results = <OptimizationResult>[];
      
      // Execute optimizations based on schedule
      for (final optimizationType in schedule.optimizations) {
        final result = await _executeOptimizationType(optimizationType);
        results.add(result);
      }
      
      // Update execution status
      final success = results.every((r) => r.success);
      final updatedExecution = execution.copyWith(
        status: success ? ExecutionStatus.completed : ExecutionStatus.failed,
        results: results,
        duration: DateTime.now().difference(execution.timestamp),
      );
      
      final index = _executionHistory.indexOf(execution);
      if (index != -1) {
        _executionHistory[index] = updatedExecution;
      }
      
      // Show completion notification
      await NotificationService.showOptimizationNotification(
        title: 'Optimization Complete',
        body: '${schedule.name} ${success ? "completed successfully" : "completed with errors"}',
      );
      
      debugPrint('Scheduled optimization ${schedule.name} ${success ? "succeeded" : "failed"}');
      
    } catch (e) {
      final updatedExecution = execution.copyWith(
        status: ExecutionStatus.failed,
        error: e.toString(),
        duration: DateTime.now().difference(execution.timestamp),
      );
      
      final index = _executionHistory.indexOf(execution);
      if (index != -1) {
        _executionHistory[index] = updatedExecution;
      }
      
      debugPrint('Error executing scheduled optimization: $e');
      
      await NotificationService.showOptimizationNotification(
        title: 'Optimization Failed',
        body: '${schedule.name} failed: $e',
      );
    } finally {
      _isOptimizing = false;
      await _saveExecutionHistory();
      _executionController.add(execution);
    }
  }

  static Future<OptimizationResult> _executeOptimizationType(OptimizationType type) async {
    switch (type) {
      case OptimizationType.ram:
        return await OptimizationService.optimizeRAM();
      case OptimizationType.cache:
        return await OptimizationService.cleanCache();
      case OptimizationType.battery:
        return await OptimizationService.optimizeBattery();
      case OptimizationType.thermal:
        return await OptimizationService.optimizeThermal();
      case OptimizationType.network:
        return await OptimizationService.optimizeNetwork();
      case OptimizationType.storage:
        return await OptimizationService.optimizeStorage();
      case OptimizationType.fullSystem:
        final results = await OptimizationService.fullSystemOptimization();
        final success = results.every((r) => r.success);
        return OptimizationResult(
          type: OptimizationType.fullSystem,
          success: success,
          message: success ? 'Full system optimization completed' : 'Some optimizations failed',
          details: {'results': results.length},
        );
      case OptimizationType.game:
        return await _executeGamingOptimization();
      default:
        return OptimizationResult.createFailure(
          type: type,
          message: 'Optimization type not supported',
        );
    }
  }

  static Future<OptimizationResult> _executeGamingOptimization() async {
    try {
      final results = <Future<OptimizationResult>>[];
      
      // RAM optimization
      results.add(OptimizationService.optimizeRAM());
      
      // Thermal optimization
      results.add(OptimizationService.optimizeThermal());
      
      // Network optimization
      results.add(OptimizationService.optimizeNetwork());
      
      // Manufacturer-specific optimizations
      if (ManufacturerIntegrationService.isInitialized) {
        final availableOptimizations = await ManufacturerIntegrationService.getAvailableOptimizations();
        for (final optimization in availableOptimizations) {
          if (optimization.category == OptimizationCategory.gaming) {
            results.add(ManufacturerIntegrationService.applyOptimization(optimization.id));
          }
        }
      }
      
      final optimizationResults = await Future.wait(results);
      final success = optimizationResults.every((r) => r.success);
      
      return OptimizationResult(
        type: OptimizationType.game,
        success: success,
        message: success ? 'Gaming optimization completed' : 'Some gaming optimizations failed',
        details: {'results': optimizationResults.length},
      );
    } catch (e) {
      return OptimizationResult.createFailure(
        type: OptimizationType.game,
        message: 'Gaming optimization failed: $e',
      );
    }
  }

  static Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = jsonEncode(_schedules.map((s) => s.toJson()).toList());
      await prefs.setString('scheduled_optimizations', schedulesJson);
    } catch (e) {
      debugPrint('Error saving schedules: $e');
    }
  }

  static Future<void> _saveExecutionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_executionHistory.map((e) => e.toJson()).toList());
      await prefs.setString('optimization_execution_history', historyJson);
    } catch (e) {
      debugPrint('Error saving execution history: $e');
    }
  }

  // Public API
  static Stream<ScheduledOptimization> get schedules => _scheduleController.stream;
  static Stream<OptimizationExecution> get executions => _executionController.stream;
  static List<ScheduledOptimization> get activeSchedules => List.unmodifiable(_schedules);
  static List<OptimizationExecution> get executionHistory => List.unmodifiable(_executionHistory);
  static bool get isInitialized => _isInitialized;
  static bool get isServiceRunning => _isServiceRunning;
  static bool get isOptimizing => _isOptimizing;

  static Future<void> addSchedule(ScheduledOptimization schedule) async {
    _schedules.add(schedule);
    await _saveSchedules();
    _scheduleController.add(schedule);
  }

  static Future<void> updateSchedule(ScheduledOptimization schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      await _saveSchedules();
      _scheduleController.add(schedule);
    }
  }

  static Future<void> deleteSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    await _saveSchedules();
  }

  static Future<void> toggleSchedule(String scheduleId, bool enabled) async {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    schedule.enabled = enabled;
    await _saveSchedules();
    _scheduleController.add(schedule);
  }

  static Future<void> executeScheduleNow(String scheduleId) async {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    await _executeScheduledOptimization(schedule);
  }

  static Future<void> triggerGamingOptimization() async {
    final gamingSchedule = _schedules.firstWhere(
      (s) => s.id == 'gaming_optimization',
      orElse: () => throw Exception('Gaming optimization schedule not found'),
    );
    await _executeScheduledOptimization(gamingSchedule);
  }

  static Future<void> startService() async {
    if (!_isServiceRunning) {
      _startScheduler();
    }
  }

  static Future<void> stopService() async {
    if (_isServiceRunning) {
      _schedulerTimer?.cancel();
      _schedulerTimer = null;
      _isServiceRunning = false;
    }
  }

  static Future<OptimizationReport> generateReport() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));
    
    final weeklyExecutions = _executionHistory.where((e) => e.timestamp.isAfter(lastWeek));
    final monthlyExecutions = _executionHistory.where((e) => e.timestamp.isAfter(lastMonth));
    
    final weeklySuccess = weeklyExecutions.where((e) => e.status == ExecutionStatus.completed).length;
    final monthlySuccess = monthlyExecutions.where((e) => e.status == ExecutionStatus.completed).length;
    
    return OptimizationReport(
      totalExecutions: _executionHistory.length,
      weeklyExecutions: weeklyExecutions.length,
      monthlyExecutions: monthlyExecutions.length,
      weeklySuccessRate: weeklyExecutions.isEmpty ? 0.0 : (weeklySuccess / weeklyExecutions.length) * 100,
      monthlySuccessRate: monthlyExecutions.isEmpty ? 0.0 : (monthlySuccess / monthlyExecutions.length) * 100,
      lastExecution: _executionHistory.isNotEmpty ? _executionHistory.last.timestamp : null,
      nextScheduledExecution: _getNextScheduledExecution(),
    );
  }

  static DateTime? _getNextScheduledExecution() {
    final now = DateTime.now();
    DateTime? nextExecution;
    
    for (final schedule in _schedules) {
      if (!schedule.enabled) continue;
      
      DateTime? scheduleTime;
      
      switch (schedule.scheduleType) {
        case ScheduleType.daily:
          scheduleTime = DateTime(now.year, now.month, now.day, schedule.time?.hour ?? 0, schedule.time?.minute ?? 0);
          if (scheduleTime.isBefore(now)) {
            scheduleTime = scheduleTime.add(const Duration(days: 1));
          }
          break;
        case ScheduleType.weekly:
          final daysUntilNext = ((schedule.dayOfWeek ?? 1) - now.weekday + 7) % 7;
          scheduleTime = DateTime(now.year, now.month, now.day + daysUntilNext, schedule.time?.hour ?? 0, schedule.time?.minute ?? 0);
          break;
        case ScheduleType.monthly:
          scheduleTime = DateTime(now.year, now.month, schedule.dayOfMonth ?? 1, schedule.time?.hour ?? 0, schedule.time?.minute ?? 0);
          if (scheduleTime.isBefore(now)) {
            scheduleTime = DateTime(now.year, now.month + 1, schedule.dayOfMonth ?? 1, schedule.time?.hour ?? 0, schedule.time?.minute ?? 0);
          }
          break;
        case ScheduleType.interval:
          final lastExecution = _getLastExecutionTime(schedule.id);
          if (lastExecution != null) {
            scheduleTime = lastExecution.add(Duration(hours: schedule.intervalHours ?? 0));
          }
          break;
        case ScheduleType.trigger:
          continue; // Skip trigger-based schedules
      }
      
      if (scheduleTime != null && (nextExecution == null || scheduleTime.isBefore(nextExecution))) {
        nextExecution = scheduleTime;
      }
    }
    
    return nextExecution;
  }

  static void dispose() {
    stopService();
    _scheduleController.close();
    _executionController.close();
  }
}

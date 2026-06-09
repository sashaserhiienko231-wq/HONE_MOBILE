import 'package:flutter/material.dart';
import 'package:hone_mobile/core/models/optimization_result.dart';

class ScheduledOptimization {
  final String id;
  final String name;
  final String description;
  final OptimizationType type;
  final ScheduleType scheduleType;
  final TimeOfDay? time;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? intervalHours;
  bool enabled;
  final List<OptimizationType> optimizations;
  final OptimizationConditions conditions;
  final DateTime createdAt;
  final DateTime? lastExecuted;
  final DateTime? nextExecution;

  ScheduledOptimization({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.scheduleType,
    this.time,
    this.dayOfWeek,
    this.dayOfMonth,
    this.intervalHours,
    this.enabled = true,
    required this.optimizations,
    required this.conditions,
    required this.createdAt,
    this.lastExecuted,
    this.nextExecution,
  });

  ScheduledOptimization copyWith({
    String? id,
    String? name,
    String? description,
    OptimizationType? type,
    ScheduleType? scheduleType,
    TimeOfDay? time,
    int? dayOfWeek,
    int? dayOfMonth,
    int? intervalHours,
    bool? enabled,
    List<OptimizationType>? optimizations,
    OptimizationConditions? conditions,
    DateTime? createdAt,
    DateTime? lastExecuted,
    DateTime? nextExecution,
  }) {
    return ScheduledOptimization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduleType: scheduleType ?? this.scheduleType,
      time: time ?? this.time,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      intervalHours: intervalHours ?? this.intervalHours,
      enabled: enabled ?? this.enabled,
      optimizations: optimizations ?? this.optimizations,
      conditions: conditions ?? this.conditions,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      nextExecution: nextExecution ?? this.nextExecution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'scheduleType': scheduleType.name,
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'intervalHours': intervalHours,
      'enabled': enabled,
      'optimizations': optimizations.map((o) => o.name).toList(),
      'conditions': conditions.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
      'nextExecution': nextExecution?.toIso8601String(),
    };
  }

  factory ScheduledOptimization.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['time'] != null) {
      final timeParts = (json['time'] as String).split(':');
      time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    return ScheduledOptimization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: OptimizationType.values.firstWhere((t) => t.name == json['type']),
      scheduleType: ScheduleType.values.firstWhere((s) => s.name == json['scheduleType']),
      time: time,
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      intervalHours: json['intervalHours'] as int?,
      enabled: json['enabled'] as bool? ?? true,
      optimizations: (json['optimizations'] as List)
          .map((o) => OptimizationType.values.firstWhere((t) => t.name == o))
          .toList(),
      conditions: OptimizationConditions.fromJson(json['conditions']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastExecuted: json['lastExecuted'] != null 
          ? DateTime.parse(json['lastExecuted'] as String)
          : null,
      nextExecution: json['nextExecution'] != null 
          ? DateTime.parse(json['nextExecution'] as String)
          : null,
    );
  }

  String get scheduleDescription {
    String formatTime(TimeOfDay? t) {
      if (t == null) return "12:00 AM";
      final hour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
      final period = t.hour >= 12 ? 'PM' : 'AM';
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }

    switch (scheduleType) {
      case ScheduleType.daily:
        return 'Daily at ${formatTime(time)}';
      case ScheduleType.weekly:
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return 'Weekly on ${dayNames[dayOfWeek ?? 0]} at ${formatTime(time)}';
      case ScheduleType.monthly:
        return 'Monthly on day $dayOfMonth at ${formatTime(time)}';
      case ScheduleType.interval:
        return 'Every $intervalHours hours';
      case ScheduleType.trigger:
        return 'On trigger event';
    }
  }

  String get statusEmoji {
    if (!enabled) return '⏸️';
    if (lastExecuted == null) return '🆕';
    if (DateTime.now().difference(lastExecuted!).inHours < 24) return '✅';
    return '⏰';
  }
}

enum ScheduleType {
  daily,
  weekly,
  monthly,
  interval,
  trigger,
}

class OptimizationConditions {
  final bool requireCharging;
  final bool requireWiFi;
  final int minBatteryLevel;
  final double maxTemperature;
  final List<String> requiredApps;
  final List<String> excludedApps;

  OptimizationConditions({
    this.requireCharging = false,
    this.requireWiFi = false,
    this.minBatteryLevel = 20,
    this.maxTemperature = 80.0,
    this.requiredApps = const [],
    this.excludedApps = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'requireCharging': requireCharging,
      'requireWiFi': requireWiFi,
      'minBatteryLevel': minBatteryLevel,
      'maxTemperature': maxTemperature,
      'requiredApps': requiredApps,
      'excludedApps': excludedApps,
    };
  }

  factory OptimizationConditions.fromJson(Map<String, dynamic> json) {
    return OptimizationConditions(
      requireCharging: json['requireCharging'] as bool? ?? false,
      requireWiFi: json['requireWiFi'] as bool? ?? false,
      minBatteryLevel: json['minBatteryLevel'] as int? ?? 20,
      maxTemperature: (json['maxTemperature'] as num?)?.toDouble() ?? 80.0,
      requiredApps: (json['requiredApps'] as List?)?.cast<String>() ?? [],
      excludedApps: (json['excludedApps'] as List?)?.cast<String>() ?? [],
    );
  }
}

class OptimizationExecution {
  final String id;
  final String scheduleId;
  final String scheduleName;
  final DateTime timestamp;
  final ExecutionStatus status;
  final Duration? duration;
  final List<OptimizationResult>? results;
  final String? error;

  OptimizationExecution({
    required this.id,
    required this.scheduleId,
    required this.scheduleName,
    required this.timestamp,
    required this.status,
    this.duration,
    this.results,
    this.error,
  });

  OptimizationExecution copyWith({
    String? id,
    String? scheduleId,
    String? scheduleName,
    DateTime? timestamp,
    ExecutionStatus? status,
    Duration? duration,
    List<OptimizationResult>? results,
    String? error,
  }) {
    return OptimizationExecution(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduleName: scheduleName ?? this.scheduleName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'scheduleName': scheduleName,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'duration': duration?.inMilliseconds,
      'results': results?.map((r) => r.toJson()).toList(),
      'error': error,
    };
  }

  factory OptimizationExecution.fromJson(Map<String, dynamic> json) {
    return OptimizationExecution(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      scheduleName: json['scheduleName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: ExecutionStatus.values.firstWhere((s) => s.name == json['status']),
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      results: json['results'] != null
          ? (json['results'] as List).map((r) => OptimizationResult.fromJson(r)).toList()
          : null,
      error: json['error'] as String?,
    );
  }

  String get statusEmoji {
    switch (status) {
      case ExecutionStatus.running:
        return '⏳';
      case ExecutionStatus.completed:
        return '✅';
      case ExecutionStatus.failed:
        return '❌';
      case ExecutionStatus.cancelled:
        return '⏹️';
    }
  }

  String get durationFormatted {
    final durationVal = duration ?? Duration.zero;
    if (durationVal.inSeconds < 60) {
      return '${durationVal.inSeconds}s';
    } else if (durationVal.inMinutes < 60) {
      return '${durationVal.inMinutes}m ${durationVal.inSeconds % 60}s';
    } else {
      return '${durationVal.inHours}h ${durationVal.inMinutes % 60}m';
    }
  }
}

enum ExecutionStatus {
  running,
  completed,
  failed,
  cancelled,
}

class OptimizationReport {
  final int totalExecutions;
  final int weeklyExecutions;
  final int monthlyExecutions;
  final double weeklySuccessRate;
  final double monthlySuccessRate;
  final DateTime? lastExecution;
  final DateTime? nextScheduledExecution;

  OptimizationReport({
    required this.totalExecutions,
    required this.weeklyExecutions,
    required this.monthlyExecutions,
    required this.weeklySuccessRate,
    required this.monthlySuccessRate,
    this.lastExecution,
    this.nextScheduledExecution,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalExecutions': totalExecutions,
      'weeklyExecutions': weeklyExecutions,
      'monthlyExecutions': monthlyExecutions,
      'weeklySuccessRate': weeklySuccessRate,
      'monthlySuccessRate': monthlySuccessRate,
      'lastExecution': lastExecution?.toIso8601String(),
      'nextScheduledExecution': nextScheduledExecution?.toIso8601String(),
    };
  }

  factory OptimizationReport.fromJson(Map<String, dynamic> json) {
    return OptimizationReport(
      totalExecutions: json['totalExecutions'] as int,
      weeklyExecutions: json['weeklyExecutions'] as int,
      monthlyExecutions: json['monthlyExecutions'] as int,
      weeklySuccessRate: (json['weeklySuccessRate'] as num).toDouble(),
      monthlySuccessRate: (json['monthlySuccessRate'] as num).toDouble(),
      lastExecution: json['lastExecution'] != null 
          ? DateTime.parse(json['lastExecution'] as String)
          : null,
      nextScheduledExecution: json['nextScheduledExecution'] != null 
          ? DateTime.parse(json['nextScheduledExecution'] as String)
          : null,
    );
  }
}

class OptimizationTemplate {
  final String id;
  final String name;
  final String description;
  final List<OptimizationType> optimizations;
  final OptimizationConditions defaultConditions;
  final ScheduleType defaultScheduleType;
  final TimeOfDay? defaultTime;

  OptimizationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.optimizations,
    required this.defaultConditions,
    required this.defaultScheduleType,
    this.defaultTime,
  });

  static List<OptimizationTemplate> get defaultTemplates {
    return [
      OptimizationTemplate(
        id: 'daily_cleanup',
        name: 'Daily Cleanup',
        description: 'Quick daily cleanup to keep your device running smoothly',
        optimizations: [OptimizationType.cache, OptimizationType.storage],
        defaultConditions: OptimizationConditions(
          requireCharging: false,
          requireWiFi: false,
          minBatteryLevel: 15,
        ),
        defaultScheduleType: ScheduleType.daily,
        defaultTime: const TimeOfDay(hour: 2, minute: 0),
      ),
      OptimizationTemplate(
        id: 'gaming_session',
        name: 'Gaming Session',
        description: 'Optimize device for the best gaming performance',
        optimizations: [OptimizationType.ram, OptimizationType.thermal, OptimizationType.network],
        defaultConditions: OptimizationConditions(
          requireCharging: false,
          requireWiFi: false,
          minBatteryLevel: 20,
        ),
        defaultScheduleType: ScheduleType.trigger,
      ),
      OptimizationTemplate(
        id: 'battery_saver',
        name: 'Battery Saver',
        description: 'Maximize battery life with conservative optimizations',
        optimizations: [OptimizationType.battery, OptimizationType.thermal],
        defaultConditions: OptimizationConditions(
          requireCharging: false,
          requireWiFi: false,
          minBatteryLevel: 10,
        ),
        defaultScheduleType: ScheduleType.daily,
        defaultTime: const TimeOfDay(hour: 22, minute: 0),
      ),
      OptimizationTemplate(
        id: 'performance_boost',
        name: 'Performance Boost',
        description: 'Maximum performance for demanding tasks',
        optimizations: [
          OptimizationType.ram,
          OptimizationType.cache,
          OptimizationType.thermal,
          OptimizationType.network,
        ],
        defaultConditions: OptimizationConditions(
          requireCharging: true,
          requireWiFi: false,
          minBatteryLevel: 50,
        ),
        defaultScheduleType: ScheduleType.trigger,
      ),
    ];
  }

  ScheduledOptimization createSchedule() {
    return ScheduledOptimization(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: optimizations.first, // Use first optimization as primary type
      scheduleType: defaultScheduleType,
      time: defaultTime,
      enabled: false, // Disabled by default
      optimizations: optimizations,
      conditions: defaultConditions,
      createdAt: DateTime.now(),
    );
  }
}

class OptimizationStatistics {
  final Map<OptimizationType, int> executionCounts;
  final Map<OptimizationType, double> successRates;
  final Map<ExecutionStatus, int> statusCounts;
  final Duration averageExecutionTime;
  final Duration totalOptimizationTime;
  final int totalCleanedStorage;
  final double averagePerformanceImprovement;

  OptimizationStatistics({
    required this.executionCounts,
    required this.successRates,
    required this.statusCounts,
    required this.averageExecutionTime,
    required this.totalOptimizationTime,
    required this.totalCleanedStorage,
    required this.averagePerformanceImprovement,
  });

  static OptimizationStatistics empty() {
    return OptimizationStatistics(
      executionCounts: {},
      successRates: {},
      statusCounts: {},
      averageExecutionTime: Duration.zero,
      totalOptimizationTime: Duration.zero,
      totalCleanedStorage: 0,
      averagePerformanceImprovement: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executionCounts': executionCounts.map((k, v) => MapEntry(k.name, v)),
      'successRates': successRates.map((k, v) => MapEntry(k.name, v)),
      'statusCounts': statusCounts.map((k, v) => MapEntry(k.name, v)),
      'averageExecutionTime': averageExecutionTime.inMilliseconds,
      'totalOptimizationTime': totalOptimizationTime.inMilliseconds,
      'totalCleanedStorage': totalCleanedStorage,
      'averagePerformanceImprovement': averagePerformanceImprovement,
    };
  }

  factory OptimizationStatistics.fromJson(Map<String, dynamic> json) {
    return OptimizationStatistics(
      executionCounts: Map.from(json['executionCounts']).map((k, v) => 
        MapEntry(OptimizationType.values.firstWhere((t) => t.name == k), v as int)),
      successRates: Map.from(json['successRates']).map((k, v) => 
        MapEntry(OptimizationType.values.firstWhere((t) => t.name == k), (v as num).toDouble())),
      statusCounts: Map.from(json['statusCounts']).map((k, v) => 
        MapEntry(ExecutionStatus.values.firstWhere((s) => s.name == k), v as int)),
      averageExecutionTime: Duration(milliseconds: json['averageExecutionTime'] as int),
      totalOptimizationTime: Duration(milliseconds: json['totalOptimizationTime'] as int),
      totalCleanedStorage: json['totalCleanedStorage'] as int,
      averagePerformanceImprovement: (json['averagePerformanceImprovement'] as num).toDouble(),
    );
  }
}

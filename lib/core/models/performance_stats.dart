import 'package:battery_plus/battery_plus.dart';
import 'package:hone_mobile/core/models/thermal_state.dart';

class PerformanceStats {
  final DateTime timestamp;
  final double cpuUsage;
  final double memoryUsage;
  final int batteryLevel;
  final BatteryState batteryState;
  final ThermalState thermalState;
  final double networkLatency;
  final double fps;
  final double gpuUsage;

  const PerformanceStats({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.batteryState,
    required this.thermalState,
    required this.networkLatency,
    required this.fps,
    required this.gpuUsage,
  });

  static final PerformanceStats empty = PerformanceStats(
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    cpuUsage: 0.0,
    memoryUsage: 0.0,
    batteryLevel: 0,
    batteryState: BatteryState.unknown,
    thermalState: ThermalState.normal,
    networkLatency: 0.0,
    fps: 0.0,
    gpuUsage: 0.0,
  );

  @override
  String toString() {
    return 'PerformanceStats(timestamp: $timestamp, cpu: ${cpuUsage.toStringAsFixed(1)}%, memory: ${memoryUsage.toStringAsFixed(1)}%, fps: ${fps.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceStats &&
        other.timestamp == timestamp &&
        other.cpuUsage == cpuUsage &&
        other.memoryUsage == memoryUsage &&
        other.batteryLevel == batteryLevel &&
        other.batteryState == batteryState &&
        other.thermalState == thermalState &&
        other.networkLatency == networkLatency &&
        other.fps == fps &&
        other.gpuUsage == gpuUsage;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        cpuUsage.hashCode ^
        memoryUsage.hashCode ^
        batteryLevel.hashCode ^
        batteryState.hashCode ^
        thermalState.hashCode ^
        networkLatency.hashCode ^
        fps.hashCode ^
        gpuUsage.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'batteryLevel': batteryLevel,
      'batteryState': batteryState.name,
      'thermalState': thermalState.name,
      'networkLatency': networkLatency,
      'fps': fps,
      'gpuUsage': gpuUsage,
    };
  }

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      timestamp: DateTime.parse(json['timestamp'] as String),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      batteryLevel: json['batteryLevel'] as int,
      batteryState: BatteryState.values.firstWhere(
        (state) => state.name == json['batteryState'],
        orElse: () => BatteryState.unknown,
      ),
      thermalState: ThermalState.values.firstWhere(
        (state) => state.name == json['thermalState'],
        orElse: () => ThermalState.normal,
      ),
      networkLatency: (json['networkLatency'] as num).toDouble(),
      fps: (json['fps'] as num).toDouble(),
      gpuUsage: (json['gpuUsage'] as num).toDouble(),
    );
  }

  PerformanceStats copyWith({
    DateTime? timestamp,
    double? cpuUsage,
    double? memoryUsage,
    int? batteryLevel,
    BatteryState? batteryState,
    ThermalState? thermalState,
    double? networkLatency,
    double? fps,
    double? gpuUsage,
  }) {
    return PerformanceStats(
      timestamp: timestamp ?? this.timestamp,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryState: batteryState ?? this.batteryState,
      thermalState: thermalState ?? this.thermalState,
      networkLatency: networkLatency ?? this.networkLatency,
      fps: fps ?? this.fps,
      gpuUsage: gpuUsage ?? this.gpuUsage,
    );
  }

  // Performance analysis methods
  bool get isCPUHigh => cpuUsage > 80.0;
  bool get isMemoryHigh => memoryUsage > 85.0;
  bool get isThermalHot => thermalState.index >= ThermalState.hot.index;
  bool get isFPSLow => fps < 30.0;
  bool get isBatteryLow => batteryLevel < 20;
  bool get isNetworkSlow => networkLatency > 100.0;
  bool get isGPUHigh => gpuUsage > 80.0;

  String get cpuStatus {
    if (cpuUsage > 80) return 'High';
    if (cpuUsage > 60) return 'Moderate';
    return 'Normal';
  }

  String get memoryStatus {
    if (memoryUsage > 85) return 'High';
    if (memoryUsage > 70) return 'Moderate';
    return 'Normal';
  }

  String get thermalStatus {
    switch (thermalState) {
      case ThermalState.normal:
        return 'Normal';
      case ThermalState.warm:
        return 'Warm';
      case ThermalState.hot:
        return 'Hot';
      case ThermalState.veryHot:
        return 'Very Hot';
    }
  }

  String get fpsStatus {
    if (fps >= 55) return 'Excellent';
    if (fps >= 45) return 'Good';
    if (fps >= 30) return 'Fair';
    return 'Poor';
  }

  String get batteryStatus {
    if (batteryLevel > 80) return 'Good';
    if (batteryLevel > 50) return 'Fair';
    if (batteryLevel > 20) return 'Low';
    return 'Critical';
  }

  String get networkStatus {
    if (networkLatency < 30) return 'Excellent';
    if (networkLatency < 60) return 'Good';
    if (networkLatency < 100) return 'Fair';
    return 'Poor';
  }

  String get gpuStatus {
    if (gpuUsage > 80) return 'High';
    if (gpuUsage > 60) return 'Moderate';
    return 'Normal';
  }

  // Performance score (0-100)
  double get performanceScore {
    double score = 100.0;
    
    // CPU impact (20% weight)
    if (isCPUHigh) {
      score -= 20;
    } else if (cpuUsage > 60) {
      score -= 10;
    }
    
    // Memory impact (20% weight)
    if (isMemoryHigh) {
      score -= 20;
    } else if (memoryUsage > 70) {
      score -= 10;
    }
    
    // FPS impact (25% weight)
    if (isFPSLow) {
      score -= 25;
    } else if (fps < 45) {
      score -= 15;
    } else if (fps < 55) {
      score -= 5;
    }
    
    // Thermal impact (15% weight)
    if (thermalState == ThermalState.veryHot) {
      score -= 15;
    } else if (thermalState == ThermalState.hot) {
      score -= 10;
    } else if (thermalState == ThermalState.warm) {
      score -= 5;
    }
    
    // Network impact (10% weight)
    if (isNetworkSlow) {
      score -= 10;
    } else if (networkLatency > 60) {
      score -= 5;
    }
    
    // Battery impact (10% weight)
    if (isBatteryLow) {
      score -= 10;
    } else if (batteryLevel < 50) {
      score -= 5;
    }
    
    return score.clamp(0.0, 100.0);
  }

  String get performanceGrade {
    final score = performanceScore;
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}

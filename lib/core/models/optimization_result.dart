enum OptimizationType {
  ram,
  cache,
  battery,
  thermal,
  network,
  storage,
  deviceSpecific,
  game,
  fullSystem,
}

class OptimizationResult {
  final OptimizationType type;
  final bool success;
  final String message;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final Duration executionTime;

  OptimizationResult({
    required this.type,
    required this.success,
    required this.message,
    this.details = const {},
    DateTime? timestamp,
    Duration? executionTime,
  }) : timestamp = timestamp ?? DateTime.now(),
       executionTime = executionTime ?? Duration.zero;

  @override
  String toString() {
    return 'OptimizationResult(type: $type, success: $success, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizationResult &&
        other.type == type &&
        other.success == success &&
        other.message == message &&
        other.details == details &&
        other.timestamp == timestamp &&
        other.executionTime == executionTime;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        success.hashCode ^
        message.hashCode ^
        details.hashCode ^
        timestamp.hashCode ^
        executionTime.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'success': success,
      'message': message,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'executionTimeMs': executionTime.inMilliseconds,
    };
  }

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    return OptimizationResult(
      type: OptimizationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => OptimizationType.ram,
      ),
      success: json['success'] as bool,
      message: json['message'] as String,
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      executionTime: Duration(milliseconds: json['executionTimeMs'] as int),
    );
  }

  OptimizationResult copyWith({
    OptimizationType? type,
    bool? success,
    String? message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
    Duration? executionTime,
  }) {
    return OptimizationResult(
      type: type ?? this.type,
      success: success ?? this.success,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      executionTime: executionTime ?? this.executionTime,
    );
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case OptimizationType.ram:
        return 'RAM Optimization';
      case OptimizationType.cache:
        return 'Cache Cleaning';
      case OptimizationType.battery:
        return 'Battery Optimization';
      case OptimizationType.thermal:
        return 'Thermal Optimization';
      case OptimizationType.network:
        return 'Network Optimization';
      case OptimizationType.storage:
        return 'Storage Optimization';
      case OptimizationType.deviceSpecific:
        return 'Device-Specific Optimization';
      case OptimizationType.game:
        return 'Game Optimization';
      case OptimizationType.fullSystem:
        return 'Full System Optimization';
    }
  }

  String get statusEmoji {
    return success ? '✅' : '❌';
  }

  bool get hasDetails => details.isNotEmpty;

  T? getDetail<T>(String key) {
    return details[key] as T?;
  }

  // Static methods for creating common results
  static OptimizationResult createSuccess({
    required OptimizationType type,
    required String message,
    Map<String, dynamic> details = const {},
  }) {
    return OptimizationResult(
      type: type,
      success: true,
      message: message,
      details: details,
    );
  }

  static OptimizationResult createFailure({
    required OptimizationType type,
    required String message,
    Map<String, dynamic> details = const {},
  }) {
    return OptimizationResult(
      type: type,
      success: false,
      message: message,
      details: details,
    );
  }
}

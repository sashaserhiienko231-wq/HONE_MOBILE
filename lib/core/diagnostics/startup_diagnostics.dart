import 'package:hone_mobile/core/utils/logger.dart';

/// Startup diagnostics system for tracking performance and issues
class StartupDiagnostics {
  static StartupDiagnostics? _instance;
  static StartupDiagnostics get instance => _instance ??= StartupDiagnostics._();

  StartupDiagnostics._();

  final Logger _logger = Logger.instance;

  // Startup metrics
  final Map<String, ServiceMetrics> _serviceMetrics = {};
  DateTime? _startupStartTime;
  DateTime? _startupEndTime;
  StartupPhase _currentPhase = StartupPhase.notStarted;

  // Memory tracking
  double? _initialMemoryMB;
  double? _peakMemoryMB;
  double? _finalMemoryMB;

  // Event tracking
  final List<StartupEvent> _events = [];

  /// Start startup diagnostics
  void startStartup() {
    _startupStartTime = DateTime.now();
    _currentPhase = StartupPhase.initialization;
    _initialMemoryMB = _getCurrentMemoryMB();

    _logger.startup('Diagnostics started', tag: 'DIAGNOSTICS');
    _recordEvent(StartupEventType.diagnosticsStarted);
  }

  /// End startup diagnostics
  void endStartup() {
    _startupEndTime = DateTime.now();
    _currentPhase = StartupPhase.completed;
    _finalMemoryMB = _getCurrentMemoryMB();

    _logger.startup('Diagnostics completed', tag: 'DIAGNOSTICS');
    _recordEvent(StartupEventType.diagnosticsCompleted);

    // Log summary
    _logSummary();
  }

  /// Record service initialization start
  void recordServiceStart(String serviceName) {
    _serviceMetrics[serviceName] = ServiceMetrics(
      serviceName: serviceName,
      startTime: DateTime.now(),
    );

    _logger.startup('Service started: $serviceName', tag: 'DIAGNOSTICS');
    _recordEvent(StartupEventType.serviceStarted, data: serviceName);
  }

  /// Record service initialization completion
  void recordServiceComplete(String serviceName, {bool success = true}) {
    final metrics = _serviceMetrics[serviceName];
    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.duration = metrics.endTime!.difference(metrics.startTime!);
      metrics.success = success;

      _logger.startup(
        'Service ${success ? "completed" : "failed"}: $serviceName (${metrics.duration!.inMilliseconds}ms)',
        tag: 'DIAGNOSTICS',
      );

      _recordEvent(
        success ? StartupEventType.serviceCompleted : StartupEventType.serviceFailed,
        data: serviceName,
      );
    }
  }

  /// Record service timeout
  void recordServiceTimeout(String serviceName) {
    final metrics = _serviceMetrics[serviceName];
    if (metrics != null) {
      metrics.timedOut = true;
      metrics.endTime = DateTime.now();
      metrics.duration = metrics.endTime!.difference(metrics.startTime!);

      _logger.warning('Service timed out: $serviceName', tag: 'DIAGNOSTICS');
      _recordEvent(StartupEventType.serviceTimeout, data: serviceName);
    }
  }

  /// Record startup phase change
  void recordPhaseChange(StartupPhase phase) {
    _currentPhase = phase;
    _logger.startup('Phase changed: ${phase.name}', tag: 'DIAGNOSTICS');
    _recordEvent(StartupEventType.phaseChanged, data: phase.name);
  }

  /// Record memory spike
  void recordMemorySpike(double memoryMB) {
    if (_peakMemoryMB == null || memoryMB > _peakMemoryMB!) {
      _peakMemoryMB = memoryMB;
    }

    _logger.warning('Memory spike detected: ${memoryMB.toStringAsFixed(1)}MB', tag: 'DIAGNOSTICS');
    _recordEvent(StartupEventType.memorySpike, data: memoryMB.toStringAsFixed(1));
  }

  /// Get service metrics
  Map<String, ServiceMetrics> get serviceMetrics => Map.from(_serviceMetrics);

  /// Get total startup duration
  Duration? get totalDuration {
    if (_startupStartTime != null && _startupEndTime != null) {
      return _startupEndTime!.difference(_startupStartTime!);
    }
    return null;
  }

  /// Get slow services (over threshold)
  List<ServiceMetrics> getSlowServices({Duration threshold = const Duration(seconds: 2)}) {
    return _serviceMetrics.values
        .where((m) => m.duration != null && m.duration! > threshold)
        .toList()
      ..sort((a, b) => b.duration!.compareTo(a.duration!));
  }

  /// Get failed services
  List<ServiceMetrics> getFailedServices() {
    return _serviceMetrics.values
        .where((m) => !m.success)
        .toList();
  }

  /// Get timed out services
  List<ServiceMetrics> getTimedOutServices() {
    return _serviceMetrics.values
        .where((m) => m.timedOut)
        .toList();
  }

  /// Get events
  List<StartupEvent> get events => List.from(_events);

  /// Get diagnostics summary
  DiagnosticsSummary getSummary() {
    return DiagnosticsSummary(
      totalDuration: totalDuration,
      serviceMetrics: Map.from(_serviceMetrics),
      slowServices: getSlowServices(),
      failedServices: getFailedServices(),
      timedOutServices: getTimedOutServices(),
      initialMemoryMB: _initialMemoryMB,
      peakMemoryMB: _peakMemoryMB,
      finalMemoryMB: _finalMemoryMB,
      events: List.from(_events),
    );
  }

  /// Record event
  void _recordEvent(StartupEventType type, {String? data}) {
    _events.add(StartupEvent(
      type: type,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  /// Get current memory usage
  double _getCurrentMemoryMB() {
    // In production, this would use platform-specific memory APIs
    // For now, return a simulated value
    return 50.0; // Default 50MB
  }

  /// Log summary
  void _logSummary() {
    final summary = getSummary();

    _logger.startup('=== STARTUP DIAGNOSTICS SUMMARY ===', tag: 'DIAGNOSTICS');
    _logger.startup('Current Phase: $_currentPhase', tag: 'DIAGNOSTICS');
    _logger.startup('Total Duration: ${summary.totalDuration?.inMilliseconds ?? 0}ms', tag: 'DIAGNOSTICS');
    _logger.startup('Services Initialized: ${summary.serviceMetrics.length}', tag: 'DIAGNOSTICS');
    _logger.startup('Failed Services: ${summary.failedServices.length}', tag: 'DIAGNOSTICS');
    _logger.startup('Timed Out Services: ${summary.timedOutServices.length}', tag: 'DIAGNOSTICS');
    _logger.startup('Slow Services: ${summary.slowServices.length}', tag: 'DIAGNOSTICS');
    _logger.startup('Memory Usage: ${summary.initialMemoryMB?.toStringAsFixed(1)}MB → ${summary.finalMemoryMB?.toStringAsFixed(1)}MB (Peak: ${summary.peakMemoryMB?.toStringAsFixed(1)}MB)', tag: 'DIAGNOSTICS');
    _logger.startup('=== END SUMMARY ===', tag: 'DIAGNOSTICS');
  }

  /// Reset diagnostics
  void reset() {
    _serviceMetrics.clear();
    _startupStartTime = null;
    _startupEndTime = null;
    _currentPhase = StartupPhase.notStarted;
    _initialMemoryMB = null;
    _peakMemoryMB = null;
    _finalMemoryMB = null;
    _events.clear();
  }
}

/// Service metrics
class ServiceMetrics {
  final String serviceName;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  bool success;
  bool timedOut;

  ServiceMetrics({
    required this.serviceName,
    this.startTime,
    this.endTime,
    this.duration,
    this.success = false,
    this.timedOut = false,
  });
}

/// Startup event
class StartupEvent {
  final StartupEventType type;
  final DateTime timestamp;
  final String? data;

  StartupEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });
}

/// Startup event type
enum StartupEventType {
  diagnosticsStarted,
  diagnosticsCompleted,
  serviceStarted,
  serviceCompleted,
  serviceFailed,
  serviceTimeout,
  phaseChanged,
  memorySpike,
}

/// Startup phase
enum StartupPhase {
  notStarted,
  initialization,
  criticalServices,
  highPriorityServices,
  mediumPriorityServices,
  lowPriorityServices,
  completed,
}

/// Diagnostics summary
class DiagnosticsSummary {
  final Duration? totalDuration;
  final Map<String, ServiceMetrics> serviceMetrics;
  final List<ServiceMetrics> slowServices;
  final List<ServiceMetrics> failedServices;
  final List<ServiceMetrics> timedOutServices;
  final double? initialMemoryMB;
  final double? peakMemoryMB;
  final double? finalMemoryMB;
  final List<StartupEvent> events;

  DiagnosticsSummary({
    required this.totalDuration,
    required this.serviceMetrics,
    required this.slowServices,
    required this.failedServices,
    required this.timedOutServices,
    required this.initialMemoryMB,
    required this.peakMemoryMB,
    required this.finalMemoryMB,
    required this.events,
  });
}

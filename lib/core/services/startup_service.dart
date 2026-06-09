import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../diagnostics/startup_diagnostics.dart';
import 'notification_service.dart';
import 'optimization_service.dart';
import 'manufacturer_integration_service.dart';
import 'root_service.dart';
import 'game_database_service.dart';
import 'ai_recommendation_service.dart';
import 'advanced_storage_service.dart';
import 'scheduled_optimization_service.dart';

/// Startup service that manages safe, non-blocking initialization
/// of all Hone Mobile services with timeout protection and error recovery.
class StartupService {
  static StartupService? _instance;
  static StartupService get instance => _instance ??= StartupService._();

  StartupService._() {
    _logger.initialize(isProduction: kReleaseMode);
  }

  final Logger _logger = Logger.instance;
  final StartupDiagnostics _diagnostics = StartupDiagnostics.instance;

  // Startup state
  final _startupStateController = StreamController<StartupState>.broadcast();
  Stream<StartupState> get startupState => _startupStateController.stream;

  StartupState _currentState = StartupState.initializing();
  StartupState get currentState => _currentState;

  // Service initialization results
  final Map<String, ServiceInitResult> _serviceResults = {};
  Map<String, ServiceInitResult> get serviceResults => _serviceResults;

  // Safe mode flag
  bool _isSafeMode = false;
  bool get isSafeMode => _isSafeMode;

  // Low memory mode flag
  bool _isLowMemoryMode = false;
  bool get isLowMemoryMode => _isLowMemoryMode;

  // Initialization timeout (3 seconds per service)

  // Service definitions with priority and risk level
  static const List<ServiceDefinition> _services = [
    // CRITICAL - Must initialize first
    ServiceDefinition(
      name: 'Notifications',
      initializer: NotificationService.initialize,
      priority: ServicePriority.critical,
      risk: ServiceRisk.low,
      timeout: Duration(seconds: 2),
    ),

    // HIGH - Important but can fail safely
    ServiceDefinition(
      name: 'Optimization',
      initializer: OptimizationService.initialize,
      priority: ServicePriority.high,
      risk: ServiceRisk.medium,
      timeout: Duration(seconds: 3),
    ),
    ServiceDefinition(
      name: 'Game Database',
      initializer: GameDatabaseService.initialize,
      priority: ServicePriority.high,
      risk: ServiceRisk.low,
      timeout: Duration(seconds: 3),
    ),

    // MEDIUM - Can be deferred
    ServiceDefinition(
      name: 'Advanced Storage',
      initializer: AdvancedStorageService.initialize,
      priority: ServicePriority.medium,
      risk: ServiceRisk.medium,
      timeout: Duration(seconds: 5),
    ),
    ServiceDefinition(
      name: 'Scheduled Optimization',
      initializer: ScheduledOptimizationService.initialize,
      priority: ServicePriority.medium,
      risk: ServiceRisk.low,
      timeout: Duration(seconds: 3),
    ),

    // LOW - High risk, can fail safely
    ServiceDefinition(
      name: 'Manufacturer Integration',
      initializer: ManufacturerIntegrationService.initialize,
      priority: ServicePriority.low,
      risk: ServiceRisk.high,
      timeout: Duration(seconds: 3),
    ),
    ServiceDefinition(
      name: 'Root Service',
      initializer: RootService.initialize,
      priority: ServicePriority.low,
      risk: ServiceRisk.high,
      timeout: Duration(seconds: 3),
    ),
    ServiceDefinition(
      name: 'AI Recommendation',
      initializer: AIRecommendationService.initialize,
      priority: ServicePriority.low,
      risk: ServiceRisk.medium,
      timeout: Duration(seconds: 5),
    ),
  ];

  /// Initialize all services with safe, non-blocking architecture
  Future<void> initialize() async {
    try {
      _diagnostics.startStartup();
      _updateState(StartupState.initializing());
      _logger.startup('=== Starting Safe Startup Initialization ===');

      // Check memory status
      _checkMemoryStatus();

      // Group services by priority
      final criticalServices = _services
          .where((s) => s.priority == ServicePriority.critical)
          .toList();
      final highServices = _services
          .where((s) => s.priority == ServicePriority.high)
          .toList();
      final mediumServices = _services
          .where((s) => s.priority == ServicePriority.medium)
          .toList();
      final lowServices = _services
          .where((s) => s.priority == ServicePriority.low)
          .toList();

      // Initialize critical services first (sequentially for dependencies)
      _diagnostics.recordPhaseChange(StartupPhase.criticalServices);
      for (final service in criticalServices) {
        await _initializeService(service);
      }

      // Initialize high priority services in parallel
      _diagnostics.recordPhaseChange(StartupPhase.highPriorityServices);
      await _initializeGroup(highServices);

      // Initialize medium priority services in parallel
      _diagnostics.recordPhaseChange(StartupPhase.mediumPriorityServices);
      await _initializeGroup(mediumServices);

      // Initialize low priority services in parallel (can fail safely)
      _diagnostics.recordPhaseChange(StartupPhase.lowPriorityServices);
      await _initializeGroup(lowServices, allowFailures: true);

      // Check if we should enter safe mode
      _checkSafeMode();

      _diagnostics.endStartup();
      _updateState(StartupState.completed());
      _logger.startup('=== Startup Initialization Completed ===');
    } catch (e) {
      _logger.error('Startup initialization error', error: e);
      _updateState(StartupState.failed());
      _diagnostics.endStartup();
      // Even if startup fails, we don't crash - app continues in degraded mode
    }
  }

  /// Initialize a group of services in parallel
  Future<void> _initializeGroup(List<ServiceDefinition> services,
      {bool allowFailures = false}) async {
    if (services.isEmpty) return;

    final results = await Future.wait(
      services.map((s) => _initializeService(s)),
      eagerError: !allowFailures,
    );

    if (!allowFailures && results.any((r) => r == null)) {
      throw Exception('Critical service initialization failed');
    }
  }

  /// Initialize a single service with timeout protection
  Future<ServiceInitResult?> _initializeService(
      ServiceDefinition service) async {
    _diagnostics.recordServiceStart(service.name);
    _logger.startup('Initializing ${service.name}...');

    try {
      await service.initializer().timeout(service.timeout);

      _serviceResults[service.name] = ServiceInitResult(
        serviceName: service.name,
        success: true,
      );

      _diagnostics.recordServiceComplete(service.name, success: true);
      _logger.startup('✓ ${service.name} initialized');
      _updateState(StartupState.progress(
          service.name, _getProgressPercentage(service.name)));

      return _serviceResults[service.name];
    } on TimeoutException {
      _logger.warning('${service.name} initialization timed out', tag: 'STARTUP');
      _diagnostics.recordServiceTimeout(service.name);
      _diagnostics.recordServiceComplete(service.name, success: false);

      _serviceResults[service.name] = ServiceInitResult(
        serviceName: service.name,
        success: false,
        error: 'Initialization timeout',
      );

      // If high-risk service times out, continue anyway
      if (service.risk == ServiceRisk.high) {
        _logger.warning('High-risk service timed out, continuing startup', tag: 'STARTUP');
        return _serviceResults[service.name];
      }

      rethrow;
    } catch (e) {
      _logger.error('${service.name} failed', error: e, tag: 'STARTUP');
      _diagnostics.recordServiceComplete(service.name, success: false);

      _serviceResults[service.name] = ServiceInitResult(
        serviceName: service.name,
        success: false,
        error: e.toString(),
      );

      // If high-risk service fails, continue anyway
      if (service.risk == ServiceRisk.high) {
        _logger.warning('High-risk service failed, continuing startup', tag: 'STARTUP');
        return _serviceResults[service.name];
      }

      rethrow;
    }
  }

  /// Check if we should enter safe mode
  void _checkSafeMode() {
    final criticalFailures = _services
        .where((s) => s.priority == ServicePriority.critical)
        .where((s) =>
            _serviceResults[s.name]?.success == false ||
            _serviceResults[s.name] == null)
        .length;

    if (criticalFailures > 0) {
      _isSafeMode = true;
      _logger.warning('Entering SAFE MODE due to critical failures', tag: 'STARTUP');
    }
  }

  /// Check memory status and enable low-memory mode if needed
  void _checkMemoryStatus() {
    // Simulate memory check - in production this would use platform APIs
    const currentMemoryMB = 50.0; // Default 50MB

    if (currentMemoryMB > 150.0) {
      _isLowMemoryMode = true;
      _logger.warning('Low memory mode enabled', tag: 'STARTUP');
      _diagnostics.recordMemorySpike(currentMemoryMB);
    }
  }

  /// Get progress percentage for UI
  double _getProgressPercentage(String currentService) {
    final currentIndex = _services.indexWhere((s) => s.name == currentService);
    return ((currentIndex + 1) / _services.length * 100).clamp(0, 100);
  }

  /// Update startup state
  void _updateState(StartupState state) {
    _currentState = state;
    _startupStateController.add(state);
  }

  /// Reset startup state (for testing/recovery)
  void reset() {
    _serviceResults.clear();
    _isSafeMode = false;
    _isLowMemoryMode = false;
    _currentState = StartupState.initializing();
    _diagnostics.reset();
  }

  /// Get diagnostics summary
  DiagnosticsSummary get diagnosticsSummary => _diagnostics.getSummary();

  /// Dispose resources
  void dispose() {
    _startupStateController.close();
  }
}

/// Service definition with metadata
class ServiceDefinition {
  final String name;
  final Future<void> Function() initializer;
  final ServicePriority priority;
  final ServiceRisk risk;
  final Duration timeout;

  const ServiceDefinition({
    required this.name,
    required this.initializer,
    required this.priority,
    required this.risk,
    required this.timeout,
  });
}

/// Service initialization result
class ServiceInitResult {
  final String serviceName;
  final bool success;
  final String? error;

  ServiceInitResult({
    required this.serviceName,
    required this.success,
    this.error,
  });
}

/// Service priority levels
enum ServicePriority { critical, high, medium, low }

/// Service risk levels
enum ServiceRisk { low, medium, high }

/// Startup state for UI
class StartupState {
  final StartupStatus status;
  final String? currentService;
  final double progress;

  const StartupState({
    required this.status,
    this.currentService,
    this.progress = 0,
  });

  factory StartupState.initializing() =>
      const StartupState(status: StartupStatus.initializing);

  factory StartupState.progress(String service, double progress) =>
      StartupState(
        status: StartupStatus.inProgress,
        currentService: service,
        progress: progress,
      );

  factory StartupState.completed() =>
      const StartupState(status: StartupStatus.completed);

  factory StartupState.failed() =>
      const StartupState(status: StartupStatus.failed);
}

/// Startup status enum
enum StartupStatus { initializing, inProgress, completed, failed }

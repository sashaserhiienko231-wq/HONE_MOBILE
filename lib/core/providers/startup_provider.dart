import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../diagnostics/startup_diagnostics.dart';
import '../services/startup_service.dart';

/// Provider for startup service instance
final startupServiceProvider = Provider<StartupService>((ref) {
  final service = StartupService.instance;
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for startup state stream
final startupStateProvider = StreamProvider<StartupState>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.startupState;
});

/// Provider for current startup state
final currentStartupStateProvider = Provider<StartupState>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.currentState;
});

/// Provider for service initialization results
final serviceResultsProvider = Provider<Map<String, ServiceInitResult>>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.serviceResults;
});

/// Provider for safe mode status
final safeModeProvider = Provider<bool>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.isSafeMode;
});

/// Provider for low memory mode status
final lowMemoryModeProvider = Provider<bool>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.isLowMemoryMode;
});

/// Provider for diagnostics summary
final diagnosticsSummaryProvider = Provider<DiagnosticsSummary>((ref) {
  final service = ref.watch(startupServiceProvider);
  return service.diagnosticsSummary;
});

/// Provider to trigger startup initialization
final startupInitializerProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(startupServiceProvider);
  await service.initialize();
});

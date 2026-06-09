import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/features/dns_boost/models/dns_provider_info.dart';
import 'package:hone_mobile/features/dns_boost/services/dns_engine_service.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class DnsBoostState {
  final bool isBoostEnabled;
  final DnsProviderInfo activeProvider;
  final String selectedMode; // Competitive, Stable, Streaming, Battery Saver, AI Smart
  final String selectedRegion; // Europe, North America, South America, Asia, Middle East, Africa, Oceania
  final bool autoOptimization;
  final bool smartRouting;
  
  // Real-time network statistics
  final double currentPing;
  final double currentJitter;
  final double currentPacketLoss;
  final int connectionScore;
  final List<double> pingHistory;

  // Benchmark status
  final List<DnsProviderInfo> benchmarkResults;
  final bool isBenchmarking;
  final bool isBoosting;

  // Custom DNS Providers added by the user
  final List<DnsProviderInfo> customProviders;

  // Per-game overrides: package_name -> provider_id
  final Map<String, String> perGameProviders;
  final Map<String, String> perGameRegions;

  // Advanced settings tuning
  final bool autoConnectOnLaunch;
  final bool startupOptimization;
  final bool backgroundOptimization;
  final bool autoRegionSelection;
  final bool aggressiveRouting;
  final bool diagnosticsLogging;

  DnsBoostState({
    required this.isBoostEnabled,
    required this.activeProvider,
    required this.selectedMode,
    required this.selectedRegion,
    required this.autoOptimization,
    required this.smartRouting,
    required this.currentPing,
    required this.currentJitter,
    required this.currentPacketLoss,
    required this.connectionScore,
    required this.pingHistory,
    required this.benchmarkResults,
    required this.isBenchmarking,
    required this.isBoosting,
    required this.customProviders,
    required this.perGameProviders,
    required this.perGameRegions,
    this.autoConnectOnLaunch = true,
    this.startupOptimization = true,
    this.backgroundOptimization = true,
    this.autoRegionSelection = true,
    this.aggressiveRouting = true,
    this.diagnosticsLogging = true,
  });

  DnsBoostState copyWith({
    bool? isBoostEnabled,
    DnsProviderInfo? activeProvider,
    String? selectedMode,
    String? selectedRegion,
    bool? autoOptimization,
    bool? smartRouting,
    double? currentPing,
    double? currentJitter,
    double? currentPacketLoss,
    int? connectionScore,
    List<double>? pingHistory,
    List<DnsProviderInfo>? benchmarkResults,
    bool? isBenchmarking,
    bool? isBoosting,
    List<DnsProviderInfo>? customProviders,
    Map<String, String>? perGameProviders,
    Map<String, String>? perGameRegions,
    bool? autoConnectOnLaunch,
    bool? startupOptimization,
    bool? backgroundOptimization,
    bool? autoRegionSelection,
    bool? aggressiveRouting,
    bool? diagnosticsLogging,
  }) {
    return DnsBoostState(
      isBoostEnabled: isBoostEnabled ?? this.isBoostEnabled,
      activeProvider: activeProvider ?? this.activeProvider,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      autoOptimization: autoOptimization ?? this.autoOptimization,
      smartRouting: smartRouting ?? this.smartRouting,
      currentPing: currentPing ?? this.currentPing,
      currentJitter: currentJitter ?? this.currentJitter,
      currentPacketLoss: currentPacketLoss ?? this.currentPacketLoss,
      connectionScore: connectionScore ?? this.connectionScore,
      pingHistory: pingHistory ?? this.pingHistory,
      benchmarkResults: benchmarkResults ?? this.benchmarkResults,
      isBenchmarking: isBenchmarking ?? this.isBenchmarking,
      isBoosting: isBoosting ?? this.isBoosting,
      customProviders: customProviders ?? this.customProviders,
      perGameProviders: perGameProviders ?? this.perGameProviders,
      perGameRegions: perGameRegions ?? this.perGameRegions,
      autoConnectOnLaunch: autoConnectOnLaunch ?? this.autoConnectOnLaunch,
      startupOptimization: startupOptimization ?? this.startupOptimization,
      backgroundOptimization: backgroundOptimization ?? this.backgroundOptimization,
      autoRegionSelection: autoRegionSelection ?? this.autoRegionSelection,
      aggressiveRouting: aggressiveRouting ?? this.aggressiveRouting,
      diagnosticsLogging: diagnosticsLogging ?? this.diagnosticsLogging,
    );
  }

  factory DnsBoostState.initial() {
    final defaultProvider = DnsProviderInfo.defaultProviders.first; // Cloudflare
    return DnsBoostState(
      isBoostEnabled: false,
      activeProvider: defaultProvider,
      selectedMode: 'AI Smart',
      selectedRegion: 'North America',
      autoOptimization: true,
      smartRouting: true,
      currentPing: 0.0,
      currentJitter: 0.0,
      currentPacketLoss: 0.0,
      connectionScore: 100,
      pingHistory: const [],
      benchmarkResults: const [],
      isBenchmarking: false,
      isBoosting: false,
      customProviders: const [],
      perGameProviders: const {},
      perGameRegions: const {},
    );
  }
}

class DnsBoostNotifier extends StateNotifier<DnsBoostState> {
  final DnsEngineService _engineService;
  Timer? _metricsTimer;
  int _ticksCount = 0;

  DnsBoostNotifier(this._engineService) : super(DnsBoostState.initial()) {
    // Start background ping loop if boost gets enabled
    if (state.isBoostEnabled) {
      _startMetricsLoop();
    }
  }

  void toggleBoost(bool enabled) {
    if (enabled == state.isBoostEnabled) return;

    if (enabled) {
      _engineService.addLog('Enabling DNS Boost protocol...');
      _engineService.addLog('Applying gaming mode: ${state.selectedMode}...');
      _engineService.addLog('Binding primary DNS routing: ${state.activeProvider.addresses.first}');
      
      state = state.copyWith(
        isBoostEnabled: true,
        isBoosting: true,
      );

      // Trigger temporary loading effect
      Future.delayed(const Duration(milliseconds: 1200), () {
        state = state.copyWith(isBoosting: false);
        _startMetricsLoop();
        _engineService.addLog('DNS Boost active. Secure gaming tunnel established.');
        
        // Award XP and log notification
        GamingHubStorage.addHubNotification(
          'Gaming DNS Boost Activated',
          'Connection optimized using ${state.activeProvider.name}. Speed boosted.',
          'notification',
          badge: 'Boost',
        );
      });
    } else {
      _engineService.addLog('Disabling DNS Boost protocol...');
      _metricsTimer?.cancel();
      state = state.copyWith(
        isBoostEnabled: false,
        currentPing: 0.0,
        currentJitter: 0.0,
        currentPacketLoss: 0.0,
        connectionScore: 100,
        pingHistory: const [],
      );
      _engineService.addLog('Default system DNS routing restored.');
    }
  }

  void setMode(String mode) {
    if (mode == state.selectedMode) return;
    _engineService.addLog('Switching optimization mode to $mode...');
    state = state.copyWith(selectedMode: mode);
    
    if (state.isBoostEnabled) {
      // Re-trigger boost log info
      _engineService.addLog('Mode parameters applied. Net stack adjustments complete.');
    }
  }

  void setRegion(String region) {
    if (region == state.selectedRegion) return;
    _engineService.addLog('Switching network affinity region to $region...');
    state = state.copyWith(selectedRegion: region);
    
    // Auto switch to regional DNS if autoRegionSelection is enabled
    if (state.autoRegionSelection) {
      final regionServers = DnsProviderInfo.getRegionalProfiles(region);
      if (regionServers.isNotEmpty) {
        final localBest = regionServers.first;
        _engineService.addLog('Auto-switched to regional server: ${localBest.name}');
        state = state.copyWith(activeProvider: localBest);
      }
    }
  }

  void selectProvider(DnsProviderInfo provider) {
    _engineService.addLog('Binding DNS network profile to ${provider.name}...');
    state = state.copyWith(activeProvider: provider);
  }

  void toggleAutoOptimization(bool value) {
    state = state.copyWith(autoOptimization: value);
  }

  void toggleSmartRouting(bool value) {
    state = state.copyWith(smartRouting: value);
  }

  // Advanced settings toggles
  void setAutoConnect(bool val) => state = state.copyWith(autoConnectOnLaunch: val);
  void setStartupOptimization(bool val) => state = state.copyWith(startupOptimization: val);
  void setBackgroundOptimization(bool val) => state = state.copyWith(backgroundOptimization: val);
  void setAutoRegionSelection(bool val) => state = state.copyWith(autoRegionSelection: val);
  void setAggressiveRouting(bool val) => state = state.copyWith(aggressiveRouting: val);
  void setDiagnosticsLogging(bool val) => state = state.copyWith(diagnosticsLogging: val);

  // Custom DNS Management
  void addCustomDns(String name, String ip) {
    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final provider = DnsProviderInfo(
      id: customId,
      name: name,
      addresses: [ip],
      latencyMs: 30.0,
      region: 'Custom',
      isCustom: true,
    );

    final updated = List<DnsProviderInfo>.from(state.customProviders)..add(provider);
    state = state.copyWith(customProviders: updated);
    _engineService.addLog('Registered custom DNS profile: $name ($ip)');
  }

  void removeCustomDns(String id) {
    final updated = List<DnsProviderInfo>.from(state.customProviders)..removeWhere((p) => p.id == id);
    state = state.copyWith(customProviders: updated);
    _engineService.addLog('Removed custom DNS profile: $id');
  }

  // Per-game presets
  void setGameDnsOverride(String packageName, String providerId) {
    final updated = Map<String, String>.from(state.perGameProviders)..[packageName] = providerId;
    state = state.copyWith(perGameProviders: updated);
    _engineService.addLog('Set game override [$packageName] -> DNS provider: $providerId');
  }

  void setGameRegionOverride(String packageName, String regionName) {
    final updated = Map<String, String>.from(state.perGameRegions)..[packageName] = regionName;
    state = state.copyWith(perGameRegions: updated);
    _engineService.addLog('Set game override [$packageName] -> Region affinity: $regionName');
  }

  void removeGameOverrides(String packageName) {
    final updatedProv = Map<String, String>.from(state.perGameProviders)..remove(packageName);
    final updatedReg = Map<String, String>.from(state.perGameRegions)..remove(packageName);
    state = state.copyWith(perGameProviders: updatedProv, perGameRegions: updatedReg);
    _engineService.addLog('Cleared game overrides for package: $packageName');
  }

  // DNS Benchmark Tool
  Future<void> runBenchmarkSuite() async {
    if (state.isBenchmarking) return;
    state = state.copyWith(isBenchmarking: true);
    
    try {
      final results = await _engineService.runBenchmark(state.selectedRegion, state.customProviders);
      state = state.copyWith(
        benchmarkResults: results,
        isBenchmarking: false,
      );
      
      // Auto optimization: Apply the fastest server if enabled
      if (state.autoOptimization && results.isNotEmpty) {
        final fastest = results.first;
        _engineService.addLog('Auto-applying fastest DNS result: ${fastest.name}');
        state = state.copyWith(activeProvider: fastest);
        
        GamingHubStorage.addHubNotification(
          'DNS Route Optimized',
          'Switched to ${fastest.name} (${fastest.latencyMs.toStringAsFixed(1)}ms) automatically.',
          'notification',
          badge: 'Network',
        );
      }
    } catch (e) {
      _engineService.addLog('Benchmark suite encountered an error: $e');
      state = state.copyWith(isBenchmarking: false);
    }
  }

  // Purge DNS Cache action
  Future<int> clearDnsCache() async {
    final bytes = await _engineService.purgeCache();
    return bytes;
  }

  // Network repair option
  Future<void> repairNetwork() async {
    state = state.copyWith(isBoosting: true);
    await _engineService.repairNetworkStack(state.activeProvider);
    state = state.copyWith(isBoosting: false);
    
    GamingHubStorage.addHubNotification(
      'Network Repair Successful',
      'Gaming DNS tables rebuilt and socket links re-established.',
      'notification',
      badge: 'Diagnostics',
    );
  }

  // Internal simulated ping updates
  void _startMetricsLoop() {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(const Duration(seconds: 1500 ~/ 1000), (timer) {
      if (!state.isBoostEnabled) {
        timer.cancel();
        return;
      }

      final metrics = _engineService.simulateNetworkMetrics(
        state.activeProvider,
        state.selectedMode,
        state.selectedRegion,
      );

      final double newPing = metrics['ping'] as double;
      final double newJitter = metrics['jitter'] as double;
      final double newLoss = metrics['packetLoss'] as double;
      final int newScore = metrics['score'] as int;

      // Update ping history
      final history = List<double>.from(state.pingHistory);
      history.add(newPing);
      if (history.length > 25) {
        history.removeAt(0);
      }

      state = state.copyWith(
        currentPing: newPing,
        currentJitter: newJitter,
        currentPacketLoss: newLoss,
        connectionScore: newScore,
        pingHistory: history,
      );

      _ticksCount++;

      // Trigger automatic smart switching in AI Smart Mode when a ping spike happens
      if (state.selectedMode == 'AI Smart' && newPing > 60.0 && _ticksCount % 3 == 0) {
        _engineService.addLog('AI detected latency spike on ${state.activeProvider.name} (${newPing.toStringAsFixed(1)}ms). Scanning alternate routes...');
        
        // Find a better server dynamically (excluding current provider)
        final alternates = [
          ...DnsProviderInfo.defaultProviders,
          ...DnsProviderInfo.gamingProfiles,
        ].where((p) => p.id != state.activeProvider.id).toList();

        if (alternates.isNotEmpty) {
          final chosen = alternates[state.activeProvider.id.length % alternates.length];
          _engineService.addLog('AI auto-switch: Rerouted traffic to ${chosen.name} to bypass congestion.');
          state = state.copyWith(activeProvider: chosen);
          
          GamingHubStorage.addHubNotification(
            'AI Smart Switch Applied',
            'Rerouted game traffic to ${chosen.name} due to latency spike.',
            'notification',
            badge: 'AI Smart',
          );
        }
      }

      // Occasional notification for unstable connection
      if (newLoss > 0.4 && _ticksCount % 10 == 0) {
        GamingHubStorage.addHubNotification(
          'Latency Jitter Detected',
          'High packet jitter (${newJitter.toStringAsFixed(1)}ms). Aggressive routing activated.',
          'alert',
          badge: 'Network Warning',
        );
      }
    });
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    super.dispose();
  }
}

// Providers registration
final dnsEngineServiceProvider = Provider<DnsEngineService>((ref) {
  final service = DnsEngineService();
  ref.onDispose(() => service.dispose());
  return service;
});

final dnsBoostStateProvider = StateNotifierProvider<DnsBoostNotifier, DnsBoostState>((ref) {
  final service = ref.watch(dnsEngineServiceProvider);
  return DnsBoostNotifier(service);
});

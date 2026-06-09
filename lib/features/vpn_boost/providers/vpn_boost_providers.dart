import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/features/vpn_boost/models/vpn_models.dart';
import 'package:hone_mobile/features/vpn_boost/services/vpn_connection_service.dart';

class VpnBoostState {
  final List<VpnServer> servers;
  final List<VpnGamingProfile> profiles;
  final VpnServer selectedServer;
  final VpnGamingProfile selectedProfile;
  final VpnConnectionSnapshot connection;
  final VpnServerCategory selectedCategory;
  final String serverQuery;
  final Set<String> favoriteServerIds;
  final VpnServer? lastUsedServer;
  final List<VpnSessionRecord> sessionHistory;
  final VpnAnalyticsSnapshot analytics;
  final List<double> pingHistory;
  final List<double> trafficHistory;
  final VpnSettings settings;
  final List<String> diagnosticLogs;

  const VpnBoostState({
    required this.servers,
    required this.profiles,
    required this.selectedServer,
    required this.selectedProfile,
    required this.connection,
    required this.selectedCategory,
    required this.serverQuery,
    required this.favoriteServerIds,
    required this.lastUsedServer,
    required this.sessionHistory,
    required this.analytics,
    required this.pingHistory,
    required this.trafficHistory,
    required this.settings,
    required this.diagnosticLogs,
  });

  bool get isConnected => connection.status == VpnConnectionStatus.connected;
  bool get isBusy =>
      connection.status == VpnConnectionStatus.connecting ||
      connection.status == VpnConnectionStatus.disconnecting;

  VpnBoostState copyWith({
    List<VpnServer>? servers,
    List<VpnGamingProfile>? profiles,
    VpnServer? selectedServer,
    VpnGamingProfile? selectedProfile,
    VpnConnectionSnapshot? connection,
    VpnServerCategory? selectedCategory,
    String? serverQuery,
    Set<String>? favoriteServerIds,
    VpnServer? lastUsedServer,
    bool? clearLastUsedServer,
    List<VpnSessionRecord>? sessionHistory,
    VpnAnalyticsSnapshot? analytics,
    List<double>? pingHistory,
    List<double>? trafficHistory,
    VpnSettings? settings,
    List<String>? diagnosticLogs,
  }) {
    return VpnBoostState(
      servers: servers ?? this.servers,
      profiles: profiles ?? this.profiles,
      selectedServer: selectedServer ?? this.selectedServer,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      connection: connection ?? this.connection,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      serverQuery: serverQuery ?? this.serverQuery,
      favoriteServerIds: favoriteServerIds ?? this.favoriteServerIds,
      lastUsedServer: clearLastUsedServer == true
          ? null
          : lastUsedServer ?? this.lastUsedServer,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      analytics: analytics ?? this.analytics,
      pingHistory: pingHistory ?? this.pingHistory,
      trafficHistory: trafficHistory ?? this.trafficHistory,
      settings: settings ?? this.settings,
      diagnosticLogs: diagnosticLogs ?? this.diagnosticLogs,
    );
  }

  factory VpnBoostState.initial() {
    final servers = VpnServer.defaultServers;
    final profiles = VpnGamingProfile.defaults;
    final selectedProfile = profiles.first;
    final selectedServer = List<VpnServer>.from(servers)
      ..sort((a, b) => b.connectionScore.compareTo(a.connectionScore));

    return VpnBoostState(
      servers: servers,
      profiles: profiles,
      selectedServer: selectedServer.first,
      selectedProfile: selectedProfile,
      connection: VpnConnectionSnapshot.disconnected(selectedProfile),
      selectedCategory: VpnServerCategory.recommended,
      serverQuery: '',
      favoriteServerIds: const {},
      lastUsedServer: null,
      sessionHistory: const [],
      analytics: VpnAnalyticsSnapshot.empty(),
      pingHistory: const [],
      trafficHistory: const [],
      settings: VpnSettings.defaults(),
      diagnosticLogs: const [],
    );
  }
}

class VpnBoostNotifier extends StateNotifier<VpnBoostState> {
  final VpnConnectionService _service;
  Timer? _metricsTimer;
  int _tickCount = 0;

  VpnBoostNotifier(this._service) : super(VpnBoostState.initial()) {
    _syncLogs();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(serverQuery: query);
  }

  void setCategory(VpnServerCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectServer(VpnServer server) {
    _service.addLog(
        'Selected ${server.country} / ${server.city} as VPN route target.');
    state = state.copyWith(
      selectedServer: server,
      selectedCategory: server.categories.contains(state.selectedCategory)
          ? state.selectedCategory
          : VpnServerCategory.recommended,
      diagnosticLogs: _service.diagnosticLogs,
    );
  }

  void selectProfile(VpnGamingProfile profile) {
    _service.addLog('VPN gaming profile set to ${profile.title}.');
    state = state.copyWith(
      selectedProfile: profile,
      connection: state.connection.copyWith(profile: profile),
      diagnosticLogs: _service.diagnosticLogs,
    );
  }

  Future<void> connect({VpnServer? server}) async {
    if (state.isBusy) return;

    final target = server ?? state.selectedServer;
    final profile = state.selectedProfile;
    _metricsTimer?.cancel();
    state = state.copyWith(
      selectedServer: target,
      connection: state.connection.copyWith(
        status: VpnConnectionStatus.connecting,
        server: target,
        profile: profile,
        securityStatus: 'Negotiating encrypted route',
      ),
      diagnosticLogs: _service.diagnosticLogs,
    );

    try {
      final connected =
          await _service.connect(server: target, profile: profile);
      if (!mounted) return;

      state = state.copyWith(
        connection: connected,
        selectedServer: target,
        lastUsedServer: target,
        pingHistory: [connected.pingMs],
        trafficHistory: const [0],
        analytics: _service.buildAnalytics(
          sessions: state.sessionHistory,
          livePingGraph: [connected.pingMs],
          liveTrafficGraph: const [0],
        ),
        diagnosticLogs: _service.diagnosticLogs,
      );
      _startMetricsLoop();
    } catch (error) {
      _service.addLog('VPN connection failed: $error');
      if (!mounted) return;
      state = state.copyWith(
        connection: VpnConnectionSnapshot.disconnected(profile),
        diagnosticLogs: _service.diagnosticLogs,
      );
    }
  }

  Future<void> disconnect() async {
    if (state.connection.status != VpnConnectionStatus.connected ||
        state.isBusy) {
      return;
    }

    final activeSnapshot = state.connection;
    final sessionRecord =
        _service.createSessionRecord(activeSnapshot, state.pingHistory);
    _metricsTimer?.cancel();

    state = state.copyWith(
      connection:
          activeSnapshot.copyWith(status: VpnConnectionStatus.disconnecting),
    );

    final disconnected = await _service.disconnect(activeSnapshot);
    if (!mounted) return;

    final updatedSessions = [
      if (sessionRecord != null) sessionRecord,
      ...state.sessionHistory,
    ].take(12).toList();

    state = state.copyWith(
      connection: disconnected,
      sessionHistory: updatedSessions,
      analytics: _service.buildAnalytics(
        sessions: updatedSessions,
        livePingGraph: state.pingHistory,
        liveTrafficGraph: state.trafficHistory,
      ),
      diagnosticLogs: _service.diagnosticLogs,
    );
  }

  Future<void> quickConnect(VpnQuickConnectOption option) async {
    final target = _service.resolveQuickConnect(
      option: option,
      servers: state.servers,
      favoriteIds: state.favoriteServerIds,
      lastUsedServer: state.lastUsedServer,
    );
    _service.addLog(
        'Quick Connect requested: ${option.label} -> ${target.country}.');
    state = state.copyWith(diagnosticLogs: _service.diagnosticLogs);
    await connect(server: target);
  }

  void toggleFavorite(String serverId) {
    final updated = Set<String>.from(state.favoriteServerIds);
    if (updated.contains(serverId)) {
      updated.remove(serverId);
      _service.addLog('Removed VPN server from favorites: $serverId');
    } else {
      updated.add(serverId);
      _service.addLog('Added VPN server to favorites: $serverId');
    }

    state = state.copyWith(
      favoriteServerIds: updated,
      diagnosticLogs: _service.diagnosticLogs,
    );
  }

  void setKillSwitch(bool value) {
    state =
        state.copyWith(settings: state.settings.copyWith(killSwitch: value));
  }

  void setAutoReconnect(bool value) {
    state =
        state.copyWith(settings: state.settings.copyWith(autoReconnect: value));
  }

  void setBlockTrackers(bool value) {
    state =
        state.copyWith(settings: state.settings.copyWith(blockTrackers: value));
  }

  void setLanBypass(bool value) {
    state = state.copyWith(settings: state.settings.copyWith(lanBypass: value));
  }

  void setDiagnosticsLogging(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(diagnosticsLogging: value),
    );
  }

  void setPrepareSdkBridge(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(prepareSdkBridge: value),
    );
  }

  void _startMetricsLoop() {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.connection.status != VpnConnectionStatus.connected) {
        timer.cancel();
        return;
      }

      final refreshed = _service.refresh(state.connection);
      final pingHistory = [...state.pingHistory, refreshed.pingMs];
      if (pingHistory.length > 30) {
        pingHistory.removeAt(0);
      }

      final trafficTotal =
          refreshed.trafficDownloadedMb + refreshed.trafficUploadedMb;
      final trafficHistory = [...state.trafficHistory, trafficTotal];
      if (trafficHistory.length > 30) {
        trafficHistory.removeAt(0);
      }

      _tickCount++;
      state = state.copyWith(
        connection: refreshed,
        pingHistory: pingHistory,
        trafficHistory: trafficHistory,
        analytics: _service.buildAnalytics(
          sessions: state.sessionHistory,
          livePingGraph: pingHistory,
          liveTrafficGraph: trafficHistory,
        ),
        diagnosticLogs: _service.diagnosticLogs,
      );

      if (state.selectedProfile.id == 'ai_smart' &&
          refreshed.pingMs > 70 &&
          _tickCount % 4 == 0) {
        final fallback = _service.resolveQuickConnect(
          option: VpnQuickConnectOption.lowestPing,
          servers: state.servers,
          favoriteIds: state.favoriteServerIds,
          lastUsedServer: state.lastUsedServer,
        );
        if (fallback.id != state.selectedServer.id) {
          _service.addLog(
            'AI Smart detected ping spike and staged ${fallback.country} as the next route.',
          );
          state = state.copyWith(
            selectedServer: fallback,
            diagnosticLogs: _service.diagnosticLogs,
          );
        }
      }
    });
  }

  void _syncLogs() {
    _service.addLog(
        'VPN Boost provider architecture initialized in simulation mode.');
    state = state.copyWith(diagnosticLogs: _service.diagnosticLogs);
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    super.dispose();
  }
}

final vpnConnectionServiceProvider = Provider<VpnConnectionService>((ref) {
  final service = VpnConnectionService();
  ref.onDispose(service.dispose);
  return service;
});

final vpnBoostStateProvider =
    StateNotifierProvider<VpnBoostNotifier, VpnBoostState>((ref) {
  final service = ref.watch(vpnConnectionServiceProvider);
  return VpnBoostNotifier(service);
});

final vpnFilteredServersProvider = Provider<List<VpnServer>>((ref) {
  final state = ref.watch(vpnBoostStateProvider);
  final service = ref.watch(vpnConnectionServiceProvider);
  return service.filterServers(
    servers: state.servers,
    category: state.selectedCategory,
    query: state.serverQuery,
  );
});

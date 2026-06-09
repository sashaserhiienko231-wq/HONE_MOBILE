import 'dart:async';

import 'package:hone_mobile/features/vpn_boost/models/vpn_models.dart';
import 'package:hone_mobile/features/vpn_boost/services/vpn_platform_channel.dart';

abstract class VpnProviderGateway {
  Future<VpnConnectionSnapshot> connect({
    required VpnServer server,
    required VpnGamingProfile profile,
  });

  Future<VpnConnectionSnapshot> disconnect(VpnConnectionSnapshot current);

  VpnConnectionSnapshot refresh(VpnConnectionSnapshot current);
}

// Real VPN gateway placeholder.
// This Phase-6 implementation will wire to Android's WireGuard tunnel runtime.
// For now, keep the abstraction in place; the simulated provider will be removed
// once the Android platform channel is added.
class VpnProviderGatewayWireGuardAdapter implements VpnProviderGateway {
  final VpnPlatformChannel _platform = VpnPlatformChannel.instance;

  @override
  Future<VpnConnectionSnapshot> connect({
    required VpnServer server,
    required VpnGamingProfile profile,
  }) async {
    // Android integration not yet completed; return explicit not-configured
    // failure instead of simulated values.
    throw UnimplementedError(
      'WireGuard tunnel connection not wired yet. Android integration pending.',
    );
  }

  @override
  Future<VpnConnectionSnapshot> disconnect(
    VpnConnectionSnapshot current,
  ) async {
    throw UnimplementedError(
      'WireGuard tunnel disconnect not wired yet. Android integration pending.',
    );
  }

  @override
  VpnConnectionSnapshot refresh(VpnConnectionSnapshot current) {
    // When real tunnel stats are available, update snapshot from platform channel.
    return current;
  }
}

class VpnConnectionService {
  final VpnProviderGateway gateway;

  // When wired, gateway will call VpnPlatformChannel methods.

  /// WireGuard integration entrypoint.
  ///
  /// We keep `VpnConnectionService` as the single place that the UI interacts with,
  /// so that the underlying VPN provider can be swapped without touching the UI.

  final List<String> _diagnosticLogs = [];
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();

  VpnConnectionService({VpnProviderGateway? gateway})
      : gateway = gateway ?? VpnProviderGatewayWireGuardAdapter();

  Stream<String> get logStream => _logStreamController.stream;
  List<String> get diagnosticLogs => List.unmodifiable(_diagnosticLogs);

  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final line = '[$timestamp] $message';
    _diagnosticLogs.add(line);
    if (_diagnosticLogs.length > 120) {
      _diagnosticLogs.removeAt(0);
    }
    _logStreamController.add(line);
  }

  Future<VpnConnectionSnapshot> connect({
    required VpnServer server,
    required VpnGamingProfile profile,
  }) async {
    addLog(
        'Preparing VPN provider session for ${server.country} / ${server.city}...');
    addLog('Profile handshake: ${profile.title}.');
    final snapshot = await gateway.connect(server: server, profile: profile);
    addLog(
        'VPN session connected through ${server.country} (${snapshot.currentIp}).');
    return snapshot;
  }

  Future<VpnConnectionSnapshot> disconnect(
      VpnConnectionSnapshot current) async {
    addLog('Stopping VPN session and restoring default route...');
    final snapshot = await gateway.disconnect(current);
    addLog('VPN session disconnected.');
    return snapshot;
  }

  VpnConnectionSnapshot refresh(VpnConnectionSnapshot current) {
    return gateway.refresh(current);
  }

  List<VpnServer> filterServers({
    required List<VpnServer> servers,
    required VpnServerCategory category,
    required String query,
  }) {
    final filtered = servers.where((server) {
      return server.categories.contains(category) && server.matches(query);
    }).toList();

    switch (category) {
      case VpnServerCategory.lowestPing:
        filtered.sort((a, b) => a.pingMs.compareTo(b.pingMs));
        break;
      case VpnServerCategory.gaming:
        filtered.sort((a, b) => b.gamingScore.compareTo(a.gamingScore));
        break;
      case VpnServerCategory.streaming:
        filtered.sort((a, b) => b.speedScore.compareTo(a.speedScore));
        break;
      case VpnServerCategory.security:
        filtered
            .sort((a, b) => b.stabilityPercent.compareTo(a.stabilityPercent));
        break;
      case VpnServerCategory.recommended:
        filtered.sort((a, b) => b.connectionScore.compareTo(a.connectionScore));
        break;
    }

    return filtered;
  }

  VpnServer resolveQuickConnect({
    required VpnQuickConnectOption option,
    required List<VpnServer> servers,
    required Set<String> favoriteIds,
    VpnServer? lastUsedServer,
  }) {
    if (servers.isEmpty) {
      throw StateError('No VPN servers available.');
    }

    switch (option) {
      case VpnQuickConnectOption.autoBest:
        final ranked = List<VpnServer>.from(servers)
          ..sort((a, b) => b.connectionScore.compareTo(a.connectionScore));
        return ranked.first;
      case VpnQuickConnectOption.fastest:
        final ranked = List<VpnServer>.from(servers)
          ..sort((a, b) => b.speedScore.compareTo(a.speedScore));
        return ranked.first;
      case VpnQuickConnectOption.lowestPing:
        final ranked = List<VpnServer>.from(servers)
          ..sort((a, b) => a.pingMs.compareTo(b.pingMs));
        return ranked.first;
      case VpnQuickConnectOption.lastUsed:
        return lastUsedServer ??
            resolveQuickConnect(
              option: VpnQuickConnectOption.autoBest,
              servers: servers,
              favoriteIds: favoriteIds,
            );
      case VpnQuickConnectOption.favorite:
        final favorites =
            servers.where((server) => favoriteIds.contains(server.id)).toList();
        if (favorites.isEmpty) {
          return resolveQuickConnect(
            option: VpnQuickConnectOption.autoBest,
            servers: servers,
            favoriteIds: favoriteIds,
          );
        }
        favorites
            .sort((a, b) => b.connectionScore.compareTo(a.connectionScore));
        return favorites.first;
    }
  }

  VpnAnalyticsSnapshot buildAnalytics({
    required List<VpnSessionRecord> sessions,
    required List<double> livePingGraph,
    required List<double> liveTrafficGraph,
  }) {
    final totalDownload = sessions.fold<double>(
      0,
      (sum, session) => sum + session.trafficDownloadedMb,
    );
    final totalUpload = sessions.fold<double>(
      0,
      (sum, session) => sum + session.trafficUploadedMb,
    );

    final avgPing = sessions.isEmpty
        ? (livePingGraph.isEmpty
            ? 0.0
            : livePingGraph.reduce((a, b) => a + b) / livePingGraph.length)
        : sessions.fold<double>(
                0, (sum, session) => sum + session.averagePingMs) /
            sessions.length;

    final usage = <String, int>{};
    for (final session in sessions) {
      usage[session.region] = (usage[session.region] ?? 0) + 1;
    }

    return VpnAnalyticsSnapshot(
      sessionCount: sessions.length,
      averagePingMs: avgPing,
      totalTrafficMb: totalDownload + totalUpload,
      totalDownloadedMb: totalDownload,
      totalUploadedMb: totalUpload,
      regionUsage: usage,
      pingGraph: livePingGraph,
      trafficGraph: liveTrafficGraph,
    );
  }

  VpnSessionRecord? createSessionRecord(
    VpnConnectionSnapshot snapshot,
    List<double> pingSamples,
  ) {
    final server = snapshot.server;
    final startedAt = snapshot.connectedAt;
    if (server == null || startedAt == null) return null;

    final avgPing = pingSamples.isEmpty
        ? snapshot.pingMs
        : pingSamples.reduce((a, b) => a + b) / pingSamples.length;

    return VpnSessionRecord(
      serverId: server.id,
      country: server.country,
      region: server.region,
      profileName: snapshot.profile.title,
      startedAt: startedAt,
      endedAt: DateTime.now(),
      averagePingMs: avgPing,
      trafficDownloadedMb: snapshot.trafficDownloadedMb,
      trafficUploadedMb: snapshot.trafficUploadedMb,
      stabilityPercent: server.stabilityPercent,
    );
  }

  void dispose() {
    _logStreamController.close();
  }
}

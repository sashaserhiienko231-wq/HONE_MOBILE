import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hone_mobile/features/vpn_boost/models/vpn_models.dart';
import 'package:hone_mobile/features/vpn_boost/providers/vpn_boost_providers.dart';
import 'package:hone_mobile/features/vpn_boost/services/vpn_connection_service.dart';

void main() {
  group('VPN Boost server catalog', () {
    test('Contains all required regions and country counts', () {
      final catalog = VpnServer.regionCatalog;

      expect(catalog['North America']?.length, equals(3));
      expect(catalog['South America']?.length, equals(4));
      expect(catalog['Europe']?.length, equals(13));
      expect(catalog['Asia']?.length, equals(11));
      expect(catalog['Middle East']?.length, equals(4));
      expect(catalog['Africa']?.length, equals(4));
      expect(catalog['Oceania']?.length, equals(2));
    });

    test('Server cards expose metrics and categories', () {
      final servers = VpnServer.defaultServers;
      final germany =
          servers.firstWhere((server) => server.country == 'Germany');

      expect(servers.length, equals(41));
      expect(germany.flag, isNotEmpty);
      expect(germany.pingMs, isPositive);
      expect(germany.loadPercent, inInclusiveRange(0, 100));
      expect(germany.stabilityPercent, inInclusiveRange(0, 100));
      expect(germany.speedScore, inInclusiveRange(0, 100));
      expect(germany.gamingScore, inInclusiveRange(0, 100));
      expect(germany.categories, contains(VpnServerCategory.gaming));
    });

    test('Every requested browser category has servers', () {
      final servers = VpnServer.defaultServers;

      for (final category in VpnServerCategory.values) {
        expect(
          servers.any((server) => server.categories.contains(category)),
          isTrue,
          reason: '${category.label} should have at least one server',
        );
      }
    });
  });

  group('VPN gaming profiles', () {
    test('Contains all requested profiles', () {
      final profileNames =
          VpnGamingProfile.defaults.map((profile) => profile.title);

      expect(profileNames, contains('AI Smart Mode'));
      expect(profileNames, contains('Ultra Low Ping'));
      expect(profileNames, contains('Competitive Gaming'));
      expect(profileNames, contains('Streaming Mode'));
      expect(profileNames, contains('Balanced Mode'));
      expect(profileNames, contains('Battery Saver Mode'));
    });
  });

  group('VPN connection service', () {
    test('Quick connect resolves fastest and lowest ping servers', () {
      final service = VpnConnectionService();
      addTearDown(service.dispose);
      final servers = VpnServer.defaultServers;

      final fastest = service.resolveQuickConnect(
        option: VpnQuickConnectOption.fastest,
        servers: servers,
        favoriteIds: const {},
      );
      final lowestPing = service.resolveQuickConnect(
        option: VpnQuickConnectOption.lowestPing,
        servers: servers,
        favoriteIds: const {},
      );

      expect(
        fastest.speedScore,
        equals(servers
            .map((server) => server.speedScore)
            .reduce((a, b) => a > b ? a : b)),
      );
      expect(
        lowestPing.pingMs,
        equals(servers
            .map((server) => server.pingMs)
            .reduce((a, b) => a < b ? a : b)),
      );
    });

    test('Simulated gateway connects with secure status and route metrics',
        () async {
      final service = VpnConnectionService();
      addTearDown(service.dispose);

      final snapshot = await service.connect(
        server: VpnServer.defaultServers.first,
        profile: VpnGamingProfile.defaults.first,
      );

      expect(snapshot.status, equals(VpnConnectionStatus.connected));
      expect(snapshot.isSecure, isTrue);
      expect(snapshot.currentIp, startsWith('10.'));
      expect(snapshot.pingMs, isPositive);
      expect(snapshot.downloadMbps, isPositive);
      expect(service.diagnosticLogs, isNotEmpty);
    });
  });

  group('VPN Boost Riverpod state', () {
    test('Initial state is standby with AI Smart profile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(vpnBoostStateProvider);

      expect(state.connection.status, equals(VpnConnectionStatus.disconnected));
      expect(state.selectedProfile.title, equals('AI Smart Mode'));
      expect(state.servers.length, equals(41));
    });

    test('Search and category provider filters server browser', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(vpnBoostStateProvider.notifier);
      notifier.setCategory(VpnServerCategory.security);
      notifier.setSearchQuery('Europe');

      final filtered = container.read(vpnFilteredServersProvider);
      expect(filtered, isNotEmpty);
      expect(filtered.every((server) => server.region == 'Europe'), isTrue);
      expect(
        filtered.every(
            (server) => server.categories.contains(VpnServerCategory.security)),
        isTrue,
      );
    });

    test('Favorites, connect, disconnect, and analytics update state',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(vpnBoostStateProvider.notifier);
      final server = container.read(vpnBoostStateProvider).servers.first;

      notifier.toggleFavorite(server.id);
      expect(
        container.read(vpnBoostStateProvider).favoriteServerIds,
        contains(server.id),
      );

      await notifier.connect(server: server);
      var state = container.read(vpnBoostStateProvider);
      expect(state.isConnected, isTrue);
      expect(state.connection.server?.id, equals(server.id));

      await notifier.disconnect();
      state = container.read(vpnBoostStateProvider);
      expect(state.isConnected, isFalse);
      expect(state.sessionHistory.length, equals(1));
      expect(state.analytics.sessionCount, equals(1));
    });
  });
}

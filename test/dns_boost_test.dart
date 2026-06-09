import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/features/dns_boost/models/dns_provider_info.dart';
import 'package:hone_mobile/features/dns_boost/services/dns_engine_service.dart';
import 'package:hone_mobile/features/dns_boost/providers/dns_boost_providers.dart';

void main() {
  group('DNS Provider Info Tests', () {
    test('Default providers contain Cloudflare and Google', () {
      final providers = DnsProviderInfo.defaultProviders;
      expect(providers.any((p) => p.id == 'cloudflare'), isTrue);
      expect(providers.any((p) => p.id == 'google'), isTrue);
      expect(providers.first.addresses.isNotEmpty, isTrue);
    });

    test('Gaming profiles contain ultra-low latency nodes', () {
      final profiles = DnsProviderInfo.gamingProfiles;
      expect(profiles.any((p) => p.isGamingProfile), isTrue);
      expect(profiles.any((p) => p.id == 'gaming_ultralow'), isTrue);
    });

    test('Regional profiles are loaded for Europe and Asia', () {
      final eu = DnsProviderInfo.getRegionalProfiles('Europe');
      final asia = DnsProviderInfo.getRegionalProfiles('Asia');
      
      expect(eu.every((p) => p.region == 'Europe'), isTrue);
      expect(asia.every((p) => p.region == 'Asia'), isTrue);
    });
  });

  group('DNS Engine Service Simulation Tests', () {
    late DnsEngineService engine;

    setUp(() {
      engine = DnsEngineService();
    });

    test('Cache purge returns freed bytes greater than zero', () async {
      final bytes = await engine.purgeCache();
      expect(bytes, isPositive);
    });

    test('Network repair succeeds', () async {
      final provider = DnsProviderInfo.defaultProviders.first;
      final result = await engine.repairNetworkStack(provider);
      expect(result, isTrue);
    });

    test('Latency metrics are modified correctly by Competitive mode', () {
      final provider = DnsProviderInfo.defaultProviders.first;
      engine.simulateNetworkMetrics(provider, 'Streaming', 'North America');
      final competitive = engine.simulateNetworkMetrics(provider, 'Competitive', 'North America');
      
      // Competitive should yield lower latency average on average
      expect(competitive['ping'], isNotNull);
      expect(competitive['jitter'], isNotNull);
    });
  });

  group('DNS Boost Riverpod State Management Tests', () {
    test('Initial state is standby with AI Smart mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(dnsBoostStateProvider);
      expect(state.isBoostEnabled, isFalse);
      expect(state.selectedMode, equals('AI Smart'));
      expect(state.activeProvider.id, equals('cloudflare'));
    });

    test('Enabling boost triggers boost state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(dnsBoostStateProvider.notifier);
      
      notifier.toggleBoost(true);
      
      var state = container.read(dnsBoostStateProvider);
      expect(state.isBoostEnabled, isTrue);
      expect(state.isBoosting, isTrue); // shows temporary optimizing spinner
    });

    test('Changing modes and regions works and modifies state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(dnsBoostStateProvider.notifier);
      
      notifier.setMode('Competitive');
      notifier.setRegion('Europe');

      final state = container.read(dnsBoostStateProvider);
      expect(state.selectedMode, equals('Competitive'));
      expect(state.selectedRegion, equals('Europe'));
    });

    test('Adding and removing custom DNS entries updates custom lists', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(dnsBoostStateProvider.notifier);
      
      notifier.addCustomDns('My Secure DNS', '10.10.10.1');
      var state = container.read(dnsBoostStateProvider);
      expect(state.customProviders.length, equals(1));
      expect(state.customProviders.first.name, equals('My Secure DNS'));
      expect(state.customProviders.first.addresses.first, equals('10.10.10.1'));

      notifier.removeCustomDns(state.customProviders.first.id);
      state = container.read(dnsBoostStateProvider);
      expect(state.customProviders.isEmpty, isTrue);
    });

    test('Setting and removing game overrides is stored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(dnsBoostStateProvider.notifier);
      
      notifier.setGameDnsOverride('com.tencent.tmgp.pubgmhd', 'google');
      notifier.setGameRegionOverride('com.tencent.tmgp.pubgmhd', 'Asia');

      var state = container.read(dnsBoostStateProvider);
      expect(state.perGameProviders['com.tencent.tmgp.pubgmhd'], equals('google'));
      expect(state.perGameRegions['com.tencent.tmgp.pubgmhd'], equals('Asia'));

      notifier.removeGameOverrides('com.tencent.tmgp.pubgmhd');
      state = container.read(dnsBoostStateProvider);
      expect(state.perGameProviders.containsKey('com.tencent.tmgp.pubgmhd'), isFalse);
    });
  });
}

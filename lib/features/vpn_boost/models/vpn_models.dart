enum VpnServerCategory {
  recommended,
  lowestPing,
  gaming,
  streaming,
  security,
}

extension VpnServerCategoryLabel on VpnServerCategory {
  String get label {
    switch (this) {
      case VpnServerCategory.recommended:
        return 'Recommended';
      case VpnServerCategory.lowestPing:
        return 'Lowest Ping';
      case VpnServerCategory.gaming:
        return 'Gaming Servers';
      case VpnServerCategory.streaming:
        return 'Streaming Servers';
      case VpnServerCategory.security:
        return 'Security Servers';
    }
  }
}

enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

enum VpnQuickConnectOption {
  autoBest,
  fastest,
  lowestPing,
  lastUsed,
  favorite,
}

extension VpnQuickConnectOptionLabel on VpnQuickConnectOption {
  String get label {
    switch (this) {
      case VpnQuickConnectOption.autoBest:
        return 'Auto Best Server';
      case VpnQuickConnectOption.fastest:
        return 'Fastest Server';
      case VpnQuickConnectOption.lowestPing:
        return 'Lowest Ping Server';
      case VpnQuickConnectOption.lastUsed:
        return 'Last Used Server';
      case VpnQuickConnectOption.favorite:
        return 'Favorite Servers';
    }
  }
}

class VpnServer {
  final String id;
  final String country;
  final String countryCode;
  final String region;
  final String city;
  final int pingMs;
  final int loadPercent;
  final int stabilityPercent;
  final int speedScore;
  final int gamingScore;
  final double downloadMbps;
  final double uploadMbps;
  final List<VpnServerCategory> categories;

  const VpnServer({
    required this.id,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.city,
    required this.pingMs,
    required this.loadPercent,
    required this.stabilityPercent,
    required this.speedScore,
    required this.gamingScore,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.categories,
  });

  String get flag {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return countryCode;
    final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCodes([first, second]);
  }

  bool matches(String query) {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) return true;

    return country.toLowerCase().contains(normalized) ||
        region.toLowerCase().contains(normalized) ||
        city.toLowerCase().contains(normalized) ||
        countryCode.toLowerCase().contains(normalized);
  }

  int get connectionScore {
    final score = ((100 - loadPercent) * 0.2) +
        (stabilityPercent * 0.25) +
        (speedScore * 0.25) +
        (gamingScore * 0.2) +
        ((120 - pingMs).clamp(0, 120) * 0.1);
    return score.round().clamp(0, 100).toInt();
  }

  VpnServer copyWith({
    int? pingMs,
    int? loadPercent,
    int? stabilityPercent,
    int? speedScore,
    int? gamingScore,
    double? downloadMbps,
    double? uploadMbps,
    List<VpnServerCategory>? categories,
  }) {
    return VpnServer(
      id: id,
      country: country,
      countryCode: countryCode,
      region: region,
      city: city,
      pingMs: pingMs ?? this.pingMs,
      loadPercent: loadPercent ?? this.loadPercent,
      stabilityPercent: stabilityPercent ?? this.stabilityPercent,
      speedScore: speedScore ?? this.speedScore,
      gamingScore: gamingScore ?? this.gamingScore,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      categories: categories ?? this.categories,
    );
  }

  static Map<String, List<String>> get regionCatalog {
    final result = <String, List<String>>{};
    for (final seed in _countrySeeds) {
      result.putIfAbsent(seed.region, () => <String>[]).add(seed.country);
    }
    return result;
  }

  static List<VpnServer> get defaultServers {
    return [
      for (var i = 0; i < _countrySeeds.length; i++)
        _buildServer(i, _countrySeeds[i]),
    ];
  }

  static VpnServer _buildServer(int index, _CountrySeed seed) {
    final ping = seed.basePing + ((index * 7) % 15);
    final load = 18 + ((index * 11) % 63);
    final stability = 88 + ((index * 5) % 12);
    final speed = 76 + ((index * 9) % 23);
    final gaming = 72 + ((index * 13) % 27);

    final categories = <VpnServerCategory>{};
    if (index % 3 != 1 || stability >= 94) {
      categories.add(VpnServerCategory.recommended);
    }
    if (ping <= seed.basePing + 7 || ping <= 25) {
      categories.add(VpnServerCategory.lowestPing);
    }
    if (gaming >= 84 || seed.gamingHub) {
      categories.add(VpnServerCategory.gaming);
    }
    if (speed >= 86 || seed.streamingHub) {
      categories.add(VpnServerCategory.streaming);
    }
    if (stability >= 94 || seed.securityHub) {
      categories.add(VpnServerCategory.security);
    }
    if (categories.isEmpty) {
      categories.add(VpnServerCategory.recommended);
    }

    return VpnServer(
      id: '${seed.countryCode.toLowerCase()}_${seed.city.toLowerCase().replaceAll(' ', '_')}',
      country: seed.country,
      countryCode: seed.countryCode,
      region: seed.region,
      city: seed.city,
      pingMs: ping,
      loadPercent: load,
      stabilityPercent: stability.clamp(0, 100).toInt(),
      speedScore: speed.clamp(0, 100).toInt(),
      gamingScore: gaming.clamp(0, 100).toInt(),
      downloadMbps: 180 + speed * 6.5 - load,
      uploadMbps: 70 + speed * 2.2 - load / 3,
      categories: List.unmodifiable(categories),
    );
  }
}

class VpnGamingProfile {
  final String id;
  final String title;
  final String subtitle;
  final double pingMultiplier;
  final double speedMultiplier;
  final double batteryCost;
  final double securityLevel;

  const VpnGamingProfile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pingMultiplier,
    required this.speedMultiplier,
    required this.batteryCost,
    required this.securityLevel,
  });

  static List<VpnGamingProfile> get defaults => const [
        VpnGamingProfile(
          id: 'ai_smart',
          title: 'AI Smart Mode',
          subtitle: 'Auto-routes around congestion and spikes.',
          pingMultiplier: 0.9,
          speedMultiplier: 1.06,
          batteryCost: 0.62,
          securityLevel: 0.95,
        ),
        VpnGamingProfile(
          id: 'ultra_low_ping',
          title: 'Ultra Low Ping',
          subtitle: 'Shortest path routing for reflex-heavy games.',
          pingMultiplier: 0.78,
          speedMultiplier: 1.0,
          batteryCost: 0.82,
          securityLevel: 0.9,
        ),
        VpnGamingProfile(
          id: 'competitive',
          title: 'Competitive Gaming',
          subtitle: 'Stable packets, strict jitter control.',
          pingMultiplier: 0.82,
          speedMultiplier: 1.03,
          batteryCost: 0.88,
          securityLevel: 0.92,
        ),
        VpnGamingProfile(
          id: 'streaming',
          title: 'Streaming Mode',
          subtitle: 'Bandwidth priority for cloud play and video.',
          pingMultiplier: 0.98,
          speedMultiplier: 1.18,
          batteryCost: 0.7,
          securityLevel: 0.9,
        ),
        VpnGamingProfile(
          id: 'balanced',
          title: 'Balanced Mode',
          subtitle: 'Everyday privacy, speed, and latency balance.',
          pingMultiplier: 1.0,
          speedMultiplier: 1.0,
          batteryCost: 0.48,
          securityLevel: 0.94,
        ),
        VpnGamingProfile(
          id: 'battery_saver',
          title: 'Battery Saver Mode',
          subtitle: 'Lower polling and quieter background traffic.',
          pingMultiplier: 1.16,
          speedMultiplier: 0.86,
          batteryCost: 0.22,
          securityLevel: 0.88,
        ),
      ];
}

class VpnConnectionSnapshot {
  final VpnConnectionStatus status;
  final VpnServer? server;
  final VpnGamingProfile profile;
  final String currentIp;
  final double pingMs;
  final double downloadMbps;
  final double uploadMbps;
  final DateTime? connectedAt;
  final bool isSecure;
  final String securityStatus;
  final double trafficDownloadedMb;
  final double trafficUploadedMb;

  const VpnConnectionSnapshot({
    required this.status,
    required this.server,
    required this.profile,
    required this.currentIp,
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.connectedAt,
    required this.isSecure,
    required this.securityStatus,
    required this.trafficDownloadedMb,
    required this.trafficUploadedMb,
  });

  Duration get duration {
    final start = connectedAt;
    if (start == null || status != VpnConnectionStatus.connected) {
      return Duration.zero;
    }
    return DateTime.now().difference(start);
  }

  VpnConnectionSnapshot copyWith({
    VpnConnectionStatus? status,
    VpnServer? server,
    VpnGamingProfile? profile,
    String? currentIp,
    double? pingMs,
    double? downloadMbps,
    double? uploadMbps,
    DateTime? connectedAt,
    bool? clearConnectedAt,
    bool? isSecure,
    String? securityStatus,
    double? trafficDownloadedMb,
    double? trafficUploadedMb,
  }) {
    return VpnConnectionSnapshot(
      status: status ?? this.status,
      server: server ?? this.server,
      profile: profile ?? this.profile,
      currentIp: currentIp ?? this.currentIp,
      pingMs: pingMs ?? this.pingMs,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      connectedAt:
          clearConnectedAt == true ? null : connectedAt ?? this.connectedAt,
      isSecure: isSecure ?? this.isSecure,
      securityStatus: securityStatus ?? this.securityStatus,
      trafficDownloadedMb: trafficDownloadedMb ?? this.trafficDownloadedMb,
      trafficUploadedMb: trafficUploadedMb ?? this.trafficUploadedMb,
    );
  }

  factory VpnConnectionSnapshot.disconnected(VpnGamingProfile profile) {
    return VpnConnectionSnapshot(
      status: VpnConnectionStatus.disconnected,
      server: null,
      profile: profile,
      currentIp: 'Protected IP unavailable',
      pingMs: 0,
      downloadMbps: 0,
      uploadMbps: 0,
      connectedAt: null,
      isSecure: false,
      securityStatus: 'VPN standby',
      trafficDownloadedMb: 0,
      trafficUploadedMb: 0,
    );
  }
}

class VpnSessionRecord {
  final String serverId;
  final String country;
  final String region;
  final String profileName;
  final DateTime startedAt;
  final DateTime endedAt;
  final double averagePingMs;
  final double trafficDownloadedMb;
  final double trafficUploadedMb;
  final int stabilityPercent;

  const VpnSessionRecord({
    required this.serverId,
    required this.country,
    required this.region,
    required this.profileName,
    required this.startedAt,
    required this.endedAt,
    required this.averagePingMs,
    required this.trafficDownloadedMb,
    required this.trafficUploadedMb,
    required this.stabilityPercent,
  });

  Duration get duration => endedAt.difference(startedAt);
}

class VpnAnalyticsSnapshot {
  final int sessionCount;
  final double averagePingMs;
  final double totalTrafficMb;
  final double totalDownloadedMb;
  final double totalUploadedMb;
  final Map<String, int> regionUsage;
  final List<double> pingGraph;
  final List<double> trafficGraph;

  const VpnAnalyticsSnapshot({
    required this.sessionCount,
    required this.averagePingMs,
    required this.totalTrafficMb,
    required this.totalDownloadedMb,
    required this.totalUploadedMb,
    required this.regionUsage,
    required this.pingGraph,
    required this.trafficGraph,
  });

  factory VpnAnalyticsSnapshot.empty() {
    return const VpnAnalyticsSnapshot(
      sessionCount: 0,
      averagePingMs: 0,
      totalTrafficMb: 0,
      totalDownloadedMb: 0,
      totalUploadedMb: 0,
      regionUsage: {},
      pingGraph: [],
      trafficGraph: [],
    );
  }
}

class VpnSettings {
  final bool killSwitch;
  final bool autoReconnect;
  final bool blockTrackers;
  final bool lanBypass;
  final bool diagnosticsLogging;
  final bool prepareSdkBridge;

  const VpnSettings({
    required this.killSwitch,
    required this.autoReconnect,
    required this.blockTrackers,
    required this.lanBypass,
    required this.diagnosticsLogging,
    required this.prepareSdkBridge,
  });

  factory VpnSettings.defaults() {
    return const VpnSettings(
      killSwitch: true,
      autoReconnect: true,
      blockTrackers: true,
      lanBypass: false,
      diagnosticsLogging: true,
      prepareSdkBridge: true,
    );
  }

  VpnSettings copyWith({
    bool? killSwitch,
    bool? autoReconnect,
    bool? blockTrackers,
    bool? lanBypass,
    bool? diagnosticsLogging,
    bool? prepareSdkBridge,
  }) {
    return VpnSettings(
      killSwitch: killSwitch ?? this.killSwitch,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      blockTrackers: blockTrackers ?? this.blockTrackers,
      lanBypass: lanBypass ?? this.lanBypass,
      diagnosticsLogging: diagnosticsLogging ?? this.diagnosticsLogging,
      prepareSdkBridge: prepareSdkBridge ?? this.prepareSdkBridge,
    );
  }
}

class _CountrySeed {
  final String country;
  final String countryCode;
  final String region;
  final String city;
  final int basePing;
  final bool gamingHub;
  final bool streamingHub;
  final bool securityHub;

  const _CountrySeed(
    this.country,
    this.countryCode,
    this.region,
    this.city,
    this.basePing, {
    this.gamingHub = false,
    this.streamingHub = false,
    this.securityHub = false,
  });
}

const List<_CountrySeed> _countrySeeds = [
  _CountrySeed('United States', 'US', 'North America', 'Dallas', 18,
      gamingHub: true, streamingHub: true),
  _CountrySeed('Canada', 'CA', 'North America', 'Toronto', 24,
      securityHub: true),
  _CountrySeed('Mexico', 'MX', 'North America', 'Mexico City', 36),
  _CountrySeed('Brazil', 'BR', 'South America', 'Sao Paulo', 42,
      gamingHub: true),
  _CountrySeed('Argentina', 'AR', 'South America', 'Buenos Aires', 49),
  _CountrySeed('Chile', 'CL', 'South America', 'Santiago', 52,
      securityHub: true),
  _CountrySeed('Colombia', 'CO', 'South America', 'Bogota', 46),
  _CountrySeed('United Kingdom', 'GB', 'Europe', 'London', 21,
      streamingHub: true, securityHub: true),
  _CountrySeed('Germany', 'DE', 'Europe', 'Frankfurt', 19,
      gamingHub: true, securityHub: true),
  _CountrySeed('France', 'FR', 'Europe', 'Paris', 23, streamingHub: true),
  _CountrySeed('Netherlands', 'NL', 'Europe', 'Amsterdam', 17,
      gamingHub: true, securityHub: true),
  _CountrySeed('Poland', 'PL', 'Europe', 'Warsaw', 27),
  _CountrySeed('Spain', 'ES', 'Europe', 'Madrid', 31, streamingHub: true),
  _CountrySeed('Italy', 'IT', 'Europe', 'Milan', 29),
  _CountrySeed('Sweden', 'SE', 'Europe', 'Stockholm', 33, securityHub: true),
  _CountrySeed('Norway', 'NO', 'Europe', 'Oslo', 35, securityHub: true),
  _CountrySeed('Finland', 'FI', 'Europe', 'Helsinki', 38, securityHub: true),
  _CountrySeed('Switzerland', 'CH', 'Europe', 'Zurich', 24, securityHub: true),
  _CountrySeed('Ukraine', 'UA', 'Europe', 'Kyiv', 34, gamingHub: true),
  _CountrySeed('Czech Republic', 'CZ', 'Europe', 'Prague', 26),
  _CountrySeed('Japan', 'JP', 'Asia', 'Tokyo', 32,
      gamingHub: true, streamingHub: true),
  _CountrySeed('South Korea', 'KR', 'Asia', 'Seoul', 29,
      gamingHub: true, streamingHub: true),
  _CountrySeed('Singapore', 'SG', 'Asia', 'Singapore', 22,
      gamingHub: true, securityHub: true),
  _CountrySeed('India', 'IN', 'Asia', 'Mumbai', 47, streamingHub: true),
  _CountrySeed('Thailand', 'TH', 'Asia', 'Bangkok', 44),
  _CountrySeed('Malaysia', 'MY', 'Asia', 'Kuala Lumpur', 39),
  _CountrySeed('Indonesia', 'ID', 'Asia', 'Jakarta', 51),
  _CountrySeed('Vietnam', 'VN', 'Asia', 'Ho Chi Minh City', 43),
  _CountrySeed('Philippines', 'PH', 'Asia', 'Manila', 48),
  _CountrySeed('Taiwan', 'TW', 'Asia', 'Taipei', 35, gamingHub: true),
  _CountrySeed('Hong Kong', 'HK', 'Asia', 'Hong Kong', 28,
      gamingHub: true, securityHub: true),
  _CountrySeed('UAE', 'AE', 'Middle East', 'Dubai', 41, streamingHub: true),
  _CountrySeed('Saudi Arabia', 'SA', 'Middle East', 'Riyadh', 45),
  _CountrySeed('Turkey', 'TR', 'Middle East', 'Istanbul', 37, gamingHub: true),
  _CountrySeed('Israel', 'IL', 'Middle East', 'Tel Aviv', 39,
      securityHub: true),
  _CountrySeed('South Africa', 'ZA', 'Africa', 'Johannesburg', 58,
      gamingHub: true),
  _CountrySeed('Egypt', 'EG', 'Africa', 'Cairo', 55),
  _CountrySeed('Morocco', 'MA', 'Africa', 'Casablanca', 53),
  _CountrySeed('Kenya', 'KE', 'Africa', 'Nairobi', 62, securityHub: true),
  _CountrySeed('Australia', 'AU', 'Oceania', 'Sydney', 36,
      gamingHub: true, streamingHub: true),
  _CountrySeed('New Zealand', 'NZ', 'Oceania', 'Auckland', 43,
      securityHub: true),
];

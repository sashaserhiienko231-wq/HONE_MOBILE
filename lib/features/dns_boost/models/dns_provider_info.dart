class DnsProviderInfo {
  final String id;
  final String name;
  final List<String> addresses;
  final double latencyMs;
  final String region;
  final bool isCustom;
  final double reliability; // 0.0 to 1.0
  final bool isGamingProfile;

  const DnsProviderInfo({
    required this.id,
    required this.name,
    required this.addresses,
    required this.latencyMs,
    required this.region,
    this.isCustom = false,
    this.reliability = 1.0,
    this.isGamingProfile = false,
  });

  DnsProviderInfo copyWith({
    String? id,
    String? name,
    List<String>? addresses,
    double? latencyMs,
    String? region,
    bool? isCustom,
    double? reliability,
    bool? isGamingProfile,
  }) {
    return DnsProviderInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      latencyMs: latencyMs ?? this.latencyMs,
      region: region ?? this.region,
      isCustom: isCustom ?? this.isCustom,
      reliability: reliability ?? this.reliability,
      isGamingProfile: isGamingProfile ?? this.isGamingProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addresses': addresses,
      'latencyMs': latencyMs,
      'region': region,
      'isCustom': isCustom,
      'reliability': reliability,
      'isGamingProfile': isGamingProfile,
    };
  }

  factory DnsProviderInfo.fromJson(Map<String, dynamic> json) {
    return DnsProviderInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      addresses: List<String>.from(json['addresses'] as List),
      latencyMs: (json['latencyMs'] as num).toDouble(),
      region: json['region'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      reliability: (json['reliability'] as num?)?.toDouble() ?? 1.0,
      isGamingProfile: json['isGamingProfile'] as bool? ?? false,
    );
  }

  @override
  String toString() => '$name (${addresses.join(', ')}) - ${latencyMs.toStringAsFixed(1)}ms';

  // Default Standard Providers
  static List<DnsProviderInfo> get defaultProviders => [
        const DnsProviderInfo(
          id: 'cloudflare',
          name: 'Cloudflare DNS',
          addresses: ['1.1.1.1', '1.0.0.1'],
          latencyMs: 14.2,
          region: 'Global',
        ),
        const DnsProviderInfo(
          id: 'google',
          name: 'Google Public DNS',
          addresses: ['8.8.8.8', '8.8.4.4'],
          latencyMs: 22.5,
          region: 'Global',
        ),
        const DnsProviderInfo(
          id: 'quad9',
          name: 'Quad9 Security',
          addresses: ['9.9.9.9', '149.112.112.112'],
          latencyMs: 18.9,
          region: 'Global',
        ),
        const DnsProviderInfo(
          id: 'opendns',
          name: 'Cisco OpenDNS',
          addresses: ['208.67.222.222', '208.67.220.220'],
          latencyMs: 28.1,
          region: 'Global',
        ),
        const DnsProviderInfo(
          id: 'adguard',
          name: 'AdGuard DNS',
          addresses: ['94.140.14.14', '94.140.15.15'],
          latencyMs: 35.4,
          region: 'Global',
        ),
      ];

  // Gaming-optimized profiles
  static List<DnsProviderInfo> get gamingProfiles => [
        const DnsProviderInfo(
          id: 'gaming_ultralow',
          name: 'Hone Ultra-Low Latency',
          addresses: ['45.90.28.0', '45.90.30.0'],
          latencyMs: 8.5,
          region: 'Global',
          isGamingProfile: true,
          reliability: 0.99,
        ),
        const DnsProviderInfo(
          id: 'gaming_level3',
          name: 'Level3 Gaming DNS',
          addresses: ['209.244.0.3', '209.244.0.4'],
          latencyMs: 11.2,
          region: 'Global',
          isGamingProfile: true,
        ),
        const DnsProviderInfo(
          id: 'gaming_comodo',
          name: 'Comodo Secure Gaming',
          addresses: ['8.26.56.26', '8.20.247.20'],
          latencyMs: 16.4,
          region: 'Global',
          isGamingProfile: true,
        ),
        const DnsProviderInfo(
          id: 'gaming_verisign',
          name: 'Verisign Public',
          addresses: ['64.6.64.6', '64.6.65.6'],
          latencyMs: 19.8,
          region: 'Global',
          isGamingProfile: true,
        ),
      ];

  // Auto-generated regional profiles
  static List<DnsProviderInfo> getRegionalProfiles(String region) {
    switch (region) {
      case 'Europe':
        return [
          const DnsProviderInfo(id: 'eu_cloudflare', name: 'Cloudflare EU Edge', addresses: ['1.1.1.1'], latencyMs: 10.5, region: 'Europe'),
          const DnsProviderInfo(id: 'eu_google', name: 'Google EU Core', addresses: ['8.8.8.8'], latencyMs: 15.2, region: 'Europe'),
          const DnsProviderInfo(id: 'eu_quad9', name: 'Quad9 Zurich', addresses: ['9.9.9.9'], latencyMs: 12.8, region: 'Europe'),
        ];
      case 'North America':
        return [
          const DnsProviderInfo(id: 'na_cloudflare', name: 'Cloudflare US East', addresses: ['1.1.1.1'], latencyMs: 9.1, region: 'North America'),
          const DnsProviderInfo(id: 'na_google', name: 'Google US Central', addresses: ['8.8.8.8'], latencyMs: 12.3, region: 'North America'),
          const DnsProviderInfo(id: 'na_level3', name: 'Level3 Dallas', addresses: ['4.2.2.1'], latencyMs: 11.5, region: 'North America'),
        ];
      case 'South America':
        return [
          const DnsProviderInfo(id: 'sa_cloudflare', name: 'Cloudflare Sao Paulo', addresses: ['1.1.1.1'], latencyMs: 28.5, region: 'South America'),
          const DnsProviderInfo(id: 'sa_google', name: 'Google Buenos Aires', addresses: ['8.8.8.8'], latencyMs: 32.1, region: 'South America'),
        ];
      case 'Asia':
        return [
          const DnsProviderInfo(id: 'asia_cloudflare', name: 'Cloudflare Tokyo', addresses: ['1.1.1.1'], latencyMs: 18.2, region: 'Asia'),
          const DnsProviderInfo(id: 'asia_google', name: 'Google Singapore', addresses: ['8.8.8.8'], latencyMs: 20.4, region: 'Asia'),
          const DnsProviderInfo(id: 'asia_quad9', name: 'Quad9 Hong Kong', addresses: ['9.9.9.9'], latencyMs: 19.1, region: 'Asia'),
        ];
      case 'Middle East':
        return [
          const DnsProviderInfo(id: 'me_cloudflare', name: 'Cloudflare Dubai', addresses: ['1.1.1.1'], latencyMs: 35.8, region: 'Middle East'),
          const DnsProviderInfo(id: 'me_google', name: 'Google Riyadh', addresses: ['8.8.8.8'], latencyMs: 40.1, region: 'Middle East'),
        ];
      case 'Africa':
        return [
          const DnsProviderInfo(id: 'af_cloudflare', name: 'Cloudflare Cape Town', addresses: ['1.1.1.1'], latencyMs: 42.4, region: 'Africa'),
          const DnsProviderInfo(id: 'af_google', name: 'Google Johannesburg', addresses: ['8.8.8.8'], latencyMs: 48.9, region: 'Africa'),
        ];
      case 'Oceania':
        return [
          const DnsProviderInfo(id: 'oc_cloudflare', name: 'Cloudflare Sydney', addresses: ['1.1.1.1'], latencyMs: 15.6, region: 'Oceania'),
          const DnsProviderInfo(id: 'oc_google', name: 'Google Sydney', addresses: ['8.8.8.8'], latencyMs: 17.8, region: 'Oceania'),
        ];
      default:
        return [];
    }
  }
}

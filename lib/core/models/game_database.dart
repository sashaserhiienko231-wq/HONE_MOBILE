class CloudGameInfo {
  final String id;
  final String packageName;
  final String name;
  final String developer;
  final String category;
  final List<String> tags;
  final String description;
  final String iconUrl;
  final String bannerUrl;
  final List<String> screenshots;
  final GameRequirements requirements;
  final GameOptimizationProfile defaultProfile;
  final double rating;
  final int downloads;
  final DateTime releaseDate;
  final DateTime lastUpdated;
  final bool isPopular;
  final bool isNew;
  final Map<String, dynamic> metadata;

  CloudGameInfo({
    required this.id,
    required this.packageName,
    required this.name,
    required this.developer,
    required this.category,
    required this.tags,
    required this.description,
    required this.iconUrl,
    required this.bannerUrl,
    required this.screenshots,
    required this.requirements,
    required this.defaultProfile,
    required this.rating,
    required this.downloads,
    required this.releaseDate,
    required this.lastUpdated,
    this.isPopular = false,
    this.isNew = false,
    this.metadata = const {},
  });

  CloudGameInfo copyWith({
    String? id,
    String? packageName,
    String? name,
    String? developer,
    String? category,
    List<String>? tags,
    String? description,
    String? iconUrl,
    String? bannerUrl,
    List<String>? screenshots,
    GameRequirements? requirements,
    GameOptimizationProfile? defaultProfile,
    double? rating,
    int? downloads,
    DateTime? releaseDate,
    DateTime? lastUpdated,
    bool? isPopular,
    bool? isNew,
    Map<String, dynamic>? metadata,
  }) {
    return CloudGameInfo(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      name: name ?? this.name,
      developer: developer ?? this.developer,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      screenshots: screenshots ?? this.screenshots,
      requirements: requirements ?? this.requirements,
      defaultProfile: defaultProfile ?? this.defaultProfile,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      releaseDate: releaseDate ?? this.releaseDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isPopular: isPopular ?? this.isPopular,
      isNew: isNew ?? this.isNew,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'name': name,
      'developer': developer,
      'category': category,
      'tags': tags,
      'description': description,
      'iconUrl': iconUrl,
      'bannerUrl': bannerUrl,
      'screenshots': screenshots,
      'requirements': requirements.toJson(),
      'defaultProfile': defaultProfile.toJson(),
      'rating': rating,
      'downloads': downloads,
      'releaseDate': releaseDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isPopular': isPopular,
      'isNew': isNew,
      'metadata': metadata,
    };
  }

  factory CloudGameInfo.fromJson(Map<String, dynamic> json) {
    return CloudGameInfo(
      id: json['id'] as String,
      packageName: json['packageName'] as String,
      name: json['name'] as String,
      developer: json['developer'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List).cast<String>(),
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      bannerUrl: json['bannerUrl'] as String,
      screenshots: (json['screenshots'] as List).cast<String>(),
      requirements: GameRequirements.fromJson(json['requirements']),
      defaultProfile: GameOptimizationProfile.fromJson(json['defaultProfile']),
      rating: (json['rating'] as num).toDouble(),
      downloads: json['downloads'] as int,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isPopular: json['isPopular'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class GameCategory {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String color;
  final int gameCount;
  final List<String> subcategories;
  final Map<String, dynamic> metadata;

  GameCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.color,
    required this.gameCount,
    required this.subcategories,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'color': color,
      'gameCount': gameCount,
      'subcategories': subcategories,
      'metadata': metadata,
    };
  }

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      color: json['color'] as String,
      gameCount: json['gameCount'] as int,
      subcategories: (json['subcategories'] as List).cast<String>(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class GameRequirements {
  final int minAndroidVersion;
  final int minRamMB;
  final int minStorageMB;
  final String minCpu;
  final String minGpu;
  final List<String> permissions;
  final Map<String, dynamic> metadata;

  GameRequirements({
    required this.minAndroidVersion,
    required this.minRamMB,
    required this.minStorageMB,
    required this.minCpu,
    required this.minGpu,
    required this.permissions,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'minAndroidVersion': minAndroidVersion,
      'minRamMB': minRamMB,
      'minStorageMB': minStorageMB,
      'minCpu': minCpu,
      'minGpu': minGpu,
      'permissions': permissions,
      'metadata': metadata,
    };
  }

  factory GameRequirements.fromJson(Map<String, dynamic> json) {
    return GameRequirements(
      minAndroidVersion: json['minAndroidVersion'] as int,
      minRamMB: json['minRamMB'] as int,
      minStorageMB: json['minStorageMB'] as int,
      minCpu: json['minCpu'] as String,
      minGpu: json['minGpu'] as String,
      permissions: (json['permissions'] as List).cast<String>(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class GameOptimizationProfile {
  final String id;
  final String name;
  final String description;
  final GamePerformanceMode mode;
  final int targetFPS;
  final int cpuCores;
  final double cpuFrequency;
  final int gpuLevel;
  final double temperatureLimit;
  final bool enableOptimization;
  final List<String> features;
  final Map<String, dynamic> settings;

  GameOptimizationProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.mode,
    required this.targetFPS,
    required this.cpuCores,
    required this.cpuFrequency,
    required this.gpuLevel,
    required this.temperatureLimit,
    required this.enableOptimization,
    required this.features,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mode': mode.name,
      'targetFPS': targetFPS,
      'cpuCores': cpuCores,
      'cpuFrequency': cpuFrequency,
      'gpuLevel': gpuLevel,
      'temperatureLimit': temperatureLimit,
      'enableOptimization': enableOptimization,
      'features': features,
      'settings': settings,
    };
  }

  factory GameOptimizationProfile.fromJson(Map<String, dynamic> json) {
    return GameOptimizationProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      mode: GamePerformanceMode.values.firstWhere(
        (mode) => mode.name == json['mode'],
        orElse: () => GamePerformanceMode.balanced,
      ),
      targetFPS: json['targetFPS'] as int,
      cpuCores: json['cpuCores'] as int,
      cpuFrequency: (json['cpuFrequency'] as num).toDouble(),
      gpuLevel: json['gpuLevel'] as int,
      temperatureLimit: (json['temperatureLimit'] as num).toDouble(),
      enableOptimization: json['enableOptimization'] as bool,
      features: (json['features'] as List).cast<String>(),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }
}

class GamePerformanceMode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int priority;
  final Map<String, dynamic> settings;

  GamePerformanceMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.priority,
    required this.settings,
  });

  // Predefined performance modes
  static final GamePerformanceMode powerSave = GamePerformanceMode(
    id: 'power_save',
    name: 'Power Save',
    description: 'Optimize for battery life',
    icon: 'battery_saver',
    priority: 1,
    settings: {
      'targetFPS': 30,
      'cpuCores': 2,
      'cpuFrequency': 1.5,
      'gpuLevel': 1,
      'temperatureLimit': 80.0,
    },
  );

  static final GamePerformanceMode balanced = GamePerformanceMode(
    id: 'balanced',
    name: 'Balanced',
    description: 'Balance performance and battery',
    icon: 'balance',
    priority: 2,
    settings: {
      'targetFPS': 60,
      'cpuCores': 4,
      'cpuFrequency': 2.0,
      'gpuLevel': 2,
      'temperatureLimit': 85.0,
    },
  );

  static final GamePerformanceMode performance = GamePerformanceMode(
    id: 'performance',
    name: 'Performance',
    description: 'Optimize for maximum performance',
    icon: 'performance',
    priority: 3,
    settings: {
      'targetFPS': 120,
      'cpuCores': 6,
      'cpuFrequency': 2.8,
      'gpuLevel': 3,
      'temperatureLimit': 90.0,
    },
  );

  static final GamePerformanceMode extreme = GamePerformanceMode(
    id: 'extreme',
    name: 'Extreme',
    description: 'Maximum performance at any cost',
    icon: 'extreme',
    priority: 4,
    settings: {
      'targetFPS': 144,
      'cpuCores': 8,
      'cpuFrequency': 3.2,
      'gpuLevel': 4,
      'temperatureLimit': 95.0,
    },
  );

  static List<GamePerformanceMode> get values => [powerSave, balanced, performance, extreme];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'priority': priority,
      'settings': settings,
    };
  }

  factory GamePerformanceMode.fromJson(Map<String, dynamic> json) {
    return GamePerformanceMode(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      priority: json['priority'] as int,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }
}

class GameLauncherInfo {
  final String packageName;
  final String launchActivity;
  final List<String> launchFlags;
  final Map<String, String> launchExtras;
  final bool requiresOptimization;
  final int preLaunchDelay;
  final List<String> preLaunchCommands;

  GameLauncherInfo({
    required this.packageName,
    required this.launchActivity,
    required this.launchFlags,
    required this.launchExtras,
    required this.requiresOptimization,
    required this.preLaunchDelay,
    required this.preLaunchCommands,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'launchActivity': launchActivity,
      'launchFlags': launchFlags,
      'launchExtras': launchExtras,
      'requiresOptimization': requiresOptimization,
      'preLaunchDelay': preLaunchDelay,
      'preLaunchCommands': preLaunchCommands,
    };
  }

  factory GameLauncherInfo.fromJson(Map<String, dynamic> json) {
    return GameLauncherInfo(
      packageName: json['packageName'] as String,
      launchActivity: json['launchActivity'] as String,
      launchFlags: (json['launchFlags'] as List).cast<String>(),
      launchExtras: Map<String, String>.from(json['launchExtras'] ?? {}),
      requiresOptimization: json['requiresOptimization'] as bool? ?? false,
      preLaunchDelay: json['preLaunchDelay'] as int? ?? 0,
      preLaunchCommands: (json['preLaunchCommands'] as List).cast<String>(),
    );
  }
}

class GameOptimizationResult {
  final String packageName;
  final bool success;
  final String message;
  final Map<String, dynamic> appliedSettings;
  final DateTime timestamp;
  final int performanceImprovement;

  GameOptimizationResult({
    required this.packageName,
    required this.success,
    required this.message,
    required this.appliedSettings,
    required this.timestamp,
    required this.performanceImprovement,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'success': success,
      'message': message,
      'appliedSettings': appliedSettings,
      'timestamp': timestamp.toIso8601String(),
      'performanceImprovement': performanceImprovement,
    };
  }

  factory GameOptimizationResult.fromJson(Map<String, dynamic> json) {
    return GameOptimizationResult(
      packageName: json['packageName'] as String,
      success: json['success'] as bool,
      message: json['message'] as String,
      appliedSettings: Map<String, dynamic>.from(json['appliedSettings'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      performanceImprovement: json['performanceImprovement'] as int,
    );
  }
}

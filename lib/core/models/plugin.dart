import 'package:hone_mobile/core/services/plugin_service.dart';

class PluginInfo {
  final String id;
  final String name;
  final String description;
  final String version;
  final String author;
  final PluginCategory category;
  final List<PluginPermission> permissions;
  final bool isBuiltIn;
  bool isEnabled;
  final String? downloadUrl;
  final DateTime? releaseDate;
  final int minSdkVersion;
  final String? changelog;
  final Map<String, dynamic> metadata;

  PluginInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    required this.category,
    required this.permissions,
    required this.isBuiltIn,
    required this.isEnabled,
    this.downloadUrl,
    this.releaseDate,
    this.minSdkVersion = 26,
    this.changelog,
    this.metadata = const {},
  });

  PluginInfo copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? author,
    PluginCategory? category,
    List<PluginPermission>? permissions,
    bool? isBuiltIn,
    bool? isEnabled,
    String? downloadUrl,
    DateTime? releaseDate,
    int? minSdkVersion,
    String? changelog,
    Map<String, dynamic>? metadata,
  }) {
    return PluginInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
      category: category ?? this.category,
      permissions: permissions ?? this.permissions,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      minSdkVersion: minSdkVersion ?? this.minSdkVersion,
      changelog: changelog ?? this.changelog,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'author': author,
      'category': category.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'isBuiltIn': isBuiltIn,
      'isEnabled': isEnabled,
      'downloadUrl': downloadUrl,
      'releaseDate': releaseDate?.toIso8601String(),
      'minSdkVersion': minSdkVersion,
      'changelog': changelog,
      'metadata': metadata,
    };
  }

  factory PluginInfo.fromJson(Map<String, dynamic> json) {
    return PluginInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      author: json['author'] as String,
      category: PluginCategory.values.firstWhere((c) => c.name == json['category']),
      permissions: (json['permissions'] as List)
          .map((p) => PluginPermission.values.firstWhere((perm) => perm.name == p))
          .toList(),
      isBuiltIn: json['isBuiltIn'] as bool,
      isEnabled: json['isEnabled'] as bool? ?? true,
      downloadUrl: json['downloadUrl'] as String?,
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
      minSdkVersion: json['minSdkVersion'] as int? ?? 26,
      changelog: json['changelog'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  String get categoryIcon {
    switch (category) {
      case PluginCategory.memory:
        return '💾';
      case PluginCategory.graphics:
        return '🎮';
      case PluginCategory.network:
        return '🌐';
      case PluginCategory.battery:
        return '🔋';
      case PluginCategory.thermal:
        return '🌡️';
      case PluginCategory.gaming:
        return '🎯';
      case PluginCategory.system:
        return '⚙️';
      case PluginCategory.security:
        return '🔒';
      case PluginCategory.other:
        return '📦';
    }
  }

  String get statusEmoji {
    if (!isEnabled) return '⏸️';
    if (isBuiltIn) return '🔧';
    return '📥';
  }
}

enum PluginCategory {
  memory,
  graphics,
  network,
  battery,
  thermal,
  gaming,
  system,
  security,
  other,
}

enum PluginPermission {
  system,
  hardware,
  network,
  storage,
  process,
  apps,
}

enum PluginStatus {
  notLoaded,
  loading,
  active,
  error,
  disabled,
}

class PluginInstance {
  final Plugin plugin;
  final PluginInfo info;
  final PluginStatus status;
  final DateTime loadTime;
  final String? error;
  final Map<String, dynamic> metrics;
  final int executionCount;
  final Duration totalExecutionTime;
  final DateTime? lastExecution;

  PluginInstance({
    required this.plugin,
    required this.info,
    required this.status,
    required this.loadTime,
    this.error,
    this.metrics = const {},
    this.executionCount = 0,
    this.totalExecutionTime = Duration.zero,
    this.lastExecution,
  });

  PluginInstance copyWith({
    Plugin? plugin,
    PluginInfo? info,
    PluginStatus? status,
    DateTime? loadTime,
    String? error,
    Map<String, dynamic>? metrics,
    int? executionCount,
    Duration? totalExecutionTime,
    DateTime? lastExecution,
  }) {
    return PluginInstance(
      plugin: plugin ?? this.plugin,
      info: info ?? this.info,
      status: status ?? this.status,
      loadTime: loadTime ?? this.loadTime,
      error: error ?? this.error,
      metrics: metrics ?? this.metrics,
      executionCount: executionCount ?? this.executionCount,
      totalExecutionTime: totalExecutionTime ?? this.totalExecutionTime,
      lastExecution: lastExecution ?? this.lastExecution,
    );
  }

  String get statusEmoji {
    switch (status) {
      case PluginStatus.notLoaded:
        return '⚪';
      case PluginStatus.loading:
        return '⏳';
      case PluginStatus.active:
        return '🟢';
      case PluginStatus.error:
        return '🔴';
      case PluginStatus.disabled:
        return '⏸️';
    }
  }

  Duration get uptime => DateTime.now().difference(loadTime);
  Duration get averageExecutionTime => executionCount > 0 
      ? Duration(milliseconds: totalExecutionTime.inMilliseconds ~/ executionCount)
      : Duration.zero;
}

class PluginEvent {
  final PluginEventType type;
  final String pluginId;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? message;

  PluginEvent({
    required this.type,
    required this.pluginId,
    required this.timestamp,
    this.data,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'pluginId': pluginId,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'message': message,
    };
  }

  factory PluginEvent.fromJson(Map<String, dynamic> json) {
    return PluginEvent(
      type: PluginEventType.values.firstWhere((t) => t.name == json['type']),
      pluginId: json['pluginId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      message: json['message'] as String?,
    );
  }

  String get typeEmoji {
    switch (type) {
      case PluginEventType.loaded:
        return '✅';
      case PluginEventType.unloaded:
        return '❌';
      case PluginEventType.error:
        return '⚠️';
      case PluginEventType.commandExecuted:
        return '⚡';
      case PluginEventType.installed:
        return '📥';
      case PluginEventType.uninstalled:
        return '📤';
      case PluginEventType.updated:
        return '🔄';
      case PluginEventType.enabled:
        return '🔛';
      case PluginEventType.disabled:
        return '🔴';
    }
  }
}

enum PluginEventType {
  loaded,
  unloaded,
  error,
  commandExecuted,
  installed,
  uninstalled,
  updated,
  enabled,
  disabled,
}

class PluginCommand {
  final String name;
  final String description;
  final List<PluginParameter> parameters;
  final PluginPermission requiredPermission;
  final bool isAsync;
  final Duration? timeout;

  PluginCommand({
    required this.name,
    required this.description,
    required this.parameters,
    required this.requiredPermission,
    this.isAsync = false,
    this.timeout,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'requiredPermission': requiredPermission.name,
      'isAsync': isAsync,
      'timeout': timeout?.inMilliseconds,
    };
  }

  factory PluginCommand.fromJson(Map<String, dynamic> json) {
    return PluginCommand(
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: (json['parameters'] as List)
          .map((p) => PluginParameter.fromJson(p))
          .toList(),
      requiredPermission: PluginPermission.values.firstWhere((p) => p.name == json['requiredPermission']),
      isAsync: json['isAsync'] as bool? ?? false,
      timeout: json['timeout'] != null 
          ? Duration(milliseconds: json['timeout'] as int)
          : null,
    );
  }
}

class PluginParameter {
  final String name;
  final String description;
  final PluginParameterType type;
  final dynamic defaultValue;
  final bool required;
  final List<dynamic>? possibleValues;
  final String? validationRegex;

  PluginParameter({
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.possibleValues,
    this.validationRegex,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'defaultValue': defaultValue,
      'required': required,
      'possibleValues': possibleValues,
      'validationRegex': validationRegex,
    };
  }

  factory PluginParameter.fromJson(Map<String, dynamic> json) {
    return PluginParameter(
      name: json['name'] as String,
      description: json['description'] as String,
      type: PluginParameterType.values.firstWhere((t) => t.name == json['type']),
      defaultValue: json['defaultValue'],
      required: json['required'] as bool? ?? false,
      possibleValues: json['possibleValues'] as List<dynamic>?,
      validationRegex: json['validationRegex'] as String?,
    );
  }
}

enum PluginParameterType {
  string,
  integer,
  double,
  boolean,
  list,
  map,
}

class PluginManifest {
  final String name;
  final String version;
  final String description;
  final String author;
  final PluginCategory category;
  final List<PluginPermission> permissions;
  final List<PluginCommand> commands;
  final String entryPoint;
  final List<String> dependencies;
  final Map<String, dynamic> metadata;

  PluginManifest({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    required this.permissions,
    required this.commands,
    required this.entryPoint,
    required this.dependencies,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'category': category.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'commands': commands.map((c) => c.toJson()).toList(),
      'entryPoint': entryPoint,
      'dependencies': dependencies,
      'metadata': metadata,
    };
  }

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      category: PluginCategory.values.firstWhere((c) => c.name == json['category']),
      permissions: (json['permissions'] as List)
          .map((p) => PluginPermission.values.firstWhere((perm) => perm.name == p))
          .toList(),
      commands: (json['commands'] as List)
          .map((c) => PluginCommand.fromJson(c))
          .toList(),
      entryPoint: json['entryPoint'] as String,
      dependencies: (json['dependencies'] as List).cast<String>(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class PluginRepository {
  final String name;
  final String url;
  final String description;
  final bool isOfficial;
  final List<PluginInfo> availablePlugins;
  final DateTime lastUpdated;

  PluginRepository({
    required this.name,
    required this.url,
    required this.description,
    required this.isOfficial,
    required this.availablePlugins,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'description': description,
      'isOfficial': isOfficial,
      'availablePlugins': availablePlugins.map((p) => p.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PluginRepository.fromJson(Map<String, dynamic> json) {
    return PluginRepository(
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      isOfficial: json['isOfficial'] as bool,
      availablePlugins: (json['availablePlugins'] as List)
          .map((p) => PluginInfo.fromJson(p))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class PluginUpdate {
  final String pluginId;
  final String currentVersion;
  final String newVersion;
  final String changelog;
  final DateTime releaseDate;
  final String downloadUrl;
  final int downloadSize;
  final bool isRequired;
  final List<String> breakingChanges;

  PluginUpdate({
    required this.pluginId,
    required this.currentVersion,
    required this.newVersion,
    required this.changelog,
    required this.releaseDate,
    required this.downloadUrl,
    required this.downloadSize,
    required this.isRequired,
    required this.breakingChanges,
  });

  Map<String, dynamic> toJson() {
    return {
      'pluginId': pluginId,
      'currentVersion': currentVersion,
      'newVersion': newVersion,
      'changelog': changelog,
      'releaseDate': releaseDate.toIso8601String(),
      'downloadUrl': downloadUrl,
      'downloadSize': downloadSize,
      'isRequired': isRequired,
      'breakingChanges': breakingChanges,
    };
  }

  factory PluginUpdate.fromJson(Map<String, dynamic> json) {
    return PluginUpdate(
      pluginId: json['pluginId'] as String,
      currentVersion: json['currentVersion'] as String,
      newVersion: json['newVersion'] as String,
      changelog: json['changelog'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      downloadUrl: json['downloadUrl'] as String,
      downloadSize: json['downloadSize'] as int,
      isRequired: json['isRequired'] as bool,
      breakingChanges: (json['breakingChanges'] as List).cast<String>(),
    );
  }

  String get downloadSizeFormatted {
    if (downloadSize < 1024) return '$downloadSize B';
    if (downloadSize < 1024 * 1024) return '${(downloadSize / 1024).toStringAsFixed(1)} KB';
    if (downloadSize < 1024 * 1024 * 1024) return '${(downloadSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(downloadSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get updateType {
    if (isRequired) return 'Required';
    if (breakingChanges.isNotEmpty) return 'Breaking';
    return 'Optional';
  }
}

class PluginStatistics {
  final int totalPlugins;
  final int activePlugins;
  final int builtInPlugins;
  final int externalPlugins;
  final Map<PluginCategory, int> categoryDistribution;
  final Map<PluginStatus, int> statusDistribution;
  final int totalExecutions;
  final Duration totalExecutionTime;
  final DateTime lastActivity;

  PluginStatistics({
    required this.totalPlugins,
    required this.activePlugins,
    required this.builtInPlugins,
    required this.externalPlugins,
    required this.categoryDistribution,
    required this.statusDistribution,
    required this.totalExecutions,
    required this.totalExecutionTime,
    required this.lastActivity,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPlugins': totalPlugins,
      'activePlugins': activePlugins,
      'builtInPlugins': builtInPlugins,
      'externalPlugins': externalPlugins,
      'categoryDistribution': categoryDistribution.map((k, v) => MapEntry(k.name, v)),
      'statusDistribution': statusDistribution.map((k, v) => MapEntry(k.name, v)),
      'totalExecutions': totalExecutions,
      'totalExecutionTime': totalExecutionTime.inMilliseconds,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  factory PluginStatistics.fromJson(Map<String, dynamic> json) {
    return PluginStatistics(
      totalPlugins: json['totalPlugins'] as int,
      activePlugins: json['activePlugins'] as int,
      builtInPlugins: json['builtInPlugins'] as int,
      externalPlugins: json['externalPlugins'] as int,
      categoryDistribution: Map.from(json['categoryDistribution']).map((k, v) => 
        MapEntry(PluginCategory.values.firstWhere((c) => c.name == k), v as int)),
      statusDistribution: Map.from(json['statusDistribution']).map((k, v) => 
        MapEntry(PluginStatus.values.firstWhere((s) => s.name == k), v as int)),
      totalExecutions: json['totalExecutions'] as int,
      totalExecutionTime: Duration(milliseconds: json['totalExecutionTime'] as int),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );
  }

  double get averageExecutionTime => totalExecutions > 0 
      ? totalExecutionTime.inMilliseconds / totalExecutions 
      : 0.0;
}

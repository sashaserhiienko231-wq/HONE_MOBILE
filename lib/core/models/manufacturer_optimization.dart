// ignore_for_file: constant_identifier_names

enum OptimizationCategory {
  gaming,
  system,
  thermal,
  battery,
  advanced,
  performance,
}

enum SystemGovernor {
  powersave,
  interactive,
  performance,
  userspace,
  ondemand,
  conservative,
  schedutil,
}

enum ThermalProfile {
  cool,
  balanced,
  performance,
  extreme,
}

enum BatteryOptimization {
  powersave,
  balanced,
  performance,
  adaptive,
}

enum GamePerformanceMode {
  power_save,
  balanced,
  performance,
  extreme,
}

class ManufacturerOptimization {
  final String id;
  final String name;
  final String description;
  final OptimizationCategory category;
  final bool requiresRoot;
  final bool isAvailable;
  final String? version;
  final Map<String, dynamic> metadata;

  ManufacturerOptimization({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.requiresRoot = false,
    this.isAvailable = true,
    this.version,
    this.metadata = const {},
  });

  ManufacturerOptimization copyWith({
    String? id,
    String? name,
    String? description,
    OptimizationCategory? category,
    bool? requiresRoot,
    bool? isAvailable,
    String? version,
    Map<String, dynamic>? metadata,
  }) {
    return ManufacturerOptimization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      requiresRoot: requiresRoot ?? this.requiresRoot,
      isAvailable: isAvailable ?? this.isAvailable,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'requiresRoot': requiresRoot,
      'isAvailable': isAvailable,
      'version': version,
      'metadata': metadata,
    };
  }

  factory ManufacturerOptimization.fromJson(Map<String, dynamic> json) {
    return ManufacturerOptimization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: OptimizationCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => OptimizationCategory.system,
      ),
      requiresRoot: json['requiresRoot'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      version: json['version'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}


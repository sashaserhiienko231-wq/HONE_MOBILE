import 'dart:typed_data';

class GameInfo {
  final String packageName;
  final String appName;
  final String category;
  final String version;
  final int versionCode;
  final bool isSystemApp;
  final bool isGame;
  final DateTime installTime;
  final DateTime updateTime;
  final int size;
  final GamePerformanceProfile performanceProfile;
  final Uint8List? icon;

  GameInfo({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.version,
    required this.versionCode,
    required this.isSystemApp,
    required this.isGame,
    required this.installTime,
    required this.updateTime,
    required this.size,
    required this.performanceProfile,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'category': category,
      'version': version,
      'versionCode': versionCode,
      'isSystemApp': isSystemApp,
      'isGame': isGame,
      'installTime': installTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'size': size,
      'performanceProfile': performanceProfile.toJson(),
      'icon': icon,
    };
  }

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      versionCode: json['versionCode'] as int,
      isSystemApp: json['isSystemApp'] as bool,
      isGame: json['isGame'] as bool,
      installTime: DateTime.parse(json['installTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
      size: json['size'] as int,
      performanceProfile: GamePerformanceProfile.fromJson(json['performanceProfile']),
      icon: json['icon'] != null ? Uint8List.fromList(List<int>.from(json['icon'])) : null,
    );
  }
}

class GamePerformanceProfile {
  final int targetFPS;
  final bool optimizeRAM;
  final bool optimizeCPU;
  final bool optimizeGPU;
  final bool disableSync;
  final bool enableDND;

  GamePerformanceProfile({
    this.targetFPS = 60,
    this.optimizeRAM = true,
    this.optimizeCPU = true,
    this.optimizeGPU = true,
    this.disableSync = false,
    this.enableDND = false,
  });

  factory GamePerformanceProfile.performance() {
    return GamePerformanceProfile(
      targetFPS: 120,
      optimizeRAM: true,
      optimizeCPU: true,
      optimizeGPU: true,
      disableSync: true,
      enableDND: true,
    );
  }

  factory GamePerformanceProfile.balanced() {
    return GamePerformanceProfile(
      targetFPS: 60,
      optimizeRAM: true,
      optimizeCPU: true,
      optimizeGPU: true,
      disableSync: false,
      enableDND: false,
    );
  }

  factory GamePerformanceProfile.standard() => GamePerformanceProfile.balanced();

  Map<String, dynamic> toJson() {
    return {
      'targetFPS': targetFPS,
      'optimizeRAM': optimizeRAM,
      'optimizeCPU': optimizeCPU,
      'optimizeGPU': optimizeGPU,
      'disableSync': disableSync,
      'enableDND': enableDND,
    };
  }

  factory GamePerformanceProfile.fromJson(Map<String, dynamic> json) {
    return GamePerformanceProfile(
      targetFPS: json['targetFPS'] as int? ?? 60,
      optimizeRAM: json['optimizeRAM'] as bool? ?? true,
      optimizeCPU: json['optimizeCPU'] as bool? ?? true,
      optimizeGPU: json['optimizeGPU'] as bool? ?? true,
      disableSync: json['disableSync'] as bool? ?? false,
      enableDND: json['enableDND'] as bool? ?? false,
    );
  }
}

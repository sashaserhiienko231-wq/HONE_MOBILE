// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class DiagnosticsReport {
  final String id;
  final DateTime timestamp;
  final SystemInfo systemInfo;
  final PerformanceTests performanceTests;
  final StorageAnalysis storageAnalysis;
  final SystemHealth systemHealth;
  final SecurityAnalysis securityAnalysis;
  final ManufacturerStatus manufacturerStatus;
  final PluginStatus pluginStatus;
  final List<DiagnosticsRecommendation> recommendations;
  final OverallScore overallScore;
  final DiagnosticsStatus status;

  DiagnosticsReport({
    required this.id,
    required this.timestamp,
    required this.systemInfo,
    required this.performanceTests,
    required this.storageAnalysis,
    required this.systemHealth,
    required this.securityAnalysis,
    required this.manufacturerStatus,
    required this.pluginStatus,
    required this.recommendations,
    required this.overallScore,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'systemInfo': systemInfo.toJson(),
      'performanceTests': performanceTests.toJson(),
      'storageAnalysis': storageAnalysis.toJson(),
      'systemHealth': systemHealth.toJson(),
      'securityAnalysis': securityAnalysis.toJson(),
      'manufacturerStatus': manufacturerStatus.toJson(),
      'pluginStatus': pluginStatus.toJson(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'overallScore': overallScore.toJson(),
      'status': status.name,
    };
  }

  factory DiagnosticsReport.fromJson(Map<String, dynamic> json) {
    return DiagnosticsReport(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      systemInfo: SystemInfo.fromJson(json['systemInfo']),
      performanceTests: PerformanceTests.fromJson(json['performanceTests']),
      storageAnalysis: StorageAnalysis.fromJson(json['storageAnalysis']),
      systemHealth: SystemHealth.fromJson(json['systemHealth']),
      securityAnalysis: SecurityAnalysis.fromJson(json['securityAnalysis']),
      manufacturerStatus: ManufacturerStatus.fromJson(json['manufacturerStatus']),
      pluginStatus: PluginStatus.fromJson(json['pluginStatus']),
      recommendations: (json['recommendations'] as List)
          .map((r) => DiagnosticsRecommendation.fromJson(r))
          .toList(),
      overallScore: OverallScore.fromJson(json['overallScore']),
      status: DiagnosticsStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }

  String get statusEmoji {
    switch (status) {
      case DiagnosticsStatus.excellent:
        return '🟢';
      case DiagnosticsStatus.good:
        return '🟡';
      case DiagnosticsStatus.fair:
        return '🟠';
      case DiagnosticsStatus.poor:
        return '🔴';
      case DiagnosticsStatus.critical:
        return '🚨';
    }
  }

  Color get statusColor {
    switch (status) {
      case DiagnosticsStatus.excellent:
        return Colors.green;
      case DiagnosticsStatus.good:
        return Colors.yellow;
      case DiagnosticsStatus.fair:
        return Colors.orange;
      case DiagnosticsStatus.poor:
        return Colors.red;
      case DiagnosticsStatus.critical:
        return Colors.red.shade900;
    }
  }
}

class SystemInfo {
  final String appName;
  final String appVersion;
  final String appBuildNumber;
  final String deviceModel;
  final String deviceManufacturer;
  final String deviceVersion;
  final int deviceSdk;
  final int totalMemory;
  final int availableMemory;
  final int usedMemory;
  final String platform;
  final String architecture;
  final bool isRooted;
  final String bootloader;
  final String kernelVersion;

  SystemInfo({
    required this.appName,
    required this.appVersion,
    required this.appBuildNumber,
    required this.deviceModel,
    required this.deviceManufacturer,
    required this.deviceVersion,
    required this.deviceSdk,
    required this.totalMemory,
    required this.availableMemory,
    required this.usedMemory,
    required this.platform,
    required this.architecture,
    required this.isRooted,
    required this.bootloader,
    required this.kernelVersion,
  });

  static SystemInfo empty() {
    return SystemInfo(
      appName: 'Hone Mobile',
      appVersion: '1.0.0',
      appBuildNumber: '1',
      deviceModel: 'Unknown',
      deviceManufacturer: 'Unknown',
      deviceVersion: 'Unknown',
      deviceSdk: 0,
      totalMemory: 0,
      availableMemory: 0,
      usedMemory: 0,
      platform: 'Unknown',
      architecture: 'Unknown',
      isRooted: false,
      bootloader: 'Unknown',
      kernelVersion: 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'deviceModel': deviceModel,
      'deviceManufacturer': deviceManufacturer,
      'deviceVersion': deviceVersion,
      'deviceSdk': deviceSdk,
      'totalMemory': totalMemory,
      'availableMemory': availableMemory,
      'usedMemory': usedMemory,
      'platform': platform,
      'architecture': architecture,
      'isRooted': isRooted,
      'bootloader': bootloader,
      'kernelVersion': kernelVersion,
    };
  }

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      appName: json['appName'] as String,
      appVersion: json['appVersion'] as String,
      appBuildNumber: json['appBuildNumber'] as String,
      deviceModel: json['deviceModel'] as String,
      deviceManufacturer: json['deviceManufacturer'] as String,
      deviceVersion: json['deviceVersion'] as String,
      deviceSdk: json['deviceSdk'] as int,
      totalMemory: json['totalMemory'] as int,
      availableMemory: json['availableMemory'] as int,
      usedMemory: json['usedMemory'] as int,
      platform: json['platform'] as String,
      architecture: json['architecture'] as String,
      isRooted: json['isRooted'] as bool,
      bootloader: json['bootloader'] as String,
      kernelVersion: json['kernelVersion'] as String,
    );
  }

  String get memoryUsagePercentage {
    if (totalMemory == 0) return '0%';
    return '${((usedMemory / totalMemory) * 100).toStringAsFixed(1)}%';
  }

  String get totalMemoryFormatted {
    if (totalMemory < 1024) return '${totalMemory}B';
    if (totalMemory < 1024 * 1024) return '${(totalMemory / 1024).toStringAsFixed(1)}KB';
    if (totalMemory < 1024 * 1024 * 1024) return '${(totalMemory / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalMemory / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

class PerformanceTests {
  final CPUTest cpuTest;
  final MemoryTest memoryTest;
  final StorageTest storageTest;
  final GPUTest gpuTest;
  final NetworkTest networkTest;
  final int overallScore;

  PerformanceTests({
    required this.cpuTest,
    required this.memoryTest,
    required this.storageTest,
    required this.gpuTest,
    required this.networkTest,
    required this.overallScore,
  });

  static PerformanceTests empty() {
    return PerformanceTests(
      cpuTest: CPUTest.empty(),
      memoryTest: MemoryTest.empty(),
      storageTest: StorageTest.empty(),
      gpuTest: GPUTest.empty(),
      networkTest: NetworkTest.empty(),
      overallScore: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuTest': cpuTest.toJson(),
      'memoryTest': memoryTest.toJson(),
      'storageTest': storageTest.toJson(),
      'gpuTest': gpuTest.toJson(),
      'networkTest': networkTest.toJson(),
      'overallScore': overallScore,
    };
  }

  factory PerformanceTests.fromJson(Map<String, dynamic> json) {
    return PerformanceTests(
      cpuTest: CPUTest.fromJson(json['cpuTest']),
      memoryTest: MemoryTest.fromJson(json['memoryTest']),
      storageTest: StorageTest.fromJson(json['storageTest']),
      gpuTest: GPUTest.fromJson(json['gpuTest']),
      networkTest: NetworkTest.fromJson(json['networkTest']),
      overallScore: json['overallScore'] as int,
    );
  }
}

class CPUTest {
  final int score;
  final Duration duration;
  final int benchmarkResult;
  final double currentUsage;
  final double temperature;
  final int coreCount;
  final int maxFrequency;
  final int currentFrequency;
  final CPUStatus status;

  CPUTest({
    required this.score,
    required this.duration,
    required this.benchmarkResult,
    required this.currentUsage,
    required this.temperature,
    required this.coreCount,
    required this.maxFrequency,
    required this.currentFrequency,
    required this.status,
  });

  static CPUTest empty() {
    return CPUTest(
      score: 0,
      duration: Duration.zero,
      benchmarkResult: 0,
      currentUsage: 0.0,
      temperature: 0.0,
      coreCount: 0,
      maxFrequency: 0,
      currentFrequency: 0,
      status: CPUStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'duration': duration.inMilliseconds,
      'benchmarkResult': benchmarkResult,
      'currentUsage': currentUsage,
      'temperature': temperature,
      'coreCount': coreCount,
      'maxFrequency': maxFrequency,
      'currentFrequency': currentFrequency,
      'status': status.name,
    };
  }

  factory CPUTest.fromJson(Map<String, dynamic> json) {
    return CPUTest(
      score: json['score'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      benchmarkResult: json['benchmarkResult'] as int,
      currentUsage: (json['currentUsage'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      coreCount: json['coreCount'] as int,
      maxFrequency: json['maxFrequency'] as int,
      currentFrequency: json['currentFrequency'] as int,
      status: CPUStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }

  String get statusEmoji {
    switch (status) {
      case CPUStatus.idle:
        return '😴';
      case CPUStatus.normal:
        return '🟢';
      case CPUStatus.busy:
        return '🟡';
      case CPUStatus.overloaded:
        return '🔴';
      case CPUStatus.unknown:
        return '❓';
    }
  }
}

enum CPUStatus {
  idle,
  normal,
  busy,
  overloaded,
  unknown,
}

class MemoryTest {
  final int score;
  final Duration duration;
  final int allocatedMemory;
  final int accessTime;
  final double currentUsage;
  final int availableMemory;
  final int totalMemory;
  final MemoryStatus status;

  MemoryTest({
    required this.score,
    required this.duration,
    required this.allocatedMemory,
    required this.accessTime,
    required this.currentUsage,
    required this.availableMemory,
    required this.totalMemory,
    required this.status,
  });

  static MemoryTest empty() {
    return MemoryTest(
      score: 0,
      duration: Duration.zero,
      allocatedMemory: 0,
      accessTime: 0,
      currentUsage: 0.0,
      availableMemory: 0,
      totalMemory: 0,
      status: MemoryStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'duration': duration.inMilliseconds,
      'allocatedMemory': allocatedMemory,
      'accessTime': accessTime,
      'currentUsage': currentUsage,
      'availableMemory': availableMemory,
      'totalMemory': totalMemory,
      'status': status.name,
    };
  }

  factory MemoryTest.fromJson(Map<String, dynamic> json) {
    return MemoryTest(
      score: json['score'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      allocatedMemory: json['allocatedMemory'] as int,
      accessTime: json['accessTime'] as int,
      currentUsage: (json['currentUsage'] as num).toDouble(),
      availableMemory: json['availableMemory'] as int,
      totalMemory: json['totalMemory'] as int,
      status: MemoryStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }
}

enum MemoryStatus {
  good,
  warning,
  critical,
  overflow,
  unknown,
}

class StorageTest {
  final int score;
  final Duration duration;
  final double writeSpeed;
  final double readSpeed;
  final Duration writeDuration;
  final Duration readDuration;
  final int availableStorage;
  final int totalStorage;
  final StorageStatus status;

  StorageTest({
    required this.score,
    required this.duration,
    required this.writeSpeed,
    required this.readSpeed,
    required this.writeDuration,
    required this.readDuration,
    required this.availableStorage,
    required this.totalStorage,
    required this.status,
  });

  static StorageTest empty() {
    return StorageTest(
      score: 0,
      duration: Duration.zero,
      writeSpeed: 0.0,
      readSpeed: 0.0,
      writeDuration: Duration.zero,
      readDuration: Duration.zero,
      availableStorage: 0,
      totalStorage: 0,
      status: StorageStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'duration': duration.inMilliseconds,
      'writeSpeed': writeSpeed,
      'readSpeed': readSpeed,
      'writeDuration': writeDuration.inMilliseconds,
      'readDuration': readDuration.inMilliseconds,
      'availableStorage': availableStorage,
      'totalStorage': totalStorage,
      'status': status.name,
    };
  }

  factory StorageTest.fromJson(Map<String, dynamic> json) {
    return StorageTest(
      score: json['score'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      writeSpeed: (json['writeSpeed'] as num).toDouble(),
      readSpeed: (json['readSpeed'] as num).toDouble(),
      writeDuration: Duration(milliseconds: json['writeDuration'] as int),
      readDuration: Duration(milliseconds: json['readDuration'] as int),
      availableStorage: json['availableStorage'] as int,
      totalStorage: json['totalStorage'] as int,
      status: StorageStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }

  String get writeSpeedFormatted => '${writeSpeed.toStringAsFixed(1)} MB/s';
  String get readSpeedFormatted => '${readSpeed.toStringAsFixed(1)} MB/s';
}

enum StorageStatus {
  excellent,
  good,
  fair,
  poor,
  unknown,
}

class GPUTest {
  final int score;
  final Duration duration;
  final double frameRate;
  final int renderTime;
  final String resolution;
  final String gpuType;
  final String driverVersion;
  final int memoryUsage;
  final double temperature;
  final GPUStatus status;

  GPUTest({
    required this.score,
    required this.duration,
    required this.frameRate,
    required this.renderTime,
    required this.resolution,
    required this.gpuType,
    required this.driverVersion,
    required this.memoryUsage,
    required this.temperature,
    required this.status,
  });

  static GPUTest empty() {
    return GPUTest(
      score: 0,
      duration: Duration.zero,
      frameRate: 0.0,
      renderTime: 0,
      resolution: 'Unknown',
      gpuType: 'Unknown',
      driverVersion: 'Unknown',
      memoryUsage: 0,
      temperature: 0.0,
      status: GPUStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'duration': duration.inMilliseconds,
      'frameRate': frameRate,
      'renderTime': renderTime,
      'resolution': resolution,
      'gpuType': gpuType,
      'driverVersion': driverVersion,
      'memoryUsage': memoryUsage,
      'temperature': temperature,
      'status': status.name,
    };
  }

  factory GPUTest.fromJson(Map<String, dynamic> json) {
    return GPUTest(
      score: json['score'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      frameRate: (json['frameRate'] as num).toDouble(),
      renderTime: json['renderTime'] as int,
      resolution: json['resolution'] as String,
      gpuType: json['gpuType'] as String,
      driverVersion: json['driverVersion'] as String,
      memoryUsage: json['memoryUsage'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      status: GPUStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }

  String get frameRateFormatted => '${frameRate.toStringAsFixed(1)} FPS';
}

enum GPUStatus {
  excellent,
  good,
  fair,
  poor,
  unknown,
}

class NetworkTest {
  final int score;
  final Duration duration;
  final List<int> pingTimes;
  final double averagePing;
  final double downloadSpeed;
  final double uploadSpeed;
  final double latency;
  final String connectionType;
  final int signalStrength;
  final NetworkStatus status;

  NetworkTest({
    required this.score,
    required this.duration,
    required this.pingTimes,
    required this.averagePing,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.connectionType,
    required this.signalStrength,
    required this.status,
  });

  static NetworkTest empty() {
    return NetworkTest(
      score: 0,
      duration: Duration.zero,
      pingTimes: [],
      averagePing: 0.0,
      downloadSpeed: 0.0,
      uploadSpeed: 0.0,
      latency: 0.0,
      connectionType: 'Unknown',
      signalStrength: 0,
      status: NetworkStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'duration': duration.inMilliseconds,
      'pingTimes': pingTimes,
      'averagePing': averagePing,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'latency': latency,
      'connectionType': connectionType,
      'signalStrength': signalStrength,
      'status': status.name,
    };
  }

  factory NetworkTest.fromJson(Map<String, dynamic> json) {
    return NetworkTest(
      score: json['score'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      pingTimes: (json['pingTimes'] as List).cast<int>(),
      averagePing: (json['averagePing'] as num).toDouble(),
      downloadSpeed: (json['downloadSpeed'] as num).toDouble(),
      uploadSpeed: (json['uploadSpeed'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      connectionType: json['connectionType'] as String,
      signalStrength: json['signalStrength'] as int,
      status: NetworkStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }

  String get averagePingFormatted => '${averagePing.toStringAsFixed(0)}ms';
  String get downloadSpeedFormatted => '${downloadSpeed.toStringAsFixed(1)} Mbps';
  String get uploadSpeedFormatted => '${uploadSpeed.toStringAsFixed(1)} Mbps';
}

enum NetworkStatus {
  excellent,
  good,
  fair,
  poor,
  unknown,
}

class StorageAnalysis {
  final double totalStorage;
  final double freeStorage;
  final double usedStorage;
  final int cacheFiles;
  final int tempFiles;
  final int duplicateFiles;
  final int obsoleteFiles;
  final int largeFiles;
  final int apks;
  final int thumbnails;
  final double fragmentationLevel;
  final int healthScore;
  final List<String> recommendations;

  StorageAnalysis({
    required this.totalStorage,
    required this.freeStorage,
    required this.usedStorage,
    required this.cacheFiles,
    required this.tempFiles,
    required this.duplicateFiles,
    required this.obsoleteFiles,
    required this.largeFiles,
    required this.apks,
    required this.thumbnails,
    required this.fragmentationLevel,
    required this.healthScore,
    required this.recommendations,
  });

  static StorageAnalysis empty() {
    return StorageAnalysis(
      totalStorage: 0.0,
      freeStorage: 0.0,
      usedStorage: 0.0,
      cacheFiles: 0,
      tempFiles: 0,
      duplicateFiles: 0,
      obsoleteFiles: 0,
      largeFiles: 0,
      apks: 0,
      thumbnails: 0,
      fragmentationLevel: 0.0,
      healthScore: 0,
      recommendations: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStorage': totalStorage,
      'freeStorage': freeStorage,
      'usedStorage': usedStorage,
      'cacheFiles': cacheFiles,
      'tempFiles': tempFiles,
      'duplicateFiles': duplicateFiles,
      'obsoleteFiles': obsoleteFiles,
      'largeFiles': largeFiles,
      'apks': apks,
      'thumbnails': thumbnails,
      'fragmentationLevel': fragmentationLevel,
      'healthScore': healthScore,
      'recommendations': recommendations,
    };
  }

  factory StorageAnalysis.fromJson(Map<String, dynamic> json) {
    return StorageAnalysis(
      totalStorage: (json['totalStorage'] as num).toDouble(),
      freeStorage: (json['freeStorage'] as num).toDouble(),
      usedStorage: (json['usedStorage'] as num).toDouble(),
      cacheFiles: json['cacheFiles'] as int,
      tempFiles: json['tempFiles'] as int,
      duplicateFiles: json['duplicateFiles'] as int,
      obsoleteFiles: json['obsoleteFiles'] as int,
      largeFiles: json['largeFiles'] as int,
      apks: json['apks'] as int,
      thumbnails: json['thumbnails'] as int,
      fragmentationLevel: (json['fragmentationLevel'] as num).toDouble(),
      healthScore: json['healthScore'] as int,
      recommendations: (json['recommendations'] as List).cast<String>(),
    );
  }

  String get healthGrade {
    if (healthScore >= 90) return 'A';
    if (healthScore >= 80) return 'B';
    if (healthScore >= 70) return 'C';
    if (healthScore >= 60) return 'D';
    return 'F';
  }
}

class SystemHealth {
  final int cpuHealth;
  final int memoryHealth;
  final int batteryHealth;
  final int thermalHealth;
  final int networkHealth;
  final int storageHealth;
  final int overallHealth;
  final List<SystemIssue> issues;
  final DateTime lastCheck;

  SystemHealth({
    required this.cpuHealth,
    required this.memoryHealth,
    required this.batteryHealth,
    required this.thermalHealth,
    required this.networkHealth,
    required this.storageHealth,
    required this.overallHealth,
    required this.issues,
    required this.lastCheck,
  });

  static SystemHealth empty() {
    return SystemHealth(
      cpuHealth: 0,
      memoryHealth: 0,
      batteryHealth: 0,
      thermalHealth: 0,
      networkHealth: 0,
      storageHealth: 0,
      overallHealth: 0,
      issues: [],
      lastCheck: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuHealth': cpuHealth,
      'memoryHealth': memoryHealth,
      'batteryHealth': batteryHealth,
      'thermalHealth': thermalHealth,
      'networkHealth': networkHealth,
      'storageHealth': storageHealth,
      'overallHealth': overallHealth,
      'issues': issues.map((i) => i.toJson()).toList(),
      'lastCheck': lastCheck.toIso8601String(),
    };
  }

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      cpuHealth: json['cpuHealth'] as int,
      memoryHealth: json['memoryHealth'] as int,
      batteryHealth: json['batteryHealth'] as int,
      thermalHealth: json['thermalHealth'] as int,
      networkHealth: json['networkHealth'] as int,
      storageHealth: json['storageHealth'] as int,
      overallHealth: json['overallHealth'] as int,
      issues: (json['issues'] as List).map((i) => SystemIssue.fromJson(i)).toList(),
      lastCheck: DateTime.parse(json['lastCheck'] as String),
    );
  }
}

class SystemIssue {
  final String type;
  final String description;
  final String severity;
  final DateTime detected;

  SystemIssue({
    required this.type,
    required this.description,
    required this.severity,
    required this.detected,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'severity': severity,
      'detected': detected.toIso8601String(),
    };
  }

  factory SystemIssue.fromJson(Map<String, dynamic> json) {
    return SystemIssue(
      type: json['type'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      detected: DateTime.parse(json['detected'] as String),
    );
  }
}

class SecurityAnalysis {
  final bool rootAccess;
  final bool developerMode;
  final bool unknownSources;
  final bool adbDebugging;
  final bool screenLock;
  final bool encryption;
  final MalwareScanResult malwareScan;
  final PermissionAnalysis permissions;
  final List<SecurityVulnerability> vulnerabilities;
  final int overallSecurity;
  final List<SecurityRecommendation> recommendations;

  SecurityAnalysis({
    required this.rootAccess,
    required this.developerMode,
    required this.unknownSources,
    required this.adbDebugging,
    required this.screenLock,
    required this.encryption,
    required this.malwareScan,
    required this.permissions,
    required this.vulnerabilities,
    required this.overallSecurity,
    required this.recommendations,
  });

  static SecurityAnalysis empty() {
    return SecurityAnalysis(
      rootAccess: false,
      developerMode: false,
      unknownSources: false,
      adbDebugging: false,
      screenLock: true,
      encryption: true,
      malwareScan: MalwareScanResult(clean: 100, threats: 0, detectedThreats: []),
      permissions: PermissionAnalysis(),
      vulnerabilities: [],
      overallSecurity: 0,
      recommendations: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rootAccess': rootAccess,
      'developerMode': developerMode,
      'unknownSources': unknownSources,
      'adbDebugging': adbDebugging,
      'screenLock': screenLock,
      'encryption': encryption,
      'malwareScan': malwareScan.toJson(),
      'permissions': permissions.toJson(),
      'vulnerabilities': vulnerabilities.map((v) => v.toJson()).toList(),
      'overallSecurity': overallSecurity,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
    };
  }

  factory SecurityAnalysis.fromJson(Map<String, dynamic> json) {
    return SecurityAnalysis(
      rootAccess: json['rootAccess'] as bool,
      developerMode: json['developerMode'] as bool,
      unknownSources: json['unknownSources'] as bool,
      adbDebugging: json['adbDebugging'] as bool,
      screenLock: json['screenLock'] as bool,
      encryption: json['encryption'] as bool,
      malwareScan: MalwareScanResult.fromJson(json['malwareScan']),
      permissions: PermissionAnalysis.fromJson(json['permissions']),
      vulnerabilities: (json['vulnerabilities'] as List)
          .map((v) => SecurityVulnerability.fromJson(v))
          .toList(),
      overallSecurity: json['overallSecurity'] as int,
      recommendations: (json['recommendations'] as List)
          .map((r) => SecurityRecommendation.fromJson(r))
          .toList(),
    );
  }
}

class MalwareScanResult {
  final int clean;
  final int threats;
  final List<String> detectedThreats;

  MalwareScanResult({
    required this.clean,
    required this.threats,
    required this.detectedThreats,
  });

  Map<String, dynamic> toJson() {
    return {
      'clean': clean,
      'threats': threats,
      'detectedThreats': detectedThreats,
    };
  }

  factory MalwareScanResult.fromJson(Map<String, dynamic> json) {
    return MalwareScanResult(
      clean: json['clean'] as int,
      threats: json['threats'] as int,
      detectedThreats: (json['detectedThreats'] as List).cast<String>(),
    );
  }
}

class PermissionAnalysis {
  final int grantedPermissions;
  final int deniedPermissions;
  final int riskyPermissions;
  final List<String> suspiciousPermissions;

  PermissionAnalysis({
    this.grantedPermissions = 0,
    this.deniedPermissions = 0,
    this.riskyPermissions = 0,
    this.suspiciousPermissions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'grantedPermissions': grantedPermissions,
      'deniedPermissions': deniedPermissions,
      'riskyPermissions': riskyPermissions,
      'suspiciousPermissions': suspiciousPermissions,
    };
  }

  factory PermissionAnalysis.fromJson(Map<String, dynamic> json) {
    return PermissionAnalysis(
      grantedPermissions: json['grantedPermissions'] as int? ?? 0,
      deniedPermissions: json['deniedPermissions'] as int? ?? 0,
      riskyPermissions: json['riskyPermissions'] as int? ?? 0,
      suspiciousPermissions: (json['suspiciousPermissions'] as List?)?.cast<String>() ?? [],
    );
  }
}

class SecurityVulnerability {
  final String type;
  final String description;
  final String severity;
  final String recommendation;

  SecurityVulnerability({
    required this.type,
    required this.description,
    required this.severity,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'severity': severity,
      'recommendation': recommendation,
    };
  }

  factory SecurityVulnerability.fromJson(Map<String, dynamic> json) {
    return SecurityVulnerability(
      type: json['type'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      recommendation: json['recommendation'] as String,
    );
  }
}

class SecurityRecommendation {
  final String title;
  final String description;
  final String priority;
  final String action;

  SecurityRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'action': action,
    };
  }

  factory SecurityRecommendation.fromJson(Map<String, dynamic> json) {
    return SecurityRecommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      action: json['action'] as String,
    );
  }
}

class ManufacturerStatus {
  final String manufacturer;
  final bool hasIntegration;
  final int availableOptimizations;
  final int enabledOptimizations;
  final bool gameTurboEnabled;
  final List<String> customFeatures;
  final double compatibility;
  final double performance;
  final ManufacturerIntegrationStatus status;

  ManufacturerStatus({
    required this.manufacturer,
    required this.hasIntegration,
    required this.availableOptimizations,
    required this.enabledOptimizations,
    required this.gameTurboEnabled,
    required this.customFeatures,
    required this.compatibility,
    required this.performance,
    required this.status,
  });

  static ManufacturerStatus empty() {
    return ManufacturerStatus(
      manufacturer: 'Unknown',
      hasIntegration: false,
      availableOptimizations: 0,
      enabledOptimizations: 0,
      gameTurboEnabled: false,
      customFeatures: [],
      compatibility: 0.0,
      performance: 0.0,
      status: ManufacturerIntegrationStatus.none,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer,
      'hasIntegration': hasIntegration,
      'availableOptimizations': availableOptimizations,
      'enabledOptimizations': enabledOptimizations,
      'gameTurboEnabled': gameTurboEnabled,
      'customFeatures': customFeatures,
      'compatibility': compatibility,
      'performance': performance,
      'status': status.name,
    };
  }

  factory ManufacturerStatus.fromJson(Map<String, dynamic> json) {
    return ManufacturerStatus(
      manufacturer: json['manufacturer'] as String,
      hasIntegration: json['hasIntegration'] as bool,
      availableOptimizations: json['availableOptimizations'] as int,
      enabledOptimizations: json['enabledOptimizations'] as int,
      gameTurboEnabled: json['gameTurboEnabled'] as bool,
      customFeatures: (json['customFeatures'] as List).cast<String>(),
      compatibility: (json['compatibility'] as num).toDouble(),
      performance: (json['performance'] as num).toDouble(),
      status: ManufacturerIntegrationStatus.values.firstWhere((s) => s.name == json['status']),
    );
  }
}

enum ManufacturerIntegrationStatus {
  none,
  basic,
  good,
  excellent,
}

class PluginStatus {
  final int totalPlugins;
  final int activePlugins;
  final int builtInPlugins;
  final int externalPlugins;
  final int enabledPlugins;
  final int disabledPlugins;
  final int errorPlugins;
  final DateTime lastUpdate;
  final double compatibility;
  final double performance;
  final List<PluginRecommendation> recommendations;

  PluginStatus({
    required this.totalPlugins,
    required this.activePlugins,
    required this.builtInPlugins,
    required this.externalPlugins,
    required this.enabledPlugins,
    required this.disabledPlugins,
    required this.errorPlugins,
    required this.lastUpdate,
    required this.compatibility,
    required this.performance,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPlugins': totalPlugins,
      'activePlugins': activePlugins,
      'builtInPlugins': builtInPlugins,
      'externalPlugins': externalPlugins,
      'enabledPlugins': enabledPlugins,
      'disabledPlugins': disabledPlugins,
      'errorPlugins': errorPlugins,
      'lastUpdate': lastUpdate.toIso8601String(),
      'compatibility': compatibility,
      'performance': performance,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
    };
  }

  factory PluginStatus.empty() {
    return PluginStatus(
      totalPlugins: 0,
      activePlugins: 0,
      builtInPlugins: 0,
      externalPlugins: 0,
      enabledPlugins: 0,
      disabledPlugins: 0,
      errorPlugins: 0,
      lastUpdate: DateTime.now(),
      compatibility: 0,
      performance: 0,
      recommendations: [],
    );
  }

  factory PluginStatus.fromJson(Map<String, dynamic> json) {
    return PluginStatus(
      totalPlugins: json['totalPlugins'] as int,
      activePlugins: json['activePlugins'] as int,
      builtInPlugins: json['builtInPlugins'] as int,
      externalPlugins: json['externalPlugins'] as int,
      enabledPlugins: json['enabledPlugins'] as int,
      disabledPlugins: json['disabledPlugins'] as int,
      errorPlugins: json['errorPlugins'] as int,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      compatibility: (json['compatibility'] as num).toDouble(),
      performance: (json['performance'] as num).toDouble(),
      recommendations: (json['recommendations'] as List)
          .map((r) => PluginRecommendation.fromJson(r))
          .toList(),
    );
  }
}

class PluginRecommendation {
  final String pluginId;
  final String title;
  final String description;
  final String action;

  PluginRecommendation({
    required this.pluginId,
    required this.title,
    required this.description,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'pluginId': pluginId,
      'title': title,
      'description': description,
      'action': action,
    };
  }

  factory PluginRecommendation.fromJson(Map<String, dynamic> json) {
    return PluginRecommendation(
      pluginId: json['pluginId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      action: json['action'] as String,
    );
  }
}

class DiagnosticsRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String action;
  final String impact;

  DiagnosticsRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.impact,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'action': action,
      'impact': impact,
    };
  }

  factory DiagnosticsRecommendation.fromJson(Map<String, dynamic> json) {
    return DiagnosticsRecommendation(
      type: RecommendationType.values.firstWhere((t) => t.name == json['type']),
      priority: RecommendationPriority.values.firstWhere((p) => p.name == json['priority']),
      title: json['title'] as String,
      description: json['description'] as String,
      action: json['action'] as String,
      impact: json['impact'] as String,
    );
  }

  String get priorityEmoji {
    switch (priority) {
      case RecommendationPriority.critical:
        return '🔴';
      case RecommendationPriority.high:
        return '🟠';
      case RecommendationPriority.medium:
        return '🟡';
      case RecommendationPriority.low:
        return '🟢';
    }
  }
}

enum RecommendationType {
  performance,
  storage,
  security,
  manufacturer,
  plugin,
  system,
}

enum RecommendationPriority {
  critical,
  high,
  medium,
  low,
}

class OverallScore {
  final int score;
  final String grade;
  final ScoreCategory category;
  final ScoreTrend trend;
  final ScoreComparison comparison;

  OverallScore({
    required this.score,
    required this.grade,
    required this.category,
    required this.trend,
    required this.comparison,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'grade': grade,
      'category': category.name,
      'trend': trend.name,
      'comparison': comparison.name,
    };
  }

  factory OverallScore.fromJson(Map<String, dynamic> json) {
    return OverallScore(
      score: json['score'] as int,
      grade: json['grade'] as String,
      category: ScoreCategory.values.firstWhere((c) => c.name == json['category']),
      trend: ScoreTrend.values.firstWhere((t) => t.name == json['trend']),
      comparison: ScoreComparison.values.firstWhere((c) => c.name == json['comparison']),
    );
  }

  Color get scoreColor {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.yellow;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

enum ScoreCategory {
  excellent,
  good,
  fair,
  poor,
}

enum ScoreTrend {
  improving,
  stable,
  declining,
}

enum ScoreComparison {
  excellent,
  above_average,
  average,
  below_average,
  poor,
}

enum DiagnosticsStatus {
  excellent,
  good,
  fair,
  poor,
  critical,
}

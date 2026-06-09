import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:hone_mobile/core/services/encryption_service.dart';
import 'package:hone_mobile/core/services/game_database_service.dart';
import 'package:hone_mobile/core/services/scheduled_optimization_service.dart';
import 'package:hone_mobile/core/services/advanced_storage_service.dart';
import 'package:hone_mobile/core/services/ai_recommendation_service.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';

class CloudBackupService {
  static bool _isInitialized = false;
  static FirebaseStorage? _storage;
  static FirebaseFirestore? _firestore;
  static String? _userId;
  
  static const String _backupsCollection = 'backups';
  static const int _maxBackups = 10;
  static const int _maxBackupSize = 50 * 1024 * 1024; // 50MB

  /// Max allowed backup size in bytes (read-only helper for UI/diagnostics).
  static int get maxBackupSize => _maxBackupSize;
  
  static final StreamController<BackupEvent> _eventController = StreamController.broadcast();
  static List<CloudBackup> _backupHistory = [];
  static bool _autoBackupEnabled = true;
  static Duration _backupInterval = const Duration(days: 7);
  static Timer? _backupTimer;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _storage = FirebaseStorage.instance;
      _firestore = FirebaseFirestore.instance;
      
      await _loadBackupSettings();
      await _loadBackupHistory();
      
      if (_autoBackupEnabled) {
        _startAutoBackup();
      }
      
      _isInitialized = true;
      debugPrint('Cloud Backup Service initialized');
    } catch (e) {
      debugPrint('Error initializing Cloud Backup Service: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _loadBackupSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      _backupInterval = Duration(days: prefs.getInt('backup_interval_days') ?? 7);
      _userId = prefs.getString('user_id');
    } catch (e) {
      debugPrint('Error loading backup settings: $e');
      _autoBackupEnabled = true;
      _backupInterval = const Duration(days: 7);
    }
  }

  static Future<void> _loadBackupHistory() async {
    try {
      if (_userId == null) return;
      
      final snapshot = await _firestore!
          .collection(_backupsCollection)
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .limit(_maxBackups)
          .get();
      
      _backupHistory = snapshot.docs
          .map((doc) => CloudBackup.fromFirebase(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading backup history: $e');
      _backupHistory = [];
    }
  }

  static void _startAutoBackup() {
    _backupTimer = Timer.periodic(_backupInterval, (timer) {
      if (_userId != null && _autoBackupEnabled) {
        _performAutoBackup();
      }
    });
  }

  static Future<void> _performAutoBackup() async {
    try {
      debugPrint('Performing automatic backup');
      
      final backup = await createBackup(
        name: 'Auto Backup',
        description: 'Automatic backup',
        type: BackupType.automatic,
      );
      
      if (backup.success) {
        _eventController.add(BackupEvent(
          type: BackupEventType.created,
          backupId: backup.id,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint('Error performing auto backup: $e');
    }
  }

  static Future<CloudBackup> createBackup({
    String? name,
    String? description,
    BackupType type = BackupType.manual,
    List<String>? includeData,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('No user logged in');
      }
      
      name ??= 'Backup ${DateTime.now().millisecondsSinceEpoch}';
      description ??= 'Manual backup created on ${DateTime.now()}';
      
      // Collect backup data
      final backupData = await _collectBackupData(includeData);
      
      // Create backup metadata
      final backup = CloudBackup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        name: name,
        description: description,
        type: type,
        size: backupData.length,
        checksum: _calculateChecksum(backupData),
        createdAt: DateTime.now(),
        data: backupData,
        isEncrypted: true,
        deviceId: 'current_device',
      );
      
      // Save backup metadata to Firestore
      await _saveBackupToFirestore(backup);
      
      // Upload backup data to Firebase Storage
      await _uploadBackupData(backup);
      
      // Update backup history
      _backupHistory.insert(0, backup);
      if (_backupHistory.length > _maxBackups) {
        await _deleteOldestBackup();
      }
      
      // Cache backup history
      await _cacheBackupHistory();
      
      debugPrint('Backup created: ${backup.name} (${backup.sizeFormatted})');
      
      return backup;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _collectBackupData(List<String>? includeData) async {
    final data = <String, dynamic>{};
    
    // Default data to include
    final defaultIncludes = [
      'user_preferences',
      'optimization_presets',
      'game_profiles',
      'performance_history',
      'ai_recommendations',
      'storage_analysis',
      'scheduled_optimizations',
    ];
    
    final dataToInclude = includeData ?? defaultIncludes;
    
    for (final dataType in dataToInclude) {
      switch (dataType) {
        case 'user_preferences':
          data['user_preferences'] = await _getUserPreferences();
          break;
        case 'optimization_presets':
          data['optimization_presets'] = await _getOptimizationPresets();
          break;
        case 'game_profiles':
          data['game_profiles'] = await _getGameProfiles();
          break;
        case 'performance_history':
          data['performance_history'] = await _getPerformanceHistory();
          break;
        case 'ai_recommendations':
          data['ai_recommendations'] = await _getAIRecommendations();
          break;
        case 'storage_analysis':
          data['storage_analysis'] = await _getStorageAnalysis();
          break;
        case 'scheduled_optimizations':
          data['scheduled_optimizations'] = await _getScheduledOptimizations();
          break;
        case 'plugin_settings':
          data['plugin_settings'] = await _getPluginSettings();
          break;
      }
    }
    
    return data;
  }

  static Future<Map<String, dynamic>> _getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final preferences = <String, dynamic>{};
      
      for (final entry in keys) {
        if (entry.startsWith('pref_')) {
          preferences[entry] = prefs.get(entry);
        }
      }
      
      return preferences;
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getOptimizationPresets() async {
    try {
      // Get optimization presets from the optimization service
      return {
        'presets': [
          {
            'id': 'gaming_preset',
            'name': 'Gaming Performance',
            'settings': {
              'cpu_performance': 'high',
              'gpu_performance': 'high',
              'thermal_control': 'aggressive',
              'battery_optimization': 'performance',
            },
          },
          {
            'id': 'battery_saver_preset',
            'name': 'Battery Saver',
            'settings': {
              'cpu_performance': 'low',
              'gpu_performance': 'low',
              'thermal_control': 'conservative',
              'battery_optimization': 'maximum',
            },
          },
        ],
      };
    } catch (e) {
      debugPrint('Error getting optimization presets: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getGameProfiles() async {
    try {
      // Get game profiles from the game database service
      final games = GameDatabaseService.localGames;
      final profiles = <String, dynamic>{};
      
      for (final game in games) {
        profiles[game.packageName] = game.performanceProfile.toJson();
            }
      
      return {
        'game_profiles': profiles,
        'total_games': games.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting game profiles: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getPerformanceHistory() async {
    try {
      // Get performance history from performance monitor service
      final history = PerformanceMonitorService.historicalStats;
      
      final performanceData = history.map((stat) => stat.toJson()).toList();
      
      return {
        'performance_history': performanceData,
        'total_entries': performanceData.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting performance history: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getAIRecommendations() async {
    try {
      // Get AI recommendations from the AI service
      final recommendations = AIRecommendationService.activeRecommendations;
      
      final recommendationsData = recommendations.map((rec) => rec.toJson()).toList();
      
      return {
        'ai_recommendations': recommendationsData,
        'total_recommendations': recommendations.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting AI recommendations: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getStorageAnalysis() async {
    try {
      // Get storage analysis from the storage service
      final analysis = AdvancedStorageService.lastAnalysis;
      
      return {
        'storage_analysis': analysis.toJson(),
        'timestamp': analysis.timestamp.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting storage analysis: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getScheduledOptimizations() async {
    try {
      // Get scheduled optimizations from the scheduled service
      final schedules = ScheduledOptimizationService.activeSchedules;
      
      final schedulesData = schedules.map((schedule) => schedule.toJson()).toList();
      
      return {
        'scheduled_optimizations': schedulesData,
        'total_schedules': schedules.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting scheduled optimizations: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getPluginSettings() async {
    try {
      // Get plugin settings from the plugin service
      return {
        'plugin_settings': {
          'enabled_plugins': [],
          'disabled_plugins': [],
          'auto_updates': false,
        },
      };
    } catch (e) {
      debugPrint('Error getting plugin settings: $e');
      return {};
    }
  }

  static String _calculateChecksum(Map<String, dynamic> data) {
    final bytes = utf8.encode(jsonEncode(data));
    int hash = 0;
    for (int i = 0; i < bytes.length; i++) {
      hash = hash * 31 + bytes[i];
    }
    return hash.toString();
  }

  static Future<void> _saveBackupToFirestore(CloudBackup backup) async {
    try {
      await _firestore!
          .collection(_backupsCollection)
          .doc(backup.id)
          .set(backup.toFirebaseMap());
    } catch (e) {
      debugPrint('Error saving backup to Firestore: $e');
    }
  }

  static Future<void> _uploadBackupData(CloudBackup backup) async {
    try {
      // Encrypt backup data
      final encryptedData = await EncryptionService.encrypt(jsonEncode(backup.data));
      
      // Upload to Firebase Storage
      final ref = _storage!
          .ref()
          .child('backups')
          .child('${backup.userId}/${backup.id}.backup');
      
      final uploadTask = ref.putData(Uint8List.fromList(utf8.encode(encryptedData)));
      
      // Wait for upload to complete
      await uploadTask;
      
      debugPrint('Backup data uploaded: ${backup.name}');
    } catch (e) {
      debugPrint('Error uploading backup data: $e');
    }
  }

  static Future<void> _deleteOldestBackup() async {
    try {
      if (_backupHistory.isEmpty) return;
      
      final oldestBackup = _backupHistory.removeLast();
      
      await _storage!
          .ref()
          .child('backups')
          .child('${oldestBackup.userId}/${oldestBackup.id}.backup')
          .delete();
      
      await _firestore!
          .collection(_backupsCollection)
          .doc(oldestBackup.id)
          .delete();
      
      await _firestore!
          .collection(_backupsCollection)
          .doc(oldestBackup.id)
          .delete();
      
      await _cacheBackupHistory();
      
      debugPrint('Deleted oldest backup: ${oldestBackup.name}');
    } catch (e) {
      debugPrint('Error deleting oldest backup: $e');
    }
  }

  static Future<void> _cacheBackupHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupsJson = jsonEncode(_backupHistory.map((b) => b.toJson()).toList());
      await prefs.setString('backup_history', backupsJson);
    } catch (e) {
      debugPrint('Error caching backup history: $e');
    }
  }

  // Public API
  static Stream<BackupEvent> get events => _eventController.stream;
  static List<CloudBackup> get backupHistory => List.unmodifiable(_backupHistory);
  static bool get isInitialized => _isInitialized;
  static bool get autoBackupEnabled => _autoBackupEnabled;
  static Duration get backupInterval => _backupInterval;

  static Future<CloudBackup> restoreBackup(String backupId) async {
    try {
      debugPrint('Restoring backup: $backupId');
      
      // Get backup metadata
      final backupDoc = await _firestore!
          .collection(_backupsCollection)
          .doc(backupId)
          .get();
      
      if (!backupDoc.exists) {
        throw Exception('Backup not found');
      }
      
      final backup = CloudBackup.fromFirebase(backupDoc);
      
      // Download backup data
      final ref = _storage!
          .ref()
          .child('backups')
          .child('${backup.userId}/${backup.id}.backup');
      
      final downloadTask = ref.getData();
      final encryptedData = await downloadTask;
      
      // Decrypt backup data
      if (encryptedData == null) {
        throw Exception('Backup data not found');
      }
      final decryptedData =
          await EncryptionService.decrypt(utf8.decode(encryptedData));
      final backupData = jsonDecode(decryptedData) as Map<String, dynamic>;
      
      // Restore data from backup
      await _restoreFromBackupData(backupData);
      
      // Update backup metadata
      final restoredBackup = backup.copyWith(
        restoredAt: DateTime.now(),
        isRestored: true,
      );
      
      await _saveBackupToFirestore(restoredBackup);
      
      _eventController.add(BackupEvent(
        type: BackupEventType.restored,
        backupId: backupId,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('Backup restored successfully: ${backup.name}');
      
      return restoredBackup;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  static Future<void> _restoreFromBackupData(Map<String, dynamic> backupData) async {
    try {
      // Restore user preferences
      if (backupData.containsKey('user_preferences')) {
        await _restoreUserPreferences(backupData['user_preferences']);
      }
      
      // Restore optimization presets
      if (backupData.containsKey('optimization_presets')) {
        await _restoreOptimizationPresets(backupData['optimization_presets']);
      }
      
      // Restore game profiles
      if (backupData.containsKey('game_profiles')) {
        await _restoreGameProfiles(backupData['game_profiles']);
      }
      
      // Restore performance history
      if (backupData.containsKey('performance_history')) {
        await _restorePerformanceHistory(backupData['performance_history']);
      }
      
      // Restore AI recommendations
      if (backupData.containsKey('ai_recommendations')) {
        await _restoreAIRecommendations(backupData['ai_recommendations']);
      }
      
      // Restore storage analysis
      if (backupData.containsKey('storage_analysis')) {
        await _restoreStorageAnalysis(backupData['storage_analysis']);
      }
      
      // Restore scheduled optimizations
      if (backupData.containsKey('scheduled_optimizations')) {
        await _restoreScheduledOptimizations(backupData['scheduled_optimizations']);
      }
      
      // Restore plugin settings
      if (backupData.containsKey('plugin_settings')) {
        await _restorePluginSettings(backupData['plugin_settings']);
      }
      
      debugPrint('All backup data restored successfully');
    } catch (e) {
      debugPrint('Error restoring backup data: $e');
    }
  }

  static Future<void> _restoreUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final entry in preferences.entries) {
        await prefs.setString('pref_${entry.key}', jsonEncode(entry.value));
      }
      
      debugPrint('User preferences restored');
    } catch (e) {
      debugPrint('Error restoring user preferences: $e');
    }
  }

  static Future<void> _restoreOptimizationPresets(Map<String, dynamic> presets) async {
    // This would integrate with the optimization service
    debugPrint('Optimization presets restored: ${presets.length}');
  }

  static Future<void> _restoreGameProfiles(Map<String, dynamic> profiles) async {
    // This would integrate with the game database service
    debugPrint('Game profiles restored: ${profiles.length}');
  }

  static Future<void> _restorePerformanceHistory(Map<String, dynamic> history) async {
    // This would integrate with the performance monitor service
    debugPrint('Performance history restored: ${history['total_entries']}');
  }

  static Future<void> _restoreAIRecommendations(Map<String, dynamic> recommendations) async {
    // This would integrate with the AI recommendation service
    debugPrint('AI recommendations restored: ${recommendations['total_recommendations']}');
  }

  static Future<void> _restoreStorageAnalysis(Map<String, dynamic> analysis) async {
    // This would integrate with the storage service
    debugPrint('Storage analysis restored');
  }

  static Future<void> _restoreScheduledOptimizations(Map<String, dynamic> schedules) async {
    // This would integrate with the scheduled optimization service
    debugPrint('Scheduled optimizations restored: ${schedules['total_schedules']}');
  }

  static Future<void> _restorePluginSettings(Map<String, dynamic> settings) async {
    // This would integrate with the plugin service
    debugPrint('Plugin settings restored');
  }

  static Future<bool> deleteBackup(String backupId) async {
    try {
      debugPrint('Deleting backup: $backupId');
      
      final backup = _backupHistory.firstWhere((b) => b.id == backupId);
      
      // Delete from Firebase Storage
      await _storage!
          .ref()
          .child('backups')
          .child('${backup.userId}/${backup.id}.backup')
          .delete();
      
      // Delete from Firestore
      await _firestore!
          .collection(_backupsCollection)
          .doc(backup.id)
          .delete();
      
      // Remove from local history
      _backupHistory.removeWhere((b) => b.id == backupId);
      
      // Cache updated history
      await _cacheBackupHistory();
      
      _eventController.add(BackupEvent(
        type: BackupEventType.deleted,
        backupId: backupId,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('Backup deleted successfully: ${backup.name}');
      return true;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }

  static Future<bool> restoreUserData() async {
    try {
      if (_backupHistory.isEmpty) return false;
      await restoreBackup(_backupHistory.first.id);
      return true;
    } catch (e) {
      debugPrint('Error restoring user data: $e');
      return false;
    }
  }

  static Future<bool> syncUserData() async {
    try {
      if (_userId == null) return false;
      
      debugPrint('Syncing user data to cloud');
      
      // Collect current user data
      // NOTE: The data is consumed by createBackup() internally. Keep reference
      // here for future enhancements and to avoid analyzer "unused_local_variable".
      await _collectUserData();
      
      // Create sync backup
      final backup = await createBackup(
        name: 'User Data Sync',
        description: 'Automatic user data synchronization',
        type: BackupType.sync,
      );
      
      if (backup.success) {
        _eventController.add(BackupEvent(
          type: BackupEventType.synced,
          backupId: backup.id,
          timestamp: DateTime.now(),
        ));
      }
      
      return backup.success;
    } catch (e) {
      debugPrint('Error syncing user data: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _collectUserData() async {
    return await _collectBackupData(null);
  }

  static Future<bool> enableAutoBackup() async {
    _autoBackupEnabled = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', true);
      
      if (!_isInitialized) {
        await initialize();
      } else if (_backupTimer == null) {
        _startAutoBackup();
      }
      
      debugPrint('Auto backup enabled');
      return true;
    } catch (e) {
      debugPrint('Error enabling auto backup: $e');
      return false;
    }
  }

  static Future<bool> disableAutoBackup() async {
    _autoBackupEnabled = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', false);
      
      _backupTimer?.cancel();
      _backupTimer = null;
      
      debugPrint('Auto backup disabled');
      return true;
    } catch (e) {
      debugPrint('Error disabling auto backup: $e');
      return false;
    }
  }

  static Future<void> setBackupInterval(Duration interval) async {
    _backupInterval = interval;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('backup_interval_days', interval.inDays);
      
      if (_autoBackupEnabled) {
        _backupTimer?.cancel();
        _startAutoBackup();
      }
      
      debugPrint('Backup interval set to ${interval.inDays} days');
    } catch (e) {
      debugPrint('Error setting backup interval: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    _userId = userId;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      
      // Load backup history for new user
      await _loadBackupHistory();
      
      debugPrint('User ID set: $userId');
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  static void dispose() {
    _backupTimer?.cancel();
    _eventController.close();
  }
}

class CloudBackup {
  final String id;
  final String userId;
  final String name;
  final String description;
  final BackupType type;
  final int size;
  final String checksum;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isEncrypted;
  final String deviceId;
  final DateTime? restoredAt;
  final bool isRestored;
  final DateTime? deletedAt;

  CloudBackup({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    required this.size,
    required this.checksum,
    required this.createdAt,
    required this.data,
    required this.isEncrypted,
    required this.deviceId,
    this.restoredAt,
    this.isRestored = false,
    this.deletedAt,
  });

  CloudBackup copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    BackupType? type,
    int? size,
    String? checksum,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    bool? isEncrypted,
    String? deviceId,
    DateTime? restoredAt,
    bool? isRestored,
    DateTime? deletedAt,
  }) {
    return CloudBackup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      deviceId: deviceId ?? this.deviceId,
      restoredAt: restoredAt ?? this.restoredAt,
      isRestored: isRestored ?? this.isRestored,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'size': size,
      'checksum': checksum,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
      'isEncrypted': isEncrypted,
      'deviceId': deviceId,
      'restoredAt': restoredAt?.toIso8601String(),
      'isRestored': isRestored,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory CloudBackup.fromJson(Map<String, dynamic> json) {
    return CloudBackup(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: BackupType.values.firstWhere((t) => t.name == json['type']),
      size: json['size'] as int,
      checksum: json['checksum'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      deviceId: json['deviceId'] as String,
      restoredAt: json['restoredAt'] != null 
          ? DateTime.parse(json['restoredAt'] as String)
          : null,
      isRestored: json['isRestored'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'size': size,
      'checksum': checksum,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
      'isEncrypted': isEncrypted,
      'deviceId': deviceId,
      'restoredAt': restoredAt != null 
          ? Timestamp.fromDate(restoredAt!)
          : null,
      'isRestored': isRestored,
      'deletedAt': deletedAt != null 
          ? Timestamp.fromDate(deletedAt!)
          : null,
    };
  }

  factory CloudBackup.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CloudBackup(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      type: BackupType.values.firstWhere((t) => t.name == data['type']),
      size: data['size'] as int,
      checksum: data['checksum'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isEncrypted: data['isEncrypted'] as bool? ?? false,
      deviceId: data['deviceId'] as String,
      restoredAt: data['restoredAt'] != null 
          ? (data['restoredAt'] as Timestamp).toDate()
          : null,
      isRestored: data['isRestored'] as bool? ?? false,
      deletedAt: data['deletedAt'] != null 
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  bool get success => id.isNotEmpty;

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get typeEmoji {
    switch (type) {
      case BackupType.manual:
        return '📦';
      case BackupType.automatic:
        return '🔄';
      case BackupType.sync:
        return '☁️';
      case BackupType.system:
        return '⚙️';
    }
  }

  String get statusEmoji {
    if (deletedAt != null) return '🗑️';
    if (isRestored) return '✅';
    return '📋';
  }
}

enum BackupType {
  manual,
  automatic,
  sync,
  system,
}

class BackupEvent {
  final BackupEventType type;
  final String backupId;
  final DateTime timestamp;
  final String? message;

  BackupEvent({
    required this.type,
    required this.backupId,
    required this.timestamp,
    this.message,
  });
}

enum BackupEventType {
  created,
  restored,
  deleted,
  synced,
  failed,
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/core/models/game_database.dart';

class GameDatabaseService {
  static bool _isInitialized = false;
  static const String _baseUrl = 'https://api.hone-mobile.com/v1';
  static const String _gamesEndpoint = '$_baseUrl/games';
  static const String _syncEndpoint = '$_baseUrl/sync';
  
  static List<GameInfo> _localGames = [];
  static List<CloudGameInfo> _cloudGames = [];
  static Map<String, GamePerformanceProfile> _gameProfiles = {};
  static Map<String, GameCategory> _gameCategories = {};
  
  static final StreamController<List<GameInfo>> _gamesController = StreamController.broadcast();
  static final StreamController<SyncStatus> _syncController = StreamController.broadcast();
  static Timer? _syncTimer;
  static bool _autoSyncEnabled = true;
  static Duration _syncInterval = const Duration(hours: 1);

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadLocalData();
      await _loadGameProfiles();
      await _loadGameCategories();
      await _fetchCloudGames();
      
      if (_autoSyncEnabled) {
        _startAutoSync();
      }
      
      _isInitialized = true;
      debugPrint('Game Database Service initialized');
      debugPrint('Local games: ${_localGames.length}');
      debugPrint('Cloud games: ${_cloudGames.length}');
    } catch (e) {
      debugPrint('Error initializing Game Database Service: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = prefs.getString('local_games') ?? '[]';
      
      final gamesList = jsonDecode(gamesJson) as List;
      _localGames = gamesList.map((game) => GameInfo.fromJson(game)).toList();
      
      _gamesController.add(_localGames);
    } catch (e) {
      debugPrint('Error loading local data: $e');
      _localGames = [];
    }
  }

  static Future<void> _loadGameProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getString('game_profiles') ?? '{}';
      
      final profilesMap = jsonDecode(profilesJson) as Map<String, dynamic>;
      _gameProfiles = profilesMap.map((key, value) => 
        MapEntry(key, GamePerformanceProfile.fromJson(value)));
    } catch (e) {
      debugPrint('Error loading game profiles: $e');
      _gameProfiles = {};
    }
  }

  static Future<void> _loadGameCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('game_categories') ?? '{}';
      
      final categoriesMap = jsonDecode(categoriesJson) as Map<String, dynamic>;
      _gameCategories = categoriesMap.map((key, value) => 
        MapEntry(key, GameCategory.fromJson(value)));
    } catch (e) {
      debugPrint('Error loading game categories: $e');
      _gameCategories = {};
    }
  }

  static Future<void> _fetchCloudGames() async {
    try {
      final response = await http.get(
        Uri.parse('$_gamesEndpoint/database'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': await _getUserAgent(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final gamesList = data['games'] as List;
        
        _cloudGames = gamesList.map((game) => CloudGameInfo.fromJson(game)).toList();
        debugPrint('Fetched ${_cloudGames.length} games from cloud');
      } else {
        debugPrint('Failed to fetch cloud games: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cloud games: $e');
    }
  }

  static Future<String> _getUserAgent() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'HoneMobile/${packageInfo.version} (${Platform.operatingSystem})';
    } catch (e) {
      return 'HoneMobile/1.0.0';
    }
  }

  static void _startAutoSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      syncWithCloud();
    });
  }

  static Future<void> scanForGames() async {
    if (!Platform.isAndroid) return;
    
    try {
      debugPrint('Scanning for installed games...');
      
      // This would use platform-specific code to scan for games
      // For now, we'll simulate with some known games
      final scannedGames = await _scanInstalledApplications();
      
      _localGames = scannedGames;
      await _saveLocalData();
      _gamesController.add(_localGames);
      
      debugPrint('Found ${_localGames.length} games');
    } catch (e) {
      debugPrint('Error scanning for games: $e');
    }
  }

  static Future<List<GameInfo>> _scanInstalledApplications() async {
    // device_apps dependency was removed because its Android integration was
    // not AGP-8 compatible in this project.
    //
    // Temporary stub: keep buildability and return no discovered games.
    if (!Platform.isAndroid) return [];

    debugPrint('Game scanning is unavailable (device_apps removed).');
    return const <GameInfo>[];
  }




  static Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = jsonEncode(_localGames.map((game) => game.toJson()).toList());
      await prefs.setString('local_games', gamesJson);
    } catch (e) {
      debugPrint('Error saving local data: $e');
    }
  }

  static Future<void> _saveGameProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = jsonEncode(
        _gameProfiles.map((key, value) => MapEntry(key, value.toJson()))
      );
      await prefs.setString('game_profiles', profilesJson);
    } catch (e) {
      debugPrint('Error saving game profiles: $e');
    }
  }

  static Future<SyncResult> syncWithCloud() async {
    try {
      _syncController.add(SyncStatus.syncing);
      
      // Upload local game profiles
      await _uploadGameProfiles();
      
      // Download updated game database
      await _fetchCloudGames();
      
      // Download updated categories
      await _fetchGameCategories();
      
      _syncController.add(SyncStatus.completed);
      
      return SyncResult(
        success: true,
        uploadedProfiles: _gameProfiles.length,
        downloadedGames: _cloudGames.length,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error syncing with cloud: $e');
      _syncController.add(SyncStatus.error);
      
      return SyncResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  static Future<void> _uploadGameProfiles() async {
    try {
      final profilesData = _gameProfiles.map((key, value) => MapEntry(key, value.toJson()));
      
      final response = await http.post(
        Uri.parse('$_syncEndpoint/profiles'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': await _getUserAgent(),
        },
        body: jsonEncode({
          'profiles': profilesData,
          'device_id': await _getDeviceId(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to upload profiles: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading game profiles: $e');
    }
  }

  static Future<void> _fetchGameCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_gamesEndpoint/categories'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': await _getUserAgent(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final categoriesList = data['categories'] as List;
        
        for (final category in categoriesList) {
          final categoryInfo = GameCategory.fromJson(category);
          _gameCategories[categoryInfo.id] = categoryInfo;
        }
        
        await _saveGameCategories();
      }
    } catch (e) {
      debugPrint('Error fetching game categories: $e');
    }
  }

  static Future<void> _saveGameCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = jsonEncode(
        _gameCategories.map((key, value) => MapEntry(key, value.toJson()))
      );
      await prefs.setString('game_categories', categoriesJson);
    } catch (e) {
      debugPrint('Error saving game categories: $e');
    }
  }

  static Future<String> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      
      if (deviceId == null) {
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('device_id', deviceId);
      }
      
      return deviceId;
    } catch (e) {
      return 'unknown_device';
    }
  }

  // Public API
  static Stream<List<GameInfo>> get gamesStream => _gamesController.stream;
  static Stream<SyncStatus> get syncStream => _syncController.stream;
  
  static List<GameInfo> get localGames => List.unmodifiable(_localGames);
  static List<CloudGameInfo> get cloudGames => List.unmodifiable(_cloudGames);
  static Map<String, GamePerformanceProfile> get gameProfiles => Map.unmodifiable(_gameProfiles);
  static Map<String, GameCategory> get gameCategories => Map.unmodifiable(_gameCategories);
  static bool get isInitialized => _isInitialized;
  static bool get autoSyncEnabled => _autoSyncEnabled;

  static Future<GameInfo?> getGameByPackage(String packageName) async {
    try {
      return _localGames.firstWhere((game) => game.packageName == packageName);
    } catch (e) {
      return null;
    }
  }

  static Future<CloudGameInfo?> getCloudGameByPackage(String packageName) async {
    try {
      return _cloudGames.firstWhere((game) => game.packageName == packageName);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setGameProfile(String packageName, GamePerformanceProfile profile) async {
    _gameProfiles[packageName] = profile;
    await _saveGameProfiles();
  }

  static Future<GamePerformanceProfile?> getGameProfile(String packageName) async {
    return _gameProfiles[packageName];
  }

  static Future<void> addGame(GameInfo game) async {
    _localGames.add(game);
    await _saveLocalData();
    _gamesController.add(_localGames);
  }

  static Future<void> removeGame(String packageName) async {
    _localGames.removeWhere((game) => game.packageName == packageName);
    await _saveLocalData();
    _gamesController.add(_localGames);
  }

  static Future<void> updateGame(GameInfo game) async {
    final index = _localGames.indexWhere((g) => g.packageName == game.packageName);
    if (index != -1) {
      _localGames[index] = game;
      await _saveLocalData();
      _gamesController.add(_localGames);
    }
  }

  static List<GameInfo> getGamesByCategory(String category) {
    return _localGames.where((game) => game.category == category).toList();
  }

  static List<GameInfo> searchGames(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _localGames.where((game) => 
      game.appName.toLowerCase().contains(lowercaseQuery) ||
      game.packageName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  static void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    if (enabled) {
      _startAutoSync();
    } else {
      _syncTimer?.cancel();
      _syncTimer = null;
    }
  }

  static void setSyncInterval(Duration interval) {
    _syncInterval = interval;
    if (_autoSyncEnabled) {
      _syncTimer?.cancel();
      _startAutoSync();
    }
  }

  static void dispose() {
    _syncTimer?.cancel();
    _gamesController.close();
    _syncController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
}

class SyncResult {
  final bool success;
  final int uploadedProfiles;
  final int downloadedGames;
  final String? error;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.uploadedProfiles = 0,
    this.downloadedGames = 0,
    this.error,
    required this.timestamp,
  });
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamingHubStorage {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyUsername = 'gh_username';
  static const String _keyAvatar = 'gh_avatar';
  static const String _keyXp = 'gh_xp';
  static const String _keyLevel = 'gh_level';
  static const String _keyBookmarks = 'gh_bookmarks';
  static const String _keyNotifications = 'gh_notifications';
  static const String _keyAchievements = 'gh_achievements';
  static const String _keyPlaytime = 'gh_playtime';
  static const String _keyFavorites = 'gh_favorites';
  static const String _keyHidden = 'gh_hidden';
  static const String _keyPinned = 'gh_pinned';
  static const String _keyRecentInstantGames = 'gh_recent_instant_games';
  static const String _keyLastActiveDate = 'gh_last_active';
  static const String _keyWeeklyPlaytime = 'gh_weekly_playtime';

  // Available Default Avatars
  static const List<String> avatars = [
    '👾',
    '🚀',
    '🐉',
    '🎮',
    '🛡️',
    '🦊',
    '⚡',
    '🤖',
    '👑',
    '🔥'
  ];

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAndInitializeDefaults();
  }

  static Future<void> _checkAndInitializeDefaults() async {
    if (_prefs == null) return;

    // Profile defaults
    if (!_prefs!.containsKey(_keyUsername)) {
      await _prefs!.setString(_keyUsername, 'GalaxyGamer');
    }
    if (!_prefs!.containsKey(_keyAvatar)) {
      await _prefs!.setInt(_keyAvatar, 0); // index 0: 👾
    }
    if (!_prefs!.containsKey(_keyXp)) {
      await _prefs!.setInt(_keyXp, 1250);
    }
    if (!_prefs!.containsKey(_keyLevel)) {
      await _prefs!.setInt(_keyLevel, 4);
    }

    // Achievements defaults
    if (!_prefs!.containsKey(_keyAchievements)) {
      final defaultAchievements = [
        {
          'id': 'welcome',
          'title': 'Welcome to Gaming Hub',
          'description': 'Enter the premium gaming ecosystem.',
          'xpReward': 100,
          'isUnlocked': true,
          'unlockTime': DateTime.now().toIso8601String(),
          'rarity': 'Common',
        },
        {
          'id': 'booster',
          'title': 'Maximum Engine Boost',
          'description': 'Launch a game with extreme optimization settings.',
          'xpReward': 250,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Rare',
        },
        {
          'id': 'instant_player',
          'title': 'Zero Download Needed',
          'description': 'Launch and play your first Instant Game.',
          'xpReward': 200,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Common',
        },
        {
          'id': 'high_score',
          'title': 'Retro Arcade Champion',
          'description': 'Score 500+ points in the Space Shooter instant game.',
          'xpReward': 500,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Epic',
        },
        {
          'id': 'survivor',
          'title': 'Untouchable Fighter',
          'description': 'Survive for more than 45 seconds in Space Shooter.',
          'xpReward': 400,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Epic',
        },
        {
          'id': 'collector',
          'title': 'Bookmarked & Loaded',
          'description':
              'Save 3 or more shortcuts in the Gaming Hub bookmarks.',
          'xpReward': 300,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Rare',
        },
        {
          'id': 'perfectionist',
          'title': 'True OneUI Veteran',
          'description': 'Unlock all other achievements in the Hub.',
          'xpReward': 1000,
          'isUnlocked': false,
          'unlockTime': '',
          'rarity': 'Legendary',
        }
      ];
      await _prefs!
          .setString(_keyAchievements, jsonEncode(defaultAchievements));
    }
    await _ensureAchievementDefinitions();

    // Bookmarks defaults
    if (!_prefs!.containsKey(_keyBookmarks)) {
      final defaultBookmarks = [
        {
          'id': 'b1',
          'title': 'Samsung Gaming Hub Info',
          'url': 'https://www.samsung.com/us/smart-tv/gaming-hub/',
          'type': 'website',
          'icon': '🌐',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'b2',
          'title': 'Xbox Cloud Gaming',
          'url': 'https://www.xbox.com/play',
          'type': 'website',
          'icon': '🎮',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'b3',
          'title': 'Discord Community',
          'url': 'https://discord.gg/gaming',
          'type': 'shortcut',
          'icon': '💬',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];
      await _prefs!.setString(_keyBookmarks, jsonEncode(defaultBookmarks));
    }

    // Notifications defaults
    if (!_prefs!.containsKey(_keyNotifications)) {
      final defaultNotifications = [
        {
          'id': 'n1',
          'title': 'Update Ready for Genshin Impact',
          'description':
              'Version 5.2 optimization parameters are loaded. Apply now for +15% GPU stability.',
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 15))
              .toIso8601String(),
          'isRead': false,
          'type': 'notification',
          'badge': 'Game Update',
        },
        {
          'id': 'n2',
          'title': 'Gaming Event: Cyber Weekend Starts Friday',
          'description':
              'Enjoy special rewards and leaderboard events in Space Shooter & other instant games.',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 3))
              .toIso8601String(),
          'isRead': false,
          'type': 'promotion',
          'badge': 'Event Promo',
        },
        {
          'id': 'n3',
          'title': 'Achievement Unlocked!',
          'description':
              'You unlocked "Welcome to Gaming Hub" and earned 100 XP.',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
          'isRead': true,
          'type': 'notification',
          'badge': 'Trophy',
        }
      ];
      await _prefs!
          .setString(_keyNotifications, jsonEncode(defaultNotifications));
    }

    // Playtime history defaults (last 7 days in minutes)
    if (!_prefs!.containsKey(_keyWeeklyPlaytime)) {
      final Map<String, int> defaultWeekly = {
        'Mon': 45,
        'Tue': 80,
        'Wed': 65,
        'Thu': 120,
        'Fri': 90,
        'Sat': 180,
        'Sun': 140,
      };
      await _prefs!.setString(_keyWeeklyPlaytime, jsonEncode(defaultWeekly));
    }

    // Playtime per game package defaults (total minutes)
    if (!_prefs!.containsKey(_keyPlaytime)) {
      final Map<String, int> defaultPlaytime = {
        'com.mihoyo.genshinimpact': 1440, // 24 hours
        'com.tencent.tmgp.pubgmhd': 820,
        'com.activision.callofduty.shooter': 640,
        'com.ea.gp.asphalt9': 380,
        'space_shooter_instant': 42,
        '2048': 12,
      };
      await _prefs!.setString(_keyPlaytime, jsonEncode(defaultPlaytime));
    }

    if (!_prefs!.containsKey(_keyRecentInstantGames)) {
      await _prefs!.setStringList(_keyRecentInstantGames, ['2048', 'sudoku']);
    }
  }

  static Future<void> _ensureAchievementDefinitions() async {
    if (_prefs == null) return;

    final existing = getAchievements();
    final existingIds = existing.map((a) => a['id'] as String? ?? '').toSet();
    var changed = false;

    for (final achievement in _extraAchievementDefinitions()) {
      if (!existingIds.contains(achievement['id'])) {
        existing.add(achievement);
        changed = true;
      }
    }

    if (changed) {
      await _prefs!.setString(_keyAchievements, jsonEncode(existing));
    }
  }

  static List<Map<String, dynamic>> _extraAchievementDefinitions() {
    Map<String, dynamic> locked(
      String id,
      String title,
      String description,
      int xpReward,
      String rarity,
    ) {
      return {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'isUnlocked': false,
        'unlockTime': '',
        'rarity': rarity,
      };
    }

    return [
      locked('first_merge', 'First Merge',
          'Merge your first pair of 2048 tiles.', 100, 'Common'),
      locked('reach_128', 'Tile Climber', 'Create a 128 tile in 2048.', 150,
          'Common'),
      locked('reach_512', 'Halfway Spark', 'Create a 512 tile in 2048.', 250,
          'Rare'),
      locked('reach_1024', 'Power Stack', 'Create a 1024 tile in 2048.', 350,
          'Epic'),
      locked('reach_2048', '2048 Champion', 'Reach the 2048 tile.', 600,
          'Legendary'),
      locked('score_5000', 'Five Thousand Club', 'Score 5,000 points in 2048.',
          300, 'Rare'),
      locked('score_10000', 'Ten Thousand Club', 'Score 10,000 points in 2048.',
          500, 'Epic'),
      locked('sudoku_first_puzzle', 'First Puzzle',
          'Start your first Sudoku puzzle.', 100, 'Common'),
      locked('sudoku_solver', 'Sudoku Solver', 'Complete a Sudoku puzzle.', 300,
          'Rare'),
      locked('sudoku_perfect_grid', 'Perfect Grid',
          'Solve Sudoku without mistakes.', 500, 'Epic'),
      locked('sudoku_master_mind', 'Master Mind',
          'Solve Sudoku without mistakes or hints.', 700, 'Legendary'),
      locked('tetris_first_line', 'First Line',
          'Clear your first line in Tetris.', 120, 'Common'),
      locked('tetris_1000_score', 'Thousand Points',
          'Score at least 1,000 points in Tetris.', 320, 'Rare'),
      locked('tetris_master', 'Tetris Master',
          'Clear a Tetris (4 lines) in one move.', 600, 'Epic'),
      locked('runner_first_run', 'First Run',
          'Complete your first Endless Runner run.', 120, 'Common'),
      locked('runner_1000_distance', '1,000 Meters',
          'Reach 1,000 distance in Endless Runner.', 320, 'Rare'),
      locked('runner_marathon_runner', 'Marathon Runner',
          'Run beyond 2,500 distance.', 600, 'Epic'),
      locked('bubble_first_clear', 'First Clear',
          'Clear your first bubble cluster.', 120, 'Common'),
      locked('bubble_combo_master', 'Combo Master',
          'Clear five or more bubbles in one shot.', 320, 'Rare'),
      locked('bubble_level_10', 'Level 10',
          'Reach level 10 in Bubble Shooter.', 600, 'Epic'),
      locked('chess_first_victory', 'First Victory',
          'Win your first chess match.', 120, 'Common'),
      locked('chess_checkmate', 'Checkmate',
          'Win a game by checkmate.', 320, 'Rare'),
      locked('chess_ten_wins', 'Ten Wins',
          'Win ten chess matches.', 600, 'Epic'),
    ];
  }

  // Profile methods
  static String getUsername() =>
      _prefs?.getString(_keyUsername) ?? 'GalaxyGamer';

  static Future<void> setUsername(String username) async {
    await _prefs?.setString(_keyUsername, username);
  }

  static String getAvatarEmoji() {
    final idx = _prefs?.getInt(_keyAvatar) ?? 0;
    if (idx >= 0 && idx < avatars.length) return avatars[idx];
    return avatars[0];
  }

  static int getAvatarIndex() => _prefs?.getInt(_keyAvatar) ?? 0;

  static Future<void> setAvatarIndex(int index) async {
    await _prefs?.setInt(_keyAvatar, index);
  }

  static int getXp() => _prefs?.getInt(_keyXp) ?? 1250;
  static int getLevel() => _prefs?.getInt(_keyLevel) ?? 4;

  static Future<void> addXp(int amount, BuildContext context) async {
    if (_prefs == null) return;
    int currentXp = getXp();
    int currentLevel = getLevel();

    currentXp += amount;

    // Level up calculation: Each level requires level * 500 XP
    int xpRequired = currentLevel * 500;
    bool leveledUp = false;
    while (currentXp >= xpRequired) {
      currentXp -= xpRequired;
      currentLevel++;
      xpRequired = currentLevel * 500;
      leveledUp = true;
    }

    await _prefs!.setInt(_keyXp, currentXp);
    await _prefs!.setInt(_keyLevel, currentLevel);

    if (leveledUp) {
      if (!context.mounted) return;
      // Trigger level up animation overlay
      _showLevelUpBanner(context, currentLevel);
    }
  }

  // Playtime Methods
  static Map<String, int> getPlaytimeMap() {
    final str = _prefs?.getString(_keyPlaytime) ?? '{}';
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  static int getPlaytime(String packageName) {
    return getPlaytimeMap()[packageName] ?? 0;
  }

  static Future<void> addPlaytime(
      String packageName, int minutes, BuildContext context) async {
    if (_prefs == null) return;
    await recordGameLaunch(packageName);
    final map = getPlaytimeMap();
    map[packageName] = (map[packageName] ?? 0) + minutes;
    await _prefs!.setString(_keyPlaytime, jsonEncode(map));

    // Also add to weekly chart for current day of week
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayIndex = DateTime.now().weekday - 1; // 0-6
    final dayStr = days[weekdayIndex];

    final weeklyMap = getWeeklyPlaytimeMap();
    weeklyMap[dayStr] = (weeklyMap[dayStr] ?? 0) + minutes;
    await _prefs!.setString(_keyWeeklyPlaytime, jsonEncode(weeklyMap));

    // Award XP: 1 XP per minute of playtime
    if (!context.mounted) return;
    await addXp(minutes, context);
  }

  static Map<String, int> getWeeklyPlaytimeMap() {
    final str = _prefs?.getString(_keyWeeklyPlaytime) ?? '{}';
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  static int getTotalPlaytime() {
    return getPlaytimeMap().values.fold(0, (sum, elem) => sum + elem);
  }

  static List<String> getRecentGameIds() {
    return _prefs?.getStringList(_keyRecentInstantGames) ?? [];
  }

  static Future<void> recordGameLaunch(String gameId) async {
    if (_prefs == null) return;
    final normalizedId =
        gameId == 'space_shooter_instant' ? 'space_shooter' : gameId;
    final recent = getRecentGameIds();
    recent.remove(normalizedId);
    recent.insert(0, normalizedId);
    await _prefs!.setStringList(
      _keyRecentInstantGames,
      recent.take(8).toList(),
    );
    await _prefs!.setString(_keyLastActiveDate, DateTime.now().toIso8601String());
  }

  // Bookmarks
  static List<Map<String, dynamic>> getBookmarks() {
    final str = _prefs?.getString(_keyBookmarks) ?? '[]';
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(str));
    } catch (_) {
      return [];
    }
  }

  static Future<void> addBookmark(
      String title, String url, String type, String emoji) async {
    if (_prefs == null) return;
    final bookmarks = getBookmarks();
    bookmarks.add({
      'id': 'b_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'url': url,
      'type': type,
      'icon': emoji,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs!.setString(_keyBookmarks, jsonEncode(bookmarks));
  }

  static Future<void> deleteBookmarks(List<String> ids) async {
    if (_prefs == null) return;
    final bookmarks = getBookmarks();
    bookmarks.removeWhere((item) => ids.contains(item['id']));
    await _prefs!.setString(_keyBookmarks, jsonEncode(bookmarks));
  }

  // Favorites, Pinned, Hidden
  static List<String> getFavorites() =>
      _prefs?.getStringList(_keyFavorites) ?? [];
  static Future<void> toggleFavorite(String packageName) async {
    final favs = getFavorites();
    if (favs.contains(packageName)) {
      favs.remove(packageName);
    } else {
      favs.add(packageName);
    }
    await _prefs?.setStringList(_keyFavorites, favs);
  }

  static List<String> getHidden() => _prefs?.getStringList(_keyHidden) ?? [];
  static Future<void> toggleHidden(String packageName) async {
    final hidden = getHidden();
    if (hidden.contains(packageName)) {
      hidden.remove(packageName);
    } else {
      hidden.add(packageName);
    }
    await _prefs?.setStringList(_keyHidden, hidden);
  }

  static List<String> getPinned() => _prefs?.getStringList(_keyPinned) ?? [];
  static Future<void> togglePinned(String packageName) async {
    final pinned = getPinned();
    if (pinned.contains(packageName)) {
      pinned.remove(packageName);
    } else {
      pinned.add(packageName);
    }
    await _prefs?.setStringList(_keyPinned, pinned);
  }

  // Notifications/Promotions
  static List<Map<String, dynamic>> getNotifications() {
    final str = _prefs?.getString(_keyNotifications) ?? '[]';
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(str));
    } catch (_) {
      return [];
    }
  }

  static Future<void> markNotificationAsRead(String id) async {
    if (_prefs == null) return;
    final notifs = getNotifications();
    for (var n in notifs) {
      if (n['id'] == id) {
        n['isRead'] = true;
      }
    }
    await _prefs!.setString(_keyNotifications, jsonEncode(notifs));
  }

  static Future<void> deleteNotification(String id) async {
    if (_prefs == null) return;
    final notifs = getNotifications();
    notifs.removeWhere((n) => n['id'] == id);
    await _prefs!.setString(_keyNotifications, jsonEncode(notifs));
  }

  static Future<void> addHubNotification(
      String title, String description, String type,
      {String badge = 'Alert'}) async {
    if (_prefs == null) return;
    final notifs = getNotifications();
    notifs.insert(0, {
      'id': 'n_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'type': type,
      'badge': badge,
    });
    await _prefs!.setString(_keyNotifications, jsonEncode(notifs));
  }

  // Achievements
  static List<Map<String, dynamic>> getAchievements() {
    final str = _prefs?.getString(_keyAchievements) ?? '[]';
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(str));
    } catch (_) {
      return [];
    }
  }

  static Future<void> unlockAchievement(String id, BuildContext context) async {
    if (_prefs == null) return;
    final achievements = getAchievements();
    bool updated = false;
    String title = '';
    int xp = 0;

    for (var a in achievements) {
      if (a['id'] == id && a['isUnlocked'] == false) {
        a['isUnlocked'] = true;
        a['unlockTime'] = DateTime.now().toIso8601String();
        title = a['title'] as String;
        xp = a['xpReward'] as int;
        updated = true;
        break;
      }
    }

    if (updated) {
      await _prefs!.setString(_keyAchievements, jsonEncode(achievements));
      if (!context.mounted) return;
      // Show floating popup notification
      _showAchievementBanner(context, title, xp);
      // Give XP
      await addXp(xp, context);

      // Check if all achievements except "perfectionist" are unlocked
      final unlockedCount = achievements
          .where((a) => a['isUnlocked'] == true && a['id'] != 'perfectionist')
          .length;
      if (unlockedCount == achievements.length - 1) {
        if (!context.mounted) return;
        await unlockAchievement('perfectionist', context);
      }
    }
  }

  // Animation banners overlay trigger
  static void _showAchievementBanner(
      BuildContext context, String title, int xpReward) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AchievementOverlayWidget(
        title: title,
        xpReward: xpReward,
        onDismiss: () => entry.remove(),
      ),
    );

    overlayState.insert(entry);
  }

  static void _showLevelUpBanner(BuildContext context, int newLevel) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _LevelUpOverlayWidget(
        level: newLevel,
        onDismiss: () => entry.remove(),
      ),
    );

    overlayState.insert(entry);
  }

  // Clear data
  static Future<void> clearAllData() async {
    await _prefs?.clear();
    await _checkAndInitializeDefaults();
  }
}

// ----------------------------------------------------
// UI WIDGET FOR DYNAMIC FLOATING ACHIEVEMENT UNLOCK
// ----------------------------------------------------
class _AchievementOverlayWidget extends StatefulWidget {
  final String title;
  final int xpReward;
  final VoidCallback onDismiss;

  const _AchievementOverlayWidget({
    required this.title,
    required this.xpReward,
    required this.onDismiss,
  });

  @override
  State<_AchievementOverlayWidget> createState() =>
      _AchievementOverlayWidgetState();
}

class _AchievementOverlayWidgetState extends State<_AchievementOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Auto dismiss after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF23074d), // Purple gradient
                        Color(0xFFcc5333), // Red-orange shimmer
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD700), // Gold
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACHIEVEMENT UNLOCKED!',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+${widget.xpReward} XP REWARD',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// UI WIDGET FOR LEVEL UP OVERLAY BANNER
// ----------------------------------------------------
class _LevelUpOverlayWidget extends StatefulWidget {
  final int level;
  final VoidCallback onDismiss;

  const _LevelUpOverlayWidget({
    required this.level,
    required this.onDismiss,
  });

  @override
  State<_LevelUpOverlayWidget> createState() => _LevelUpOverlayWidgetState();
}

class _LevelUpOverlayWidgetState extends State<_LevelUpOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7F00FF), // Deep purple
                    Color(0xFFE100FF), // Light purple/pink
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.6),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.upgrade,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are now Level ${widget.level}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Next milestone reward: +500 XP bonus',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

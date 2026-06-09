import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/models/discover_game.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/core/services/game_database_service.dart';
import 'package:hone_mobile/shared/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

// Import sub-pages
import 'package:hone_mobile/features/games/presentation/pages/gamer_profile_page.dart';
import 'package:hone_mobile/features/games/presentation/pages/gaming_notifications_page.dart';
import 'package:hone_mobile/features/games/presentation/pages/gaming_bookmarks_page.dart';
import 'package:hone_mobile/features/games/presentation/pages/gaming_settings_page.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/instant_game.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Home, 1: Library, 2: Instant, 3: Discover, 4: Social
  late String _username;
  late String _avatarEmoji;
  List<GameInfo> _games = [];
  bool _isLoading = true;

  // Search & Filter
  String _librarySearchQuery = '';
  String _selectedFilterCategory = 'All'; // All, FPS, RPG, MOBA, Racing
  String _selectedSortMode = 'Alphabetical'; // Alphabetical, Playtime, Category

  // Library Edit Mode
  bool _isLibraryEditMode = false;
  final List<String> _selectedLibraryPackages = [];

  // Bookmarks count (for badging)
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeHub();
  }

  Future<void> _initializeHub() async {
    setState(() => _isLoading = true);
    // Initialize Local Storage Layer
    await GamingHubStorage.initialize();

    // Check local database and pre-populate popular games if empty
    if (GameDatabaseService.localGames.isEmpty) {
      await _prepopulateDefaultGames();
    }

    _refreshHubState();
    setState(() => _isLoading = false);
  }

  void _refreshHubState() {
    setState(() {
      _username = GamingHubStorage.getUsername();
      _avatarEmoji = GamingHubStorage.getAvatarEmoji();
      _games = GameDatabaseService.localGames;
      _unreadNotificationsCount =
          GamingHubStorage.getNotifications().where((n) => !n['isRead']).length;
    });
  }

  List<InstantGame> _recentInstantGames() {
    final recentIds = GamingHubStorage.getRecentGameIds();
    return recentIds
        .map(InstantGame.byId)
        .whereType<InstantGame>()
        .toList(growable: false);
  }

  Future<void> _openInstantGame(InstantGame game) async {
    await GamingHubStorage.recordGameLaunch(game.id);
    if (!mounted) return;
    await context.push(game.route);
    _refreshHubState();
  }

  void _openInstantGameDetails(InstantGame game) {
    context
        .push('/games/details', extra: game.toGameInfo())
        .then((_) => _refreshHubState());
  }

  Future<void> _prepopulateDefaultGames() async {
    final defaultGames = [
      GameInfo(
        packageName: 'com.mihoyo.genshinimpact',
        appName: 'Genshin Impact',
        category: 'RPG',
        version: '5.2.0',
        versionCode: 520,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 30)),
        updateTime: DateTime.now().subtract(const Duration(days: 2)),
        size: 19537418240, // 18.2 GB
        performanceProfile: GamePerformanceProfile.performance(),
      ),
      GameInfo(
        packageName: 'com.tencent.tmgp.pubgmhd',
        appName: 'PUBG Mobile',
        category: 'FPS',
        version: '3.1.0',
        versionCode: 310,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 45)),
        updateTime: DateTime.now().subtract(const Duration(days: 4)),
        size: 3650720768, // 3.4 GB
        performanceProfile: GamePerformanceProfile.balanced(),
      ),
      GameInfo(
        packageName: 'com.activision.callofduty.shooter',
        appName: 'Call of Duty: Mobile',
        category: 'FPS',
        version: '1.0.43',
        versionCode: 1043,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 15)),
        updateTime: DateTime.now().subtract(const Duration(days: 1)),
        size: 3006477107, // 2.8 GB
        performanceProfile: GamePerformanceProfile.performance(),
      ),
      GameInfo(
        packageName: 'com.ea.gp.asphalt9',
        appName: 'Asphalt Legends',
        category: 'Racing',
        version: '4.5.1',
        versionCode: 451,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 60)),
        updateTime: DateTime.now().subtract(const Duration(days: 10)),
        size: 2362232012, // 2.2 GB
        performanceProfile: GamePerformanceProfile.balanced(),
      ),
      GameInfo(
        packageName: 'com.supercell.brawlstars',
        appName: 'Brawl Stars',
        category: 'MOBA',
        version: '54.243',
        versionCode: 54243,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 100)),
        updateTime: DateTime.now().subtract(const Duration(days: 5)),
        size: 471859200, // 450 MB
        performanceProfile: GamePerformanceProfile.balanced(),
      ),
      GameInfo(
        packageName: 'com.riotgames.league.wildrift',
        appName: 'LoL: Wild Rift',
        category: 'MOBA',
        version: '5.0.0',
        versionCode: 500,
        isSystemApp: false,
        isGame: true,
        installTime: DateTime.now().subtract(const Duration(days: 8)),
        updateTime: DateTime.now().subtract(const Duration(days: 8)),
        size: 3328599654, // 3.1 GB
        performanceProfile: GamePerformanceProfile.performance(),
      ),
    ];

    for (var game in defaultGames) {
      await GameDatabaseService.addGame(game);
    }
  }

  // Dialog to manually add a custom game shortcut
  void _showAddCustomGameDialog() {
    final nameController = TextEditingController();
    final pkgController = TextEditingController();
    String category = 'FPS';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Add Game Manually'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Game Title', hintText: 'e.g. Minecraft'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: pkgController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Package Name',
                    hintText: 'e.g. com.mojang.minecraftpe'),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Category:',
                      style: TextStyle(color: Colors.white70)),
                  DropdownButton<String>(
                    dropdownColor: AppTheme.cardDark,
                    value: category,
                    items: ['FPS', 'RPG', 'MOBA', 'Racing', 'Casual']
                        .map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          category = v;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final pkg = pkgController.text.trim().isNotEmpty
                    ? pkgController.text.trim()
                    : 'custom.game.${DateTime.now().millisecondsSinceEpoch}';

                final newGame = GameInfo(
                  packageName: pkg,
                  appName: nameController.text.trim(),
                  category: category,
                  version: '1.0.0',
                  versionCode: 1,
                  isSystemApp: false,
                  isGame: true,
                  installTime: DateTime.now(),
                  updateTime: DateTime.now(),
                  size: 512 * 1024 * 1024, // 512 MB
                  performanceProfile: GamePerformanceProfile.balanced(),
                );

                await GameDatabaseService.addGame(newGame);
                if (!context.mounted) return;
                Navigator.pop(context);
                _refreshHubState();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('"${newGame.appName}" added to library.')),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple),
              child: const Text('Add Shortcut'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppTheme.primaryDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonPurple),
        ),
      );
    }

    return Container(
      color: AppTheme.primaryDark,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF060913),
              AppTheme.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Unified AMOLED OneUI Header
              _buildHubHeader(),

              // Active Tab Content View
              Expanded(
                child: _buildActiveTabContent(),
              ),

              // Premium Gaming bottom navigation bar
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // UNIFIED HEADER BAR W/ METRICS
  // ----------------------------------------------------
  Widget _buildHubHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gaming Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'ONE UI INTEGRATED ENGINE',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              // Notification Bell with Badge
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GamingNotificationsPage()),
                      );
                      _refreshHubState();
                    },
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white70),
                  ),
                  if (_unreadNotificationsCount > 0)
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              // Bookmarks tag
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GamingBookmarksPage()),
                  );
                  _refreshHubState();
                },
                icon: const Icon(Icons.bookmark_outline, color: Colors.white70),
              ),

              // Settings cog
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GamingSettingsPage()),
                  );
                  _refreshHubState();
                },
                icon:
                    const Icon(Icons.settings_outlined, color: Colors.white70),
              ),

              SizedBox(width: 8.w),

              // Profile Avatar
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GamerProfilePage()),
                  );
                  _refreshHubState();
                },
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppTheme.neonPurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonPurple, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _avatarEmoji,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // ACTIVE TAB DISPATCHER
  // ----------------------------------------------------
  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildLibraryTab();
      case 2:
        return _buildInstantGamesTab();
      case 3:
        return _buildDiscoverTab();
      case 4:
        return _buildSocialTab();
      default:
        return _buildHomeTab();
    }
  }

  // ----------------------------------------------------
  // TAB 0: HOME DASHBOARD
  // ----------------------------------------------------
  Widget _buildHomeTab() {
    final favorites = GamingHubStorage.getFavorites();
    final hidden = GamingHubStorage.getHidden();

    // Filter out hidden games for dashboard
    final visibleGames =
        _games.where((g) => !hidden.contains(g.packageName)).toList();
    final favGames =
        visibleGames.where((g) => favorites.contains(g.packageName)).toList();

    // Recently played simulated: sort games by install date desc
    final recentlyPlayed = List<GameInfo>.from(visibleGames)
      ..sort((a, b) => b.installTime.compareTo(a.installTime));
    final recentInstantGames = _recentInstantGames();
    final continueInstantGame = recentInstantGames.isNotEmpty
        ? recentInstantGames.first
        : InstantGame.byId('2048');

    return RefreshIndicator(
      onRefresh: () async {
        _refreshHubState();
      },
      backgroundColor: AppTheme.cardDark,
      color: AppTheme.neonPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // Welcome Header
            Text(
              'Hello, $_username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Your Galaxy devices are fully boosted and synced.',
              style: TextStyle(color: Colors.white38, fontSize: 11.sp),
            ),

            SizedBox(height: 20.h),

            // Event Swiper Banner (Promotions Carousel)
            _buildEventBanner(),

            SizedBox(height: 24.h),

            // Continue Playing (Last launch simulation card)
            if (recentlyPlayed.isNotEmpty) ...[
              _buildContinuePlayingSection(recentlyPlayed.first),
              SizedBox(height: 24.h),
            ],

            if (continueInstantGame != null) ...[
              _buildInstantContinuePlayingSection(continueInstantGame),
              SizedBox(height: 24.h),
            ],

            if (recentInstantGames.isNotEmpty) ...[
              _buildRecentlyPlayedInstantGamesSection(recentInstantGames),
              SizedBox(height: 24.h),
            ],

            // Favorites Row
            if (favGames.isNotEmpty) ...[
              _buildFavoritesSection(favGames),
              SizedBox(height: 24.h),
            ],

            // My Games Library Grid Quick Peek
            _buildLibraryQuickSection(visibleGames),

            SizedBox(height: 24.h),

            // AI Recommendations Section
            _buildAIRecommendationsSection(),

            SizedBox(height: 24.h),

            // Instant Games teaser grid
            _buildInstantGamesSection(),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBanner() {
    return Container(
      height: 110.h,
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E0854), Color(0xFF6B1D9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Exclusive Galaxy Gear Pack',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Claim free weapon skins for COD Mobile in Gaming Hub.',
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Text('🎁', style: TextStyle(fontSize: 36.sp)),
        ],
      ),
    );
  }

  Widget _buildContinuePlayingSection(GameInfo game) {
    final playtime = GamingHubStorage.getPlaytime(game.packageName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTINUE PLAYING',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        GlassCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () => context.push('/games/details', extra: game),
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🎮', style: TextStyle(fontSize: 22.sp)),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.appName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Category: ${game.category} | Playtime: $playtime mins',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.neonPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: AppTheme.neonPurple),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(List<GameInfo> favorites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAVORITE GAMES',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final game = favorites[index];
              return InkWell(
                onTap: () => context.push('/games/details', extra: game),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 160.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppTheme.neonPurple.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              game.appName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              game.category,
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 9.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryQuickSection(List<GameInfo> visibleGames) {
    final pinned = GamingHubStorage.getPinned();
    // Sort pinned to top
    final sortedGames = List<GameInfo>.from(visibleGames)
      ..sort((a, b) {
        final aPinned = pinned.contains(a.packageName) ? 1 : 0;
        final bPinned = pinned.contains(b.packageName) ? 1 : 0;
        return bPinned.compareTo(aPinned);
      });

    final libraryWidth = MediaQuery.sizeOf(context).width;
    final libraryColumns = libraryWidth >= 900
        ? 4
        : libraryWidth >= 620
            ? 3
            : 2;
    final libraryAspect = libraryWidth >= 900 ? 1.05 : 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY GAMES LIBRARY',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            TextButton(
              onPressed: () => setState(() => _activeTab = 1),
              child: Text(
                'Show all (${_games.length})',
                style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        if (sortedGames.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                  'No games loaded. Tap Settings > Reset or add game manually.',
                  style: TextStyle(color: Colors.white24, fontSize: 12.sp)),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: libraryColumns,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: libraryAspect,
            ),
            itemCount: sortedGames.length > 6 ? 6 : sortedGames.length,
            itemBuilder: (context, index) {
              final game = sortedGames[index];
              final isPinned = pinned.contains(game.packageName);

              return InkWell(
                onTap: () => context.push('/games/details', extra: game),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isPinned
                          ? Colors.amber.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child:
                                Text('🎮', style: TextStyle(fontSize: 20.sp)),
                          ),
                          if (isPinned)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: Colors.amber, shape: BoxShape.circle),
                              child: const Icon(Icons.push_pin,
                                  size: 8, color: Colors.black),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        game.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        game.category,
                        style: TextStyle(color: Colors.white38, fontSize: 8.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAIRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI RECOMMENDATIONS',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F0B24), Color(0xFF1B112D)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border:
                Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Performance Optimiser',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    const Text(
                      'Heavy gaming pattern detected during late nights. Boost GPU throttle range for maximum cooling.',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () {
                        // Apply simulated boost action
                        GamingHubStorage.unlockAchievement('booster', context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Applied Extreme Booster parameters to GPU.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Optimize Engine',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              const Icon(Icons.rocket_launch,
                  color: AppTheme.neonPurple, size: 36),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstantGamesSection() {
    final featuredGames = InstantGame.all.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'POPULAR INSTANT GAMES',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            TextButton(
              onPressed: () => setState(() => _activeTab = 2),
              child: Text(
                'See all',
                style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 900
                ? 5
                : MediaQuery.sizeOf(context).width >= 720
                    ? 4
                    : 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: MediaQuery.sizeOf(context).width >= 720 ? 0.98 : 0.92,
          ),
          itemCount: featuredGames.length,
          itemBuilder: (context, index) {
            return _buildInstantGameTile(featuredGames[index], compact: true);
          },
        ),
      ],
    );
  }

  Widget _buildInstantContinuePlayingSection(InstantGame game) {
    final playtime = GamingHubStorage.getPlaytime(game.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTINUE INSTANT GAME',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        InkWell(
          onTap: () => _openInstantGame(game),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: AppTheme.neonPurple.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                _buildInstantIcon(game, size: 50.w),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${game.category} | Playtime: $playtime mins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow, color: AppTheme.neonPurple, size: 26.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayedInstantGamesSection(List<InstantGame> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENTLY PLAYED',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 104.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final game = games[index];
              return InkWell(
                onTap: () => _openInstantGame(game),
                onLongPress: () => _openInstantGameDetails(game),
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  width: 170.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(18.r),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      _buildInstantIcon(game, size: 44.w),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              game.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 9.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstantGameTile(InstantGame game, {bool compact = false}) {
    return InkWell(
      onTap: () => _openInstantGameDetails(game),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(compact ? 10.w : 14.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInstantIcon(game, size: compact ? 42.w : 52.w),
            SizedBox(height: 8.h),
            Text(
              game.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 11.sp : 13.sp,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              game.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white38, fontSize: compact ? 8.sp : 10.sp),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: compact ? 28.h : 32.h,
              child: ElevatedButton(
                onPressed: () => _openInstantGame(game),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Play',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 10.sp : 11.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstantIcon(InstantGame game, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.neonPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Icon(game.icon, color: AppTheme.neonPurple, size: size * 0.52),
    );
  }

  // ----------------------------------------------------
  // TAB 1: MY GAMES LIBRARY
  // ----------------------------------------------------
  Widget _buildLibraryTab() {
    final favorites = GamingHubStorage.getFavorites();
    final hidden = GamingHubStorage.getHidden();
    final pinned = GamingHubStorage.getPinned();

    // 1. Filter out hidden games unless we are in hidden filter?
    // Let's filter based on tabs
    List<GameInfo> filteredList = _games.where((g) {
      // Hidden condition
      if (_selectedFilterCategory == 'Hidden') {
        return hidden.contains(g.packageName);
      }
      if (hidden.contains(g.packageName)) return false;

      // Category filter
      if (_selectedFilterCategory == 'Favorites') {
        return favorites.contains(g.packageName);
      }
      if (_selectedFilterCategory != 'All') {
        return g.category == _selectedFilterCategory;
      }
      return true;
    }).toList();

    // 2. Search query filter
    if (_librarySearchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((g) => g.appName
              .toLowerCase()
              .contains(_librarySearchQuery.toLowerCase()))
          .toList();
    }

    // 3. Pinning sorting logic: Pins always float to the top
    filteredList.sort((a, b) {
      final aPinned = pinned.contains(a.packageName) ? 1 : 0;
      final bPinned = pinned.contains(b.packageName) ? 1 : 0;
      final pinCompare = bPinned.compareTo(aPinned);
      if (pinCompare != 0) return pinCompare;

      // Secondary sorting
      if (_selectedSortMode == 'Playtime') {
        final aTime = GamingHubStorage.getPlaytime(a.packageName);
        final bTime = GamingHubStorage.getPlaytime(b.packageName);
        return bTime.compareTo(aTime);
      } else if (_selectedSortMode == 'Category') {
        return a.category.compareTo(b.category);
      } else {
        return a.appName.compareTo(b.appName);
      }
    });

    return Column(
      children: [
        // Sub Header containing search bar & filter actions
        _buildLibrarySubHeader(),

        // Horizontal Category pills selector
        _buildLibraryCategoryPills(),

        // Grid View
        Expanded(
          child: filteredList.isEmpty
              ? _buildLibraryEmptyState()
              : GridView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final game = filteredList[index];
                    final pkg = game.packageName;
                    final isSelected = _selectedLibraryPackages.contains(pkg);
                    final isPinned = pinned.contains(pkg);
                    final isFav = favorites.contains(pkg);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _isLibraryEditMode = true;
                          if (!isSelected) _selectedLibraryPackages.add(pkg);
                        });
                      },
                      onTap: () {
                        if (_isLibraryEditMode) {
                          setState(() {
                            if (isSelected) {
                              _selectedLibraryPackages.remove(pkg);
                            } else {
                              _selectedLibraryPackages.add(pkg);
                            }
                          });
                        } else {
                          context.push('/games/details', extra: game);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.purple.withValues(alpha: 0.15)
                              : AppTheme.cardDark.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.neonPurple
                                : isPinned
                                    ? Colors.amber.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.04),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 46.w,
                                    height: 46.w,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('🎮',
                                        style: TextStyle(fontSize: 22.sp)),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    game.appName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    game.category,
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 8.sp),
                                  ),
                                ],
                              ),
                            ),

                            // Pin Indicator
                            if (isPinned)
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: const Icon(Icons.push_pin,
                                    color: Colors.amber, size: 10),
                              ),

                            // Favorite star indicator
                            if (isFav)
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: const Icon(Icons.star,
                                    color: Colors.amberAccent, size: 10),
                              ),

                            // Multi-Select Checkbox
                            if (_isLibraryEditMode)
                              Positioned(
                                top: 6.h,
                                right: 6.w,
                                child: Container(
                                  width: 18.w,
                                  height: 18.w,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.neonPurple
                                        : Colors.black26,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white24, width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? Icon(Icons.check,
                                          color: Colors.white, size: 10.w)
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Library action footer in edit mode
        if (_isLibraryEditMode) _buildLibraryEditFooter(),
      ],
    );
  }

  Widget _buildLibrarySubHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _librarySearchQuery = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search my games...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 12.sp),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white30, size: 18.w),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Sorting Toggle Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_outlined, color: Colors.white70),
            color: AppTheme.cardDark,
            onSelected: (mode) {
              setState(() {
                _selectedSortMode = mode;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'Alphabetical',
                  child: Text('Alphabetical',
                      style: TextStyle(
                          color: _selectedSortMode == 'Alphabetical'
                              ? AppTheme.neonPurple
                              : Colors.white70))),
              PopupMenuItem(
                  value: 'Playtime',
                  child: Text('Playtime Logs',
                      style: TextStyle(
                          color: _selectedSortMode == 'Playtime'
                              ? AppTheme.neonPurple
                              : Colors.white70))),
              PopupMenuItem(
                  value: 'Category',
                  child: Text('Genre Category',
                      style: TextStyle(
                          color: _selectedSortMode == 'Category'
                              ? AppTheme.neonPurple
                              : Colors.white70))),
            ],
          ),

          // Add manual shortcut shortcut
          IconButton(
            onPressed: _showAddCustomGameDialog,
            icon: const Icon(Icons.add_box_outlined, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCategoryPills() {
    final categories = [
      'All',
      'Favorites',
      'FPS',
      'RPG',
      'MOBA',
      'Racing',
      'Hidden'
    ];
    return Container(
      height: 38.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedFilterCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            selectedColor: Colors.purple.withValues(alpha: 0.2),
            backgroundColor: Colors.white.withValues(alpha: 0.02),
            side: BorderSide(
                color: isSelected
                    ? AppTheme.neonPurple
                    : Colors.white.withValues(alpha: 0.04)),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilterCategory = cat;
                });
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLibraryEditFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Exit Edit Mode
            TextButton(
              onPressed: () {
                setState(() {
                  _isLibraryEditMode = false;
                  _selectedLibraryPackages.clear();
                });
              },
              child:
                  const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),

            // Actions Row
            Row(
              children: [
                // Favorite Button
                IconButton(
                  onPressed: () async {
                    for (var pkg in _selectedLibraryPackages) {
                      await GamingHubStorage.toggleFavorite(pkg);
                    }
                    setState(() {
                      _isLibraryEditMode = false;
                      _selectedLibraryPackages.clear();
                    });
                    _refreshHubState();
                  },
                  icon: const Icon(Icons.star, color: Colors.amberAccent),
                ),

                // Pin Button
                IconButton(
                  onPressed: () async {
                    for (var pkg in _selectedLibraryPackages) {
                      await GamingHubStorage.togglePinned(pkg);
                    }
                    setState(() {
                      _isLibraryEditMode = false;
                      _selectedLibraryPackages.clear();
                    });
                    _refreshHubState();
                  },
                  icon: const Icon(Icons.push_pin, color: Colors.amber),
                ),

                // Hide Button
                IconButton(
                  onPressed: () async {
                    for (var pkg in _selectedLibraryPackages) {
                      await GamingHubStorage.toggleHidden(pkg);
                    }
                    setState(() {
                      _isLibraryEditMode = false;
                      _selectedLibraryPackages.clear();
                    });
                    _refreshHubState();
                  },
                  icon: const Icon(Icons.visibility_off, color: Colors.white70),
                ),

                // Delete Shortcut Button
                IconButton(
                  onPressed: () async {
                    for (var pkg in _selectedLibraryPackages) {
                      await GameDatabaseService.removeGame(pkg);
                    }
                    setState(() {
                      _isLibraryEditMode = false;
                      _selectedLibraryPackages.clear();
                    });
                    _refreshHubState();
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sports_esports_outlined,
            color: Colors.white10, size: 56),
        SizedBox(height: 12.h),
        Text('No Matching Games',
            style: TextStyle(color: Colors.white38, fontSize: 13.sp)),
      ],
    );
  }

  // ----------------------------------------------------
  // TAB 2: INSTANT GAMES ARCADE
  // ----------------------------------------------------
  Widget _buildInstantGamesTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1000
            ? 4
            : width >= 620
                ? 3
                : 2;

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            Text(
              'INSTANT PLAY ARCADE',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            SizedBox(height: 4.h),
            Text(
              'Zero installation games tuned for quick offline sessions.',
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
            ),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: width >= 620 ? 0.96 : 0.9,
              ),
              itemCount: InstantGame.all.length,
              itemBuilder: (context, index) {
                return _buildInstantGameTile(InstantGame.all[index]);
              },
            ),
            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 3: DISCOVER RECOMMENDATIONS (INFINITE SCROLL MOCK)
  // ----------------------------------------------------
  Widget _buildDiscoverTab() {
    final games = discoverGamesDatabase;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: games.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI DISCOVER ENGINE',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
              SizedBox(height: 4.h),
              Text(
                'Recommendations open the official Google Play listing.',
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              ),
              SizedBox(height: 16.h),
            ],
          );
        }

        final game = games[index - 1];
        final sizeLabel = game.size >= 1024
            ? '${(game.size / 1024).toStringAsFixed(1)} GB'
            : '${game.size.toStringAsFixed(0)} MB';

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: AppTheme.neonPurple.withValues(alpha: 0.16)),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.sports_esports,
                    color: AppTheme.neonPurple, size: 24.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.developer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.neonPurple,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      game.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${game.genre} | $sizeLabel | ${game.rating.toStringAsFixed(1)} rating',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: 'Open in Google Play',
                onPressed: () => _openPlayStore(game),
                icon: const Icon(Icons.open_in_new, color: AppTheme.neonPurple),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPlayStore(DiscoverGame game) async {
    final marketUrl = 'market://details?id=${game.id}';
    final webUrl = game.playStoreUrl;

    try {
      if (Platform.isAndroid) {
        await AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: marketUrl,
          package: 'com.android.vending',
        ).launch();
        return;
      }
    } catch (_) {
      // Fall through to browser URL below.
    }

    try {
      if (Platform.isAndroid) {
        await AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: webUrl,
        ).launch();
        return;
      }
    } catch (_) {
      // Surface a usable fallback below.
    }

    await Clipboard.setData(ClipboardData(text: webUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Play link copied to clipboard.')),
    );
  }

  // ----------------------------------------------------
  // TAB 4: SOCIAL FRIENDS & LEADERBOARDS
  // ----------------------------------------------------
  Widget _buildSocialTab() {
    final friends = [
      {
        'name': 'ChronoBooster',
        'status': 'Online',
        'game': 'Space Shooter',
        'active': true,
        'avatar': '🤖'
      },
      {
        'name': 'UltraFrameGamer',
        'status': 'Online',
        'game': 'PUBG Mobile',
        'active': true,
        'avatar': '⚡'
      },
      {
        'name': 'PixelPioneer',
        'status': 'Away',
        'game': 'Minecraft',
        'active': false,
        'avatar': '🦊'
      },
      {
        'name': 'OneUITrigger',
        'status': 'Offline',
        'game': 'Offline',
        'active': false,
        'avatar': '🛡️'
      },
    ];

    final leaderboard = [
      {'rank': '1', 'name': 'UltraFrameGamer', 'score': '1,420 pts'},
      {'rank': '2', 'name': 'ChronoBooster', 'score': '1,050 pts'},
      {'rank': '3', 'name': 'You (GalaxyGamer)', 'score': '950 pts'},
      {'rank': '4', 'name': 'PixelPioneer', 'score': '650 pts'},
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        SizedBox(height: 8.h),
        Text(
          'SOCIAL ACTIVITY FEED',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 16.h),

        // Leaderboards Card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.leaderboard, color: Colors.amber),
                  SizedBox(width: 8.w),
                  Text(
                    'Instant Game Leaderboard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final row = leaderboard[index];
                  final isMe = row['name']!.contains('You');
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        Text(
                          '#${row['rank']}',
                          style: TextStyle(
                            color: row['rank'] == '1'
                                ? Colors.amber
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            row['name']!,
                            style: TextStyle(
                              color:
                                  isMe ? AppTheme.neonPurple : Colors.white70,
                              fontWeight:
                                  isMe ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        Text(
                          row['score']!,
                          style:
                              TextStyle(color: Colors.white54, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Friends List Header
        Text(
          'FRIENDS ONLINE (${friends.where((f) => f['active'] as bool).length})',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),

        // Friends List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: friends.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final f = friends[index];
            final bool online = f['active'] as bool;

            return Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Row(
                children: [
                  // Friend Emoji Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        alignment: Alignment.center,
                        child: Text(f['avatar'] as String,
                            style: TextStyle(fontSize: 20.sp)),
                      ),
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['name'] as String,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          online ? 'Playing ${f['game']}' : 'Offline',
                          style: TextStyle(
                              color:
                                  online ? AppTheme.neonPurple : Colors.white38,
                              fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  if (online)
                    ElevatedButton(
                      onPressed: () {
                        // Invite friend action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Multiplayer Invite sent to ${f['name']}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Invite',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ----------------------------------------------------
  // NATIVE BOTTOM NAVIGATION SYSTEM
  // ----------------------------------------------------
  Widget _buildBottomNavigationBar() {
    final List<Map<String, dynamic>> barItems = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.library_books_rounded, 'label': 'Library'},
      {'icon': Icons.bolt, 'label': 'Instant'},
      {'icon': Icons.explore_outlined, 'label': 'Discover'},
      {'icon': Icons.group_outlined, 'label': 'Social'},
    ];

    return Container(
      padding: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)
        ],
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(barItems.length, (index) {
            final item = barItems[index];
            final isSelected = _activeTab == index;
            final Color color =
                isSelected ? AppTheme.neonPurple : Colors.white38;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = index;
                    _isLibraryEditMode = false;
                    _selectedLibraryPackages.clear();
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: color,
                      size: 20.w,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 9.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

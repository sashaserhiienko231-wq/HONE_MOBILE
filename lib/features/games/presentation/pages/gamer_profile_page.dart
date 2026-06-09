import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GamerProfilePage extends StatefulWidget {
  const GamerProfilePage({super.key});

  @override
  State<GamerProfilePage> createState() => _GamerProfilePageState();
}

class _GamerProfilePageState extends State<GamerProfilePage> {
  late String _username;
  late int _avatarIdx;
  late int _level;
  late int _xp;
  bool _isEditingName = false;
  late TextEditingController _nameController;

  // Stats loaded from storage
  int _totalPlaytime = 0;
  int _playedGamesCount = 0;
  Map<String, int> _weeklyPlaytime = {};
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      _username = GamingHubStorage.getUsername();
      _avatarIdx = GamingHubStorage.getAvatarIndex();
      _level = GamingHubStorage.getLevel();
      _xp = GamingHubStorage.getXp();
      _nameController = TextEditingController(text: _username);
      _totalPlaytime = GamingHubStorage.getTotalPlaytime();
      _playedGamesCount = GamingHubStorage.getPlaytimeMap().keys.length;
      _weeklyPlaytime = GamingHubStorage.getWeeklyPlaytimeMap();
      _achievements = GamingHubStorage.getAchievements();
    });
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isNotEmpty) {
      await GamingHubStorage.setUsername(_nameController.text.trim());
      setState(() {
        _username = _nameController.text.trim();
        _isEditingName = false;
      });
      // Try to unlock achievement or give haptic feedback
      GamingHubStorage.addHubNotification(
        'Profile Updated',
        'Gamer username changed to $_username.',
        'notification',
        badge: 'Gamer Profile',
      );
    }
  }

  void _changeAvatar(int index) async {
    await GamingHubStorage.setAvatarIndex(index);
    setState(() {
      _avatarIdx = index;
    });
    if (!mounted) return;
    Navigator.pop(context);
    
    // Notify
    GamingHubStorage.addHubNotification(
      'Profile Icon Updated',
      'Changed avatar to ${GamingHubStorage.avatars[index]}.',
      'notification',
      badge: 'Gamer Profile',
    );
  }

  void _showAvatarSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Gamer Avatar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: GamingHubStorage.avatars.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _avatarIdx;
                  return InkWell(
                    onTap: () => _changeAvatar(index),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple.withValues(alpha: 0.3) : Colors.black26,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected ? AppTheme.neonPurple : Colors.white10,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        GamingHubStorage.avatars[index],
                        style: TextStyle(fontSize: 26.sp),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int xpNeeded = _level * 500;
    double xpProgress = (_xp / xpNeeded).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F051D),
              AppTheme.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),
              
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      
                      // Gamer Identity Card (AMOLED floating card)
                      _buildGamerIdentityCard(xpNeeded, xpProgress),
                      
                      SizedBox(height: 24.h),
                      
                      // Quick Stats Overview Row
                      _buildQuickStats(),
                      
                      SizedBox(height: 24.h),

                      // Weekly Playtime Chart (Custom painter based OneUI widget)
                      _buildWeeklyPlaytimeChart(),
                      
                      SizedBox(height: 24.h),

                      // Favorite Genres Panel
                      _buildFavoriteGenres(),

                      SizedBox(height: 24.h),

                      // Achievements Showcase
                      _buildAchievementsShowcase(),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          Text(
            'GAMER PROFILE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          IconButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Stats?'),
                  content: const Text('This will reset your playtime statistics, level, and accomplishments. This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await GamingHubStorage.clearAllData();
                        if (!mounted) return;
                        _loadProfileData();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Stats reset successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.restart_alt, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildGamerIdentityCard(int xpNeeded, double xpProgress) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _showAvatarSelector,
                child: Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    GamingHubStorage.avatars[_avatarIdx],
                    style: TextStyle(fontSize: 48.sp),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showAvatarSelector,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 14.w),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Username Input / Label
          _isEditingName
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 180.w,
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        autofocus: true,
                        maxLength: 16,
                        decoration: const InputDecoration(
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonPurple)),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saveName,
                      icon: const Icon(Icons.check, color: AppTheme.neonGreen),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => setState(() => _isEditingName = true),
                      child: Icon(Icons.edit, color: Colors.white38, size: 16.w),
                    ),
                  ],
                ),
                
          SizedBox(height: 4.h),
          Text(
            'Samsung Account Sync Active',
            style: TextStyle(color: Colors.white38, fontSize: 10.sp),
          ),
          
          SizedBox(height: 20.h),
          
          // XP Bar & Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL $_level',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$_xp / $xpNeeded XP',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              height: 10.h,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.06),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: xpProgress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFFCC00FF)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '${(_totalPlaytime / 60).toStringAsFixed(1)}h',
            'TOTAL PLAYTIME',
            Icons.timer_outlined,
            Colors.cyanAccent,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatItem(
            '$_playedGamesCount',
            'GAMES PLAYED',
            Icons.sports_esports_outlined,
            Colors.amberAccent,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatItem(
            '${_achievements.where((a) => a['isUnlocked'] == true).length}',
            'TROPHIES',
            Icons.emoji_events_outlined,
            AppTheme.neonPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            val,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlaytimeChart() {
    // Generate data heights
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    int maxVal = 1;
    for (var day in days) {
      maxVal = max(maxVal, _weeklyPlaytime[day] ?? 0);
    }
    // Prevent zero division
    maxVal = maxVal == 0 ? 60 : maxVal;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY PLAYTIME',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Weekly Log',
                style: TextStyle(color: Colors.white38, fontSize: 10.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Chart Columns
          SizedBox(
            height: 130.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final playMin = _weeklyPlaytime[day] ?? 0;
                final double percent = playMin / maxVal;
                final colHeight = (percent * 100.h).clamp(4.0, 100.h);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${playMin}m',
                      style: TextStyle(
                        color: playMin > 0 ? Colors.purpleAccent : Colors.white24,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 14.w,
                      height: colHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: playMin > 0 
                              ? [const Color(0xFF9d50bb), const Color(0xFF6e48aa)]
                              : [Colors.white10, Colors.white10],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: playMin > 0
                            ? [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, -2),
                                )
                              ]
                            : null,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      day,
                      style: TextStyle(
                        color: playMin > 0 ? Colors.white70 : Colors.white38,
                        fontSize: 10.sp,
                        fontWeight: playMin > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteGenres() {
    // Genres based on fake data
    final genres = [
      {'name': 'FPS (Shooter)', 'percentage': 0.45, 'color': AppTheme.neonOrange},
      {'name': 'Role-Playing (RPG)', 'percentage': 0.30, 'color': AppTheme.neonBlue},
      {'name': 'Multiplayer Arena (MOBA)', 'percentage': 0.18, 'color': AppTheme.neonGreen},
      {'name': 'Casual & Racing', 'percentage': 0.07, 'color': AppTheme.neonPurple},
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENRE BREAKDOWN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genres.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final g = genres[index];
              final double ratio = g['percentage'] as double;
              final Color color = g['color'] as Color;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        g['name'] as String,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Container(
                      height: 6.h,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsShowcase() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACHIEVEMENTS SHOWCASE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${_achievements.where((a) => a['isUnlocked'] == true).length} / ${_achievements.length}',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _achievements.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.04), height: 24.h),
            itemBuilder: (context, index) {
              final a = _achievements[index];
              final isUnlocked = a['isUnlocked'] as bool;
              final String rarity = a['rarity'] as String;
              final Color rarityColor = _getRarityColor(rarity);

              return Row(
                children: [
                  // Medal Icon
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: isUnlocked ? rarityColor.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked ? rarityColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: isUnlocked ? rarityColor : Colors.white24,
                      size: 22.w,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Title / Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              a['title'] as String,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white30,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: isUnlocked ? rarityColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                rarity.toUpperCase(),
                                style: TextStyle(
                                  color: isUnlocked ? rarityColor : Colors.white24,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          a['description'] as String,
                          style: TextStyle(
                            color: isUnlocked ? Colors.white54 : Colors.white24,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // XP Value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${a['xpReward']} XP',
                        style: TextStyle(
                          color: isUnlocked ? AppTheme.neonPurple : Colors.white24,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (isUnlocked && a['unlockTime'] != null && a['unlockTime'] != '')
                        Text(
                          _formatDate(a['unlockTime'] as String),
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8.sp,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common': return Colors.grey[400]!;
      case 'Rare': return Colors.blueAccent;
      case 'Epic': return Colors.purpleAccent;
      case 'Legendary': return const Color(0xFFFFD700); // Gold
      default: return Colors.white;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }
}

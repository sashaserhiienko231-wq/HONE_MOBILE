import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/glass_card.dart';
import 'package:hone_mobile/shared/widgets/performance_graph.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/instant_game.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GameDetailsPage extends StatefulWidget {
  final GameInfo game;

  const GameDetailsPage({super.key, required this.game});

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  bool _optimizeRAM = true;
  bool _optimizeCPU = true;
  bool _optimizeGPU = true;
  bool _enableDND = true;
  double _targetFPS = 60;

  // Game Playtime State
  int _playtimeMinutes = 0;
  InstantGame? _instantGame;

  // Mock Screenshot carousel data
  final List<String> _screenshotCaptions = [
    'Ultra Graphic Mode Active',
    'Low Latency Network Layer',
    'Real-time Raytracing Shader',
    'Dynamic Performance Profile'
  ];

  @override
  void initState() {
    super.initState();
    _instantGame = InstantGame.fromGameInfo(widget.game);
    _loadPlaytime();
  }

  void _loadPlaytime() {
    setState(() {
      _playtimeMinutes = GamingHubStorage.getPlaytime(_storageId);
    });
  }

  String get _storageId => _instantGame?.id ?? widget.game.packageName;

  // Trigger full screen custom booster overlay launch
  void _launchOptimizedGame() {
    final instantGame = _instantGame;
    if (instantGame != null) {
      GamingHubStorage.recordGameLaunch(instantGame.id);
      context.push(instantGame.route).then((_) => _loadPlaytime());
      return;
    }

    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _GamingOptimizationOverlay(
        appName: widget.game.appName,
        ramEnabled: _optimizeRAM,
        cpuEnabled: _optimizeCPU,
        gpuEnabled: _optimizeGPU,
        targetFps: _targetFPS,
        onComplete: () async {
          entry.remove();

          // Award XP/Playtime: Simulate playing for 30 minutes
          await GamingHubStorage.addPlaytime(
              widget.game.packageName, 30, context);
          if (!context.mounted) return;

          // Unlock booster achievement
          await GamingHubStorage.unlockAchievement('booster', context);
          if (!context.mounted) return;

          // Re-load playtime state
          _loadPlaytime();

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _getCategoryColor(widget.game.category),
              content: Text(
                'Launched ${widget.game.appName}! Playtime logged, +30 XP awarded.',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );

    overlayState.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.game.category);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              categoryColor.withValues(alpha: 0.12),
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGameInfo(categoryColor),
                      SizedBox(height: 24.h),

                      // Screenshot Carousel
                      _buildScreenshotCarousel(categoryColor),
                      SizedBox(height: 24.h),

                      // Tuning Target FPS Slider
                      _buildTargetFPSTuning(categoryColor),
                      SizedBox(height: 24.h),

                      _buildPerformanceAnalytics(categoryColor),
                      SizedBox(height: 24.h),

                      _buildOptimizationPanel(categoryColor),
                      SizedBox(height: 24.h),

                      // Trophies / Friends Showcase
                      _buildCommunitySection(categoryColor),
                      SizedBox(height: 32.h),

                      _buildLaunchButton(categoryColor),
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

  Widget _buildHeader() {
    return CustomAppBar(
      title: widget.game.appName.toUpperCase(),
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: () {
            // Toggle favorite in detail page
            GamingHubStorage.toggleFavorite(widget.game.packageName);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Updated favorites status'),
                  duration: Duration(milliseconds: 1000)),
            );
          },
          icon: Icon(
            GamingHubStorage.getFavorites().contains(widget.game.packageName)
                ? Icons.star
                : Icons.star_border,
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildGameInfo(Color categoryColor) {
    return Row(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
                color: categoryColor.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text('🎮', style: TextStyle(fontSize: 40.sp)),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.game.appName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(
                'Playtime: $_playtimeMinutes mins',
                style: TextStyle(
                    color: categoryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: categoryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.game.category.toUpperCase(),
                      style: TextStyle(
                          color: categoryColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${(widget.game.size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB',
                    style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotCarousel(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOCK SCREENSHOTS',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _screenshotCaptions.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return Container(
                width: 170.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      categoryColor.withValues(alpha: 0.15)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.photo_library_outlined,
                        color: Colors.white38, size: 20),
                    const Spacer(),
                    Text(
                      _screenshotCaptions[index],
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Render Buffer #${index + 1}',
                      style: TextStyle(color: Colors.white38, fontSize: 8.sp),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTargetFPSTuning(Color categoryColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.3),
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
                'TARGET FRAME RATE',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
              Text(
                '${_targetFPS.toInt()} FPS',
                style: TextStyle(
                    color: categoryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Slider(
            value: _targetFPS,
            min: 30,
            max: 144,
            divisions: 6,
            activeColor: categoryColor,
            inactiveColor: Colors.white10,
            onChanged: (v) {
              setState(() {
                _targetFPS = v;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30 FPS (Battery Saver)',
                  style: TextStyle(color: Colors.white24, fontSize: 8.sp)),
              Text('60 FPS (Balanced)',
                  style: TextStyle(color: Colors.white24, fontSize: 8.sp)),
              Text('144 FPS (Ultra Fluid)',
                  style: TextStyle(color: Colors.white24, fontSize: 8.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalytics(Color categoryColor) {
    return StreamBuilder<PerformanceStats>(
      stream: PerformanceMonitorService.performanceStats,
      builder: (context, snapshot) {
        final history = PerformanceMonitorService.historicalStats;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENGINE FREQUENCY LOGS',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            SizedBox(height: 10.h),
            GlassCard(
              height: 150.h,
              child: PerformanceGraph(
                data: history.map((e) => e.fps).toList(),
                color: categoryColor,
                label: 'Realtime Frame Pacing',
                max: 144,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptimizationPanel(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GAMING ENGINE BOOST PARAMETERS',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        SizedBox(height: 10.h),
        GlassCard(
          padding: EdgeInsets.all(8.w),
          child: Column(
            children: [
              _buildOptToggle(
                  'RAM Purge Hook',
                  'Free system memory prior to thread allocation.',
                  _optimizeRAM,
                  (v) => setState(() => _optimizeRAM = v),
                  Icons.memory,
                  categoryColor),
              const Divider(color: Colors.white10),
              _buildOptToggle(
                  'CPU Affinity Bind',
                  'Force priority allocation to high-performance cores.',
                  _optimizeCPU,
                  (v) => setState(() => _optimizeCPU = v),
                  Icons.speed,
                  categoryColor),
              const Divider(color: Colors.white10),
              _buildOptToggle(
                  'GPU Range Tuning',
                  'Boost clock frequency thresholds by +15%.',
                  _optimizeGPU,
                  (v) => setState(() => _optimizeGPU = v),
                  Icons.shutter_speed,
                  categoryColor),
              const Divider(color: Colors.white10),
              _buildOptToggle(
                  'DND Silent Mode',
                  'Block floating alerts and ambient banner interruptions.',
                  _enableDND,
                  (v) => setState(() => _enableDND = v),
                  Icons.notifications_off,
                  categoryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptToggle(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, IconData icon, Color activeColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: activeColor, size: 20.w),
      ),
      title: Text(title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.white38, fontSize: 10.sp)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
      ),
    );
  }

  Widget _buildCommunitySection(Color categoryColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FRIENDS ACTIVITY',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              Text('2 friends active',
                  style: TextStyle(
                      color: categoryColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white10),
          Row(
            children: [
              _buildMiniFriendAvatar('⚡'),
              SizedBox(width: 8.w),
              _buildMiniFriendAvatar('🤖'),
              SizedBox(width: 12.w),
              Text(
                'UltraFrameGamer and ChronoBooster are playing',
                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFriendAvatar(String emoji) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: 14.sp)),
    );
  }

  Widget _buildLaunchButton(Color categoryColor) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _launchOptimizedGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _instantGame == null ? Icons.rocket_launch : Icons.play_arrow,
              color: Colors.black,
              size: 22.w,
            ),
            SizedBox(width: 12.w),
            Text(
              _instantGame == null ? 'OPTIMIZE & LAUNCH' : 'PLAY INSTANTLY',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FPS':
        return AppTheme.neonOrange;
      case 'MOBA':
        return AppTheme.neonGreen;
      case 'RPG':
        return AppTheme.neonBlue;
      case 'Racing':
        return AppTheme.neonPurple;
      case 'Puzzle':
        return AppTheme.neonPurple;
      case 'Strategy':
        return AppTheme.neonBlue;
      case 'Arcade':
        return AppTheme.neonGreen;
      case 'Action':
        return AppTheme.neonOrange;
      case 'Board':
        return AppTheme.neonBlue;
      default:
        return AppTheme.neonGreen;
    }
  }
}

// ----------------------------------------------------
// FULL SCREEN OPTIMIZATION BOOSTER SIMULATOR
// ----------------------------------------------------
class _GamingOptimizationOverlay extends StatefulWidget {
  final String appName;
  final bool ramEnabled;
  final bool cpuEnabled;
  final bool gpuEnabled;
  final double targetFps;
  final VoidCallback onComplete;

  const _GamingOptimizationOverlay({
    required this.appName,
    required this.ramEnabled,
    required this.cpuEnabled,
    required this.gpuEnabled,
    required this.targetFps,
    required this.onComplete,
  });

  @override
  State<_GamingOptimizationOverlay> createState() =>
      _GamingOptimizationOverlayState();
}

class _GamingOptimizationOverlayState
    extends State<_GamingOptimizationOverlay> {
  final List<String> _logs = [];
  int _logIndex = 0;
  Timer? _logTimer;
  double _progress = 0.0;

  final List<String> _predefinedLogs = [
    'CONNECTING TO HONE TUNING KERNEL...',
    'ISOLATING GAME ENGINE PROCESS THREADS...',
  ];

  @override
  void initState() {
    super.initState();
    _buildCustomLogs();
    _startLogSimulation();
  }

  void _buildCustomLogs() {
    if (widget.ramEnabled) {
      _predefinedLogs.addAll([
        'RAM HYPER-PURGE INITIALIZED...',
        'FREEING SYS MEMORY PAGES: +1.42 GB RECOVERED.',
      ]);
    }
    if (widget.cpuEnabled) {
      _predefinedLogs.addAll([
        'PINNING CPU CORES 4-7 TO EXCLUSIVE PRIORITY MODE...',
        'THREAD ALLOCATION ENVELOPE CALIBRATED.',
      ]);
    }
    if (widget.gpuEnabled) {
      _predefinedLogs.addAll([
        'GPU CLOCK TUNER ACTIVE: CLOCK RATIO MULTIPLIER 1.15x...',
        'TARGET FRAME RATE RATIO LOCK: ${widget.targetFps.toInt()} FPS.',
      ]);
    }
    _predefinedLogs.addAll([
      'THERMAL ENGINE BOUNDARY OFFSET ADJUSTED (+5.0°C)...',
      'BATTERY DISCHARGE PACING REGULATOR CONFIGURED.',
      'SYS KERNEL BOOST COMPLETE. FORWARDING RUNTIME TO ENGINE...',
      'LAUNCHING GAME ENGINES...'
    ]);
  }

  void _startLogSimulation() {
    const logInterval = Duration(milliseconds: 320);
    _logTimer = Timer.periodic(logInterval, (timer) {
      if (_logIndex < _predefinedLogs.length) {
        setState(() {
          _logs.add(_predefinedLogs[_logIndex]);
          _logIndex++;
          _progress = _logIndex / _predefinedLogs.length;
        });
        HapticFeedback.lightImpact();
      } else {
        _logTimer?.cancel();
        // Wait a small moment then trigger completion callback
        Future.delayed(const Duration(milliseconds: 500), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer Header
              Row(
                children: [
                  const Icon(Icons.rocket_launch,
                      color: AppTheme.neonPurple, size: 28),
                  SizedBox(width: 12.w),
                  Text(
                    'HONE ENGINE BOOST ACTIVATED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Tuning parameters for ${widget.appName.toUpperCase()}',
                style: const TextStyle(color: Colors.white30, fontSize: 12),
              ),
              SizedBox(height: 24.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  height: 6.h,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.06),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: _progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Console logs output
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView.separated(
                    itemCount: _logs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final isLast = index == _logs.length - 1;
                      return Text(
                        _logs[index],
                        style: TextStyle(
                          color: isLast ? AppTheme.neonPurple : Colors.white60,
                          fontFamily: 'monospace',
                          fontSize: 10.sp,
                          fontWeight:
                              isLast ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              const Center(
                child: Text(
                  'DO NOT CLOSE OR SWITCH APPLICATIONS',
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../engines/2048_engine.dart';
import '../../services/gaming_hub_storage.dart';
import 'package:hone_mobile/features/overlay/presentation/widgets/gaming_overlay.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';

/// 2048 Game Screen adhering to Gaming Hub premium UI.
class Game2048Screen extends ConsumerStatefulWidget {
  const Game2048Screen({super.key});

  @override
  ConsumerState<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends ConsumerState<Game2048Screen>
    with TickerProviderStateMixin {
  late Game2048Engine _engine;
  SharedPreferences? _prefs;
  late StreamSubscription<String> _achievementSub;
  bool _victoryDialogShown = false;
  bool _gameOverDialogShown = false;
  DateTime _sessionStartedAt = DateTime.now();

  // Animation controllers
  late AnimationController _spawnController;
  late AnimationController _mergeController;
  late AnimationController _victoryController;
  late AnimationController _gameOverController;
  late AnimationController _achievementController;

  // Animations
  late Animation<double> _spawnAnimation;
  late Animation<double> _mergeAnimation;
  late Animation<double> _victoryAnimation;
  late Animation<double> _gameOverAnimation;
  late Animation<double> _achievementAnimation;

  int _previousScore = 0;
  String? _achievementToShow;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _engine = Game2048Engine();
    _loadState();

    // Initialize animation controllers
    _spawnController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 200) : Duration.zero,
    );
    _mergeController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 300) : Duration.zero,
    );
    _victoryController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );
    _gameOverController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.normal : Duration.zero,
    );
    _achievementController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.normal : Duration.zero,
    );

    // Initialize animations
    _spawnAnimation = CurvedAnimation(
      parent: _spawnController,
      curve: AnimationPresets.easeOutCubic,
    );
    _mergeAnimation = CurvedAnimation(
      parent: _mergeController,
      curve: AnimationPresets.easeOutCubic,
    );
    _victoryAnimation = CurvedAnimation(
      parent: _victoryController,
      curve: AnimationPresets.easeOutCubic,
    );
    _gameOverAnimation = CurvedAnimation(
      parent: _gameOverController,
      curve: AnimationPresets.easeOutCubic,
    );
    _achievementAnimation = CurvedAnimation(
      parent: _achievementController,
      curve: AnimationPresets.easeOutCubic,
    );

    // Listen for engine changes to persist state and rebuild UI.
    _engine.addListener(_onEngineChanged);
    // Listen for achievements.
    _achievementSub = _engine.onAchievementUnlocked.listen(_onAchievement);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GamingHubStorage.recordGameLaunch('2048');
      GamingHubStorage.unlockAchievement('instant_player', context);
      // Auto-show overlay if configured
      try {
        final overlayNotifier = ref.read(overlaySettingsProvider.notifier);
        final overlayState = ref.read(overlaySettingsProvider);
        if (overlayState.autoShowDuringGames) overlayNotifier.setEnabled(true);
      } catch (_) {}
    });
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getString('2048_state');
    if (saved != null) {
      try {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        _engine.fromJson(map);
      } catch (_) {}
    }
  }

  void _onEngineChanged() {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Trigger spawn animation for new tiles
    if (animEnabled) {
      _spawnController.forward(from: 0);
    }

    // Trigger merge animation if score increased
    if (_engine.score > _previousScore) {
      if (animEnabled) {
        _mergeController.forward(from: 0);
      }
      _previousScore = _engine.score;
    }

    // Persist engine state.
    final json = jsonEncode(_engine.toJson());
    _prefs?.setString('2048_state', json);
    // Trigger UI rebuild.
    setState(() {});
    // Victory or game‑over dialogs.
    if (_engine.hasWon && !_victoryDialogShown) {
      _victoryDialogShown = true;
      _logSessionPlaytime();
      if (animEnabled) {
        _victoryController.forward();
      }
      _showVictoryDialog();
    }
    if (_engine.isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      _logSessionPlaytime();
      if (animEnabled) {
        _gameOverController.forward();
      }
      _showGameOverDialog();
    }
  }

  void _onAchievement(String id) {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Trigger achievement popup animation
    if (animEnabled) {
      setState(() {
        _achievementToShow = id;
      });
      _achievementController.forward(from: 0);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _achievementToShow = null;
          });
        }
      });
    }

    // Forward to GamingHubStorage – IDs match engine emission.
    GamingHubStorage.unlockAchievement(id, context);
  }

  void _logSessionPlaytime() {
    final elapsed = DateTime.now().difference(_sessionStartedAt);
    final minutes = max(1, elapsed.inMinutes);
    GamingHubStorage.addPlaytime('2048', minutes, context);
    _sessionStartedAt = DateTime.now();
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    _achievementSub.cancel();
    _spawnController.dispose();
    _mergeController.dispose();
    _victoryController.dispose();
    _gameOverController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // UI builders
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Apply screen util for responsive sizing.
    ScreenUtil.init(context,
        designSize: const Size(1080, 2400), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxSide =
                    (constraints.maxWidth - 48.w).clamp(240.w, double.infinity);
                final reservedHeight = 210.h;
                final boardSide = min(
                  maxSide,
                  (constraints.maxHeight - reservedHeight)
                      .clamp(240.w, double.infinity),
                );

                return Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 8),
                    Expanded(child: _buildBoard(boardSide)),
                    const SizedBox(height: 8),
                    _buildControlRow(constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
          const GamingOverlay(),
          if (_achievementToShow != null) _buildAchievementPopup(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Title
          Text(
            '2048',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              shadows: const [Shadow(color: Colors.purple, blurRadius: 8)],
            ),
          ),
          // Pause / Resume toggle
          IconButton(
            icon: Icon(
              _engine.isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white70,
            ),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(double boardSide) {
    final tileSize = (boardSide - 24.w) / Game2048Engine.boardSize;
    return Center(
      child: GestureDetector(
        onPanEnd: _handleSwipe,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: boardSide,
              height: boardSide,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(12.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Game2048Engine.boardSize,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: Game2048Engine.boardSize * Game2048Engine.boardSize,
                itemBuilder: (context, index) {
                  final y = index ~/ Game2048Engine.boardSize;
                  final x = index % Game2048Engine.boardSize;
                  final value = _engine.board[y][x];
                  return _buildTile(value, tileSize);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int value, double size) {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Color mapping – higher values get brighter neon.
    final bool empty = value == 0;
    final Color bg = empty
        ? Colors.transparent
        : Color.lerp(
                Colors.purpleAccent, Colors.cyanAccent, log(value) / log(2048))!
            .withValues(alpha: 0.9);
    final textStyle = TextStyle(
      color: empty ? Colors.transparent : Colors.white,
      fontSize: size * 0.4,
      fontWeight: FontWeight.bold,
      shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
    );

    Widget tile = AnimatedContainer(
      duration: animEnabled ? const Duration(milliseconds: 150) : Duration.zero,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: empty
            ? []
            : [
                BoxShadow(
                  color: bg.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
      ),
      alignment: Alignment.center,
      child: Text(
        empty ? '' : value.toString(),
        style: textStyle,
      ),
    );

    // Apply spawn and merge animations
    if (!empty && animEnabled) {
      tile = AnimatedBuilder(
        animation: Listenable.merge([_spawnAnimation, _mergeAnimation]),
        builder: (context, child) {
          final pulse = sin(_mergeAnimation.value * pi) * 0.1;
          return Transform.scale(
            scale: 0.5 + (_spawnAnimation.value * 0.5) + pulse,
            child: Opacity(
              opacity: _spawnAnimation.value,
              child: child,
            ),
          );
        },
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildControlRow(double width) {
    final isWide = width > 420.w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        children: [
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _statItem('Score', _engine.score.toString(), Colors.amberAccent),
              _statItem('Best', _engine.bestScore.toString(),
                  Colors.deepPurpleAccent),
              _statItem(
                  'Tile', _engine.highestTile.toString(), Colors.cyanAccent),
              _statItem(
                  'Merges', _engine.totalMerges.toString(), Colors.pinkAccent),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: isWide ? 170.w : double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                  onPressed: _restartGame,
                ),
              ),
              SizedBox(
                width: isWide ? 170.w : double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: Icon(_engine.isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(_engine.isPaused ? 'Resume' : 'Pause'),
                  onPressed: _togglePause,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
        const SizedBox(height: 4),
        if (label == 'Score' && animEnabled)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: _previousScore.toDouble(), end: double.parse(value)),
            duration: const Duration(milliseconds: 300),
            curve: AnimationPresets.easeOutCubic,
            builder: (_, v, __) => Text(
              v.toInt().toString(),
              style: TextStyle(
                  color: color, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAchievementPopup() {
    return Positioned(
      top: 80.h,
      left: 16.w,
      right: 16.w,
      child: AnimatedBuilder(
        animation: _achievementAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50 * (1 - _achievementAnimation.value)),
            child: Opacity(
              opacity: _achievementAnimation.value,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.8),
                      Colors.cyanAccent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amberAccent, size: 24),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement Unlocked!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _achievementToShow ?? '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Interaction helpers
  // ---------------------------------------------------------------------
  void _restartGame() {
    _engine.removeListener(_onEngineChanged);
    _achievementSub.cancel();
    _engine.dispose();
    setState(() {
      _engine = Game2048Engine();
      _engine.addListener(_onEngineChanged);
      _achievementSub = _engine.onAchievementUnlocked.listen(_onAchievement);
      _victoryDialogShown = false;
      _gameOverDialogShown = false;
      _sessionStartedAt = DateTime.now();
    });
  }

  void _togglePause() {
    if (_engine.isPaused) {
      _engine.resume();
    } else {
      _engine.pause();
    }
    setState(() {});
  }

  void _handleSwipe(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;
    const threshold = 200; // px/s
    SwipeDirection? dir;
    if (vx.abs() > vy.abs()) {
      if (vx > threshold) dir = SwipeDirection.right;
      if (vx < -threshold) dir = SwipeDirection.left;
    } else {
      if (vy > threshold) dir = SwipeDirection.down;
      if (vy < -threshold) dir = SwipeDirection.up;
    }
    if (dir != null) _engine.slide(dir);
  }

  // ---------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------
  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedBuilder(
        animation: _victoryAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_victoryAnimation.value * 0.2),
            child: Opacity(
              opacity: _victoryAnimation.value,
              child: child,
            ),
          );
        },
        child: AlertDialog(
          backgroundColor: const Color(0xFF0D0A1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title:
              const Text('VICTORY', style: TextStyle(color: Colors.cyanAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Final Score: ${_engine.score}',
                  style: const TextStyle(color: Colors.white70)),
              Text('Highest Tile: ${_engine.highestTile}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('Restart',
                  style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedBuilder(
        animation: _gameOverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_gameOverAnimation.value * 0.2),
            child: Opacity(
              opacity: _gameOverAnimation.value,
              child: child,
            ),
          );
        },
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A0A0A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: const Text('GAME OVER',
              style: TextStyle(color: Colors.redAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: ${_engine.score}',
                  style: const TextStyle(color: Colors.white70)),
              Text('Best: ${_engine.bestScore}',
                  style: const TextStyle(color: Colors.white70)),
              Text('Highest Tile: ${_engine.highestTile}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}

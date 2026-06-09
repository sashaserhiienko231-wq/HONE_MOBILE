import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';
import 'package:hone_mobile/features/overlay/presentation/widgets/gaming_overlay.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';

class EndlessRunnerGameScreen extends ConsumerStatefulWidget {
  const EndlessRunnerGameScreen({super.key});

  @override
  ConsumerState<EndlessRunnerGameScreen> createState() =>
      _EndlessRunnerGameScreenState();
}

class _EndlessRunnerGameScreenState
    extends ConsumerState<EndlessRunnerGameScreen>
    with TickerProviderStateMixin {
  late Timer _gameTimer;
  final Random _random = Random();
  double _playerY = 0.0;
  double _playerVelocity = 0.0;
  bool _isJumping = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _score = 0;
  int _coins = 0;
  int _distance = 0;
  int _highScore = 0;
  int _bestDistance = 0;
  double _scrollSpeed = 2.6;
  final List<Obstacle> _obstacles = [];
  final List<Coin> _coinsOnTrack = [];
  double _spawnCooldown = 0.0;
  late SharedPreferences _prefs;
  bool _firstRunAchievement = false;

  // Animation controllers
  late AnimationController _jumpController;
  late AnimationController _spawnController;
  late AnimationController _scoreController;
  late AnimationController _distanceController;
  late AnimationController _gameOverController;

  // Animations
  late Animation<double> _jumpAnimation;
  late Animation<double> _spawnAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _distanceAnimation;
  late Animation<double> _gameOverAnimation;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Initialize animation controllers
    _jumpController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 400) : Duration.zero,
    );
    _spawnController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 200) : Duration.zero,
    );
    _scoreController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 300) : Duration.zero,
    );
    _distanceController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 500) : Duration.zero,
    );
    _gameOverController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.normal : Duration.zero,
    );

    // Initialize animations
    _jumpAnimation = CurvedAnimation(
      parent: _jumpController,
      curve: AnimationPresets.easeOutCubic,
    );
    _spawnAnimation = CurvedAnimation(
      parent: _spawnController,
      curve: AnimationPresets.easeOutCubic,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: AnimationPresets.easeOutCubic,
    );
    _distanceAnimation = CurvedAnimation(
      parent: _distanceController,
      curve: AnimationPresets.easeOutCubic,
    );
    _gameOverAnimation = CurvedAnimation(
      parent: _gameOverController,
      curve: AnimationPresets.easeOutCubic,
    );

    _loadState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GamingHubStorage.recordGameLaunch('endless-runner');
      GamingHubStorage.unlockAchievement('instant_player', context);
      _applyOverlay();
    });
  }

  void _applyOverlay() {
    try {
      final overlayNotifier = ref.read(overlaySettingsProvider.notifier);
      final overlayState = ref.read(overlaySettingsProvider);
      if (overlayState.autoShowDuringGames) {
        overlayNotifier.setEnabled(true);
      }
    } catch (_) {}
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs.getInt('endless_runner_high_score') ?? 0;
    _bestDistance = _prefs.getInt('endless_runner_best_distance') ?? 0;
    final saved = _prefs.getString('endless_runner_state');
    if (saved != null) {
      try {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        _score = map['score'] as int? ?? 0;
        _coins = map['coins'] as int? ?? 0;
        _distance = map['distance'] as int? ?? 0;
        _playerY = map['playerY'] as double? ?? 0.0;
        _playerVelocity = map['playerVelocity'] as double? ?? 0.0;
        _isGameOver = map['isGameOver'] as bool? ?? false;
        _isJumping = map['isJumping'] as bool? ?? false;
        _obstacles.clear();
        final obstacles = (map['obstacles'] as List<dynamic>?) ?? [];
        for (final item in obstacles) {
          final o = item as Map<String, dynamic>;
          _obstacles.add(
              Obstacle(x: o['x'] as double, height: o['height'] as double));
        }
        _coinsOnTrack.clear();
        final coins = (map['coinsOnTrack'] as List<dynamic>?) ?? [];
        for (final item in coins) {
          final c = item as Map<String, dynamic>;
          _coinsOnTrack.add(Coin(x: c['x'] as double, y: c['y'] as double));
        }
      } catch (_) {}
    }
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_isPaused || _isGameOver) return;
      _updatePhysics();
    });
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _updatePhysics() {
    setState(() {
      _distance += 1;
      _scrollSpeed = 2.6 + min(4.5, _distance / 300.0);
      _playerVelocity += 0.35;
      _playerY += _playerVelocity * 0.02;
      if (_playerY >= 0) {
        _playerY = 0;
        _playerVelocity = 0;
        _isJumping = false;
      }
      _spawnCooldown -= 0.05;
      if (_spawnCooldown <= 0) {
        _spawnObstacle();
        if (_random.nextBool()) {
          _spawnCoin();
        }
        _spawnCooldown = max(1.0, 2.3 - _distance / 800.0);
      }
      for (var obstacle in _obstacles) {
        obstacle.x -= _scrollSpeed * 0.011;
      }
      for (var coin in _coinsOnTrack) {
        coin.x -= _scrollSpeed * 0.011;
      }
      _obstacles.removeWhere((o) => o.x < -0.15);
      _coinsOnTrack.removeWhere((c) => c.x < -0.15);
      _checkCollisions();
      _score = _distance + _coins * 15;
      if (_distance % 100 == 0 && _distance > 0) {
        final settings = ref.read(animationSettingsProvider);
        if (settings.enabled && !settings.reduceMotion) {
          _distanceController.forward(from: 0);
        }
      }
      if (_distance >= 1000 && !_firstRunAchievement) {
        _firstRunAchievement = true;
        GamingHubStorage.unlockAchievement('runner_1000_distance', context);
      }
      if (_distance >= 2500) {
        GamingHubStorage.unlockAchievement('runner_marathon_runner', context);
      }
    });
    _saveState();
  }

  void _spawnObstacle() {
    final height = 0.15 + _random.nextDouble() * 0.18;
    _obstacles.add(Obstacle(x: 1.12, height: height));
    final settings = ref.read(animationSettingsProvider);
    if (settings.enabled && !settings.reduceMotion) {
      _spawnController.forward(from: 0);
    }
  }

  void _spawnCoin() {
    _coinsOnTrack.add(Coin(x: 1.08, y: -0.15 - _random.nextDouble() * 0.18));
  }

  void _checkCollisions() {
    for (final obstacle in _obstacles) {
      if ((obstacle.x - 0.12).abs() < 0.12 && _playerY >= -0.18) {
        _triggerGameOver();
        return;
      }
    }
    for (var i = _coinsOnTrack.length - 1; i >= 0; i--) {
      final coin = _coinsOnTrack[i];
      if ((coin.x - 0.12).abs() < 0.12 && (_playerY - coin.y).abs() < 0.18) {
        _coins += 1;
        _coinsOnTrack.removeAt(i);
        GamingHubStorage.addPlaytime('endless-runner', 0, context);
        final settings = ref.read(animationSettingsProvider);
        if (settings.enabled && !settings.reduceMotion) {
          _scoreController.forward(from: 0);
        }
      }
    }
  }

  void _triggerGameOver() {
    setState(() {
      _isGameOver = true;
      _isPaused = false;
      _highScore = max(_highScore, _score);
      _bestDistance = max(_bestDistance, _distance);
    });
    final settings = ref.read(animationSettingsProvider);
    if (settings.enabled && !settings.reduceMotion) {
      _gameOverController.forward(from: 0);
    }
    _prefs.setInt('endless_runner_high_score', _highScore);
    _prefs.setInt('endless_runner_best_distance', _bestDistance);
    GamingHubStorage.addPlaytime(
        'endless-runner', max(1, _distance ~/ 120), context);
    if (_distance > 0) {
      GamingHubStorage.unlockAchievement('runner_first_run', context);
    }
  }

  void _saveState() {
    _prefs.setInt('endless_runner_high_score', _highScore);
    _prefs.setInt('endless_runner_best_distance', _bestDistance);
    _prefs.setString(
        'endless_runner_state',
        jsonEncode({
          'score': _score,
          'coins': _coins,
          'distance': _distance,
          'playerY': _playerY,
          'playerVelocity': _playerVelocity,
          'isGameOver': _isGameOver,
          'isJumping': _isJumping,
          'obstacles':
              _obstacles.map((o) => {'x': o.x, 'height': o.height}).toList(),
          'coinsOnTrack':
              _coinsOnTrack.map((c) => {'x': c.x, 'y': c.y}).toList(),
        }));
  }

  void _jump() {
    if (_isGameOver || _isPaused) return;
    if (!_isJumping) {
      final settings = ref.read(animationSettingsProvider);
      if (settings.enabled && !settings.reduceMotion) {
        _jumpController.forward(from: 0);
      }
      setState(() {
        _playerVelocity = -0.95;
        _isJumping = true;
      });
    }
  }

  void _togglePause() {
    if (_isGameOver) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _restart() {
    setState(() {
      _isGameOver = false;
      _isPaused = false;
      _playerY = 0.0;
      _playerVelocity = 0.0;
      _isJumping = false;
      _score = 0;
      _coins = 0;
      _distance = 0;
      _scrollSpeed = 2.6;
      _obstacles.clear();
      _coinsOnTrack.clear();
      _firstRunAchievement = false;
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(1080, 2400), minTextAdapt: true);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF060815), Color(0xFF0B0C27)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'ENDLESS RUNNER',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white70),
                          onPressed: _togglePause,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Expanded(child: _buildGameArea()),
                    SizedBox(height: 12.h),
                    _buildStatusRow(),
                    SizedBox(height: 12.h),
                    _buildControlPanel(),
                  ],
                ),
              ),
            ),
          ),
          if (_isPaused) _buildOverlay('PAUSED', 'Tap resume to keep running.'),
          if (_isGameOver)
            _buildOverlay('GAME OVER', 'Tap restart to run again.'),
          const GamingOverlay(),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: (0.04 * 255).round().toDouble()),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: Colors.purple
                        .withValues(alpha: (0.2 * 255).round().toDouble()),
                    width: 1.4),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: height * 0.14,
              height: height * 0.06,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple
                      .withValues(alpha: (0.18 * 255).round().toDouble()),
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            Positioned(
              left: width * 0.1,
              bottom: height * 0.14 + (_playerY * height * 0.3),
              width: width * 0.12,
              height: height * 0.16,
              child: AnimatedBuilder(
                animation: _jumpAnimation,
                builder: (context, child) => Transform.rotate(
                  angle: _jumpAnimation.value * pi * 2,
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.purple.withValues(
                              alpha: (0.5 * 255).round().toDouble()),
                          blurRadius: 20,
                          spreadRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
            for (final obstacle in _obstacles)
              Positioned(
                left: obstacle.x * width,
                bottom: height * 0.14,
                width: width * 0.12,
                height: obstacle.height * height,
                child: AnimatedBuilder(
                  animation: _spawnAnimation,
                  builder: (context, child) {
                    if (obstacle.x > 1.0) {
                      return Transform.scale(
                        scale: _spawnAnimation.value,
                        child: child,
                      );
                    }
                    return child!;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            for (final coin in _coinsOnTrack)
              Positioned(
                left: coin.x * width,
                bottom: height * 0.14 + height * 0.22 + coin.y * height,
                width: 26.w,
                height: 26.w,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                        colors: [Color(0xFFFFE91E), Color(0xFFB08900)]),
                  ),
                ),
              ),
            Positioned(
              left: width * 0.5 - 44.w,
              bottom: 16.h,
              child: TextButton(
                onPressed: _jump,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple
                      .withValues(alpha: (0.9 * 255).round().toDouble()),
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r)),
                ),
                child: Text('JUMP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedBuilder(
          animation: _distanceAnimation,
          builder: (context, child) => Transform.scale(
            scale: 1.0 + _distanceAnimation.value * 0.3,
            child: _statCard('DISTANCE', '$_distance'),
          ),
        ),
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) => Transform.scale(
            scale: 1.0 + _scoreAnimation.value * 0.3,
            child: _statCard('COINS', '$_coins'),
          ),
        ),
        _statCard('HIGH', '$_highScore'),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
              color: Colors.purple
                  .withValues(alpha: (0.2 * 255).round().toDouble())),
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
            SizedBox(height: 8.h),
            Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white),
            label: Text(_isPaused ? 'RESUME' : 'PAUSE',
                style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 16.h)),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            label: const Text('RESTART', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple
                    .withValues(alpha: (0.85 * 255).round().toDouble()),
                padding: EdgeInsets.symmetric(vertical: 16.h)),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay(String headline, String description) {
    Widget overlay = Container(
      color: Colors.black.withValues(alpha: (0.78 * 255).round().toDouble()),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: (0.08 * 255).round().toDouble()),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
                color: Colors.purple
                    .withValues(alpha: (0.2 * 255).round().toDouble()),
                width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(headline,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900)),
              SizedBox(height: 12.h),
              Text(description,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  textAlign: TextAlign.center),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _isGameOver ? _restart : _togglePause,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text(_isGameOver ? 'RESTART' : 'RESUME'),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isGameOver) {
      return AnimatedBuilder(
        animation: _gameOverAnimation,
        builder: (context, child) {
          return Opacity(
            opacity:
                _gameOverAnimation.value == 0 ? 1.0 : _gameOverAnimation.value,
            child: Transform.scale(
              scale: _gameOverAnimation.value == 0
                  ? 1.0
                  : 0.8 + (_gameOverAnimation.value * 0.2),
              child: child,
            ),
          );
        },
        child: overlay,
      );
    }

    return overlay;
  }
}

class Obstacle {
  double x;
  final double height;
  Obstacle({required this.x, required this.height});
}

class Coin {
  double x;
  final double y;
  Coin({required this.x, required this.y});
}

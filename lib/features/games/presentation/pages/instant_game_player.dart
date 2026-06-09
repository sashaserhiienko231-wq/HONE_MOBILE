import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';
import 'package:hone_mobile/core/services/game_profile_service.dart';

import 'package:hone_mobile/features/overlay/presentation/widgets/gaming_overlay.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';

class InstantGamePlayer extends ConsumerStatefulWidget {
  final String gameId;
  final String gameName;

  const InstantGamePlayer({
    super.key,
    required this.gameId,
    required this.gameName,
  });

  @override
  ConsumerState<InstantGamePlayer> createState() => _InstantGamePlayerState();
}

class _InstantGamePlayerState extends ConsumerState<InstantGamePlayer> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Game Loop
  late AnimationController _loopController;
  bool _isPlaying = false;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _pausedByLifecycle = false;
  int _score = 0;
  int _lives = 3;
  double _survivalTime = 0.0;

  // Space Shooter entities
  double _shipX = 0.5; // normalized 0.0 to 1.0
  final List<Offset> _lasers = []; // normalized coordinate points (x, y)
  final List<Asteroid> _asteroids = [];
  final List<Explosion> _explosions = [];
  final Random _random = Random();
  
  // Game limits & ticks
  double _asteroidSpawnTimer = 0.0;
  double _laserCooldown = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameTick);
    
    // Unlock instant_player achievement immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      GamingHubStorage.unlockAchievement('instant_player', context);
      _startGame();
      // Auto-enable overlay for instant games if configured
      try {
        final overlayNotifier = ref.read(overlaySettingsProvider.notifier);
        final overlayState = ref.read(overlaySettingsProvider);
        if (overlayState.autoShowDuringGames) overlayNotifier.setEnabled(true);
      } catch (_) {}
      // Apply game profile overlay settings if available
      try {
        final profiles = ref.read(gameProfilesProvider);
        final matches = profiles.where((e) => e.id == widget.gameId);
        if (matches.isNotEmpty) {
          final p = matches.first;
          await applyProfileOverlay(ref, p);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loopController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _survivalTime = 0.0;
      _shipX = 0.5;
      _lasers.clear();
      _asteroids.clear();
      _explosions.clear();
      _isGameOver = false;
      _isPaused = false;
      _isPlaying = true;
    });
    _loopController.repeat();
  }

  void _gameTick() {
    if (!_isPlaying || _isGameOver || _isPaused) return;

    setState(() {
      // Calculate survival time
      _survivalTime += 0.016; // Approx 60 FPS tick
      if (_survivalTime >= 45.0) {
        GamingHubStorage.unlockAchievement('survivor', context);
      }

      // 1. Spawning Asteroids
      _asteroidSpawnTimer -= 0.016;
      if (_asteroidSpawnTimer <= 0) {
        _asteroids.add(Asteroid(
          x: _random.nextDouble(),
          y: -0.1,
          speed: 0.005 + _random.nextDouble() * 0.005 + (_survivalTime * 0.0001),
          size: 15.0 + _random.nextDouble() * 25.0,
          rotation: _random.nextDouble() * 2.0 * pi,
          rotSpeed: 0.01 + _random.nextDouble() * 0.05,
        ));
        // Spawn faster as time goes on
        _asteroidSpawnTimer = max(0.3, 1.2 - (_survivalTime * 0.01));
      }

      // 2. Cooldown laser
      if (_laserCooldown > 0) {
        _laserCooldown -= 0.016;
      }

      // Auto fire laser
      if (_laserCooldown <= 0) {
        _lasers.add(Offset(_shipX, 0.8));
        _laserCooldown = 0.25; // 4 shots per second
        HapticFeedback.lightImpact();
      }

      // 3. Move Lasers
      for (int i = _lasers.length - 1; i >= 0; i--) {
        double newY = _lasers[i].dy - 0.02;
        if (newY < 0) {
          _lasers.removeAt(i);
        } else {
          _lasers[i] = Offset(_lasers[i].dx, newY);
        }
      }

      // 4. Move Asteroids
      for (int i = _asteroids.length - 1; i >= 0; i--) {
        _asteroids[i].y += _asteroids[i].speed;
        _asteroids[i].rotation += _asteroids[i].rotSpeed;
        if (_asteroids[i].y > 1.1) {
          _asteroids.removeAt(i);
        }
      }

      // 5. Update Explosions
      for (int i = _explosions.length - 1; i >= 0; i--) {
        _explosions[i].progress += 0.05;
        if (_explosions[i].progress >= 1.0) {
          _explosions.removeAt(i);
        }
      }

      // 6. Collision Detection (Laser vs Asteroids)
      for (int i = _lasers.length - 1; i >= 0; i--) {
        final laser = _lasers[i];
        for (int j = _asteroids.length - 1; j >= 0; j--) {
          final ast = _asteroids[j];
          
          // Compute screen distances approximately using normalized coordinates
          // Width of game area is roughly 350. Height roughly 500.
          double dx = (laser.dx - ast.x) * 350.0;
          double dy = (laser.dy - ast.y) * 500.0;
          double distance = sqrt(dx * dx + dy * dy);

          if (distance < ast.size) {
            // Hit!
            _explosions.add(Explosion(x: ast.x, y: ast.y, maxRadius: ast.size * 1.5));
            _asteroids.removeAt(j);
            _lasers.removeAt(i);
            _score += 25;
            HapticFeedback.mediumImpact();
            
            if (_score >= 500) {
              GamingHubStorage.unlockAchievement('high_score', context);
            }
            break; // laser is gone
          }
        }
      }

      // 7. Collision Detection (Asteroids vs Spaceship)
      // Spaceship is located at (_shipX, 0.85)
      for (int i = _asteroids.length - 1; i >= 0; i--) {
        final ast = _asteroids[i];
        double dx = (_shipX - ast.x) * 350.0;
        double dy = (0.85 - ast.y) * 500.0;
        double distance = sqrt(dx * dx + dy * dy);

        if (distance < (ast.size + 15.0)) {
          // Ship hit!
          _explosions.add(Explosion(x: ast.x, y: ast.y, maxRadius: 40.0));
          _asteroids.removeAt(i);
          _lives--;
          HapticFeedback.vibrate();

          if (_lives <= 0) {
            _endGame();
          }
          break;
        }
      }
    });
  }

  void _endGame() {
    _loopController.stop();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    // Save playtime & XP (1 min of playtime rewarded)
    GamingHubStorage.addPlaytime('space_shooter_instant', 1, context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isPlaying || _isGameOver) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (!_isPaused && _loopController.isAnimating) {
        _pausedByLifecycle = true;
        setState(() {
          _isPaused = true;
        });
        _loopController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedByLifecycle && !_isGameOver) {
        _pausedByLifecycle = false;
        setState(() {
          _isPaused = false;
        });
        _loopController.repeat();
      }
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _loopController.stop();
      } else {
        _loopController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF0D0A1E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(),

                  // Canvas Game Area
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              if (!_isPlaying || _isGameOver || _isPaused) return;
                              setState(() {
                                // Map drag update to ShipX
                                double width = MediaQuery.of(context).size.width - 32.w;
                                _shipX = (_shipX + details.delta.dx / width).clamp(0.05, 0.95);
                              });
                            },
                            child: CustomPaint(
                              painter: SpaceShooterPainter(
                                shipX: _shipX,
                                lasers: _lasers,
                                asteroids: _asteroids,
                                explosions: _explosions,
                              ),
                              child: Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Controls Guide & Score Indicator
                  _buildControlPanel(),
                ],
              ),
            ),
          ),
          const GamingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (_isPlaying && !_isGameOver) {
                // Confirm exit
                _togglePause();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exit Game?'),
                    content: const Text('Are you sure you want to exit? Your highscore and playtime will be saved.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _togglePause();
                        },
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // dialog
                          Navigator.pop(context); // game page
                          // Save 1 min playtime as exit award
                          GamingHubStorage.addPlaytime('space_shooter_instant', 1, context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Column(
            children: [
              Text(
                widget.gameName.toUpperCase(),
                style: TextStyle(
                  color: Colors.purple[200],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '⚡ INSTANT GAME',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _isGameOver ? null : _togglePause,
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lives indicator
              Row(
                children: List.generate(3, (index) {
                  return Icon(
                    Icons.favorite,
                    color: index < _lives ? Colors.redAccent : Colors.white10,
                    size: 20.w,
                  );
                }),
              ),
              // Timer
              Text(
                'SURVIVED: ${_survivalTime.toStringAsFixed(1)}s',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Score
              Text(
                'SCORE: $_score',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          if (_isGameOver)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'MISSION FAILED',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Score: $_score | Playtime: +1 Min XP awarded',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.replay),
                    label: const Text('PLAY AGAIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isPaused)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'GAME PAUSED',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: _togglePause,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text('RESUME'),
                  ),
                ],
              ),
            )
          else
            Text(
              'DRAG ON GAME BOARD TO STEER SHIP',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}

// Asteroid Entity
class Asteroid {
  double x;
  double y;
  double speed;
  double size;
  double rotation;
  double rotSpeed;

  Asteroid({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
  });
}

// Explosion Entity
class Explosion {
  double x;
  double y;
  double maxRadius;
  double progress = 0.0;

  Explosion({
    required this.x,
    required this.y,
    required this.maxRadius,
  });
}

// Canvas Painter
class SpaceShooterPainter extends CustomPainter {
  final double shipX;
  final List<Offset> lasers;
  final List<Asteroid> asteroids;
  final List<Explosion> explosions;

  SpaceShooterPainter({
    required this.shipX,
    required this.lasers,
    required this.asteroids,
    required this.explosions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Starry Background Star Clusters
    final starPaint = Paint()..color = Colors.white24;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), 1.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 1.5, starPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.7), 1.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.8), 2.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 1.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.65), 1.5, starPaint);

    // 2. Draw Lasers (glowing purple rays)
    final laserPaint = Paint()
      ..color = const Color(0xFFE100FF)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

    for (var laser in lasers) {
      double lx = laser.dx * size.width;
      double ly = laser.dy * size.height;
      canvas.drawLine(Offset(lx, ly), Offset(lx, ly - 18), laserPaint);
    }

    // 3. Draw Asteroids (detailed rocks with rotation)
    for (var ast in asteroids) {
      double ax = ast.x * size.width;
      double ay = ast.y * size.height;

      canvas.save();
      canvas.translate(ax, ay);
      canvas.rotate(ast.rotation);

      // Draw asteroid body
      final asteroidPaint = Paint()
        ..color = const Color(0xFF6E7A90)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = const Color(0xFFA5B4CD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final path = Path();
      // Draw a rocky irregular shape
      int vertices = 8;
      for (int i = 0; i < vertices; i++) {
        double angle = (i * 2 * pi) / vertices;
        double radius = ast.size * (0.85 + 0.3 * sin(i * 3.0));
        double vx = radius * cos(angle);
        double vy = radius * sin(angle);
        if (i == 0) {
          path.moveTo(vx, vy);
        } else {
          path.lineTo(vx, vy);
        }
      }
      path.close();

      canvas.drawPath(path, asteroidPaint);
      canvas.drawPath(path, borderPaint);

      // Draw rock details (crater lines)
      final craterPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-ast.size * 0.3, -ast.size * 0.2), ast.size * 0.2, craterPaint);
      canvas.drawCircle(Offset(ast.size * 0.2, ast.size * 0.3), ast.size * 0.15, craterPaint);

      canvas.restore();
    }

    // 4. Draw Explosions (animated orange ring bursts)
    for (var exp in explosions) {
      double ex = exp.x * size.width;
      double ey = exp.y * size.height;
      double currentRadius = exp.maxRadius * exp.progress;

      final expPaint = Paint()
        ..color = Colors.deepOrangeAccent.withValues(alpha: 1.0 - exp.progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - exp.progress);

      canvas.drawCircle(Offset(ex, ey), currentRadius, expPaint);

      final corePaint = Paint()
        ..color = Colors.yellowAccent.withValues(alpha: (1.0 - exp.progress) * 0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ex, ey), currentRadius * 0.5, corePaint);
    }

    // 5. Draw Spaceship (glowing player fighter ship at x = shipX)
    double sx = shipX * size.width;
    double sy = 0.85 * size.height;

    // Draw engine thruster flame
    final flamePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.yellow, Colors.red, Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(sx, sy + 20), radius: 15))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sx, sy + 15), 10.0, flamePaint);

    // Ship body path
    final shipPaint = Paint()
      ..color = Colors.purple[900]!
      ..style = PaintingStyle.fill;

    final wingPaint = Paint()
      ..color = const Color(0xFF7F00FF)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5.0);

    // Wing path
    final wingPath = Path();
    wingPath.moveTo(sx, sy - 15);
    wingPath.lineTo(sx - 25, sy + 15);
    wingPath.lineTo(sx + 25, sy + 15);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    // Main fuselage path
    final bodyPath = Path();
    bodyPath.moveTo(sx, sy - 25);
    bodyPath.lineTo(sx - 10, sy + 10);
    bodyPath.lineTo(sx + 10, sy + 10);
    bodyPath.close();
    canvas.drawPath(bodyPath, shipPaint);

    // Cabin/Cockpit glow
    final cockpitPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sx, sy - 2), 4.0, cockpitPaint);

    // Glow border around ship
    canvas.drawPath(wingPath, glowPaint);
    canvas.drawPath(bodyPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

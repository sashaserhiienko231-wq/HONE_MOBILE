import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class GameObject {
  double x, y, width, height;
  Color color;
  bool isDead = false;

  GameObject({required this.x, required this.y, required this.width, required this.height, required this.color});

  Rect get rect => Rect.fromLTWH(x, y, width, height);
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  Timer? _gameLoop;
  double _playerX = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  
  final List<GameObject> _bullets = [];
  final List<GameObject> _enemies = [];
  
  int _score = 0;
  int _highScore = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _frameCount = 0;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('space_shooter_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('space_shooter_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _bullets.clear();
      _enemies.clear();
      _playerX = _screenWidth / 2 - 25;
      _frameCount = 0;
    });

    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!mounted) return;
    setState(() {
      _frameCount++;
      
      // Move bullets
      for (var bullet in _bullets) {
        bullet.y -= 10;
        if (bullet.y < 0) bullet.isDead = true;
      }
      
      // Move enemies
      for (var enemy in _enemies) {
        enemy.y += 3 + (_score * 0.05); // increase speed with score
        if (enemy.y > _screenHeight) {
          enemy.isDead = true;
        }
      }
      
      // Spawn enemies
      if (_frameCount % max(20, 60 - _score) == 0) {
        _enemies.add(GameObject(
          x: _random.nextDouble() * (_screenWidth - 40),
          y: -40,
          width: 40,
          height: 40,
          color: AppTheme.neonPurple,
        ));
      }
      
      // Shoot bullets
      if (_frameCount % 15 == 0) {
        _bullets.add(GameObject(
          x: _playerX + 20,
          y: _screenHeight - 80,
          width: 10,
          height: 20,
          color: AppTheme.neonGreen,
        ));
      }
      
      // Collisions: Bullet vs Enemy
      for (var bullet in _bullets) {
        for (var enemy in _enemies) {
          if (!bullet.isDead && !enemy.isDead && bullet.rect.overlaps(enemy.rect)) {
            bullet.isDead = true;
            enemy.isDead = true;
            _score += 10;
          }
        }
      }
      
      // Collisions: Player vs Enemy
      Rect playerRect = Rect.fromLTWH(_playerX, _screenHeight - 60, 50, 50);
      for (var enemy in _enemies) {
        if (!enemy.isDead && enemy.rect.overlaps(playerRect)) {
          _gameOver();
        }
      }
      
      _bullets.removeWhere((b) => b.isDead);
      _enemies.removeWhere((e) => e.isDead);
    });
  }

  void _gameOver() {
    _gameLoop?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    _saveHighScore();
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Space Shooter', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;

          return GestureDetector(
            onPanUpdate: (details) {
              if (_isPlaying) {
                setState(() {
                  _playerX += details.delta.dx;
                  if (_playerX < 0) _playerX = 0;
                  if (_playerX > _screenWidth - 50) _playerX = _screenWidth - 50;
                });
              }
            },
            child: Container(
              color: Colors.transparent,
              width: _screenWidth,
              height: _screenHeight,
              child: Stack(
                children: [
                  // Draw Bullets
                  ..._bullets.map((b) => Positioned(
                    left: b.x,
                    top: b.y,
                    child: Container(
                      width: b.width,
                      height: b.height,
                      decoration: BoxDecoration(
                        color: b.color,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(color: b.color.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                    ),
                  )),
                  // Draw Enemies
                  ..._enemies.map((e) => Positioned(
                    left: e.x,
                    top: e.y,
                    child: Container(
                      width: e.width,
                      height: e.height,
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: e.color.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                    ),
                  )),
                  // Draw Player
                  if (_isPlaying || _isGameOver)
                    Positioned(
                      left: _playerX,
                      top: _screenHeight - 60,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 15, spreadRadius: 3)
                          ]
                        ),
                      ),
                    ),
                  // Score & High Score
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Score: $_score', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('High Score: $_highScore', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                  // UI Overlays
                  if (!_isPlaying)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isGameOver)
                            const Text('GAME OVER', style: TextStyle(color: Colors.redAccent, fontSize: 40, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            onPressed: _startGame,
                            child: Text(_isGameOver ? 'RETRY' : 'START GAME', style: const TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

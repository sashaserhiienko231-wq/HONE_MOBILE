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

const _bubbleCols = 9;
const _bubbleRows = 10;
const _bubbleColors = [
  Colors.purple,
  Colors.cyan,
  Colors.orange,
  Colors.blue,
  Colors.green,
];

class BubbleShooterGameScreen extends ConsumerStatefulWidget {
  const BubbleShooterGameScreen({super.key});

  @override
  ConsumerState<BubbleShooterGameScreen> createState() =>
      _BubbleShooterGameScreenState();
}

class _BubbleShooterGameScreenState
    extends ConsumerState<BubbleShooterGameScreen>
    with TickerProviderStateMixin {
  late Timer _gameTimer;
  late SharedPreferences _prefs;
  final Random _random = Random();
  final List<List<int>> _grid =
      List.generate(_bubbleRows, (_) => List<int>.filled(_bubbleCols, -1));
  int _currentColor = 0;
  int _nextColor = 1;
  double _aimPosition = 0.0;
  bool _isShooting = false;
  Offset _projectilePosition = Offset.zero;
  Offset _projectileVelocity = Offset.zero;
  int _score = 0;
  int _level = 1;
  int _shotCount = 0;
  int _highScore = 0;
  bool _isGameOver = false;
  bool _firstClear = false;
  bool _victory = false;

  // Animation controllers
  late AnimationController _launchController;
  late AnimationController _popController;
  late AnimationController _comboController;
  late AnimationController _victoryController;

  // Animations
  late Animation<double> _launchAnimation;
  late Animation<double> _popAnimation;
  late Animation<double> _comboAnimation;
  late Animation<double> _victoryAnimation;

  String? _comboMessage;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Initialize animation controllers
    _launchController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 200) : Duration.zero,
    );
    _popController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 300) : Duration.zero,
    );
    _comboController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 600) : Duration.zero,
    );
    _victoryController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );

    // Initialize animations
    _launchAnimation = CurvedAnimation(
      parent: _launchController,
      curve: AnimationPresets.easeOutCubic,
    );
    _popAnimation = CurvedAnimation(
      parent: _popController,
      curve: AnimationPresets.easeOutCubic,
    );
    _comboAnimation = CurvedAnimation(
      parent: _comboController,
      curve: AnimationPresets.easeOutCubic,
    );
    _victoryAnimation = CurvedAnimation(
      parent: _victoryController,
      curve: AnimationPresets.easeOutCubic,
    );

    _loadState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GamingHubStorage.recordGameLaunch('bubble-shooter');
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
    _highScore = _prefs.getInt('bubble_shooter_high_score') ?? 0;
    final saved = _prefs.getString('bubble_shooter_state');
    if (saved != null) {
      try {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        _score = map['score'] as int? ?? 0;
        _level = map['level'] as int? ?? 1;
        _shotCount = map['shotCount'] as int? ?? 0;
        _currentColor = map['currentColor'] as int? ?? 0;
        _nextColor = map['nextColor'] as int? ?? 1;
        _aimPosition = map['aimPosition'] as double? ?? 0.0;
        _isGameOver = map['isGameOver'] as bool? ?? false;
        _victory = map['victory'] as bool? ?? false;
        final grid = (map['grid'] as List<dynamic>?) ?? [];
        if (grid.length == _bubbleRows) {
          for (var row = 0; row < _bubbleRows; row++) {
            _grid[row] = (grid[row] as List<dynamic>).cast<int>();
          }
        }
      } catch (_) {
        _initializeGrid();
      }
    } else {
      _initializeGrid();
    }
    _generateCurrentColors();
    _startTimer();
    setState(() {});
  }

  void _initializeGrid() {
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < _bubbleCols; col++) {
        _grid[row][col] = _random.nextInt(_bubbleColors.length);
      }
    }
    for (var row = 5; row < _bubbleRows; row++) {
      _grid[row] = List<int>.filled(_bubbleCols, -1);
    }
  }

  void _generateCurrentColors() {
    _currentColor = _currentColor.clamp(0, _bubbleColors.length - 1);
    _nextColor = _nextColor.clamp(0, _bubbleColors.length - 1);
    if (_currentColor < 0) {
      _currentColor = _random.nextInt(_bubbleColors.length);
    }
    if (_nextColor < 0) {
      _nextColor = _random.nextInt(_bubbleColors.length);
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 24), (_) {
      if (_isGameOver || !_isShooting) return;
      _updateProjectile();
    });
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _launchController.dispose();
    _popController.dispose();
    _comboController.dispose();
    _victoryController.dispose();
    super.dispose();
  }

  void _updateProjectile() {
    setState(() {
      _projectilePosition += _projectileVelocity;
      if (_projectilePosition.dx < 0 || _projectilePosition.dx > 1) {
        _projectileVelocity =
            Offset(-_projectileVelocity.dx, _projectileVelocity.dy);
      }
      if (_projectilePosition.dy <= 0) {
        _projectilePosition = Offset(_projectilePosition.dx, 0);
        _attachProjectile();
      }
      for (var r = 0; r < _bubbleRows; r++) {
        for (var c = 0; c < _bubbleCols; c++) {
          if (_grid[r][c] != -1) {
            final center =
                Offset((c + 0.5) / _bubbleCols, 1 - (r + 0.5) / _bubbleRows);
            if ((_projectilePosition - center).distance <
                1 / _bubbleCols * 0.9) {
              _attachProjectile();
              return;
            }
          }
        }
      }
    });
  }

  void _attachProjectile() {
    _isShooting = false;
    final gridRow = (_bubbleRows - 1 - (_projectilePosition.dy * _bubbleRows))
        .clamp(0, _bubbleRows - 1)
        .toInt();
    final gridCol = (_projectilePosition.dx * _bubbleCols)
        .clamp(0, _bubbleCols - 1)
        .toInt();
    final candidateRow = max(0, min(_bubbleRows - 1, gridRow));
    final candidateCol = max(0, min(_bubbleCols - 1, gridCol));
    if (_grid[candidateRow][candidateCol] != -1) {
      _placeBubble(candidateRow + 1, candidateCol);
    } else {
      _placeBubble(candidateRow, candidateCol);
    }
    _saveState();
  }

  void _placeBubble(int row, int col) {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final safeRow = max(0, min(_bubbleRows - 1, row));
    final safeCol = max(0, min(_bubbleCols - 1, col));
    if (_grid[safeRow][safeCol] != -1) {
      return;
    }
    _grid[safeRow][safeCol] = _currentColor;
    _shotCount++;
    final removed = _removeMatchingCluster(safeRow, safeCol, _currentColor);
    if (removed >= 3) {
      // Trigger pop animation
      if (animEnabled) {
        _popController.forward(from: 0);
      }

      _score += removed * 45;
      if (!_firstClear) {
        _firstClear = true;
        GamingHubStorage.unlockAchievement('bubble_first_clear', context);
      }
      if (removed >= 5) {
        // Trigger combo animation
        if (animEnabled) {
          setState(() {
            _comboMessage = 'COMBO x$removed!';
          });
          _comboController.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _comboMessage = null;
              });
            }
          });
        }
        GamingHubStorage.unlockAchievement('bubble_combo_master', context);
      }
      if (_isBoardCleared()) {
        _victory = true;
        if (animEnabled) {
          _victoryController.forward();
        }
        GamingHubStorage.unlockAchievement('bubble_level_10', context);
      }
    }
    _currentColor = _nextColor;
    _nextColor = _random.nextInt(_bubbleColors.length);
    if (_shotCount % 6 == 0) {
      _level = min(12, _level + 1);
      _addNewRow();
    }
    if (_grid[_bubbleRows - 1].any((cell) => cell != -1)) {
      _triggerGameOver();
    }
    _highScore = max(_highScore, _score);
    _prefs.setInt('bubble_shooter_high_score', _highScore);
  }

  bool _isBoardCleared() {
    for (var row = 0; row < _bubbleRows; row++) {
      for (var col = 0; col < _bubbleCols; col++) {
        if (_grid[row][col] != -1) return false;
      }
    }
    return true;
  }

  int _removeMatchingCluster(int row, int col, int color) {
    final visited = <String>{};
    final queue = <_GridCell>[];
    queue.add(_GridCell(row, col));
    visited.add('$row,$col');
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      for (var delta in const [
        Offset(1, 0),
        Offset(-1, 0),
        Offset(0, 1),
        Offset(0, -1),
      ]) {
        final nextRow = current.row + delta.dy.toInt();
        final nextCol = current.col + delta.dx.toInt();
        if (nextRow < 0 ||
            nextRow >= _bubbleRows ||
            nextCol < 0 ||
            nextCol >= _bubbleCols) {
          continue;
        }
        if (_grid[nextRow][nextCol] == color &&
            !visited.contains('$nextRow,$nextCol')) {
          visited.add('$nextRow,$nextCol');
          queue.add(_GridCell(nextRow, nextCol));
        }
      }
    }
    if (visited.length < 3) {
      return 0;
    }
    for (final coord in visited) {
      final parts = coord.split(',');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      _grid[r][c] = -1;
    }
    return visited.length;
  }

  void _addNewRow() {
    _grid.removeLast();
    _grid.insert(
        0,
        List<int>.generate(
            _bubbleCols, (_) => _random.nextInt(_bubbleColors.length)));
  }

  void _triggerGameOver() {
    setState(() {
      _isGameOver = true;
    });
    GamingHubStorage.addPlaytime(
        'bubble-shooter', max(1, _score ~/ 50), context);
    _prefs.setInt('bubble_shooter_high_score', _highScore);
  }

  void _restart() {
    setState(() {
      _score = 0;
      _level = 1;
      _shotCount = 0;
      _isGameOver = false;
      _victory = false;
      _firstClear = false;
      _initializeGrid();
      _currentColor = _random.nextInt(_bubbleColors.length);
      _nextColor = _random.nextInt(_bubbleColors.length);
      _isShooting = false;
      _projectilePosition = Offset.zero;
      _projectileVelocity = Offset.zero;
    });
    _saveState();
  }

  void _saveState() {
    _prefs.setString(
        'bubble_shooter_state',
        jsonEncode({
          'score': _score,
          'level': _level,
          'shotCount': _shotCount,
          'currentColor': _currentColor,
          'nextColor': _nextColor,
          'aimPosition': _aimPosition,
          'isGameOver': _isGameOver,
          'victory': _victory,
          'grid': _grid,
        }));
  }

  void _shoot() {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    if (_isGameOver || _isShooting) return;
    setState(() {
      _isShooting = true;
      _projectilePosition = const Offset(0.5, 0.0);
      final targetX = 0.5 + _aimPosition;
      final direction = Offset(targetX - 0.5, 1.0);
      final distance = direction.distance;
      _projectileVelocity =
          distance <= 0 ? const Offset(0, 0) : direction / distance * 0.02;
    });

    if (animEnabled) {
      _launchController.forward(from: 0);
    }
  }

  void _adjustAim(double delta) {
    if (_isGameOver) return;
    setState(() {
      _aimPosition = (_aimPosition + delta).clamp(-0.4, 0.4);
    });
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
                colors: [Color(0xFF050409), Color(0xFF100724)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 10.h),
                    Expanded(child: _buildBoard()),
                    SizedBox(height: 10.h),
                    _buildHud(),
                    SizedBox(height: 10.h),
                    _buildActionRow(),
                  ],
                ),
              ),
            ),
          ),
          if (_isGameOver || _victory)
            _buildOverlay(
                _victory ? 'VICTORY' : 'DEFEAT',
                _victory
                    ? 'You cleared the board!'
                    : 'The bubbles reached the bottom.'),
          if (_comboMessage != null) _buildComboMessage(),
          const GamingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text('BUBBLE SHOOTER',
            style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900)),
        TextButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.restart_alt, color: Colors.white70),
          label: const Text('NEW', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: (0.06 * 255).round().toDouble()),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
                color: Colors.purple
                    .withValues(alpha: (0.2 * 255).round().toDouble()),
                width: 1.5),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              for (var row = 0; row < _bubbleRows; row++)
                Row(
                  children: [
                    for (var col = 0; col < _bubbleCols; col++)
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _popAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _grid[row][col] == -1
                                  ? 1.0
                                  : 1.0 +
                                      (sin(_popAnimation.value * pi) * 0.15),
                              child: child,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _grid[row][col] == -1
                                  ? Colors.white10
                                  : _bubbleColors[_grid[row][col]],
                              border: Border.all(color: Colors.white12),
                            ),
                            height: 32.w,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (_isShooting)
          Positioned(
            left: (_projectilePosition.dx * MediaQuery.of(context).size.width) -
                12.w,
            top: ((1 - _projectilePosition.dy) *
                    (MediaQuery.of(context).size.height * 0.52)) -
                12.w,
            child: AnimatedBuilder(
              animation: _launchAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_launchAnimation.value * 0.2),
                  child: child,
                );
              },
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: _bubbleColors[_currentColor],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white24, blurRadius: 12, spreadRadius: 2)
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHud() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statTile('LEVEL', '$_level'),
        _statTile('SCORE', '$_score'),
        _statTile('BEST', '$_highScore'),
      ],
    );
  }

  Widget _statTile(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: Colors.purple
                  .withValues(alpha: (0.15 * 255).round().toDouble())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildActionRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _adjustAim(-0.06),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple
                        .withValues(alpha: (0.9 * 255).round().toDouble()),
                    padding: EdgeInsets.symmetric(vertical: 16.h)),
                child: const Icon(Icons.arrow_left, color: Colors.white),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _shoot,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16.h)),
                child: const Text('SHOOT',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _adjustAim(0.06),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple
                        .withValues(alpha: (0.9 * 255).round().toDouble()),
                    padding: EdgeInsets.symmetric(vertical: 16.h)),
                child: const Icon(Icons.arrow_right, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _previewTile('NEXT', _bubbleColors[_nextColor]),
            _previewTile('LAUNCH', _bubbleColors[_currentColor]),
          ],
        ),
      ],
    );
  }

  Widget _previewTile(String label, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: (0.06 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
              color: Colors.purple
                  .withValues(alpha: (0.15 * 255).round().toDouble())),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(String title, String description) {
    Widget overlay = Container(
      color: Colors.black.withValues(alpha: (0.8 * 255).round().toDouble()),
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
              Text(title,
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
                onPressed: _restart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('PLAY AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );

    if (_victory) {
      return AnimatedBuilder(
        animation: _victoryAnimation,
        builder: (context, child) {
          return Opacity(
            opacity:
                _victoryAnimation.value == 0 ? 1.0 : _victoryAnimation.value,
            child: Transform.scale(
              scale: _victoryAnimation.value == 0
                  ? 1.0
                  : 0.8 + (_victoryAnimation.value * 0.2),
              child: child,
            ),
          );
        },
        child: overlay,
      );
    }
    return overlay;
  }

  Widget _buildComboMessage() {
    return Positioned(
      top: 100.h,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _comboAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_comboAnimation.value * 0.5),
              child: Opacity(
                opacity: 1.0 - _comboAnimation.value,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.8),
                        Colors.cyan.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Text(
                    _comboMessage ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridCell {
  final int row;
  final int col;
  const _GridCell(this.row, this.col);
}

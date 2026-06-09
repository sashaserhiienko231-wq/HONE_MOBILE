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

const int _tetrisBoardWidth = 10;
const int _tetrisBoardHeight = 20;

class TetrisGameScreen extends ConsumerStatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  ConsumerState<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends ConsumerState<TetrisGameScreen>
    with TickerProviderStateMixin {
  late List<List<int>> _board;
  late int _currentPiece;
  late int _currentRotation;
  late int _currentX;
  late int _currentY;
  late int _nextPiece;
  Timer? _gameTimer;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _score = 0;
  int _linesCleared = 0;
  int _level = 1;
  int _highScore = 0;
  bool _firstLineUnlocked = false;
  late SharedPreferences _prefs;

  // Animation controllers
  late AnimationController _spawnController;
  late AnimationController _rotationController;
  late AnimationController _lineClearController;
  late AnimationController _levelUpController;
  late AnimationController _gameOverController;
  late AnimationController _comboController;

  // Animations
  late Animation<double> _spawnAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _lineClearAnimation;
  late Animation<double> _levelUpAnimation;
  late Animation<double> _gameOverAnimation;
  late Animation<double> _comboAnimation;

  // Animation state
  int _previousLevel = 1;
  String? _comboMessage;

  static final Map<int, List<List<List<int>>>> _tetrominoes = {
    0: [
      [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      [
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
    1: [
      [
        [1, 0, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 1],
        [0, 1, 0],
        [0, 1, 0],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 0, 1],
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [1, 1, 0],
      ],
    ],
    2: [
      [
        [0, 0, 1],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 1],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [1, 0, 0],
      ],
      [
        [1, 1, 0],
        [0, 1, 0],
        [0, 1, 0],
      ],
    ],
    3: [
      [
        [1, 1],
        [1, 1],
      ],
    ],
    4: [
      [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 0, 1],
      ],
    ],
    5: [
      [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 1, 0],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 1, 0],
      ],
      [
        [0, 1, 0],
        [1, 1, 0],
        [0, 1, 0],
      ],
    ],
    6: [
      [
        [1, 1, 0],
        [0, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 0, 1],
        [0, 1, 1],
        [0, 1, 0],
      ],
    ],
  };

  static const Map<int, Color> _pieceColors = {
    0: Color(0xFF00FFFF),
    1: Color(0xFF0042FF),
    2: Color(0xFFFFA500),
    3: Color(0xFFFFE81F),
    4: Color(0xFF00FF4E),
    5: Color(0xFFAF33FF),
    6: Color(0xFFFF2A6D),
  };

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _initializeBoard();
    _nextPiece = _randomPiece();
    _spawnPiece();
    _loadPreferences();

    // Initialize animation controllers
    _spawnController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 200) : Duration.zero,
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 150) : Duration.zero,
    );
    _lineClearController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 400) : Duration.zero,
    );
    _levelUpController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );
    _gameOverController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.normal : Duration.zero,
    );
    _comboController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 600) : Duration.zero,
    );

    // Initialize animations
    _spawnAnimation = CurvedAnimation(
      parent: _spawnController,
      curve: AnimationPresets.easeOutCubic,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: AnimationPresets.easeOutCubic,
    );
    _lineClearAnimation = CurvedAnimation(
      parent: _lineClearController,
      curve: AnimationPresets.easeOutCubic,
    );
    _levelUpAnimation = CurvedAnimation(
      parent: _levelUpController,
      curve: AnimationPresets.easeOutCubic,
    );
    _gameOverAnimation = CurvedAnimation(
      parent: _gameOverController,
      curve: AnimationPresets.easeOutCubic,
    );
    _comboAnimation = CurvedAnimation(
      parent: _comboController,
      curve: AnimationPresets.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GamingHubStorage.recordGameLaunch('tetris');
      GamingHubStorage.unlockAchievement('instant_player', context);
      _applyOverlay();
    });
  }

  void _initializeBoard() {
    _board = List.generate(
      _tetrisBoardHeight,
      (_) => List<int>.filled(_tetrisBoardWidth, 0),
    );
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs.getInt('tetris_high_score') ?? 0;
    final saved = _prefs.getString('tetris_state');
    if (saved != null) {
      try {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        _score = map['score'] as int? ?? 0;
        _linesCleared = map['lines'] as int? ?? 0;
        _level = map['level'] as int? ?? 1;
        _isGameOver = map['isGameOver'] as bool? ?? false;
        _currentPiece = map['currentPiece'] as int? ?? _randomPiece();
        _currentRotation = map['currentRotation'] as int? ?? 0;
        _currentX = map['currentX'] as int? ?? 3;
        _currentY = map['currentY'] as int? ?? 0;
        _nextPiece = map['nextPiece'] as int? ?? _randomPiece();
        final board = (map['board'] as List<dynamic>?)
            ?.map((row) => (row as List<dynamic>).cast<int>())
            .toList();
        if (board != null &&
            board.length == _tetrisBoardHeight &&
            board[0].length == _tetrisBoardWidth) {
          _board = board;
        }
      } catch (_) {
        _initializeBoard();
      }
    }
    _startTimer();
    setState(() {});
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

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnController.dispose();
    _rotationController.dispose();
    _lineClearController.dispose();
    _levelUpController.dispose();
    _gameOverController.dispose();
    _comboController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
        Duration(milliseconds: max(180, 700 - (_level - 1) * 25)), (_) {
      if (!_isPaused && !_isGameOver) {
        _moveDown();
      }
    });
  }

  int _randomPiece() {
    return Random().nextInt(_tetrominoes.length);
  }

  void _spawnPiece() {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _currentPiece = _nextPiece;
    _currentRotation = 0;
    _currentX = 3;
    _currentY = 0;
    _nextPiece = _randomPiece();

    if (animEnabled) {
      _spawnController.forward(from: 0);
    }

    if (!_isValidPosition(_currentX, _currentY, _currentRotation)) {
      _endGame();
    }
  }

  bool _isValidPosition(int x, int y, int rotation) {
    final shape = _tetrominoes[_currentPiece]![rotation];
    for (var row = 0; row < shape.length; row++) {
      for (var col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 0) continue;
        final boardX = x + col;
        final boardY = y + row;
        if (boardX < 0 ||
            boardX >= _tetrisBoardWidth ||
            boardY < 0 ||
            boardY >= _tetrisBoardHeight) {
          return false;
        }
        if (_board[boardY][boardX] != 0) {
          return false;
        }
      }
    }
    return true;
  }

  void _placeCurrentPiece() {
    final shape = _tetrominoes[_currentPiece]![_currentRotation];
    for (var row = 0; row < shape.length; row++) {
      for (var col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final boardX = _currentX + col;
          final boardY = _currentY + row;
          if (boardY >= 0 &&
              boardY < _tetrisBoardHeight &&
              boardX >= 0 &&
              boardX < _tetrisBoardWidth) {
            _board[boardY][boardX] = _currentPiece + 1;
          }
        }
      }
    }
  }

  void _moveDown() {
    if (_isGameOver) return;
    if (_isValidPosition(_currentX, _currentY + 1, _currentRotation)) {
      setState(() {
        _currentY += 1;
      });
      return;
    }
    _placeCurrentPiece();
    final cleared = _clearLines();
    if (cleared > 0) {
      if (!_firstLineUnlocked) {
        _firstLineUnlocked = true;
        GamingHubStorage.unlockAchievement('tetris_first_line', context);
      }
      if (_score >= 1000) {
        GamingHubStorage.unlockAchievement('tetris_1000_score', context);
      }
    }
    _spawnPiece();
    _saveState();
  }

  int _clearLines() {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final fullRows = <int>[];
    for (var row = 0; row < _tetrisBoardHeight; row++) {
      if (_board[row].every((value) => value != 0)) {
        fullRows.add(row);
      }
    }
    if (fullRows.isEmpty) {
      return 0;
    }
    for (final row in fullRows) {
      _board.removeAt(row);
      _board.insert(0, List<int>.filled(_tetrisBoardWidth, 0));
    }
    final count = fullRows.length;
    _linesCleared += count;
    _score += 100 * count * count + _level * 10;
    _level = 1 + (_linesCleared ~/ 10);

    // Trigger line clear animation
    if (animEnabled) {
      _lineClearController.forward(from: 0);
    }

    // Combo animation
    if (count >= 2 && animEnabled) {
      setState(() {
        _comboMessage = count >= 4
            ? 'TETRIS!'
            : count == 3
                ? 'TRIPLE!'
                : 'DOUBLE!';
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

    // Level up animation
    if (_level > _previousLevel && animEnabled) {
      _levelUpController.forward(from: 0);
      _previousLevel = _level;
    }

    if (count >= 4) {
      GamingHubStorage.unlockAchievement('tetris_master', context);
    }
    return count;
  }

  void _saveState() {
    _prefs.setInt('tetris_high_score', max(_highScore, _score));
    _highScore = max(_highScore, _score);
    _prefs.setString(
        'tetris_state',
        jsonEncode({
          'score': _score,
          'lines': _linesCleared,
          'level': _level,
          'isGameOver': _isGameOver,
          'currentPiece': _currentPiece,
          'currentRotation': _currentRotation,
          'currentX': _currentX,
          'currentY': _currentY,
          'nextPiece': _nextPiece,
          'board': _board,
        }));
  }

  void _endGame() {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    setState(() {
      _isGameOver = true;
      _isPaused = false;
    });

    if (animEnabled) {
      _gameOverController.forward();
    }

    _saveState();
    GamingHubStorage.addPlaytime('tetris', max(1, (_level * 1)), context);
  }

  void _togglePause() {
    if (_isGameOver) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _restart() {
    setState(() {
      _initializeBoard();
      _score = 0;
      _linesCleared = 0;
      _level = 1;
      _isGameOver = false;
      _isPaused = false;
      _nextPiece = _randomPiece();
      _spawnPiece();
    });
    _saveState();
  }

  void _moveHorizontal(int delta) {
    if (_isGameOver || _isPaused) return;
    final newX = _currentX + delta;
    if (_isValidPosition(newX, _currentY, _currentRotation)) {
      setState(() {
        _currentX = newX;
      });
    }
  }

  void _rotateCurrentPiece() {
    if (_isGameOver || _isPaused) return;
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final nextRotation =
        (_currentRotation + 1) % _tetrominoes[_currentPiece]!.length;
    if (_isValidPosition(_currentX, _currentY, nextRotation)) {
      setState(() {
        _currentRotation = nextRotation;
      });
      if (animEnabled) {
        _rotationController.forward(from: 0);
      }
      return;
    }
    if (_isValidPosition(_currentX - 1, _currentY, nextRotation)) {
      setState(() {
        _currentX -= 1;
        _currentRotation = nextRotation;
      });
      if (animEnabled) {
        _rotationController.forward(from: 0);
      }
      return;
    }
    if (_isValidPosition(_currentX + 1, _currentY, nextRotation)) {
      setState(() {
        _currentX += 1;
        _currentRotation = nextRotation;
      });
      if (animEnabled) {
        _rotationController.forward(from: 0);
      }
    }
  }

  void _hardDrop() {
    if (_isGameOver || _isPaused) return;
    while (_isValidPosition(_currentX, _currentY + 1, _currentRotation)) {
      _currentY += 1;
    }
    _moveDown();
  }

  Widget _buildTile(int x, int y, double size) {
    final cell = _board[y][x];
    Color color = Colors.transparent;
    if (cell > 0) {
      color = _pieceColors[cell - 1]!
          .withValues(alpha: (0.95 * 255).round().toDouble());
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
            color:
                Colors.white.withValues(alpha: (0.07 * 255).round().toDouble()),
            width: 1),
      ),
    );
  }

  List<List<int>> _currentPieceMatrix() {
    return _tetrominoes[_currentPiece]![_currentRotation];
  }

  bool _isPieceCell(int x, int y) {
    final matrix = _currentPieceMatrix();
    final relX = x - _currentX;
    final relY = y - _currentY;
    if (relX < 0 ||
        relY < 0 ||
        relY >= matrix.length ||
        relX >= matrix[relY].length) {
      return false;
    }
    return matrix[relY][relX] == 1;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(1080, 2400), minTextAdapt: true);
    final width = MediaQuery.of(context).size.width;
    final boardSide = min(width - 48.w, 560.w);
    final tileSize = (boardSide - 20.w) / _tetrisBoardWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF090110)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: _buildBoard(boardSide, tileSize)),
                                SizedBox(width: 12.w),
                                _buildSidePanel(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildControls(),
                  ],
                ),
              ),
            ),
          ),
          if (_isPaused) _buildOverlay('PAUSED', 'Tap resume to continue.'),
          if (_isGameOver)
            _buildOverlay('GAME OVER', 'Press restart to play again.'),
          if (_comboMessage != null) _buildComboMessage(),
          const GamingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text(
          'TETRIS',
          style: TextStyle(
            color: Colors.purpleAccent,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            shadows: const [Shadow(color: Colors.purple, blurRadius: 12)],
          ),
        ),
        IconButton(
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white70),
          onPressed: _togglePause,
        ),
      ],
    );
  }

  Widget _buildBoard(double boardSide, double tileSize) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 6) {
          _moveHorizontal(1);
        } else if (details.delta.dx < -6) {
          _moveHorizontal(-1);
        }
        if (details.delta.dy > 8) {
          _hardDrop();
        }
      },
      onTap: _rotateCurrentPiece,
      child: Container(
        width: boardSide,
        height: boardSide * 2,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
              color: Colors.purple
                  .withValues(alpha: (0.3 * 255).round().toDouble()),
              width: 1.4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tetrisBoardHeight * _tetrisBoardWidth,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _tetrisBoardWidth,
                  mainAxisSpacing: 2.w,
                  crossAxisSpacing: 2.w,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final x = index % _tetrisBoardWidth;
                  final y = index ~/ _tetrisBoardWidth;
                  final hasPiece = _isPieceCell(x, y);
                  final settings = ref.watch(animationSettingsProvider);
                  final animEnabled =
                      settings.enabled && !settings.reduceMotion;

                  if (hasPiece) {
                    Widget piece = Container(
                      decoration: BoxDecoration(
                        color: _pieceColors[_currentPiece]!
                            .withValues(alpha: (0.95 * 255).round().toDouble()),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                    );

                    if (animEnabled) {
                      piece = AnimatedBuilder(
                        animation: Listenable.merge([
                          _spawnAnimation,
                          _rotationAnimation,
                          _lineClearAnimation
                        ]),
                        builder: (context, child) {
                          final rot = sin(_rotationAnimation.value * pi) * 0.1;
                          return Transform.rotate(
                            angle: rot,
                            child: Transform.scale(
                              scale: 0.8 + (_spawnAnimation.value * 0.2),
                              child: Opacity(
                                opacity: _spawnAnimation.value *
                                    (1.0 - _lineClearAnimation.value),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: piece,
                      );
                    }

                    return piece;
                  }
                  return _buildTile(x, y, tileSize);
                },
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                Text('Level: $_level',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                Text('High: $_highScore',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMetricCard('NEXT', _buildNextPiecePreview()),
        SizedBox(height: 12.h),
        _buildMetricCard(
            'LINES',
            Text('$_linesCleared',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold))),
        SizedBox(height: 12.h),
        _buildMetricCard(
            'LEVEL',
            AnimatedBuilder(
              animation: _levelUpAnimation,
              builder: (context, child) {
                final scale = 1.0 + (sin(_levelUpAnimation.value * pi) * 0.5);
                return Transform.scale(
                  scale: animEnabled ? scale : 1.0,
                  child: Text('$_level',
                      style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold)),
                );
              },
            )),
        SizedBox(height: 12.h),
        _buildMetricCard(
            'BEST',
            Text('$_highScore',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildMetricCard(String title, Widget child) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.06 * 255).round().toDouble()),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color:
                Colors.purple.withValues(alpha: (0.3 * 255).round().toDouble()),
            width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }

  Widget _buildNextPiecePreview() {
    final matrix = _tetrominoes[_nextPiece]![0];
    return SizedBox(
      width: 100.w,
      height: 100.w,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: matrix.length,
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 1,
        ),
        itemCount: matrix.length * matrix.length,
        itemBuilder: (context, index) {
          final x = index % matrix.length;
          final y = index ~/ matrix.length;
          final occupied = matrix[y][x] == 1;
          return Container(
            decoration: BoxDecoration(
              color: occupied
                  ? _pieceColors[_nextPiece]!
                      .withValues(alpha: (0.95 * 255).round().toDouble())
                  : Colors.white10,
              borderRadius: BorderRadius.circular(6.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(Icons.arrow_left, 'Left', () => _moveHorizontal(-1)),
        _buildActionButton(Icons.rotate_right, 'Rotate', _rotateCurrentPiece),
        _buildActionButton(
            Icons.arrow_right, 'Right', () => _moveHorizontal(1)),
        _buildActionButton(Icons.arrow_downward, 'Drop', _hardDrop),
        _buildActionButton(Icons.restart_alt, 'Restart', _restart),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.purple.withValues(alpha: (0.9 * 255).round().toDouble()),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(height: 6.h),
              Text(label,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(String headline, String description) {
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
      child: Container(
        color: Colors.black.withValues(alpha: (0.72 * 255).round().toDouble()),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: (0.08 * 255).round().toDouble()),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                  color: Colors.purple
                      .withValues(alpha: (0.25 * 255).round().toDouble()),
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text(_isGameOver ? 'RESTART' : 'RESUME'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                        Colors.pink.withValues(alpha: 0.8),
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

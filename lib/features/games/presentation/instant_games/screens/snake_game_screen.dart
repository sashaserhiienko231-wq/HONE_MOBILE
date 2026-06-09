import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import '../../instant_games/engines/snake_engine.dart';
import '../../instant_games/services/score_service.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final SnakeEngine _engine = SnakeEngine();
  final ScoreService _scoreService = ScoreService();
  static const String _gameId = 'snake';

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
    _engine.init();
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.disposeEngine();
    super.dispose();
  }

  void _onEngineUpdate() {
    setState(() {});
    if (_engine.isGameOver) {
      _saveScore();
    }
  }

  Future<void> _saveScore() async {
    final previous = await _scoreService.loadScore(_gameId);
    if (_engine.score > previous) {
      await _scoreService.saveScore(_gameId, _engine.score);
    }
  }

  void _onSwipe(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx > 0) {
        _engine.changeDirection(const Offset(1, 0));
      } else {
        _engine.changeDirection(const Offset(-1, 0));
      }
    } else {
      // Vertical swipe
      if (dy > 0) {
        _engine.changeDirection(const Offset(0, 1));
      } else {
        _engine.changeDirection(const Offset(0, -1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.shortestSide - 40.w) / SnakeEngine.columns;
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Snake'),
      ),
      body: Center(
        child: RepaintBoundary(
          child: GestureDetector(
            onPanUpdate: _onSwipe,
            child: Container(
              width: cellSize * SnakeEngine.columns,
              height: cellSize * SnakeEngine.rows,
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: AppTheme.neonPurple),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CustomPaint(
                painter: _SnakePainter(_engine.body, _engine.food, cellSize),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _engine.isGameOver
          ? Container(
              color: AppTheme.cardDark,
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: ${_engine.score}', style: const TextStyle(color: Colors.white)),
                  ElevatedButton(
                    onPressed: () {
                      _engine.init();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPurple),
                    child: const Text('Restart'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Offset> body;
  final Offset food;
  final double cellSize;

  _SnakePainter(this.body, this.food, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Draw snake body
    paint.color = AppTheme.neonPurple;
    for (final segment in body) {
      final rect = Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize);
      canvas.drawRect(rect, paint);
    }
    // Draw food
    paint.color = Colors.redAccent;
    final foodRect = Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize);
    canvas.drawRect(foodRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

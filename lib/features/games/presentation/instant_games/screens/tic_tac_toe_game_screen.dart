import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import '../../instant_games/services/score_service.dart';

class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  static const _gameId = 'tictactoe';
  final ScoreService _scoreService = ScoreService();
  List<String> _board = List.filled(9, '');
  String _current = 'X';
  bool _gameOver = false;
  String _message = '';

  void _reset() {
    setState(() {
      _board = List.filled(9, '');
      _current = 'X';
      _gameOver = false;
      _message = '';
    });
  }

  void _handleTap(int index) {
    if (_board[index].isNotEmpty || _gameOver) return;
    setState(() {
      _board[index] = _current;
      if (_checkWin(_current)) {
        _gameOver = true;
        _message = 'Player $_current wins!';
        _saveScore();
      } else if (!_board.contains('')) {
        _gameOver = true;
        _message = 'It\'s a draw.';
        _saveScore();
      } else {
        _current = _current == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWin(String player) {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var line in wins) {
      if (_board[line[0]] == player &&
          _board[line[1]] == player &&
          _board[line[2]] == player) {
        return true;
      }
    }
    return false;
  }

  Future<void> _saveScore() async {
    // Simple scoring: 1 point for a win, 0 for draw.
    final int score = _message.contains('wins') ? 1 : 0;
    final previous = await _scoreService.loadScore(_gameId);
    if (score > previous) {
      await _scoreService.saveScore(_gameId, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Tic‑Tac‑Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () => _handleTap(i),
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        _board[i],
                        style: TextStyle(color: Colors.white, fontSize: 48.sp),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_gameOver) ...[
              SizedBox(height: 20.h),
              Text(_message, style: const TextStyle(color: Colors.white70, fontSize: 18)),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPurple),
                child: const Text('Play Again'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

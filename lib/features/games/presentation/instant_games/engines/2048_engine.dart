// ignore_for_file: file_names

import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';

enum SwipeDirection { up, down, left, right }

class Game2048Engine extends ChangeNotifier {
  static const int boardSize = 4;
  final List<List<int>> board =
      List.generate(boardSize, (_) => List.filled(boardSize, 0));
  int score = 0;
  int bestScore = 0;
  int totalMerges = 0;
  int highestTile = 0;
  bool _hasMerged = false; // for first merge achievement
  bool _hasWon = false;
  bool _isPaused = false;

  // Shared random instance
  final Random _random = Random();

  // Achievement stream
  final StreamController<String> _achievementController =
      StreamController<String>.broadcast();
  Stream<String> get onAchievementUnlocked => _achievementController.stream;

  Game2048Engine() {
    _initBoard();
  }

  void _initBoard() {
    _clearBoard();
    _addRandomTile();
    _addRandomTile();
    score = 0;
    bestScore = 0;
    totalMerges = 0;
    highestTile = 0;
    _hasMerged = false;
    _hasWon = false;
    _isPaused = false;
    notifyListeners();
  }

  void _clearBoard() {
    for (var row in board) {
      for (int i = 0; i < boardSize; i++) {
        row[i] = 0;
      }
    }
  }

  void _addRandomTile() {
    final empty = <Point<int>>[];
    for (int y = 0; y < boardSize; y++) {
      for (int x = 0; x < boardSize; x++) {
        if (board[y][x] == 0) empty.add(Point(x, y));
      }
    }
    if (empty.isEmpty) return;
    final pos = empty[_random.nextInt(empty.length)];
    board[pos.y][pos.x] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  bool canMove() {
    // any empty cell
    if (board.any((row) => row.contains(0))) return true;
    // adjacent equal tiles
    for (int y = 0; y < boardSize; y++) {
      for (int x = 0; x < boardSize; x++) {
        final value = board[y][x];
        if (x + 1 < boardSize && board[y][x + 1] == value) return true;
        if (y + 1 < boardSize && board[y + 1][x] == value) return true;
      }
    }
    return false;
  }

  void slide(SwipeDirection direction) {
    if (_isPaused) return;
    bool moved = false;
    switch (direction) {
      case SwipeDirection.left:
        moved = _slideLeft();
        break;
      case SwipeDirection.right:
        moved = _slideRight();
        break;
      case SwipeDirection.up:
        moved = _slideUp();
        break;
      case SwipeDirection.down:
        moved = _slideDown();
        break;
    }
    if (moved) {
      _addRandomTile();
      notifyListeners();
    }
  }

  // Direction helpers
  bool _slideLeft() {
    bool moved = false;
    for (int y = 0; y < boardSize; y++) {
      final original = List<int>.from(board[y]);
      final compressed = _compress(board[y]);
      final merged = _merge(compressed);
      final finalRow = _compress(merged);
      board[y] = finalRow;
      if (!listEquals(original, finalRow)) moved = true;
    }
    return moved;
  }

  bool _slideRight() {
    bool moved = false;
    for (int y = 0; y < boardSize; y++) {
      final original = List<int>.from(board[y]);
      final reversed = board[y].reversed.toList();
      final compressed = _compress(reversed);
      final merged = _merge(compressed);
      final finalRow = _compress(merged).reversed.toList();
      board[y] = finalRow;
      if (!listEquals(original, finalRow)) moved = true;
    }
    return moved;
  }

  bool _slideUp() {
    bool moved = false;
    for (int x = 0; x < boardSize; x++) {
      final column = List<int>.generate(boardSize, (i) => board[i][x]);
      final original = List<int>.from(column);
      final compressed = _compress(column);
      final merged = _merge(compressed);
      final finalCol = _compress(merged);
      for (int i = 0; i < boardSize; i++) {
        board[i][x] = finalCol[i];
      }
      if (!listEquals(original, finalCol)) moved = true;
    }
    return moved;
  }

  bool _slideDown() {
    bool moved = false;
    for (int x = 0; x < boardSize; x++) {
      final column =
          List<int>.generate(boardSize, (i) => board[i][x]).reversed.toList();
      final original = List<int>.generate(boardSize, (i) => board[i][x]);
      final compressed = _compress(column);
      final merged = _merge(compressed);
      final finalCol = _compress(merged).reversed.toList();
      for (int i = 0; i < boardSize; i++) {
        board[i][x] = finalCol[i];
      }
      if (!listEquals(original, finalCol)) moved = true;
    }
    return moved;
  }

  List<int> _compress(List<int> line) {
    final newLine = line.where((v) => v != 0).toList();
    while (newLine.length < boardSize) {
      newLine.add(0);
    }
    return newLine;
  }

  List<int> _merge(List<int> line) {
    for (int i = 0; i < boardSize - 1; i++) {
      if (line[i] != 0 && line[i] == line[i + 1]) {
        line[i] *= 2;
        score += line[i];
        if (score > bestScore) bestScore = score;
        totalMerges += 1;
        if (line[i] > highestTile) highestTile = line[i];
        // achievement processing
        _processMergeAchievements(line[i]);
        // win detection
        if (line[i] == 2048) {
          _hasWon = true;
          _achievementController.add('reach_2048');
        }
        line[i + 1] = 0;
      }
    }
    return line;
  }

  void _processMergeAchievements(int value) {
    if (!_hasMerged) {
      _hasMerged = true;
      _achievementController.add('first_merge');
    }
    if (value >= 128) _achievementController.add('reach_128');
    if (value >= 512) _achievementController.add('reach_512');
    if (value >= 1024) _achievementController.add('reach_1024');
    if (score >= 5000) _achievementController.add('score_5000');
    if (score >= 10000) _achievementController.add('score_10000');
  }

  // Public getters
  bool get hasWon => _hasWon;
  bool get isGameOver => !canMove() && !_hasWon;
  bool get isPaused => _isPaused;
  List<List<int>> get boardCopy =>
      board.map((row) => List<int>.from(row)).toList();

  // Persistence
  Map<String, dynamic> toJson() => {
        'board': board,
        'score': score,
        'bestScore': bestScore,
        'totalMerges': totalMerges,
        'highestTile': highestTile,
        'hasWon': _hasWon,
        'isPaused': _isPaused,
      };

  void fromJson(Map<String, dynamic> json) {
    final List<dynamic> boardData = json['board'];
    for (int y = 0; y < boardSize; y++) {
      board[y] = List<int>.from(boardData[y]);
    }
    score = json['score'] ?? 0;
    bestScore = json['bestScore'] ?? 0;
    totalMerges = json['totalMerges'] ?? 0;
    highestTile = json['highestTile'] ?? 0;
    _hasWon = json['hasWon'] ?? false;
    _isPaused = json['isPaused'] ?? false;
    notifyListeners();
  }

  // Pause / resume
  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _achievementController.close();
    super.dispose();
  }
}

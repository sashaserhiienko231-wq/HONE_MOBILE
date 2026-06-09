import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Simple snake engine for instant game.
class SnakeEngine extends ChangeNotifier {
  static const int rows = 20;
  static const int columns = 20;
  static const Duration tickDuration = Duration(milliseconds: 150);

  List<Offset> _body = [];
  Offset _direction = const Offset(1, 0);
  Offset _food = Offset.zero;
  Timer? _timer;
  bool _gameOver = false;
  int _score = 0;

  List<Offset> get body => List.unmodifiable(_body);
  Offset get food => _food;
  bool get isGameOver => _gameOver;
  int get score => _score;

  void init() {
    _body = [const Offset(5, 10), const Offset(4, 10), const Offset(3, 10)];
    _direction = const Offset(1, 0);
    _placeFood();
    _score = 0;
    _gameOver = false;
    _timer?.cancel();
    _timer = Timer.periodic(tickDuration, (_) => _update());
  }

  void disposeEngine() {
    _timer?.cancel();
    super.dispose();
  }

  void changeDirection(Offset newDir) {
    // Prevent reversing directly.
    if (newDir.dx + _direction.dx == 0 && newDir.dy + _direction.dy == 0) {
      return;
    }
    _direction = newDir;
  }

  void _update() {
    if (_gameOver) return;
    final newHead = _body.first + _direction;
    // Boundary check
    if (newHead.dx < 0 ||
        newHead.dx >= columns ||
        newHead.dy < 0 ||
        newHead.dy >= rows) {
      _gameOver = true;
      _timer?.cancel();
      notifyListeners();
      return;
    }
    // Self collision
    if (_body.contains(newHead)) {
      _gameOver = true;
      _timer?.cancel();
      notifyListeners();
      return;
    }
    _body.insert(0, newHead);
    if (newHead == _food) {
      _score += 10;
      _placeFood();
    } else {
      _body.removeLast();
    }
    notifyListeners();
  }

  void _placeFood() {
    final rng = Random();
    do {
      _food =
          Offset(rng.nextInt(columns).toDouble(), rng.nextInt(rows).toDouble());
    } while (_body.contains(_food));
  }
}

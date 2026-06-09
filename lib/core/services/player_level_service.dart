import 'package:flutter/material.dart';

class PlayerLevelService with ChangeNotifier {
  int _level = 1;
  int _xp = 0;

  int get level => _level;
  int get xp => _xp;

  void addXp(int value) {
    _xp += value;
    while (_xp >= _xpForNextLevel()) {
      _xp -= _xpForNextLevel();
      _level += 1;
    }
    notifyListeners();
  }

  int _xpForNextLevel() => 100 + (_level - 1) * 40;
}

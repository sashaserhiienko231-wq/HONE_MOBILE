import 'package:shared_preferences/shared_preferences.dart';

/// Simple service to persist high scores and optional game state.
class ScoreService {
  static const String _prefix = 'instant_game_';

  Future<void> saveScore(String gameId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix${gameId}_high_score', score);
  }

  Future<int> loadScore(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix${gameId}_high_score') ?? 0;
  }

  // Optional: store arbitrary string state (e.g., JSON) for resume.
  Future<void> saveState(String gameId, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${gameId}_state', json);
  }

  Future<String?> loadState(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix${gameId}_state');
  }
}

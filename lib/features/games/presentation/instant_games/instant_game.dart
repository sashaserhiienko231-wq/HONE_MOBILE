import 'package:flutter/material.dart';
import 'package:hone_mobile/core/models/game_info.dart';

class InstantGame {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final String route;
  final List<String> achievements;
  final List<String> statistics;
  final bool isPlayable;

  const InstantGame({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.route,
    required this.achievements,
    required this.statistics,
    this.isPlayable = true,
  });

  String get routeName => route;

  GameInfo toGameInfo() {
    return GameInfo(
      packageName: 'instant.$id',
      appName: title,
      category: category,
      version: '1.0.0',
      versionCode: 1,
      isSystemApp: false,
      isGame: true,
      installTime: DateTime(2026),
      updateTime: DateTime(2026),
      size: 0,
      performanceProfile: GamePerformanceProfile.balanced(),
    );
  }

  static const List<InstantGame> all = [
    InstantGame(
      id: '2048',
      title: '2048',
      description: 'Slide tiles, merge powers of two, and chase the 2048 tile.',
      icon: Icons.grid_4x4_rounded,
      category: 'Puzzle',
      route: '/instant/2048',
      achievements: [
        'first_merge',
        'reach_128',
        'reach_512',
        'reach_1024',
        'reach_2048',
      ],
      statistics: ['score', 'bestScore', 'highestTile', 'totalMerges'],
    ),
    InstantGame(
      id: 'sudoku',
      title: 'Sudoku',
      description:
          'Solve a clean easy-grid logic puzzle with hints and validation.',
      icon: Icons.apps_rounded,
      category: 'Puzzle',
      route: '/instant/sudoku',
      achievements: [
        'sudoku_first_puzzle',
        'sudoku_solver',
        'sudoku_perfect_grid',
        'sudoku_master_mind',
      ],
      statistics: ['puzzlesSolved', 'bestTime', 'mistakes', 'hintsUsed'],
    ),
    InstantGame(
      id: 'chess',
      title: 'Chess',
      description: 'Fully playable chess with legal moves and offline AI.',
      icon: Icons.extension_rounded,
      category: 'Strategy',
      route: '/instant/chess',
      achievements: ['chess_first_victory', 'chess_checkmate', 'chess_ten_wins'],
      statistics: ['wins', 'matches', 'bestStreak'],
      isPlayable: true,
    ),
    InstantGame(
      id: 'bubble-shooter',
      title: 'Bubble Shooter',
      description: 'Match colors with a real shooter grid and level progression.',
      icon: Icons.bubble_chart_rounded,
      category: 'Arcade',
      route: '/instant/bubble-shooter',
      achievements: ['bubble_first_clear', 'bubble_combo_master', 'bubble_level_10'],
      statistics: ['score', 'levels', 'bestCombo'],
      isPlayable: true,
    ),
    InstantGame(
      id: 'tetris',
      title: 'Tetris',
      description:
          'Stack falling blocks with preview, scoring, and line clearing.',
      icon: Icons.view_module_rounded,
      category: 'Arcade',
      route: '/instant/tetris',
      achievements: ['tetris_first_line', 'tetris_1000_score', 'tetris_master'],
      statistics: ['score', 'linesCleared', 'bestLevel'],
      isPlayable: true,
    ),
    InstantGame(
      id: 'endless-runner',
      title: 'Endless Runner',
      description: 'Run through an infinite track, jump obstacles and collect coins.',
      icon: Icons.directions_run_rounded,
      category: 'Action',
      route: '/instant/endless-runner',
      achievements: ['runner_first_run', 'runner_1000_distance', 'runner_marathon_runner'],
      statistics: ['distance', 'coins', 'bestDistance'],
      isPlayable: true,
    ),
    InstantGame(
      id: 'space_shooter',
      title: 'Space Shooter',
      description: 'Drag to steer, auto-fire, and survive waves of asteroids.',
      icon: Icons.rocket_launch_rounded,
      category: 'Arcade',
      route: '/instant/space-shooter',
      achievements: ['instant_player', 'high_score', 'survivor'],
      statistics: ['score', 'survivalTime', 'lives'],
    ),
    InstantGame(
      id: 'snake',
      title: 'Snake',
      description: 'Classic grid chase with score persistence.',
      icon: Icons.timeline_rounded,
      category: 'Arcade',
      route: '/instant/snake',
      achievements: ['snake_first_food'],
      statistics: ['score', 'highScore'],
    ),
    InstantGame(
      id: 'tictactoe',
      title: 'Tic-Tac-Toe',
      description: 'Quick local two-player board game.',
      icon: Icons.close_rounded,
      category: 'Board',
      route: '/instant/tictactoe',
      achievements: ['tictactoe_first_win'],
      statistics: ['wins', 'draws'],
    ),
  ];

  static InstantGame? byId(String id) {
    for (final game in all) {
      if (game.id == id) return game;
    }
    return null;
  }

  static InstantGame? byRoute(String route) {
    for (final game in all) {
      if (game.route == route) return game;
    }
    return null;
  }

  static InstantGame? fromGameInfo(GameInfo game) {
    if (game.packageName.startsWith('instant.')) {
      return byId(game.packageName.substring('instant.'.length));
    }

    for (final instantGame in all) {
      if (instantGame.title == game.appName) return instantGame;
    }
    return null;
  }
}

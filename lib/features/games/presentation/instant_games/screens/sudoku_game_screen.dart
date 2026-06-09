import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/engines/sudoku_engine.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/services/score_service.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  static const String _gameId = 'sudoku';
  static const String _stateKey = 'sudoku_state';

  final ScoreService _scoreService = ScoreService();
  late SudokuEngine _engine;
  late StreamSubscription<String> _achievementSub;
  SharedPreferences? _prefs;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    _engine = SudokuEngine();
    _engine.addListener(_onEngineChanged);
    _achievementSub = _engine.onAchievementUnlocked.listen(_onAchievement);
    _loadState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GamingHubStorage.recordGameLaunch(_gameId);
      GamingHubStorage.unlockAchievement('instant_player', context);
      GamingHubStorage.unlockAchievement('sudoku_first_puzzle', context);
    });
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getString(_stateKey);
    if (saved == null) return;

    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final restored = _engine.fromJson(data);
      if (!restored) {
        _engine.newGame();
      }
      _completionShown = _engine.isCompleted;
    } catch (_) {
      _engine.newGame();
    }
  }

  void _onEngineChanged() {
    _prefs?.setString(_stateKey, jsonEncode(_engine.toJson()));
    if (mounted) setState(() {});

    if (_engine.isCompleted && !_completionShown) {
      _completionShown = true;
      _handleCompletion();
    }
  }

  Future<void> _handleCompletion() async {
    final minutes = max(1, _engine.elapsed.inMinutes);
    final score = max(
      0,
      10000 -
          _engine.elapsed.inSeconds -
          (_engine.mistakes * 500) -
          (_engine.hintsUsed * 300),
    );
    final previous = await _scoreService.loadScore(_gameId);
    if (score > previous) {
      await _scoreService.saveScore(_gameId, score);
    }

    if (!mounted) return;
    await GamingHubStorage.addPlaytime(_gameId, minutes, context);
    _showCompletionDialog(score);
  }

  void _onAchievement(String id) {
    GamingHubStorage.unlockAchievement(id, context);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _achievementSub.cancel();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide =
        media.size.width >= 720 || media.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF060913), Color(0xFF111427)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 20.w : 16.w),
                  child: isWide ? _buildWideLayout() : _buildPhoneLayout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SUDOKU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Easy logic grid',
                  style: TextStyle(color: AppTheme.neonPurple, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _buildStatsRow(),
        SizedBox(height: 14.h),
        Expanded(child: Center(child: _buildBoard())),
        SizedBox(height: 14.h),
        _buildKeypad(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Center(child: _buildBoard()),
        ),
        SizedBox(width: 20.w),
        SizedBox(
          width: min(360.w, 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatsPanel(),
              SizedBox(height: 16.h),
              _buildKeypad(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatPill('Moves', _engine.moves.toString())),
        SizedBox(width: 8.w),
        Expanded(
            child: _buildStatPill('Mistakes', _engine.mistakes.toString())),
        SizedBox(width: 8.w),
        Expanded(child: _buildStatPill('Hints', _engine.hintsUsed.toString())),
      ],
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PUZZLE STATUS',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          _buildStatsRow(),
          SizedBox(height: 12.h),
          Text(
            _engine.hasErrors
                ? 'Validation found cells that need attention.'
                : 'Current grid has no detected conflicts.',
            style: TextStyle(color: Colors.white54, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white54, fontSize: 9.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.26),
          borderRadius: BorderRadius.circular(24.r),
          border:
              Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonPurple.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: SudokuEngine.size,
          ),
          itemCount: SudokuEngine.size * SudokuEngine.size,
          itemBuilder: (context, index) {
            final row = index ~/ SudokuEngine.size;
            final col = index % SudokuEngine.size;
            return _buildCell(row, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final value = _engine.board[row][col];
    final isGiven = _engine.isGiven(row, col);
    final isSelected = _engine.isSelected(row, col);
    final isPeer = _engine.isPeer(row, col);
    final isInvalid = _engine.isInvalid(row, col);
    final selectedValue = _engine.selectedValue;
    final isSameValue = selectedValue != null && value == selectedValue;

    final borderColor = _borderColor(row, col, isSelected);
    final fillColor = isInvalid
        ? Colors.redAccent.withValues(alpha: 0.18)
        : isSelected
            ? AppTheme.neonPurple.withValues(alpha: 0.34)
            : isSameValue
                ? AppTheme.neonBlue.withValues(alpha: 0.18)
                : isPeer
                    ? Colors.white.withValues(alpha: 0.055)
                    : Colors.white.withValues(alpha: 0.025);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _engine.selectCell(row, col);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        margin: EdgeInsets.all(1.2.w),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border(
            top:
                BorderSide(color: borderColor.top, width: borderColor.topWidth),
            right: BorderSide(
                color: borderColor.right, width: borderColor.rightWidth),
            bottom: BorderSide(
                color: borderColor.bottom, width: borderColor.bottomWidth),
            left: BorderSide(
                color: borderColor.left, width: borderColor.leftWidth),
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value == 0 ? '' : value.toString(),
            style: TextStyle(
              color: isInvalid
                  ? Colors.redAccent
                  : isGiven
                      ? Colors.white
                      : AppTheme.neonPurple,
              fontSize: 21.sp,
              fontWeight: isGiven ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  _SudokuCellBorder _borderColor(int row, int col, bool isSelected) {
    final heavy = AppTheme.neonPurple.withValues(alpha: 0.55);
    final light = Colors.white.withValues(alpha: 0.08);
    const selected = AppTheme.neonBlue;
    return _SudokuCellBorder(
      top: isSelected ? selected : (row % 3 == 0 ? heavy : light),
      right: isSelected ? selected : ((col + 1) % 3 == 0 ? heavy : light),
      bottom: isSelected ? selected : ((row + 1) % 3 == 0 ? heavy : light),
      left: isSelected ? selected : (col % 3 == 0 ? heavy : light),
      topWidth: row % 3 == 0 || isSelected ? 1.6 : 0.6,
      rightWidth: (col + 1) % 3 == 0 || isSelected ? 1.6 : 0.6,
      bottomWidth: (row + 1) % 3 == 0 || isSelected ? 1.6 : 0.6,
      leftWidth: col % 3 == 0 || isSelected ? 1.6 : 0.6,
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1.22,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              if (index == 9) {
                return _buildKeyButton(
                  icon: Icons.backspace_outlined,
                  onPressed: _engine.clearSelected,
                );
              }

              final value = index + 1;
              return _buildKeyButton(
                label: value.toString(),
                onPressed: () => _engine.enterNumber(value),
              );
            },
          ),
          SizedBox(height: 10.h),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Row(
      children: [
        Expanded(
          child: _buildCommandButton(
            icon: Icons.tips_and_updates_outlined,
            label: 'Hint',
            onPressed: () {
              final used = _engine.useHint();
              if (!used) return;
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildCommandButton(
            icon: Icons.fact_check_outlined,
            label: 'Check',
            onPressed: _showValidationSnack,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton({
    String? label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      child: icon == null
          ? Text(
              label!,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
            )
          : Icon(icon, size: 18.w),
    );
  }

  Widget _buildCommandButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16.w),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonPurple,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: AppTheme.cardDark.withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(22.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
    );
  }

  void _showValidationSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            _engine.hasErrors ? Colors.redAccent : AppTheme.neonGreen,
        content: Text(
          _engine.hasErrors
              ? 'Some entries do not match this puzzle.'
              : 'No mistakes detected.',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _startNewGame() {
    _completionShown = false;
    _engine.newGame();
    GamingHubStorage.unlockAchievement('sudoku_first_puzzle', context);
  }

  void _showCompletionDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111427),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title:
            const Text('Puzzle Solved', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: $score',
                style: const TextStyle(color: Colors.white70)),
            Text('Mistakes: ${_engine.mistakes}',
                style: const TextStyle(color: Colors.white70)),
            Text('Hints: ${_engine.hintsUsed}',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPurple),
            child: const Text('New Puzzle'),
          ),
        ],
      ),
    );
  }
}

class _SudokuCellBorder {
  final Color top;
  final Color right;
  final Color bottom;
  final Color left;
  final double topWidth;
  final double rightWidth;
  final double bottomWidth;
  final double leftWidth;

  const _SudokuCellBorder({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.topWidth,
    required this.rightWidth,
    required this.bottomWidth,
    required this.leftWidth,
  });
}

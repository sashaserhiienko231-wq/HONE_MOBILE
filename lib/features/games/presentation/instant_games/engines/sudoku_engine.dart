import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class SudokuEngine extends ChangeNotifier {
  static const int size = 9;
  static const int boxSize = 3;

  final Random _random;
  final StreamController<String> _achievementController =
      StreamController<String>.broadcast();

  List<List<int>> puzzle = _emptyGrid();
  List<List<int>> board = _emptyGrid();
  List<List<int>> solution = _emptyGrid();
  int selectedRow = -1;
  int selectedCol = -1;
  int mistakes = 0;
  int hintsUsed = 0;
  int moves = 0;
  bool isCompleted = false;
  DateTime startedAt = DateTime.now();

  SudokuEngine({Random? random}) : _random = random ?? Random() {
    newGame();
  }

  Stream<String> get onAchievementUnlocked => _achievementController.stream;

  Duration get elapsed => DateTime.now().difference(startedAt);

  bool isGiven(int row, int col) => puzzle[row][col] != 0;

  bool isSelected(int row, int col) => row == selectedRow && col == selectedCol;

  bool isPeer(int row, int col) {
    if (selectedRow < 0 || selectedCol < 0) return false;
    return row == selectedRow ||
        col == selectedCol ||
        (row ~/ boxSize == selectedRow ~/ boxSize &&
            col ~/ boxSize == selectedCol ~/ boxSize);
  }

  bool isInvalid(int row, int col) {
    final value = board[row][col];
    return value != 0 && value != solution[row][col];
  }

  bool get hasErrors {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (isInvalid(row, col)) return true;
      }
    }
    return false;
  }

  int? get selectedValue {
    if (selectedRow < 0 || selectedCol < 0) return null;
    final value = board[selectedRow][selectedCol];
    return value == 0 ? null : value;
  }

  void newGame() {
    solution = _generateSolvedBoard();
    puzzle = _buildPuzzle(solution, holes: 36);
    board = _copyGrid(puzzle);
    selectedRow = -1;
    selectedCol = -1;
    mistakes = 0;
    hintsUsed = 0;
    moves = 0;
    isCompleted = false;
    startedAt = DateTime.now();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void enterNumber(int value) {
    if (!_canEditSelected || value < 1 || value > 9 || isCompleted) return;

    if (board[selectedRow][selectedCol] != value) {
      board[selectedRow][selectedCol] = value;
      moves++;
      if (value != solution[selectedRow][selectedCol]) {
        mistakes++;
      }
      _checkCompletion();
      notifyListeners();
    }
  }

  void clearSelected() {
    if (!_canEditSelected || isCompleted) return;
    if (board[selectedRow][selectedCol] != 0) {
      board[selectedRow][selectedCol] = 0;
      moves++;
      notifyListeners();
    }
  }

  bool useHint() {
    if (isCompleted) return false;
    var row = selectedRow;
    var col = selectedCol;

    if (row < 0 ||
        col < 0 ||
        isGiven(row, col) ||
        board[row][col] == solution[row][col]) {
      final next = _firstUnsolvedCell();
      if (next == null) return false;
      row = next.$1;
      col = next.$2;
    }

    selectedRow = row;
    selectedCol = col;
    board[row][col] = solution[row][col];
    hintsUsed++;
    moves++;
    _checkCompletion();
    notifyListeners();
    return true;
  }

  bool get _canEditSelected {
    return selectedRow >= 0 &&
        selectedCol >= 0 &&
        !isGiven(selectedRow, selectedCol);
  }

  (int, int)? _firstUnsolvedCell() {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (!isGiven(row, col) && board[row][col] != solution[row][col]) {
          return (row, col);
        }
      }
    }
    return null;
  }

  void _checkCompletion() {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (board[row][col] != solution[row][col]) return;
      }
    }

    if (!isCompleted) {
      isCompleted = true;
      _achievementController.add('sudoku_solver');
      if (mistakes == 0) {
        _achievementController.add('sudoku_perfect_grid');
      }
      if (mistakes == 0 && hintsUsed == 0) {
        _achievementController.add('sudoku_master_mind');
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzle': puzzle,
      'board': board,
      'solution': solution,
      'selectedRow': selectedRow,
      'selectedCol': selectedCol,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'moves': moves,
      'isCompleted': isCompleted,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  bool fromJson(Map<String, dynamic> json) {
    try {
      puzzle = _readGrid(json['puzzle']);
      board = _readGrid(json['board']);
      solution = _readGrid(json['solution']);
      selectedRow = json['selectedRow'] as int? ?? -1;
      selectedCol = json['selectedCol'] as int? ?? -1;
      mistakes = json['mistakes'] as int? ?? 0;
      hintsUsed = json['hintsUsed'] as int? ?? 0;
      moves = json['moves'] as int? ?? 0;
      isCompleted = json['isCompleted'] as bool? ?? false;
      startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now();
      notifyListeners();
      return _isGridShapeValid(puzzle) &&
          _isGridShapeValid(board) &&
          _isGridShapeValid(solution);
    } catch (_) {
      return false;
    }
  }

  List<List<int>> _generateSolvedBoard() {
    final rows = _shuffledUnits();
    final cols = _shuffledUnits();
    final digits = List<int>.generate(size, (index) => index + 1)
      ..shuffle(_random);

    return List<List<int>>.generate(size, (rowIndex) {
      return List<int>.generate(size, (colIndex) {
        final pattern = (rows[rowIndex] * boxSize +
                rows[rowIndex] ~/ boxSize +
                cols[colIndex]) %
            size;
        return digits[pattern];
      });
    });
  }

  List<int> _shuffledUnits() {
    final bands = [0, 1, 2]..shuffle(_random);
    final result = <int>[];
    for (final band in bands) {
      final cells = [0, 1, 2]..shuffle(_random);
      for (final cell in cells) {
        result.add(band * boxSize + cell);
      }
    }
    return result;
  }

  List<List<int>> _buildPuzzle(List<List<int>> solved, {required int holes}) {
    final grid = _copyGrid(solved);
    final positions = <(int, int)>[];
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        positions.add((row, col));
      }
    }
    positions.shuffle(_random);

    var removed = 0;
    for (final (row, col) in positions) {
      if (removed >= holes) break;

      final backup = grid[row][col];
      grid[row][col] = 0;
      if (_countSolutions(_copyGrid(grid), limit: 2) == 1) {
        removed++;
      } else {
        grid[row][col] = backup;
      }
    }

    return grid;
  }

  int _countSolutions(List<List<int>> grid, {required int limit}) {
    final empty = _findCellWithFewestCandidates(grid);
    if (empty == null) return 1;

    final (row, col, candidates) = empty;
    var count = 0;
    for (final value in candidates) {
      grid[row][col] = value;
      count += _countSolutions(grid, limit: limit);
      if (count >= limit) {
        grid[row][col] = 0;
        return count;
      }
    }
    grid[row][col] = 0;
    return count;
  }

  (int, int, List<int>)? _findCellWithFewestCandidates(List<List<int>> grid) {
    (int, int, List<int>)? best;

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (grid[row][col] != 0) continue;

        final candidates = _candidatesFor(grid, row, col);
        if (candidates.isEmpty) return (row, col, candidates);
        if (best == null || candidates.length < best.$3.length) {
          best = (row, col, candidates);
        }
      }
    }

    return best;
  }

  List<int> _candidatesFor(List<List<int>> grid, int row, int col) {
    final used = <int>{};
    for (var i = 0; i < size; i++) {
      used.add(grid[row][i]);
      used.add(grid[i][col]);
    }

    final boxRow = (row ~/ boxSize) * boxSize;
    final boxCol = (col ~/ boxSize) * boxSize;
    for (var r = boxRow; r < boxRow + boxSize; r++) {
      for (var c = boxCol; c < boxCol + boxSize; c++) {
        used.add(grid[r][c]);
      }
    }

    final candidates = <int>[];
    for (var value = 1; value <= size; value++) {
      if (!used.contains(value)) candidates.add(value);
    }
    candidates.shuffle(_random);
    return candidates;
  }

  static List<List<int>> _emptyGrid() =>
      List<List<int>>.generate(size, (_) => List<int>.filled(size, 0));

  static List<List<int>> _copyGrid(List<List<int>> grid) =>
      grid.map((row) => List<int>.from(row)).toList();

  static List<List<int>> _readGrid(dynamic raw) {
    final rows = raw as List<dynamic>;
    return rows.map((row) => List<int>.from(row as List<dynamic>)).toList();
  }

  static bool _isGridShapeValid(List<List<int>> grid) {
    return grid.length == size && grid.every((row) => row.length == size);
  }

  @override
  void dispose() {
    _achievementController.close();
    super.dispose();
  }
}

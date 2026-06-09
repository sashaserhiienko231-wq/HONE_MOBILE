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

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late SharedPreferences _prefs;
  late List<List<ChessPiece?>> _board;
  bool _whiteTurn = true;
  bool _isGameOver = false;
  String _status = 'Your move';
  _BoardLocation? _selected;
  int _wins = 0;
  int _highScore = 0;
  bool _hasCheckmate = false;

  // Animation controllers
  late AnimationController _moveController;
  late AnimationController _captureController;
  late AnimationController _checkController;
  late AnimationController _checkmateController;
  late AnimationController _victoryController;

  // Animations
  late Animation<double> _moveAnimation;
  late Animation<double> _captureAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _checkmateAnimation;
  late Animation<double> _victoryAnimation;

  // Animation state
  _BoardLocation? _lastMoveFrom;
  _BoardLocation? _lastMoveTo;
  bool _wasCapture = false;
  bool _wasCheck = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _initializeBoard();
    _loadState();

    // Initialize animation controllers
    _moveController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 300) : Duration.zero,
    );
    _captureController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 400) : Duration.zero,
    );
    _checkController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 500) : Duration.zero,
    );
    _checkmateController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );
    _victoryController = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.premium : Duration.zero,
    );

    // Initialize animations
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: AnimationPresets.easeOutCubic,
    );
    _captureAnimation = CurvedAnimation(
      parent: _captureController,
      curve: AnimationPresets.easeOutCubic,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: AnimationPresets.easeOutCubic,
    );
    _checkmateAnimation = CurvedAnimation(
      parent: _checkmateController,
      curve: AnimationPresets.easeOutCubic,
    );
    _victoryAnimation = CurvedAnimation(
      parent: _victoryController,
      curve: AnimationPresets.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GamingHubStorage.recordGameLaunch('chess');
      GamingHubStorage.unlockAchievement('instant_player', context);
      _applyOverlay();
    });
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
    _moveController.dispose();
    _captureController.dispose();
    _checkController.dispose();
    _checkmateController.dispose();
    _victoryController.dispose();
    super.dispose();
  }

  void _initializeBoard() {
    _board = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
    _setupPieces();
  }

  void _setupPieces() {
    const backRank = [PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen, PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook];
    for (var i = 0; i < 8; i++) {
      _board[0][i] = ChessPiece(PieceType.rook, false); // placeholder black back row overwritten
      _board[7][i] = ChessPiece(PieceType.rook, true);
    }
    for (var i = 0; i < 8; i++) {
      _board[1][i] = ChessPiece(PieceType.pawn, false);
      _board[6][i] = ChessPiece(PieceType.pawn, true);
    }
    for (var i = 0; i < 8; i++) {
      _board[0][i] = ChessPiece(backRank[i], false);
      _board[7][i] = ChessPiece(backRank[i], true);
    }
    _whiteTurn = true;
    _isGameOver = false;
    _status = 'Your move';
    _selected = null;
    _wins = _wins;
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    _wins = _prefs.getInt('chess_wins') ?? 0;
    _highScore = _prefs.getInt('chess_high_score') ?? 0;
    final saved = _prefs.getString('chess_state');
    if (saved != null) {
      try {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        _whiteTurn = map['whiteTurn'] as bool? ?? true;
        _isGameOver = map['isGameOver'] as bool? ?? false;
        _status = map['status'] as String? ?? 'Your move';
        final grid = (map['board'] as List<dynamic>?) ?? [];
        if (grid.length == 8) {
          for (var row = 0; row < 8; row++) {
            final rowData = (grid[row] as List<dynamic>).cast<Map<String, dynamic>>();
            for (var col = 0; col < 8; col++) {
              final data = rowData[col];
              if (data['type'] == null) {
                _board[row][col] = null;
              } else {
                _board[row][col] = ChessPiece.fromJson(data);
              }
            }
          }
        }
      } catch (_) {
        _initializeBoard();
      }
    }
    setState(() {});
  }

  void _saveState() {
    _prefs.setInt('chess_wins', _wins);
    _prefs.setInt('chess_high_score', _highScore);
    _prefs.setString('chess_state', jsonEncode({
      'whiteTurn': _whiteTurn,
      'isGameOver': _isGameOver,
      'status': _status,
      'board': _board.map((row) => row.map((piece) => piece?.toJson() ?? {'type': null}).toList()).toList(),
    }));
  }

  void _selectSquare(int row, int col) {
    if (_isGameOver) return;
    final piece = _board[row][col];
    if (_selected == null) {
      if (piece != null && piece.isWhite == _whiteTurn) {
        setState(() => _selected = _BoardLocation(row, col));
      }
      return;
    }
    final from = _selected!;
    final attempt = _createMove(from.row, from.col, row, col);
    if (attempt != null) {
      _applyMove(attempt);
    } else if (piece != null && piece.isWhite == _whiteTurn) {
      setState(() => _selected = _BoardLocation(row, col));
    } else {
      setState(() => _selected = null);
    }
  }

  _Move? _createMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _board[fromRow][fromCol];
    if (piece == null || piece.isWhite != _whiteTurn) return null;
    final legal = _legalMovesFor(fromRow, fromCol);
    return legal.firstWhereOrNull((move) => move.toRow == toRow && move.toCol == toCol);
  }

  void _applyMove(_Move move) {
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final piece = _board[move.fromRow][move.fromCol]!;
    final capturedPiece = _board[move.toRow][move.toCol];
    final wasCapture = capturedPiece != null;

    // Track last move for animation
    _lastMoveFrom = _BoardLocation(move.fromRow, move.fromCol);
    _lastMoveTo = _BoardLocation(move.toRow, move.toCol);
    _wasCapture = wasCapture;

    _board[move.toRow][move.toCol] = piece;
    _board[move.fromRow][move.fromCol] = null;
    if (piece.type == PieceType.pawn && (move.toRow == 0 || move.toRow == 7)) {
      _board[move.toRow][move.toCol] = ChessPiece(PieceType.queen, piece.isWhite);
    }

    // Trigger move animation
    if (animEnabled) {
      _moveController.forward(from: 0);
    }

    // Trigger capture animation
    if (wasCapture && animEnabled) {
      _captureController.forward(from: 0);
    }

    if (_isInCheck(!_whiteTurn)) {
      _wasCheck = true;
      if (animEnabled) {
        _checkController.forward(from: 0);
      }
    } else {
      _wasCheck = false;
    }

    _whiteTurn = !_whiteTurn;
    _selected = null;
    final opponentLegal = _allLegalMoves(!_whiteTurn);
    if (opponentLegal.isEmpty) {
      if (_isInCheck(!_whiteTurn)) {
        _status = _whiteTurn ? 'Checkmate! You win.' : 'Checkmate! AI wins.';
        if (_whiteTurn) {
          _onPlayerVictory();
          if (animEnabled) {
            _victoryController.forward();
          }
        } else {
          if (animEnabled) {
            _checkmateController.forward();
          }
        }
      } else {
        _status = 'Stalemate.';
      }
      _isGameOver = true;
      _saveState();
      return;
    }
    if (_whiteTurn == false) {
      _performAiMove();
    }
    _saveState();
  }

  void _performAiMove() {
    final moves = _allLegalMoves(false);
    if (moves.isEmpty) {
      return;
    }
    final move = moves[_random.nextInt(moves.length)];
    final piece = _board[move.fromRow][move.fromCol]!;
    _board[move.toRow][move.toCol] = piece;
    _board[move.fromRow][move.fromCol] = null;
    if (piece.type == PieceType.pawn && (move.toRow == 0 || move.toRow == 7)) {
      _board[move.toRow][move.toCol] = ChessPiece(PieceType.queen, piece.isWhite);
    }
    _whiteTurn = true;
    if (_allLegalMoves(true).isEmpty) {
      if (_isInCheck(true)) {
        _status = 'Checkmate! AI wins.';
      } else {
        _status = 'Stalemate.';
      }
      _isGameOver = true;
    } else {
      _status = 'Your move';
    }
    _saveState();
  }

  void _onPlayerVictory() {
    _wins += 1;
    _highScore = max(_highScore, _wins);
    if (!_hasCheckmate) {
      _hasCheckmate = true;
      GamingHubStorage.unlockAchievement('chess_checkmate', context);
    }
    if (_wins == 1) {
      GamingHubStorage.unlockAchievement('chess_first_victory', context);
    }
    if (_wins >= 10) {
      GamingHubStorage.unlockAchievement('chess_ten_wins', context);
    }
    GamingHubStorage.addPlaytime('chess', 5, context);
  }

  List<_Move> _allLegalMoves(bool white) {
    final moves = <_Move>[];
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null && piece.isWhite == white) {
          moves.addAll(_legalMovesFor(row, col));
        }
      }
    }
    return moves;
  }

  List<_Move> _legalMovesFor(int row, int col) {
    final piece = _board[row][col];
    if (piece == null) return [];
    final moves = <_Move>[];
    for (var candidate in _rawMovesFor(row, col, piece)) {
      final copy = _copyBoard();
      final movingPiece = copy[row][col]!;
      copy[candidate.toRow][candidate.toCol] = movingPiece;
      copy[row][col] = null;
      if (movingPiece.type == PieceType.pawn && (candidate.toRow == 0 || candidate.toRow == 7)) {
        copy[candidate.toRow][candidate.toCol] = ChessPiece(PieceType.queen, movingPiece.isWhite);
      }
      if (!_isKingInCheck(copy, piece.isWhite)) {
        moves.add(candidate);
      }
    }
    return moves;
  }

  List<_Move> _rawMovesFor(int row, int col, ChessPiece piece) {
    final moves = <_Move>[];
    final directions = <Offset>[];
    switch (piece.type) {
      case PieceType.pawn:
        final forward = piece.isWhite ? -1 : 1;
        if (_isEmpty(row + forward, col)) {
          moves.add(_Move(row, col, row + forward, col));
          if ((piece.isWhite && row == 6 || !piece.isWhite && row == 1) && _isEmpty(row + 2 * forward, col)) {
            moves.add(_Move(row, col, row + 2 * forward, col));
          }
        }
        for (var dx in [-1, 1]) {
          if (_isEnemy(row + forward, col + dx, piece.isWhite)) {
            moves.add(_Move(row, col, row + forward, col + dx));
          }
        }
        break;
      case PieceType.knight:
        for (var offset in const [
          Offset(1, 2),
          Offset(2, 1),
          Offset(-1, 2),
          Offset(-2, 1),
          Offset(1, -2),
          Offset(2, -1),
          Offset(-1, -2),
          Offset(-2, -1),
        ]) {
          final toRow = row + offset.dy.toInt();
          final toCol = col + offset.dx.toInt();
          if (_isFriendlyOrOutOfBounds(toRow, toCol, piece.isWhite)) continue;
          moves.add(_Move(row, col, toRow, toCol));
        }
        break;
      case PieceType.bishop:
        directions.addAll([const Offset(1, 1), const Offset(1, -1), const Offset(-1, 1), const Offset(-1, -1)]);
        break;
      case PieceType.rook:
        directions.addAll([const Offset(1, 0), const Offset(-1, 0), const Offset(0, 1), const Offset(0, -1)]);
        break;
      case PieceType.queen:
        directions.addAll([const Offset(1, 1), const Offset(1, -1), const Offset(-1, 1), const Offset(-1, -1), const Offset(1, 0), const Offset(-1, 0), const Offset(0, 1), const Offset(0, -1)]);
        break;
      case PieceType.king:
        for (var offset in const [
          Offset(1, 1),
          Offset(1, -1),
          Offset(-1, 1),
          Offset(-1, -1),
          Offset(1, 0),
          Offset(-1, 0),
          Offset(0, 1),
          Offset(0, -1),
        ]) {
          final toRow = row + offset.dy.toInt();
          final toCol = col + offset.dx.toInt();
          if (_isFriendlyOrOutOfBounds(toRow, toCol, piece.isWhite)) continue;
          moves.add(_Move(row, col, toRow, toCol));
        }
        return moves;
    }
    for (final direction in directions) {
      var distance = 1;
      while (true) {
        final toRow = row + direction.dy.toInt() * distance;
        final toCol = col + direction.dx.toInt() * distance;
        if (!_isOnBoard(toRow, toCol)) break;
        if (_board[toRow][toCol] == null) {
          moves.add(_Move(row, col, toRow, toCol));
        } else {
          if (_board[toRow][toCol]!.isWhite != piece.isWhite) {
            moves.add(_Move(row, col, toRow, toCol));
          }
          break;
        }
        distance++;
      }
    }
    return moves;
  }

  bool _isFriendlyOrOutOfBounds(int row, int col, bool isWhite) {
    return !_isOnBoard(row, col) || (_board[row][col] != null && _board[row][col]!.isWhite == isWhite);
  }

  bool _isEmpty(int row, int col) {
    return _isOnBoard(row, col) && _board[row][col] == null;
  }

  bool _isEnemy(int row, int col, bool isWhite) {
    return _isOnBoard(row, col) && _board[row][col] != null && _board[row][col]!.isWhite != isWhite;
  }

  bool _isOnBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool _isKingInCheck(List<List<ChessPiece?>> board, bool isWhite) {
    final position = _findKing(board, isWhite);
    if (position == null) return false;
    return _isSquareAttacked(board, position.row, position.col, !isWhite);
  }

  bool _isInCheck(bool isWhite) {
    return _isKingInCheck(_board, isWhite);
  }

  _BoardLocation? _findKing(List<List<ChessPiece?>> board, bool isWhite) {
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.type == PieceType.king && piece.isWhite == isWhite) {
          return _BoardLocation(row, col);
        }
      }
    }
    return null;
  }

  bool _isSquareAttacked(List<List<ChessPiece?>> board, int row, int col, bool byWhite) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null || piece.isWhite != byWhite) continue;
        if (_attacksSquare(board, r, c, row, col)) return true;
      }
    }
    return false;
  }

  bool _attacksSquare(List<List<ChessPiece?>> board, int fromRow, int fromCol, int targetRow, int targetCol) {
    final piece = board[fromRow][fromCol]!;
    final dRow = targetRow - fromRow;
    final dCol = targetCol - fromCol;
    switch (piece.type) {
      case PieceType.pawn:
        final forward = piece.isWhite ? -1 : 1;
        return dRow == forward && dCol.abs() == 1;
      case PieceType.knight:
        return (dRow.abs() == 1 && dCol.abs() == 2) || (dRow.abs() == 2 && dCol.abs() == 1);
      case PieceType.bishop:
        if (dRow.abs() != dCol.abs()) return false;
        return _isStraightPathClear(board, fromRow, fromCol, targetRow, targetCol);
      case PieceType.rook:
        if (dRow != 0 && dCol != 0) return false;
        return _isStraightPathClear(board, fromRow, fromCol, targetRow, targetCol);
      case PieceType.queen:
        if (dRow != 0 && dCol != 0 && dRow.abs() != dCol.abs()) return false;
        return _isStraightPathClear(board, fromRow, fromCol, targetRow, targetCol);
      case PieceType.king:
        return max(dRow.abs(), dCol.abs()) == 1;
    }
  }

  bool _isStraightPathClear(List<List<ChessPiece?>> board, int fromRow, int fromCol, int toRow, int toCol) {
    final stepRow = (toRow - fromRow).sign.toInt();
    final stepCol = (toCol - fromCol).sign.toInt();
    var row = fromRow + stepRow;
    var col = fromCol + stepCol;
    while (row != toRow || col != toCol) {
      if (board[row][col] != null) return false;
      row += stepRow;
      col += stepCol;
    }
    return true;
  }

  List<List<ChessPiece?>> _copyBoard() {
    return List.generate(8, (row) => List<ChessPiece?>.from(_board[row]));
  }

  void _newGame() {
    setState(() {
      _initializeBoard();
      _setupPieces();
      _saveState();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(1080, 2400), minTextAdapt: true);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050409), Color(0xFF120A26)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text('CHESS', style: TextStyle(color: Colors.purpleAccent, fontSize: 22.sp, fontWeight: FontWeight.w900)),
                        TextButton.icon(
                          onPressed: _newGame,
                          icon: const Icon(Icons.restart_alt, color: Colors.white70),
                          label: const Text('NEW GAME', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Expanded(child: _buildBoard()),
                    SizedBox(height: 10.h),
                    _buildInfoRow(),
                  ],
                ),
              ),
            ),
          ),
          if (_isGameOver) _buildOverlay(),
          const GamingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.purple.withValues(alpha: (0.2 * 255).round().toDouble()), width: 1.4),
        ),
        child: Column(
          children: List.generate(8, (row) {
            return Expanded(
              child: Row(
                children: List.generate(8, (col) {
                  final isSelected = _selected?.row == row && _selected?.col == col;
                  final isLastMoveFrom = _lastMoveFrom?.row == row && _lastMoveFrom?.col == col;
                  final isLastMoveTo = _lastMoveTo?.row == row && _lastMoveTo?.col == col;
                  final color = ((row + col) % 2 == 0) ? const Color(0xFF141327) : const Color(0xFF221A38);
                  final piece = _board[row][col];
                  
                  Widget square = Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.purple.withValues(alpha: (0.35 * 255).round().toDouble()) 
                          : isLastMoveTo 
                              ? Colors.green.withValues(alpha: (0.3 * 255).round().toDouble())
                              : isLastMoveFrom
                                  ? Colors.yellow.withValues(alpha: (0.2 * 255).round().toDouble())
                                  : color,
                      border: Border.all(color: Colors.white12, width: 0.4),
                    ),
                    child: Center(
                      child: piece == null
                          ? const SizedBox.shrink()
                          : Text(
                              piece.symbol,
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: piece.isWhite ? Colors.white : Colors.amberAccent,
                              ),
                            ),
                    ),
                  );

                  // Apply move animation
                  if (isLastMoveTo && animEnabled) {
                    square = AnimatedBuilder(
                      animation: _moveAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.9 + (_moveAnimation.value * 0.1),
                          child: Opacity(
                            opacity: 0.7 + (_moveAnimation.value * 0.3),
                            child: child,
                          ),
                        );
                      },
                      child: square,
                    );
                  }

                  // Apply capture animation
                  if (isLastMoveTo && _wasCapture && animEnabled) {
                    square = AnimatedBuilder(
                      animation: _captureAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: _captureAnimation.value * 0.5),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: child,
                        );
                      },
                      child: square,
                    );
                  }

                  // Apply check animation
                  if (_wasCheck && piece?.type == PieceType.king && piece?.isWhite == !_whiteTurn && animEnabled) {
                    square = AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3 + (_checkAnimation.value * 0.3).clamp(0.0, 0.5)),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: child,
                        );
                      },
                      child: square,
                    );
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectSquare(row, col),
                      child: square,
                    ),
                  );
                } ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.purple.withValues(alpha: (0.15 * 255).round().toDouble())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_status, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          Row(
            children: [
              _infoChip('TURN', _whiteTurn ? 'WHITE' : 'BLACK'),
              _infoChip('WINS', '$_wins'),
              _infoChip('RECORD', '$_highScore'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: (0.05 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.purple.withValues(alpha: (0.2 * 255).round().toDouble()), width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
            SizedBox(height: 4.h),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    final isVictory = _whiteTurn; // The opponent is checkmated
    final isCheckmate = _status.contains('Checkmate');
    
    Animation<double>? activeAnimation;
    if (animEnabled && isCheckmate) {
      activeAnimation = isVictory ? _victoryAnimation : _checkmateAnimation;
    }

    Widget overlay = Container(
      color: Colors.black.withValues(alpha: (0.8 * 255).round().toDouble()),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: (0.08 * 255).round().toDouble()),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.purple.withValues(alpha: (0.2 * 255).round().toDouble()), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w900)),
              SizedBox(height: 14.h),
              Text(_status, style: TextStyle(color: Colors.white70, fontSize: 14.sp), textAlign: TextAlign.center),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _newGame,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('PLAY AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );

    if (activeAnimation != null) {
      return AnimatedBuilder(
        animation: activeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: activeAnimation!.value == 0 ? 1.0 : activeAnimation.value,
            child: Transform.scale(
              scale: activeAnimation.value == 0 ? 1.0 : 0.8 + (activeAnimation.value * 0.2),
              child: child,
            ),
          );
        },
        child: overlay,
      );
    }

    return overlay;
  }
}

class ChessPiece {
  final PieceType type;
  final bool isWhite;

  ChessPiece(this.type, this.isWhite);

  String get symbol {
    const white = {
      PieceType.king: '?',
      PieceType.queen: '?',
      PieceType.rook: '?',
      PieceType.bishop: '?',
      PieceType.knight: '?',
      PieceType.pawn: '?',
    };
    const black = {
      PieceType.king: '?',
      PieceType.queen: '?',
      PieceType.rook: '?',
      PieceType.bishop: '?',
      PieceType.knight: '?',
      PieceType.pawn: '?',
    };
    return isWhite ? white[type]! : black[type]!;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isWhite': isWhite,
    };
  }

  static ChessPiece fromJson(Map<String, dynamic> json) {
    final type = PieceType.values.firstWhere((value) => value.name == json['type'], orElse: () => PieceType.pawn);
    return ChessPiece(type, json['isWhite'] as bool? ?? true);
  }
}

enum PieceType { pawn, knight, bishop, rook, queen, king }

class _Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  _Move(this.fromRow, this.fromCol, this.toRow, this.toCol);
}

class _BoardLocation {
  final int row;
  final int col;
  _BoardLocation(this.row, this.col);
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

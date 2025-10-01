// Pure Dart game logic for Tic-Tac-Toe (Noughts & Crosses).
// Covers: board, move validation, winner/draw detection, undo,
// and AI for Easy / Medium / Hard (per assignment pseudocode).

import 'dart:math';
import 'enums.dart'; 


class GameLogic {
  /// 3x3 board using 'X', 'O', or '' for empty as per assignment
  final List<List<String>> board = List.generate(
    3,
    (_) => List.filled(3, ''),
  );

  /// Move history (stack) for undo
  final List<_Move> _history = [];

  /// 'X' or 'O' — whoever’s turn it is
  String currentPlayer = 'X';

  /// Cached winner: 'X', 'O', 'Draw', or null if game in progress
  String? winner;

  /// For Medium difficulty: first AI move random, then alternate random <-> hard
  bool _mediumPlayRandomThisTurn = true;

  final Random _rng;

  GameLogic({int? seed}) : _rng = Random(seed);

  // --------------- Core API ----------------

  /// Clears the board & history; sets starting player to 'X'
  void reset() {
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        board[r][c] = '';
      }
    }
    _history.clear();
    currentPlayer = 'X';
    winner = null;
    _mediumPlayRandomThisTurn = true;
  }

  /// Returns true if (row,col) is within 0..2 and empty
  bool isValidMove(int row, int col) {
    return row >= 0 &&
        row < 3 &&
        col >= 0 &&
        col < 3 &&
        board[row][col].isEmpty &&
        winner == null; // disallow moves once game is over
  }

  /// Applies a move if valid. Returns true if placed.
  bool makeMove(int row, int col, String mark) {
    if (mark != 'X' && mark != 'O') {
      throw ArgumentError("mark must be 'X' or 'O'");
    }
    if (!isValidMove(row, col)) return false;

    board[row][col] = mark;
    _history.add(_Move(row, col, mark));

    // After placing, check game outcome
    winner = checkWinner();

    // Advance turn only if game not over
    if (winner == null) {
      currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
    }
    return true;
  }

  /// Undo the last [count] moves (default 1).
  /// Returns how many moves were actually undone.
  int undo({int count = 1}) {
    var undone = 0;
    while (undone < count && _history.isNotEmpty) {
      final last = _history.removeLast();
      board[last.row][last.col] = '';
      currentPlayer = last.mark; // because next player becomes the one who moved
      undone++;
    }
    if (undone > 0) winner = checkWinner(); // recompute
    return undone;
  }

  /// Special: When playing vs AI, "Undo" should rewind a full turn:
  /// human move + AI move (if present). This undoes up to 2 moves.
  int undoFullTurnVsAI() {
    // undo AI (if any)
    var total = 0;
    if (_history.isNotEmpty) {
      total += undo(count: 1);
    }
    // undo human (if any)
    if (_history.isNotEmpty) {
      total += undo(count: 1);
    }
    return total;
  }

  /// Returns 'X' or 'O' if there is a winner, 'Draw' if board full, else null.
  String? checkWinner() {
    // rows
    for (var r = 0; r < 3; r++) {
      if (board[r][0].isNotEmpty &&
          board[r][0] == board[r][1] &&
          board[r][1] == board[r][2]) {
        return board[r][0];
      }
    }
    // cols
    for (var c = 0; c < 3; c++) {
      if (board[0][c].isNotEmpty &&
          board[0][c] == board[1][c] &&
          board[1][c] == board[2][c]) {
        return board[0][c];
      }
    }
    // diagonals
    if (board[0][0].isNotEmpty &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    if (board[0][2].isNotEmpty &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }

    // draw?
    if (_isBoardFull()) return 'Draw';
    return null;
  }

  bool _isBoardFull() {
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        if (board[r][c].isEmpty) return false;
      }
    }
    return true;
  }

  // --------------- AI ----------------

  /// Get the next AI move (row,col) for the given [difficulty].
  /// [aiMark] is 'X' or 'O'; [humanMark] the opposite.
  /// Returns null if there is no legal move (game over or full board).
  Point<int>? chooseAiMove(Difficulty difficulty, String aiMark, String humanMark) {
    if (winner != null) return null;

    switch (difficulty) {
      case Difficulty.easy:
        return _aiEasy();
      case Difficulty.hard:
        return _aiHard(aiMark, humanMark);
      case Difficulty.medium:
        if (_mediumPlayRandomThisTurn) {
          _mediumPlayRandomThisTurn = false; // next time use hard
          return _aiEasy();
        } else {
          _mediumPlayRandomThisTurn = true; // alternate back to random
          return _aiHard(aiMark, humanMark);
        }
    }
  }

  /// Easy: purely random empty cell.
  Point<int>? _aiEasy() {
    final empties = _emptyCells();
    if (empties.isEmpty) return null;
    return empties[_rng.nextInt(empties.length)];
  }

  /// Hard: Implements the given pseudocode strategy.
  Point<int>? _aiHard(String ai, String opp) {
    // 1) If you or your opponent has two in a row, play in the remaining square.
    final win = _findWinningOrBlockingMove(ai);
    if (win != null) return win;
    final block = _findWinningOrBlockingMove(opp);
    if (block != null) return block;

    // 2) If there's a move that creates two lines of two in a row (a "fork"), play that move.
    final fork = _findFork(ai, opp);
    if (fork != null) return fork;

    // 3) Center if free.
    if (board[1][1].isEmpty) return const Point(1, 1);

    // 4) If opponent has played in a corner, play the opposite corner.
    final opposite = _oppositeCornerIfTakenBy(opp);
    if (opposite != null) return opposite;

    // 5) Otherwise, if there's a free corner, play there.
    final corner = _anyFreeCorner();
    if (corner != null) return corner;

    // 6) Otherwise, play any empty square.
    return _aiEasy();
  }

  // --------- AI helpers ---------

  List<Point<int>> _emptyCells() {
    final out = <Point<int>>[];
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        if (board[r][c].isEmpty) out.add(Point(r, c));
      }
    }
    return out;
  }

  /// Returns a cell that completes a 3-in-a-row for [mark], or null.
  Point<int>? _findWinningOrBlockingMove(String mark) {
    // rows
    for (var r = 0; r < 3; r++) {
      final line = board[r];
      final empties = <int>[];
      var count = 0;
      for (var c = 0; c < 3; c++) {
        if (line[c] == mark) count++;
        if (line[c].isEmpty) empties.add(c);
      }
      if (count == 2 && empties.length == 1) return Point(r, empties.first);
    }
    // cols
    for (var c = 0; c < 3; c++) {
      final empties = <int>[];
      var count = 0;
      for (var r = 0; r < 3; r++) {
        if (board[r][c] == mark) count++;
        if (board[r][c].isEmpty) empties.add(r);
      }
      if (count == 2 && empties.length == 1) return Point(empties.first, c);
    }
    // diags
    {
      final empties = <int>[];
      var count = 0;
      for (var i = 0; i < 3; i++) {
        if (board[i][i] == mark) count++;
        if (board[i][i].isEmpty) empties.add(i);
      }
      if (count == 2 && empties.length == 1) {
        final i = empties.first;
        return Point(i, i);
      }
    }
    {
      final empties = <int>[];
      var count = 0;
      for (var i = 0; i < 3; i++) {
        final r = i, c = 2 - i;
        if (board[r][c] == mark) count++;
        if (board[r][c].isEmpty) empties.add(r); // store row; col can be derived
      }
      if (count == 2 && empties.length == 1) {
        final r = empties.first;
        final c = 2 - r;
        return Point(r, c);
      }
    }
    return null;
  }

  /// Find a move that creates two separate immediate winning threats (a "fork").
  Point<int>? _findFork(String me, String opp) {
    // Try each empty; count how many winning lines it creates after a hypothetical move.
    for (final cell in _emptyCells()) {
      final r = cell.x, c = cell.y;
      board[r][c] = me;
      final threats = _countImmediateWins(me);
      board[r][c] = '';
      if (threats >= 2) {
        return cell;
      }
    }
    return null;
  }

  /// Returns how many lines (rows/cols/diags) have exactly two of [me] and one empty.
  int _countImmediateWins(String me) {
    var total = 0;

    // rows
    for (var r = 0; r < 3; r++) {
      var countMe = 0, countEmpty = 0;
      for (var c = 0; c < 3; c++) {
        if (board[r][c] == me) countMe++;
        if (board[r][c].isEmpty) countEmpty++;
      }
      if (countMe == 2 && countEmpty == 1) total++;
    }
    // cols
    for (var c = 0; c < 3; c++) {
      var countMe = 0, countEmpty = 0;
      for (var r = 0; r < 3; r++) {
        if (board[r][c] == me) countMe++;
        if (board[r][c].isEmpty) countEmpty++;
      }
      if (countMe == 2 && countEmpty == 1) total++;
    }
    // diag \
    {
      var countMe = 0, countEmpty = 0;
      for (var i = 0; i < 3; i++) {
        if (board[i][i] == me) countMe++;
        if (board[i][i].isEmpty) countEmpty++;
      }
      if (countMe == 2 && countEmpty == 1) total++;
    }
    // diag /
    {
      var countMe = 0, countEmpty = 0;
      for (var i = 0; i < 3; i++) {
        final r = i, c = 2 - i;
        if (board[r][c] == me) countMe++;
        if (board[r][c].isEmpty) countEmpty++;
      }
      if (countMe == 2 && countEmpty == 1) total++;
    }

    return total;
  }

  /// If opponent took a corner, return the opposite corner if free.
  Point<int>? _oppositeCornerIfTakenBy(String opp) {
    const corners = [
      Point(0, 0),
      Point(0, 2),
      Point(2, 0),
      Point(2, 2),
    ];
    for (final p in corners) {
      final oppR = p.x, oppC = p.y;
      final oppTaken = board[oppR][oppC] == opp;
      if (oppTaken) {
        final q = Point(2 - oppR, 2 - oppC);
        if (board[q.x][q.y].isEmpty) return q;
      }
    }
    return null;
  }

  /// Any free corner.
  Point<int>? _anyFreeCorner() {
    const corners = [
      Point(0, 0),
      Point(0, 2),
      Point(2, 0),
      Point(2, 2),
    ];
    for (final p in corners) {
      if (board[p.x][p.y].isEmpty) return p;
    }
    return null;
  }
}

class _Move {
  final int row, col;
  final String mark;
  _Move(this.row, this.col, this.mark);
}

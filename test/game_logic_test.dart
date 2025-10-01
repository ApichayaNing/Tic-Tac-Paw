import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/logic/game_logic.dart';

void main() {
  test('Board starts empty and X starts', () {
    final g = GameLogic();
    expect(g.currentPlayer, 'X');
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        expect(g.board[r][c], '');
      }
    }
    expect(g.winner, isNull);
  });

  test('isValidMove only true for empty cells', () {
    final g = GameLogic();
    expect(g.isValidMove(0, 0), true);
    g.makeMove(0, 0, 'X');
    expect(g.isValidMove(0, 0), false);
    expect(g.isValidMove(3, 0), false);
  });

  test('Row win detection', () {
    final g = GameLogic();
    g.makeMove(1, 0, 'X');
    g.makeMove(0, 0, 'O');
    g.makeMove(1, 1, 'X');
    g.makeMove(0, 1, 'O');
    g.makeMove(1, 2, 'X');
    expect(g.checkWinner(), 'X');
  });

  test('Draw detection', () {
    final g = GameLogic();
    // X O X
    // X X O
    // O X O
    final moves = [
      [0,0,'X'], [0,1,'O'], [0,2,'X'],
      [1,0,'X'], [1,1,'X'], [1,2,'O'],
      [2,0,'O'], [2,1,'X'], [2,2,'O'],
    ];
    for (final m in moves) {
      g.makeMove(m[0] as int, m[1] as int, m[2] as String);
    }
    expect(g.checkWinner(), 'Draw');
  });

  test('Undo single move', () {
    final g = GameLogic();
    g.makeMove(0, 0, 'X');
    g.makeMove(1, 1, 'O');
    expect(g.board[1][1], 'O');
    g.undo(); // remove O
    expect(g.board[1][1], '');
    expect(g.currentPlayer, 'O'); // it's O's turn again
  });

  test('AI Easy returns a legal empty cell', () {
    final g = GameLogic(seed: 42);
    final p = g.chooseAiMove(Difficulty.easy, 'O', 'X');
    expect(p, isNotNull);
    expect(g.isValidMove(p!.x, p.y), true);
  });

  test('AI Hard blocks immediate threat', () {
    final g = GameLogic();
    // Human 'X' threatens to win on row 0
    g.board[0][0] = 'X';
    g.board[0][1] = 'X';
    final ai = g.chooseAiMove(Difficulty.hard, 'O', 'X')!;
    expect([ai.x, ai.y], [0,2]); // should block at (0,2)
  });
}

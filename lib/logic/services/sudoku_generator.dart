import 'dart:math';
import '../models/sudoku_cell.dart';
import '../models/game_state.dart';

/// Генератор судоку с разными уровнями сложности
class SudokuGenerator {
  Random _random = Random();

  /// Генерирует новую доску судоку
  List<List<SudokuCell>> generate(Difficulty difficulty) {
    _random = Random();
    return _generateBoard(difficulty);
  }

  /// Генерирует доску с определённым seed (для ежедневного челленджа)
  List<List<SudokuCell>> generateWithSeed(int seed, Difficulty difficulty) {
    _random = Random(seed);
    return _generateBoard(difficulty);
  }

  List<List<SudokuCell>> _generateBoard(Difficulty difficulty) {
    // Создаём полностью решённую доску
    final solution = _generateSolution();

    // Копируем для игровой доски
    final board = List.generate(
      9,
      (i) => List.generate(9, (j) => solution[i][j]),
    );

    // Удаляем клетки в зависимости от сложности
    _removeCells(board, difficulty.cellsToRemove);

    // Создаём клетки с метаданными
    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final value = board[row][col];
        return SudokuCell(
          value: value,
          solution: solution[row][col],
          isFixed: value != 0,
        );
      });
    });
  }

  /// Генерирует полностью решённую доску
  List<List<int>> _generateSolution() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  /// Заполняет доску рекурсивно с backtracking
  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (int num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Проверяет валидность числа в позиции
  bool _isValid(List<List<int>> board, int row, int col, int num) {
    // Проверка строки
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }

    // Проверка столбца
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }

    // Проверка блока 3x3
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }

    return true;
  }

  /// Удаляет клетки для создания головоломки
  void _removeCells(List<List<int>> board, int count) {
    final positions = <List<int>>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= count) break;
      board[pos[0]][pos[1]] = 0;
      removed++;
    }
  }
}

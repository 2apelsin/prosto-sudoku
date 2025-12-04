import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/sudoku_cell.dart';
import '../services/sudoku_generator.dart';
import '../services/storage_service.dart';
import 'statistics_provider.dart';

/// Провайдер состояния игры
final gameProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier(ref);
});

class GameNotifier extends StateNotifier<GameState?> {
  final Ref _ref;
  final _generator = SudokuGenerator();
  final _storage = StorageService();
  Timer? _timer;

  GameNotifier(this._ref) : super(null) {
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() async {
    final saved = await _storage.loadGame();
    if (saved != null) {
      state = saved;
    }
  }

  /// Начинает новую игру
  void startNewGame(
    Difficulty difficulty, {
    GameMode mode = GameMode.normal,
    Duration? timeLimit,
  }) {
    _timer?.cancel();
    final board = _generator.generate(difficulty);
    state = GameState(
      board: board,
      difficulty: difficulty,
      gameMode: mode,
      showErrors: mode != GameMode.hardcore,
      maxMistakes: mode == GameMode.hardcore ? 3 : 999,
      timeLimit: timeLimit,
    );
    _startTimer();
    _saveGame();
  }

  /// Продолжает сохранённую игру
  void resumeGame() {
    if (state != null && !state!.isCompleted && !state!.isGameOver) {
      _startTimer();
    }
  }

  /// Запускает таймер
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state != null &&
          !state!.isCompleted &&
          !state!.isGameOver &&
          !state!.isTimeUp) {
        final newElapsed = state!.elapsedTime + const Duration(seconds: 1);

        // Проверяем время для режима "На время"
        if (state!.gameMode == GameMode.timed && state!.timeLimit != null) {
          if (newElapsed >= state!.timeLimit!) {
            // Время вышло!
            state = state!.copyWith(
              elapsedTime: state!.timeLimit,
              isTimeUp: true,
              isGameOver: true,
            );
            _timer?.cancel();
            _storage.clearGame();
            return;
          }
        }

        state = state!.copyWith(elapsedTime: newElapsed);
      }
    });
  }

  /// Останавливает таймер
  void pauseTimer() {
    _timer?.cancel();
    _saveGame();
  }

  /// Выбирает клетку
  void selectCell(int row, int col) {
    if (state == null) return;

    final cell = state!.board[row][col];
    final selectedNum = cell.value > 0 ? cell.value : null;

    final newBoard = _updateBoardHighlights(row, col, selectedNum);
    state = state!.copyWith(
      board: newBoard,
      selectedRow: row,
      selectedCol: col,
      selectedNumber: () => selectedNum,
    );
  }

  /// Обновляет подсветку клеток
  List<List<SudokuCell>> _updateBoardHighlights(
    int selRow,
    int selCol,
    int? selectedNum,
  ) {
    final board = state!.board;
    final blockRow = (selRow ~/ 3) * 3;
    final blockCol = (selCol ~/ 3) * 3;

    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final cell = board[row][col];
        final isSelected = row == selRow && col == selCol;
        final isHighlighted =
            row == selRow ||
            col == selCol ||
            (row >= blockRow &&
                row < blockRow + 3 &&
                col >= blockCol &&
                col < blockCol + 3);

        // Подсветка одинаковых цифр
        final isSameNumber =
            selectedNum != null && cell.value == selectedNum && cell.value > 0;

        return cell.copyWith(
          isSelected: isSelected,
          isHighlighted: isHighlighted && !isSelected,
          isSameNumber: isSameNumber && !isSelected,
        );
      });
    });
  }

  /// Вводит число в выбранную клетку
  void enterNumber(int number) {
    if (state == null || !state!.hasSelection) return;
    if (state!.isCompleted || state!.isGameOver) return;

    final row = state!.selectedRow;
    final col = state!.selectedCol;
    final cell = state!.board[row][col];

    if (cell.isFixed) return;

    // Сохраняем ход для Undo
    final move = GameMove(
      row: row,
      col: col,
      previousValue: cell.value,
      previousNotes: Set.from(cell.notes),
    );

    List<List<SudokuCell>> newBoard;
    int newMistakes = state!.mistakes;
    bool hasError = false;
    bool isGameOver = false;

    if (state!.isPencilMode) {
      // Режим пометок
      final newNotes = Set<int>.from(cell.notes);
      if (newNotes.contains(number)) {
        newNotes.remove(number);
      } else {
        newNotes.add(number);
      }
      newBoard = _updateCell(row, col, cell.copyWith(notes: newNotes));
    } else {
      // Обычный режим
      final isWrong = number != cell.solution;

      if (isWrong) {
        newMistakes++;
        hasError = true;

        // Проверяем проигрыш в хардкор режиме
        if (state!.gameMode == GameMode.hardcore &&
            newMistakes >= state!.maxMistakes) {
          isGameOver = true;
        }
      }

      // В обычном режиме показываем ошибку, в хардкоре - нет
      final showAsError = state!.showErrors && isWrong;

      newBoard = _updateCell(
        row,
        col,
        cell.copyWith(value: number, notes: {}, isError: showAsError),
      );

      // Обновляем подсветку одинаковых цифр
      newBoard = _highlightSameNumbers(newBoard, number);
    }

    // Проверяем завершение игры
    final isCompleted = !isGameOver && _checkCompletion(newBoard);

    state = state!.copyWith(
      board: newBoard,
      mistakes: newMistakes,
      isCompleted: isCompleted,
      isGameOver: isGameOver,
      history: [...state!.history, move],
      hasError: hasError,
      selectedNumber: () => number,
    );

    // Сбрасываем флаг ошибки через небольшую задержку
    if (hasError) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          state = state?.copyWith(hasError: false);
        }
      });
    }

    if (isCompleted) {
      _onGameCompleted();
    } else if (isGameOver) {
      _timer?.cancel();
      _storage.clearGame();
    }

    _saveGame();
  }

  /// Подсвечивает все клетки с таким же числом
  List<List<SudokuCell>> _highlightSameNumbers(
    List<List<SudokuCell>> board,
    int number,
  ) {
    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final cell = board[row][col];
        final isSame =
            cell.value == number && cell.value > 0 && !cell.isSelected;
        return cell.copyWith(isSameNumber: isSame);
      });
    });
  }

  /// Очищает выбранную клетку
  void clearCell() {
    if (state == null || !state!.hasSelection) return;
    if (state!.isCompleted || state!.isGameOver) return;

    final row = state!.selectedRow;
    final col = state!.selectedCol;
    final cell = state!.board[row][col];

    if (cell.isFixed) return;

    final move = GameMove(
      row: row,
      col: col,
      previousValue: cell.value,
      previousNotes: Set.from(cell.notes),
    );

    final newBoard = _updateCell(
      row,
      col,
      cell.copyWith(value: 0, notes: {}, isError: false),
    );

    state = state!.copyWith(
      board: newBoard,
      history: [...state!.history, move],
      selectedNumber: () => null,
    );
    _saveGame();
  }

  /// Отменяет последний ход
  void undo() {
    if (state == null || state!.history.isEmpty) return;
    if (state!.isCompleted || state!.isGameOver) return;

    final history = List<GameMove>.from(state!.history);
    final move = history.removeLast();

    final cell = state!.board[move.row][move.col];
    final newBoard = _updateCell(
      move.row,
      move.col,
      cell.copyWith(
        value: move.previousValue,
        notes: move.previousNotes,
        isError: false,
      ),
    );

    state = state!.copyWith(board: newBoard, history: history);
    _saveGame();
  }

  /// Даёт подсказку
  void hint() {
    if (state == null) return;
    if (state!.isCompleted || state!.isGameOver) return;

    // Находим пустую клетку
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = state!.board[r][c];
        if (cell.isEmpty && !cell.isFixed) {
          final newBoard = _updateCell(
            r,
            c,
            cell.copyWith(value: cell.solution, isError: false, notes: {}),
          );

          final isCompleted = _checkCompletion(newBoard);

          state = state!.copyWith(
            board: newBoard,
            hintsUsed: state!.hintsUsed + 1,
            isCompleted: isCompleted,
          );

          if (isCompleted) _onGameCompleted();
          _saveGame();
          return;
        }
      }
    }
  }

  /// Переключает режим пометок
  void togglePencilMode() {
    if (state == null) return;
    state = state!.copyWith(isPencilMode: !state!.isPencilMode);
  }

  /// Переключает показ ошибок (только для обычного режима)
  void toggleShowErrors() {
    if (state == null || state!.gameMode == GameMode.hardcore) return;
    state = state!.copyWith(showErrors: !state!.showErrors);
    _saveGame();
  }

  /// Обновляет клетку на доске
  List<List<SudokuCell>> _updateCell(int row, int col, SudokuCell newCell) {
    return List.generate(9, (r) {
      return List.generate(9, (c) {
        if (r == row && c == col) return newCell;
        return state!.board[r][c];
      });
    });
  }

  /// Проверяет завершение игры
  bool _checkCompletion(List<List<SudokuCell>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell.value != cell.solution) return false;
      }
    }
    return true;
  }

  /// Начинает ежедневный челлендж
  void startDailyChallenge(
    List<List<SudokuCell>> board,
    Difficulty difficulty,
  ) {
    _timer?.cancel();
    state = GameState(
      board: board,
      difficulty: difficulty,
      gameMode: GameMode.normal,
      showErrors: true,
    );
    _startTimer();
  }

  /// Обработка завершения игры
  void _onGameCompleted() {
    _timer?.cancel();
    _ref
        .read(statisticsProvider.notifier)
        .recordWin(state!.difficulty, state!.elapsedTime);
    _storage.clearGame();
  }

  /// Сохраняет игру
  Future<void> _saveGame() async {
    if (state != null && !state!.isCompleted && !state!.isGameOver) {
      await _storage.saveGame(state!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

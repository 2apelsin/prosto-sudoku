import 'package:equatable/equatable.dart';
import 'sudoku_cell.dart';

/// Уровни сложности
enum Difficulty { easy, medium, hard, expert }

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Лёгкий';
      case Difficulty.medium:
        return 'Средний';
      case Difficulty.hard:
        return 'Сложный';
      case Difficulty.expert:
        return 'Эксперт';
    }
  }

  int get cellsToRemove {
    switch (this) {
      case Difficulty.easy:
        return 30;
      case Difficulty.medium:
        return 40;
      case Difficulty.hard:
        return 50;
      case Difficulty.expert:
        return 58;
    }
  }
}

/// Режим игры
enum GameMode {
  normal, // С показом ошибок
  hardcore, // Без показа ошибок (3 жизни)
  timed, // На время
}

extension GameModeExtension on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.normal:
        return 'Обычный';
      case GameMode.hardcore:
        return 'Хардкор';
      case GameMode.timed:
        return 'На время';
    }
  }

  String get description {
    switch (this) {
      case GameMode.normal:
        return 'Ошибки подсвечиваются';
      case GameMode.hardcore:
        return '3 жизни, ошибки скрыты';
      case GameMode.timed:
        return 'Успей за время!';
    }
  }
}

/// Лимиты времени для режима "На время"
enum TimeLimit {
  five(Duration(minutes: 5), '5 минут', 50),
  three(Duration(minutes: 3), '3 минуты', 100),
  two(Duration(minutes: 2), '2 минуты', 200);

  final Duration duration;
  final String displayName;
  final int bonusXp;

  const TimeLimit(this.duration, this.displayName, this.bonusXp);
}

/// Состояние игры
class GameState extends Equatable {
  final List<List<SudokuCell>> board;
  final Difficulty difficulty;
  final GameMode gameMode;
  final int selectedRow;
  final int selectedCol;
  final int? selectedNumber; // Выбранная цифра для подсветки
  final bool isPencilMode;
  final bool showErrors;
  final int hintsUsed;
  final int mistakes;
  final int maxMistakes; // Для хардкор режима
  final Duration elapsedTime;
  final Duration? timeLimit; // Лимит времени для режима "На время"
  final bool isCompleted;
  final bool isGameOver; // Проигрыш в хардкор/timed режиме
  final bool isTimeUp; // Время вышло
  final List<GameMove> history;
  final bool hasError; // Флаг для анимации тряски

  const GameState({
    required this.board,
    this.difficulty = Difficulty.easy,
    this.gameMode = GameMode.normal,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.selectedNumber,
    this.isPencilMode = false,
    this.showErrors = true,
    this.hintsUsed = 0,
    this.mistakes = 0,
    this.maxMistakes = 3,
    this.elapsedTime = Duration.zero,
    this.timeLimit,
    this.isCompleted = false,
    this.isGameOver = false,
    this.isTimeUp = false,
    this.history = const [],
    this.hasError = false,
  });

  GameState copyWith({
    List<List<SudokuCell>>? board,
    Difficulty? difficulty,
    GameMode? gameMode,
    int? selectedRow,
    int? selectedCol,
    int? Function()? selectedNumber,
    bool? isPencilMode,
    bool? showErrors,
    int? hintsUsed,
    int? mistakes,
    int? maxMistakes,
    Duration? elapsedTime,
    Duration? Function()? timeLimit,
    bool? isCompleted,
    bool? isGameOver,
    bool? isTimeUp,
    List<GameMove>? history,
    bool? hasError,
  }) {
    return GameState(
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      selectedNumber: selectedNumber != null
          ? selectedNumber()
          : this.selectedNumber,
      isPencilMode: isPencilMode ?? this.isPencilMode,
      showErrors: showErrors ?? this.showErrors,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakes: mistakes ?? this.mistakes,
      maxMistakes: maxMistakes ?? this.maxMistakes,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      timeLimit: timeLimit != null ? timeLimit() : this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      isTimeUp: isTimeUp ?? this.isTimeUp,
      history: history ?? this.history,
      hasError: hasError ?? this.hasError,
    );
  }

  bool get hasSelection => selectedRow >= 0 && selectedCol >= 0;
  int get livesLeft => maxMistakes - mistakes;

  /// Оставшееся время для режима "На время"
  Duration get remainingTime {
    if (timeLimit == null) return Duration.zero;
    final remaining = timeLimit! - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  List<Object?> get props => [
    board,
    difficulty,
    gameMode,
    selectedRow,
    selectedCol,
    selectedNumber,
    isPencilMode,
    showErrors,
    hintsUsed,
    mistakes,
    maxMistakes,
    elapsedTime,
    timeLimit,
    isCompleted,
    isGameOver,
    isTimeUp,
    history,
    hasError,
  ];
}

/// Ход для истории (Undo)
class GameMove extends Equatable {
  final int row;
  final int col;
  final int previousValue;
  final Set<int> previousNotes;

  const GameMove({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.previousNotes,
  });

  @override
  List<Object?> get props => [row, col, previousValue, previousNotes];
}

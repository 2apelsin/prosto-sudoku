import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/sudoku_cell.dart';
import '../services/sudoku_generator.dart';

/// Провайдер ежедневного челленджа
final dailyChallengeProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService();
});

class DailyChallengeService {
  final _generator = SudokuGenerator();

  /// Генерирует головоломку для сегодняшнего дня
  /// Использует дату как seed для генератора, чтобы у всех была одинаковая головоломка
  List<List<SudokuCell>> generateDailyPuzzle() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return _generator.generateWithSeed(seed, Difficulty.medium);
  }

  /// Возвращает сложность сегодняшнего челленджа (меняется по дням недели)
  Difficulty getDailyDifficulty() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: // Понедельник
      case 2: // Вторник
        return Difficulty.easy;
      case 3: // Среда
      case 4: // Четверг
        return Difficulty.medium;
      case 5: // Пятница
      case 6: // Суббота
        return Difficulty.hard;
      case 7: // Воскресенье
        return Difficulty.expert;
      default:
        return Difficulty.medium;
    }
  }

  /// Возвращает название дня для отображения
  String getDayName() {
    final weekday = DateTime.now().weekday;
    const days = [
      '',
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[weekday];
  }
}

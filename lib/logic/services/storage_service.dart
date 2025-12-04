import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../models/statistics.dart';
import '../models/sudoku_cell.dart';

/// Сервис для сохранения/загрузки данных
class StorageService {
  static const _gameKey = 'saved_game';
  static const _statsKey = 'statistics';
  static const _themeKey = 'dark_theme';
  static const _firstLaunchKey = 'first_launch_complete';
  static const _vibrationKey = 'vibration_enabled';

  /// Сохраняет текущую игру
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'board': state.board
          .map(
            (row) => row
                .map(
                  (cell) => {
                    'value': cell.value,
                    'solution': cell.solution,
                    'isFixed': cell.isFixed,
                    'notes': cell.notes.toList(),
                  },
                )
                .toList(),
          )
          .toList(),
      'difficulty': state.difficulty.index,
      'elapsedTime': state.elapsedTime.inSeconds,
      'hintsUsed': state.hintsUsed,
      'mistakes': state.mistakes,
      'showErrors': state.showErrors,
    };
    await prefs.setString(_gameKey, jsonEncode(data));
  }

  /// Загружает сохранённую игру
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_gameKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final boardData = data['board'] as List;

      final board = boardData.map<List<SudokuCell>>((row) {
        return (row as List).map<SudokuCell>((cell) {
          return SudokuCell(
            value: cell['value'] as int,
            solution: cell['solution'] as int,
            isFixed: cell['isFixed'] as bool,
            notes: Set<int>.from(cell['notes'] as List),
          );
        }).toList();
      }).toList();

      return GameState(
        board: board,
        difficulty: Difficulty.values[data['difficulty'] as int],
        elapsedTime: Duration(seconds: data['elapsedTime'] as int),
        hintsUsed: data['hintsUsed'] as int,
        mistakes: data['mistakes'] as int,
        showErrors: data['showErrors'] as bool? ?? true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Удаляет сохранённую игру
  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameKey);
  }

  /// Сохраняет статистику
  Future<void> saveStatistics(Statistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    final data = stats.stats.map(
      (key, value) => MapEntry(key.index.toString(), {
        'gamesPlayed': value.gamesPlayed,
        'gamesWon': value.gamesWon,
        'bestTime': value.bestTime.inSeconds,
        'totalTime': value.totalTime.inSeconds,
      }),
    );
    await prefs.setString(_statsKey, jsonEncode(data));
  }

  /// Загружает статистику
  Future<Statistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_statsKey);
    if (json == null) return Statistics.empty();

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final stats = <Difficulty, DifficultyStats>{};

      for (var d in Difficulty.values) {
        final s = data[d.index.toString()];
        if (s != null) {
          stats[d] = DifficultyStats(
            gamesPlayed: s['gamesPlayed'] as int,
            gamesWon: s['gamesWon'] as int,
            bestTime: Duration(seconds: s['bestTime'] as int),
            totalTime: Duration(seconds: s['totalTime'] as int),
          );
        } else {
          stats[d] = const DifficultyStats();
        }
      }

      return Statistics(stats: stats);
    } catch (e) {
      return Statistics.empty();
    }
  }

  /// Сохраняет настройку темы
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Загружает настройку темы
  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  /// Проверяет, первый ли это запуск
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLaunchKey) ?? false);
  }

  /// Отмечает, что первый запуск завершён
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  /// Сохраняет настройку вибрации
  Future<void> saveVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  /// Загружает настройку вибрации
  Future<bool> loadVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }
}

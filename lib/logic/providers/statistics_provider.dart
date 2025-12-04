import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/statistics.dart';
import '../services/storage_service.dart';

/// Провайдер статистики
final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, Statistics>((ref) {
      return StatisticsNotifier();
    });

class StatisticsNotifier extends StateNotifier<Statistics> {
  final _storage = StorageService();

  StatisticsNotifier() : super(Statistics.empty()) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    state = await _storage.loadStatistics();
  }

  /// Записывает победу
  Future<void> recordWin(Difficulty difficulty, Duration time) async {
    final currentStats = state.stats[difficulty] ?? const DifficultyStats();

    final newStats = currentStats.copyWith(
      gamesPlayed: currentStats.gamesPlayed + 1,
      gamesWon: currentStats.gamesWon + 1,
      bestTime: time < currentStats.bestTime ? time : currentStats.bestTime,
      totalTime: currentStats.totalTime + time,
    );

    final updatedStats = Map<Difficulty, DifficultyStats>.from(state.stats);
    updatedStats[difficulty] = newStats;

    state = state.copyWith(stats: updatedStats);
    await _storage.saveStatistics(state);
  }

  /// Сбрасывает статистику
  Future<void> reset() async {
    state = Statistics.empty();
    await _storage.saveStatistics(state);
  }
}

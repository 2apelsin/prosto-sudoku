import 'package:equatable/equatable.dart';
import 'game_state.dart';

/// Статистика игрока
class Statistics extends Equatable {
  final Map<Difficulty, DifficultyStats> stats;

  const Statistics({this.stats = const {}});

  factory Statistics.empty() {
    return Statistics(
      stats: {for (var d in Difficulty.values) d: const DifficultyStats()},
    );
  }

  Statistics copyWith({Map<Difficulty, DifficultyStats>? stats}) {
    return Statistics(stats: stats ?? this.stats);
  }

  int get totalGames => stats.values.fold(0, (sum, s) => sum + s.gamesPlayed);
  int get totalWins => stats.values.fold(0, (sum, s) => sum + s.gamesWon);

  @override
  List<Object?> get props => [stats];
}

/// Статистика по уровню сложности
class DifficultyStats extends Equatable {
  final int gamesPlayed;
  final int gamesWon;
  final Duration bestTime;
  final Duration totalTime;

  const DifficultyStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTime = const Duration(hours: 99),
    this.totalTime = Duration.zero,
  });

  DifficultyStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    Duration? bestTime,
    Duration? totalTime,
  }) {
    return DifficultyStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestTime: bestTime ?? this.bestTime,
      totalTime: totalTime ?? this.totalTime,
    );
  }

  Duration get averageTime {
    if (gamesWon == 0) return Duration.zero;
    return Duration(milliseconds: totalTime.inMilliseconds ~/ gamesWon);
  }

  @override
  List<Object?> get props => [gamesPlayed, gamesWon, bestTime, totalTime];
}

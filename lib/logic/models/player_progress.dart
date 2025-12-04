/// Прогресс игрока (уровни и XP)
class PlayerProgress {
  final int totalXp;
  final int currentStreak; // Текущая серия дней
  final int bestStreak; // Лучшая серия
  final DateTime? lastPlayedDate;
  final bool dailyChallengeCompleted;
  final DateTime? dailyChallengeDate;

  const PlayerProgress({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDate,
    this.dailyChallengeCompleted = false,
    this.dailyChallengeDate,
  });

  PlayerProgress copyWith({
    int? totalXp,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayedDate,
    bool? dailyChallengeCompleted,
    DateTime? dailyChallengeDate,
  }) {
    return PlayerProgress(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      dailyChallengeCompleted:
          dailyChallengeCompleted ?? this.dailyChallengeCompleted,
      dailyChallengeDate: dailyChallengeDate ?? this.dailyChallengeDate,
    );
  }

  /// Текущий уровень игрока
  int get level {
    if (totalXp < 100) return 1;
    if (totalXp < 300) return 2;
    if (totalXp < 600) return 3;
    if (totalXp < 1000) return 4;
    if (totalXp < 1500) return 5;
    if (totalXp < 2200) return 6;
    if (totalXp < 3000) return 7;
    if (totalXp < 4000) return 8;
    if (totalXp < 5500) return 9;
    return 10;
  }

  /// Название уровня
  String get levelTitle {
    switch (level) {
      case 1:
        return 'Новичок';
      case 2:
        return 'Ученик';
      case 3:
        return 'Любитель';
      case 4:
        return 'Знаток';
      case 5:
        return 'Умелец';
      case 6:
        return 'Эксперт';
      case 7:
        return 'Мастер';
      case 8:
        return 'Гроссмейстер';
      case 9:
        return 'Легенда';
      case 10:
        return 'Гуру Судоку';
      default:
        return 'Новичок';
    }
  }

  /// XP для текущего уровня
  int get xpForCurrentLevel {
    final thresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5500];
    if (level >= 10) return 5500;
    return thresholds[level - 1];
  }

  /// XP для следующего уровня
  int get xpForNextLevel {
    final thresholds = [
      100,
      300,
      600,
      1000,
      1500,
      2200,
      3000,
      4000,
      5500,
      9999,
    ];
    return thresholds[level - 1];
  }

  /// Прогресс до следующего уровня (0.0 - 1.0)
  double get levelProgress {
    if (level >= 10) return 1.0;
    final current = totalXp - xpForCurrentLevel;
    final needed = xpForNextLevel - xpForCurrentLevel;
    return current / needed;
  }
}

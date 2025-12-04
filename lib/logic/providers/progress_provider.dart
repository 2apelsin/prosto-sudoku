import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';
import '../models/achievement.dart';
import '../models/game_state.dart';

/// Провайдер прогресса игрока
final progressProvider =
    StateNotifierProvider<ProgressNotifier, PlayerProgress>((ref) {
      return ProgressNotifier();
    });

/// Провайдер достижений
final achievementsProvider =
    StateNotifierProvider<
      AchievementsNotifier,
      Map<AchievementType, Achievement>
    >((ref) {
      return AchievementsNotifier();
    });

class ProgressNotifier extends StateNotifier<PlayerProgress> {
  static const _key = 'player_progress';

  ProgressNotifier() : super(const PlayerProgress()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        state = PlayerProgress(
          totalXp: data['totalXp'] as int? ?? 0,
          currentStreak: data['currentStreak'] as int? ?? 0,
          bestStreak: data['bestStreak'] as int? ?? 0,
          lastPlayedDate: data['lastPlayedDate'] != null
              ? DateTime.parse(data['lastPlayedDate'] as String)
              : null,
          dailyChallengeCompleted:
              data['dailyChallengeCompleted'] as bool? ?? false,
          dailyChallengeDate: data['dailyChallengeDate'] != null
              ? DateTime.parse(data['dailyChallengeDate'] as String)
              : null,
        );
      } catch (e) {
        // Игнорируем ошибки
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'totalXp': state.totalXp,
      'currentStreak': state.currentStreak,
      'bestStreak': state.bestStreak,
      'lastPlayedDate': state.lastPlayedDate?.toIso8601String(),
      'dailyChallengeCompleted': state.dailyChallengeCompleted,
      'dailyChallengeDate': state.dailyChallengeDate?.toIso8601String(),
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Добавляет XP
  Future<void> addXp(int amount) async {
    state = state.copyWith(totalXp: state.totalXp + amount);
    await _save();
  }

  /// Обновляет серию дней
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (state.lastPlayedDate != null) {
      final lastPlayed = DateTime(
        state.lastPlayedDate!.year,
        state.lastPlayedDate!.month,
        state.lastPlayedDate!.day,
      );

      final difference = today.difference(lastPlayed).inDays;

      if (difference == 1) {
        // Продолжаем серию
        final newStreak = state.currentStreak + 1;
        state = state.copyWith(
          currentStreak: newStreak,
          bestStreak: newStreak > state.bestStreak
              ? newStreak
              : state.bestStreak,
          lastPlayedDate: now,
        );
      } else if (difference > 1) {
        // Серия прервана
        state = state.copyWith(currentStreak: 1, lastPlayedDate: now);
      }
      // Если difference == 0, ничего не меняем
    } else {
      // Первый день
      state = state.copyWith(
        currentStreak: 1,
        bestStreak: 1,
        lastPlayedDate: now,
      );
    }

    await _save();
  }

  /// Отмечает ежедневный челлендж выполненным
  Future<void> completeDailyChallenge() async {
    final now = DateTime.now();
    state = state.copyWith(
      dailyChallengeCompleted: true,
      dailyChallengeDate: now,
    );
    await _save();
  }

  /// Проверяет, выполнен ли сегодняшний челлендж
  bool isDailyChallengeCompletedToday() {
    if (!state.dailyChallengeCompleted || state.dailyChallengeDate == null) {
      return false;
    }
    final now = DateTime.now();
    final challengeDate = state.dailyChallengeDate!;
    return now.year == challengeDate.year &&
        now.month == challengeDate.month &&
        now.day == challengeDate.day;
  }

  /// Сбрасывает ежедневный челлендж (вызывается при новом дне)
  Future<void> resetDailyChallengeIfNeeded() async {
    if (!isDailyChallengeCompletedToday() && state.dailyChallengeCompleted) {
      state = state.copyWith(dailyChallengeCompleted: false);
      await _save();
    }
  }
}

class AchievementsNotifier
    extends StateNotifier<Map<AchievementType, Achievement>> {
  static const _key = 'achievements';

  AchievementsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);

    // Инициализируем все достижения
    final achievements = <AchievementType, Achievement>{};
    for (var type in AchievementType.values) {
      achievements[type] = Achievement(type: type);
    }

    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        for (var entry in data.entries) {
          final index = int.tryParse(entry.key);
          if (index != null && index < AchievementType.values.length) {
            final type = AchievementType.values[index];
            final achievementData = entry.value as Map<String, dynamic>;
            achievements[type] = Achievement(
              type: type,
              unlocked: achievementData['unlocked'] as bool? ?? false,
              unlockedAt: achievementData['unlockedAt'] != null
                  ? DateTime.parse(achievementData['unlockedAt'] as String)
                  : null,
            );
          }
        }
      } catch (e) {
        // Игнорируем ошибки
      }
    }

    state = achievements;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (var entry in state.entries) {
      data[entry.key.index.toString()] = {
        'unlocked': entry.value.unlocked,
        'unlockedAt': entry.value.unlockedAt?.toIso8601String(),
      };
    }
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Разблокирует достижение
  Future<bool> unlock(AchievementType type) async {
    if (state[type]?.unlocked == true) return false;

    state = {
      ...state,
      type: Achievement(type: type, unlocked: true, unlockedAt: DateTime.now()),
    };
    await _save();
    return true;
  }

  /// Проверяет и разблокирует достижения после победы
  Future<List<AchievementType>> checkAchievements({
    required int totalWins,
    required Map<Difficulty, int> winsByDifficulty,
    required Duration gameTime,
    required int mistakes,
    required int hintsUsed,
    required bool isHardcore,
    required int currentStreak,
  }) async {
    final unlocked = <AchievementType>[];

    // Первая победа
    if (totalWins >= 1 && await unlock(AchievementType.firstWin)) {
      unlocked.add(AchievementType.firstWin);
    }

    // Победы
    if (totalWins >= 10 && await unlock(AchievementType.wins10)) {
      unlocked.add(AchievementType.wins10);
    }
    if (totalWins >= 50 && await unlock(AchievementType.wins50)) {
      unlocked.add(AchievementType.wins50);
    }
    if (totalWins >= 100 && await unlock(AchievementType.wins100)) {
      unlocked.add(AchievementType.wins100);
    }

    // Мастера уровней
    if ((winsByDifficulty[Difficulty.easy] ?? 0) >= 10 &&
        await unlock(AchievementType.easyMaster)) {
      unlocked.add(AchievementType.easyMaster);
    }
    if ((winsByDifficulty[Difficulty.medium] ?? 0) >= 10 &&
        await unlock(AchievementType.mediumMaster)) {
      unlocked.add(AchievementType.mediumMaster);
    }
    if ((winsByDifficulty[Difficulty.hard] ?? 0) >= 10 &&
        await unlock(AchievementType.hardMaster)) {
      unlocked.add(AchievementType.hardMaster);
    }
    if ((winsByDifficulty[Difficulty.expert] ?? 0) >= 10 &&
        await unlock(AchievementType.expertMaster)) {
      unlocked.add(AchievementType.expertMaster);
    }

    // Скоростной (меньше 3 минут)
    if (gameTime.inMinutes < 3 && await unlock(AchievementType.speedDemon)) {
      unlocked.add(AchievementType.speedDemon);
    }

    // Безупречный (без ошибок)
    if (mistakes == 0 && await unlock(AchievementType.perfectGame)) {
      unlocked.add(AchievementType.perfectGame);
    }

    // Без подсказок
    if (hintsUsed == 0 && await unlock(AchievementType.noHints)) {
      unlocked.add(AchievementType.noHints);
    }

    // Хардкор
    if (isHardcore && await unlock(AchievementType.hardcoreSurvivor)) {
      unlocked.add(AchievementType.hardcoreSurvivor);
    }

    // Серии
    if (currentStreak >= 3 && await unlock(AchievementType.streak3)) {
      unlocked.add(AchievementType.streak3);
    }
    if (currentStreak >= 7 && await unlock(AchievementType.streak7)) {
      unlocked.add(AchievementType.streak7);
    }
    if (currentStreak >= 30 && await unlock(AchievementType.streak30)) {
      unlocked.add(AchievementType.streak30);
    }

    return unlocked;
  }

  int get unlockedCount => state.values.where((a) => a.unlocked).length;
  int get totalCount => AchievementType.values.length;
}

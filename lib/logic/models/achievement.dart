import 'package:flutter/material.dart';

/// Достижения игрока
enum AchievementType {
  firstWin, // Первая победа
  wins10, // 10 побед
  wins50, // 50 побед
  wins100, // 100 побед
  easyMaster, // 10 побед на лёгком
  mediumMaster, // 10 побед на среднем
  hardMaster, // 10 побед на сложном
  expertMaster, // 10 побед на эксперте
  speedDemon, // Решить за 3 минуты
  perfectGame, // Без ошибок
  streak3, // 3 дня подряд
  streak7, // 7 дней подряд
  streak30, // 30 дней подряд
  noHints, // Победа без подсказок
  hardcoreSurvivor, // Победа в хардкор режиме
}

extension AchievementExtension on AchievementType {
  String get title {
    switch (this) {
      case AchievementType.firstWin:
        return 'Первые шаги';
      case AchievementType.wins10:
        return 'Начинающий';
      case AchievementType.wins50:
        return 'Опытный';
      case AchievementType.wins100:
        return 'Ветеран';
      case AchievementType.easyMaster:
        return 'Мастер лёгкого';
      case AchievementType.mediumMaster:
        return 'Мастер среднего';
      case AchievementType.hardMaster:
        return 'Мастер сложного';
      case AchievementType.expertMaster:
        return 'Мастер эксперта';
      case AchievementType.speedDemon:
        return 'Скоростной';
      case AchievementType.perfectGame:
        return 'Безупречный';
      case AchievementType.streak3:
        return 'Три дня подряд';
      case AchievementType.streak7:
        return 'Неделя подряд';
      case AchievementType.streak30:
        return 'Месяц подряд';
      case AchievementType.noHints:
        return 'Без подсказок';
      case AchievementType.hardcoreSurvivor:
        return 'Выживший';
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstWin:
        return 'Решите первую головоломку';
      case AchievementType.wins10:
        return 'Решите 10 головоломок';
      case AchievementType.wins50:
        return 'Решите 50 головоломок';
      case AchievementType.wins100:
        return 'Решите 100 головоломок';
      case AchievementType.easyMaster:
        return '10 побед на лёгком уровне';
      case AchievementType.mediumMaster:
        return '10 побед на среднем уровне';
      case AchievementType.hardMaster:
        return '10 побед на сложном уровне';
      case AchievementType.expertMaster:
        return '10 побед на уровне эксперт';
      case AchievementType.speedDemon:
        return 'Решите головоломку за 3 минуты';
      case AchievementType.perfectGame:
        return 'Победа без единой ошибки';
      case AchievementType.streak3:
        return 'Играйте 3 дня подряд';
      case AchievementType.streak7:
        return 'Играйте 7 дней подряд';
      case AchievementType.streak30:
        return 'Играйте 30 дней подряд';
      case AchievementType.noHints:
        return 'Победа без использования подсказок';
      case AchievementType.hardcoreSurvivor:
        return 'Победа в хардкор режиме';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementType.firstWin:
        return Icons.flag;
      case AchievementType.wins10:
        return Icons.star_outline;
      case AchievementType.wins50:
        return Icons.star_half;
      case AchievementType.wins100:
        return Icons.star;
      case AchievementType.easyMaster:
        return Icons.looks_one;
      case AchievementType.mediumMaster:
        return Icons.looks_two;
      case AchievementType.hardMaster:
        return Icons.looks_3;
      case AchievementType.expertMaster:
        return Icons.workspace_premium;
      case AchievementType.speedDemon:
        return Icons.bolt;
      case AchievementType.perfectGame:
        return Icons.diamond;
      case AchievementType.streak3:
        return Icons.local_fire_department;
      case AchievementType.streak7:
        return Icons.whatshot;
      case AchievementType.streak30:
        return Icons.emoji_events;
      case AchievementType.noHints:
        return Icons.psychology;
      case AchievementType.hardcoreSurvivor:
        return Icons.shield;
    }
  }

  int get xpReward {
    switch (this) {
      case AchievementType.firstWin:
        return 10;
      case AchievementType.wins10:
        return 50;
      case AchievementType.wins50:
        return 200;
      case AchievementType.wins100:
        return 500;
      case AchievementType.easyMaster:
        return 30;
      case AchievementType.mediumMaster:
        return 50;
      case AchievementType.hardMaster:
        return 100;
      case AchievementType.expertMaster:
        return 200;
      case AchievementType.speedDemon:
        return 100;
      case AchievementType.perfectGame:
        return 50;
      case AchievementType.streak3:
        return 30;
      case AchievementType.streak7:
        return 100;
      case AchievementType.streak30:
        return 500;
      case AchievementType.noHints:
        return 50;
      case AchievementType.hardcoreSurvivor:
        return 150;
    }
  }
}

class Achievement {
  final AchievementType type;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return Achievement(
      type: type,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

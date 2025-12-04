import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/progress_provider.dart';
import '../../logic/models/achievement.dart';

/// Экран достижений
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final progress = ref.watch(progressProvider);
    final unlockedCount = achievements.values.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Прогресс игрока
          _PlayerProgressCard(progress: progress),

          const SizedBox(height: 24),

          // Счётчик достижений
          Row(
            children: [
              Text(
                'Достижения',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unlockedCount / ${AchievementType.values.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Список достижений
          ...AchievementType.values.map((type) {
            final achievement = achievements[type];
            return _AchievementCard(
              achievement: achievement ?? Achievement(type: type),
            );
          }),
        ],
      ),
    );
  }
}

class _PlayerProgressCard extends StatelessWidget {
  final dynamic progress;

  const _PlayerProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Уровень
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${progress.level}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.levelTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.totalXp} XP',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Прогресс бар
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'До следующего уровня',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${progress.totalXp - progress.xpForCurrentLevel} / ${progress.xpForNextLevel - progress.xpForCurrentLevel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.levelProgress,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Серия дней
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.local_fire_department,
                  value: '${progress.currentStreak}',
                  label: 'Текущая серия',
                ),
                _StatColumn(
                  icon: Icons.emoji_events,
                  value: '${progress.bestStreak}',
                  label: 'Лучшая серия',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = achievement.unlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnlocked ? null : (isDark ? Colors.grey[900] : Colors.grey[100]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Иконка
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Theme.of(context).colorScheme.primaryContainer
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? achievement.type.icon : Icons.lock,
                  size: 24,
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.type.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? null
                          : (isDark ? Colors.grey[600] : Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.type.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6)
                          : (isDark ? Colors.grey[700] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),

            // XP награда
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${achievement.type.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

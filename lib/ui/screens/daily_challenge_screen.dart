import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/daily_challenge_provider.dart';
import '../../logic/providers/progress_provider.dart';
import '../../logic/providers/game_provider.dart';
import '../../logic/models/game_state.dart';
import 'game_screen.dart';

/// Экран ежедневного челленджа
class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyService = ref.watch(dailyChallengeProvider);
    final progress = ref.watch(progressProvider);
    final isCompleted = ref
        .read(progressProvider.notifier)
        .isDailyChallengeCompletedToday();

    return Scaffold(
      appBar: AppBar(title: const Text('Ежедневный челлендж')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Иконка календаря
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${DateTime.now().day}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getMonthName(DateTime.now().month),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              dailyService.getDayName(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Сложность: ${dailyService.getDailyDifficulty().displayName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 32),

            // Серия дней
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: '🔥',
                      value: '${progress.currentStreak}',
                      label: 'дней подряд',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).dividerColor,
                    ),
                    _StatItem(
                      icon: '🏆',
                      value: '${progress.bestStreak}',
                      label: 'лучшая серия',
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Статус / Кнопка
            if (isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Сегодня выполнено!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startDailyChallenge(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Начать челлендж',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Text(
              'Новый челлендж каждый день в полночь',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _startDailyChallenge(BuildContext context, WidgetRef ref) {
    final dailyService = ref.read(dailyChallengeProvider);
    final board = dailyService.generateDailyPuzzle();
    final difficulty = dailyService.getDailyDifficulty();

    // Создаём игру напрямую через провайдер
    ref.read(gameProvider.notifier).startDailyChallenge(board, difficulty);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GameScreen(isDailyChallenge: true),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];
    return months[month];
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

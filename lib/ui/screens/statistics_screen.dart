import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/statistics_provider.dart';
import '../../logic/models/game_state.dart';

/// Экран статистики
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            onPressed: () => _showResetDialog(context, ref),
            icon: const Icon(Icons.refresh),
            tooltip: 'Сбросить статистику',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Общая статистика
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  Text(
                    '${stats.totalWins}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'Всего побед',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'По уровням сложности',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 16),

          // Статистика по уровням
          ...Difficulty.values.map((difficulty) {
            final diffStats = stats.stats[difficulty];
            if (diffStats == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          difficulty.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${diffStats.gamesWon} побед',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.timer,
                            label: 'Лучшее время',
                            value: diffStats.gamesWon > 0
                                ? _formatDuration(diffStats.bestTime)
                                : '-',
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.schedule,
                            label: 'Среднее время',
                            value: diffStats.gamesWon > 0
                                ? _formatDuration(diffStats.averageTime)
                                : '-',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить статистику?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(statisticsProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 99) return '-';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

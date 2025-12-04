import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/models/game_state.dart';
import '../../logic/providers/game_provider.dart';
import 'game_screen.dart';

/// Экран выбора режима "На время"
class TimedModeScreen extends ConsumerWidget {
  const TimedModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Режим на время')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.timer, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Успей решить!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Выбери время и сложность',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // 10 минут
                  _buildSection(context, '10 минут', [
                    _TimeLimitCard(
                      minutes: 10,
                      difficulty: Difficulty.easy,
                      bonusXp: 20,
                      onTap: () =>
                          _startGame(context, ref, 10, Difficulty.easy),
                    ),
                    _TimeLimitCard(
                      minutes: 10,
                      difficulty: Difficulty.medium,
                      bonusXp: 40,
                      onTap: () =>
                          _startGame(context, ref, 10, Difficulty.medium),
                    ),
                    _TimeLimitCard(
                      minutes: 10,
                      difficulty: Difficulty.hard,
                      bonusXp: 60,
                      onTap: () =>
                          _startGame(context, ref, 10, Difficulty.hard),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // 5 минут
                  _buildSection(context, '5 минут', [
                    _TimeLimitCard(
                      minutes: 5,
                      difficulty: Difficulty.easy,
                      bonusXp: 50,
                      onTap: () => _startGame(context, ref, 5, Difficulty.easy),
                    ),
                    _TimeLimitCard(
                      minutes: 5,
                      difficulty: Difficulty.medium,
                      bonusXp: 80,
                      onTap: () =>
                          _startGame(context, ref, 5, Difficulty.medium),
                    ),
                    _TimeLimitCard(
                      minutes: 5,
                      difficulty: Difficulty.hard,
                      bonusXp: 120,
                      onTap: () => _startGame(context, ref, 5, Difficulty.hard),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // 3 минуты
                  _buildSection(context, '3 минуты', [
                    _TimeLimitCard(
                      minutes: 3,
                      difficulty: Difficulty.easy,
                      bonusXp: 100,
                      onTap: () => _startGame(context, ref, 3, Difficulty.easy),
                    ),
                    _TimeLimitCard(
                      minutes: 3,
                      difficulty: Difficulty.medium,
                      bonusXp: 150,
                      onTap: () =>
                          _startGame(context, ref, 3, Difficulty.medium),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // 2 минуты - экстрим
                  _buildSection(context, '2 минуты ⚡', [
                    _TimeLimitCard(
                      minutes: 2,
                      difficulty: Difficulty.easy,
                      bonusXp: 200,
                      onTap: () => _startGame(context, ref, 2, Difficulty.easy),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...cards.map(
          (card) =>
              Padding(padding: const EdgeInsets.only(bottom: 8), child: card),
        ),
      ],
    );
  }

  void _startGame(
    BuildContext context,
    WidgetRef ref,
    int minutes,
    Difficulty difficulty,
  ) {
    ref
        .read(gameProvider.notifier)
        .startNewGame(
          difficulty,
          mode: GameMode.timed,
          timeLimit: Duration(minutes: minutes),
        );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _TimeLimitCard extends StatelessWidget {
  final int minutes;
  final Difficulty difficulty;
  final int bonusXp;
  final VoidCallback onTap;

  const _TimeLimitCard({
    required this.minutes,
    required this.difficulty,
    required this.bonusXp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor(difficulty);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.timer, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '+$bonusXp XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }
}

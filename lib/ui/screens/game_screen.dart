import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/game_provider.dart';
import '../../logic/providers/sound_provider.dart';
import '../../logic/models/game_state.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_timer.dart';

/// Экран игры
class GameScreen extends ConsumerStatefulWidget {
  final bool isDailyChallenge;

  const GameScreen({super.key, this.isDailyChallenge = false});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _dialogShown = false;
  bool _lastHasError = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final sound = ref.watch(soundServiceProvider);

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Звук при ошибке
    if (gameState.hasError && !_lastHasError) {
      sound.playError();
    }
    _lastHasError = gameState.hasError;

    // Показываем диалог победы или проигрыша
    if ((gameState.isCompleted || gameState.isGameOver) && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (gameState.isCompleted) {
          sound.playWin();
          _showWinDialog(context, gameState, widget.isDailyChallenge);
        } else if (gameState.isTimeUp) {
          _showTimeUpDialog(context, gameState);
        } else {
          _showGameOverDialog(context, gameState);
        }
      });
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(gameProvider.notifier).pauseTimer();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gameState.difficulty.displayName),
              if (gameState.gameMode == GameMode.hardcore) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('💀', style: TextStyle(fontSize: 14)),
                ),
              ],
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              sound.playTap();
              ref.read(gameProvider.notifier).pauseTimer();
              Navigator.pop(context);
            },
          ),
          actions: [
            if (gameState.gameMode == GameMode.normal)
              IconButton(
                onPressed: () {
                  sound.playTap();
                  ref.read(gameProvider.notifier).toggleShowErrors();
                },
                icon: Icon(
                  gameState.showErrors
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                tooltip: 'Показывать ошибки',
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                // Таймер и информация - компактно
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RepaintBoundary(
                        child: gameState.gameMode == GameMode.timed
                            ? _TimedModeTimer(
                                remaining: gameState.remainingTime,
                                total:
                                    gameState.timeLimit ??
                                    const Duration(minutes: 5),
                              )
                            : GameTimer(elapsed: gameState.elapsedTime),
                      ),
                      RepaintBoundary(child: _buildStats(context, gameState)),
                    ],
                  ),
                ),

                // Игровое поле - максимально большое
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SudokuBoard(
                          board: gameState.board,
                          hasError: gameState.hasError,
                          onCellTap: (row, col) {
                            sound.playSelect();
                            ref
                                .read(gameProvider.notifier)
                                .selectCell(row, col);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Панель управления - компактнее
                GameControls(
                  isPencilMode: gameState.isPencilMode,
                  onUndo: () {
                    sound.playTap();
                    ref.read(gameProvider.notifier).undo();
                  },
                  onClear: () {
                    sound.playTap();
                    ref.read(gameProvider.notifier).clearCell();
                  },
                  onHint: () {
                    sound.playCorrect();
                    ref.read(gameProvider.notifier).hint();
                  },
                  onPencilToggle: () {
                    sound.playTap();
                    ref.read(gameProvider.notifier).togglePencilMode();
                  },
                ),

                const SizedBox(height: 8),

                // Цифровая панель - увеличенная
                SizedBox(
                  height: 56,
                  child: NumberPad(
                    selectedNumber: gameState.selectedNumber,
                    board: gameState.board,
                    onNumberTap: (number) {
                      sound.playTap();
                      ref.read(gameProvider.notifier).enterNumber(number);
                    },
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, GameState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    if (state.gameMode == GameMode.hardcore) {
      return Row(
        children: List.generate(state.maxMistakes, (index) {
          final isLost = index < state.mistakes;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isLost ? Icons.favorite_border : Icons.favorite,
                key: ValueKey('heart_${index}_$isLost'),
                size: 22,
                color: isLost ? textColor : Colors.red,
              ),
            ),
          );
        }),
      );
    }

    return Row(
      children: [
        Icon(Icons.close, size: 18, color: textColor),
        const SizedBox(width: 4),
        Text(
          '${state.mistakes}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.lightbulb_outline, size: 18, color: textColor),
        const SizedBox(width: 4),
        Text(
          '${state.hintsUsed}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showWinDialog(
    BuildContext context,
    GameState state,
    bool isDailyChallenge,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Text(isDailyChallenge ? 'Челлендж пройден!' : 'Победа! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow(
              icon: Icons.speed,
              label: 'Уровень',
              value: state.difficulty.displayName,
            ),
            _StatRow(
              icon: Icons.timer,
              label: 'Время',
              value: _formatDuration(state.elapsedTime),
            ),
            _StatRow(
              icon: Icons.close,
              label: 'Ошибок',
              value: '${state.mistakes}',
            ),
            _StatRow(
              icon: Icons.lightbulb,
              label: 'Подсказок',
              value: '${state.hintsUsed}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('На главную'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Игра окончена'),
          ],
        ),
        content: const Text('Вы исчерпали все жизни. Попробуйте ещё раз!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('На главную'),
          ),
        ],
      ),
    );
  }

  void _showTimeUpDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.timer_off,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Время вышло!'),
          ],
        ),
        content: const Text(
          'Не успели решить головоломку. Попробуйте ещё раз!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('На главную'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Таймер обратного отсчёта для режима "На время"
class _TimedModeTimer extends StatelessWidget {
  final Duration remaining;
  final Duration total;

  const _TimedModeTimer({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final isLow = remaining.inSeconds <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
              ? [Colors.red.shade400, Colors.orange]
              : [Colors.orange, Colors.amber],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow ? Icons.warning_rounded : Icons.timer,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

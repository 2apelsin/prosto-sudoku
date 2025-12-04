import 'package:flutter/material.dart';
import '../../logic/models/game_state.dart';

/// Селектор уровня сложности и режима игры
class DifficultySelector extends StatefulWidget {
  final Function(Difficulty, GameMode) onSelect;

  const DifficultySelector({super.key, required this.onSelect});

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  GameMode _selectedMode = GameMode.normal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Новая игра',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 20),

              // Выбор режима
              _ModeSelector(
                selectedMode: _selectedMode,
                onModeChanged: (mode) => setState(() => _selectedMode = mode),
              ),

              const SizedBox(height: 24),

              Text(
                'Выберите сложность',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 16),

              ...Difficulty.values.map((difficulty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DifficultyCard(
                    difficulty: difficulty,
                    onTap: () => widget.onSelect(difficulty, _selectedMode),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final Function(GameMode) onModeChanged;

  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  // Только обычный и хардкор режимы (на время - отдельная кнопка на главном экране)
  static const _availableModes = [GameMode.normal, GameMode.hardcore];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _availableModes.map((mode) {
          final isSelected = mode == selectedMode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      mode.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final VoidCallback onTap;

  const _DifficultyCard({required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _getDifficultyColors(difficulty, context);

    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.icon.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDifficultyIcon(difficulty),
                  color: colors.icon,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.displayName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDifficultyDescription(difficulty),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.text.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case Difficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case Difficulty.hard:
        return Icons.sentiment_dissatisfied_rounded;
      case Difficulty.expert:
        return Icons.local_fire_department_rounded;
    }
  }

  String _getDifficultyDescription(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Для начинающих';
      case Difficulty.medium:
        return 'Требует внимания';
      case Difficulty.hard:
        return 'Для опытных игроков';
      case Difficulty.expert:
        return 'Максимальный вызов';
    }
  }

  _DifficultyColors _getDifficultyColors(Difficulty d, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (d) {
      case Difficulty.easy:
        return _DifficultyColors(
          background: isDark
              ? const Color(0xFF1A3D2E)
              : const Color(0xFFE8F5E9),
          icon: const Color(0xFF4CAF50),
          text: isDark ? Colors.white : const Color(0xFF1B5E20),
        );
      case Difficulty.medium:
        return _DifficultyColors(
          background: isDark
              ? const Color(0xFF3D3A1A)
              : const Color(0xFFFFF8E1),
          icon: const Color(0xFFFFC107),
          text: isDark ? Colors.white : const Color(0xFFF57F17),
        );
      case Difficulty.hard:
        return _DifficultyColors(
          background: isDark
              ? const Color(0xFF3D2A1A)
              : const Color(0xFFFBE9E7),
          icon: const Color(0xFFFF5722),
          text: isDark ? Colors.white : const Color(0xFFBF360C),
        );
      case Difficulty.expert:
        return _DifficultyColors(
          background: isDark
              ? const Color(0xFF3D1A2A)
              : const Color(0xFFFCE4EC),
          icon: const Color(0xFFE91E63),
          text: isDark ? Colors.white : const Color(0xFF880E4F),
        );
    }
  }
}

class _DifficultyColors {
  final Color background;
  final Color icon;
  final Color text;

  _DifficultyColors({
    required this.background,
    required this.icon,
    required this.text,
  });
}

import 'package:flutter/material.dart';

/// Оптимизированная панель управления игрой
class GameControls extends StatelessWidget {
  final bool isPencilMode;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onHint;
  final VoidCallback onPencilToggle;

  const GameControls({
    super.key,
    required this.isPencilMode,
    required this.onUndo,
    required this.onClear,
    required this.onHint,
    required this.onPencilToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: Icons.undo_rounded,
              label: 'Отмена',
              isDark: isDark,
              primaryColor: primaryColor,
              onTap: onUndo,
            ),
            _ControlButton(
              icon: Icons.backspace_outlined,
              label: 'Стереть',
              isDark: isDark,
              primaryColor: primaryColor,
              onTap: onClear,
            ),
            _ControlButton(
              icon: isPencilMode ? Icons.edit : Icons.edit_outlined,
              label: 'Заметки',
              isActive: isPencilMode,
              isDark: isDark,
              primaryColor: primaryColor,
              onTap: onPencilToggle,
            ),
            _ControlButton(
              icon: Icons.lightbulb_outline,
              label: 'Подсказка',
              isDark: isDark,
              primaryColor: primaryColor,
              onTap: onHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDark;
  final Color primaryColor;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.primaryColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? primaryColor
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

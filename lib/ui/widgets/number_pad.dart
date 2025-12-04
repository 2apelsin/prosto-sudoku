import 'package:flutter/material.dart';
import '../../logic/models/sudoku_cell.dart';

/// Оптимизированная цифровая панель 1-9
class NumberPad extends StatelessWidget {
  final Function(int) onNumberTap;
  final int? selectedNumber;
  final List<List<SudokuCell>>? board;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    this.selectedNumber,
    this.board,
  });

  int _countNumber(int number) {
    if (board == null) return 0;
    int count = 0;
    for (var row in board!) {
      for (var cell in row) {
        if (cell.value == number) count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: Row(
        children: List.generate(9, (index) {
          final number = index + 1;
          final isSelected = selectedNumber == number;
          final count = _countNumber(number);
          final isCompleted = count >= 9;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _NumberButton(
                number: number,
                isSelected: isSelected,
                isCompleted: isCompleted,
                remainingCount: 9 - count,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => onNumberTap(number),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final bool isSelected;
  final bool isCompleted;
  final int remainingCount;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.isSelected,
    required this.isCompleted,
    required this.remainingCount,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedColor = isDark
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);
    final completedTextColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);
    final normalBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final normalText = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF1E293B);

    Color bgColor;
    Color textColor;

    if (isCompleted) {
      bgColor = completedColor;
      textColor = completedTextColor;
    } else if (isSelected) {
      bgColor = primaryColor;
      textColor = Colors.white;
    } else {
      bgColor = normalBg;
      textColor = normalText;
    }

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (!isCompleted && remainingCount < 9)
              Positioned(
                top: 2,
                right: 4,
                child: Text(
                  '$remainingCount',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white70
                        : primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            if (isCompleted)
              Positioned(
                top: 2,
                right: 3,
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: isDark
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFF22C55E),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

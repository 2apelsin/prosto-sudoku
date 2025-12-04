import 'package:flutter/material.dart';
import '../../logic/models/sudoku_cell.dart';
import '../theme/app_theme.dart';

/// Оптимизированное игровое поле 9x9
class SudokuBoard extends StatefulWidget {
  final List<List<SudokuCell>> board;
  final Function(int row, int col) onCellTap;
  final bool hasError;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.onCellTap,
    this.hasError = false,
  });

  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

class _SudokuBoardState extends State<SudokuBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: 3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 3, end: -2), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -2, end: 1), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(SudokuBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? SudokuColors.blockBorderDark
                  : SudokuColors.blockBorder,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _BoardGrid(
              board: widget.board,
              onCellTap: widget.onCellTap,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Сетка доски - отдельный виджет для оптимизации
class _BoardGrid extends StatelessWidget {
  final List<List<SudokuCell>> board;
  final Function(int row, int col) onCellTap;
  final bool isDark;

  const _BoardGrid({
    required this.board,
    required this.onCellTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(9, (row) {
        return Expanded(
          child: Row(
            children: List.generate(9, (col) {
              return Expanded(
                child: RepaintBoundary(
                  child: _OptimizedCell(
                    cell: board[row][col],
                    row: row,
                    col: col,
                    isDark: isDark,
                    onTap: () => onCellTap(row, col),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/// Оптимизированная ячейка без лишних анимаций
class _OptimizedCell extends StatelessWidget {
  final SudokuCell cell;
  final int row;
  final int col;
  final bool isDark;
  final VoidCallback onTap;

  const _OptimizedCell({
    required this.cell,
    required this.row,
    required this.col,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final borderRight = (col + 1) % 3 == 0 && col < 8 ? 2.0 : 0.5;
    final borderBottom = (row + 1) % 3 == 0 && row < 8 ? 2.0 : 0.5;

    final borderColor = isDark
        ? SudokuColors.gridLineDark
        : SudokuColors.gridLine;
    final blockBorderColor = isDark
        ? SudokuColors.blockBorderDark
        : SudokuColors.blockBorder;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(
              color: borderRight > 1 ? blockBorderColor : borderColor,
              width: borderRight,
            ),
            bottom: BorderSide(
              color: borderBottom > 1 ? blockBorderColor : borderColor,
              width: borderBottom,
            ),
          ),
        ),
        child: Center(
          child: cell.isEmpty ? _buildNotes() : _buildValue(textColor),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (cell.isSelected) {
      return isDark ? SudokuColors.selectedCellDark : SudokuColors.selectedCell;
    }
    if (cell.isSameNumber) {
      return isDark ? SudokuColors.sameNumberDark : SudokuColors.sameNumber;
    }
    if (cell.isHighlighted) {
      return isDark
          ? SudokuColors.highlightedCellDark
          : SudokuColors.highlightedCell;
    }
    return isDark
        ? SudokuColors.cellBackgroundDark
        : SudokuColors.cellBackground;
  }

  Color _getTextColor() {
    if (cell.isError) return SudokuColors.errorText;
    if (cell.isFixed) {
      return isDark ? SudokuColors.fixedTextDark : SudokuColors.fixedText;
    }
    return isDark ? SudokuColors.inputTextDark : SudokuColors.inputText;
  }

  Widget _buildValue(Color textColor) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '${cell.value}',
        style: TextStyle(
          fontSize: cell.isSelected ? 32 : 28,
          fontWeight: cell.isFixed ? FontWeight.w700 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildNotes() {
    if (cell.notes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          final number = index + 1;
          final hasNote = cell.notes.contains(number);
          return Center(
            child: hasNote
                ? Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? SudokuColors.notesTextDark
                          : SudokuColors.notesText,
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }
}

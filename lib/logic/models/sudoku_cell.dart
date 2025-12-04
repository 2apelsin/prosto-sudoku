import 'package:equatable/equatable.dart';

/// Модель клетки судоку
class SudokuCell extends Equatable {
  final int value; // Текущее значение (0 = пусто)
  final int solution; // Правильный ответ
  final bool isFixed; // Изначально заполненная клетка
  final bool isError; // Ошибка ввода
  final Set<int> notes; // Пометки (pencil mode)
  final bool isSelected; // Выбрана ли клетка
  final bool isHighlighted; // Подсветка (строка/столбец/блок)
  final bool isSameNumber; // Подсветка одинаковых цифр

  const SudokuCell({
    this.value = 0,
    this.solution = 0,
    this.isFixed = false,
    this.isError = false,
    this.notes = const {},
    this.isSelected = false,
    this.isHighlighted = false,
    this.isSameNumber = false,
  });

  SudokuCell copyWith({
    int? value,
    int? solution,
    bool? isFixed,
    bool? isError,
    Set<int>? notes,
    bool? isSelected,
    bool? isHighlighted,
    bool? isSameNumber,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      solution: solution ?? this.solution,
      isFixed: isFixed ?? this.isFixed,
      isError: isError ?? this.isError,
      notes: notes ?? this.notes,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isSameNumber: isSameNumber ?? this.isSameNumber,
    );
  }

  bool get isEmpty => value == 0;
  bool get isCorrect => value == solution;

  @override
  List<Object?> get props => [
    value,
    solution,
    isFixed,
    isError,
    notes,
    isSelected,
    isHighlighted,
    isSameNumber,
  ];
}

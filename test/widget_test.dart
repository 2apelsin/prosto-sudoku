import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prosto_sudoku/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SudokuApp()));

    // Проверяем что главный экран загрузился
    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('Новая игра'), findsOneWidget);
  });
}

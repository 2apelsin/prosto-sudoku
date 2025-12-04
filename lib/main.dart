import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart';
import 'logic/providers/theme_provider.dart';
import 'logic/providers/app_theme_provider.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Фиксируем ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: SudokuApp()));
}

class SudokuApp extends ConsumerWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'Просто Судоку',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(appTheme, false),
      darkTheme: AppTheme.getTheme(appTheme, true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

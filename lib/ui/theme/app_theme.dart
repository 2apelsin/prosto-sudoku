import 'package:flutter/material.dart';
import '../../logic/models/app_theme.dart';

/// Темы приложения в стиле Material 3
class AppTheme {
  /// Генерирует тему на основе выбранной цветовой схемы
  static ThemeData getTheme(AppThemeType appTheme, bool isDark) {
    final primaryColor = appTheme.primaryColor;
    final secondaryColor = appTheme.secondaryColor;

    final backgroundColor = isDark
        ? appTheme.backgroundColorDark
        : appTheme.backgroundColor;
    final cardColor = isDark ? appTheme.cardColorDark : appTheme.cardColor;
    final textColor = isDark ? appTheme.textColorDark : appTheme.textColor;
    final subtextColor = isDark
        ? appTheme.subtextColorDark
        : appTheme.subtextColor;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        }),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: subtextColor),
        bodyMedium: TextStyle(fontSize: 14, color: subtextColor),
      ),
    );
  }

  static ThemeData get lightTheme => getTheme(AppThemeType.classic, false);
  static ThemeData get darkTheme => getTheme(AppThemeType.classic, true);
}

/// Цвета для игрового поля
class SudokuColors {
  static const cellBackground = Color(0xFFFFFFFF);
  static const cellBackgroundDark = Color(0xFF1E293B);

  static const selectedCell = Color(0xFFBBDEFB);
  static const selectedCellDark = Color(0xFF1E3A5F);

  static const highlightedCell = Color(0xFFE8EEF4);
  static const highlightedCellDark = Color(0xFF172554);

  static const sameNumber = Color(0xFFDDD6FE);
  static const sameNumberDark = Color(0xFF3730A3);

  static const fixedText = Color(0xFF1E293B);
  static const fixedTextDark = Color(0xFFF1F5F9);

  static const inputText = Color(0xFF6366F1);
  static const inputTextDark = Color(0xFF818CF8);

  static const errorText = Color(0xFFEF4444);

  static const notesText = Color(0xFF64748B);
  static const notesTextDark = Color(0xFF94A3B8);

  static const gridLine = Color(0xFFE2E8F0);
  static const gridLineDark = Color(0xFF334155);

  static const blockBorder = Color(0xFF1E293B);
  static const blockBorderDark = Color(0xFF94A3B8);
}

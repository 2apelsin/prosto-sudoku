import 'package:flutter/material.dart';

/// Темы оформления приложения
enum AppThemeType {
  classic, // Классика (фиолетовый)
  ocean, // Океан (голубой)
  sunset, // Закат (оранжевый)
  forest, // Лес (зелёный)
  rose, // Роза (розовый)
  midnight, // Полночь (тёмно-синий)
}

extension AppThemeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.classic:
        return 'Классика';
      case AppThemeType.ocean:
        return 'Океан';
      case AppThemeType.sunset:
        return 'Закат';
      case AppThemeType.forest:
        return 'Лес';
      case AppThemeType.rose:
        return 'Роза';
      case AppThemeType.midnight:
        return 'Полночь';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeType.classic:
        return Icons.auto_awesome;
      case AppThemeType.ocean:
        return Icons.water_drop;
      case AppThemeType.sunset:
        return Icons.wb_twilight;
      case AppThemeType.forest:
        return Icons.park;
      case AppThemeType.rose:
        return Icons.local_florist;
      case AppThemeType.midnight:
        return Icons.nightlight_round;
    }
  }

  bool get isFree => true;

  Color get primaryColor {
    switch (this) {
      case AppThemeType.classic:
        return const Color(0xFF6366F1);
      case AppThemeType.ocean:
        return const Color(0xFF0EA5E9);
      case AppThemeType.sunset:
        return const Color(0xFFF97316);
      case AppThemeType.forest:
        return const Color(0xFF22C55E);
      case AppThemeType.rose:
        return const Color(0xFFEC4899);
      case AppThemeType.midnight:
        return const Color(0xFF6366F1);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppThemeType.classic:
        return const Color(0xFF8B5CF6);
      case AppThemeType.ocean:
        return const Color(0xFF06B6D4);
      case AppThemeType.sunset:
        return const Color(0xFFEF4444);
      case AppThemeType.forest:
        return const Color(0xFF10B981);
      case AppThemeType.rose:
        return const Color(0xFFF472B6);
      case AppThemeType.midnight:
        return const Color(0xFF3B82F6);
    }
  }

  // Светлая тема
  Color get backgroundColor => const Color(0xFFF8FAFC);
  Color get cardColor => Colors.white;
  Color get textColor => const Color(0xFF1E293B);
  Color get subtextColor => const Color(0xFF64748B);

  // Тёмная тема
  Color get backgroundColorDark => const Color(0xFF0F172A);
  Color get cardColorDark => const Color(0xFF1E293B);
  Color get textColorDark => const Color(0xFFF1F5F9);
  Color get subtextColorDark => const Color(0xFF94A3B8);

  // Цвета для игрового поля
  Color get selectedCellColor => primaryColor.withValues(alpha: 0.25);
  Color get selectedCellColorDark => primaryColor.withValues(alpha: 0.35);

  Color get highlightColor => primaryColor.withValues(alpha: 0.08);
  Color get highlightColorDark => primaryColor.withValues(alpha: 0.15);

  Color get sameNumberColor => secondaryColor.withValues(alpha: 0.2);
  Color get sameNumberColorDark => secondaryColor.withValues(alpha: 0.3);
}

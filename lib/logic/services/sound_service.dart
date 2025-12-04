import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Сервис для вибрации (без звуков для простоты)
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _vibrationEnabled = true;
  bool _initialized = false;

  bool get vibrationEnabled => _vibrationEnabled;

  /// Инициализация - загружаем настройки
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final storage = StorageService();
    _vibrationEnabled = await storage.loadVibration();
  }

  /// Включить/выключить вибрацию
  Future<void> setVibration(bool enabled) async {
    _vibrationEnabled = enabled;
    final storage = StorageService();
    await storage.saveVibration(enabled);
  }

  /// Вибрация при нажатии
  void playTap() {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Вибрация при ошибке
  void playError() {
    if (_vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Вибрация при правильном вводе
  void playCorrect() {
    if (_vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Вибрация при победе
  void playWin() {
    if (_vibrationEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  /// Вибрация при выборе клетки
  void playSelect() {
    if (_vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }
}

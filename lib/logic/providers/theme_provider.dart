import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Провайдер темы (светлая/тёмная)
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  final _storage = StorageService();

  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    state = await _storage.loadTheme();
  }

  Future<void> toggle() async {
    state = !state;
    await _storage.saveTheme(state);
  }
}

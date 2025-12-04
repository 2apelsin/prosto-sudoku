import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

/// Провайдер выбранной темы оформления
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, AppThemeType>((
  ref,
) {
  return AppThemeNotifier();
});

/// Провайдер купленных тем
final purchasedThemesProvider =
    StateNotifierProvider<PurchasedThemesNotifier, Set<AppThemeType>>((ref) {
      return PurchasedThemesNotifier();
    });

class AppThemeNotifier extends StateNotifier<AppThemeType> {
  static const _key = 'selected_theme';

  AppThemeNotifier() : super(AppThemeType.classic) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    if (index < AppThemeType.values.length) {
      state = AppThemeType.values[index];
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
  }
}

class PurchasedThemesNotifier extends StateNotifier<Set<AppThemeType>> {
  static const _key = 'purchased_themes';

  PurchasedThemesNotifier() : super({AppThemeType.classic}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final indices = prefs.getStringList(_key) ?? [];
    final themes = <AppThemeType>{
      AppThemeType.classic,
    }; // Классика всегда бесплатна
    for (var indexStr in indices) {
      final index = int.tryParse(indexStr);
      if (index != null && index < AppThemeType.values.length) {
        themes.add(AppThemeType.values[index]);
      }
    }
    state = themes;
  }

  Future<void> purchase(AppThemeType theme) async {
    state = {...state, theme};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((t) => t.index.toString()).toList(),
    );
  }

  bool isOwned(AppThemeType theme) => state.contains(theme) || theme.isFree;
}

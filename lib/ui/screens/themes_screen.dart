import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/models/app_theme.dart';
import '../../logic/providers/app_theme_provider.dart';
import '../../logic/providers/theme_provider.dart';

/// Экран выбора темы оформления
class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Переключатель светлая/тёмная
          _DarkModeCard(isDark: isDark, ref: ref),

          const SizedBox(height: 28),

          Text('Цветовая схема', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Выберите любимый цвет',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Сетка тем
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: AppThemeType.values.length,
            itemBuilder: (context, index) {
              final theme = AppThemeType.values[index];
              final isSelected = theme == currentTheme;

              return _ThemeCard(
                theme: theme,
                isSelected: isSelected,
                onTap: () {
                  ref.read(appThemeProvider.notifier).setTheme(theme);
                },
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Карточка переключения тёмной темы
class _DarkModeCard extends StatelessWidget {
  final bool isDark;
  final WidgetRef ref;

  const _DarkModeCard({required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.blue : Colors.amber).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.indigo.withOpacity(0.3)
                    : Colors.amber.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.blue[200] : Colors.amber[700],
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Тёмная тема' : 'Светлая тема',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Нажмите чтобы переключить',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.swap_horiz_rounded,
              color: isDark ? Colors.white54 : Colors.amber[700],
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Контент
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(theme.icon, size: 28, color: Colors.white),
                  const Spacer(),
                  Text(
                    theme.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Галочка
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: theme.primaryColor,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

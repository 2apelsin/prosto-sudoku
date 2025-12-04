import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/services/storage_service.dart';
import 'home_screen.dart';

/// Экран обучения при первом запуске
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.grid_3x3_rounded,
      title: 'Добро пожаловать!',
      description:
          'Судоку — это логическая головоломка.\nЗаполните сетку 9×9 цифрами от 1 до 9.',
      color: Colors.blue,
    ),
    _OnboardingPage(
      icon: Icons.rule_rounded,
      title: 'Правила игры',
      description:
          'Каждая цифра должна встречаться\nтолько один раз в каждой строке,\nстолбце и блоке 3×3.',
      color: Colors.green,
    ),
    _OnboardingPage(
      icon: Icons.touch_app_rounded,
      title: 'Как играть',
      description:
          'Нажмите на клетку, затем выберите\nцифру внизу экрана.\nИспользуйте заметки для подсказок.',
      color: Colors.orange,
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Зарабатывайте награды',
      description:
          'Решайте головоломки, получайте опыт\nи открывайте достижения.\nУдачи!',
      color: Colors.purple,
    ),
  ];

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final storage = StorageService();
    await storage.setFirstLaunchComplete();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка пропустить
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Пропустить',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Страницы
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, isDark);
                },
              ),
            ),

            // Индикаторы и кнопка
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Точки-индикаторы
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _pages[_currentPage].color
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Кнопка далее/начать
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Начать игру'
                            : 'Далее',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),

          const SizedBox(height: 40),

          // Заголовок
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Описание
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

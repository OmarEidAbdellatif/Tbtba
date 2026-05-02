import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';

// شاشة الترحيب (Onboarding) - واجهة العرض الأولى للمستخدمين الجدد للتعريف بمميزات التطبيق
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController(); // متحكم في صفحات الترحيب
  int _currentPage = 0; // مؤشر الصفحة الحالية

  late AnimationController _floatController; // متحكم حركات الطفو للعناصر الرسومية
  late AnimationController _fadeController; // متحكم حركة الظهور التدريجي

  // بيانات صفحات الترحيب (العنوان، الوصف، اللون، والأيقونة)
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'أهلاً بك في طبطبة',
      description: 'بيتك الثاني ومجتمعك الذي ينبض بالحياة والدفء',
      color: const Color(0xFF6C63FF),
      icon: Icons.home_rounded,
    ),
    OnboardingData(
      title: 'تواصل مع أحبائك',
      description: 'افتح نوافذ التواصل مع عائلتك والأخصائيين بضغطة واحدة',
      color: const Color(0xFFec4899),
      icon: Icons.favorite_rounded,
    ),
    OnboardingData(
      title: 'صحتك في أمان',
      description: 'نظام ذكي يذكرك بمواعيد أدويتك ويتابع حالتك بدقة',
      color: const Color(0xFF10b981),
      icon: Icons.health_and_safety_rounded,
    ),
    OnboardingData(
      title: 'ابدأ رحلتك معنا',
      description: 'اختر هويتك وادخل عالم طبطبة المتكامل',
      color: const Color(0xFF3b82f6),
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة المؤثرات الحركية لضمان تجربة مستخدم ممتعة عند الدخول لأول مرة
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    // تنظيف الموارد عند الانتهاء من عرض شاشات الترحيب
    _pageController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // دالة الانتقال للصفحة التالية أو إنهاء الترحيب والذهاب لشاشة الدخول
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      // إبلاغ النظام بأن المستخدم أتم مشاهدة شاشات الترحيب
      ref.read(appRiverpod).completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildAnimatedBackground(), // خلفية متحركة بفقاعات لونية
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]); // بناء محتوى كل صفحة
                  },
                ),
              ),
              _buildFooter(), // شريط التنقل السفلي (المؤشرات وزر التالي)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: [
            _buildBlob(200, _pages[_currentPage].color.withOpacity(0.12), -50, 100, 1.2),
            _buildBlob(150, _pages[_currentPage].color.withOpacity(0.08), 250, -50, 1.5),
            _buildBlob(100, _pages[_currentPage].color.withOpacity(0.05), 50, 400, 1.8),
          ],
        );
      },
    );
  }

  Widget _buildBlob(double size, Color color, double right, double top, double speed) {
    final offset = sin(_floatController.value * pi * 2 * speed) * 15;
    return Positioned(
      right: right + offset,
      top: top + offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatarShape(data),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1e293b)),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Color(0xFF64748b), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarShape(OnboardingData data) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 15 * sin(_floatController.value * pi * 2)),
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Icon(data.icon, size: 80, color: data.color),
                ),
                ...List.generate(3, (i) {
                  final angle = (i * 120) * (pi / 180);
                  return Positioned(
                    right: 110 + 85 * cos(angle + _floatController.value * pi),
                    top: 110 + 85 * sin(angle + _floatController.value * pi),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(_pages.length, (index) {
              final isCurrent = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: isCurrent ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isCurrent ? _pages[_currentPage].color : const Color(0xFFcbd5e1),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: _pages[_currentPage].color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _pages[_currentPage].color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import '../../providers/app_riverpod.dart'; // استيراد مزود الحالة الرئيسي
import 'views/admin_home_view.dart'; // واجهة الإحصائيات العامة للمدير
import 'views/residents_management_view.dart'; // واجهة إدارة المقيمين
import 'views/staff_management_view.dart'; // واجهة إدارة طاقم العمل
import 'views/visit_approval_view.dart'; // واجهة مراجعة طلبات الزيارة
import '../specialist/views/complaints_view.dart'; // واجهة الشكاوى والاقتراحات للمدير
import 'views/admin_reports_view.dart'; // واجهة التقارير الإدارية والمالية
import '../../widgets/taptaba_drawer.dart'; // القائمة الجانبية الموحدة
import '../../widgets/taptaba_scaffold.dart'; // الهيكل الموحد للتطبيق

class AdminDashboardScreen extends ConsumerStatefulWidget {
  // شاشة لوحة تحكم المدير العام
  const AdminDashboardScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState(); // إنشاء حالة المكون
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  // حالة الشاشة مع دعم الأنيميشن
  int _currentTabIndex = 0; // الفهرس الحالي للتبويب المختار
  late AnimationController _fadeController; // متحكم أنيميشن التلاشي
  late List<Animation<double>> _fadeAnimations; // قائمة حركات التلاشي المتسلسلة
  late AnimationController _floatController; // متحكم أنيميشن الطفو للأيقونات
  late AnimationController _shimmerController; // متحكم أنيميشن اللمعان
  late AnimationController _popController; // متحكم أنيميشن الظهور المفاجئ

  @override
  void initState() {
    // دالة التهيئة الأولية عند تشغيل الشاشة
    super.initState();
    _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000)); // إعداد متحكم التلاشي
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true); // إعداد متحكم الطفو المستمر
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _popController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _fadeAnimations = List.generate(15, (index) {
      // إنشاء تسلسل حركات ظهور للعناصر (Staggered Animation)
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeController.forward(); // بدء تشغيل أنيميشن الظهور
  }

  @override
  void dispose() {
    // تنظيف متحكمات الأنيميشن عند إغلاق الشاشة
    _fadeController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _popController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    // دالة معالجة تغيير التبويب
    setState(() => _currentTabIndex = index); // تحديث التبويب الحالي
    _fadeController.reset(); // إعادة تعيين أنيميشن التلاشي
    _fadeController.forward(); // إعادة تشغيل الأنيميشن للتبويب الجديد
  }

  @override
  Widget build(BuildContext context) {
    // دالة بناء واجهة المدير الرئيسية
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق

    return TaptabaScaffold(
      // استخدام الهيكل الموحد "طبطبة"
      title: 'طبطبـة', // عنوان التطبيق
      titleColor: const Color(0xFF1e293b), // لون العنوان (كحلي غامق رسمي)
      overrideRole: 'مدير', // تحديد دور المدير للألوان الداكنة والاحترافية
      bottomNavigationBar:
          _buildDirectorNav(), // بناء شريط التنقل السفلي المخصص للمدير
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDirectorHero(provider),
            _getCurrentView(),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentView() {
    // إرجاع الواجهة المطلوبة بناءً على التبويب المختار
    switch (_currentTabIndex) {
      case 0:
        return AdminHomeView(
            fadeAnimations: _fadeAnimations, floatController: _floatController);
      case 1:
        return ResidentsManagementView(fadeAnimations: _fadeAnimations);
      case 2:
        return VisitApprovalView(fadeAnimations: _fadeAnimations);
      case 3:
        return SpecialistComplaintsView(
          fadeAnimations: _fadeAnimations,
          floatController: _floatController,
          shimmerController: _shimmerController,
          popController: _popController,
          onNavigate: _onTabChanged,
        );
      case 4:
        return StaffManagementView(fadeAnimations: _fadeAnimations);
      case 5:
        return AdminReportsView(fadeAnimations: _fadeAnimations);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDirectorHero(AppRiverpod provider) {
    // بناء منطقة الـ Hero الخاصة بالمدير مع تأثير زجاجي وأنيمشن قوي
    return ClipRect(
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 10, sigmaY: 10), // تأثير التغبيش الزجاجي
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color:
                const Color(0xFF0f172a).withOpacity(0.85), // لون داكن شبه شفاف
            border: Border(
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1), width: 0.5)),
          ),
          child: Stack(
            children: [
              // 1. شكل متحرك يسبح في الخلفية (الجهة العلوية)
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Positioned(
                    top: -100 + (20 * sin(_floatController.value * 2 * pi)),
                    left: -100 + (30 * cos(_floatController.value * 2 * pi)),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF0ea5e9).withOpacity(0.2),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 2. شكل متحرك آخر يسبح في الجهة السفلية بتوقيت مختلف
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Positioned(
                    bottom: -80 + (25 * cos(_floatController.value * 2 * pi)),
                    right: -50 + (40 * sin(_floatController.value * 2 * pi)),
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF38bdf8).withOpacity(0.18),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 3. نبض ضوئي خفيف في المنتصف
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Center(
                    child: Opacity(
                      opacity: 0.05 + (0.05 * sin(_floatController.value * pi)),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // المحتوى الأساسي للـ Hero
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('لوحة تحكم المدير المسئول',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xFF94a3b8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text('م. إبراهيم الجوهري',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              _buildAnimatedBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge() {
    // بناء شارة المدير مع أنيميشن الطفو
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 3 * _floatController.value), // حركة رأسية خفيفة
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Color(0xFF0ea5e9),
                shape: BoxShape.circle), // شارة زرقاء دائرية
            child: const Icon(Icons.shield_rounded,
                color: Colors.white, size: 18), // أيقونة درع الحماية
          ),
        );
      },
    );
  }

  Widget _buildDirectorNav() {
    // بناء شريط التنقل السفلي المخصص للمدير
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ], // ظل خفيف للأعلى
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: _buildNavItem(0, Icons.analytics_outlined, 'نظرة عامة')),
          Expanded(child: _buildNavItem(1, Icons.groups_outlined, 'المقيمين')),
          Expanded(
              child:
                  _buildNavItem(2, Icons.calendar_month_outlined, 'الزيارات')),
          Expanded(
              child: _buildNavItem(3, Icons.error_outline_rounded, 'الشكاوى')),
          Expanded(child: _buildNavItem(4, Icons.badge_outlined, 'الموظفين')),
          Expanded(
              child:
                  _buildNavItem(5, Icons.account_balance_outlined, 'التقارير')),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    // قالب عنصر التنقل في الشريط السفلي
    final isAct = _currentTabIndex == index; // هل هذا التبويب هو النشط حالياً؟
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        // حاوية متحركة لتغيير الخلفية بسلاسة
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: isAct
            ? BoxDecoration(
                color: const Color(0xFFf0f9ff),
                borderRadius: BorderRadius.circular(20))
            : null, // خلفية زرقاء فاتحة للمختار
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    isAct ? const Color(0xFF0369a1) : const Color(0xFF94a3b8),
                size: 24), // تغيير لون الأيقونة
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isAct
                        ? const Color(0xFF0369a1)
                        : const Color(0xFF94a3b8),
                    fontSize: 10,
                    fontWeight: isAct
                        ? FontWeight.bold
                        : FontWeight.normal)), // تغيير لون النص
          ],
        ),
      ),
    );
  }
}

import 'dart:math'; // مكتبة العمليات الرياضية

import 'package:flutter/material.dart'; // مكتبة فلاتر للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import '../../providers/app_riverpod.dart'; // مزود الحالة الرئيسي
import '../../widgets/taptaba_scaffold.dart'; // الهيكل الموحد للتطبيق
import 'views/assessment_view.dart'; // واجهة التقييمات الاجتماعية
import 'views/complaints_view.dart'; // واجهة الشكاوى والاقتراحات
import 'views/kpi_view.dart'; // واجهة مؤشرات الأداء للأخصائي
import 'views/files_view.dart'; // واجهة الملفات والمستندات
import '../common/notifications_center_screen.dart'; // مركز التنبيهات العام

class SocialSpecialistDashboardScreen extends ConsumerStatefulWidget { // شاشة لوحة تحكم الأخصائي الاجتماعي
  const SocialSpecialistDashboardScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<SocialSpecialistDashboardScreen> createState() =>
      _SocialSpecialistDashboardScreenState(); // إنشاء حالة المكون
}

class _SocialSpecialistDashboardScreenState
    extends ConsumerState<SocialSpecialistDashboardScreen>
    with TickerProviderStateMixin { // حالة الشاشة مع دعم الأنيميشن
  int _currentTabIndex = 0; // الفهرس الحالي للتبويبات
  late AnimationController _floatController; // متحكم أنيميشن الطفو
  late AnimationController _shimmerController; // متحكم أنيميشن اللمعان
  late AnimationController _popController; // متحكم أنيميشن الظهور المفاجئ
  late List<Animation<double>> _fadeAnimations; // قائمة حركات التلاشي للعناصر

  @override
  void initState() { // دالة التهيئة الأولية
    super.initState();
    _floatController = AnimationController( // إعداد حركة الطفو المستمرة
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _shimmerController = AnimationController( // إعداد حركة اللمعان للمؤشرات
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _popController = AnimationController( // إعداد حركة دخول العناصر
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _fadeAnimations = List.generate( // إنشاء تسلسل حركات ظهور للعناصر
      15,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _popController,
          curve: Interval(index * 0.05, min(index * 0.05 + 0.5, 1.0),
              curve: Curves.easeOut),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) { // تحديث دور المستخدم في الحالة بعد البناء
      if (mounted) ref.read(appRiverpod).currentRole = 'specialist';
    });
  }

  @override
  void dispose() { // تنظيف متحكمات الأنيميشن عند إغلاق الشاشة
    _floatController.dispose();
    _shimmerController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // بناء واجهة لوحة تحكم الأخصائي
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق

    void navigateToTab(int index) { // دالة للتنقل بين التبويبات برمجياً
      if (index >= 0 && index < 4) {
        setState(() => _currentTabIndex = index);
      }
    }

    return TaptabaScaffold( // استخدام الهيكل الموحد المخصص
      title: 'طبطبـة', // عنوان التطبيق
      titleColor: Colors.white,
      overrideRole: 'أخصائي', // تحديد دور الأخصائي للألوان البرتقالية
      extendBodyBehindAppBar: true, // تمديد المحتوى خلف شريط العنوان
      transparentAppBar: true, // جعل شريط العنوان شفافاً
      hideAppBar: true, // إخفاء شريط العنوان الافتراضي لاستخدام المخصص
      body: NestedScrollView( // هيكل يسمح بالتمرير المتداخل مع شريط عنوان مرن
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar( // شريط عنوان مرن يتمدد وينكمش
            expandedHeight: 220, // ارتفاع الشريط عند التمدد
            pinned: true, // تثبيت الشريط عند الوصول للقمة
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFea580c), // اللون البرتقالي الأساسي للأخصائي
            leading: IconButton( // زر فتح القائمة الجانبية
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: const Text('طبطبـة',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              Stack( // أيقونة التنبيهات مع نقطة الإشعار
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NotificationsCenterScreen()),
                      );
                    },
                  ),
                  if (provider.hasNewNotification) // إظهار نقطة حمراء إذا وجد إشعار جديد
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar( // الجزء المتمدد من شريط العنوان
              background: _buildHero(provider, navigateToTab), // بناء محتوى الـ Hero
            ),
          ),
        ],
        body: Container( // جسم الصفحة تحت شريط العنوان
          decoration: const BoxDecoration(
            color: Color(0xFFf8fafc), // لون خلفية هادئ
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)), // حواف دائرية علوية
          ),
          child: IndexedStack( // عرض المحتوى بناءً على التبويب المختار
            index: _currentTabIndex,
            children: [
              SpecialistAssessmentView( // واجهة التقييمات
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistComplaintsView( // واجهة الشكاوى
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistKPIView( // واجهة الأرقام والإحصائيات
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistFilesView( // واجهة المستندات
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(), // بناء شريط التنقل السفلي المخصص
    );
  }

  Widget _buildHero(AppRiverpod provider, void Function(int) navigateToTab) { // بناء منطقة الـ Hero في الأعلى
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient( // تدرج برتقالي حيوي
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFc2410c), Color(0xFFea580c), Color(0xFFf97316)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(28, 85, 28, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين (RTL)
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row( // المسمى الوظيفي
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('🧠', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text('الأخصائي الاجتماعي',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ],
                    ),
                    Text('أ. نور — رعاية المقيمين', // اسم الأخصائي
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Spacer(),
              SingleChildScrollView( // شرائح إحصائية سريعة في الـ Hero
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHeroChip('شكاوى مفتوحة ٢', const Color(0xFF34d399),
                        () => navigateToTab(1)), // شريحة الشكاوى
                    const SizedBox(width: 12),
                    _buildHeroChip('تقييم مطلوب ٧', const Color(0xFFfbbf24),
                        () => navigateToTab(0)), // شريحة التقييمات المطلوبة
                    const SizedBox(width: 12),
                    _buildHeroChip('احتياج فوري ١٣', const Color(0xFFf87171),
                        () => navigateToTab(0)), // شريحة الاحتياجات العاجلة
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.assignment_rounded, 'التقييمات'),
          _buildNavItem(1, Icons.report_problem_rounded, 'الشكاوى'),
          _buildNavItem(2, Icons.analytics_rounded, 'الأداء'),
          _buildNavItem(3, Icons.folder_shared_rounded, 'الملفات'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFfff7ed),
                borderRadius: BorderRadius.circular(16))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive
                    ? const Color(0xFFea580c)
                    : const Color(0xFF94a3b8),
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isActive
                        ? const Color(0xFFea580c)
                        : const Color(0xFF94a3b8),
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

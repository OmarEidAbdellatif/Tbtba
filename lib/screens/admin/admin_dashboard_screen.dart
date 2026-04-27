import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import '../../providers/app_riverpod.dart'; // استيراد مزود الحالة الرئيسي
import 'views/admin_home_view.dart'; // واجهة الإحصائيات العامة للمدير
import 'views/residents_management_view.dart'; // واجهة إدارة المقيمين
import 'views/staff_management_view.dart'; // واجهة إدارة طاقم العمل

import 'views/admin_reports_view.dart'; // واجهة التقارير الإدارية والمالية
import '../../widgets/taptaba_drawer.dart'; // القائمة الجانبية الموحدة
import '../../widgets/taptaba_scaffold.dart'; // الهيكل الموحد للتطبيق

class AdminDashboardScreen extends ConsumerStatefulWidget { // شاشة لوحة تحكم المدير العام
  const AdminDashboardScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState(); // إنشاء حالة المكون
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with TickerProviderStateMixin { // حالة الشاشة مع دعم الأنيميشن
  int _currentTabIndex = 0; // الفهرس الحالي للتبويب المختار
  late AnimationController _fadeController; // متحكم أنيميشن التلاشي
  late List<Animation<double>> _fadeAnimations; // قائمة حركات التلاشي المتسلسلة
  late AnimationController _floatController; // متحكم أنيميشن الطفو للأيقونات

  @override
  void initState() { // دالة التهيئة الأولية عند تشغيل الشاشة
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)); // إعداد متحكم التلاشي
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true); // إعداد متحكم الطفو المستمر

    _fadeAnimations = List.generate(10, (index) { // إنشاء تسلسل حركات ظهور للعناصر (Staggered Animation)
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
  void dispose() { // تنظيف متحكمات الأنيميشن عند إغلاق الشاشة
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) { // دالة معالجة تغيير التبويب
    setState(() => _currentTabIndex = index); // تحديث التبويب الحالي
    _fadeController.reset(); // إعادة تعيين أنيميشن التلاشي
    _fadeController.forward(); // إعادة تشغيل الأنيميشن للتبويب الجديد
  }

  @override
  Widget build(BuildContext context) { // دالة بناء واجهة المدير الرئيسية
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق

    return TaptabaScaffold( // استخدام الهيكل الموحد "طبطبة"
      title: 'طبطبـة', // عنوان التطبيق
      titleColor: const Color(0xFF1e293b), // لون العنوان (كحلي غامق رسمي)
      overrideRole: 'مدير', // تحديد دور المدير للألوان الداكنة والاحترافية
      bottomNavigationBar: _buildDirectorNav(), // بناء شريط التنقل السفلي المخصص للمدير
      body: Column( // ترتيب المحتوى بشكل رأسي
        children: [
          _buildDirectorHero(provider), // بناء الجزء العلوي (معلومات المدير)
          Expanded( // استهلاك المساحة المتبقية لعرض الشاشة المختارة
            child: IndexedStack( // تكديس الشاشات وعرض واحدة فقط بناءً على الفهرس
              index: _currentTabIndex,
              children: [
                AdminHomeView(fadeAnimations: _fadeAnimations, floatController: _floatController), // شاشة الإحصائيات
                ResidentsManagementView(fadeAnimations: _fadeAnimations), // شاشة إدارة المقيمين
                StaffManagementView(fadeAnimations: _fadeAnimations), // شاشة إدارة الموظفين
                AdminReportsView(fadeAnimations: _fadeAnimations), // شاشة التقارير
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorHero(AppRiverpod provider) { // بناء منطقة الـ Hero الخاصة بالمدير
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient( // تدرج لوني احترافي داكن (كحلي/أسود)
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b), Color(0xFF334155)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(), // دفع المحتوى لليمين (محاذاة عربية)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('لوحة تحكم المدير المسئول', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12, fontWeight: FontWeight.bold)), // مسمى الوظيفة
              Row(
                children: [
                  const Text('م. إبراهيم الجوهري', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), // اسم المدير
                  const SizedBox(width: 12),
                  _buildAnimatedBadge(), // عرض شارة الحماية المتحركة
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) { // دالة مساعدة لبناء أيقونات سريعة في الهيدر
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildAnimatedBadge() { // بناء شارة المدير مع أنيميشن الطفو
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 3 * _floatController.value), // حركة رأسية خفيفة
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Color(0xFF0ea5e9), shape: BoxShape.circle), // شارة زرقاء دائرية
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 14), // أيقونة درع الحماية
          ),
        );
      },
    );
  }

  Widget _buildDirectorNav() { // بناء شريط التنقل السفلي المخصص للمدير
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))], // ظل خفيف للأعلى
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.analytics_outlined, 'نظرة عامة'), // تبويب الإحصائيات
          _buildNavItem(1, Icons.groups_outlined, 'المقيمين'), // تبويب المقيمين
          _buildNavItem(2, Icons.badge_outlined, 'الموظفين'), // تبويب الموظفين
          _buildNavItem(3, Icons.account_balance_outlined, 'التقارير'), // تبويب التقارير المالية
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) { // قالب عنصر التنقل في الشريط السفلي
    final isAct = _currentTabIndex == index; // هل هذا التبويب هو النشط حالياً؟
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer( // حاوية متحركة لتغيير الخلفية بسلاسة
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isAct ? BoxDecoration(color: const Color(0xFFf0f9ff), borderRadius: BorderRadius.circular(20)) : null, // خلفية زرقاء فاتحة للمختار
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isAct ? const Color(0xFF0369a1) : const Color(0xFF94a3b8), size: 24), // تغيير لون الأيقونة
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isAct ? const Color(0xFF0369a1) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: isAct ? FontWeight.bold : FontWeight.normal)), // تغيير لون النص
          ],
        ),
      ),
    );
  }
}

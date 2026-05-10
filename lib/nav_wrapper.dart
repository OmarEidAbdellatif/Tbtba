import 'dart:ui'; // مكتبة الواجهات المتقدمة
import 'widgets/draggable_sos.dart'; // استيراد زر الطوارئ الجانبي الجديد
import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import 'providers/app_riverpod.dart'; // استيراد مزود الحالة الرئيسي
import 'screens/elderly/home_screen.dart'; // شاشة المسن الرئيسية
import 'screens/elderly/medication_screen.dart'; // شاشة الأدوية
import 'screens/elderly/calls_screen.dart'; // شاشة المكالمات
import 'screens/elderly/memories_screen.dart'; // شاشة الذكريات
import 'screens/elderly/activities_screen.dart'; // شاشة الأنشطة
import 'screens/elderly/widgets/video_call_overlay.dart'; // واجهة مكالمة الفيديو
import 'widgets/bottom_nav_bar.dart'; // شريط التنقل السفلي المخصص
import 'widgets/taptaba_scaffold.dart'; // الهيكل الموحد للتطبيق

class NavWrapper extends ConsumerStatefulWidget {
  // غلاف التنقل لدور المسن
  const NavWrapper({super.key}); // مشيد الفئة

  @override
  ConsumerState<NavWrapper> createState() => _NavWrapperState(); // إنشاء الحالة
}

class _NavWrapperState extends ConsumerState<NavWrapper> {
  // حالة غلاف التنقل
  @override
  Widget build(BuildContext context) {
    // دالة بناء الواجهة
    final provider = ref.watch(appRiverpod); // مراقبة تغيرات حالة التطبيق

    // قائمة الشاشات المتاحة للمسن
    final List<Widget> screens = [
      const HomeScreen(), // شاشة البداية
      const MedicationScreen(), // شاشة تنبيهات الأدوية
      const CallsScreen(), // شاشة الاتصال بالأسرة
      const MemoriesScreen(), // شاشة ألبوم الصور
      const ActivitiesScreen(), // شاشة التمارين والأنشطة
    ];

    return Stack(
      children: [
        TaptabaScaffold(
          // استخدام الهيكل الموحد لطبطبة
          title: 'طبطبـة', // عنوان التطبيق
          overrideRole: 'مسن', // تحديد الدور كمسن لإظهار الألوان المناسبة
          bottomNavigationBar: BottomNavBar(
            // شريط التنقل السفلي
            currentIndex:
                provider.currentElderlyTabIndex, // الفهرس الحالي المختار
            onTap: (index) {
              // عند الضغط على تبويب جديد
              provider.setElderlyTabIndex(index); // تحديث الفهرس في الحالة
            },
          ),
          body: IndexedStack(
            // عرض شاشة واحدة فقط بناءً على الفهرس
            index: provider.currentElderlyTabIndex, // الفهرس المختار
            children: screens, // قائمة الشاشات
          ),
        ),
        if (provider.isVideoCallActive) // إذا كانت هناك مكالمة فيديو نشطة
          const VideoCallOverlay(), // إظهار واجهة المكالمة فوق المحتوى
        if (provider.isEmergencyActive) // إذا تم تفعيل حالة الطوارئ
          _buildSOSOverlay(provider), // إظهار واجهة الاستغاثة الحمراء

        // الزر الجانبي القابل للسحب (SOS) - يظهر دائماً في مكان ثابت
        const DraggableSOS(),
      ],
    );
  }

  Widget _buildSOSOverlay(AppRiverpod provider) {
    // دالة بناء واجهة الاستغاثة الكاملة
    return BackdropFilter(
      // فلتر لتغطية الشاشة بالكامل
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ضبابية خفيفة للخلفية
      child: Container(
        // وعاء أحمر شفاف
        color: const Color(0xFFef4444).withOpacity(0.85), // لون أحمر طوارئ
        width: double.infinity, // كامل العرض
        height: double.infinity, // كامل الارتفاع
        child: Column(
          // ترتيب عناصر الاستغاثة
          mainAxisAlignment: MainAxisAlignment.center, // توسيط رأسي
          children: [
            const Icon(Icons.emergency_share_rounded,
                color: Colors.white, size: 100), // أيقونة استغاثة كبيرة
            const SizedBox(height: 24), // مسافة فارغة
            const Text(
              // نص جاري الإرسال
              'جاري إرسال نداء استغاثة...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), // مسافة فارغة
            const Text(
              // نص توضيحي للمسن
              'سيصل النداء للأسرة والممرض فوراً',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60), // مسافة قبل زر الإلغاء
            ElevatedButton(
              // زر إلغاء النداء في حالة الخطأ
              onPressed: () => provider.cancelSOS(), // إلغاء الاستغاثة
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // خلفية بيضاء للزر
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15), // حواف مريحة للضغط
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)), // حواف دائرية
              ),
              child: const Text('إلغاء النداء ❌',
                  style: TextStyle(
                      color: Color(0xFFef4444),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)), // نص الإلغاء
            ),
          ],
        ),
      ),
    );
  }
}

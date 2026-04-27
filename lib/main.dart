import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية
import 'package:flutter/services.dart'; // مكتبة التحكم في خصائص النظام
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import 'nav_wrapper.dart'; // غلاف التنقل
import 'screens/auth/login_screen.dart'; // شاشة تسجيل الدخول
import 'screens/nurse/nurse_dashboard_screen.dart'; // لوحة تحكم الممرض
import 'screens/volunteer/volunteer_dashboard_screen.dart'; // لوحة تحكم المتطوع
import 'screens/family/family_dashboard_screen.dart'; // لوحة تحكم الأسرة
import 'screens/specialist/specialist_dashboard_screen.dart'; // لوحة تحكم الأخصائي
import 'screens/admin/admin_dashboard_screen.dart'; // لوحة تحكم الإدارة
import 'screens/onboarding/onboarding_screen.dart'; // شاشة البداية
import 'providers/app_riverpod.dart'; // مزود الحالة

void main() { // الدالة الرئيسية
  WidgetsFlutterBinding.ensureInitialized(); // تهيئة النظام
  SystemChrome.setPreferredOrientations([ // تثبيت وضع الشاشة
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp( // تشغيل التطبيق
    const ProviderScope( // تفعيل إدارة الحالة
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // المكون الرئيسي
  const MyApp({super.key}); // مشيد الفئة

  @override
  Widget build(BuildContext context, WidgetRef ref) { // بناء واجهة المستخدم
    final provider = ref.watch(appRiverpod); // مراقبة الحالة
    
    Widget getHomeWidget() { // تحديد الشاشة الحالية
      if (!provider.hasSeenOnboarding) return const OnboardingScreen(); // فحص شاشة البداية
      if (!provider.isAuthenticated) return const LoginScreen(); // فحص تسجيل الدخول
      
      switch (provider.currentRole) { // فحص دور المستخدم
        case 'ممرض':
          return const NurseDashboardScreen();
        case 'متطوع':
          return const VolunteerDashboardScreen();
        case 'مسن':
          return const NavWrapper();
        case 'أخصائي اجتماعي':
          return const SocialSpecialistDashboardScreen(); // تصحيح اسم الفئة لتطابق التعريف الفعلي
        case 'أسرة':
          return const FamilyDashboardScreen();
        case 'إدارة':
          return const AdminDashboardScreen();
        default:
          return const NavWrapper();
      }
    }

    return MaterialApp( // تطبيق ماتيريال
      debugShowCheckedModeBanner: false, // إخفاء علامة التصحيح
      title: 'طبطبة', // اسم التطبيق
      themeMode: (provider.isDarkMode || provider.isHighContrast) ? ThemeMode.dark : ThemeMode.light, // اختيار النمط
      builder: (context, child) { // منشئ المحتوى
        return Stack(
          children: [
            MediaQuery( // إعدادات الخط
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(provider.fontScaleFactor)),
              child: child!,
            ),
            if (provider.isRefreshingSession) // فحص تجديد الجلسة
              Container(
                color: Colors.black.withOpacity(0.5), // لون الخلفية
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF6C63FF)), // مؤشر التحميل
                        SizedBox(height: 16),
                        Text('جاري تجديد الجلسة...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text('برجاء الانتظار لحظة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      theme: ThemeData( // النمط الفاتح
        fontFamily: 'Cairo', // نوع الخط
        useMaterial3: true, // تفعيل مادة ٣
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF6C63FF),
        ),
      ),
      darkTheme: ThemeData( // النمط الليلي
        fontFamily: 'Cairo',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: provider.isHighContrast ? const Color(0xFF000000) : const Color(0xFF0F172A),
        appBarTheme: AppBarTheme(
          backgroundColor: provider.isHighContrast ? const Color(0xFF000000) : const Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
      ),
      home: getHomeWidget(), // تعيين الصفحة الرئيسية
    );
  }
}

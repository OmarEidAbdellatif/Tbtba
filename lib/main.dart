import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nav_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/nurse/nurse_dashboard_screen.dart';
import 'screens/volunteer/volunteer_dashboard_screen.dart';
import 'screens/family/family_dashboard_screen.dart';
import 'screens/specialist/specialist_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/app_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);
    
    Widget getHomeWidget() {
      if (!provider.hasSeenOnboarding) return const OnboardingScreen();
      if (!provider.isAuthenticated) return const LoginScreen();
      
      switch (provider.currentRole) {
        case 'ممرض':
          return const NurseDashboardScreen();
        case 'متطوع':
          return const VolunteerDashboardScreen();
        case 'مسن':
          return const NavWrapper();
        case 'أخصائي اجتماعي':
          return const SocialSpecialistDashboardScreen();
        case 'أسرة':
          return const FamilyDashboardScreen();
        case 'إدارة':
          return const AdminDashboardScreen();
        default:
          return const NavWrapper();
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'طبطبة',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(provider.fontScaleFactor)),
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
        brightness: provider.isHighContrast ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: provider.isHighContrast ? const Color(0xFF000000) : const Color(0xFFF8FAFC),
        appBarTheme: AppBarTheme(
          backgroundColor: provider.isHighContrast ? const Color(0xFF000000) : Colors.white,
          foregroundColor: provider.isHighContrast ? Colors.white : const Color(0xFF6C63FF),
        ),
      ),
      home: getHomeWidget(),
    );
  }
}

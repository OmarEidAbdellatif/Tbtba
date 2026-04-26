import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/app_riverpod.dart';
import 'screens/elderly/home_screen.dart';
import 'screens/elderly/medication_screen.dart';
import 'screens/elderly/calls_screen.dart';
import 'screens/elderly/memories_screen.dart';
import 'screens/elderly/activities_screen.dart';
import 'screens/elderly/widgets/video_call_overlay.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/taptaba_drawer.dart';
import 'widgets/taptaba_scaffold.dart';

class NavWrapper extends ConsumerStatefulWidget {
  const NavWrapper({super.key});

  @override
  ConsumerState<NavWrapper> createState() => _NavWrapperState();
}

class _NavWrapperState extends ConsumerState<NavWrapper> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    
    // Dynamic screens list to ensure state updates propagate correctly
    final List<Widget> screens = [
      const HomeScreen(),
      const MedicationScreen(),
      const CallsScreen(),
      const MemoriesScreen(),
      const ActivitiesScreen(),
    ];

    return TaptabaScaffold(
      title: 'طبطبـة',
      overrideRole: 'مسن',
      bottomNavigationBar: BottomNavBar(
        currentIndex: provider.currentElderlyTabIndex,
        onTap: (index) {
          provider.setElderlyTabIndex(index);
        },
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: provider.currentElderlyTabIndex,
            children: screens,
          ),
          if (provider.isVideoCallActive)
            const VideoCallOverlay(),
          if (provider.isEmergencyActive)
            _buildSOSOverlay(provider),
        ],
      ),
      floatingActionButton: provider.isEmergencyActive ? null : _buildSOSButton(provider),
    );
  }

  Widget _buildSOSButton(AppRiverpod provider) {
    return FloatingActionButton.large(
      onPressed: () => provider.triggerSOS(),
      backgroundColor: const Color(0xFFef4444),
      elevation: 8,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_rounded, color: Colors.white, size: 32),
          Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSOSOverlay(AppRiverpod provider) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: const Color(0xFFef4444).withOpacity(0.85),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 100),
            const SizedBox(height: 24),
            const Text(
              'جاري إرسال نداء استغاثة...',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيصل النداء للأسرة والممرض فوراً',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => provider.cancelSOS(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('إلغاء النداء ❌', style: TextStyle(color: Color(0xFFef4444), fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

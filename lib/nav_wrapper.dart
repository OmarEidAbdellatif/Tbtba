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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    HomeScreen(),
    MedicationScreen(),
    CallsScreen(),
    MemoriesScreen(),
    ActivitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
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
            children: _screens,
          ),
          if (provider.isVideoCallActive)
            const VideoCallOverlay(),
        ],
      ),
    );
  }
}

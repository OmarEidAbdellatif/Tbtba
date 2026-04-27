import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../widgets/taptaba_scaffold.dart';
import 'views/assessment_view.dart';
import 'views/complaints_view.dart';
import 'views/kpi_view.dart';
import 'views/files_view.dart';
import '../common/notifications_center_screen.dart';

class SocialSpecialistDashboardScreen extends ConsumerStatefulWidget {
  const SocialSpecialistDashboardScreen({super.key});

  @override
  ConsumerState<SocialSpecialistDashboardScreen> createState() =>
      _SocialSpecialistDashboardScreenState();
}

class _SocialSpecialistDashboardScreenState
    extends ConsumerState<SocialSpecialistDashboardScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _popController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _popController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _fadeAnimations = List.generate(
      15,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _popController,
          curve: Interval(index * 0.05, min(index * 0.05 + 0.5, 1.0),
              curve: Curves.easeOut),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(appRiverpod).currentRole = 'specialist';
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    void navigateToTab(int index) {
      if (index >= 0 && index < 4) {
        setState(() => _currentTabIndex = index);
      }
    }

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: Colors.white,
      overrideRole: 'أخصائي',
      extendBodyBehindAppBar: true,
      transparentAppBar: true,
      hideAppBar: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFea580c),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: const Text('طبطبـة',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              Stack(
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
                  if (provider.hasNewNotification)
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
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(provider, navigateToTab),
            ),
          ),
        ],
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf8fafc),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              SpecialistAssessmentView(
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistComplaintsView(
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistKPIView(
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
              SpecialistFilesView(
                  fadeAnimations: _fadeAnimations,
                  floatController: _floatController,
                  shimmerController: _shimmerController,
                  popController: _popController,
                  onNavigate: navigateToTab),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHero(AppRiverpod provider, void Function(int) navigateToTab) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFc2410c), Color(0xFFea580c), Color(0xFFf97316)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(28, 85, 28, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row(
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
                    Text('أ. نور — رعاية المقيمين',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Spacer(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHeroChip('شكاوى مفتوحة ٢', const Color(0xFF34d399),
                        () => navigateToTab(1)),
                    const SizedBox(width: 12),
                    _buildHeroChip('تقييم مطلوب ٧', const Color(0xFFfbbf24),
                        () => navigateToTab(0)),
                    const SizedBox(width: 12),
                    _buildHeroChip('احتياج فوري ١٣', const Color(0xFFf87171),
                        () => navigateToTab(0)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import 'views/home_view.dart';
import 'views/assessment_view.dart';
import 'views/complaints_view.dart';
import 'views/kpi_view.dart';
import 'views/files_view.dart';
import '../../widgets/taptaba_drawer.dart';
import '../../widgets/taptaba_scaffold.dart';

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
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _popController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _popController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _fadeAnimations = List.generate(12, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeController.forward();
    _popController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    void navigateToTab(int index) {
      if (index >= 0 && index < 5) {
        setState(() => _currentTabIndex = index);
      }
    }

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: const Color(0xFFea580c),
      overrideRole: 'أخصائي',
      body: Column(
        children: [
          _buildHero(provider, navigateToTab),
          _buildNavTabs(navigateToTab),
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                SpecialistHomeView(
                    fadeAnimations: _fadeAnimations,
                    floatController: _floatController,
                    shimmerController: _shimmerController,
                    popController: _popController,
                    onNavigate: navigateToTab),
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
          _buildBottomGlobalActions(provider),
          _buildBottomNavBar(navigateToTab),
        ],
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider, Function(int) navigateToTab) {
    final openComplaints =
        provider.socialComplaints.where((c) => c.status == 'open').length;
    final pendingAssessments =
        provider.socialAssessmentTools.where((t) => t.status == 'جديد').length;
    final urgentNeeds = provider.socialNeeds.where((n) => n.isUrgent).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFc2410c),
            Color(0xFFea580c),
            Color(0xFFf97316)
          ],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(45)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFea580c).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -50,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('🧠 الأخصائي الاجتماعي',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('أ. نور — رعاية المقيمين',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () => navigateToTab(2),
                        child: _buildHeroChip('شكاوى مفتوحة ${ref.watch(appRiverpod).totalOpenComplaints}',
                            const Color(0xFF4ade80))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => navigateToTab(1),
                        child: _buildHeroChip('تقييم مطلوب ${ref.watch(appRiverpod).totalPendingAssessments}',
                            const Color(0xFFfbbf24))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => navigateToTab(0),
                        child: _buildHeroChip('احتياج فوري ${ref.watch(appRiverpod).totalOpenNeeds}',
                            const Color(0xFFef4444),
                            isBlinking: ref.watch(appRiverpod).totalOpenNeeds > 0)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, Color color, {bool isBlinking = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildNavTabs(void Function(int) onNavigate) {
    final tabs = [
      {'icon': '🗺️', 'label': 'الخريطة'},
      {'icon': '📋', 'label': 'التقييم', 'badge': '٧'},
      {'icon': '💬', 'label': 'الشكاوى', 'badge': '٣'},
      {'icon': '📊', 'label': 'المؤشرات'},
    ];

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFfed7aa))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isAct = _currentTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onNavigate(index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: isAct
                              ? const Color(0xFFea580c)
                              : Colors.transparent,
                          width: 2.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(tabs[index]['icon']!,
                            style: const TextStyle(fontSize: 16)),
                        if (tabs[index].containsKey('badge'))
                          Positioned(
                            top: -4,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(tabs[index]['badge']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(tabs[index]['label']!,
                        style: TextStyle(
                            color: isAct
                                ? const Color(0xFFea580c)
                                : const Color(0xFF94a3b8),
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomGlobalActions(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFfed7aa)))),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري إرسال التقرير للإدارة...'),
                    backgroundColor: Color(0xFFea580c),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('📤 إرسال تقرير',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _showAddNeedDialog(context, provider),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff7ed),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
                ),
                child: const Center(
                    child: Text('➕ تسجيل احتياج',
                        style: TextStyle(
                            color: Color(0xFF9a3412),
                            fontSize: 11,
                            fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNeedDialog(BuildContext context, AppRiverpod provider) {
    String type = 'نفسي';
    String room = '';
    bool urgent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تسجيل احتياج جديد', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: ['نفسي', 'أسري', 'مالي', 'طبي']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setDialogState(() => type = v!),
                decoration: const InputDecoration(labelText: 'نوع الاحتياج'),
              ),
              TextField(
                onChanged: (v) => room = v,
                decoration: const InputDecoration(labelText: 'رقم الغرفة'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('احتياج عاجل؟'),
                value: urgent,
                onChanged: (v) => setDialogState(() => urgent = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (room.isNotEmpty) {
                  provider.addSocialNeed(SocialSpecialistNeed(
                    id: DateTime.now().toString(),
                    type: type,
                    roomNumber: room,
                    isUrgent: urgent,
                    label: type[0],
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل الاحتياج بنجاح')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFea580c)),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(void Function(int) onNavigate) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFfed7aa)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.person_outline, 'ملفات', _currentTabIndex == 4,
              () => onNavigate(4)),
          _buildNavItem(Icons.chat_bubble_outline, 'الشكاوى',
              _currentTabIndex == 2, () => onNavigate(2)),
          _buildNavItem(Icons.assignment_outlined, 'التقييم',
              _currentTabIndex == 1, () => onNavigate(1)),
          _buildNavItem(Icons.map_outlined, 'الخريطة', _currentTabIndex == 0,
              () => onNavigate(0)),
          _buildNavItem(Icons.grid_view_rounded, 'لوحتي', _currentTabIndex == 3,
              () => onNavigate(3)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isAct, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isAct ? const Color(0xFFea580c) : const Color(0xFF9ca3af),
              size: 20),
          Text(label,
              style: TextStyle(
                  color:
                      isAct ? const Color(0xFFea580c) : const Color(0xFF9ca3af),
                  fontSize: 9,
                  fontWeight: isAct ? FontWeight.bold : FontWeight.normal)),
          if (isAct)
            Container(
                margin: const EdgeInsets.only(top: 2),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Color(0xFFea580c), shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

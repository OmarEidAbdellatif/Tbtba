import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import 'views/admin_home_view.dart';
import 'views/residents_management_view.dart';
import 'views/staff_management_view.dart';

import 'views/admin_reports_view.dart';
import '../../widgets/taptaba_drawer.dart';
import '../../widgets/taptaba_scaffold.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  late AnimationController _fadeController;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

    _fadeAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _currentTabIndex = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: const Color(0xFF1e293b),
      overrideRole: 'مدير',
      bottomNavigationBar: _buildDirectorNav(),
      body: Column(
        children: [
          _buildDirectorHero(provider),
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                AdminHomeView(fadeAnimations: _fadeAnimations, floatController: _floatController),
                ResidentsManagementView(fadeAnimations: _fadeAnimations),
                StaffManagementView(fadeAnimations: _fadeAnimations),
                AdminReportsView(fadeAnimations: _fadeAnimations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorHero(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b), Color(0xFF334155)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('لوحة تحكم المدير المسئول', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Text('م. إبراهيم الجوهري', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  _buildAnimatedBadge(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildAnimatedBadge() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 3 * _floatController.value),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Color(0xFF0ea5e9), shape: BoxShape.circle),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
          ),
        );
      },
    );
  }

  Widget _buildDirectorNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.analytics_outlined, 'نظرة عامة'),
          _buildNavItem(1, Icons.groups_outlined, 'المقيمين'),
          _buildNavItem(2, Icons.badge_outlined, 'الموظفين'),
          _buildNavItem(3, Icons.account_balance_outlined, 'التقارير'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isAct = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isAct ? BoxDecoration(color: const Color(0xFFf0f9ff), borderRadius: BorderRadius.circular(20)) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isAct ? const Color(0xFF0369a1) : const Color(0xFF94a3b8), size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isAct ? const Color(0xFF0369a1) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: isAct ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import 'opportunities_view.dart';
import 'bookings_view.dart';
import 'certificates_view.dart';
import 'ratings_view.dart';
import 'profile_view.dart';
import '../../widgets/taptaba_drawer.dart';
import '../../widgets/taptaba_scaffold.dart';

class VolunteerDashboardScreen extends ConsumerStatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  ConsumerState<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends ConsumerState<VolunteerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _ringController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  late AnimationController _popController;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimations = List.generate(
      12,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.08, 1.0, curve: Curves.easeOut),
        ),
      ),
    );

    _ringController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _popController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _fadeController.forward();
    _ringController.forward();
    _popController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: const Color(0xFF059669),
      overrideRole: 'متطوع',
      body: Column(
        children: [
          _buildHero(provider),
          _buildNavTabs(),
          Expanded(
            child: _buildCurrentView(provider),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildCurrentView(AppRiverpod provider) {
    switch (_selectedTab) {
      case 1:
        return VolunteerOpportunitiesView(
          fadeAnimations: _fadeAnimations,
          floatController: _floatController,
          shimmerController: _shimmerController,
        );
      case 2:
        return VolunteerBookingsView(
           fadeAnimations: _fadeAnimations,
           floatController: _floatController,
           shimmerController: _shimmerController,
           popController: _popController,
        );
      case 3:
        return VolunteerCertificatesView(
           fadeAnimations: _fadeAnimations,
           floatController: _floatController,
           shimmerController: _shimmerController,
           popController: _popController,
        );
      case 4:
        return VolunteerRatingsView(
           fadeAnimations: _fadeAnimations,
           floatController: _floatController,
           shimmerController: _shimmerController,
           popController: _popController,
        );
      case 0:
      default:
        return VolunteerProfileView(
          fadeAnimations: _fadeAnimations,
          floatController: _floatController,
          shimmerController: _shimmerController,
          popController: _popController,
        );
    }
  }

  Widget _buildHero(AppRiverpod provider) {
    final isCertTab = _selectedTab == 3;
    final isRatingTab = _selectedTab == 4;
    final opportunitiesCount = provider.volunteerOpportunities.length;
    final bookingsSummary = '${provider.volunteerBookings.length} حجوزات مقبلة';
    const certsCount = '٣';
    const ratingSummary = '⭐ ٤.٩';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRatingTab
              ? [const Color(0xFF312e81), const Color(0xFF4338ca), const Color(0xFF6366f1)]
              : (isCertTab
                  ? [const Color(0xFF78350f), const Color(0xFF92400e), const Color(0xFFb45309)]
                  : [const Color(0xFF064e3b), const Color(0xFF059669), const Color(0xFF10b981)]),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isCertTab)
                 GestureDetector(
                   onTap: () {},
                   child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_outlined, color: Colors.white),
                  ),
                 )
              else
                 const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_selectedTab == 1
                      ? '🎯 فرص التطوع'
                      : (_selectedTab == 2 ? '📅 حجوزاتي' : (isCertTab ? '🏅 شهاداتي' : (isRatingTab ? '⭐ تقييمي' : 'أهلاً بك يا'))),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  Text(_selectedTab == 1
                      ? '$opportunitiesCount فرص متاحة دلوقتي'
                      : (_selectedTab == 2
                          ? bookingsSummary
                          : (isCertTab ? '$certsCount شهادات مكتسبة' : (isRatingTab ? ratingSummary : '${provider.currentUser.name} 🌿'))),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (_selectedTab == 0) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildHeroChip('${provider.volunteerGoal} ساعة', 'الهدف الشهري'),
                      const SizedBox(height: 8),
                      _buildHeroChip('⭐ ${provider.volunteerBookings.where((b) => b.status == 'done').length} جلسة', 'جلسات مكتملة'),
                      const SizedBox(height: 8),
                      _buildHeroChip('⭐⭐⭐⭐⭐', 'تقييم المقيمين'),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(100, 100),
                            painter: RingPainter(
                              progress: _ringController.value * (provider.volunteerHours / provider.volunteerGoal),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              progressColor: Colors.white,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${provider.volunteerHours}',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('ساعة',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ] else if (_selectedTab == 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTopChip('مناسب لمهاراتك ٥', const Color(0xFF4ade80)),
                const SizedBox(width: 8),
                _buildTopChip('هذا الأسبوع ٣', const Color(0xFFfbbf24)),
                const SizedBox(width: 8),
                _buildTopChip('محجوزة ٢', const Color(0xFF60a5fa)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Text('٥ فرص',
                      style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11, backgroundColor: Colors.white)),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('مطابق لمهاراتك: قراءة، دعم نفسي، ترفيه',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right)),
                  Text('🎯', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ] else if (_selectedTab == 2) ...[
            const SizedBox(height: 16),
            _buildCalendarStrip(),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final days = [
      {'name': 'إث', 'num': '٧', 'hasDot': false},
      {'name': 'ثلا', 'num': '٨', 'hasDot': true},
      {'name': 'أحد', 'num': '٦', 'hasDot': true, 'active': true},
      {'name': 'خمس', 'num': '١٠', 'hasDot': true},
      {'name': 'أربع', 'num': '١٤', 'hasDot': true},
      {'name': 'جمع', 'num': '١٨', 'hasDot': false},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isActive = day['active'] == true;
          return Container(
            width: 45,
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day['name'] as String, style: TextStyle(color: isActive ? const Color(0xFF064e3b) : Colors.white.withOpacity(0.75), fontSize: 8, fontWeight: FontWeight.bold)),
                Text(day['num'] as String, style: TextStyle(color: isActive ? const Color(0xFF064e3b) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (day['hasDot'] == true)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: isActive ? const Color(0xFF059669) : const Color(0xFFfbbf24), shape: BoxShape.circle),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopChip(String label, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildNavTabs() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, '🏠', 'ملفي'),
          _buildTabItem(1, '🎯', 'الفرص'),
          _buildTabItem(2, '📅', 'حجوزاتي'),
          _buildTabItem(3, '🏅', 'شهاداتي'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF10b981) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF059669) : const Color(0xFF94a3b8),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.person_outline, 'ملفي'),
          _buildNavItem(1, Icons.track_changes, 'الفرص'),
          _buildNavItem(2, Icons.calendar_month_outlined, 'حجوزاتي'),
          _buildNavItem(3, Icons.card_membership_outlined, 'شهاداتي'),
          _buildNavItem(4, Icons.star_border, 'تقييمي'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF059669) : Colors.grey[400], size: 24),
          Text(label, style: TextStyle(color: active ? const Color(0xFF059669) : Colors.grey[400], fontSize: 9, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          if (active) Container(margin: const EdgeInsets.only(top: 2), width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF10b981), shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  RingPainter({required this.progress, required this.backgroundColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4;
    final strokeWidth = 8.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

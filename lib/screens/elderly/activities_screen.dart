import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _ringController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _dotController;
  late AnimationController _starController;
  late AnimationController _shimmerController;
  late AnimationController _lockController;
  late AnimationController _badgeController;

  int selectedDay = 1;
  final days = ['أمس', 'اليوم', 'غداً', 'الأسبوع'];
  int currentPoints = 370;
  int targetPoints = 600;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _ringController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _dotController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _starController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _lockController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _badgeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _ringController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _dotController.dispose();
    _starController.dispose();
    _shimmerController.dispose();
    _lockController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHero(provider),
          _buildDayTabs(provider),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildActivitiesList(provider),
                const SizedBox(height: 12),
                _buildPointsCard(provider),
                const SizedBox(height: 12),
                _buildBadgesRow(),
                const SizedBox(height: 12),
                _buildHonorBoard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0533),
                Color(0xFF3730a3),
                Color(0xFF0f3460),
                Color(0xFF6C63FF)
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildBlob(180, const Color(0xFF6C63FF), -50, -50, 7),
              _buildBlob(130, const Color(0xFFf472b6), -35, 30, 9),
              _buildBlob(80, const Color(0xFFfbbf24), 80, -10, 6),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 22, top: 4, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('🏆 أنشطتي ونقاطي',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('أبريل ٢٠٢٥ — أنت في المركز الأول! 👑',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 12, bottom: 24),
                      child: Row(
                        children: [
                          _buildRingChart(provider),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                _buildStatChip('الهدف', '٦٠٠ نقطة', 0),
                                const SizedBox(height: 7),
                                _buildStatChip('أنشطة مكتملة', '⭐ ${provider.currentUser.completedActivities}', 1),
                                const SizedBox(height: 7),
                                _buildStatChip('أيام متواصلة', '🔥 ${provider.currentUser.streakDays}', 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlob(
      double size, Color color, double right, double top, double duration) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value * 2 * pi;
        final x = sin(t * (duration / 7)) * 10;
        final y = cos(t * (duration / 7)) * 12;
        return Positioned(
          right: right + x,
          top: top + y,
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withOpacity(0.4))),
        );
      },
    );
  }

  Widget _buildRingChart(AppRiverpod provider) {
    int points = provider.currentUser.points;
    double targetProgress = (points / targetPoints).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) {
        final progress = _ringController.value * targetProgress;
        final dashOffset = 214 * (1 - progress);
        return SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: RingPainter(progress: progress, dashOffset: dashOffset),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$points',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      Text('نقطة',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85), fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, String value, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.6, end: 1),
      duration: Duration(milliseconds: 450 + (index * 120)),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 13)),
            ),
            const SizedBox(width: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTabs(AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return Container(
      color: hc ? const Color(0xFF1E1E1E) : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(days.length, (index) {
            final isActive = selectedDay == index;
            return GestureDetector(
              onTap: () => setState(() => selectedDay = index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: isActive
                              ? (hc ? const Color(0xFFfbbf24) : const Color(0xFFd97706))
                              : Colors.transparent,
                          width: 2.5)),
                ),
                child: Text(days[index],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? (hc ? const Color(0xFFfbbf24) : const Color(0xFFd97706))
                            : (hc ? Colors.white38 : const Color(0xFF94a3b8)))),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActivitiesList(AppRiverpod provider) {
    final activities = provider.getActivitiesForDay(selectedDay);
    bool hc = provider.isHighContrast;

    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('لا توجد أنشطة مسجلة في هذا اليوم.',
            style: TextStyle(fontSize: 18, color: hc ? Colors.white38 : Colors.grey)),
      );
    }

    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final act = entry.value;

        if (act.status == 'active') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildActiveActivityCard(provider, act),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _buildActivityCard(
              act.emoji, act.name, act.location, act.time, act.status, act.badges, index),
        );
      }).toList(),
    );
  }

  Widget _buildActivityCard(String emoji, String name, String location,
      String time, String status, String badge, int index) {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    final isDone = status == 'done';
    final isLater = status == 'later';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDone
            ? (hc ? const Color(0xFF064e3b).withOpacity(0.3) : const Color(0xFFf0fdf4))
            : (isLater ? (hc ? const Color(0xFF252525) : const Color(0xFFfafafa)) : (hc ? const Color(0xFF1E1E1E) : Colors.white)),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: hc ? (isDone ? const Color(0xFF059669) : const Color(0xFF333333)) : (isDone ? const Color(0xFFd1fae5) : const Color(0xFFfde68a)),
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFd97706).withOpacity(hc ? 0.2 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF6C63FF), size: 24),
            onPressed: () => ref.read(appRiverpod).startReading('نشاط $name، المكان $location، الساعة $time'),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: hc ? Colors.white : const Color(0xFF0f172a))),
                const SizedBox(height: 4),
                Text(location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: hc ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 16, color: hc ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(time,
                        style: TextStyle(
                            fontSize: 16, color: hc ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? (hc ? const Color(0xFF065f46) : const Color(0xFFd1fae5))
                  : (hc ? const Color(0xFF333333) : const Color(0xFFf5f5f5)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDone
                        ? Colors.white
                        : (hc ? Colors.white38 : const Color(0xFF9ca3af)))),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveActivityCard(AppRiverpod provider, Activity act) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatController.value),
          child: GestureDetector(
            onTap: () {
              provider.completeActivity(act.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إنجاز ${act.name} بنجاح! +${act.pointsReward} نقطة 🌟', style: const TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                  backgroundColor: const Color(0xFF10b981),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFd97706),
                  Color(0xFFfbbf24),
                  Color(0xFFf59e0b)
                ]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFfbbf24), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFd97706).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6)),
                  BoxShadow(
                      color: const Color(0xFFfbbf24)
                          .withOpacity(0.45 + (_glowController.value * 0.45)),
                      blurRadius: 10 + (_glowController.value * 10),
                      spreadRadius: _glowController.value * 5),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 11,
                    left: 11,
                    child: AnimatedBuilder(
                      animation: _dotController,
                      builder: (context, child) {
                        final scale = 1 + (_dotController.value * 0.4);
                        final opacity = 1 - (_dotController.value * 0.45);
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.white)),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16)),
                          child: Center(
                              child: Text(act.emoji, style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(act.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(act.location,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9))),
                              const SizedBox(height: 6),
                              const Text('🔴 جارٍ الآن! (اضغط للإتمام)',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35))),
                          child: Text(act.badges,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCard(AppRiverpod provider) {
    int points = provider.currentUser.points;
    double progress = (points / targetPoints).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();
    int remaining = targetPoints - points > 0 ? targetPoints - points : 0;

    return AnimatedBuilder(
      animation: Listenable.merge([_starController, _shimmerController]),
      builder: (context, child) {
        final starY = -7 * sin(_starController.value * pi);
        final starScale = 1 + (sin(_starController.value * pi * 2) * 0.15);
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFFd97706),
              Color(0xFFfbbf24),
              Color(0xFFf59e0b)
            ]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFd97706).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 6))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1)))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.translate(
                            offset: Offset(0, starY),
                            child: Transform.scale(
                              scale: starScale,
                              child: const Text('🏆',
                                  style: TextStyle(fontSize: 38)),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('⭐ $points',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              const SizedBox(height: 3),
                              Text('نقطة هذا الشهر',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.75))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Container(
                        height: 11,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: progress,
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(
                                          _shimmerController.value * 4 - 2, 0),
                                      end: const Alignment(1, 0),
                                      colors: const [
                                        Color(0xFFfbbf24),
                                        Color(0xFFfde68a),
                                        Color(0xFFfbbf24)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text('٪$percentage — باقي $remaining نقطة للجائزة الكبرى 🎁',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildPointChip('رياضة +٣٠'),
                          _buildPointChip('ذاكرة +٢٥'),
                          _buildPointChip('قراءة +٢٠'),
                          _buildPointChip('حضور +١٠'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15))),
      child: Text(text,
          style: const TextStyle(
              fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildBadgesRow() {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏅', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('شاراتي',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hc ? const Color(0xFFfbbf24) : const Color(0xFF92400e))),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBadge('🥇', 'الأول هذا الشهر', 'مكتسبة', false, 0),
              const SizedBox(width: 8),
              _buildBadge('🔥', '٧ أيام متواصلة', 'مكتسبة', false, 1),
              const SizedBox(width: 8),
              _buildBadge('🎨', 'فنان الدار', 'مكتسبة', false, 2),
              const SizedBox(width: 8),
              _buildBadge('🏆', 'بطل الشهر', '٢٣٠ نقطة', true, 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
      String icon, String name, String status, bool isLocked, int index) {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 120)),
      curve: const Cubic(0.34, 1.56, 0.64, 1),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: scale, child: child),
        );
      },
      child: AnimatedBuilder(
        animation: isLocked ? _lockController : const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          final shake =
              isLocked ? sin(_lockController.value * pi * 2) * 8 * pi / 180 : 0;
          return Transform.rotate(
            angle: shake.toDouble(),
            child: Opacity(
              opacity: isLocked ? 0.38 : 1,
              child: Container(
                width: 76,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hc ? const Color(0xFF252525) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: hc ? const Color(0xFF444444) : const Color(0xFFfde68a),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFd97706).withOpacity(hc ? 0.1 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    Text(icon,
                        style: TextStyle(
                            fontSize: 26,
                            color: isLocked ? Colors.grey : null)),
                    const SizedBox(height: 5),
                    Text(name,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: hc ? Colors.white : const Color(0xFF92400e)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(status,
                        style: TextStyle(fontSize: 9, color: hc ? Colors.white38 : Colors.grey[400])),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHonorBoard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFfde68a), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFd97706).withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌟', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('لوح الشرف — أبريل',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF92400e))),
            ],
          ),
          const SizedBox(height: 10),
          _buildHonorRow('١', 'مح', 'الحاج محمود', '٣٧٠',
              const Color(0xFFfef3c7), const Color(0xFFd97706), true),
          const Divider(color: Color(0xFFfffbeb)),
          _buildHonorRow('٢', 'فا', 'الحاجة فاطمة', '٣٤٠',
              const Color(0xFFf3f4f6), const Color(0xFF6b7280), false),
          const Divider(color: Color(0xFFfffbeb)),
          _buildHonorRow('٣', 'أح', 'الحاج أحمد', '٣١٠',
              const Color(0xFFfce7f3), const Color(0xFFbe185d), false),
        ],
      ),
    );
  }

  Widget _buildHonorRow(String rank, String initials, String name,
      String points, Color bgColor, Color textColor, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
                child: Text(rank,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor))),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: bgColor.withOpacity(0.7), shape: BoxShape.circle),
            child: Center(
                child: Text(initials,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textColor))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0f172a))),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  const Text('👑 أنت!',
                      style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFFd97706),
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          Text('$points ⭐',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFd97706))),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final double dashOffset;
  RingPainter({required this.progress, required this.dashOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 34.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * 0.62,
      );
    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

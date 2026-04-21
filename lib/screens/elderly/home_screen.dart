import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import 'widgets/permission_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _pillController;
  late AnimationController _ringController;
  late AnimationController _starController;
  late AnimationController _glowController;

  int remainingSeconds = 22 * 60; // 22 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Pill floating
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Ring pulse
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Star bounce
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Button glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pillController.dispose();
    _ringController.dispose();
    _starController.dispose();
    _glowController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m دقيقة' : '$s ثانية';
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    return Column(
      children: [
        // Hero Section
        _buildHero(provider),

        // Cards Section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildMedicineCard(provider),
                const SizedBox(height: 12),
                _buildMemoryBoxCard(provider), // Added here
                const SizedBox(height: 12),
                _buildFamilyCard(provider, context),
                const SizedBox(height: 12),
                _buildPointsCard(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryBoxCard(AppRiverpod provider) {
    final moment = provider.latestMemoryMoment;
    if (moment == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (provider.hasGalleryPermission) {
          provider.setElderlyTabIndex(3); // Navigate to Memories
        } else {
          PermissionDialog.show(
            context,
            onGranted: () {
              provider.setGalleryPermission(true);
              provider.setElderlyTabIndex(3);
            },
            onDenied: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('نحتاج للإذن لعرض معرض الصور', textAlign: TextAlign.right),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF312e81), Color(0xFF4338ca)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4338ca).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('صندوق الذكريات ✨', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(moment.activityTitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              width: 65, height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                image: DecorationImage(image: NetworkImage(moment.imageUrl), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
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
                Color(0xFF6C63FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated blobs
              _buildBlob(180, const Color(0xFF6C63FF), -50, -50, 7),
              _buildBlob(130, const Color(0xFFf472b6), -35, 30, 9),
              _buildBlob(90, const Color(0xFF0ea5e9), 80, -10, 6),

              SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    // Greeting
                    Padding(
                      padding: const EdgeInsets.only(right: 22, top: 8, bottom: 8),
                      child: Text('😊 صباح الخير يا ${provider.currentUser.name} ',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2)),
                    ),

                    // Chips
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildChip('❤️', 'الحالة', 0),
                          const SizedBox(width: 8),
                          _buildChip('${provider.todayMedications.length}', 'أدوية', 1),
                          const SizedBox(width: 8),
                          _buildChip('${provider.currentUser.points}', 'نقاطي', 2),
                          const SizedBox(width: 8),
                          _buildChip('${provider.currentUser.completedActivities}', 'نشاطات', 3),
                        ],
                      ),
                    ),
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
        final x = sin(t * (duration / 7)) * 8;
        final y = cos(t * (duration / 7)) * 10;

        return Positioned(
          right: right + x,
          top: top + y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.4),
            ),
            child: BackdropFilter(
              filter:
                  const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
              child: Container(color: Colors.transparent),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String value, String label, int index) {
    return Expanded(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child!,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(AppRiverpod provider) {
    final nextMed = provider.nextMedication;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFFA78BFA), Color(0xFFc084fc)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF)
                    .withOpacity(0.35 + (_glowController.value * 0.25)),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08)))),
                Positioned(
                    left: 20,
                    bottom: -15,
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08)))),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('💊 الجرعة القادمة',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Pill animation
                          GestureDetector(
                            onTap: () {
                              if (nextMed != null) {
                                ref.read(appRiverpod).takeMedication(nextMed.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تسجيل الجرعة بنجاح! +10 نقاط 🌟', style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                                    backgroundColor: Color(0xFF10b981),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ring pulse
                                  AnimatedBuilder(
                                    animation: _ringController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + (_ringController.value * 0.3),
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white.withOpacity(
                                                    0.55 -
                                                        (_ringController.value *
                                                            0.55)),
                                                width: 2.5),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Pill
                                  AnimatedBuilder(
                                    animation: _pillController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset:
                                            Offset(0, -6 * _pillController.value),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3))
                                            ],
                                          ),
                                          child: const Icon(Icons.touch_app,
                                              color: Color(0xFF6C63FF), size: 26),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(nextMed != null ? '${nextMed.name}\n${nextMed.dosage}' : 'كل الأدوية تم أخذها',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2),
                                    textAlign: TextAlign.right),
                                const SizedBox(height: 4),
                                Text(nextMed != null ? nextMed.timeDescription : 'ممتاز!',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⏱', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 7),
                            Text(formatTime(remainingSeconds),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (nextMed != null)
                        GestureDetector(
                          onTap: () {
                            provider.takeMedication(nextMed.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تسجيل الجرعة بنجاح! +10 نقاط 🌟', style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                                backgroundColor: Color(0xFF10b981),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.white.withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFede9fe)),
                                  child: const Icon(Icons.check,
                                      color: Color(0xFF6C63FF), size: 12),
                                ),
                                const SizedBox(width: 8),
                                const Text('أخذت الدواء ✓',
                                    style: TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      if (nextMed == null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text('أتمنى لك دوام الصحة والعافية 🌸',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
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

  Widget _buildFamilyCard(AppRiverpod provider, BuildContext context) {
    bool hc = provider.isHighContrast;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeText = provider.fontScaleFactor >= 1.25;
        final cardWidth = isLargeText 
            ? constraints.maxWidth 
            : ((constraints.maxWidth - 46) / 2).floorToDouble();
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: hc ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(hc ? 0.2 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => provider.setElderlyTabIndex(2),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      const Text('اتصل بالأسرة',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    for (int i = 0; i < provider.familyMembers.length; i += (isLargeText ? 1 : 2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            if (!isLargeText && i + 1 < provider.familyMembers.length) ...[
                              Expanded(
                                child: _buildPerson(
                                  provider.familyMembers[i + 1].name,
                                  provider.familyMembers[i + 1].relation,
                                  provider.familyMembers[i + 1].name.length >= 2 ? provider.familyMembers[i + 1].name.substring(0, 2) : provider.familyMembers[i + 1].name,
                                  provider.familyMembers[i + 1].isAvailable,
                                  [
                                    const [Color(0xFFf472b6), Color(0xFFdb2777)],
                                    const [Color(0xFF34d399), Color(0xFF059669)],
                                    const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                                    const [Color(0xFFfbbf24), Color(0xFFd97706)]
                                  ][(i + 1) % 4],
                                  provider,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (!isLargeText) ...[
                              Expanded(child: const SizedBox()), // Empty slot for balance
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: _buildPerson(
                                provider.familyMembers[i].name,
                                provider.familyMembers[i].relation,
                                provider.familyMembers[i].name.length >= 2 ? provider.familyMembers[i].name.substring(0, 2) : provider.familyMembers[i].name,
                                provider.familyMembers[i].isAvailable,
                                [
                                  const [Color(0xFFf472b6), Color(0xFFdb2777)],
                                  const [Color(0xFF34d399), Color(0xFF059669)],
                                  const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                                  const [Color(0xFFfbbf24), Color(0xFFd97706)]
                                ][i % 4],
                                provider,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerson(String name, String relation, String initials,
      bool isOnline, List<Color> gradient, AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return GestureDetector(
      onTap: () {
        if (isOnline) {
          provider.startVideoCall(name, initials);
          provider.addPoints(5);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name غير متاح حالياً، يمكنك ترك رسالة صوتية.', style: const TextStyle(fontSize: 18, fontFamily: 'Cairo'))),
          );
        }
      },
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hc ? const Color(0xFF252525) : const Color(0xFFf5f3ff),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: hc ? const Color(0xFF444444) : const Color(0xFFede9fe), width: 1.5),
          ),
          child: Stack(
            children: [
              if (isOnline)
                Positioned(
                  top: 10,
                  left: 10,
                  child: AnimatedBuilder(
                    animation: _bgController,
                    builder: (context, child) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4ade80),
                          border: Border.all(
                              color: const Color(0xFFf5f3ff), width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF4ade80).withOpacity(0.6),
                                blurRadius: 6)
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFd1d5db),
                      border:
                          Border.all(color: const Color(0xFFf5f3ff), width: 2),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: hc ? Colors.white : const Color(0xFF1f2937))),
                    const SizedBox(height: 2),
                    Text(relation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: hc ? Colors.white70 : const Color(0xFF6b7280))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(AppRiverpod provider) {
    int points = provider.currentUser.points;
    double progress = (points / 600.0).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();
    bool hc = provider.isHighContrast;
    return Container(
      decoration: BoxDecoration(
        color: hc ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(hc ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _starController,
                  builder: (context, child) {
                    final t = _starController.value * 2 * pi;
                    final y = -5 * sin(t * 2);
                    final rot = -8 * sin(t * 2) + 4 * sin(t * 4);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Transform.rotate(
                        angle: rot * pi / 180,
                        child: const Text('🏆', style: TextStyle(fontSize: 36)),
                      ),
                    );
                  },
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('⭐ $points',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF))),
                    const SizedBox(height: 4),
                    Text('من ٦٠٠ نقطة هذا الشهر',
                        style: TextStyle(
                            fontSize: 16,
                            color: hc ? Colors.white70 : Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                    color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
                    borderRadius: BorderRadius.circular(10)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: progress,
                  child: AnimatedBuilder(
                    animation: _bgController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(_bgController.value * 4 - 2, 0),
                            end: const Alignment(1, 0),
                            colors: const [
                              Color(0xFFa78bfa),
                              Color(0xFFe9d5ff),
                              Color(0xFFa78bfa)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('٪$percentage — استمر يا بطل! 💪',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7c3aed))),
          ],
        ),
      ),
    );
  }
}

// Custom painter for pill icon


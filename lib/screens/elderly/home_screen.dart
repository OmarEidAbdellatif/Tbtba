import 'dart:async'; // مكتبة المؤقتات والعمليات غير المتزامنة
import 'dart:math'; // مكتبة العمليات الرياضية
import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import '../../providers/app_riverpod.dart'; // مزود الحالة الرئيسي للتطبيق
import '../../models/app_models.dart'; // نماذج البيانات (Medication, User, etc.)
// ويدجت رفيق الذكاء الاصطناعي
// حوار طلب الصلاحيات المخصص

class HomeScreen extends ConsumerStatefulWidget {
  // شاشة المسن الرئيسية
  const HomeScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState(); // إنشاء حالة الشاشة
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // حالة الشاشة مع دعم الأنيميشن المتعدد
  late AnimationController _bgController; // متحكم أنيميشن الخلفية المتحركة
  late AnimationController _pillController; // متحكم أنيميشن طفو حبة الدواء
  late AnimationController _ringController; // متحكم أنيميشن نبض الحلقة
  late AnimationController _starController; // متحكم أنيميشن قفز النجوم
  late AnimationController _glowController; // متحكم أنيميشن توهج الأزرار

  int remainingSeconds = 22 * 60; // الوقت المتبقي للدواء (22 دقيقة افتراضياً)
  Timer? _timer; // مؤقت للعد التنازلي

  @override
  void initState() {
    // دالة التهيئة الأولية عند تشغيل الشاشة
    super.initState();

    // إعداد أنيميشن تدرج الخلفية (حركة بطيئة وهادئة)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // إعداد أنيميشن طفو حبة الدواء (حركة ترددية)
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // إعداد أنيميشن نبض الحلقة حول الزر
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // إعداد أنيميشن قفز النجوم عند كسب النقاط
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // إعداد أنيميشن توهج الأزرار للتنبيه
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // بدء مؤقت العد التنازلي كل ثانية
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--); // تحديث الواجهة عند نقصان الثواني
      }
    });
  }

  @override
  void dispose() {
    // تنظيف الموارد وإغلاق المؤقتات عند إغلاق الشاشة
    _bgController.dispose();
    _pillController.dispose();
    _ringController.dispose();
    _starController.dispose();
    _glowController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    // دالة لتحويل الثواني إلى صيغة نصية عربية
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m دقيقة' : '$s ثانية';
  }

  @override
  Widget build(BuildContext context) {
    // دالة بناء واجهة الشاشة الرئيسية
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // مساحة إضافية في الأسفل
          child: Column(
            children: [
              // قسم الترحيب العلوي (Hero)
              _buildHero(provider),
              if (provider.currentMood.isEmpty)
                _buildMoodTracker(
                    provider), // إظهار متعقب المزاج إذا لم يحدد بعد

              // قسم البطاقات الرئيسية
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _buildMedicineCard(provider), // بطاقة الدواء
                    const SizedBox(height: 12),
                    _buildFamilyCard(
                        provider, context), // بطاقة التواصل مع العائلة
                    const SizedBox(height: 12),
                    _buildPointsCard(provider), // بطاقة إجمالي النقاط
                    const SizedBox(height: 12),
                    _buildVolunteerRatingCard(provider, context), // بطاقة تقييم المتطوع
                    const SizedBox(height: 12),
                    _buildComplaintCard(provider, context), // بطاقة طلب المساعدة
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildHero(AppRiverpod provider) {
    // بناء قسم الترحيب العلوي (الـ Hero)
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // تدرج أرجواني عميق
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
              // كرات ملونة متحركة في الخلفية (Blobs) للحيوية
              _buildBlob(180, const Color(0xFF6C63FF), -50, -50, 7),
              _buildBlob(130, const Color(0xFFf472b6), -35, 30, 9),
              _buildBlob(90, const Color(0xFF0ea5e9), 80, -10, 6),

              SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نص الترحيب الصباحي باسم المستخدم
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 28, top: 15, bottom: 8),
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                            'صباح الخير يا ${provider.currentUser.name} ',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                      ),
                    ),

                    // شرائح إحصائية سريعة (أدوية، نقاط، نشاطات)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildChip('${provider.todayMedications.length}',
                              'أدوية', 1), // عدد الأدوية اليوم
                          const SizedBox(width: 8),
                          _buildChip('${provider.currentUser.points}', 'نقاطي',
                              2), // إجمالي النقاط
                          const SizedBox(width: 8),
                          _buildChip(
                              '${provider.currentUser.completedActivities}',
                              'نشاطات',
                              3), // عدد النشاطات المكتملة
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

  Widget _buildMoodTracker(AppRiverpod provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Text('طمنا عليك، كيف حالك اليوم؟ ✨',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moodItem(provider, 'happy', '😊', 'سعيد'),
              _moodItem(provider, 'calm', '😌', 'هادئ'),
              _moodItem(provider, 'tired', '😴', 'متعب'),
              _moodItem(provider, 'active', '☀️', 'بخير'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moodItem(
      AppRiverpod provider, String mood, String emoji, String label) {
    return GestureDetector(
      onTap: () => provider.setMood(mood),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFede9fe)),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748b))),
        ],
      ),
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
          left: right + x,
          top: top + y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.4),
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
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
    final remainingSeconds = provider.remainingSecondsToNextMed;
    bool hc = provider.isHighContrast;

    return AnimatedBuilder(
      animation: Listenable.merge([_bgController, _glowController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الجرعة القادمة 💊',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextMed != null
                                ? nextMed.name
                                : 'كل الأدوية تم أخذها',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextMed != null ? nextMed.dosage : '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextMed != null ? 'بعد الغداء' : 'ممتاز!',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildHandIcon(),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⏱️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            formatTime(remainingSeconds),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (nextMed != null)
                  _buildTakeMedButton(provider, nextMed, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandIcon() {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, child) {
              return Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.4 * (1 - _ringController.value)),
                    width: 5 * _ringController.value,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: const Center(
              child: Icon(Icons.touch_app, color: Color(0xFF6366F1), size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakeMedButton(
      AppRiverpod provider, Medication nextMed, BuildContext context) {
    return GestureDetector(
      onTap: () {
        provider.takeMedication(nextMed.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الجرعة بنجاح! +10 نقاط 🌟',
                style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
            backgroundColor: Color(0xFF10b981),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('أخذت الدواء ✓',
                style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Icon(Icons.check_circle_outline_rounded,
                color: const Color(0xFF6366F1).withValues(alpha: 0.3), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard(AppRiverpod provider, BuildContext context) {
    bool hc = provider.isHighContrast;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hc ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: hc ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
        border: Border.all(
            color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
            width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.phone_enabled_rounded,
                    color: Color(0xFF6C63FF), size: 28),
                SizedBox(width: 8),
                Text('اتصل بالأسرة',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF))),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: provider.familyMembers.length,
              itemBuilder: (context, index) {
                final member = provider.familyMembers[index];
                final List<Color> avatarColors = [
                  const Color(0xFFdb2777),
                  const Color(0xFF10b981),
                  const Color(0xFF6366F1),
                ];
                return _buildPerson(
                  member.name,
                  member.relation,
                  member.initials,
                  member.isAvailable,
                  avatarColors[index % avatarColors.length],
                  provider,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerson(String name, String relation, String initials,
      bool isOnline, Color color, AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return GestureDetector(
      onTap: () {
        if (isOnline) {
          provider.startVideoCall(name, initials);
          provider.addPoints(5);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('$name غير متاح حالياً، يمكنك ترك رسالة صوتية.',
                    style: const TextStyle(fontSize: 18, fontFamily: 'Cairo'))),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: hc ? const Color(0xFF252525) : const Color(0xFFf5f3ff),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: hc ? const Color(0xFF444444) : const Color(0xFFede9fe),
              width: 1.2),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? const Color(0xFF4ade80)
                      : const Color(0xFFd1d5db),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937)),
                  ),
                  Text(
                    relation,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
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
              color: const Color(0xFF6C63FF).withValues(alpha: hc ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
        border: Border.all(
            color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
            width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  // جعل قسم النصوص مرناً بالكامل
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        // يضمن أن رقم النقاط الكبير لن يسبب Overflow
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '⭐ $points',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        // يضمن أن الجملة التوضيحية لن تخرج عن حدود الكارت
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'من ٦٠٠ نقطة هذا الشهر',
                          style: TextStyle(
                              fontSize: 16,
                              color: hc ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                    color:
                        hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
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

  Widget _buildComplaintCard(AppRiverpod provider, BuildContext context) {
    bool hc = provider.isHighContrast;
    return GestureDetector(
      onTap: () => _showElderlyComplaintSheet(provider, context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: hc ? const Color(0xFF1E1E1E) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: hc ? 0.2 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ],
          border: Border.all(
              color: hc ? const Color(0xFF450a0a) : const Color(0xFFFECACA),
              width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCA5A5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.room_service_rounded,
                    color: Color(0xFFB91C1C), size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب مساعدة / شكوى',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B))),
                    Text('هل تحتاج لشيء؟ نحن هنا لخدمتك.',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFFB91C1C))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showElderlyComplaintSheet(AppRiverpod provider, BuildContext context) {
    String selectedType = 'جودة الطعام';
    final TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 24),
                const Text('أخبرنا بما يزعجك 📝',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    'جودة الطعام',
                    'صيانة الغرفة',
                    'مساعدة في التنظيف',
                    'أحتاج ممرض',
                    'أخرى'
                  ].map((type) {
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEA580C)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(type,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'اكتب تفاصيل إضافية إن أردت...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.submitComplaint(
                          descController.text.isNotEmpty
                              ? descController.text
                              : 'طلب من المسن بخصوص $selectedType',
                          selectedType,
                          'مسن');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم استلام طلبك وسيتوجه فريقنا لخدمتك فوراً 🧡',
                              style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                          backgroundColor: Color(0xFFEA580C),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('إرسال الطلب',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVolunteerRatingCard(AppRiverpod provider, BuildContext context) {
    bool hc = provider.isHighContrast;
    return GestureDetector(
      onTap: () => _showVolunteerRatingSheet(provider, context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: hc ? const Color(0xFF1E1E1E) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: hc ? 0.2 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ],
          border: Border.all(
              color: hc ? const Color(0xFF052e16) : const Color(0xFFBBF7D0),
              width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF86EFAC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism_rounded,
                    color: Color(0xFF15803D), size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('كيف كانت جلستك التطوعية؟',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534))),
                    Text('أخبرنا برأيك في المتطوع الذي زارك مؤخراً.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF15803D))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVolunteerRatingSheet(AppRiverpod provider, BuildContext context) {
    int selectedRating = 0; // 3 = happy, 2 = normal, 1 = sad

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 24),
                const Text('تقييم زيارة التطوع 🌟',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                const Text('كيف كان وقتك مع المتطوع أحمد؟',
                    style: TextStyle(fontSize: 18, color: Color(0xFF475569))),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRatingEmoji('☹️', 'غير سعيد', 1, selectedRating, () {
                      setModalState(() => selectedRating = 1);
                    }),
                    _buildRatingEmoji('😐', 'عادي', 2, selectedRating, () {
                      setModalState(() => selectedRating = 2);
                    }),
                    _buildRatingEmoji('😊', 'سعيد', 3, selectedRating, () {
                      setModalState(() => selectedRating = 3);
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: selectedRating == 0
                        ? null
                        : () {
                            provider.rateVolunteerSession('v_123', selectedRating);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('شكراً لتقييمك! نحن سعداء بخدمتك 🌸',
                                    style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                    ),
                    child: const Text('إرسال التقييم',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingEmoji(String emoji, String label, int value,
      int selectedValue, VoidCallback onTap) {
    bool isSelected = value == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected
                      ? const Color(0xFF22C55E)
                      : Colors.transparent,
                  width: 3),
            ),
            child: Text(emoji,
                style: TextStyle(fontSize: isSelected ? 48 : 36)),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected ? const Color(0xFF166534) : const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// Custom painter for pill icon

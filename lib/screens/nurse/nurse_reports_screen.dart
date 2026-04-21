import 'package:flutter/material.dart';

class NurseReportsScreen extends StatefulWidget {
  const NurseReportsScreen({super.key});

  @override
  State<NurseReportsScreen> createState() => _NurseReportsScreenState();
}

class _NurseReportsScreenState extends State<NurseReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _blinkController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _blinkController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHero(),
                const SizedBox(height: 10),
                _buildQuickSendCard(),
                const SizedBox(height: 10),
                _buildCriticalNotif(),
                const SizedBox(height: 10),
                _buildReportTypes(),
                const SizedBox(height: 10),
                _buildRecipients(),
                const SizedBox(height: 10),
                _buildScheduleSettings(),
                const SizedBox(height: 10),
                _buildReportCompleteness(),
                const SizedBox(height: 10),
                _buildSentHistory(),
                const SizedBox(height: 20),
                const SizedBox(height: 100), // Space for parent's bottom nav
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF06B6D4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 10,
            child: RotationTransition(
              turns: _spinController,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📤 التقارير والإرسال',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'أ. منى — الوردية الصباحية',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.15, end: 1.0)
                                .animate(_blinkController),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4ADE80)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text('إرسال تلقائي يومي ٨:٠٠ ص — مفعّل',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSendCard() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -3 * _floatController.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -34,
                    top: -34,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('التقرير اليومي جاهز',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.8))),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.4 *
                                              _pulseController.value),
                                      blurRadius:
                                          7 * _pulseController.value,
                                      spreadRadius:
                                          2 * _pulseController.value,
                                    )
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Text('✓',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 4),
                                    Text('آخر إرسال ٨:٠٠ ص',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text('تقرير الوردية الصباحية',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('٢٤ مقيم · ٢ حالة حرجة · ٩٢٪ التزام بالأدوية',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.75))),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.remove_red_eye_outlined,
                                      color: Color(0xFF0369A1), size: 14),
                                  SizedBox(width: 5),
                                  Text('معاينة',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0369A1))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.send_rounded,
                                      color: Colors.white, size: 13),
                                  SizedBox(width: 5),
                                  Text('إرسال الآن',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCriticalNotif() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            FadeTransition(
              opacity: Tween<double>(begin: 0.15, end: 1.0)
                  .animate(_blinkController),
              child: const Text('🚨', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إرسال تنبيه حرج — الحاج محمود',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 1),
                  Text('ضغط ١٦٠/١٠٠ · تجاوز الحد منذ ٢٣ د',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('إرسال',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0369A1))),
        ],
      ),
    );
  }

  Widget _buildReportTypes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _sectionHeader('نوع التقرير', const Color(0xFF0EA5E9)),
          Row(
            children: [
              Expanded(
                  child: _rTypeCard(
                      '📋', 'تقرير يومي', 'ملخص كامل للوردية', true)),
              const SizedBox(width: 8),
              Expanded(
                  child: _rTypeCard(
                      '📊', 'تقرير أسبوعي', 'اتجاهات ومقارنات', false)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _rTypeCard(
                      '🚨', 'تنبيه حرج', 'إرسال فوري للحالات', false)),
              const SizedBox(width: 8),
              Expanded(
                  child: _rTypeCard(
                      '💊', 'تقرير أدوية', 'الالتزام والجرعات', false)),
            ],
          )
        ],
      ),
    );
  }

  Widget _rTypeCard(String icon, String title, String desc, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: active ? const Color(0xFF0EA5E9) : const Color(0xFFE0F2FE),
            width: 1.5),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 5),
              Text(title,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(desc,
                  style:
                      const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
            ],
          ),
          if (active)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF0EA5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('✓',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold))),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildRecipients() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('المستلمون', const Color(0xFF7C3AED)),
            _recRow('د.أ', const Color(0xFFDBEAFE), const Color(0xFF1E40AF),
                'د. أحمد — الطبيب المشرف', 'يستلم: الحرجة + اليومي', true),
            const Divider(color: Color(0xFFF0F9FF), height: 12),
            _recRow('إد', const Color(0xFFEDE9FE), const Color(0xFF4C1D95),
                'الإدارة العامة', 'يستلم: الأسبوعي فقط', true),
            const Divider(color: Color(0xFFF0F9FF), height: 12),
            _recRow('أس', const Color(0xFFD1FAE5), const Color(0xFF065F46),
                'الأخصائي الاجتماعي', 'يستلم: الحرجة النفسية', true),
            const Divider(color: Color(0xFFF0F9FF), height: 12),
            _recRow('أس', const Color(0xFFFEF3C7), const Color(0xFF92400E),
                'أسر المقيمين', 'يستلمون: التقرير الأسبوعي', false),
          ],
        ),
      ),
    );
  }

  Widget _recRow(String av, Color bg, Color fg, String n, String r, bool on) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: bg,
          child: Text(av,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text(r, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),
        _toggle(on),
      ],
    );
  }

  Widget _toggle(bool on) {
    return Container(
      width: 36,
      height: 20,
      decoration: BoxDecoration(
        color: on ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            top: 2,
            left: on ? 18 : 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('إعدادات الجدول التلقائي', const Color(0xFF10B981)),
            _schRowVal('التقرير اليومي', 'يُرسل تلقائياً نهاية الوردية', '٨:٠٠ ص'),
            const Divider(color: Color(0xFFF0F9FF), height: 14),
            _schRowVal('التقرير الأسبوعي', 'كل جمعة تلقائياً', 'الجمعة'),
            const Divider(color: Color(0xFFF0F9FF), height: 14),
            _schRowTog('تنبيه القراءات الحرجة', 'إرسال فوري عند تجاوز الحد'),
            const Divider(color: Color(0xFFF0F9FF), height: 14),
            _schRowTog('تنبيه الدواء الفائت', 'بعد ٣٠ دقيقة من الموعد'),
          ],
        ),
      ),
    );
  }

  Widget _schRowVal(String lbl, String sub, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lbl,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8)),
          child: Text(val,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0369A1))),
        )
      ],
    );
  }

  Widget _schRowTog(String lbl, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lbl,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
        Row(
          children: [
            Container(
              width: 32,
              height: 18,
              decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(9)),
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    left: 14,
                    child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white)),
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text('مفعّل',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1))),
          ],
        )
      ],
    );
  }

  Widget _buildReportCompleteness() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('اكتمال التقرير اليومي', const Color(0xFF0EA5E9)),
            const SizedBox(height: 4),
            _progRow('القراءات الحيوية', '٨٧٪', 0.87, const Color(0xFF0EA5E9),
                900),
            const SizedBox(height: 9),
            _progRow(
                'تأكيد الأدوية', '٩٢٪', 0.92, const Color(0xFF10B981), 1500),
            const SizedBox(height: 9),
            _progRow(
                'ملاحظات الممرضة', '٦٠٪', 0.60, const Color(0xFFF59E0B), 1600),
            const SizedBox(height: 7),
            const Text('أكمل الملاحظات الناقصة قبل إرسال التقرير',
                style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _progRow(String title, String val, double pct, Color c, int delay) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            Text(val,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 7,
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6)),
          child: Align(
            alignment: Alignment.centerRight,
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: pct),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSentHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _sectionHeader('سجل الإرسال', const Color(0xFF10B981)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
            ),
            child: Column(
              children: [
                _histRow('📋', const Color(0xFFD1FAE5),
                    'تقرير يومي — السبت ٥ أبريل',
                    'أُرسل تلقائياً لـ ٣ جهات · ٨:٠٢ ص',
                    '✓ أُرسل',
                    const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                const Divider(color: Color(0xFFF0F9FF), height: 1),
                _histRow('🚨', const Color(0xFFFEE2E2),
                    'تنبيه حرج — الحاج محمود',
                    'أُرسل يدوياً للطبيب · أمس ٤:١٥ م',
                    '✓ أُرسل',
                    const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                const Divider(color: Color(0xFFF0F9FF), height: 1),
                _histRow('📊', const Color(0xFFDBEAFE),
                    'تقرير أسبوعي — أبريل',
                    'مجدول للجمعة القادمة',
                    '⏰ مجدول',
                    const Color(0xFFFEF3C7), const Color(0xFF92400E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _histRow(String icon, Color iconBg, String title, String meta,
      String stLabel, Color stBg, Color stFg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(meta,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration:
                BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(8)),
            child: Text(stLabel,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: stFg)),
          )
        ],
      ),
    );
  }
}

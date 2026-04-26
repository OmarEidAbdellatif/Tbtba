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
  String _selectedType = 'تقرير يومي';
  Map<String, bool> _activeRecipients = {
    'د. أحمد': true,
    'الإدارة': true,
    'الأخصائي': true,
    'الأسر': false,
  };

  String _dailyTime = '٠٨:٠٠ ص';
  String _weeklyDay = 'الجمعة';
  bool _isCriticalAlertOn = true;
  bool _isMissedMedAlertOn = true;

  String _getShiftName() {
    int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) return 'الوردية الصباحية (٦ ص - ٢ ظ)';
    if (hour >= 14 && hour < 22) return 'الوردية المسائية (٢ ظ - ١٠ م)';
    return 'الوردية الليلية (١٠ م - ٦ ص)';
  }

  @override
  void initState() {
    super.initState();
    _spinController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();

    _blinkController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
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

  void _showSendSimulation(String reportType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                  color: Color(0xFF0EA5E9), strokeWidth: 3),
              const SizedBox(height: 24),
              Text('جاري إرسال $reportType...',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      decoration: TextDecoration.none,
                      color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text('يتم الآن تشفير البيانات وإرسالها للجهات المعنية',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      decoration: TextDecoration.none,
                      fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم إرسال $reportType بنجاح ✅'),
        backgroundColor: const Color(0xFF10B981),
      ));
    });
  }

  void _showPreviewDialog(String type) {
    String title = 'معاينة $type';
    Widget content;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (type == 'تقرير أسبوعي') {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _previewRow('الأسبوع الحالي', '١٩ - ٢٦ أبريل'),
          _previewRow('نسبة الرضا العام', '٩٨٪'),
          _previewRow('متوسط الالتزام', '٩٥٪'),
          Divider(height: 24, color: isDark ? Colors.white10 : Colors.black12),
          Text('تقرير الاتجاهات:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87)),
          Text('• تحسن ملحوظ في النشاط الجماعي للمقيمين.',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black54)),
        ],
      );
    } else if (type == 'تنبيه حرج') {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️ سيتم إرسال تنبيه فوري للطبيب المشرف والإدارة',
              style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 12),
          _previewRow('المقيم', 'الحاج محمود سالم'),
          _previewRow('نوع الحالة', 'ارتفاع ضغط مفاجئ'),
          _previewRow('القراءة', '١٦٠/١٠٠'),
        ],
      );
    } else if (type == 'تقرير أدوية') {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _previewRow('إجمالي الجرعات اليوم', '٧٢ جرعة'),
          _previewRow('جرعات منفذة', '٦٨ جرعة'),
          _previewRow('جرعات متبقية', '٤ جرعات'),
          Divider(height: 24, color: isDark ? Colors.white10 : Colors.black12),
          Text('تفاصيل الجرعات المعلقة:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87)),
          Text('• بانادول اكسترا (عند اللزوم).',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black54)),
        ],
      );
    } else {
      // Daily
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _previewRow('تاريخ التقرير', '٢٦ أبريل ٢٠٢٤'),
          _previewRow('عدد المقيمين', '٢٤ مقيم'),
          _previewRow('حالات حرجة', '٢ حالة'),
          _previewRow('الالتزام بالأدوية', '٩٢٪'),
          Divider(height: 24, color: isDark ? Colors.white10 : Colors.black12),
          Text('أهم الملاحظات:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87)),
          Text('• استقرار حالة الحاج محمود بعد تعديل الجرعة.',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black54)),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: isDark ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(child: content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: TextStyle(
                      color:
                          isDark ? Colors.white38 : const Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSendSimulation(type);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: type == 'تنبيه حرج'
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0EA5E9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('إرسال الآن',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0EA5E9))),
          Text(label,
              style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B))),
        ],
      ),
    );
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
                      'أ. منى — ${_getShiftName()}',
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
                                          .withOpacity(
                                              0.4 * _pulseController.value),
                                      blurRadius: 7 * _pulseController.value,
                                      spreadRadius: 2 * _pulseController.value,
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
                                            color: Colors.white, fontSize: 10)),
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
                            child: GestureDetector(
                              onTap: () => _showPreviewDialog('التقرير اليومي'),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _showSendSimulation('التقرير اليومي'),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                          fontSize: 10, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showSendSimulation('التنبيه الحرج'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('إرسال',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
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
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0369A1))),
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
                  child: _rTypeCard('📋', 'تقرير يومي', 'ملخص كامل للوردية',
                      _selectedType == 'تقرير يومي', () {
                setState(() => _selectedType = 'تقرير يومي');
                _showPreviewDialog('تقرير يومي');
              })),
              const SizedBox(width: 8),
              Expanded(
                  child: _rTypeCard('📊', 'تقرير أسبوعي', 'اتجاهات ومقارنات',
                      _selectedType == 'تقرير أسبوعي', () {
                setState(() => _selectedType = 'تقرير أسبوعي');
                _showPreviewDialog('تقرير أسبوعي');
              })),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _rTypeCard('🚨', 'تنبيه حرج', 'إرسال فوري للحالات',
                      _selectedType == 'تنبيه حرج', () {
                setState(() => _selectedType = 'تنبيه حرج');
                _showPreviewDialog('تنبيه حرج');
              })),
              const SizedBox(width: 8),
              Expanded(
                  child: _rTypeCard('💊', 'تقرير أدوية', 'الالتزام والجرعات',
                      _selectedType == 'تقرير أدوية', () {
                setState(() => _selectedType = 'تقرير أدوية');
                _showPreviewDialog('تقرير أدوية');
              })),
            ],
          )
        ],
      ),
    );
  }

  Widget _rTypeCard(
      String icon, String title, String desc, bool active, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active
              ? (isDark
                  ? const Color(0xFF0EA5E9).withOpacity(0.2)
                  : const Color(0xFFF0F9FF))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active
                  ? const Color(0xFF0EA5E9)
                  : (isDark ? Colors.white10 : const Color(0xFFE0F2FE)),
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
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? (isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0EA5E9))
                            : (isDark
                                ? Colors.white
                                : const Color(0xFF0F172A)))),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(
                        fontSize: 9,
                        color:
                            isDark ? Colors.white38 : const Color(0xFF64748B))),
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
      ),
    );
  }

  Widget _buildRecipients() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE0F2FE),
              width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('المستلمون', const Color(0xFF7C3AED)),
            _recRow('د.أ', const Color(0xFFDBEAFE), const Color(0xFF1E40AF),
                'د. أحمد — الطبيب المشرف', 'يستلم: الحرجة + اليومي', 'د. أحمد'),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 12),
            _recRow('إد', const Color(0xFFEDE9FE), const Color(0xFF4C1D95),
                'الإدارة العامة', 'يستلم: الأسبوعي فقط', 'الإدارة'),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 12),
            _recRow('أس', const Color(0xFFD1FAE5), const Color(0xFF065F46),
                'الأخصائي الاجتماعي', 'يستلم: الحرجة النفسية', 'الأخصائي'),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 12),
            _recRow('أس', const Color(0xFFFEF3C7), const Color(0xFF92400E),
                'أسر المقيمين', 'يستلمون: التقرير الأسبوعي', 'الأسر'),
          ],
        ),
      ),
    );
  }

  Widget _recRow(
      String av, Color bg, Color fg, String n, String r, String key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isOn = _activeRecipients[key] ?? false;
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: isDark ? bg.withOpacity(0.2) : bg,
          child: Text(av,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? fg.withOpacity(0.8) : fg)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text(r,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          isDark ? Colors.white38 : const Color(0xFF64748B))),
            ],
          ),
        ),
        _toggle(isOn, () {
          setState(() {
            _activeRecipients[key] = !isOn;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isOn
                ? 'تم إيقاف الإرسال لـ $key 🛑'
                : 'تم تفعيل الإرسال لـ $key ✅'),
            duration: const Duration(seconds: 1),
          ));
        }),
      ],
    );
  }

  Widget _toggle(bool on, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          color: on
              ? const Color(0xFF0EA5E9)
              : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
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
                decoration: BoxDecoration(
                    color: isDark
                        ? (on ? Colors.white : Colors.white38)
                        : Colors.white,
                    shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE0F2FE),
              width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('إعدادات الجدول التلقائي', const Color(0xFF10B981)),
            _schRowVal(
                'التقرير اليومي', 'يُرسل تلقائياً نهاية الوردية', _dailyTime,
                () async {
              final picked = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
              if (picked != null) {
                setState(() => _dailyTime = picked.format(context));
              }
            }),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 14),
            _schRowVal('التقرير الأسبوعي', 'كل جمعة تلقائياً', _weeklyDay, () {
              _showDayPicker();
            }),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 14),
            _schRowTog('تنبيه القراءات الحرجة', 'إرسال فوري عند تجاوز الحد',
                _isCriticalAlertOn, (val) {
              setState(() => _isCriticalAlertOn = val);
            }),
            Divider(
                color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                height: 14),
            _schRowTog('تنبيه الدواء الفائت', 'بعد ٣٠ دقيقة من الموعد',
                _isMissedMedAlertOn, (val) {
              setState(() => _isMissedMedAlertOn = val);
            }),
          ],
        ),
      ),
    );
  }

  void _showDayPicker() {
    final days = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('اختر يوم التقرير الأسبوعي',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days
              .map((d) => ListTile(
                    title: Text(d,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo')),
                    onTap: () {
                      setState(() => _weeklyDay = d);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _schRowVal(String lbl, String sub, String val, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lbl,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text(sub,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          isDark ? Colors.white38 : const Color(0xFF64748B))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8)),
            child: Text(val,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1))),
          )
        ],
      ),
    );
  }

  Widget _schRowTog(String lbl, String sub, bool on, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lbl,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(sub,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : const Color(0xFF64748B))),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged(!on),
              child: Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                    color: on
                        ? const Color(0xFF0EA5E9)
                        : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(9)),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      top: 2,
                      left: on ? 14 : 2,
                      child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(on ? 'مفعّل' : 'معطّل',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: on
                        ? (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1))
                        : (isDark ? Colors.white38 : const Color(0xFF64748B)))),
          ],
        )
      ],
    );
  }

  Widget _buildReportCompleteness() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE0F2FE),
              width: 1.5),
        ),
        child: Column(
          children: [
            _sectionHeader('اكتمال التقرير اليومي', const Color(0xFF0EA5E9)),
            const SizedBox(height: 4),
            _progRow(
                'القراءات الحيوية', '٨٧٪', 0.87, const Color(0xFF0EA5E9), 900),
            const SizedBox(height: 9),
            _progRow(
                'تأكيد الأدوية', '٩٢٪', 0.92, const Color(0xFF10B981), 1500),
            const SizedBox(height: 9),
            _progRow(
                'ملاحظات الممرضة', '٦٠٪', 0.60, const Color(0xFFF59E0B), 1600),
            const SizedBox(height: 7),
            Text('أكمل الملاحظات الناقصة قبل إرسال التقرير',
                style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _progRow(String title, String val, double pct, Color c, int delay) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
            Text(val,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 7,
          decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _sectionHeader('سجل الإرسال', const Color(0xFF10B981)),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFE0F2FE),
                  width: 1.5),
            ),
            child: Column(
              children: [
                _histRow(
                    '📋',
                    isDark
                        ? const Color(0xFF065F46).withOpacity(0.2)
                        : const Color(0xFFD1FAE5),
                    'تقرير يومي — السبت ٥ أبريل',
                    'أُرسل تلقائياً لـ ٣ جهات · ٨:٠٢ ص',
                    '✓ أُرسل',
                    isDark
                        ? const Color(0xFF065F46).withOpacity(0.2)
                        : const Color(0xFFD1FAE5),
                    const Color(0xFF10B981)),
                Divider(
                    color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                    height: 1),
                _histRow(
                    '🚨',
                    isDark
                        ? const Color(0xFF7F1D1D).withOpacity(0.2)
                        : const Color(0xFFFEE2E2),
                    'تنبيه حرج — الحاج محمود',
                    'أُرسل يدوياً للطبيب · أمس ٤:١٥ م',
                    '✓ أُرسل',
                    isDark
                        ? const Color(0xFF065F46).withOpacity(0.2)
                        : const Color(0xFFD1FAE5),
                    const Color(0xFF10B981)),
                Divider(
                    color: isDark ? Colors.white10 : const Color(0xFFF0F9FF),
                    height: 1),
                _histRow(
                    '📊',
                    isDark
                        ? const Color(0xFF1E3A8A).withOpacity(0.2)
                        : const Color(0xFFDBEAFE),
                    'تقرير أسبوعي — أبريل',
                    'مجدول للجمعة القادمة',
                    '⏰ مجدول',
                    isDark
                        ? const Color(0xFF78350F).withOpacity(0.2)
                        : const Color(0xFFFEF3C7),
                    const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _histRow(String icon, Color iconBg, String title, String meta,
      String stLabel, Color stBg, Color stFg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(meta,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            isDark ? Colors.white38 : const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: stBg, borderRadius: BorderRadius.circular(8)),
            child: Text(stLabel,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: stFg)),
          )
        ],
      ),
    );
  }
}

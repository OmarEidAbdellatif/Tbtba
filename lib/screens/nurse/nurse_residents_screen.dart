import 'package:flutter/material.dart';
import 'nurse_dashboard_screen.dart';
import 'nurse_medications_screen.dart';
import 'nurse_reports_screen.dart';

class NurseResidentsScreen extends StatefulWidget {
  const NurseResidentsScreen({super.key});

  @override
  State<NurseResidentsScreen> createState() => _NurseResidentsScreenState();
}

class _NurseResidentsScreenState extends State<NurseResidentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _pulseRedController;
  late AnimationController _pulseGrnController;
  late AnimationController _floatController;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseRedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseGrnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pulseRedController.dispose();
    _pulseGrnController.dispose();
    _floatController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHero(),
                _buildSearchAndFilter(),
                _buildBody(),
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
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 ملفات المقيمين',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '٢٤ مقيم — الوردية الصباحية',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
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
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _heroChip('حرجة ٢', const Color(0xFFEF4444), blink: true),
                    _heroChip('تحذير ٥', const Color(0xFFFBBF24)),
                    _heroChip('مستقرة ١٧', const Color(0xFF4ADE80)),
                    _heroChip('جديد ١', const Color(0xFFA78BFA)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, Color dotColor, {bool blink = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          blink
              ? FadeTransition(
                  opacity: _blinkController,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: dotColor),
                  ),
                )
              : Container(
                  width: 7,
                  height: 7,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: dotColor),
                ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          color: Colors.white,
          child: Row(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ابحث بالاسم أو رقم الغرفة...',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sort_rounded,
                    color: Color(0xFF0369A1), size: 18),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE))),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _filterTab('الكل (٢٤)', true),
              _filterTab('🔴 حرجة', false),
              _filterTab('🟡 تحذير', false),
              _filterTab('✅ مستقرة', false),
              _filterTab('🆕 جديد', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterTab(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
            : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: active ? null : Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF0369A1),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildCriticalSection(),
          const SizedBox(height: 18),
          _buildWarningSection(),
          const SizedBox(height: 18),
          _buildStableSection(),
          const SizedBox(height: 18),
          _buildMoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildCriticalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FadeTransition(
              opacity: _blinkController,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'حالات تحتاج تدخل فوري',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -3 * _floatController.value),
              child: _buildResidentCard(
                name: 'الحاج محمود سالم',
                age: '٧٨ سنة',
                room: 'غرفة ١٠٣',
                diagnoses: 'ضغط + سكري',
                statusLabel: '🔴 حرجة',
                statusColor: const Color(0xFF7F1D1D),
                statusBg: const Color(0xFFFEE2E2),
                type: 'critical',
                vitals: [
                  _vitalItem('❤️', '١٦٠/١٠٠', 'ضغط', true),
                  _vitalItem('🩸', '٢٤٠', 'سكر', false, warning: true),
                  _vitalItem('🌡️', '٣٧.١', 'حرارة', false),
                  _vitalItem('💧', '٩٧٪', 'أكسجين', false),
                ],
                meds: [
                  _medDot('✓', true),
                  _medDot('!', false, critical: true),
                  _medDot('!', false, critical: true),
                  _medDot('—', false, empty: true),
                ],
                medPercentage: '٣٣٪',
                note: 'آخر ملاحظة: ارتفاع حاد في الضغط — يحتاج مراجعة الطبيب فوراً',
                actions: [
                  _actionBtn('🚨 طوارئ',
                      color: const Color(0xFFEF4444),
                      bg: const Color(0xFFFFF5F5),
                      border: const Color(0xFFFCA5A5)),
                  _actionBtn('📋 الملف الكامل',
                      color: Colors.white,
                      isPrimary: true,
                      bg: const Color(0xFF0369A1)),
                  _actionBtn('📥 قراءة',
                      color: const Color(0xFF0369A1),
                      bg: const Color(0xFFF0F9FF),
                      border: const Color(0xFFBAE6FD)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWarningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'تحتاج متابعة دقيقة',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildResidentCard(
          name: 'الحاجة فاطمة علي',
          age: '٧٢ سنة',
          room: 'غرفة ١٠٧',
          diagnoses: 'قلب وأوعية',
          statusLabel: '🟡 تحذير',
          statusColor: const Color(0xFF92400E),
          statusBg: const Color(0xFFFEF3C7),
          type: 'warning',
          vitals: [
            _vitalItem('❤️', '١٤٥/٩٢', 'ضغط', false, warning: true),
            _vitalItem('🩸', '١٢٠', 'سكر', false),
            _vitalItem('🌡️', '٣٦.٨', 'حرارة', false),
            _vitalItem('💧', '٩٨٪', 'أكسجين', false),
          ],
          meds: [
            _medDot('✓', true),
            _medDot('⏰', false, warning: true),
            _medDot('—', false, empty: true),
            _medDot('—', false, empty: true),
          ],
          medPercentage: '٥٠٪',
          note: 'الضغط في ارتفاع تدريجي — تحتاج مراقبة كل ساعتين',
          actions: [
            _actionBtn('📋 الملف الكامل',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
            _actionBtn('📥 قراءة',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
            _actionBtn('💬 ملاحظة',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
          ],
        ),
      ],
    );
  }

  Widget _buildStableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'مستقرة — لا تحتاج تدخل',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildResidentCard(
          name: 'الحاج أحمد كمال',
          age: '٦٩ سنة',
          room: 'غرفة ١١٢',
          diagnoses: 'مستقر',
          statusLabel: '✅ ممتاز',
          statusColor: const Color(0xFF065F46),
          statusBg: const Color(0xFFD1FAE5),
          type: 'stable',
          vitals: [
            _vitalItem('❤️', '١٢٠/٨٠', 'ضغط', false),
            _vitalItem('🩸', '١١٠', 'سكر', false),
            _vitalItem('🌡️', '٣٦.٦', 'حرارة', false),
            _vitalItem('💧', '٩٩٪', 'أكسجين', false),
          ],
          meds: [
            _medDot('✓', true),
            _medDot('—', false, empty: true),
            _medDot('—', false, empty: true),
            _medDot('○', false, warning: true),
          ],
          medPercentage: '٨٠٪',
          note: 'جميع القراءات طبيعية — نشاط بدني ممتاز هذا الأسبوع',
          actions: [
            _actionBtn('📋 الملف الكامل',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
            _actionBtn('📥 قراءة',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
            _actionBtn('💬 ملاحظة',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
          ],
        ),
        const SizedBox(height: 8),
        _buildResidentCard(
          name: 'الحاجة سمية إبراهيم',
          age: '٦٥ سنة',
          room: 'غرفة ١١٥',
          diagnoses: 'مستقرة',
          statusLabel: '✅ جيد',
          statusColor: const Color(0xFF065F46),
          statusBg: const Color(0xFFD1FAE5),
          type: 'stable',
          vitals: [
            _vitalItem('❤️', '١٢٥/٨٢', 'ضغط', false),
            _vitalItem('🩸', '١٠٥', 'سكر', false),
            _vitalItem('🌡️', '٣٦.٧', 'حرارة', false),
            _vitalItem('💧', '٩٨٪', 'أكسجين', false),
          ],
          meds: [],
          medPercentage: '',
          note: '',
          actions: [
            _actionBtn('📋 الملف الكامل',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
            _actionBtn('📥 قراءة',
                color: const Color(0xFF0369A1),
                bg: const Color(0xFFF0F9FF),
                border: const Color(0xFFBAE6FD)),
          ],
        ),
      ],
    );
  }

  Widget _buildResidentCard({
    required String name,
    required String age,
    required String room,
    required String diagnoses,
    required String statusLabel,
    required Color statusColor,
    required Color statusBg,
    required List<Widget> vitals,
    required String type,
    List<Widget>? meds,
    String? medPercentage,
    String? note,
    required List<Widget> actions,
  }) {
    Color cardBorder;
    Color headerBg;
    Color avBg;
    Color avFg;
    Color pipColor;
    bool showPulse = false;

    if (type == 'critical') {
      cardBorder = const Color(0xFFFCA5A5);
      headerBg = const Color(0xFFFFF5F5);
      avBg = const Color(0xFFFFE4E6);
      avFg = const Color(0xFF9F1239);
      pipColor = const Color(0xFFEF4444);
      showPulse = true;
    } else if (type == 'warning') {
      cardBorder = const Color(0xFFFDE68A);
      headerBg = const Color(0xFFFFFBEB);
      avBg = const Color(0xFFFEF3C7);
      avFg = const Color(0xFF92400E);
      pipColor = const Color(0xFFF59E0B);
    } else {
      cardBorder = const Color(0xFFE0F2FE);
      headerBg = const Color(0xFFF0FDF4);
      avBg = const Color(0xFFD1FAE5);
      avFg = const Color(0xFF065F46);
      pipColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            color: headerBg,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: avBg,
                      child: Text(
                        name.substring(0, 2),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: avFg),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      left: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: pipColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: showPulse
                            ? ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.2)
                                    .animate(_pulseRedController),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(age,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B))),
                            const Text(' · ',
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B))),
                            Text(room,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B))),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 1),
                              decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Text(diagnoses,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(9)),
                      child: Text(statusLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor)),
                    ),
                    const SizedBox(height: 4),
                    const Text('منذ ٢٣ د',
                        style:
                            TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          // Vitals Strip
          Container(
            height: 1,
            color: const Color(0xFFF0F9FF),
          ),
          Container(
            color: Colors.white,
            child: Row(
              children: vitals,
            ),
          ),
          // Meds Row
          if (meds != null && meds.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF0F9FF))),
                  color: Colors.white),
              child: Row(
                children: [
                  const Text('💊 أدوية اليوم',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  const Spacer(),
                  Row(children: meds),
                  const SizedBox(width: 8),
                  Text(medPercentage ?? '',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1))),
                ],
              ),
            ),
          ],
          // Note Preview
          if (note != null && note.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF0F9FF))),
                  color: Color(0xFFF8FAFC)),
              child: Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F9FF))),
                color: Colors.white),
            child: Row(
              children: actions
                  .map((a) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: a == actions.last ? 0 : 6),
                          child: a,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalItem(String icon, String val, String lbl, bool isCritical,
      {bool warning = false}) {
    Color valColor = const Color(0xFF10B981);
    if (isCritical) {
      valColor = const Color(0xFFEF4444);
    } else if (warning) {
      valColor = const Color(0xFFF59E0B);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFF0F9FF))),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(val,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: valColor)),
            Text(lbl, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _medDot(String txt, bool success,
      {bool critical = false, bool warning = false, bool empty = false}) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF94A3B8);

    if (success) {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (critical) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF7F1D1D);
    } else if (warning) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    Widget content = Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Center(
        child: Text(txt,
            style: TextStyle(
                fontSize: 8, fontWeight: FontWeight.bold, color: fg)),
      ),
    );

    if (critical) {
      return FadeTransition(opacity: _blinkController, child: content);
    }
    return content;
  }

  Widget _actionBtn(String label,
      {required Color color,
      required Color bg,
      Color? border,
      bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
            : null,
        color: isPrimary ? null : bg,
        borderRadius: BorderRadius.circular(10),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5, style: BorderStyle.solid),
      ),
      child: const Text(
        '+ ٢٠ مقيم آخر — اضغط لتحميل المزيد',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
      ),
    );
  }

}

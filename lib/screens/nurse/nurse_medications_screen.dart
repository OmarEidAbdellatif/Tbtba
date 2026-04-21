import 'package:flutter/material.dart';

class NurseMedicationsScreen extends StatefulWidget {
  const NurseMedicationsScreen({super.key});

  @override
  State<NurseMedicationsScreen> createState() => _NurseMedicationsScreenState();
}

class _NurseMedicationsScreenState extends State<NurseMedicationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHero(),
          _buildPeriodTabs(),
          _buildSearchFilter(),
          const SizedBox(height: 10),
          _buildOverallProgress(),
          const SizedBox(height: 10),
          _buildResidentBlocks(),
          const SizedBox(height: 10),
          _buildGlobalActions(),
          const SizedBox(height: 100), // Space for the parent's bottom nav
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💊 جدول الأدوية',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الأحد ٦ أبريل — الوردية الصباحية',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11),
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _heroChip('مكتمل ١٨', const Color(0xFF4ADE80), false),
                    _heroChip('فائت ٣', const Color(0xFFEF4444), true),
                    _heroChip('قادم ٧', const Color(0xFFFBBF24), false),
                    _heroChip('متبقي ١٢', const Color(0xFF94A3B8), false),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, Color dotColor, bool isBlink) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBlink)
            FadeTransition(
              opacity: Tween<double>(begin: 0.15, end: 1.0)
                  .animate(_blinkController),
              child: Container(
                  width: 7,
                  height: 7,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: dotColor)),
            )
          else
            Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE)))),
      child: Row(
        children: [
          _periodTab('🌅', 'الصباح', '٨/٨ ✓', const Color(0xFFD1FAE5),
              const Color(0xFF065F46), false),
          _periodTab('☀️', 'الظهر', '٢ فائت', const Color(0xFFFEE2E2),
              const Color(0xFF7F1D1D), true),
          _periodTab('🌆', 'المساء', '٧ قادم', const Color(0xFFFEF3C7),
              const Color(0xFF92400E), false),
          _periodTab('🌙', 'الليل', '١٢ قادم', const Color(0xFFFEF3C7),
              const Color(0xFF92400E), false),
        ],
      ),
    );
  }

  Widget _periodTab(String icon, String label, String count, Color bg,
      Color textC, bool active) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: active ? const Color(0xFF0EA5E9) : Colors.transparent,
                width: 2.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? const Color(0xFF0369A1)
                        : const Color(0xFF64748B))),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(8)),
              child: Text(count,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold, color: textC)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE)))),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('ابحث باسم المقيم أو الدواء...',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 48,
          color: const Color(0xFFF8FAFC),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip('الكل (٢٤)', true),
                _filterChip('فائت 🔴', false),
                _filterChip('قادم ⏰', false),
                _filterChip('مكتمل ✅', false),
                _filterChip('الغرفة', false),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _filterChip(String text, bool act) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: act ? null : Colors.white,
        gradient: act
            ? const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: act ? Colors.transparent : const Color(0xFFBAE6FD)),
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: act ? Colors.white : const Color(0xFF0369A1))),
      ),
    );
  }

  Widget _buildOverallProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.64,
                    backgroundColor: const Color(0xFFE0F2FE),
                    color: const Color(0xFF0EA5E9),
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('٦٤٪',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0369A1))),
                      Text('اليوم',
                          style: TextStyle(
                              fontSize: 7, color: Color(0xFF94A3B8))),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _statRow('✅ مكتملة', '١٨ جرعة', const Color(0xFF10B981)),
                  _statRow('❌ فائتة', '٣ جرعات', const Color(0xFFEF4444)),
                  _statRow('⏰ قادمة', '٧ جرعات', const Color(0xFFF59E0B)),
                  _statRow(
                      '📊 الالتزام الأسبوعي', '٩٢٪', const Color(0xFF0369A1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String lbl, String val, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lbl,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          Text(val,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  Widget _buildResidentBlocks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _buildCriticalCard(),
          const SizedBox(height: 10),
          _buildWarningCard(),
          const SizedBox(height: 10),
          _buildStableCard(),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Text(
              '+ ٢١ مقيم آخر — اضغط لعرض الكل',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0369A1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCriticalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
                color: Color(0xFFFFF5F5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFFFE4E6),
                        child: const Text('مح',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9F1239)))),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444)
                                      .withOpacity(0.55 * _pulseController.value),
                                  blurRadius: 7 * _pulseController.value,
                                  spreadRadius: 2 * _pulseController.value,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('الحاج محمود سالم — غرفة ١٠٣',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('٧٨ سنة · ضغط + سكري · ٤ أدوية',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('🔴 حرجة',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F1D1D)))),
              ],
            ),
          ),
          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _gridHeader(),
                _drugRow('أسبرين ١٠٠', 'قرص — مع الأكل', _done(), _miss(),
                    _pend(), _na()),
                _drugRow('ميتفورمين ٥٠٠', 'قرص — قبل الأكل', _done(), _miss(),
                    _pend(), _pend()),
                _drugRow('أملوديبين ٥', 'قرص — صباحاً', _done(), _na(), _na(),
                    _na(),
                    isLast: true),
              ],
            ),
          ),
          // Progress
          _progressBar('٣٣٪', 0.33, const Color(0xFFEF4444)),
          // Footer
          _actionFooter([
            _btn('🚨 تنبيه عاجل', const Color(0xFFFEE2E2),
                const Color(0xFFEF4444), const Color(0xFFFCA5A5)),
            _btn('✓ تأكيد الجرعة الفائتة', const Color(0xFF0369A1),
                Colors.white, Colors.transparent,
                isGrad: true),
            _btn('📋 ملف', const Color(0xFFF0F9FF), const Color(0xFF0369A1),
                const Color(0xFFBAE6FD)),
          ]),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFFEF3C7),
                        child: const Text('فا',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E)))),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('الحاجة فاطمة علي — غرفة ١٠٧',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('٧٢ سنة · قلب وأوعية · ٣ أدوية',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('🟡 تحذير',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E)))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _gridHeader(),
                _drugRow('أملوديبين ٥', 'قرص — صباحاً', _done(), _na(), _na(),
                    _na()),
                _drugRow(
                    'واترفارين ٣', 'قرص — مع الغداء', _na(), _now(), _na(), _na()),
                _drugRow('أتورفاستاتين ٢٠', 'قرص — قبل النوم', _na(), _na(),
                    _na(), _pend(),
                    isLast: true),
              ],
            ),
          ),
          _progressBar('٥٠٪', 0.5, const Color(0xFFF59E0B)),
          _actionFooter([
            _btn('✓ تأكيد واترفارين', const Color(0xFF0369A1), Colors.white,
                Colors.transparent,
                isGrad: true),
            _btn('📋 ملف', const Color(0xFFF0F9FF), const Color(0xFF0369A1),
                const Color(0xFFBAE6FD)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF0F9FF)))),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFD1FAE5),
                        child: const Text('أح',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46)))),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('الحاج أحمد كمال — غرفة ١١٢',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('٦٩ سنة · مستقر · ٢ دواء',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('✅ مستقر',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46)))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _gridHeader(),
                _drugRow('أتورفاستاتين ٢٠', 'قرص — قبل النوم', _na(), _na(),
                    _na(), _pend()),
                _drugRow('فيتامين د ١٠٠٠', 'كبسولة — الصباح', _done(), _na(),
                    _na(), _na(),
                    isLast: true),
              ],
            ),
          ),
          _progressBar('٨٠٪', 0.8, const Color(0xFF10B981)),
          _actionFooter([
            Expanded(
                flex: 2,
                child: _btn('📋 عرض الملف الكامل', const Color(0xFFF0F9FF),
                    const Color(0xFF0369A1), const Color(0xFFBAE6FD))),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _btn('✓ ممتاز', const Color(0xFFF0FDF4),
                      const Color(0xFF10B981), const Color(0xFFA7F3D0)),
                )),
          ], isExpanded: false),
        ],
      ),
    );
  }

  Widget _gridHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: const [
          Expanded(
              child: Text('الدواء',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8)))),
          SizedBox(
              width: 48,
              child: Text('ص',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8)))),
          SizedBox(
              width: 48,
              child: Text('ظ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8)))),
          SizedBox(
              width: 48,
              child: Text('م',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8)))),
          SizedBox(
              width: 48,
              child: Text('ل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8)))),
        ],
      ),
    );
  }

  Widget _drugRow(String n, String d, Widget c1, Widget c2, Widget c3, Widget c4,
      {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: isLast ? Colors.transparent : const Color(0xFFF8FAFC)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                Text(d,
                    style: const TextStyle(
                        fontSize: 9, color: Color(0xFF64748B))),
              ],
            ),
          ),
          SizedBox(width: 48, child: Center(child: c1)),
          SizedBox(width: 48, child: Center(child: c2)),
          SizedBox(width: 48, child: Center(child: c3)),
          SizedBox(width: 48, child: Center(child: c4)),
        ],
      ),
    );
  }

  Widget _circ(String txt, Color bg, Color textC, {bool blink = false}) {
    Widget child = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Center(
        child: Text(txt,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: textC)),
      ),
    );
    if (blink) {
      child = FadeTransition(
          opacity:
              Tween<double>(begin: 0.15, end: 1.0).animate(_blinkController),
          child: child);
    }
    return child;
  }

  Widget _done() =>
      _circ('✓', const Color(0xFFD1FAE5), const Color(0xFF065F46));
  Widget _miss() =>
      _circ('!', const Color(0xFFFEE2E2), const Color(0xFFEF4444), blink: true);
  Widget _pend() => _circ('○', const Color(0xFFF1F5F9), const Color(0xFF94A3B8));
  Widget _na() => const Text('—',
      style: TextStyle(fontSize: 9, color: Color(0xFFE2E8F0)));
  Widget _now() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])),
      child: const Center(
        child: Text('⏰', style: TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _progressBar(String txt, double perc, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الالتزام اليومي',
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              Text(txt,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: perc,
              child: Container(
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _actionFooter(List<Widget> btns, {bool isExpanded = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: isExpanded
            ? btns
                .map((b) => Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: b == btns.last ? 0 : 7),
                        child: b)))
                .toList()
            : btns,
      ),
    );
  }

  Widget _btn(String txt, Color bg, Color fg, Color borderC,
      {bool isGrad = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isGrad ? null : bg,
        gradient: isGrad
            ? const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderC),
      ),
      child: Center(
        child: Text(txt,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
      ),
    );
  }

  Widget _buildGlobalActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  border:
                      Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('📤 إرسال تقرير',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1)))),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)]),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('✓ تأكيد جماعي',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}

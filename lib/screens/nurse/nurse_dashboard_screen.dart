import 'dart:async';
import 'package:flutter/material.dart';
import 'nurse_reports_screen.dart';
import 'nurse_residents_screen.dart';
import 'views/medical_admin_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../widgets/taptaba_drawer.dart';
import '../../widgets/taptaba_scaffold.dart';

class NurseDashboardScreen extends ConsumerStatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  ConsumerState<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends ConsumerState<NurseDashboardScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  int _timerMins = 4;
  int _timerSecs = 38;
  Timer? _timer;

  late AnimationController _pulseController;
  late AnimationController _spinController;

  final TextEditingController _oxygenController = TextEditingController(text: '٩٧٪');

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _spinController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timerSecs > 0) {
          _timerSecs--;
        } else {
          if (_timerMins > 0) {
            _timerMins--;
            _timerSecs = 59;
          } else {
            _timer?.cancel();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _spinController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: const Color(0xFF0369A1),
      overrideRole: 'ممرض',
      bottomNavigationBar: _buildBottomNav(),
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                _buildHomeView(),
                const NurseResidentsScreen(),
                const MedicalAdminView(),
                const NurseReportsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPIs(),
          _buildTabs(),
          _buildResidentsSection(),
          _buildMedScheduleSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        ),
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 8,
            child: RotationTransition(
              turns: _spinController,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏥 لوحة المشرف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أ. منى — الوردية الصباحية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _pulseController,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFCA5A5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '٢ حالة تحتاج تدخل فوري',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الوردية تنتهي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${_timerMins}:${_timerSecs.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildKPICard('${ref.watch(appRiverpod).totalResidentsCount}', 'إجمالي المقيمين', 'جميعهم نشطون',
              const Color(0xFF0369A1), const Color(0xFF10B981)),
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).criticalResidentsCount}', 'حالات حرجة', 'تحتاج متابعة',
              const Color(0xFFEF4444), const Color(0xFFEF4444)),
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).medications.where((m) => !m.isTaken).length}', 'جرعات متبقية', 'هذا الصباح',
              const Color(0xFF0369A1), const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).compliancePercentage}٪', 'الالتزام بالدواء', 'هذا الأسبوع',
              const Color(0xFF0369A1), const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String val, String lbl, String sub, Color valColor,
      Color subColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0F2FE)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lbl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: subColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['الكل', 'حرجة 🔴', 'تحذير 🟡', 'مستقرة ✅', 'دواء متأخر'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: tabs.map((t) {
          final isAct = t == 'الكل';
          return Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: isAct
                  ? const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
                  : null,
              color: isAct ? null : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isAct ? Colors.transparent : const Color(0xFFBAE6FD)),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAct ? Colors.white : const Color(0xFF0369A1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0369A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('المقيمون — حسب الأولوية', const Color(0xFFEF4444)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _buildResCard(
                name: 'الحاج محمود — غرفة ١٠٣',
                room: '٧٨ سنة · متابعة دورية',
                av: 'مح',
                avBg: const Color(0xFFFFE4E6),
                avColor: const Color(0xFF9F1239),
                statusColor: const Color(0xFFEF4444),
                borderColor: const Color(0xFFFCA5A5),
                bg: const Color(0xFFFFF5F5),
                btnText: 'تدخّل',
                btnColor: const Color(0xFFEF4444),
                vitals: [
                  _vitalChip('💧 ٩٧٪', const Color(0xFFF0FDF4),
                      const Color(0xFF16A34A)),
                ],
                warnText: '⏰ ميتفورمين — فات موعده منذ ٣٠ د',
              ),
              const SizedBox(height: 8),
              _buildResCard(
                name: 'الحاجة فاطمة — غرفة ١٠٧',
                room: '٧٢ سنة · أمراض قلب',
                av: 'فا',
                avBg: const Color(0xFFFEF3C7),
                avColor: const Color(0xFF92400E),
                statusColor: const Color(0xFFF59E0B),
                borderColor: const Color(0xFFFDE68A),
                bg: Colors.white,
                btnText: 'تأكيد',
                btnColor: const Color(0xFF0EA5E9),
                vitals: [
                  _vitalChip('💧 ٩٨٪', const Color(0xFFF0FDF4),
                      const Color(0xFF16A34A)),
                ],
                warnText: '⏰ أملوديبين — باقي ١٥ دقيقة',
              ),
              const SizedBox(height: 8),
              _buildResCard(
                name: 'الحاج أحمد — غرفة ١١٢',
                room: '٦٩ سنة · مستقر',
                av: 'أح',
                avBg: const Color(0xFFD1FAE5),
                avColor: const Color(0xFF065F46),
                statusColor: const Color(0xFF10B981),
                borderColor: const Color(0xFFE0F2FE),
                bg: Colors.white,
                btnText: 'تفاصيل',
                btnColor: const Color(0xFF10B981),
                vitals: [
                  _vitalChip('💧 ٩٩٪', const Color(0xFFF0FDF4),
                      const Color(0xFF16A34A)),
                ],
                warnText: '✓ جميع أدويته مكتملة اليوم',
                isStable: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vitalChip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResCard({
    required String name,
    required String room,
    required String av,
    required Color avBg,
    required Color avColor,
    required Color statusColor,
    required Color borderColor,
    required Color bg,
    required String btnText,
    required Color btnColor,
    required List<Widget> vitals,
    required String warnText,
    bool isStable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (!isStable)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: avBg,
                      child: Text(
                        av,
                        style: TextStyle(
                            color: avColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(room,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 4, children: vitals),
                      const SizedBox(height: 6),
                      Text(
                        warnText,
                        style: TextStyle(
                            fontSize: 11,
                            color: isStable
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0369A1)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(btnText,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إدخال قراءات — الحاج محمود', const Color(0xFF0EA5E9)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
            ),
            child: Column(
              children: [
                _inputRow('💧', 'تشبع الأكسجين', _oxygenController, 'SpO₂',
                    const Color(0xFFF0FDF4), false),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      ref.read(appRiverpod).saveMedicalVitals('الحاج محمود', {
                        'oxygen': _oxygenController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حفظ القراءات وتحديث ملف المريض بنجاح ✅',
                              style: TextStyle(fontFamily: 'Cairo')),
                          backgroundColor: Color(0xFF0369A1),
                        ),
                      );
                    },
                    child: const Text('💾 حفظ القراءات',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputRow(String emoji, String lbl, TextEditingController controller,
      String unit, Color bg, bool hasBtn) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(lbl,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        Container(
          width: 80,
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(unit,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ),
        const SizedBox(width: 8),
        if (hasBtn)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('🔗 جهاز',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        else
          const SizedBox(width: 58)
      ],
    );
  }



  Widget _bar(double h, Color c) {
    return Expanded(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: h),
        builder: (context, val, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: val,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedScheduleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('جدول الأدوية — اليوم', const Color(0xFF6366F1)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Row(
                    children: [
                      const Expanded(
                          child: Text('الدواء / المقيم',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B)))),
                      _medH('ص'),
                      _medH('ظ'),
                      _medH('م'),
                      _medH('ل'),
                    ],
                  ),
                ),
                _medRow('الحاج محمود', 'ميتفورمين + أسبرين', '✓', '!', '-', '-'),
                const Divider(height: 1, color: Color(0xFFF0F9FF)),
                _medRow('الحاجة فاطمة', 'أملوديبين + واتس', '✓', '⏰', '-', '-'),
                const Divider(height: 1, color: Color(0xFFF0F9FF)),
                _medRow('الحاج أحمد', 'أتورفاستاتين', '✓', '—', '—', '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medH(String txt) {
    return SizedBox(
        width: 40,
        child: Text(txt,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B))));
  }

  Widget _medRow(String n, String s, String d1, String d2, String d3, String d4) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                Text(s,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          _doseCell(d1),
          _doseCell(d2),
          _doseCell(d3),
          _doseCell(d4),
        ],
      ),
    );
  }

  Widget _doseCell(String st) {
    Color bg = const Color(0xFFF3F4F6);
    Color fg = const Color(0xFF9CA3AF);
    if (st == '✓') {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (st == '!') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF7F1D1D);
    } else if (st == '⏰') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    return SizedBox(
      width: 40,
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(
            child: Text(st,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0F2FE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard_rounded, 'الرئيسية', _currentTabIndex == 0, onTap: () => setState(() => _currentTabIndex = 0)),
          _navItem(Icons.people_alt_rounded, 'المقيمين', _currentTabIndex == 1, onTap: () => setState(() => _currentTabIndex = 1)),
          _navItem(Icons.medical_services_rounded, 'الإدارة الطبية', _currentTabIndex == 2, onTap: () => setState(() => _currentTabIndex = 2)),
          _navItem(Icons.receipt_long_rounded, 'التقارير', _currentTabIndex == 3, onTap: () => setState(() => _currentTabIndex = 3)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF0369A1) : const Color(0xFF9CA3AF)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? const Color(0xFF0369A1) : const Color(0xFF9CA3AF)),
          ),
          if (active) ...[
            const SizedBox(height: 2),
            Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0369A1)))
          ]
        ],
      ),
    );
  }
}

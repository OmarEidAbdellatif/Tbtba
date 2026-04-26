import 'dart:async';
import 'package:flutter/material.dart';
import 'nurse_reports_screen.dart';
import 'nurse_residents_screen.dart';
import 'nurse_resident_detail_screen.dart';
import 'nurse_profile_screen.dart';
import 'shift_handoff_screen.dart';
import 'views/medical_admin_view.dart';
import 'views/operations_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
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
  Timer? _timer;

  late AnimationController _pulseController;
  late AnimationController _spinController;

  final TextEditingController _bpController = TextEditingController(text: '١٢٠/٨٠');
  final TextEditingController _sugarController = TextEditingController(text: '٩٥');

  String _selectedFilter = 'الكل';

  void _startShiftTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      DateTime shiftEnd;
      
      if (now.hour >= 6 && now.hour < 14) {
        shiftEnd = DateTime(now.year, now.month, now.day, 14, 0, 0);
      } else if (now.hour >= 14 && now.hour < 22) {
        shiftEnd = DateTime(now.year, now.month, now.day, 22, 0, 0);
      } else {
        // Night shift ends at 6 AM tomorrow or today if it's before 6 AM
        if (now.hour >= 22) {
          shiftEnd = DateTime(now.year, now.month, now.day + 1, 6, 0, 0);
        } else {
          shiftEnd = DateTime(now.year, now.month, now.day, 6, 0, 0);
        }
      }

      final diff = shiftEnd.difference(now);
      if (diff.isNegative) {
        // Should not happen with logic above, but safety first
        _timerHours = 0;
        _timerMins = 0;
        _timerSecs = 0;
      } else {
        setState(() {
          _timerHours = diff.inHours;
          _timerMins = diff.inMinutes % 60;
          _timerSecs = diff.inSeconds % 60;
        });
      }
    });
  }

  int _timerHours = 0;
  int _timerMins = 0;
  int _timerSecs = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _spinController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _startShiftTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _spinController.dispose();
    _bpController.dispose();
    _sugarController.dispose();
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
      floatingActionButton: _buildEmergencyFAB(),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeView(provider),
          const NurseResidentsScreen(),
          const OperationsView(),
          const MedicalAdminView(),
          const NurseReportsScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeView(AppRiverpod provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHero(),
          _buildOperationalAlerts(provider),
          _buildShiftHandoffCard(provider),
          _buildKPIs(),
          _buildTabs(),
          _buildResidentsSection(provider),
          _buildMedScheduleSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOperationalAlerts(AppRiverpod provider) {
    final lowStockItems = provider.inventoryItems.where((i) => i.isLowStock).toList();
    final pendingTasks = provider.careTasks.where((t) => !t.isCompleted).toList();

    if (lowStockItems.isEmpty && pendingTasks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          if (lowStockItems.isNotEmpty)
            _alertCard(
              'نقص في المخزون! 📦',
              'يوجد ${lowStockItems.length} أصناف أوشكت على النفاذ',
              const Color(0xFFEF4444),
              () => setState(() => _currentTabIndex = 2), // Go to Operations
            ),
          if (pendingTasks.isNotEmpty)
            const SizedBox(height: 8),
          if (pendingTasks.isNotEmpty)
            _alertCard(
              'مهام رعاية معلقة ✅',
              'لديك ${pendingTasks.length} مهام متبقية لليوم',
              const Color(0xFFF59E0B),
              () => setState(() => _currentTabIndex = 2), // Go to Operations
            ),
        ],
      ),
    );
  }

  Widget _alertCard(String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF64748B)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(sub, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftHandoffCard(AppRiverpod provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
          boxShadow: [BoxShadow(color: const Color(0xFF0369A1).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.sync_alt_rounded, color: Color(0xFF0EA5E9), size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('إدارة تسليم الوردية 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('جاهز للتسليم؟ قم بتجهيز تقريرك الآن', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('السجلات السابقة', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShiftHandoffScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0369A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('بدء التسليم الآن', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getShiftName() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) return 'الوردية الصباحية (٦ ص - ٢ ظ)';
    if (hour >= 14 && hour < 22) return 'الوردية المسائية (٢ ظ - ١٠ م)';
    return 'الوردية الليلية (١٠ م - ٦ ص)';
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
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NurseProfileScreen())),
                      child: Text(
                        'أ. منى — ${_getShiftName()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
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
                      '${_timerHours}:${_timerMins.toString().padLeft(2, '0')}:${_timerSecs.toString().padLeft(2, '0')}',
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
          final isAct = t == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = t),
            child: Container(
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

  Widget _vitalChip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildResidentsSection(AppRiverpod provider) {
    String getLatestNote(String name) {
      final cleanName = name.split(' — ')[0];
      final notes = provider.getNotesForResident(cleanName);
      return notes.isNotEmpty ? '${notes.first.title}: ${notes.first.content}' : '';
    }

    List<Widget> residents = [
      _buildResCard(
        name: 'الحاج محمود سالم — غرفة ١٠٣',
        room: '٧٨ سنة · متابعة دورية',
        av: 'مح',
        avBg: const Color(0xFFFFE4E6),
        avColor: const Color(0xFF9F1239),
        statusColor: const Color(0xFFEF4444),
        borderColor: const Color(0xFFFCA5A5),
        bg: const Color(0xFFFFF5F5),
        btnText: 'تدخّل',
        btnColor: const Color(0xFFEF4444),
        warnText: '⏰ ميتفورمين — فات موعده منذ ٣٠ د',
        category: 'حرجة 🔴',
        note: getLatestNote('الحاج محمود سالم'),
      ),
      _buildResCard(
        name: 'الحاجة فاطمة علي — غرفة ١٠٧',
        room: '٧٢ سنة · أمراض قلب',
        av: 'فا',
        avBg: const Color(0xFFFEF3C7),
        avColor: const Color(0xFF92400E),
        statusColor: const Color(0xFFF59E0B),
        borderColor: const Color(0xFFFDE68A),
        bg: Colors.white,
        btnText: 'تأكيد',
        btnColor: const Color(0xFF0EA5E9),
        warnText: '⏰ أملوديبين — باقي ١٥ دقيقة',
        category: 'تحذير 🟡',
        note: getLatestNote('الحاجة فاطمة علي'),
      ),
      _buildResCard(
        name: 'الحاج أحمد كمال — غرفة ١١٢',
        room: '٦٩ سنة · مستقر',
        av: 'أح',
        avBg: const Color(0xFFD1FAE5),
        avColor: const Color(0xFF065F46),
        statusColor: const Color(0xFF10B981),
        borderColor: const Color(0xFFE0F2FE),
        bg: Colors.white,
        btnText: 'تفاصيل',
        btnColor: const Color(0xFF10B981),
        warnText: '✓ جميع أدويته مكتملة اليوم',
        isStable: true,
        category: 'مستقرة ✅',
        note: getLatestNote('الحاج أحمد كمال'),
      ),
    ];

    List<Widget> filtered = residents.where((r) {
      if (_selectedFilter == 'الكل') return true;
      if (r is! Container) return true;
      if (_selectedFilter == 'حرجة 🔴') return residents.indexOf(r) == 0;
      if (_selectedFilter == 'تحذير 🟡') return residents.indexOf(r) == 1;
      if (_selectedFilter == 'مستقرة ✅') return residents.indexOf(r) == 2;
      return false;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('المقيمون — حسب الأولوية', const Color(0xFFEF4444)),
        ...filtered,
      ],
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
    required String warnText,
    required String category,
    bool isStable = false,
    String? note,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(room,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
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
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_note_rounded,
                            color: Color(0xFF0EA5E9), size: 16),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn('🚑 طوارئ',
                          color: const Color(0xFF7F1D1D),
                          bg: const Color(0xFFFEE2E2),
                          onTap: () => _showEmergencyAlert(name)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn('📋 الملف',
                          color: Colors.white,
                          isPrimary: true,
                          bg: const Color(0xFF0369A1),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NurseResidentDetailScreen(
                            residentName: name.split(' — ')[0],
                            roomNumber: room.replaceAll('غرفة ', '').split(' · ')[0],
                          )))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn('💬 ملاحظة',
                          color: const Color(0xFF0369A1),
                          bg: const Color(0xFFF0F9FF),
                          onTap: () => _showNoteDialog(name)),
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

  Widget _actionBtn(String label,
      {required Color color,
      required Color bg,
      bool isPrimary = false,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0369A1) : bg,
          borderRadius: BorderRadius.circular(10),
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
          _doseCell(d1, n),
          _doseCell(d2, n),
          _doseCell(d3, n),
          _doseCell(d4, n),
        ],
      ),
    );
  }

  Widget _doseCell(String st, String resident) {
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

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تحديث حالة الدواء لـ $resident'),
            backgroundColor: const Color(0xFF0369A1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: SizedBox(
        width: 40,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: Center(
              child: Text(st,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(String residentName) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text('إضافة ملاحظة تمريضية', textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
            Text('المقيم: $residentName', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'عنوان الملاحظة (مثال: وجبة الغداء)',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل الملاحظة هنا...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('بواسطة: أ. منى (مشرف)', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                final newNote = NursingNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  residentName: residentName,
                  title: titleController.text,
                  content: contentController.text,
                  author: 'أ. منى (مشرف)',
                  timestamp: DateTime.now(),
                );
                ref.read(appRiverpod).addNursingNote(newNote);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الملاحظة بنجاح ✅')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('حفظ الملاحظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyAlert(String residentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF7F1D1D),
        title: const Text('🚨 تأكيد استغاثة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من تفعيل حالة الطوارئ لـ $residentName؟ سيتم تنبيه الفريق الطبي فوراً.', 
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('تم إرسال إشارة الطوارئ! 🚑')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('تأكيد الطوارئ', style: TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE0F2FE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard_rounded, 'الرئيسية', _currentTabIndex == 0, onTap: () => setState(() => _currentTabIndex = 0)),
          _navItem(Icons.people_alt_rounded, 'المقيمين', _currentTabIndex == 1, onTap: () => setState(() => _currentTabIndex = 1)),
          _navItem(Icons.business_center_rounded, 'العمليات', _currentTabIndex == 2, onTap: () => setState(() => _currentTabIndex = 2)),
          _navItem(Icons.medical_services_rounded, 'الإدارة الطبية', _currentTabIndex == 3, onTap: () => setState(() => _currentTabIndex = 3)),
          _navItem(Icons.receipt_long_rounded, 'التقارير', _currentTabIndex == 4, onTap: () => setState(() => _currentTabIndex = 4)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF0EA5E9) : (isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? const Color(0xFF0EA5E9) : (isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
          ),
          if (active) ...[
            const SizedBox(height: 2),
            Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFF0EA5E9)))
          ]
        ],
      ),
    );
  }
  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
      onPressed: _showEmergencyDialog,
      backgroundColor: const Color(0xFFEF4444),
      elevation: 8,
      icon: const Icon(Icons.emergency_rounded, color: Colors.white),
      label: const Text('طوارئ SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  void _showEmergencyDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('إجراء طوارئ فوري 🚨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            const SizedBox(height: 8),
            Text('برجاء اختيار نوع الطوارئ لتنبيه الطاقم المعني', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _emergencyAction('طلب إسعاف', Icons.airport_shuttle_rounded, const Color(0xFFEF4444), () => _triggerEmergency('سيارة إسعاف'))),
                const SizedBox(width: 12),
                Expanded(child: _emergencyAction('الطبيب المناوب', Icons.local_hospital_rounded, const Color(0xFFF59E0B), () => _triggerEmergency('الطبيب المناوب'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _emergencyAction('كود بلو (قلبي)', Icons.favorite_rounded, const Color(0xFFB91C1C), () => _triggerEmergency('Code Blue'))),
                const SizedBox(width: 12),
                Expanded(child: _emergencyAction('تنبيه الإدارة', Icons.notifications_active_rounded, const Color(0xFF6366F1), () => _triggerEmergency('الإدارة'))),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _emergencyAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerEmergency(String type) async {
    Navigator.pop(context);
    
    if (type == 'سيارة إسعاف') {
      final status = await Permission.phone.request();
      if (!mounted) return;

      if (status.isGranted) {
        final Uri telUri = Uri.parse('tel:128');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يجب منح إذن الاتصال لطلب الإسعاف 📞'),
          backgroundColor: Color(0xFFF59E0B),
        ));
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تم إرسال تنبيه $type لجميع الطاقم المعني 🚨'),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

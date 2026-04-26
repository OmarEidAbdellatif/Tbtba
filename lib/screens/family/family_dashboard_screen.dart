import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import 'visit_booking_screen.dart';
import 'care_report_detail_screen.dart';
import 'resident_id_screen.dart';
import '../../widgets/taptaba_drawer.dart';
import '../../widgets/taptaba_scaffold.dart';

class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends ConsumerState<FamilyDashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _fadeAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return TaptabaScaffold(
      title: 'طبطبـة',
      titleColor: const Color(0xFFea580c),
      overrideRole: 'عائلة',
      bottomNavigationBar: _buildBottomNav(),
      body: Column(
        children: [
          _buildHero(provider),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeView(provider),
                _buildCareView(provider),
                _buildVisitsView(provider),
                _buildBillingView(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFea580c), Color(0xFFf97316), Color(0xFFfb923c)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('مرحباً سارة 👋', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('الابنة · آخر زيارة: منذ ٣ أيام', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWellnessPulse(provider),
        ],
      ),
    );
  }

  Widget _buildWellnessPulse(AppRiverpod provider) {
    return FadeTransition(
      opacity: _fadeAnimations[1],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('نبض العافية — الحاج محمود', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        provider.currentMood == 'happy' ? 'سعيد ومبتهج 😊' :
                        provider.currentMood == 'calm' ? 'هادئ ومستقر 😌' :
                        provider.currentMood == 'tired' ? 'يحتاج للراحة 😴' :
                        provider.currentMood == 'active' ? 'نشيط وحيوي 🔥' : 'مستقر ومطمئن',
                        style: const TextStyle(color: Colors.white70, fontSize: 10)
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: provider.currentMood == 'tired' ? const Color(0xFFfbbf24) : const Color(0xFF4ade80),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: (provider.currentMood == 'tired' ? const Color(0xFFfbbf24) : const Color(0xFF4ade80)).withOpacity(0.6), blurRadius: 4 + _pulseController.value * 8, spreadRadius: _pulseController.value * 4)],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildMiniBadge('🥣 فطر جيداً', const Color(0xFFfef3c7)),
                      const SizedBox(width: 6),
                      _buildMiniBadge('😴 نوم هادئ', const Color(0xFFdbeafe)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64, height: 64,
                  child: CircularProgressIndicator(
                    value: ref.watch(appRiverpod).compliancePercentage / 100,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 52, height: 52,
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Center(child: Text('مح', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'lbl': 'نظرة عامة', 'icon': Icons.dashboard_outlined},
      {'lbl': 'الرعاية', 'icon': Icons.favorite_border_rounded},
      {'lbl': 'الزيارات', 'icon': Icons.calendar_month_outlined},
      {'lbl': 'الفواتير', 'icon': Icons.account_balance_wallet_outlined},
    ];

    return Container(
      height: 48,
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFf1f5f9)))),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isAct = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isAct ? const Color(0xFFea580c) : Colors.transparent, width: 2.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tabs[index]['lbl'] as String, style: TextStyle(color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: isAct ? FontWeight.bold : FontWeight.w500)),
                    const SizedBox(width: 4),
                    Icon(tabs[index]['icon'] as IconData, size: 14, color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- VIEWS ---

  Widget _buildHomeView(AppRiverpod provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHealthMetricsGrid(provider),
          const SizedBox(height: 24),
          _buildVirtualVisitSection(),
          const SizedBox(height: 24),
          _buildMemoryWall(provider),
          const SizedBox(height: 24),
          _buildNextmedCard(provider),
          const SizedBox(height: 20),
          _buildUpcomingVisit(provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMemoryWall(AppRiverpod provider) {
    final moments = provider.memoryMoments.where((m) => m.residentId == 'r1').toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('حائط الذكريات ✨', style: TextStyle(color: Color(0xFF1f2937), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF0ea5e9), borderRadius: BorderRadius.circular(2))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: moments.length,
            itemBuilder: (context, i) {
              final m = moments[i];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFf1f5f9)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.network(m.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(m.activityTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                            Text(m.date, style: const TextStyle(fontSize: 8, color: Color(0xFF94a3b8))),
                            const Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => provider.addAppreciation(m.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFfff1f2), borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        Text('${m.appreciations}', style: const TextStyle(color: Color(0xFFe11d48), fontSize: 9, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.favorite, color: Color(0xFFe11d48), size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text('ممتنـون ❤️', style: TextStyle(fontSize: 8, color: Color(0xFF64748b))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualVisitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('الزيارة الافتراضية (AR) 🕶️', style: TextStyle(color: Color(0xFF1f2937), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFFa855f7), borderRadius: BorderRadius.circular(2))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1513161455079-7dc1de15ef3e?q=80&w=1000'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)]),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text('ابدأ جولة ٣٦٠ درجة في الغرفة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Positioned(
                bottom: 15, right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Text('مباشر الآن', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(Icons.circle, color: Colors.red, size: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsGrid(AppRiverpod provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('مؤشرات الحالة اليوم', style: TextStyle(color: Color(0xFF1f2937), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFFea580c), borderRadius: BorderRadius.circular(2))),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
          itemCount: provider.familyHealthMetrics.length,
          itemBuilder: (context, i) {
            final m = provider.familyHealthMetrics[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFf1f5f9)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                       _buildTrendIcon(m.trend),
                       const Spacer(),
                       Text(m.label, style: const TextStyle(color: Color(0xFF64748b), fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(color: _getMetricBg(m.status), borderRadius: BorderRadius.circular(6)),
                         child: Text(_getMetricStatus(m.status), style: TextStyle(color: _getMetricFg(m.status), fontSize: 8, fontWeight: FontWeight.bold)),
                       ),
                       const Spacer(),
                       Text('${(m.value * 100).toInt()}%', style: const TextStyle(color: Color(0xFF1f2937), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNextmedCard(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFeff6ff), Color(0xFFdbeafe)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFbfdbfe)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF3b82f6), borderRadius: BorderRadius.circular(12)),
            child: const Text('تذكير', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('الجرعة القادمة: ${ref.watch(appRiverpod).nextMedication?.name ?? "مكتملة ✅"}', style: const TextStyle(color: Color(0xFF1e3a8a), fontSize: 12, fontWeight: FontWeight.bold)),
                Text(ref.watch(appRiverpod).nextMedication != null ? 'موعد ${ref.watch(appRiverpod).nextMedication!.timeOfDay} — ${ref.watch(appRiverpod).nextMedication!.timeDescription}' : 'جميع الأدوية تم أخذها بنجاح', style: const TextStyle(color: Color(0xFF3b82f6), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.medication_liquid_rounded, color: Color(0xFF3b82f6), size: 28),
        ],
      ),
    );
  }

  Widget _buildUpcomingVisit(AppRiverpod provider) {
    final visit = provider.familyVisits.firstWhere((v) => v.status == 'upcoming');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFdcfce7), borderRadius: BorderRadius.circular(8)),
                child: const Text('مؤكدة', style: TextStyle(color: Color(0xFF166534), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Text('زيارتك القادمة', style: TextStyle(color: Color(0xFF1f2937), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVisitInfo(Icons.access_time_filled, visit.time),
              const SizedBox(width: 20),
              _buildVisitInfo(Icons.calendar_today_rounded, visit.date),
              const Spacer(),
              const CircleAvatar(radius: 18, backgroundColor: Color(0xFFf3f4f6), child: Text('س', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6b7280)))),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitBookingScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFfff7ed), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFfed7aa))),
              child: const Center(child: Text('تعديل الموعد', style: TextStyle(color: Color(0xFFea580c), fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitInfo(IconData icon, String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(color: Color(0xFF4b5563), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: const Color(0xFF94a3b8)),
      ],
    );
  }

  Widget _buildCareView(AppRiverpod provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('سجل الأدوية اليوم', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...provider.medications.map((m) => _buildCareLogCard(m)).toList(),
        const SizedBox(height: 24),
        const Text('آخر التقارير الطبية', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildReportCard('تقييم ربع سنوي — أخصائي اجتماعي', '١٨ أبريل ٢٠٢٤', 'تحسن ملحوظ في مستوى المشاركة الاجتماعية والمزاج العام رغبة في الأنشطة الجماعية.', const Color(0xFF6366f1)),
      ],
    );
  }

  Widget _buildCareLogCard(Medication m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: m.isTaken ? const Color(0xFFdcfce7) : const Color(0xFFf1f5f9)),
      ),
      child: Row(
        children: [
          if (m.isTaken)
           const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 20)
          else
           const Icon(Icons.pending_actions_rounded, color: Color(0xFFf59e0b), size: 20),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${m.dosage} · ${m.timeDescription}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
            ],
          ),
          const SizedBox(width: 12),
          Container(
             width: 40, height: 40,
             decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(10)),
             child: const Center(child: Icon(Icons.medication, color: Color(0xFFea580c), size: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String date, String excerpt, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf1f5f9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 10)),
              Text(title, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(excerpt, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF4b5563), fontSize: 10, height: 1.5)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CareReportDetailScreen(title: title, date: date))),
            child: const Text('عرض التقرير الكامل ←', style: TextStyle(color: Color(0xFFea580c), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsView(AppRiverpod provider) {
    return Column(
      children: [
        _buildVisitsHeader(),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: const Color(0xFFea580c),
                  unselectedLabelColor: const Color(0xFF94a3b8),
                  indicatorColor: const Color(0xFFea580c),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(child: Text('الزيارات القادمة (${provider.familyVisits.where((v) => v.status == 'upcoming').length})', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Tab(child: Text('السجل السابق', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildVisitsList(provider.familyVisits.where((v) => v.status == 'upcoming').toList()),
                      _buildVisitsList(provider.familyVisits.where((v) => v.status != 'upcoming').toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitsHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitBookingScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFea580c), Color(0xFFf97316)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFea580c).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 40),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حجز موعد زيارة جديد',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('اختر الوقت المناسب لرؤية أحبائك',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Spacer(),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsList(List<FamilyVisit> visits) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 64, color: const Color(0xFFcbd5e1)),
            const SizedBox(height: 16),
            const Text('لا توجد زيارات حالياً',
                style: TextStyle(color: Color(0xFF94a3b8), fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: visits.length,
      itemBuilder: (context, i) => _buildVisitCard(visits[i]),
    );
  }

  Widget _buildVisitCard(FamilyVisit v) {
    bool isUpcoming = v.status == 'upcoming';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildVisitBadge(v.status),
              const Spacer(),
              Text(
                  v.type == 'physical' ? '🏠 زيارة واقعية' : '📹 مكالمة فيديو',
                  style: const TextStyle(
                      color: Color(0xFF64748b),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: const Color(0xFFf8fafc),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                    v.type == 'physical'
                        ? Icons.people_alt_rounded
                        : Icons.videocam_rounded,
                    color: const Color(0xFFea580c)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الزائر: ${v.visitorName}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1e293b))),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildVisitInfo(Icons.access_time_rounded, v.time),
                        const SizedBox(width: 12),
                        _buildVisitInfo(Icons.calendar_month_rounded, v.date),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFf1f5f9)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFcbd5e1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {},
                    child: const Text('إلغاء',
                        style: TextStyle(color: Color(0xFF64748b))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFfff7ed),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitBookingScreen())),
                    child: const Text('تعديل الموعد',
                        style: TextStyle(
                            color: Color(0xFFea580c),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisitBadge(String status) {
    Color col = const Color(0xFF64748b);
    Color bg = const Color(0xFFf1f5f9);
    String label = 'غير محدد';
    if (status == 'upcoming') {
      col = const Color(0xFF1d4ed8);
      bg = const Color(0xFFdbeafe);
      label = 'قادمة';
    } else if (status == 'completed') {
      col = const Color(0xFF166534);
      bg = const Color(0xFFdcfce7);
      label = 'تمت';
    } else if (status == 'cancelled') {
      col = const Color(0xFFef4444);
      bg = const Color(0xFFfee2e2);
      label = 'ملغاة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: col, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBillingView(AppRiverpod provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildBillingSummary(provider),
        const SizedBox(height: 32),
        _buildSectionHeaderWithAction('الفواتير المتاحة', 'رؤية الكل'),
        const SizedBox(height: 16),
        ...provider.familyBills.map((b) => _buildBillCard(b)).toList(),
        const SizedBox(height: 32),
        _buildSectionHeader('طرق الدفع'),
        const SizedBox(height: 16),
        _buildPaymentMethodCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBillingSummary(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0f172a).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
        image: const DecorationImage(
          image: NetworkImage(
              'https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المستحقات الحالية',
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
              Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white24, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              '${provider.unpaidBillsAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} ج.م',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFea580c).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () => _showPaymentSheet(provider),
                    child: const Text('ادفع الآن',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري تجهيز وتحميل الفاتورة بصيغة PDF...'),
                      backgroundColor: Color(0xFF1e293b),
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.download_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(AppRiverpod provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFe2e8f0),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),
            const Text('تأكيد الدفع',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('سيتم خصم المبلغ من بطاقتك المسجلة المنتهية بـ 4242',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748b), fontSize: 16)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFFf8fafc),
                  borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${provider.unpaidBillsAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} ج.م',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b))),
                  const Text('إجمالي المبلغ',
                      style: TextStyle(
                          color: Color(0xFF64748b),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFea580c),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  Navigator.pop(context); // Close sheet
                  _processPayment(provider);
                },
                child: const Text('تأكيد وإتمام الدفع',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء العملية',
                  style: TextStyle(color: Color(0xFF94a3b8))),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(AppRiverpod provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFea580c)),
                SizedBox(height: 24),
                Text('جاري معالجة الدفع...',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      provider.clearUnpaidBills();
      _showSuccessPayment();
    });
  }

  void _showSuccessPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('تمت عملية الدفع بنجاح! شكراً لك.'),
          ],
        ),
        backgroundColor: const Color(0xFF16a34a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildSectionHeaderWithAction(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(action,
            style: const TextStyle(
                color: Color(0xFFea580c),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        _buildSectionHeader(title),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b))),
        const SizedBox(width: 10),
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: const Color(0xFFea580c),
                borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildBillCard(FamilyBill b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: b.isPaid ? const Color(0xFFdcfce7) : const Color(0xFFf1f5f9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: b.isPaid ? const Color(0xFFf0fdf4) : const Color(0xFFfff1f2),
                shape: BoxShape.circle),
            child: Icon(
                b.isPaid ? Icons.check_rounded : Icons.priority_high_rounded,
                color: b.isPaid ? const Color(0xFF16a34a) : const Color(0xFFe11d48),
                size: 20),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(b.title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              Text(b.month,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
              const SizedBox(height: 6),
              Text(
                  b.isPaid
                      ? 'تم الدفع بنجاح'
                      : 'تاريخ الاستحقاق: ${b.dueDate}',
                  style: TextStyle(
                      color: b.isPaid
                          ? const Color(0xFF16a34a)
                          : const Color(0xFFe11d48),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 20),
          Text('${b.amount.toInt()} ج.م',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b))),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf1f5f9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_left_rounded, color: Color(0xFF94a3b8)),
          const Spacer(),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Visa **** 4242',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              Text('بطاقة الدفع الأساسية',
                  style: TextStyle(color: Color(0xFF64748b), fontSize: 11)),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFf8fafc),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.credit_card_rounded,
                color: Color(0xFF1e293b)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(String trend) {
     if (trend == 'up') return const Icon(Icons.trending_up, color: Color(0xFF10b981), size: 14);
     if (trend == 'down') return const Icon(Icons.trending_down, color: Color(0xFFef4444), size: 14);
     return const Icon(Icons.trending_flat, color: Color(0xFF94a3b8), size: 14);
  }

  String _getMetricStatus(String s) {
    if (s == 'good') return 'جيد';
    if (s == 'medium') return 'مستقر';
    return 'منخفض';
  }

  Color _getMetricBg(String s) {
    if (s == 'good') return const Color(0xFFd1fae5);
    if (s == 'medium') return const Color(0xFFfef3c7);
    return const Color(0xFFfee2e2);
  }

  Color _getMetricFg(String s) {
    if (s == 'good') return const Color(0xFF065f46);
    if (s == 'medium') return const Color(0xFF92400e);
    return const Color(0xFF7f1d1d);
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_outlined, 'الرئيسية', 0),
          _buildNavItem(Icons.favorite_border_rounded, 'الرعاية', 1),
          _buildNavItem(Icons.calendar_month_outlined, 'الزيارات', 2),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'الفواتير', 3),
          _buildNavItem(Icons.qr_code_scanner_rounded, 'الهوية', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isAct = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 4) {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const ResidentIdScreen()));
        } else {
           setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8), size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8), fontSize: 9, fontWeight: isAct ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class AssessmentDetailedScreen extends ConsumerStatefulWidget {
  const AssessmentDetailedScreen({super.key});

  @override
  ConsumerState<AssessmentDetailedScreen> createState() => _AssessmentDetailedScreenState();
}

class _AssessmentDetailedScreenState extends ConsumerState<AssessmentDetailedScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _ringController;
  late AnimationController _shimmerController;
  late List<Animation<double>> _fadeAnimations;
  int _currentToolIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _fadeAnimations = List.generate(12, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeController.forward();
    _ringController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return Scaffold(
      backgroundColor: const Color(0xFFfff7ed),
      body: Column(
        children: [
          _buildHero(provider),
          _buildToolTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                   _buildScoreOverview(),
                   const SizedBox(height: 12),
                   _buildQuestionnaire(provider),
                   const SizedBox(height: 24),
                   _buildHistoryComparison(provider),
                   const SizedBox(height: 24),
                   _buildSpecialistNotes(),
                   const SizedBox(height: 24),
                   _buildAutoRecommendations(),
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 40, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFc2410c), Color(0xFFea580c), Color(0xFFf97316)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14)),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('📋 التقييم التفصيلي', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('أ. نور — الأخصائية الاجتماعية', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FadeTransition(
            opacity: _fadeAnimations[1],
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('يحتاج تجديد', style: TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الحاج محمود سالم', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('غرفة ١٠١ · ٧٨ سنة · آخر تقييم: ٣ أشهر', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.28), shape: BoxShape.circle),
                    child: const Center(child: Text('مح', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTabs() {
    final tools = [
      {'label': 'نفسي', 'icon': '🧠', 'score': '٨/١٥', 'col': const Color(0xFFf59e0b), 'bg': const Color(0xFFfef3c7)},
      {'label': 'اجتماعي', 'icon': '🤝', 'score': '٥/٢٠', 'col': const Color(0xFFef4444), 'bg': const Color(0xFFfee2e2)},
      {'label': 'بدني', 'icon': '🏃', 'score': '٧٨/١٠٠', 'col': const Color(0xFF10b981), 'bg': const Color(0xFFd1fae5)},
      {'label': 'جودة الحياة', 'icon': '❤️', 'score': '٦٢/١٠٠', 'col': const Color(0xFFf59e0b), 'bg': const Color(0xFFfef3c7)},
    ];

    return Container(
      height: 44,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: List.generate(tools.length, (index) {
            final isAct = _currentToolIndex == index;
            final tool = tools[index];
            return GestureDetector(
              onTap: () => setState(() => _currentToolIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isAct ? const Color(0xFFea580c) : Colors.transparent, width: 2.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: tool['bg'] as Color, borderRadius: BorderRadius.circular(6)),
                      child: Text(tool['score'] as String, style: TextStyle(color: tool['col'] as Color, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    Text('${tool['icon']} ${tool['label']}', style: TextStyle(color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScoreOverview() {
    return FadeTransition(
      opacity: _fadeAnimations[2],
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('تقييم الحالة النفسية GDS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                  const Text('مؤشر اكتئاب متوسط · يحتاج متابعة', style: TextStyle(fontSize: 10, color: Color(0xFF64748b))),
                  const SizedBox(height: 8),
                  _buildSubScoreBar('المزاج', 0.40, const Color(0xFFf59e0b)),
                  _buildSubScoreBar('الطاقة', 0.30, const Color(0xFFef4444)),
                  _buildSubScoreBar('الأمل', 0.65, const Color(0xFF10b981)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 72, height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72, height: 72,
                    child: CircularProgressIndicator(
                      value: 0.53,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFfef3c7),
                      color: const Color(0xFFf59e0b),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('٨', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400e))),
                      Text('من ١٥', style: TextStyle(fontSize: 8, color: const Color(0xFFb45309).withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScoreBar(String label, double val, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: col)),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: val,
                child: Container(decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(width: 44, child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: Color(0xFF64748b)))),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire(AppRiverpod provider) {
    return FadeTransition(
      opacity: _fadeAnimations[3],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('٦ / ١٥ سؤال', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text('📝 مقياس GDS-15 — الاكتئاب', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                 return Container(
                   height: 3,
                   width: double.infinity,
                   child: FractionallySizedBox(
                     alignment: Alignment.centerRight,
                     widthFactor: 0.4,
                     child: Container(color: Colors.white.withOpacity(0.8 + 0.2 * sin(_shimmerController.value * 2 * pi))),
                   ),
                   color: Colors.white.withOpacity(0.25),
                 );
              },
            ),
            _buildQuestionItem('السؤال ٦ من ١٥', 'هل تشعر بالقلق وأن هناك أشياء سيئة ستحدث لك؟', type: 'choice', options: ['نعم — أحياناً', 'لا — نادراً', 'أحياناً جداً'], selected: 0),
            _buildQuestionItem('السؤال ٧ من ١٥', 'كيف تقيّم مزاجك العام خلال الأسبوع الماضي؟', type: 'scale', selectedScale: 3),
            _buildQuestionItem('السؤال ٨ من ١٥', 'هل تشعر أنك عاجز عن مساعدة الآخرين؟ اشرح بكلماتك:', type: 'text'),
            _buildQuestionNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(String num, String text, {required String type, List<String>? options, int? selected, int? selectedScale}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFfff7ed)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(num, style: const TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
          Text(text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0f172a), height: 1.5)),
          const SizedBox(height: 8),
          if (type == 'choice' && options != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: List.generate(options.length, (index) {
                final isSel = selected == index;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? null : const Color(0xFFf8fafc),
                    gradient: isSel ? const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]) : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isSel ? null : Border.all(color: const Color(0xFFe2e8f0), width: 1.5),
                  ),
                  child: Text(options[index], style: TextStyle(color: isSel ? Colors.white : const Color(0xFF64748b), fontSize: 10, fontWeight: FontWeight.bold)),
                );
              }),
            ),
          if (type == 'scale')
             Row(
               children: [
                 const Text('ممتاز', style: TextStyle(fontSize: 9, color: Color(0xFF94a3b8))),
                 Expanded(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: List.generate(5, (index) {
                       final i = 5 - index;
                       final isSel = selectedScale == i;
                       return Container(
                         width: 26, height: 26,
                         decoration: BoxDecoration(
                           color: isSel ? null : const Color(0xFFf8fafc),
                           gradient: isSel ? const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]) : null,
                           shape: BoxShape.circle,
                           border: isSel ? null : Border.all(color: const Color(0xFFe2e8f0), width: 1.5),
                         ),
                         child: Center(child: Text('$i', style: TextStyle(color: isSel ? Colors.white : const Color(0xFF94a3b8), fontSize: 10, fontWeight: FontWeight.bold))),
                       );
                     }),
                   ),
                 ),
                 const Text('سيء جداً', style: TextStyle(fontSize: 9, color: Color(0xFF94a3b8))),
               ],
             ),
          if (type == 'text')
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: const Color(0xFFf8fafc), border: Border.all(color: const Color(0xFFe2e8f0)), borderRadius: BorderRadius.circular(10)),
               child: const Text('المقيم ذكر شعوره بالعجز في بعض المواقف اليومية البسيطة...', style: TextStyle(fontSize: 11, color: Color(0xFF0f172a), height: 1.4)),
             ),
        ],
      ),
    );
  }

  Widget _buildQuestionNav() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Color(0xFFf8fafc)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
             decoration: BoxDecoration(color: const Color(0xFFfff7ed), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFfed7aa))),
             child: const Text('التالي →', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
           ),
           const Text('٦ من ١٥ — ٤٠٪ مكتمل', style: TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
             decoration: BoxDecoration(color: const Color(0xFFfff7ed), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFfed7aa))),
             child: const Text('← السابق', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
           ),
        ],
      ),
    );
  }

  Widget _buildHistoryComparison(AppRiverpod provider) {
    return FadeTransition(
      opacity: _fadeAnimations[4],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('مقارنة التقييمات السابقة', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF6366f1), shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
            ),
            child: Column(
              children: provider.assessmentHistory.map((h) => _buildCompareRow(h)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareRow(AssessmentHistoricalEntry h) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _buildTrendArrow(h.trend),
          const SizedBox(width: 6),
          Text('${h.score.toInt()}/${h.total}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFf59e0b))),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: h.score / double.parse(h.total),
                child: Container(decoration: BoxDecoration(color: const Color(0xFFf59e0b), borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 72, child: Text(h.date, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF64748b)))),
        ],
      ),
    );
  }

  Widget _buildTrendArrow(String trend) {
    if (trend == 'up') return const Text('↑', style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.bold));
    if (trend == 'down') return const Text('↓', style: TextStyle(color: Color(0xFFef4444), fontWeight: FontWeight.bold));
    return const Text('—', style: TextStyle(color: Color(0xFF94a3b8), fontWeight: FontWeight.bold));
  }

  Widget _buildSpecialistNotes() {
    return FadeTransition(
      opacity: _fadeAnimations[5],
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('ملاحظات الأخصائية', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFf97316), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFfff7ed), border: Border.all(color: const Color(0xFFfed7aa)), borderRadius: BorderRadius.circular(12)),
              child: const Text('المقيم يُبدي علامات قلق متزايدة مؤخراً، خاصةً بعد آخر زيارة للأسرة. ينصح بجلسة دعم نفسي أسبوعية...', style: TextStyle(fontSize: 11, color: Color(0xFF0f172a), height: 1.6)),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                _NoteChip('+ متابعة شهرية'),
                _NoteChip('+ جلسة أسبوعية'),
                _NoteChip('+ تنسيق مع الأسرة'),
                _NoteChip('+ يحتاج دعم نفسي'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoRecommendations() {
    final recs = [
      {'icon': '✅', 'text': 'جدولة جلسة دعم نفسي هذا الأسبوع', 'bg': const Color(0xFFd1fae5), 'fg': const Color(0xFF065f46)},
      {'icon': '📞', 'text': 'التواصل مع الأسرة لتشجيع الزيارات', 'bg': const Color(0xFFfef3c7), 'fg': const Color(0xFF92400e)},
      {'icon': '🎯', 'text': 'تسجيله في برنامج ورشة الرسم الأسبوعية', 'bg': const Color(0xFFede9fe), 'fg': const Color(0xFF4c1d95)},
    ];

    return FadeTransition(
      opacity: _fadeAnimations[6],
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('التوصيات التلقائية', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10b981), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 8),
            ...recs.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(color: r['bg'] as Color, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Text(r['icon'] as String, style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  Text(r['text'] as String, style: TextStyle(color: r['fg'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFfed7aa)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('✅ إنهاء التقييم', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFfff7ed),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
              ),
              child: const Center(child: Text('💾 حفظ مؤقت', style: TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String label;
  const _NoteChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFffedd5), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFfed7aa))),
      child: Text(label, style: const TextStyle(color: Color(0xFF9a3412), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

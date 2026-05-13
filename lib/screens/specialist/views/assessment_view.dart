import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart'; // مزود الحالة العام
import '../../../models/app_models.dart'; // نماذج البيانات
import '../assessment_detailed_screen.dart'; // شاشة التقييم التفصيلية

// شاشة التقييم الرئيسية للأخصائي الاجتماعي - تعرض خريطة الاحتياجات وقائمة المقيمين
class SpecialistAssessmentView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations; // حركات الظهور المتسلسلة للعناصر
  final AnimationController floatController; // متحكم حركات الطفو الرسومية
  final AnimationController shimmerController; // متحكم حركة اللمعان للعناصر قيد التحميل
  final AnimationController popController; // متحكم حركة القفز للأيقونات التفاعلية
  final void Function(int) onNavigate; // دالة للتنقل بين التبويبات الرئيسية
  static bool _showNeedMap = false; // متغير ثابت للتبديل بين وضع القائمة ووضع الخريطة

  const SpecialistAssessmentView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod); // مراقبة حالة الـ Provider

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(14),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSyncBanner(provider), // بنر مزامنة البيانات (أوفلاين)
              const SizedBox(height: 12),
              _buildSectionLabel(
                  'أدوات التقييم المتاحة', const Color(0xFF6366f1), 0),
              const SizedBox(height: 12),
              _buildToolsCard(
                  context, provider), // كارت يحتوي على روابط سريعة لأدوات التقييم المختلفة
              const SizedBox(height: 24),
              _buildSectionLabel(
                  'خريطة توزيع الاحتياجات', const Color(0xFFef4444), 1),
              const SizedBox(height: 12),
              _buildViewToggle(provider), // أزرار التبديل بين عرض (قائمة) أو (خريطة ملونة)
              const SizedBox(height: 12),
              
              // التبديل البرمجي بين واجهة الخريطة التفاعلية وواجهة القائمة التقليدية
              if (SpecialistAssessmentView._showNeedMap)
                _buildNeedMap(context, provider) // عرض خريطة المقيمين الملونة بناءً على حالتهم
              else ...[
                _buildAdvancedSearch(provider), // شريط البحث والفلترة حسب الغرف أو الحالات
                const SizedBox(height: 12),
                // عرض قائمة المقيمين الذين يحتاجون لتقييم دوري
                ...provider.filteredResidentScores
                    .map((score) => _buildResidentAssessmentCard(context, score))
                    ,
              ],
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  // بناء بنر المزامنة عند وجود بيانات لم تُرفع بعد
  Widget _buildSyncBanner(AppRiverpod provider) {
    if (provider.pendingAssessments.isEmpty && !provider.isSyncing) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFfffbeb),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFfef3c7))),
      child: Row(
        children: [
          if (provider.isSyncing)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFd97706)))
          else
            const Icon(Icons.cloud_upload_outlined,
                color: Color(0xFFd97706), size: 18),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
                provider.isSyncing
                    ? 'جاري مزامنة البيانات...'
                    : 'يوجد ${provider.pendingAssessments.length} تقييمات بانتظار الرفع',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400e))),
            if (!provider.isSyncing)
              const Text('سيتم الرفع تلقائياً عند استقرار الاتصال',
                  style: TextStyle(fontSize: 9, color: Color(0xFFb45309))),
          ])),
          if (!provider.isSyncing)
            TextButton(
                onPressed: () => provider.syncAssessments(),
                child: const Text('مزامنة الآن',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400e)))),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, int index) {
    return FadeTransition(
        opacity: fadeAnimations[min(index, 11)],
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF9a3412),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle))
        ]));
  }

  // بناء الكارت الخاص بأدوات التقييم (نفسي، اجتماعي...)
  Widget _buildToolsCard(BuildContext context, AppRiverpod provider) {
    return FadeTransition(
      opacity: fadeAnimations[2],
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFfed7aa), width: 1.5)),
        child: Column(
            children: provider.socialAssessmentTools
                .map((tool) => _buildToolRow(context, tool, provider))
                .toList()),
      ),
    );
  }

  // بناء صف أداة التقييم الفردية
  Widget _buildToolRow(BuildContext context,
      SocialSpecialistAssessmentTool tool, AppRiverpod provider) {
    return GestureDetector(
      onTap: () => _showToolDetails(context, tool, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFfff7ed)))),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: Color(0xFF94a3b8)),
            const Spacer(),
            _buildToolAction(tool.status), // عرض حالة الأداة (مكتمل/جديد)
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text(tool.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b))),
                  Text(tool.subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748b)))
                ])),
            const SizedBox(width: 14),
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: _getToolColor(tool.icon),
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                    child:
                        Text(tool.icon, style: const TextStyle(fontSize: 20)))),
          ],
        ),
      ),
    );
  }

  // نافذة عرض تفاصيل أداة التقييم قبل البدء
  void _showToolDetails(BuildContext context,
      SocialSpecialistAssessmentTool tool, AppRiverpod provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
            color: Color(0xFFf8fafc),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                            Text(tool.name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1e293b))),
                            Text(tool.subtitle,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]))
                          ])),
                      const SizedBox(width: 16),
                      Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                              color: _getToolColor(tool.icon),
                              borderRadius: BorderRadius.circular(18)),
                          child: Center(
                              child: Text(tool.icon,
                                  style: const TextStyle(fontSize: 28))))
                    ]),
                    const SizedBox(height: 32),
                    const Text('حول هذه الأداة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155))),
                    const SizedBox(height: 12),
                    Text(
                        'تستخدم هذه الأداة لتقييم الجوانب ${tool.name} للمقيم بشكل دوري.',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748b),
                            height: 1.6)),
                    const SizedBox(height: 32),
                    _buildInfoRow(
                        'الحالة الحالية',
                        tool.status,
                        tool.status == 'مكتمل'
                            ? const Color(0xFF059669)
                            : const Color(0xFFea580c)),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        'آخر تحديث', 'منذ يومين', const Color(0xFF64748b)),
                    const SizedBox(height: 32),
                    Row(children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AssessmentDetailedScreen(
                                                tool: tool,
                                                resident: provider
                                                    .filteredResidentScores
                                                    .first)));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFea580c),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              child: const Text('بدء التقييم الآن 📝',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)))),
                      const SizedBox(width: 12),
                      Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFf1f5f9),
                              borderRadius: BorderRadius.circular(16)),
                          child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF64748b)),
                              padding: const EdgeInsets.all(16))),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)))
      ]);

  Widget _buildToolAction(String status) {
    final isDone = status == 'مكتمل';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFd1fae5) : const Color(0xFFffedd5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status,
          style: TextStyle(
              color: isDone ? const Color(0xFF065f46) : const Color(0xFF9a3412),
              fontSize: 9,
              fontWeight: FontWeight.bold)),
    );
  }

  // بناء شريط البحث المتقدم والفلترة حسب الحالة الصحية
  Widget _buildAdvancedSearch(AppRiverpod provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe2e8f0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: TextField(
              onChanged: (v) => provider.setResidentSearch(v),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو رقم الغرفة...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
                  border: InputBorder.none,
                  icon:
                      Icon(Icons.search, color: Color(0xFF94a3b8), size: 20))),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(children: [
              _buildFilterChip('الكل', null, provider),
              _buildFilterChip('حالة مستقرة', 'stable', provider),
              _buildFilterChip('متابعة دقيقة', 'monitoring', provider),
              _buildFilterChip('حالة حرجة', 'critical', provider)
            ])),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value, AppRiverpod provider) {
    final isSel = provider.selectedHealthStatus == value;
    return GestureDetector(
        onTap: () => provider.setHealthFilter(value),
        child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: isSel ? const Color(0xFF6366f1) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isSel ? Colors.transparent : const Color(0xFFe2e8f0))),
            child: Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : const Color(0xFF64748b)))));
  }

  // بناء كارت المقيم الفردي لعرض درجات تقييماته الأخيرة
  Widget _buildResidentAssessmentCard(
      BuildContext context, SocialSpecialistResidentScore score) {
    return FadeTransition(
      opacity: fadeAnimations[4],
      child: GestureDetector(
        onTap: () => _showResidentAssessmentOptions(context, score),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: score.isUrgent
                      ? const Color(0xFFef4444).withValues(alpha: 0.5)
                      : const Color(0xFFfed7aa),
                  width: 1.5)),
          child: Column(
            children: [
              Row(children: [
                if (score.isUrgent)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFFfee2e2),
                          borderRadius: BorderRadius.circular(9)),
                      child: const Text('عاجل',
                          style: TextStyle(
                              color: Color(0xFF7f1d1d),
                              fontSize: 10,
                              fontWeight: FontWeight.bold))),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(score.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b))),
                  Text('غرفة ${score.room} · ${score.date}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748b)))
                ]),
                const SizedBox(width: 10),
                Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: Color(0xFFffe4e6), shape: BoxShape.circle),
                    child: Center(
                        child: Text(score.initials,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9f1239))))),
              ]),
              const SizedBox(height: 16),
              ...score.scores.entries
                  .map((e) => _buildProgressRow(e.key, e.value))
                  , // عرض أشرطة التقدم لكل نوع تقييم
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () =>
                            _showResidentAssessmentOptions(context, score),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFFffedd5),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                                child: Text('📊 عرض النتائج',
                                    style: TextStyle(
                                        color: Color(0xFF9a3412),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)))))),
                const SizedBox(width: 8),
                Expanded(
                    child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AssessmentDetailedScreen(resident: score))),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFea580c),
                                  Color(0xFFf97316)
                                ]),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                                child: Text('📝 تقييم جديد',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)))))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // نافذة الخيارات عند الضغط على كارت المقيم
  void _showResidentAssessmentOptions(
      BuildContext context, SocialSpecialistResidentScore score) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
            color: Color(0xFFf8fafc),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      Text(score.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1e293b))),
                      const Text('اختر الإجراء المطلوب للمقيم',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF64748b))),
                      const SizedBox(height: 32),
                      _buildOptionButton(context, 'فتح التقييم التفصيلي 📊',
                          const Color(0xFFfff7ed), const Color(0xFFea580c), () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AssessmentDetailedScreen(resident: score)));
                      }),
                      const SizedBox(height: 12),
                      _buildOptionButton(context, 'بدء تقييم جديد الآن 📝',
                          const Color(0xFFea580c), Colors.white, () {
                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 12),
                      _buildOptionButton(context, 'إلغاء', Colors.transparent,
                          const Color(0xFF64748b), () => Navigator.pop(context))
                    ]))),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String label, Color bg,
          Color fg, VoidCallback onTap) =>
      SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: bg == Colors.transparent
                          ? BorderSide(color: Colors.grey[300]!)
                          : BorderSide.none)),
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15))));

  // بناء صف شريط التقدم الفردي (للدرجات البدنية والنفسية...)
  Widget _buildProgressRow(String label, double val) {
    final color = _getScoreColor(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
            width: 35,
            child: Text('${(val * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: color))),
        const SizedBox(width: 8),
        Expanded(
            child: Container(
                height: 7,
                decoration: BoxDecoration(
                    color: const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                    widthFactor: val,
                    child: Container(
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4)))))),
        const SizedBox(width: 8),
        SizedBox(
            width: 60,
            child: Text(label,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF64748b)))),
      ]),
    );
  }

  Color _getScoreColor(String label) => label == 'نفسي'
      ? const Color(0xFFf59e0b)
      : (label == 'اجتماعي'
          ? const Color(0xFFef4444)
          : (label == 'بدني'
              ? const Color(0xFF10b981)
              : const Color(0xFF6366f1)));
  Color _getToolColor(String icon) => icon == '🧠'
      ? const Color(0xFFffedd5)
      : (icon == '🤝'
          ? const Color(0xFFede9fe)
          : (icon == '🏃' ? const Color(0xFFdbeafe) : const Color(0xFFd1fae5)));

  Widget _buildViewToggle(AppRiverpod provider) {
    return StatefulBuilder(
      builder: (context, setState) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toggleBtn('قائمة', !SpecialistAssessmentView._showNeedMap, Icons.list_alt_rounded, () {
            setState(() => SpecialistAssessmentView._showNeedMap = false);
            provider.notifyListeners();
          }),
          const SizedBox(width: 8),
          _toggleBtn('خريطة', SpecialistAssessmentView._showNeedMap, Icons.grid_view_rounded, () {
            setState(() => SpecialistAssessmentView._showNeedMap = true);
            provider.notifyListeners();
          }),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isSel, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFea580c) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? Colors.transparent : const Color(0xFFfed7aa)),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isSel ? Colors.white : const Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Icon(icon, color: isSel ? Colors.white : const Color(0xFF9a3412), size: 16),
          ],
        ),
      ),
    );
  }

  // بناء خريطة الاحتياجات: عرض المقيمين كشبكة من الدوائر الملونة لسهولة المتابعة
  Widget _buildNeedMap(BuildContext context, AppRiverpod provider) {
    final mapData = provider.needMapData; // استلام بيانات الحالة والألوان من الـ Provider
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // عرض 4 مقيمين في كل صف
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: mapData.length,
      itemBuilder: (context, index) {
        final r = mapData[index];
        return GestureDetector(
          onTap: () {
            // عند الضغط على مقيم في الخريطة، تظهر خيارات التقييم المباشرة
            final score = provider.filteredResidentScores.firstWhere((s) => s.id == r['id']);
            _showResidentAssessmentOptions(context, score);
          },
          child: Container(
            decoration: BoxDecoration(
              color: (r['color'] as Color).withValues(alpha: 0.1), // لون الخلفية شفاف قليلاً
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: r['color'] as Color, width: 2), // إطار ملون يعكس الحالة
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(r['initials'], style: TextStyle(color: r['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('غ ${r['room']}', style: TextStyle(color: (r['color'] as Color).withValues(alpha: 0.8), fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }
}

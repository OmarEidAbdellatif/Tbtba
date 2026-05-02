import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';
import '../admin_resident_detail_screen.dart';

// واجهة التحكم الرئيسية للمدير - تعرض مؤشرات الأداء والتنبيهات العاجلة
class AdminHomeView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations; // قائمة حركات الظهور التدريجي للعناصر
  final AnimationController floatController; // متحكم حركات الطفو للعناصر الرسومية

  const AdminHomeView({super.key, required this.fadeAnimations, required this.floatController});

  @override
  ConsumerState<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends ConsumerState<AdminHomeView> {
  bool _showResolved = false; // متغير للتحكم في عرض التنبيهات (نشطة أم تمت معالجتها)

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    
    // فلترة التنبيهات بناءً على الحالة والدور
    final adminAlerts = provider.notifications
        .where((n) => n.targetRole == 'مدير' || n.targetRole == 'all')
        .where((n) => n.isRead == _showResolved)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان قسم الأداء مع فلتر التاريخ الجديد
          FadeTransition(
            opacity: widget.fadeAnimations[0],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateFilter(provider), // فلتر التاريخ للتقارير
                _buildSectionTitle('الأداء التشغيلي'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // شبكة مربعات مؤشرات الأداء (KPIs) - الآن تفاعلية
          _buildKPIGrid(provider.adminStats, context),
          
          const SizedBox(height: 32),
          // عنوان قسم الرسوم البيانية للنمو والصحة
          FadeTransition(opacity: widget.fadeAnimations[1], child: _buildSectionTitle('منحنى النمو والصحة')),
          const SizedBox(height: 16),
          _buildLargeChartCard(),
          
          const SizedBox(height: 32),
          // قسم التنبيهات مع شريط الفلترة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAlertFilter(), // أزرار التبديل بين التنبيهات النشطة والمعالجة
              FadeTransition(opacity: widget.fadeAnimations[2], child: _buildSectionTitle('تنبيهات المركز العاجلة')),
            ],
          ),
          const SizedBox(height: 16),
          if (adminAlerts.isEmpty)
            _buildAlertCard(
              TaptabaNotification(id: '0', title: 'لا توجد تنبيهات حالياً', body: '', time: 'الآن', type: 'stable', isRead: true), 
              Colors.green, 
              provider
            )
          else
            ...adminAlerts
                .take(5)
                .map((n) => _buildAlertCard(n, _getAlertColor(n.type), provider)),
        ],
      ),
    );
  }

  // دالة لتحديد لون التنبيه بناءً على نوعه (طبي، شكوى، اجتماعي)
  Color _getAlertColor(String type) {
    switch (type) {
      case 'medical': return Colors.red;
      case 'complaint': return Colors.orange;
      case 'social': return Colors.purple;
      default: return Colors.blue;
    }
  }

  // بناء شريط الفلترة (النشط / المعالج)
  Widget _buildAlertFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _filterBtn('المعالج', _showResolved, () => setState(() => _showResolved = true)),
          _filterBtn('النشط', !_showResolved, () => setState(() => _showResolved = false)),
        ],
      ),
    );
  }

  // بناء زر الفلترة الفردي
  Widget _filterBtn(String label, bool isSel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSel ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF0f172a) : const Color(0xFF64748b))),
      ),
    );
  }

  // بناء فلتر التاريخ (اليوم، الأسبوع، الشهر) للوحة تحكم المدير
  Widget _buildDateFilter(AppRiverpod provider) {
    final filters = ['اليوم', 'أسبوع', 'شهر'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: filters.map((f) => _dateChip(f, provider)).toList(),
      ),
    );
  }

  // بناء زر اختيار التاريخ الفردي مع تأثير بصري عند الاختيار
  Widget _dateChip(String label, AppRiverpod provider) {
    bool isSel = provider.selectedAdminDateFilter == label;
    return GestureDetector(
      onTap: () => provider.updateAdminDateFilter(label), // تحديث حالة الفلتر في المزود
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent, // اللون الأبيض للزر المختار
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSel ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF0f172a) : const Color(0xFF64748b))),
      ),
    );
  }

  // بناء عنوان القسم مع خط جانبي جمالي لتمييز الأقسام المختلفة
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
        const SizedBox(width: 8),
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF0ea5e9), borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  // بناء شبكة مؤشرات الأداء مع دعم الضغط لرؤية التفاصيل (Drill-down)
  Widget _buildKPIGrid(List<CenterOperationalStat> stats, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // منع التمرير داخل الشبكة لأنها داخل قائمة أكبر
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
      itemBuilder: (context, index) {
        final s = stats[index];
        return GestureDetector(
          onTap: () => _showKPIDrillDown(context, s), // فتح نافذة التفاصيل التاريخية عند الضغط
          child: FadeTransition(
            opacity: widget.fadeAnimations[index + 1],
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFf1f5f9)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s.label, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(s.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                  const Spacer(),
                  Row(
                    children: [
                      // عرض نسبة النمو أو الانخفاض مع أيقونة مناسبة
                      Expanded(
                        child: Text(
                          s.trend,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: s.isPositive ? const Color(0xFF10b981) : const Color(0xFFef4444),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildMiniTrendChart(s.history, s.isPositive), // الرسم البياني المصغر
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

  // إظهار نافذة تفاصيل المؤشر (Drill-down) مع عرض البيانات بصورة أعمق
  void _showKPIDrillDown(BuildContext context, CenterOperationalStat stat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('تفاصيل ${stat.label}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
            const SizedBox(height: 8),
            const Text('تحليل البيانات التاريخية والنمو في الفترة المختارة', style: TextStyle(fontSize: 12, color: Color(0xFF64748b))),
            const SizedBox(height: 32),
            // قائمة المعلومات التفصيلية للمؤشر
            Expanded(
              child: ListView(
                children: [
                  _buildDrillDownRow('القيمة الحالية', stat.value, Icons.analytics_rounded),
                  _buildDrillDownRow('معدل النمو', stat.trend, Icons.show_chart_rounded),
                  _buildDrillDownRow('المتوسط العام', '٨٢٪', Icons.bar_chart_rounded),
                  const SizedBox(height: 24),
                  // منطقة محاكاة الرسم البياني التفصيلي
                  Container(
                    height: 150,
                    decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFf1f5f9))),
                    child: const Center(child: Text('جاري تحميل الرسم البياني التفصيلي...', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 11))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء سطر معلومات داخل نافذة الـ Drill-down
  Widget _buildDrillDownRow(String label, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFF0ea5e9), size: 20),
        ],
      ),
    );
  }

  // بناء رسم بياني خطي مصغر (Sparkline) باستخدام الأعمدة لتمثيل التاريخ
  Widget _buildMiniTrendChart(List<double> history, bool positive) {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((h) => Container(
          width: 4,
          height: h * 20, // ارتفاع العمود بناءً على القيمة التاريخية
          decoration: BoxDecoration(color: (positive ? const Color(0xFF10b981) : const Color(0xFFef4444)).withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
        )).toList(),
      ),
    );
  }

  // بناء كارت الرسم البياني الكبير لمنحنى الصحة
  Widget _buildLargeChartCard() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0ea5e9), Color(0xFF0284c7)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF0ea5e9).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الإيرادات التشغيلية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('مقارنة بالشهر الماضي', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
               height: 60,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   _chartBar(40), _chartBar(60), _chartBar(30), _chartBar(80), _chartBar(50), _chartBar(90), _chartBar(70),
                 ],
               ),
            ),
          ),
        ],
      ),
    );
  }

  // رسم عمود فردي في الرسم البياني
  Widget _chartBar(double height) {
    return Container(width: 8, height: height, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4)));
  }

  // بناء كارت التنبيه العاجل (قابل للتفاعل)
  Widget _buildAlertCard(TaptabaNotification n, Color color, AppRiverpod provider) {
    return InkWell(
      onTap: () {
        // إذا كان التنبيه مرتبط بمقيم، افتح ملفه الشخصي
        if (n.residentId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminResidentDetailScreen(residentId: n.residentId!)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد ملف مرتبط بهذا التنبيه')));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Row(
          children: [
            // زر "تم الحل" يظهر فقط في التنبيهات النشطة
            if (!_showResolved)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Color(0xFF94a3b8), size: 18),
                onPressed: () => provider.resolveNotification(n.id),
              ),
            Text(n.time, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 10)),
            const Spacer(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(n.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  if (n.body.isNotEmpty)
                    Text(n.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Color(0xFF64748b))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // نقطة ملونة تعبر عن نوع التنبيه
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

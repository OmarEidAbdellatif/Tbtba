import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';

class AdminReportsView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;

  const AdminReportsView({super.key, required this.fadeAnimations});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFinancialReportCard(provider),
          const SizedBox(height: 20),
          _buildSafetyReportCard(provider),
          const SizedBox(height: 20),
          _buildExportSection(context, provider),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('تقارير الأداء المركزية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
        const SizedBox(height: 4),
        Text('محدث بتاريخ الآن', style: TextStyle(fontSize: 12, color: const Color(0xFF64748b).withOpacity(0.8))),
      ],
    );
  }

  Widget _buildFinancialReportCard(AppRiverpod provider) {
    final compliance = (provider.medicationComplianceRate * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFf1f5f9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Icon(Icons.more_horiz, color: Color(0xFF94a3b8)),
               Text('الأداء التشغيلي والمالي', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
            ],
          ),
          const SizedBox(height: 24),
          _buildChartMockup(Colors.blue),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statMini('$compliance%', 'التزام دوائي'),
              _statMini('٩٤٪', 'نسبة الإشغال'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyReportCard(AppRiverpod provider) {
    final unresolved = provider.unresolvedComplaintsCount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFfef2f2), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFfee2e2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Icon(Icons.warning_amber_rounded, color: Color(0xFFef4444), size: 18),
               Text('تقرير جودة الرعاية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991b1b))),
            ],
          ),
          const SizedBox(height: 16),
          _buildSafetyRow('شكاوى قيد المتابعة', unresolved.toString().padLeft(2, '٠'), Colors.red),
          _buildSafetyRow('إجمالي المقيمين', provider.residentFiles.length.toString().padLeft(2, '٠'), Colors.green),
          _buildSafetyRow('أعضاء الطاقم النشط', provider.activeStaffCount.toString().padLeft(2, '٠'), Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSafetyRow(String label, String val, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(val, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF7f1d1d))),
          const SizedBox(width: 8),
          Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildChartMockup(Color color) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) => Container(
          width: 25,
          height: (20 + (index * 10)).toDouble(),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
        )),
      ),
    );
  }

  static Widget _statMini(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
      ],
    );
  }

  Widget _buildExportSection(BuildContext context, AppRiverpod provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('تصدير البيانات والتحاليل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _exportBtn(context, 'Excel', Icons.table_chart_outlined, Colors.green, provider)),
            const SizedBox(width: 12),
            Expanded(child: _exportBtn(context, 'PDF Report', Icons.picture_as_pdf_outlined, Colors.red, provider)),
          ],
        ),
      ],
    );
  }

  Widget _exportBtn(BuildContext context, String label, IconData icon, Color c, AppRiverpod provider) {
    return InkWell(
      onTap: () => _showExportDialog(context, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: c, size: 18),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppRiverpod provider) {
    final summary = provider.generatePerformanceSummary();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('تقرير أداء الدار', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(summary, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Color(0xFF64748b))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0369a1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('مشاركة التقرير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

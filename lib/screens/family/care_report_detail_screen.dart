import 'package:flutter/material.dart';

class CareReportDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  const CareReportDetailScreen({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdfcfb),
      appBar: AppBar(
        title: const Text('تفاصيل التقرير', style: TextStyle(color: Color(0xFF1f2937), fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1f2937), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 24),
            _buildSection('الملخص المهني', 'يُظهر المقيم تحسناً ملحوظاً في التفاعل مع الأنشطة الجماعية وخاصة جلسات القراءة. الروح المعنوية مرتفعة والشهية للطعام منتظمة.'),
            const SizedBox(height: 20),
            _buildMetricsSection(),
            const SizedBox(height: 24),
            _buildSection('الملاحظات الاجتماعية', 'شارك في مسابقة الذاكرة وحصل على المركز الثاني. أبدى رغبة في التحدث عن ذكريات الطفولة مع زملائه في الغرفة.'),
            const SizedBox(height: 20),
            _buildSection('التوصيات', 'يُنصح بزيادة التفاعل العائلي عبر مكالمات الفيديو خلال عطلة نهاية الأسبوع لتعزيز الشعور بالانتماء.'),
            const SizedBox(height: 40),
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(date, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 11)),
              const Spacer(),
              const Text('تقرير تقييم دوري', style: TextStyle(color: Color(0xFFea580c), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFf1f5f9)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('أ. نور الدين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                   Text('أخصائي اجتماعي أول', style: TextStyle(color: Color(0xFF64748b), fontSize: 11)),
                ],
              ),
              SizedBox(width: 12),
              CircleAvatar(backgroundColor: Color(0xFFfee2e2), child: Text('ن', style: TextStyle(color: Color(0xFFef4444)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFea580c))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFf1f5f9))),
          child: Text(content, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF4b5563), fontSize: 13, height: 1.6)),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Row(
      children: [
        Expanded(child: _buildMiniMetric('التفاعل', 'ممتاز', const Color(0xFFdcfce7), const Color(0xFF166534))),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniMetric('المزاج', 'مستقر', const Color(0xFFdbeafe), const Color(0xFF1e4ed8))),
      ],
    );
  }

  Widget _buildMiniMetric(String label, String val, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('تواصل مع الأخصائي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
             SizedBox(width: 12),
             Icon(Icons.chat_outlined, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

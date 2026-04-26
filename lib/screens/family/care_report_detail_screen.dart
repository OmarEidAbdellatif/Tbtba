import 'package:flutter/material.dart';

class CareReportDetailScreen extends StatelessWidget {
  final String title;
  final String date;

  const CareReportDetailScreen(
      {super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F6),
      appBar: AppBar(
        title: const Text('تفاصيل التقرير',
            style: TextStyle(
                color: Color(0xFF1e293b),
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1e293b), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMainCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('الملخص المهني'),
                  const SizedBox(height: 12),
                  _buildContentCard(
                      'يُظهر المقيم تحسناً ملحوظاً في التفاعل مع الأنشطة الجماعية وخاصة جلسات القراءة. الروح المعنوية مرتفعة والشهية للطعام منتظمة.'),
                  const SizedBox(height: 24),
                  _buildMetricsRow(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('الملاحظات الاجتماعية'),
                  const SizedBox(height: 12),
                  _buildContentCard(
                      'شارك في مسابقة الذاكرة وحصل على المركز الثاني. أبدى رغبة في التحدث عن ذكريات الطفولة مع زملائه في الغرفة.'),
                  const SizedBox(height: 32),
                  _buildSectionHeader('التوصيات'),
                  const SizedBox(height: 12),
                  _buildContentCard(
                      'يُنصح بزيادة التفاعل العائلي عبر مكالمات الفيديو خلال عطلة نهاية الأسبوع لتعزيز الشعور بالانتماء.'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style:
                      const TextStyle(color: Color(0xFF94a3b8), fontSize: 14)),
              const Text('تقرير تقييم دوري',
                  style: TextStyle(
                      color: Color(0xFFea580c),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                  height: 1.3)),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFf1f5f9), thickness: 1.5),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('أ. نور الدين',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1e293b))),
                  Text('أخصائي اجتماعي أول',
                      style: TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: Color(0xFFfee2e2), shape: BoxShape.circle),
                child: const Center(
                    child: Text('ن',
                        style: TextStyle(
                            color: Color(0xFFef4444),
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFea580c)));
  }

  Widget _buildContentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: Color(0xFF4b5563),
              fontSize: 15,
              height: 1.7,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildMetricBox('التفاعل', 'ممتاز', const Color(0xFFf0fdf4),
                const Color(0xFF16a34a))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricBox('المزاج', 'مستقر', const Color(0xFFeff6ff),
                const Color(0xFF2563eb))),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: fg, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1e293b).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم فتح المحادثة مع الأخصائي')),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text('تواصل مع الأخصائي',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

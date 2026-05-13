import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class AdminVolunteerView extends StatelessWidget {
  final List<Animation<double>> fadeAnimations;

  const AdminVolunteerView({super.key, required this.fadeAnimations});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(appRiverpod);
        final opportunities = provider.volunteerOpportunities;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0ea5e9),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem(
                            opportunities.length.toString(), 'إجمالي الفرص'),
                        _summaryItem(
                            opportunities
                                .where((o) => o.status == 'متاحة')
                                .length
                                .toString(),
                            'فرص متاحة'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('الفرص التطوعية المتاحة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b))),
                  const SizedBox(height: 16),
                  if (opportunities.isEmpty)
                    const Center(child: Text('لا توجد فرص متاحة'))
                  else
                    ...opportunities.asMap().entries.map((entry) {
                      final index = entry.key;
                      final opp = entry.value;
                      return FadeTransition(
                        opacity: fadeAnimations[index % fadeAnimations.length],
                        child: _buildOpportunityCard(opp),
                      );
                    }),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () => _showAddOpportunitySheet(context, provider),
                backgroundColor: const Color(0xFF0ea5e9),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: Colors.white),
                label: const Text('إنشاء فرصة',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryItem(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildOpportunityCard(VolunteerOpportunity opp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFf1f5f9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(opp.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e293b))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: opp.status == 'متاحة'
                        ? const Color(0xFFdcfce7)
                        : const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(opp.status,
                    style: TextStyle(
                        color: opp.status == 'متاحة'
                            ? const Color(0xFF166534)
                            : const Color(0xFF94a3b8),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(opp.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFf59e0b), size: 16),
              const SizedBox(width: 4),
              Text('${opp.points} نقطة',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              const Spacer(),
              Text(opp.date,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
            ],
          )
        ],
      ),
    );
  }

  void _showAddOpportunitySheet(BuildContext context, AppRiverpod provider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedPoints = 50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('نشر فرصة تطوعية جديدة ✨',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              const Text('ستظهر الفرصة فوراً لجميع المتطوعين المتاحين.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748b))),
              const SizedBox(height: 24),
              _buildField(titleController, 'عنوان الفرصة (مثال: مرافقة طبية)'),
              const SizedBox(height: 12),
              _buildField(descController, 'وصف المهمة المطلوبة', maxLines: 3),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('النقاط الممنوحة',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155))),
                  Text('$selectedPoints نقطة',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0ea5e9))),
                ],
              ),
              Slider(
                value: selectedPoints.toDouble(),
                min: 10,
                max: 200,
                divisions: 19,
                activeColor: const Color(0xFF0ea5e9),
                onChanged: (val) =>
                    setModalState(() => selectedPoints = val.toInt()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty) {
                      final newOpp = VolunteerOpportunity(
                        id: 'opp${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text,
                        org: 'الإدارة العامة',
                        dateInfo: 'اليوم',
                        icon: '🌟',
                        tags: ['التواصل', 'عام'],
                        hours: 1,
                        isNew: true,
                        description: descController.text,
                        totalSlots: 5,
                        filledSlots: 0,
                        points: selectedPoints,
                      );
                      provider.addVolunteerOpportunity(newOpp);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نشر الفرصة بنجاح! 🎉'),
                          backgroundColor: Color(0xFF0ea5e9),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ea5e9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('نشر الفرصة الآن',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFf8fafc),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFe2e8f0))),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
      ),
    );
  }
}

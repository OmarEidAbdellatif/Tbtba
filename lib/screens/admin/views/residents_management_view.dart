import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class ResidentsManagementView extends StatelessWidget {
  final List<Animation<double>> fadeAnimations;

  const ResidentsManagementView({super.key, required this.fadeAnimations});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(appRiverpod);
        final residents = provider.residentFiles;

        return Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final r = residents[index];
                      return FadeTransition(
                        opacity: fadeAnimations[index % fadeAnimations.length],
                        child: _buildResidentControlCard(r.name, r.room, r.status, r.initials),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () => _showAddResidentSheet(context, ref),
                backgroundColor: const Color(0xFF0f172a),
                icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                label: const Text('إضافة مقيم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddResidentSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final roomController = TextEditingController();
    String selectedStatus = 'updated'; // Default: Stable

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('تسجيل مقيم جديد 👥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
              const Text('أدخل البيانات الأساسية لفتح ملف تعريف جديد', style: TextStyle(fontSize: 13, color: Color(0xFF64748b))),
              const SizedBox(height: 24),
              _buildLabel('اسم المقيم'),
              const SizedBox(height: 8),
              _buildField(nameController, 'مثلاً: الحاج محمود الجوهري'),
              const SizedBox(height: 20),
              _buildLabel('رقم الغرفة'),
              const SizedBox(height: 8),
              _buildField(roomController, 'مثلاً: ٢٠٥', keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildLabel('الحالة الأولية'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusOption('critical', 'حرجة', Colors.red, selectedStatus == 'critical', () => setModalState(() => selectedStatus = 'critical')),
                  const SizedBox(width: 10),
                  _buildStatusOption('pending', 'متابعة', Colors.amber, selectedStatus == 'pending', () => setModalState(() => selectedStatus = 'pending')),
                  const SizedBox(width: 10),
                  _buildStatusOption('updated', 'مستقرة', Colors.green, selectedStatus == 'updated', () => setModalState(() => selectedStatus = 'updated')),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && roomController.text.isNotEmpty) {
                      final initials = nameController.text.length >= 2 ? nameController.text.substring(0, 2) : 'مق';
                      final newResident = SpecialistResidentFile(
                        id: 'r${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        room: roomController.text,
                        status: selectedStatus,
                        lastUpdate: 'الآن',
                        categories: ['admin'],
                        initials: initials,
                      );
                      ref.read(appRiverpod).addResident(newResident);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم تسجيل "${nameController.text}" بنجاح! 🎉'),
                          backgroundColor: const Color(0xFF0ea5e9),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ea5e9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('تأكيد التسجيل', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)));
  }

  Widget _buildField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, Color color, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : const Color(0xFFe2e8f0)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748b), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFe2e8f0))),
        child: const TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(hintText: 'بحث عن مقيم أو غرفة...', hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94a3b8)), border: InputBorder.none, icon: Icon(Icons.search, color: Color(0xFF94a3b8), size: 20)),
        ),
      ),
    );
  }

  Widget _buildResidentControlCard(String name, String room, String status, String initials) {
    Color statusColor = status == 'critical' ? Colors.red : (status == 'pending' ? Colors.amber : Colors.green);
    String statusText = status == 'critical' ? 'حالة حرجة' : (status == 'pending' ? 'متابعة دقيقة' : 'مستقر');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFf1f5f9))),
      child: Row(
        children: [
          _buildActionBtn('التفاصيل'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              Text('غرفة $room', style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), radius: 24, child: Text(initials, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748b))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class MedicalAdminView extends ConsumerStatefulWidget {
  const MedicalAdminView({super.key});

  @override
  ConsumerState<MedicalAdminView> createState() => _MedicalAdminViewState();
}

class _MedicalAdminViewState extends ConsumerState<MedicalAdminView> {
  final TextEditingController _medName = TextEditingController();
  final TextEditingController _medDosage = TextEditingController();
  String _selectedTime = 'الصباح';

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('الإدارة الطبية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
          const Text('تسجيل الأدوية، الجلسات، والملاحظات الطبية', style: TextStyle(fontSize: 12, color: Color(0xFF0EA5E9))),
          const SizedBox(height: 24),

          _buildEntryCard(
            title: 'إضافة دواء جديد',
            icon: Icons.medication_rounded,
            color: const Color(0xFF0EA5E9),
            child: Column(
              children: [
                _buildTextField(_medName, 'اسم الدواء', Icons.medical_services_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_medDosage, 'الجرعة', Icons.shutter_speed_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionBtn('تسجيل الدواء لكافة الأنظمة', () {
                   if (_medName.text.isNotEmpty) {
                     provider.addMedication('الحاج محمود', Medication(
                       id: DateTime.now().toString(),
                       name: _medName.text,
                       dosage: _medDosage.text,
                       timeDescription: 'حسب الجدول',
                       timeOfDay: _selectedTime,
                     ));
                     _medName.clear();
                     _medDosage.clear();
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الدواء بنجاح')));
                   }
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildEntryCard(
            title: 'تسجيل جلسة / زيارة طبيب',
            icon: Icons.person_search_rounded,
            color: const Color(0xFF6366F1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSessionType('علاج طبيعي', Icons.accessibility_new_rounded),
                    _buildSessionType('زيارة طبيب', Icons.local_hospital_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionBtn('بدء تسجيل تفاصيل الجلسة', () {}),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('سجل الزيارات والروشتات المرفوعة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const SizedBox(height: 12),
          ...provider.medicalSessions.map((s) => _buildSessionLog(s)).toList(),
          const SizedBox(height: 12),
          ...provider.medicalPrescriptions.map((p) => _buildPrescriptionCard(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildEntryCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 10),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          suffixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTime,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1e293b), fontWeight: FontWeight.bold),
          items: ['الصباح', 'الظهر', 'المساء'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _selectedTime = v!),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSessionType(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF0F9FF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildSessionLog(MedicalSession s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          _buildSessionBadge(s.type),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(s.specialistName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${s.residentName} · ${s.time}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), radius: 18, child: Icon(Icons.history_edu_rounded, size: 16, color: Color(0xFF0369A1))),
        ],
      ),
    );
  }

  Widget _buildSessionBadge(String type) {
    bool isDoc = type == 'doctor';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isDoc ? const Color(0xFFF0F9FF) : const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
      child: Text(isDoc ? 'زيارة طبيب' : 'علاج طبيعي', style: TextStyle(color: isDoc ? const Color(0xFF0369A1) : const Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPrescriptionCard(MedicalPrescription p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF8FAFC), Colors.white]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.file_present_rounded, color: Color(0xFF0EA5E9)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(p.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${p.doctorName} · ${p.date}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

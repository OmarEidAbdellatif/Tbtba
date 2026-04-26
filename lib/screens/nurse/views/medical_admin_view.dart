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
  final TextEditingController _specialistName = TextEditingController();
  final TextEditingController _sessionNotes = TextEditingController();
  final TextEditingController _prescTitle = TextEditingController();

  String _selectedResident = 'الحاج محمود سالم';
  String _selectedTime = 'الصباح';
  String _sessionType = 'doctor'; // 'doctor' or 'pt'

  final List<String> _residents = [
    'الحاج محمود سالم',
    'الحاجة فاطمة علي',
    'الحاج أحمد كمال',
    'الحاجة سمية إبراهيم'
  ];

  @override
  void dispose() {
    _medName.dispose();
    _medDosage.dispose();
    _specialistName.dispose();
    _sessionNotes.dispose();
    _prescTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          
          _buildResidentSelector(),
          const SizedBox(height: 20),

          _buildEntryCard(
            title: 'تسجيل دواء جديد',
            subtitle: 'سيتم إضافته لجدول الأدوية والملف الطبي',
            icon: Icons.medication_rounded,
            color: const Color(0xFF0EA5E9),
            child: Column(
              children: [
                _buildTextField(_medName, 'اسم الدواء (مثال: كونكور ٥ ملغ)', Icons.medical_services_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdown(_selectedTime, ['الصباح', 'الظهر', 'المساء'], (v) => setState(() => _selectedTime = v!))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_medDosage, 'الجرعة (مثال: قرص واحد)', Icons.shutter_speed_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionBtn('حفظ وتسجيل الدواء', const Color(0xFF0EA5E9), () {
                   if (_medName.text.isNotEmpty) {
                     provider.addMedication(_selectedResident, Medication(
                       id: DateTime.now().toString(),
                       name: _medName.text,
                       dosage: _medDosage.text,
                       timeDescription: 'حسب الجدول المعتمد',
                       timeOfDay: _selectedTime,
                       dayTag: 'اليوم',
                     ));
                     
                     // Also update ResidentMedicalInfo
                     final info = provider.getMedicalInfo(_selectedResident);
                     provider.updateMedicalInfo(ResidentMedicalInfo(
                       residentName: _selectedResident,
                       medications: [...info.medications, '${_medName.text} (${_medDosage.text})'],
                       allergies: info.allergies,
                       chronicDiseases: info.chronicDiseases,
                     ));

                     _medName.clear();
                     _medDosage.clear();
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدواء وتحديث الملف الطبي ✅')));
                   }
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildEntryCard(
            title: 'تسجيل جلسة / زيارة طبيب',
            subtitle: 'توثيق نتائج الكشف أو جلسات العلاج',
            icon: Icons.person_search_rounded,
            color: const Color(0xFF6366F1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSessionTypeSelector('زيارة طبيب', Icons.local_hospital_rounded, 'doctor'),
                    _buildSessionTypeSelector('علاج طبيعي', Icons.accessibility_new_rounded, 'pt'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(_specialistName, 'اسم الطبيب أو الأخصائي', Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildTextField(_sessionNotes, 'ملاحظات الجلسة والنتائج', Icons.note_alt_outlined, maxLines: 2),
                const SizedBox(height: 16),
                _buildActionBtn('توثيق الجلسة في السجل', const Color(0xFF6366F1), () {
                  if (_specialistName.text.isNotEmpty) {
                    provider.logMedicalSession(MedicalSession(
                      id: DateTime.now().toString(),
                      type: _sessionType,
                      specialistName: _specialistName.text,
                      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      date: 'اليوم',
                      notes: _sessionNotes.text,
                      residentName: _selectedResident,
                    ));
                    _specialistName.clear();
                    _sessionNotes.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم توثيق الجلسة بنجاح ✅')));
                  }
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildEntryCard(
            title: 'رفع روشتة / تقرير',
            subtitle: 'أرشفة المستندات الطبية الورقية',
            icon: Icons.file_upload_rounded,
            color: const Color(0xFF10B981),
            child: Column(
              children: [
                _buildTextField(_prescTitle, 'عنوان المستند (مثال: روشتة الصدر)', Icons.title_rounded),
                const SizedBox(height: 16),
                _buildActionBtn('رفع المستند للملف', const Color(0xFF10B981), () {
                  if (_prescTitle.text.isNotEmpty) {
                    _showUploadSimulation(() {
                      provider.addPrescription(MedicalPrescription(
                        id: DateTime.now().toString(),
                        title: _prescTitle.text,
                        doctorName: 'د. خالد صفا (مرفق)',
                        date: '٢٠ أبريل ٢٠٢٤',
                        residentName: _selectedResident,
                      ));
                      _prescTitle.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع المستند وأرشفته بنجاح ✅')));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة عنوان للمستند أولاً ⚠️')));
                  }
                }),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('آخر العمليات المسجلة', Icons.history_rounded),
          const SizedBox(height: 12),
          ...provider.medicalSessions.take(3).map((s) => _buildSessionLog(s)).toList(),
          const SizedBox(height: 12),
          ...provider.medicalPrescriptions.take(2).map((p) => _buildPrescriptionCard(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('الإدارة الطبية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0369A1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('التحكم المركزي في الأدوية، الجلسات، والتقارير الطبية', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildResidentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, color: Color(0xFF0369A1), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedResident,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0369A1)),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'Cairo'),
                items: _residents.map((r) => DropdownMenuItem(value: r, child: Text(r, textAlign: TextAlign.right))).toList(),
                onChanged: (v) => setState(() => _selectedResident = v!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(': اختيار المقيم', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

   Widget _buildEntryCard({required String title, required String subtitle, required IconData icon, required Color color, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
          suffixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF94A3B8), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textAlign: TextAlign.right))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSessionTypeSelector(String label, IconData icon, String type) {
    bool isSelected = _sessionType == type;
    return GestureDetector(
      onTap: () => setState(() => _sessionType = type),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF64748B), size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(width: 8),
        Icon(icon, color: const Color(0xFF64748B), size: 18),
      ],
    );
  }

  Widget _buildSessionLog(MedicalSession s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildSessionBadge(s.type),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(s.specialistName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.file_present_rounded, color: Color(0xFF10B981), size: 24),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(p.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('${p.residentName} · ${p.date}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 18),
        ],
      ),
    );
  }

  void _showUploadSimulation(VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 3),
              const SizedBox(height: 24),
              const Text('جاري معالجة المستند...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo', decoration: TextDecoration.none, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              const Text('يتم أرشفته في ملف المقيم الآن', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), decoration: TextDecoration.none, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      onComplete();
    });
  }
}

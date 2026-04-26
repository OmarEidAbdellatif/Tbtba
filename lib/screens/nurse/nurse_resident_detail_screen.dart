import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class NurseResidentDetailScreen extends ConsumerStatefulWidget {
  final String residentName;
  final String roomNumber;

  const NurseResidentDetailScreen({
    super.key,
    required this.residentName,
    required this.roomNumber,
  });

  @override
  ConsumerState<NurseResidentDetailScreen> createState() => _NurseResidentDetailScreenState();
}

class _NurseResidentDetailScreenState extends ConsumerState<NurseResidentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();
  
  // Dynamic data for the demo
  final List<String> _meds = ['ميتفورمين ٥٠٠ ملغ', 'أسبرين حماية', 'فيتامين د٣'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    final residentNotes = provider.getNotesForResident(widget.residentName);
    final medicalInfo = provider.getMedicalInfo(widget.residentName);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('الملف الطبي المتكامل', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: Color(0xFF0369A1)),
            onPressed: _simulatePrint,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildResidentHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicalFileTab(medicalInfo),
                _buildNotesTab(residentNotes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('حالة حرجة 🔴', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(widget.residentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('غرفة ${widget.roomNumber} · ٧٨ سنة', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ],
          ),
          const Spacer(),
          Hero(
            tag: widget.residentName,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE0F2FE),
              child: Text(widget.residentName.substring(0, 2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF0369A1),
        indicatorWeight: 3,
        labelColor: const Color(0xFF0369A1),
        unselectedLabelColor: const Color(0xFF94A3B8),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
        tabs: const [
          Tab(text: 'الملف الطبي'),
          Tab(text: 'الملاحظات'),
        ],
      ),
    );
  }

  Widget _buildMedicalFileTab(ResidentMedicalInfo info) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitleWithAdd('الأمراض المزمنة', () => _showAddItemDialog('مرض مزمن', (v) {
          final newDiseases = List<String>.from(info.chronicDiseases)..add(v);
          ref.read(appRiverpod).updateMedicalInfo(ResidentMedicalInfo(
            residentName: info.residentName,
            medications: info.medications,
            allergies: info.allergies,
            chronicDiseases: newDiseases,
          ));
        })),
        _buildInfoCard(Icons.medical_information_rounded, info.chronicDiseases.isEmpty ? 'لا توجد أمراض مسجلة' : info.chronicDiseases.join('، ')),
        const SizedBox(height: 20),
        _buildSectionTitleWithAdd('الحساسية', () => _showAddItemDialog('حساسية', (v) {
          final newAllergies = List<String>.from(info.allergies)..add(v);
          ref.read(appRiverpod).updateMedicalInfo(ResidentMedicalInfo(
            residentName: info.residentName,
            medications: info.medications,
            allergies: newAllergies,
            chronicDiseases: info.chronicDiseases,
          ));
        })),
        _buildInfoCard(Icons.warning_amber_rounded, info.allergies.isEmpty ? 'لا توجد حساسية مسجلة' : info.allergies.join('، '), color: const Color(0xFFEF4444)),
        const SizedBox(height: 24),
        _buildSectionTitleWithAdd('الأدوية الحالية', _showAddMedicationDialog),
        _buildMedicineList(info.medications),
      ],
    );
  }

  Widget _buildSectionTitleWithAdd(String title, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF0369A1)),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          Text(title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text, {Color color = const Color(0xFF0369A1)}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Color(0xFF475569)))),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }

  Widget _buildMedicineList(List<String> meds) {
    if (meds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: const Center(child: Text('لا توجد أدوية مسجلة', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: meds.map((m) => ListTile(
          trailing: const Icon(Icons.medication_rounded, color: Color(0xFF0369A1), size: 20),
          title: Text(m, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: const Text('حسب تعليمات الطبيب', textAlign: TextAlign.right, style: TextStyle(fontSize: 11)),
        )).toList(),
      ),
    );
  }

  Widget _buildNotesTab(List<NursingNote> notes) {
    return Column(
      children: [
        Expanded(
          child: notes.isEmpty 
            ? const Center(child: Text('لا توجد ملاحظات حالياً', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteItem(note);
                },
              ),
        ),
        _buildNoteInput(),
      ],
    );
  }

  Widget _buildNoteItem(NursingNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('منذ فترة قريبة', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(6)),
                child: Text(note.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0369A1), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(note.content, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteTitleController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'عنوان الملاحظة...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('إضافة ملاحظة', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xFF0369A1), shape: BoxShape.circle),
                child: IconButton(
                  onPressed: () {
                    if (_noteTitleController.text.isNotEmpty && _noteContentController.text.isNotEmpty) {
                      final newNote = NursingNote(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        residentName: widget.residentName,
                        title: _noteTitleController.text,
                        content: _noteContentController.text,
                        author: 'أ. منى (مشرف)',
                        timestamp: DateTime.now(),
                      );
                      ref.read(appRiverpod).addNursingNote(newNote);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الملاحظة بنجاح ✅')));
                      _noteTitleController.clear();
                      _noteContentController.clear();
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _noteContentController,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب تفاصيل الملاحظة هنا...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showAddItemDialog(String label, Function(String) onAdd) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إضافة $label جديد', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'اكتب هنا...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة $label بنجاح ✅')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0369A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    final TextEditingController medNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة دواء جديد', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        content: TextField(
          controller: medNameController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'اسم الدواء والجرعة...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (medNameController.text.isNotEmpty) {
                final provider = ref.read(appRiverpod);
                final info = provider.getMedicalInfo(widget.residentName);
                final newMeds = List<String>.from(info.medications)..add(medNameController.text);
                provider.updateMedicalInfo(ResidentMedicalInfo(
                  residentName: info.residentName,
                  medications: newMeds,
                  allergies: info.allergies,
                  chronicDiseases: info.chronicDiseases,
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الدواء بنجاح ✅')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0369A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _simulatePrint() {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF0369A1)),
                SizedBox(height: 24),
                Text('جاري تحويل الملف إلى PDF...', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحميل الملف الطبي الكامل بنجاح ✅')));
    });
  }
}

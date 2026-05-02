import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import '../../widgets/taptaba_scaffold.dart';

// شاشة تفاصيل ملف المقيم الخاصة بالمدير - تعرض معلومات شاملة وحالة المتابعة
class AdminResidentDetailScreen extends ConsumerWidget {
  final String residentId; // معرف المقيم المطلوب عرض تفاصيله

  const AdminResidentDetailScreen({super.key, required this.residentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);
    // البحث عن بيانات المقيم في قائمة الملفات المتاحة لدى المدير
    final resident = provider.residentFiles.firstWhere((r) => r.id == residentId);

    return TaptabaScaffold(
      title: 'ملف المقيم',
      overrideRole: 'مدير',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(resident), // واجهة التعريف بالمقيم (الاسم، الغرفة)
            _buildQuickStatus(resident), // ملخص الحالة الصحية والاجتماعية الحالية
            _buildFamilySection(resident), // قسم بيانات الأقارب وجهات الاتصال
            _buildCategoriesSection(resident), // الملفات والتقييمات المرتبطة بالمقيم
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // بناء الجزء العلوي للملف الشخصي مع خلفية متدرجة احترافية
  Widget _buildProfileHeader(SpecialistResidentFile resident) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b)], // ألوان كحلية رسمية تليق بنظام المدير
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // عرض الحروف الأولى من اسم المقيم (Avatar)
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Text(resident.initials, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Text(resident.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(resident.nameEn, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('غرفة ${resident.room} — ${resident.age ?? "??"} عاماً', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 20),
          // أزرار سريعة للتواصل مع المقيم أو المسؤولين عنه
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerAction(Icons.phone_rounded, 'اتصال'),
              const SizedBox(width: 12),
              _headerAction(Icons.message_rounded, 'رسالة'),
            ],
          ),
        ],
      ),
    );
  }

  // بناء زر إجراء سريع في الترويسة
  Widget _headerAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  // بناء ملخص الحالة (مستقر، حرج، متابعة)
  Widget _buildQuickStatus(SpecialistResidentFile resident) {
    Color statusColor = resident.status == 'critical' ? Colors.red : (resident.status == 'pending' ? Colors.amber : Colors.green);
    String statusText = resident.status == 'critical' ? 'حالة حرجة' : (resident.status == 'pending' ? 'متابعة دقيقة' : 'مستقر');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('ملخص الحالة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFf1f5f9)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resident.lastUpdate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                    const Text('آخر تحديث للملف', style: TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // وسام (Badge) يظهر حالة المقيم الحالية
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const Text('الحالة الحالية', style: TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء قسم الأقارب وطرق الاتصال بهم
  Widget _buildFamilySection(SpecialistResidentFile resident) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تعديل', style: TextStyle(color: Color(0xFF0ea5e9), fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('الأقارب والاتصال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
            ],
          ),
          const SizedBox(height: 12),
          if (resident.familyMembers.isEmpty)
            _buildEmptyFamily()
          else
            ...resident.familyMembers.map((f) => _buildFamilyCard(f)),
        ],
      ),
    );
  }

  // واجهة تظهر في حال عدم وجود أقارب مسجلين
  Widget _buildEmptyFamily() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFe2e8f0), style: BorderStyle.solid)),
      child: const Column(
        children: [
          Icon(Icons.family_restroom_rounded, color: Color(0xFF94a3b8), size: 30),
          SizedBox(height: 8),
          Text('لا يوجد أقارب مسجلين لهذا المقيم', style: TextStyle(color: Color(0xFF64748b), fontSize: 12)),
        ],
      ),
    );
  }

  // بناء كارت بيانات القريب (الاسم، العلاقة، الاتصال)
  Widget _buildFamilyCard(FamilyMember f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFf1f5f9))),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10b981), size: 20),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              Text(f.relation, style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(backgroundColor: const Color(0xFFf1f5f9), radius: 20, child: Text(f.initials, style: const TextStyle(fontSize: 12, color: Color(0xFF1e293b)))),
        ],
      ),
    );
  }

  // بناء قسم يظهر أنواع الملفات والتقييمات المتاحة لهذا المقيم
  Widget _buildCategoriesSection(SpecialistResidentFile resident) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('الملفات النشطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: resident.categories.map((c) => _categoryChip(c)).toList(),
          ),
        ],
      ),
    );
  }

  // بناء "Chip" صغير لكل تصنيف (طبي، اجتماعي، إلخ)
  Widget _categoryChip(String cat) {
    String label = cat == 'social' ? 'أخصائي اجتماعي' : (cat == 'medical' ? 'طبي' : (cat == 'psychological' ? 'نفسي' : 'إداري'));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFf0f9ff), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFbae6fd))),
      child: Text(label, style: const TextStyle(color: Color(0xFF0369a1), fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

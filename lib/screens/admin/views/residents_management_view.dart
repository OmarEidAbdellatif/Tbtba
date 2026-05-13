import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';
import '../admin_resident_detail_screen.dart';

class ResidentsManagementView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations;

  const ResidentsManagementView({super.key, required this.fadeAnimations});

  @override
  ConsumerState<ResidentsManagementView> createState() =>
      _ResidentsManagementViewState();
}

class _ResidentsManagementViewState
    extends ConsumerState<ResidentsManagementView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    final filteredResidents = provider.residentFiles.where((r) {
      final nameMatch = r.name.contains(_searchQuery);
      final roomMatch = r.room.contains(_searchQuery);
      final nameEnMatch =
          r.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || roomMatch || nameEnMatch;
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            if (filteredResidents.isEmpty)
              _buildEmptyState()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(filteredResidents.length, (index) {
                    final r = filteredResidents[index];
                    return FadeTransition(
                      opacity: widget
                          .fadeAnimations[index % widget.fadeAnimations.length],
                      child: _buildResidentControlCard(r),
                    );
                  }),
                ),
              ),
            const SizedBox(height: 100), // مساحة للزر العائم
          ],
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _showResidentForm(context, ref),
            backgroundColor: const Color(0xFF0f172a),
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('إضافة مقيم',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo')),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('لا يوجد نتائج لـ "$_searchQuery"',
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFe2e8f0))),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'بحث عن مقيم أو غرفة...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Color(0xFF94a3b8), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildResidentControlCard(SpecialistResidentFile r) {
    Color statusColor = r.status == 'critical'
        ? Colors.red
        : (r.status == 'pending' ? Colors.amber : Colors.green);
    String statusText = r.status == 'critical'
        ? 'حالة حرجة'
        : (r.status == 'pending' ? 'متابعة دقيقة' : 'مستقر');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFf1f5f9))),
      child: Column(
        children: [
          Row(
            children: [
              // 1. أيقونة التعريف (أقصى اليمين)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(r.name.substring(0, min(2, r.name.length)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              // 2. معلومات المقيم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0f172a))),
                    if (r.familyEmail != null)
                      Text('مرتبط بـ: ${r.familyEmail}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF0ea5e9)))
                    else
                      Text(r.nameEn,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748b))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 3. قائمة الخيارات المنبثقة (الجهة اليسرى)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Color(0xFF94a3b8)),
                color: const Color(0xFFf8fafc), // خلفية هادئة
                elevation: 6, // شادو
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        const BorderSide(color: Color(0xFFe2e8f0), width: 0.5)),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showResidentForm(context, ref, resident: r);
                      break;
                    case 'details':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AdminResidentDetailScreen(residentId: r.id)));
                      break;
                    case 'link':
                      _showLinkFamilySheet(context, ref, r);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  _buildPopupItem('تعديل', Icons.edit_outlined, 'edit'),
                  _buildPopupItem(
                      'التفاصيل', Icons.info_outline_rounded, 'details'),
                  _buildPopupItem(
                      'ربط العائلة', Icons.family_restroom_outlined, 'link',
                      color: const Color(0xFF0ea5e9)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 56),
              Text('غرفة ${r.room}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569))),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String label, IconData icon, String val,
      {Color? color}) {
    return PopupMenuItem<String>(
      value: val,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: color ?? const Color(0xFF334155),
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          Icon(icon, color: color ?? const Color(0xFF94a3b8), size: 18),
        ],
      ),
    );
  }

  void _showResidentForm(BuildContext context, WidgetRef ref,
      {SpecialistResidentFile? resident}) {
    final bool isEdit = resident != null;
    final nameArController = TextEditingController(text: resident?.name ?? '');
    final nameEnController =
        TextEditingController(text: resident?.nameEn ?? '');
    final roomController = TextEditingController(text: resident?.room ?? '');
    final phoneController = TextEditingController(text: resident?.phone ?? '');
    final ageController =
        TextEditingController(text: resident?.age?.toString() ?? '');
    final passwordController = TextEditingController();
    String selectedStatus = resident?.status ?? 'updated';

    // Validation State
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                  Text(isEdit ? 'تعديل بيانات المقيم ✏️' : 'تسجيل مقيم جديد 👥',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0f172a))),
                  const Text(
                      'يرجى التأكد من دقة البيانات المدخلة للحفاظ على جودة السجلات',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                  const SizedBox(height: 24),
                  _buildLabel('الاسم بالعربية *'),
                  _buildField(nameArController, 'مثلاً: محمود الجوهري',
                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null),
                  const SizedBox(height: 16),
                  _buildLabel('الاسم بالإنجليزية *'),
                  _buildField(nameEnController, 'Example: Mahmoud El Gohary',
                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                      isEn: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('العمر'),
                            _buildField(ageController, '٧٠',
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('رقم الغرفة *'),
                            _buildField(roomController, '٢٠٥',
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('رقم الهاتف / اسم المستخدم'),
                  _buildField(phoneController, '01xxxxxxxxx',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'مطلوب للدخول' : null),
                  const SizedBox(height: 16),
                  _buildLabel('كلمة المرور للدخول'),
                  _buildField(passwordController, 'أدخل كلمة مرور للمسن',
                      validator: (v) => v!.isEmpty ? 'مطلوب للدخول' : null),
                  const SizedBox(height: 20),
                  _buildLabel('الحالة الصحية'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statusOption(
                          'critical',
                          'حرجة',
                          Colors.red,
                          selectedStatus == 'critical',
                          () =>
                              setModalState(() => selectedStatus = 'critical')),
                      const SizedBox(width: 10),
                      _statusOption(
                          'pending',
                          'متابعة',
                          Colors.amber,
                          selectedStatus == 'pending',
                          () =>
                              setModalState(() => selectedStatus = 'pending')),
                      const SizedBox(width: 10),
                      _statusOption(
                          'updated',
                          'مستقرة',
                          Colors.green,
                          selectedStatus == 'updated',
                          () =>
                              setModalState(() => selectedStatus = 'updated')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // 1. إنشاء الحساب للدخول إذا كان مقيم جديد
                          if (!isEdit) {
                            ref.read(appRiverpod).createAccount(
                                  name: nameArController.text,
                                  email: phoneController
                                      .text, // يستخدم الهاتف كمعرف
                                  password: passwordController.text,
                                  role: 'مسن',
                                );
                          }

                          // 2. تحديث/إضافة بيانات المقيم
                          final initials = nameArController.text.length >= 2
                              ? nameArController.text.substring(0, 2)
                              : 'مق';
                          final residentData = SpecialistResidentFile(
                            id: isEdit
                                ? resident.id
                                : 'r${DateTime.now().millisecondsSinceEpoch}',
                            name: nameArController.text,
                            nameEn: nameEnController.text,
                            room: roomController.text,
                            status: selectedStatus,
                            lastUpdate:
                                isEdit ? 'تم التعديل الآن' : 'تم التسجيل الآن',
                            categories:
                                isEdit ? resident.categories : ['admin'],
                            initials: initials,
                            familyMembers: isEdit ? resident.familyMembers : [],
                            age: int.tryParse(ageController.text) ?? 70,
                            phone: phoneController.text,
                            familyEmail: isEdit ? resident.familyEmail : null,
                          );

                          if (isEdit) {
                            ref.read(appRiverpod).updateResident(residentData);
                          } else {
                            ref.read(appRiverpod).addResident(residentData);
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit
                                  ? 'تم تحديث بيانات المقيم بنجاح! ✅'
                                  : 'تم تسجيل المقيم وحسابه بنجاح! 🎉'),
                              backgroundColor: const Color(0xFF10b981),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0ea5e9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: Text(isEdit ? 'حفظ التعديلات' : 'تأكيد التسجيل',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155))),
      );

  Widget _buildField(TextEditingController controller, String hint,
      {TextInputType? keyboardType,
      String? Function(String?)? validator,
      bool isEn = false}) {
    return TextFormField(
      controller: controller,
      textAlign: isEn ? TextAlign.left : TextAlign.right,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
        filled: true,
        fillColor: const Color(0xFFf8fafc),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0ea5e9))),
        errorStyle: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _statusOption(String value, String label, Color color, bool isSelected,
      VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? color : const Color(0xFFe2e8f0))),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748b),
                      fontSize: 13,
                      fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  void _showLinkFamilySheet(
      BuildContext context, WidgetRef ref, SpecialistResidentFile resident) {
    final emailController = TextEditingController(text: resident.familyEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
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
            Text('ربط فرد عائلة بـ ${resident.name} 🔗',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0f172a))),
            const Text(
                'أدخل البريد الإلكتروني المسجل لفرد العائلة ليتمكن من متابعة حالة المسن',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748b))),
            const SizedBox(height: 24),
            _buildLabel('بريد فرد العائلة'),
            _buildField(emailController, 'example@family.com',
                keyboardType: TextInputType.emailAddress, isEn: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(appRiverpod)
                      .linkFamilyToResident(resident.id, emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم ربط فرد العائلة بنجاح! ✅'),
                        backgroundColor: Color(0xFF10b981)),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ea5e9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('تأكيد الربط',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

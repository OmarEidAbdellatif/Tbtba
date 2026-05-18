import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // مكتبة اختيار الصور
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class SpecialistActivitiesView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistActivitiesView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
    required this.onNavigate,
  });

  @override
  ConsumerState<SpecialistActivitiesView> createState() => _SpecialistActivitiesViewState();
}

class _SpecialistActivitiesViewState extends ConsumerState<SpecialistActivitiesView> {
  // بيانات تجريبية للأنشطة مع التفاصيل الجديدة (تم نقلها هنا لتكون قابلة للتعديل)
  final List<Map<String, dynamic>> activities = [
    {
      'title': 'رحلة لحديقة الأزهر',
      'type': 'رحلة',
      'date': 'اليوم، 10:00 ص',
      'status': 'قادم',
      'icon': '🌳',
      'color': const Color(0xFF10b981),
      'bg': const Color(0xFFd1fae5),
      'target': 'لكل المقيمين',
      'location': 'حديقة الأزهر',
      'supervisor': 'أ. سارة المنسق',
      'image': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=200',
    },
    {
      'title': 'جلسة رسم وأشغال يدوية',
      'type': 'نشاط',
      'date': 'غداً، 11:30 ص',
      'status': 'مجدول',
      'icon': '🎨',
      'color': const Color(0xFF3b82f6),
      'bg': const Color(0xFFdbeafe),
      'target': 'قسم الرعاية الخاصة',
      'location': 'قاعة الأنشطة',
      'supervisor': 'أ. محمد علي',
    },
    {
      'title': 'مسابقة حفظ القرآن الكريم',
      'type': 'نشاط',
      'date': '٢٥ مايو، ٠٤:٠٠ م',
      'status': 'مجدول',
      'icon': '📖',
      'color': const Color(0xFFf59e0b),
      'bg': const Color(0xFFfef3c7),
      'target': 'الراغبين فقط',
      'location': 'المسجد',
      'supervisor': 'الشيخ أحمد',
    },
    {
      'title': 'زيارة لمعرض الكتاب',
      'type': 'رحلة',
      'date': 'أمس، ٠٩:٠٠ ص',
      'status': 'مكتمل',
      'icon': '📚',
      'color': const Color(0xFF64748b),
      'bg': const Color(0xFFf1f5f9),
      'target': 'المجموعة الثقافية',
      'location': 'معرض الكتاب',
      'supervisor': 'أ. نورهان سعيد',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // العنوان الرئيسي
          FadeTransition(
            opacity: widget.fadeAnimations[0],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأنشطة والرحلات',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1e293b))),
                    Text('تنظيم وإدارة الأنشطة الترفيهية',
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748b))),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddActivityModal(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة نشاط', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFea580c),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // قائمة الأنشطة
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final act = activities[index];
                return FadeTransition(
                  opacity: widget.fadeAnimations[1],
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12), // تقليل المسافة الخارجية قليلاً
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // تقليل الحشو الداخلي بشكل كبير لحل الأوفرفلو
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // تقليل الانحناء قليلاً
                      border: Border.all(color: const Color(0xFFe2e8f0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: (act['color'] as Color).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // جعلها في المنتصف لتوزيع المساحة
                      children: [
                        // الأيقونة أو الصورة
                        Container(
                          width: 48, // تقليل الحجم ليوفر مساحة
                          height: 48,
                          decoration: BoxDecoration(
                            color: act['bg'] as Color,
                            borderRadius: BorderRadius.circular(10),
                            image: act['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(act['image'] as String),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: act['image'] == null
                              ? Center(
                                  child: Text(act['icon'] as String, style: const TextStyle(fontSize: 22)),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12), // تقليل المسافة
                        // التفاصيل
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(act['title'] as String,
                                  maxLines: 1, // منع السطر الثاني لعدم حدوث أوفرفلو
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15, // تقليل حجم الخط قليلاً
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0f172a))),
                              const SizedBox(height: 3), // تقليل المسافات البينية
                              // السطر الأول: التاريخ والنوع
                              Wrap(
                                spacing: 8,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time_filled_rounded, size: 12, color: Colors.grey[700]),
                                      const SizedBox(width: 2),
                                      Text(act['date'] as String, style: TextStyle(fontSize: 11, color: const Color(0xFF334155), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (act['color'] as Color).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(act['type'] as String, style: TextStyle(fontSize: 10, color: act['color'] as Color, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // السطر الثاني: المكان والمستهدفين
                              Wrap(
                                spacing: 8,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[700]),
                                      const SizedBox(width: 2),
                                      Text(act['location'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.people_alt_rounded, size: 12, color: Colors.grey[700]),
                                      const SizedBox(width: 2),
                                      Text(act['target'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // السطر الثالث: المشرف
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 12, color: Colors.grey[700]),
                                  const SizedBox(width: 2),
                                  Text('المشرف: ${act['supervisor']}', style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // الحالة والقائمة
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // الحالة
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: act['bg'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                act['status'] as String,
                                style: TextStyle(fontSize: 10, color: act['color'] as Color, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // زر التعديل والحذف
                            PopupMenuButton<String>(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFe2e8f0), width: 1.5),
                              ),
                              icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddActivityModal(context, editActivity: act, index: index);
                                } else if (value == 'delete') {
                                  setState(() {
                                    activities.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم حذف النشاط بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
                                      backgroundColor: Color(0xFFea580c),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, color: Color(0xFFea580c), size: 18),
                                      SizedBox(width: 8),
                                      Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddActivityModal(BuildContext context, {Map<String, dynamic>? editActivity, int? index}) {
    final titleController = TextEditingController(text: editActivity != null ? editActivity['title'] as String : '');
    final locationController = TextEditingController(text: editActivity != null ? editActivity['location'] as String : '');
    final supervisorController = TextEditingController(text: editActivity != null ? editActivity['supervisor'] as String : '');
    final dateController = TextEditingController(text: editActivity != null ? editActivity['date'] as String : '');
    String selectedType = editActivity != null ? editActivity['type'] as String : 'نشاط';
    String selectedTarget = 'all';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateModal) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFf8fafc),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              const ActivitiesCardDustAnimation(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(editActivity != null ? 'تعديل النشاط' : 'إضافة نشاط جديد',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0f172a))),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748b)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      const Text('عنوان النشاط أو الرحلة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'مثال: رحلة إلى حديقة الحيوان',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('النوع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: const [
                          DropdownMenuItem(value: 'نشاط', child: Text('نشاط داخلي')),
                          DropdownMenuItem(value: 'رحلة', child: Text('رحلة خارجية')),
                        ],
                        onChanged: (v) {
                          setStateModal(() {
                            selectedType = v!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('المكان', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: 'مثال: قاعة الأنشطة الكبرى',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('الفئة المستهدفة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedTarget,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('لكل المقيمين')),
                          DropdownMenuItem(value: 'special', child: Text('قسم الرعاية الخاصة')),
                          DropdownMenuItem(value: 'culture', child: Text('المجموعة الثقافية')),
                        ],
                        onChanged: (v) {
                          setStateModal(() {
                            selectedTarget = v!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('المشرف المسؤول', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: supervisorController,
                        decoration: InputDecoration(
                          hintText: 'مثال: أ. سارة المنسق',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('صورة النشاط (اختياري)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم اختيار الصورة بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
                                  backgroundColor: Color(0xFF10b981),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFe2e8f0)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_search_rounded, color: Color(0xFFea580c), size: 20),
                              SizedBox(width: 8),
                              Text('اختر صورة للنشاط', style: TextStyle(color: Color(0xFFea580c), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('التاريخ والوقت', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFea580c),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xFF0f172a),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            if (context.mounted) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.input,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFea580c),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF0f172a),
                                      ),
                                      timePickerTheme: const TimePickerThemeData(
                                        backgroundColor: Colors.white,
                                        dialHandColor: Color(0xFFea580c),
                                        dialBackgroundColor: Color(0xFFfff7ed),
                                        entryModeIconColor: Color(0xFFea580c),
                                        hourMinuteColor: Color(0xFFfff7ed),
                                        hourMinuteTextColor: Color(0xFFea580c),
                                        dayPeriodColor: Color(0xFFfff7ed),
                                        dayPeriodTextColor: Color(0xFFea580c),
                                        dayPeriodBorderSide: BorderSide(color: Color(0xFFea580c)),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                final formattedDate = "${pickedDate.year}/${pickedDate.month}/${pickedDate.day} - ${pickedTime.format(context)}";
                                setStateModal(() {
                                  dateController.text = formattedDate;
                                });
                              }
                            }
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'اختر التاريخ والوقت',
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFFea580c)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            final newActivity = {
                              'title': titleController.text,
                              'type': selectedType,
                              'date': dateController.text.isNotEmpty ? dateController.text : 'غير محدد',
                              'status': 'قادم',
                              'icon': selectedType == 'رحلة' ? '🌳' : '🎨',
                              'color': selectedType == 'رحلة' ? const Color(0xFF10b981) : const Color(0xFF3b82f6),
                              'bg': selectedType == 'رحلة' ? const Color(0xFFd1fae5) : const Color(0xFFdbeafe),
                              'target': 'لكل المقيمين',
                              'location': locationController.text,
                              'supervisor': supervisorController.text,
                            };
                            
                            setState(() {
                              if (editActivity != null && index != null) {
                                activities[index] = newActivity;
                              } else {
                                activities.insert(0, newActivity);
                                
                                // إضافة النشاط للمسن أيضاً عبر الـ Provider ليظهر عنده
                                ref.read(appRiverpod).addActivity(Activity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: titleController.text,
                                  emoji: selectedType == 'رحلة' ? '🌳' : '🎨',
                                  location: locationController.text,
                                  time: dateController.text.isNotEmpty ? dateController.text : '١٠:٠٠ ص',
                                  status: 'coming',
                                  badges: selectedType == 'رحلة' ? 'ترفيه' : 'نشاط',
                                  pointsReward: 30,
                                  dayTag: 'اليوم', // جعله يظهر في قائمة اليوم للمسن
                                ));
                              }
                            });
                            
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(editActivity != null ? 'تم تحديث النشاط بنجاح!' : 'تم حفظ النشاط بنجاح!', style: const TextStyle(fontFamily: 'Cairo')),
                                backgroundColor: const Color(0xFF10b981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFea580c),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(editActivity != null ? 'تحديث النشاط' : 'حفظ النشاط', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كلاسات الأنيميشن الخاصة بغبار النجوم
class _ActivitiesCardDustParticle {
  Offset position;
  double speed;
  double radius;
  _ActivitiesCardDustParticle({required this.position, required this.speed, required this.radius});
}

class ActivitiesCardDustAnimation extends StatefulWidget {
  const ActivitiesCardDustAnimation({super.key});

  @override
  State<ActivitiesCardDustAnimation> createState() => _ActivitiesCardDustAnimationState();
}

class _ActivitiesCardDustAnimationState extends State<ActivitiesCardDustAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ActivitiesCardDustParticle> _dust;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    
    final random = Random();
    _dust = List.generate(100, (index) {
      return _ActivitiesCardDustParticle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        speed: random.nextDouble() * 0.05 + 0.02,
        radius: random.nextDouble() * 1.5 + 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ActivitiesCardDustPainter(dust: _dust, animationValue: _controller.value),
          );
        },
      ),
    );
  }
}

class ActivitiesCardDustPainter extends CustomPainter {
  final List<_ActivitiesCardDustParticle> dust;
  final double animationValue;

  ActivitiesCardDustPainter({required this.dust, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFea580c).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < dust.length; i++) {
      final p = dust[i];
      
      // حركة للأعلى
      double dy = (p.position.dy * size.height) - (animationValue * p.speed * size.height);
      if (dy < 0) dy += size.height;

      double dx = p.position.dx * size.width + sin(animationValue * 2 * pi + i) * 5;

      final currentPos = Offset(dx, dy);

      double opacity = (sin(animationValue * 2 * pi * 2 + i) + 1) / 2;
      paint.color = const Color(0xFFea580c).withValues(alpha: opacity * 0.4);

      canvas.drawCircle(currentPos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ActivitiesCardDustPainter oldDelegate) {
    return true;
  }
}

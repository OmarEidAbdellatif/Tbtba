import 'dart:async'; // مكتبة التوقيت والعمليات غير المتزامنة
import 'package:flutter/material.dart'; // مكتبة فلاتر للواجهات
import 'nurse_reports_screen.dart'; // شاشة التقارير الخاصة بالتمريض
import 'nurse_residents_screen.dart'; // شاشة قائمة المقيمين
import 'nurse_resident_detail_screen.dart'; // شاشة تفاصيل المقيم
import 'nurse_profile_screen.dart'; // شاشة الملف الشخصي للممرض
import 'shift_handoff_screen.dart'; // شاشة تسليم واستلام الوردية
import 'views/medical_admin_view.dart'; // واجهة الإدارة الطبية
import 'views/operations_view.dart'; // واجهة العمليات اليومية
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import 'package:url_launcher/url_launcher.dart'; // مكتبة لفتح الروابط والاتصال
import 'package:permission_handler/permission_handler.dart'; // مكتبة إدارة الصلاحيات
import '../../providers/app_riverpod.dart'; // مزود الحالة الرئيسي
import '../../models/app_models.dart'; // نماذج البيانات الخاصة بالتطبيق
import '../../widgets/taptaba_drawer.dart'; // القائمة الجانبية الموحدة
import '../../widgets/taptaba_scaffold.dart'; // الهيكل الموحد للتطبيق

class NurseDashboardScreen extends ConsumerStatefulWidget { // شاشة لوحة تحكم الممرض
  const NurseDashboardScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<NurseDashboardScreen> createState() => _NurseDashboardScreenState(); // إنشاء حالة المكون
}

class _NurseDashboardScreenState extends ConsumerState<NurseDashboardScreen>
    with TickerProviderStateMixin { // حالة الشاشة مع دعم الأنيميشن والتوقيت
  int _currentTabIndex = 0; // الفهرس الحالي للتبويبات
  Timer? _timer; // مؤقت لحساب وقت الوردية

  late AnimationController _pulseController; // متحكم أنيميشن النبض للتنبيهات
  late AnimationController _spinController; // متحكم أنيميشن الدوران

  final TextEditingController _bpController = TextEditingController(text: '١٢٠/٨٠'); // متحكم ضغط الدم
  final TextEditingController _sugarController = TextEditingController(text: '٩٥'); // متحكم مستوى السكر

  String _selectedFilter = 'الكل'; // الفلتر المختار لعرض المقيمين

  void _startShiftTimer() { // دالة لبدء مؤقت تنازلي لنهاية الوردية
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // تحديث كل ثانية
      if (!mounted) return; // التأكد من أن الشاشة ما زالت مفتوحة
      final now = DateTime.now(); // الوقت الحالي
      DateTime shiftEnd; // موعد نهاية الوردية
      
      // منطق تحديد نهاية الوردية بناءً على الوقت الحالي (صباحية، مسائية، ليلية)
      if (now.hour >= 6 && now.hour < 14) {
        shiftEnd = DateTime(now.year, now.month, now.day, 14, 0, 0); // تنتهي 2 ظهراً
      } else if (now.hour >= 14 && now.hour < 22) {
        shiftEnd = DateTime(now.year, now.month, now.day, 22, 0, 0); // تنتهي 10 مساءً
      } else {
        if (now.hour >= 22) {
          shiftEnd = DateTime(now.year, now.month, now.day + 1, 6, 0, 0); // تنتهي 6 صباح غد
        } else {
          shiftEnd = DateTime(now.year, now.month, now.day, 6, 0, 0); // تنتهي 6 صباح اليوم
        }
      }

      final diff = shiftEnd.difference(now); // حساب الفرق الزمني
      if (diff.isNegative) { // إذا انتهى الوقت
        _timerHours = 0;
        _timerMins = 0;
        _timerSecs = 0;
      } else {
        setState(() { // تحديث عرض الوقت في الواجهة
          _timerHours = diff.inHours; // الساعات المتبقية
          _timerMins = diff.inMinutes % 60; // الدقائق المتبقية
          _timerSecs = diff.inSeconds % 60; // الثواني المتبقية
        });
      }
    });
  }

  int _timerHours = 0; // متغير تخزين الساعات المتبقية
  int _timerMins = 0; // متغير تخزين الدقائق المتبقية
  int _timerSecs = 0; // متغير تخزين الثواني المتبقية

  @override
  void initState() { // دالة التهيئة الأولية
    super.initState(); // استدعاء التهيئة الأصلية
    _pulseController = AnimationController( // إعداد أنيميشن النبض
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true); // تكرار الحركة ذهاباً وإياباً

    _spinController = AnimationController( // إعداد أنيميشن الدوران
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat(); // تكرار الدوران باستمرار

    _startShiftTimer(); // بدء تشغيل مؤقت الوردية
  }

  @override
  void dispose() { // تنظيف الموارد عند إغلاق الشاشة
    _timer?.cancel(); // إيقاف المؤقت
    _pulseController.dispose(); // إغلاق متحكم النبض
    _spinController.dispose(); // إغلاق متحكم الدوران
    _bpController.dispose(); // إغلاق متحكم ضغط الدم
    _sugarController.dispose(); // إغلاق متحكم السكر
    super.dispose(); // استدعاء التنظيف الأصلي
  }

  @override
  Widget build(BuildContext context) { // بناء واجهة الشاشة الرئيسية للممرض
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق

    return TaptabaScaffold( // استخدام الهيكل الموحد
      title: 'طبطبـة', // عنوان الصفحة
      titleColor: const Color(0xFF0369A1), // لون العنوان الأزرق الطبي
      overrideRole: 'ممرض', // تحديد دور المستخدم كممرض
      bottomNavigationBar: _buildBottomNav(), // بناء شريط التنقل السفلي
      floatingActionButton: _buildEmergencyFAB(), // بناء زر الطوارئ العائم
      body: IndexedStack( // عرض المحتوى بناءً على التبويب المختار
        index: _currentTabIndex, // التبويب الحالي
        children: [
          _buildHomeView(provider), // واجهة الرئيسية (نظرة عامة)
          const NurseResidentsScreen(), // واجهة قائمة المقيمين
          const OperationsView(), // واجهة العمليات والرعاية
          const MedicalAdminView(), // واجهة الإدارة الطبية
          const NurseReportsScreen(), // واجهة التقارير والتحليلات
        ],
      ),
    );
  }

  Widget _buildHomeView(AppRiverpod provider) { // بناء واجهة "الرئيسية" للممرض
    return SingleChildScrollView( // السماح بالتمرير الرأسي
      physics: const BouncingScrollPhysics(), // تأثير الارتداد عند التمرير
      child: Column( // ترتيب العناصر رأسياً
        children: [
          _buildHero(), // بناء الجزء العلوي (الهوية والوردية)
          _buildOperationalAlerts(provider), // بناء تنبيهات المخزون والمهام
          _buildShiftHandoffCard(provider), // بناء بطاقة تسليم الوردية
          _buildKPIs(), // بناء مؤشرات الأداء الرئيسية
          _buildTabs(), // بناء فلاتر فرز المقيمين
          _buildResidentsSection(provider), // بناء قائمة المقيمين ذات الأولوية
          _buildMedScheduleSection(), // بناء جدول مواعيد الأدوية
          const SizedBox(height: 100), // مسافة فارغة في الأسفل
        ],
      ),
    );
  }

  Widget _buildOperationalAlerts(AppRiverpod provider) { // بناء تنبيهات العمليات (نقص مخزون أو مهام معلقة)
    final lowStockItems = provider.inventoryItems.where((i) => i.isLowStock).toList(); // جرد الأصناف الناقصة
    final pendingTasks = provider.careTasks.where((t) => !t.isCompleted).toList(); // جرد المهام غير المكتملة

    if (lowStockItems.isEmpty && pendingTasks.isEmpty) return const SizedBox.shrink(); // إخفاء إذا لم يوجد تنبيهات

    return Padding( // هوامش حول التنبيهات
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          if (lowStockItems.isNotEmpty) // تنبيه نقص المخزون
            _alertCard(
              'نقص في المخزون! 📦',
              'يوجد ${lowStockItems.length} أصناف أوشكت على النفاذ',
              const Color(0xFFEF4444),
              () => setState(() => _currentTabIndex = 2), // الانتقال لتبويب العمليات
            ),
          if (pendingTasks.isNotEmpty)
            const SizedBox(height: 8),
          if (pendingTasks.isNotEmpty) // تنبيه المهام المعلقة
            _alertCard(
              'مهام رعاية معلقة ✅',
              'لديك ${pendingTasks.length} مهام متبقية لليوم',
              const Color(0xFFF59E0B),
              () => setState(() => _currentTabIndex = 2), // الانتقال لتبويب العمليات
            ),
        ],
      ),
    );
  }

  Widget _alertCard(String title, String sub, Color color, VoidCallback onTap) { // قالب بطاقة التنبيه
    return GestureDetector( // كاشف للمسات
      onTap: onTap,
      child: Container( // تصميم البطاقة
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF64748B)), // أيقونة الانتقال
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)), // عنوان التنبيه
                  Text(sub, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)), // نص فرعي للتنبيه
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftHandoffCard(AppRiverpod provider) { // بناء بطاقة إدارة تسليم الوردية
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
          boxShadow: [BoxShadow(color: const Color(0xFF0369A1).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container( // أيقونة التسليم
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.sync_alt_rounded, color: Color(0xFF0EA5E9), size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('إدارة تسليم الوردية 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('جاهز للتسليم؟ قم بتجهيز تقريرك الآن', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1), // خط فاصل
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded( // زر عرض السجلات السابقة
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('السجلات السابقة', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded( // زر بدء عملية التسليم الحالية
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShiftHandoffScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0369A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('بدء التسليم الآن', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getShiftName() { // دالة للحصول على اسم الوردية بناءً على الساعة
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) return 'الوردية الصباحية (٦ ص - ٢ ظ)';
    if (hour >= 14 && hour < 22) return 'الوردية المسائية (٢ ظ - ١٠ م)';
    return 'الوردية الليلية (١٠ م - ٦ ص)';
  }

  Widget _buildHero() { // بناء الجزء العلوي الجمالي للشاشة (Hero Section)
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient( // تدرج أزرق طبي
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        ),
      ),
      child: Stack(
        children: [
          // خلفية دائرية تجميلية
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 8,
            child: RotationTransition( // أيقونة دوارة خفيفة للجمالية
              turns: _spinController,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏥 لوحة المشرف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector( // معلومات الممرض والوردية
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NurseProfileScreen())),
                      child: Text(
                        'أ. منى — ${_getShiftName()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container( // شارة التنبيه للحالات العاجلة
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition( // نبض ضوئي للتنبيه
                            opacity: _pulseController,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFCA5A5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '٢ حالة تحتاج تدخل فوري',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text( // مؤقت نهاية الوردية
                      'الوردية تنتهي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${_timerHours}:${_timerMins.toString().padLeft(2, '0')}:${_timerSecs.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs() { // بناء مؤشرات الأداء الرئيسية (KPIs)
    return Padding( // هوامش حول المؤشرات
      padding: const EdgeInsets.all(12),
      child: Row( // ترتيب المؤشرات أفقياً
        children: [
          _buildKPICard('${ref.watch(appRiverpod).totalResidentsCount}', 'إجمالي المقيمين', 'جميعهم نشطون',
              const Color(0xFF0369A1), const Color(0xFF10B981)), // كارت عدد المقيمين
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).criticalResidentsCount}', 'حالات حرجة', 'تحتاج متابعة',
              const Color(0xFFEF4444), const Color(0xFFEF4444)), // كارت الحالات الحرجة
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).medications.where((m) => !m.isTaken).length}', 'جرعات متبقية', 'هذا الصباح',
              const Color(0xFF0369A1), const Color(0xFFF59E0B)), // كارت الجرعات المتبقية
          const SizedBox(width: 8),
          _buildKPICard('${ref.watch(appRiverpod).compliancePercentage}٪', 'الالتزام بالدواء', 'هذا الأسبوع',
              const Color(0xFF0369A1), const Color(0xFF10B981)), // كارت نسبة الالتزام
        ],
      ),
    );
  }

  Widget _buildKPICard(String val, String lbl, String sub, Color valColor,
      Color subColor) { // قالب بطاقة مؤشر الأداء
    return Expanded( // توزيع البطاقات بالتساوي
      child: Container( // تصميم البطاقة
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0F2FE)), // إطار أزرق فاتح جداً
        ),
        child: Column(
          children: [
            Text( // القيمة الرقمية للمؤشر
              val,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valColor,
              ),
            ),
            const SizedBox(height: 4),
            Text( // مسمى المؤشر
              lbl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text( // نص توضيحي إضافي
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: subColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() { // بناء فلاتر فرز المقيمين (التبويبات العلوية)
    final tabs = ['الكل', 'حرجة 🔴', 'تحذير 🟡', 'مستقرة ✅', 'دواء متأخر']; // قائمة الفلاتر
    return SingleChildScrollView( // السماح بالتمرير الأفقي للفلاتر
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: tabs.map((t) {
          final isAct = t == _selectedFilter; // هل الفلتر حالياً هو المختار؟
          return GestureDetector( // كاشف للمسات
            onTap: () => setState(() => _selectedFilter = t), // تحديث الفلتر عند الضغط
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isAct // تدرج لوني للمختار فقط
                    ? const LinearGradient(
                        colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)])
                    : null,
                color: isAct ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isAct ? Colors.transparent : const Color(0xFFBAE6FD)),
              ),
              child: Text( // اسم الفلتر
                t,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAct ? Colors.white : const Color(0xFF0369A1),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) { // بناء عنوان القسم مع نقطة ملونة
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          Container( // نقطة اللون الجانبية
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 8),
          Text( // نص العنوان
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0369A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalChip(String text, Color bg, Color color) { // بناء شريحة عرض العلامات الحيوية
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResidentsSection(AppRiverpod provider) { // بناء قسم قائمة المقيمين
    String getLatestNote(String name) { // دالة للحصول على آخر ملاحظة لمقيم معين
      final cleanName = name.split(' — ')[0];
      final notes = provider.getNotesForResident(cleanName);
      return notes.isNotEmpty ? '${notes.first.title}: ${notes.first.content}' : '';
    }

    // تعريف قائمة ثابتة للمقيمين (لغرض العرض)
    List<Widget> residents = [
      _buildResCard( // كارت الحاج محمود (حالة حرجة)
        name: 'الحاج محمود سالم — غرفة ١٠٣',
        room: '٧٨ سنة · متابعة دورية',
        av: 'مح',
        avBg: const Color(0xFFFFE4E6),
        avColor: const Color(0xFF9F1239),
        statusColor: const Color(0xFFEF4444),
        borderColor: const Color(0xFFFCA5A5),
        bg: const Color(0xFFFFF5F5),
        btnText: 'تدخّل',
        btnColor: const Color(0xFFEF4444),
        warnText: '⏰ ميتفورمين — فات موعده منذ ٣٠ د',
        category: 'حرجة 🔴',
        note: getLatestNote('الحاج محمود سالم'),
      ),
      _buildResCard( // كارت الحاجة فاطمة (حالة تحذير)
        name: 'الحاجة فاطمة علي — غرفة ١٠٧',
        room: '٧٢ سنة · أمراض قلب',
        av: 'فا',
        avBg: const Color(0xFFFEF3C7),
        avColor: const Color(0xFF92400E),
        statusColor: const Color(0xFFF59E0B),
        borderColor: const Color(0xFFFDE68A),
        bg: Colors.white,
        btnText: 'تأكيد',
        btnColor: const Color(0xFF0EA5E9),
        warnText: '⏰ أملوديبين — باقي ١٥ دقيقة',
        category: 'تحذير 🟡',
        note: getLatestNote('الحاجة فاطمة علي'),
      ),
      _buildResCard( // كارت الحاج أحمد (حالة مستقرة)
        name: 'الحاج أحمد كمال — غرفة ١١٢',
        room: '٦٩ سنة · مستقر',
        av: 'أح',
        avBg: const Color(0xFFD1FAE5),
        avColor: const Color(0xFF065F46),
        statusColor: const Color(0xFF10B981),
        borderColor: const Color(0xFFE0F2FE),
        bg: Colors.white,
        btnText: 'تفاصيل',
        btnColor: const Color(0xFF10B981),
        warnText: '✓ جميع أدويته مكتملة اليوم',
        isStable: true,
        category: 'مستقرة ✅',
        note: getLatestNote('الحاج أحمد كمال'),
      ),
    ];

    // تصفية القائمة بناءً على الفلتر المختار
    List<Widget> filtered = residents.where((r) {
      if (_selectedFilter == 'الكل') return true;
      if (r is! Container) return true; // تأمين ضد أنواع أخرى
      if (_selectedFilter == 'حرجة 🔴') return residents.indexOf(r) == 0;
      if (_selectedFilter == 'تحذير 🟡') return residents.indexOf(r) == 1;
      if (_selectedFilter == 'مستقرة ✅') return residents.indexOf(r) == 2;
      return false;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('المقيمون — حسب الأولوية', const Color(0xFFEF4444)),
        ...filtered, // عرض العناصر المصفاة
      ],
    );
  }

  Widget _buildResCard({ // قالب بطاقة المقيم المتقدمة
    required String name,
    required String room,
    required String av,
    required Color avBg,
    required Color avColor,
    required Color statusColor,
    required Color borderColor,
    required Color bg,
    required String btnText,
    required Color btnColor,
    required String warnText,
    required String category,
    bool isStable = false,
    String? note,
  }) {
    return Container( // وعاء البطاقة الأساسي
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack( // عرض الأفاتار مع نقطة الحالة (أونلاين/طوارئ)
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: avBg,
                          child: Text(
                            av,
                            style: TextStyle(
                                color: avColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, // اسم المقيم والغرفة
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(room, // العمر والحالة العامة
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Text( // نص التنبيه الزمني
                            warnText,
                            style: TextStyle(
                                fontSize: 11,
                                color: isStable
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0369A1)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[ // عرض الملاحظة الأخيرة إن وجدت
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_note_rounded,
                            color: Color(0xFF0EA5E9), size: 16),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row( // أزرار الإجراءات السريعة (طوارئ، ملف، ملاحظة)
                  children: [
                    Expanded( // زر الطوارئ العاجل للمقيم
                      child: _actionBtn('🚑 طوارئ',
                          color: const Color(0xFF7F1D1D),
                          bg: const Color(0xFFFEE2E2),
                          onTap: () => _showEmergencyAlert(name)),
                    ),
                    const SizedBox(width: 8),
                    Expanded( // زر فتح ملف المقيم الكامل
                      child: _actionBtn('📋 الملف',
                          color: Colors.white,
                          isPrimary: true,
                          bg: const Color(0xFF0369A1),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NurseResidentDetailScreen(
                            residentName: name.split(' — ')[0],
                            roomNumber: room.replaceAll('غرفة ', '').split(' · ')[0],
                          )))),
                    ),
                    const SizedBox(width: 8),
                    Expanded( // زر إضافة ملاحظة تمريضية سريعة
                      child: _actionBtn('💬 ملاحظة',
                          color: const Color(0xFF0369A1),
                          bg: const Color(0xFFF0F9FF),
                          onTap: () => _showNoteDialog(name)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, // دالة مساعدة لبناء أزرار الإجراءات
      {required Color color,
      required Color bg,
      bool isPrimary = false,
      VoidCallback? onTap}) {
    return GestureDetector( // كاشف لمسات مخصص بدلاً من أزرار فلاتر الافتراضية
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0369A1) : bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text( // نص الزر
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputRow(String emoji, String lbl, TextEditingController controller,
      String unit, Color bg, bool hasBtn) { // بناء صف إدخال بيانات (مثل الضغط أو السكر)
    return Row(
      children: [
        Container( // أيقونة تعبيرية للبيان
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded( // تسمية البيان (Label)
            child: Text(lbl,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        Container( // حقل الإدخال الرقمي
          width: 80,
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox( // وحدة القياس (مثل مجم/ديسيلتر)
          width: 40,
          child: Text(unit,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ),
        const SizedBox(width: 8),
        if (hasBtn) // زر الربط مع أجهزة القياس الخارجية (بلوتوث)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('🔗 جهاز',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        else
          const SizedBox(width: 58)
      ],
    );
  }

  Widget _bar(double h, Color c) { // بناء أعمدة الرسم البياني للإحصائيات
    return Expanded(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: h),
        builder: (context, val, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: val,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedScheduleSection() { // بناء قسم جدول مواعيد الأدوية لليوم
    final provider = ref.watch(appRiverpod);
    final allMeds = provider.medications;
    
    // تجميع الأدوية حسب المقيم لعرضها في صفوف منظمة
    final Map<String, List<Medication>> groupedMeds = {};
    for (var med in allMeds) {
      final name = med.residentName ?? 'غير محدد';
      if (!groupedMeds.containsKey(name)) groupedMeds[name] = [];
      groupedMeds[name]!.add(med);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton( // زر للانتقال لتبويب العمليات لمشاهدة تفاصيل أكثر
                onPressed: () => setState(() => _currentTabIndex = 2),
                child: const Text('عرض الكل 📊', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              _buildSectionHeader('جدول الأدوية — اليوم', const Color(0xFF6366F1)),
            ],
          ),
          Container( // حاوية الجدول الرئيسي
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
            ),
            child: Column(
              children: [
                Container( // ترويسة الجدول (الفترات الزمنية)
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Row(
                    children: [
                      const Expanded(
                          child: Text('الدواء / المقيم',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B)))),
                      _medH('ص'), // صباحاً
                      _medH('ظ'), // ظهراً
                      _medH('م'), // مساءً
                      _medH('ل'), // ليلاً
                    ],
                  ),
                ),
                ...groupedMeds.entries.map((entry) { // إنشاء صف لكل مقيم وأدويته
                  final name = entry.key;
                  final meds = entry.value;
                  final medNames = meds.map((m) => m.name).join(' + ');
                  
                  // منطق تحديد حالة الدواء لكل فترة زمنية في الجدول
                  String d1 = '-', d2 = '-', d3 = '-', d4 = '-';
                  for (var m in meds) {
                    final status = m.isTaken ? '✓' : ((m.isMissed || m.isSkipped) ? '!' : '⏰');
                    if (m.timeOfDay == 'الصباح') d1 = status;
                    if (m.timeOfDay == 'الظهر') d2 = status;
                    if (m.timeOfDay == 'المساء') d3 = status;
                  }

                  return Column(
                    children: [
                      _medRow(name, medNames, d1, d2, d3, d4),
                      const Divider(height: 1, color: Color(0xFFF0F9FF)),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medH(String txt) { // خلية ترويسة الجدول
    return SizedBox(
        width: 40,
        child: Text(txt,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B))));
  }

  Widget _medRow(String n, String s, String d1, String d2, String d3, String d4) { // صف بيانات المقيم في جدول الأدوية
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NurseResidentDetailScreen(residentName: n, roomNumber: n.contains('محمود') ? '١٠٣' : '١١٢'))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(n, // اسم المقيم
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                  Text(s, // أسماء الأدوية
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            _doseCell(d1, n), // خلية الجرعة الصباحية
            _doseCell(d2, n), // خلية الجرعة الظهرية
            _doseCell(d3, n), // خلية الجرعة المسائية
            _doseCell(d4, n), // خلية الجرعة الليلية
          ],
        ),
      ),
    );
  }

  Widget _doseCell(String st, String resident) { // خلية حالة الجرعة (ملونة حسب الحالة)
    Color bg = const Color(0xFFF3F4F6); // لون افتراضي (لا يوجد دواء)
    Color fg = const Color(0xFF9CA3AF);
    if (st == '✓') { // تم الإعطاء (أخضر)
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (st == '!') { // فاشلة/تجاوزت (أحمر)
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF7F1D1D);
    } else if (st == '⏰') { // بانتظار الموعد (أصفر)
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    return GestureDetector(
      onTap: () { // فتح نافذة التأكيد عند الضغط على الخلية
        final provider = ref.read(appRiverpod);
        final med = provider.medications.firstWhere(
          (m) => m.residentName == resident && 
                ((st == '⏰' && !m.isTaken && !m.isSkipped) || 
                 (st == '✓' && m.isTaken) || 
                 (st == '!' && m.isMissed)),
          orElse: () => provider.medications.firstWhere((m) => m.residentName == resident),
        );

        _showDoseConfirmation(med);
      },
      child: SizedBox(
        width: 40,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: Center(
              child: Text(st,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
            ),
          ),
        ),
      ),
    );
  }

  void _showDoseConfirmation(Medication med) { // نافذة تأكيد إعطاء الجرعة الدوائية
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('تأكيد جرعة الدواء 💊', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
            const SizedBox(height: 8),
            Text('المقيم: ${med.residentName}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            Text('${med.name} — ${med.dosage}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded( // زر التأكيد النهائي
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(appRiverpod).takeMedication(med.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل إعطاء الدواء بنجاح ✅')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('تم الإعطاء ✅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded( // زر لتسجيل سبب عدم الإعطاء
                  child: OutlinedButton(
                    onPressed: () => _showSkipReasonDialog(med),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('تجاوز الجرعة ❌', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSkipReasonDialog(Medication med) { // نافذة اختيار سبب تجاوز الجرعة
    final reasons = ['رفض المريض', 'غير متاح', 'نائم', 'حالة صحية لا تسمح', 'صائم'];
    Navigator.pop(context); // إغلاق النافذة السابقة
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سبب تجاوز الجرعة', textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r, textAlign: TextAlign.right),
            onTap: () {
              ref.read(appRiverpod).skipMedication(med.id, r);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تسجيل تجاوز الجرعة: $r ⚠️')));
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showNoteDialog(String residentName) { // نافذة إضافة ملاحظة تمريضية جديدة
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text('إضافة ملاحظة تمريضية', textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
            Text('المقيم: $residentName', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField( // حقل العنوان
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'عنوان الملاحظة (مثال: وجبة الغداء)',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 12),
            TextField( // حقل التفاصيل (متعدد الأسطر)
              controller: contentController,
              maxLines: 4,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل الملاحظة هنا...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('بواسطة: أ. منى (مشرف)', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton( // زر الحفظ النهائي للملاحظة
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                final newNote = NursingNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  residentName: residentName,
                  title: titleController.text,
                  content: contentController.text,
                  author: 'أ. منى (مشرف)',
                  timestamp: DateTime.now(),
                );
                ref.read(appRiverpod).addNursingNote(newNote);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الملاحظة بنجاح ✅')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('حفظ الملاحظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyAlert(String residentName) { // نافذة تأكيد إرسال استغاثة طارئة لمقيم محدد
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF7F1D1D),
        title: const Text('🚨 تأكيد استغاثة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من تفعيل حالة الطوارئ لـ $residentName؟ سيتم تنبيه الفريق الطبي فوراً.', 
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.white70))),
          ElevatedButton( // زر التأكيد (يؤدي لإرسال إشارات التنبيه)
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('تم إرسال إشارة الطوارئ! 🚑')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('تأكيد الطوارئ', style: TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() { // بناء شريط التنقل السفلي المخصص للممرض
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE0F2FE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard_rounded, 'الرئيسية', _currentTabIndex == 0, onTap: () => setState(() => _currentTabIndex = 0)),
          _navItem(Icons.people_alt_rounded, 'المقيمين', _currentTabIndex == 1, onTap: () => setState(() => _currentTabIndex = 1)),
          _navItem(Icons.business_center_rounded, 'العمليات', _currentTabIndex == 2, onTap: () => setState(() => _currentTabIndex = 2)),
          _navItem(Icons.medical_services_rounded, 'الإدارة الطبية', _currentTabIndex == 3, onTap: () => setState(() => _currentTabIndex = 3)),
          _navItem(Icons.receipt_long_rounded, 'التقارير', _currentTabIndex == 4, onTap: () => setState(() => _currentTabIndex = 4)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) { // بناء عنصر واحد في شريط التنقل
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF0EA5E9) : (isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? const Color(0xFF0EA5E9) : (isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
          ),
          if (active) ...[ // إظهار نقطة تحت العنصر النشط
            const SizedBox(height: 2),
            Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFF0EA5E9)))
          ]
        ],
      ),
    );
  }

  Widget _buildEmergencyFAB() { // بناء زر الطوارئ العام (SOS) العائم
    return FloatingActionButton.extended(
      onPressed: _showEmergencyDialog,
      backgroundColor: const Color(0xFFEF4444),
      elevation: 8,
      icon: const Icon(Icons.emergency_rounded, color: Colors.white),
      label: const Text('طوارئ SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  void _showEmergencyDialog() { // نافذة اختيار نوع حالة الطوارئ العامة
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('إجراء طوارئ فوري 🚨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            const SizedBox(height: 8),
            Text('برجاء اختيار نوع الطوارئ لتنبيه الطاقم المعني', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
            const SizedBox(height: 24),
            Row( // شبكة خيارات الطوارئ (إسعاف، طبيب، كود بلو، إدارة)
              children: [
                Expanded(child: _emergencyAction('طلب إسعاف', Icons.airport_shuttle_rounded, const Color(0xFFEF4444), () => _triggerEmergency('سيارة إسعاف'))),
                const SizedBox(width: 12),
                Expanded(child: _emergencyAction('الطبيب المناوب', Icons.local_hospital_rounded, const Color(0xFFF59E0B), () => _triggerEmergency('الطبيب المناوب'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _emergencyAction('كود بلو (قلبي)', Icons.favorite_rounded, const Color(0xFFB91C1C), () => _triggerEmergency('Code Blue'))),
                const SizedBox(width: 12),
                Expanded(child: _emergencyAction('تنبيه الإدارة', Icons.notifications_active_rounded, const Color(0xFF6366F1), () => _triggerEmergency('الإدارة'))),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _emergencyAction(String label, IconData icon, Color color, VoidCallback onTap) { // بناء زر واحد لنوع الطوارئ
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerEmergency(String type) async { // معالجة تفعيل حالة الطوارئ (الاتصال بالإسعاف أو تنبيه الطاقم)
    Navigator.pop(context); // إغلاق النافذة
    
    if (type == 'سيارة إسعاف') { // محاولة الاتصال برقم الإسعاف (128)
      final status = await Permission.phone.request();
      if (!mounted) return;

      if (status.isGranted) {
        final Uri telUri = Uri.parse('tel:128');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يجب منح إذن الاتصال لطلب الإسعاف 📞'),
          backgroundColor: Color(0xFFF59E0B),
        ));
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar( // إشعار نجاح إرسال التنبيه
      content: Text('تم إرسال تنبيه $type لجميع الطاقم المعني 🚨'),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

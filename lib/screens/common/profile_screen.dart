import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة
import '../../providers/app_riverpod.dart'; // مزود الحالة الرئيسي للتطبيق
import '../../models/app_models.dart'; // نماذج البيانات المستخدمة
import '../../widgets/taptaba_scaffold.dart'; // الهيكل الموحد للشاشة

class ProfileScreen extends ConsumerWidget { // شاشة الملف الشخصي العامة (لكل الأدوار)
  const ProfileScreen({super.key}); // مشيد الفئة

  @override
  Widget build(BuildContext context, WidgetRef ref) { // دالة بناء الواجهة
    final provider = ref.watch(appRiverpod); // مراقبة حالة التطبيق
    final user = provider.currentUser; // جلب بيانات المستخدم الحالي
    final role = provider.currentRole; // جلب الدور الوظيفي الحالي
    final themeColor = _getRoleColor(role); // تحديد اللون الرئيسي بناءً على الدور

    return TaptabaScaffold( // استخدام الهيكل الموحد
      title: 'الملف الشخصي', // عنوان الشاشة
      titleColor: themeColor, // تلوين العنوان بلون الدور
      body: SingleChildScrollView( // جعل المحتوى قابلاً للتمرير
        physics: const BouncingScrollPhysics(), // تأثير الارتداد عند التمرير
        child: Column( // ترتيب العناصر رأسياً
          children: [
            _buildHeroHeader(context, ref, user, role, themeColor), // بناء الجزء العلوي (الصورة والاسم)
            Padding(
              padding: const EdgeInsets.all(20.0), // هوامش داخلية
              child: Column(
                children: [
                  _buildStatsSection(role, provider, themeColor), // قسم الإحصائيات (نقاط، ساعات، إلخ)
                  const SizedBox(height: 30), // مسافة فاصلة
                  _buildInformationSection(user, role, themeColor), // قسم المعلومات الشخصية (إيميل، هاتف)
                  const SizedBox(height: 30), // مسافة فاصلة
                  _buildActionsSection(themeColor), // قسم الروابط والإعدادات
                  const SizedBox(height: 50), // مسافة في النهاية
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) { // دالة لتحديد اللون المميز لكل دور وظيفي
    switch (role) {
      case 'ممرض': return const Color(0xFF0369A1); // أزرق طبي
      case 'متطوع': return const Color(0xFF059669); // أخضر متطوع
      case 'عائلة': return const Color(0xFFea580c); // برتقالي عائلة
      case 'أخصائي': return const Color(0xFFc026d3); // أرجواني أخصائي
      case 'مدير': return const Color(0xFF1e293b); // كحلي مدير
      case 'مسن':
      default: return const Color(0xFF6C63FF); // موف مسن (خبير سعادة)
    }
  }

  Widget _buildHeroHeader(BuildContext context, WidgetRef ref, User user, String role, Color themeColor) { // بناء الهيدر الفاخر بتدرج لوني
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient( // تدرج لوني يعتمد على لون الدور
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only( // حواف دائرية سفلية
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          Row( // شريط التحكم العلوي داخل الهيدر
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton( // زر العودة
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              ),
              IconButton( // زر تسجيل الخروج السريع
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack( // عرض الصورة الشخصية مع زر التعديل
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=elderly'), // صورة افتراضية
                ),
              ),
              Positioned( // زر القلم لتعديل الصورة
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)), // اسم المستخدم
          const SizedBox(height: 8),
          Container( // شارة توضح الدور الوظيفي
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role == 'مسن' ? 'خبير سعادة' : role,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String role, AppRiverpod provider, Color themeColor) { // بناء قسم الإحصائيات المتغير حسب الدور
    List<Map<String, dynamic>> stats = [];
    
    if (role == 'مسن') { // إحصائيات المسن
      stats = [
        {'label': 'النقاط', 'value': '${provider.currentUser.points}', 'icon': Icons.stars_rounded},
        {'label': 'الأنشطة', 'value': '${provider.currentUser.completedActivities}', 'icon': Icons.check_circle_rounded},
        {'label': 'الأيام', 'value': '${provider.currentUser.streakDays}', 'icon': Icons.calendar_today_rounded},
      ];
    } else if (role == 'متطوع') { // إحصائيات المتطوع
      stats = [
        {'label': 'الساعات', 'value': '${provider.volunteerHours}', 'icon': Icons.timer_rounded},
        {'label': 'المهام', 'value': '${provider.volunteerBookings.length}', 'icon': Icons.assignment_turned_in_rounded},
        {'label': 'التقييم', 'value': '${provider.averageRating}', 'icon': Icons.star_rounded},
      ];
    } else { // إحصائيات الأدوار الأخرى
      stats = [
        {'label': 'الحالات', 'value': '${provider.residentFiles.length}', 'icon': Icons.people_rounded},
        {'label': 'التقارير', 'value': '١٥٦', 'icon': Icons.description_rounded},
        {'label': 'المركز', 'value': 'طبطبة', 'icon': Icons.business_rounded},
      ];
    }

    return Row( // عرض الكروت بجانب بعضها
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((s) => _buildStatCard(s, themeColor)).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, Color themeColor) { // بناء كارت إحصائي واحد
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(stat['icon'], color: themeColor, size: 28), // الأيقونة بلون الدور
          const SizedBox(height: 8),
          Text(stat['value'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), // القيمة
          Text(stat['label'], style: const TextStyle(fontSize: 10, color: Colors.grey)), // العنوان التوضيحي
        ],
      ),
    );
  }

  Widget _buildInformationSection(User user, String role, Color themeColor) { // بناء قسم المعلومات الشخصية الأساسية
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المعلومات الأساسية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        _buildInfoTile(Icons.email_outlined, 'البريد الإلكتروني', 'ahmed.shereef@example.com'), // الإيميل
        _buildInfoTile(Icons.phone_outlined, 'رقم الهاتف', '01234567890'), // الهاتف
        _buildInfoTile(Icons.location_on_outlined, 'العنوان', 'القاهرة، المعادي'), // العنوان
        _buildInfoTile(Icons.cake_outlined, 'تاريخ الميلاد', '١٥ يناير ١٩٥٠'), // الميلاد
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) { // بناء سطر معلومة واحدة
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), // مسمى الحقل
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), // القيمة المسجلة
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(Color themeColor) { // بناء قسم الأفعال والإعدادات
    return Column(
      children: [
        _buildActionTile(Icons.settings_outlined, 'إعدادات الحساب'), // الإعدادات
        _buildActionTile(Icons.security_rounded, 'الأمان والخصوصية'), // الأمان
        _buildActionTile(Icons.help_outline_rounded, 'المساعدة والدعم'), // الدعم
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String label) { // بناء عنصر اختيار واحد (ListTile)
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E293B)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14), // سهم التنقل
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.white,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) { // حوار تأكيد تسجيل الخروج
    final hc = ref.read(appRiverpod).isHighContrast;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: hc ? const Color(0xFF252525) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('تأكيد الخروج',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: hc ? Colors.white : Colors.black)),
        content: Text('هل أنت متأكد أنك تريد تسجيل الخروج والعودة لصفحة الدخول؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: hc ? Colors.white70 : Colors.black87)),
        actionsPadding: const EdgeInsets.all(25),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton( // زر الموافقة على الخروج
                  onPressed: () {
                    Navigator.pop(ctx); // إغلاق الحوار
                    Navigator.pop(context); // العودة من شاشة البروفايل
                    ref.read(appRiverpod).logout(); // تنفيذ عملية الخروج من النظام
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFef4444),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('نعم، اخرج',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton( // زر الإلغاء
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: hc ? Colors.white24 : const Color(0xFFcbd5e1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text('إلغاء',
                      style: TextStyle(color: hc ? Colors.white60 : const Color(0xFF64748b), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

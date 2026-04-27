import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية
import 'taptaba_drawer.dart'; // استيراد القائمة الجانبية
import 'taptaba_bell.dart'; // استيراد أيقونة الإشعارات

class TaptabaScaffold extends StatefulWidget { // فئة الهيكل الموحد للتطبيق (Scaffold)
  final Widget body; // محتوى الشاشة الأساسي
  final String title; // عنوان الشاشة
  final Color appBarColor; // لون شريط العنوان
  final Color? titleColor; // لون نص العنوان
  final List<Widget>? actions; // أيقونات جانبية في شريط العنوان
  final Widget? bottomNavigationBar; // شريط التنقل السفلي
  final Widget? floatingActionButton; // الزر العائم
  final String? overrideRole; // تحديد دور المستخدم لتخصيص القائمة
  final bool extendBodyBehindAppBar; // تمديد المحتوى خلف شريط العنوان
  final bool transparentAppBar; // جعل شريط العنوان شفافاً
  final bool hideAppBar; // إخفاء شريط العنوان بالكامل

  const TaptabaScaffold({ // مشيد الفئة مع البارامترات المطلوبة والاختيارية
    super.key,
    required this.body,
    this.title = 'طبطبـة',
    this.appBarColor = Colors.transparent,
    this.titleColor,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.overrideRole,
    this.extendBodyBehindAppBar = false,
    this.transparentAppBar = false,
    this.hideAppBar = false,
  });

  @override
  State<TaptabaScaffold> createState() => _TaptabaScaffoldState(); // إنشاء حالة الهيكل
}

class _TaptabaScaffoldState extends State<TaptabaScaffold>
    with SingleTickerProviderStateMixin { // حالة الهيكل مع دعم متحكم الأنيميشن
  late AnimationController _drawerController; // متحكم أنيميشن القائمة الجانبية
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // مفتاح الوصول للهيكل

  @override
  void initState() { // دالة التهيئة الأولية
    super.initState();
    _drawerController = AnimationController( // إعداد متحكم الأنيميشن
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() { // تنظيف الموارد عند إغلاق الشاشة
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() { // دالة لفتح وإغلاق القائمة الجانبية
    if (_drawerController.isCompleted) {
      _drawerController.reverse(); // إغلاق
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _drawerController.forward(); // فتح
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) { // دالة بناء الواجهة
    return Scaffold( // المكون الأساسي للهيكل في فلاتر
      key: _scaffoldKey, // ربط المفتاح
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar, // ضبط تمديد المحتوى
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // لون خلفية التطبيق
      drawer: TaptabaDrawer(overrideRole: widget.overrideRole), // القائمة الجانبية الموحدة
      appBar: widget.hideAppBar ? null : AppBar( // شريط العنوان (إذا لم يتم إخفاؤه)
        backgroundColor: widget.transparentAppBar ? Colors.transparent : Colors.white, // شفافية الشريط
        elevation: 0, // إخفاء الظل الافتراضي لجمالية Glassmorphism
        centerTitle: true, // توسيط العنوان
        iconTheme: const IconThemeData(color: Color(0xFF64748b)), // لون الأيقونات
        leading: IconButton( // زر فتح القائمة الجانبية (الهامبرغر)
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748b)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(), // فتح القائمة عند الضغط
        ),
        title: Text( // نص العنوان (طبطبـة)
          'طبطبـة',
          style: TextStyle(
            color: widget.titleColor ?? const Color(0xFF6C63FF), // اللون الموف المميز لطبطبة
            fontWeight: FontWeight.w900, // خط عريض جداً
            fontSize: 24, // حجم كبير للعنوان
            letterSpacing: 1.2, // تباعد خفيف بين الحروف
          ),
        ),
        actions: widget.actions ?? // أيقونات الأكشن (أو الجرس الافتراضي)
            [
              const TaptabaBell(), // جرس التنبيهات
              const SizedBox(width: 8), // مسافة جانبية
            ],
      ),
      body: widget.body, // المحتوى الرئيسي للشاشة
      bottomNavigationBar: widget.bottomNavigationBar, // شريط التنقل السفلي إن وجد
      floatingActionButton: widget.floatingActionButton, // الزر العائم إن وجد
    );
  }
}

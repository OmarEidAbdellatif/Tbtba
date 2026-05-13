import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_riverpod.dart';
import 'taptaba_drawer.dart'; // استيراد القائمة الجانبية
import 'taptaba_bell.dart'; // استيراد أيقونة الإشعارات

class TaptabaScaffold extends ConsumerStatefulWidget {
  // فئة الهيكل الموحد للتطبيق (Scaffold)
  final Widget body; // محتوى الشاشة الأساسي
  final String title; // عنوان الشاشة
  final Color appBarColor; // لون شريط العنوان
  final Color? titleColor; // لون نص العنوان
  final List<Widget>? actions; // أيقونات جانبية في شريط العنوان
  final Widget? bottomNavigationBar; // شريط التنقل السفلي
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final String? overrideRole; // تحديد دور المستخدم لتخصيص القائمة
  final bool extendBodyBehindAppBar; // تمديد المحتوى خلف شريط العنوان
  final bool transparentAppBar; // جعل شريط العنوان شفافاً
  final bool hideAppBar; // إخفاء شريط العنوان بالكامل
  final bool useNestedScrollView; // استخدام التمرير المتداخل (للهيدر المتحرك)
  final bool hideAppBarOnScroll; // إخفاء شريط العنوان عند التمرير لأسفل
  final double? appBarHeight; // ارتفاع مخصص لشريط العنوان
  final Widget? sliverHeader; // محتوى إضافي يتحرك مع شريط العنوان (كالـ Hero)

  const TaptabaScaffold({
    // مشيد الفئة مع البارامترات المطلوبة والاختيارية
    super.key,
    required this.body,
    this.title = 'طبطبـة',
    this.appBarColor = Colors.transparent,
    this.titleColor,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.overrideRole,
    this.extendBodyBehindAppBar = false,
    this.transparentAppBar = false,
    this.hideAppBar = false,
    this.useNestedScrollView = true,
    this.hideAppBarOnScroll = true,
    this.appBarHeight,
    this.sliverHeader,
  });

  @override
  ConsumerState<TaptabaScaffold> createState() =>
      _TaptabaScaffoldState(); // إنشاء حالة الهيكل
}

class _TaptabaScaffoldState extends ConsumerState<TaptabaScaffold>
    with SingleTickerProviderStateMixin {
  // حالة الهيكل مع دعم متحكم الأنيميشن
  late AnimationController _drawerController; // متحكم أنيميشن القائمة الجانبية
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // مفتاح الوصول للهيكل

  @override
  void initState() {
    // دالة التهيئة الأولية
    super.initState();
    _drawerController = AnimationController(
      // إعداد متحكم الأنيميشن
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    // تنظيف الموارد عند إغلاق الشاشة
    _drawerController.dispose();
    super.dispose();
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      // إذا hideAppBarOnScroll: يختفي عند النزول ويظهر عند الصعود
      floating: widget.hideAppBarOnScroll,
      snap: widget.hideAppBarOnScroll,
      pinned: !widget.hideAppBarOnScroll,
      backgroundColor:
          widget.transparentAppBar ? Colors.transparent : Colors.white,
      elevation: 0,
      centerTitle: true,
      forceElevated: innerBoxIsScrolled,
      iconTheme: const IconThemeData(color: Color(0xFF64748b)),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748b)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget _buildFixedAppBar() {
    return AppBar(
      backgroundColor:
          widget.transparentAppBar ? Colors.transparent : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFF64748b)),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748b)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: TextStyle(
        color: widget.titleColor ?? const Color(0xFF6C63FF),
        fontWeight: FontWeight.w900,
        fontSize: 24,
        letterSpacing: 1.2,
      ),
    );
  }

  List<Widget> _buildActions() {
    return widget.actions ??
        [
          if ((widget.overrideRole ?? ref.watch(appRiverpod).currentRole) ==
              'مسن')
            IconButton(
              icon: const Text('🏆', style: TextStyle(fontSize: 22)),
              onPressed: () {
                ref.read(appRiverpod).setElderlyTabIndex(4);
              },
            ),
          const TaptabaBell(),
          const SizedBox(width: 8),
        ];
  }

  @override
  Widget build(BuildContext context) {
    // دالة بناء الواجهة
    return Scaffold(
      // المكون الأساسي للهيكل في فلاتر
      key: _scaffoldKey, // ربط المفتاح
      extendBodyBehindAppBar:
          widget.extendBodyBehindAppBar, // ضبط تمديد المحتوى
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // لون خلفية التطبيق
      drawer: TaptabaDrawer(
          overrideRole: widget.overrideRole), // القائمة الجانبية الموحدة
      body: widget.hideAppBar
          ? widget.body
          : (widget.useNestedScrollView
              ? NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      _buildSliverAppBar(innerBoxIsScrolled),
                      if (widget.sliverHeader != null)
                        SliverToBoxAdapter(child: widget.sliverHeader!),
                    ];
                  },
                  body: widget.body,
                )
              : Column(
                  children: [
                    _buildFixedAppBar(),
                    Expanded(child: widget.body),
                  ],
                )),
      bottomNavigationBar:
          widget.bottomNavigationBar, // شريط التنقل السفلي إن وجد
      floatingActionButton: widget.floatingActionButton, // الزر العائم إن وجد
      floatingActionButtonLocation:
          widget.floatingActionButtonLocation, // موقع الزر العائم
    );
  }
}

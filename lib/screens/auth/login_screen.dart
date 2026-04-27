import 'dart:math'; // مكتبة الرياضيات للعمليات الحسابية
import 'package:flutter/material.dart'; // مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة إدارة الحالة ريفربود
import 'dart:ui'; // مكتبة لواجهات المستخدم المتقدمة مثل البلور

import '../../providers/app_riverpod.dart'; // استيراد مزود الحالة الخاص بالتطبيق
import 'signup_screen.dart'; // استيراد شاشة إنشاء الحساب

class LoginScreen extends ConsumerStatefulWidget { // شاشة تسجيل الدخول كمكون تفاعلي مع ريفربود
  const LoginScreen({super.key}); // مشيد الفئة

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); // إنشاء حالة المكون
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin { // حالة الشاشة مع دعم الأنيميشن
  late AnimationController _bgController; // متحكم أنيميشن الخلفية المتحركة
  late AnimationController _fadeController; // متحكم أنيميشن الظهور التدريجي
  late List<Animation<double>> _fadeAnimations; // قائمة حركات الظهور للعناصر
  late TextEditingController _phoneController; // متحكم حقل رقم الهاتف
  late TextEditingController _passwordController; // متحكم حقل كلمة المرور
  String selectedRole = 'مسن'; // الدور المختار افتراضياً

  @override
  void initState() { // دالة تهيئة الحالة عند بدء الشاشة
    super.initState(); // استدعاء دالة التهيئة الأصلية
    _phoneController = TextEditingController(); // تهيئة متحكم الهاتف
    _passwordController = TextEditingController(); // تهيئة متحكم كلمة المرور

    _bgController = AnimationController( // إعداد متحكم الخلفية
      vsync: this, // المزامنة مع الشاشة
      duration: const Duration(seconds: 15), // مدة الحركة 15 ثانية
    )..repeat(); // تكرار الحركة باستمرار

    _fadeController = AnimationController( // إعداد متحكم الظهور التدريجي
      vsync: this, // المزامنة مع الشاشة
      duration: const Duration(seconds: 1), // مدة الظهور ثانية واحدة
    );

    _fadeAnimations = List.generate( // توليد حركات الظهور للعناصر بشكل متتابع
      6, // عدد العناصر التي ستتحرك
      (index) => Tween<double>(begin: 0, end: 1).animate( // الحركة من اختفاء إلى ظهور
        CurvedAnimation( // نوع منحنى الحركة
          parent: _fadeController, // المتحكم الأب
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut), // توقيت كل عنصر
        ),
      ),
    );
    _fadeController.forward(); // البدء في تنفيذ أنيميشن الظهور
  }

  @override
  void dispose() { // دالة تنظيف الموارد عند إغلاق الشاشة
    _bgController.dispose(); // إغلاق متحكم الخلفية
    _fadeController.dispose(); // إغلاق متحكم الظهور
    _phoneController.dispose(); // إغلاق متحكم الهاتف
    _passwordController.dispose(); // إغلاق متحكم كلمة المرور
    super.dispose(); // استدعاء دالة التنظيف الأصلية
  }

  @override
  Widget build(BuildContext context) { // دالة بناء واجهة الشاشة
    final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة الحالي
    return Scaffold( // الهيكل الأساسي للصفحة
      body: Stack( // تكديس العناصر فوق بعضها (الخلفية ثم المحتوى)
        children: [
          // Animated Background - الخلفية المتحركة
          AnimatedBuilder( // باني واجهات يعتمد على الأنيميشن
            animation: _bgController, // ربط الباني بمتحكم الخلفية
            builder: (context, child) { // دالة بناء عناصر الخلفية
              return Stack( // تكديس الطبقات اللونية
                children: [
                  Container( // وعاء الطبقة الأساسية للتدرج اللوني
                    decoration: const BoxDecoration(
                      gradient: LinearGradient( // تدرج لوني خطي
                        begin: Alignment.topLeft, // البداية من أعلى اليسار
                        end: Alignment.bottomRight, // النهاية في أسفل اليمين
                        colors: [
                          Color(0xFFeef2ff), // لون فاتح أول
                          Color(0xFFe0e7ff), // لون فاتح ثانٍ
                          Color(0xFFf3e8ff), // لون مائل للبنفسجي
                        ],
                      ),
                    ),
                  ),
                  Positioned( // تحديد موقع الدائرة الأولى المتحركة
                    top: -100 + sin(_bgController.value * 2 * pi) * 50, // حركة رأسية جيبية
                    left: -50 + cos(_bgController.value * 2 * pi) * 50, // حركة أفقية جيبية
                    child: Container( // وعاء الدائرة الأولى
                      width: size.width * 0.8, // عرض الدائرة 80% من الشاشة
                      height: size.width * 0.8, // ارتفاع الدائرة
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // شكل دائري
                        gradient: RadialGradient( // تدرج لوني دائري
                          colors: [
                            const Color(0xFF818cf8).withOpacity(0.4), // لون الدائرة مع شفافية
                            Colors.transparent, // تلاشي إلى الشفافية
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned( // تحديد موقع الدائرة الثانية المتحركة
                    bottom: -150 + cos(_bgController.value * 2 * pi) * 70, // حركة أسفل الشاشة
                    right: -100 + sin(_bgController.value * 2 * pi) * 70, // حركة يمين الشاشة
                    child: Container( // وعاء الدائرة الثانية
                      width: size.width * 0.9, // عرض أكبر قليلاً
                      height: size.width * 0.9, // ارتفاع الدائرة
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // شكل دائري
                        gradient: RadialGradient( // تدرج لوني دائري
                          colors: [
                            const Color(0xFFc084fc).withOpacity(0.4), // لون بنفسجي مع شفافية
                            Colors.transparent, // تلاشي إلى الشفافية
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Blur Effect - تأثير الضبابية للزجاج
          Positioned.fill( // تغطية كامل الشاشة
            child: BackdropFilter( // فلتر لخلفية العناصر
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // شدة الضبابية 30
              child: Container(color: Colors.white.withOpacity(0.1)), // لون أبيض خفيف جداً
            ),
          ),

          // Content - المحتوى الأساسي
          SafeArea( // التأكد من عدم تداخل المحتوى مع حواف الهاتف (النوتش)
            child: Center( // توسيط المحتوى في الشاشة
              child: SingleChildScrollView( // السماح بالتمرير عند صغر الشاشة
                padding: const EdgeInsets.symmetric(horizontal: 24), // حواف جانبية 24
                child: Column( // ترتيب العناصر رأسياً
                  mainAxisAlignment: MainAxisAlignment.center, // توسيط رأسي
                  crossAxisAlignment: CrossAxisAlignment.stretch, // تمديد العناصر أفقياً
                  children: [
                    FadeTransition( // أنيميشن ظهور الشعار
                      opacity: _fadeAnimations[0], // استخدام أول حركة ظهور
                      child: Column( // عمود للشعار والاسم
                        children: [
                          Container( // وعاء أيقونة التطبيق
                            padding: const EdgeInsets.all(16), // حواف داخلية للأيقونة
                            decoration: BoxDecoration(
                              color: Colors.white, // خلفية بيضاء للأيقونة
                              shape: BoxShape.circle, // شكل دائري
                              boxShadow: [ // ظل خفيف للأيقونة
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.2), // لون الظل
                                  blurRadius: 24, // مدى الظل
                                  offset: const Offset(0, 8), // موقع الظل
                                ),
                              ],
                            ),
                            child: const Icon( // أيقونة الصحة والأمان
                              Icons.health_and_safety,
                              size: 56, // حجم الأيقونة
                              color: Color(0xFF6C63FF), // لون الأيقونة
                            ),
                          ),
                          const SizedBox(height: 24), // مسافة فارغة
                          const Text( // نص اسم التطبيق "طبطبة"
                            'طبطبـة',
                            textAlign: TextAlign.center, // توسيط النص
                            style: TextStyle(
                              fontSize: 36, // حجم خط كبير
                              fontWeight: FontWeight.w900, // خط عريض جداً
                              color: Color(0xFF1e1b4b), // لون داكن
                              letterSpacing: 1.5, // تباعد الحروف
                            ),
                          ),
                          const SizedBox(height: 8), // مسافة فارغة
                          const Text( // نص وصفي للتطبيق
                            'نظام طبطبة للمسنين الذكي',
                            textAlign: TextAlign.center, // توسيط النص
                            style: TextStyle(
                              fontSize: 16, // حجم خط متوسط
                              color: Color(0xFF4f46e5), // لون أزرق مريح
                              fontWeight: FontWeight.w600, // خط شبه عريض
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48), // مسافة قبل الكارت الأساسي

                    // Glassmorphic Card - كارت إدخال البيانات الزجاجي
                    FadeTransition( // أنيميشن ظهور الكارت
                      opacity: _fadeAnimations[1], // ثاني حركة ظهور
                      child: Container( // وعاء محتوى تسجيل الدخول
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7), // أبيض شفاف (تأثير الزجاج)
                          borderRadius: BorderRadius.circular(32), // حواف دائرية كبيرة
                          border: Border.all(color: Colors.white, width: 2), // إطار أبيض ناصع
                          boxShadow: [ // ظل عميق للكارت
                            BoxShadow(
                              color: const Color(0xFF312e81).withOpacity(0.08), // لون ظل نيلي خفيف
                              blurRadius: 32, // مدى تلاشي الظل
                              offset: const Offset(0, 16), // إزاحة الظل للأسفل
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24), // حواف داخلية للكارت
                        child: Column( // عناصر الكارت الداخلية
                          crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين (عربي)
                          children: [
                            const Text( // عنوان تسجيل الدخول
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 24, // حجم خط العنوان
                                fontWeight: FontWeight.bold, // خط عريض
                                color: Color(0xFF1e1b4b), // لون داكن
                              ),
                            ),
                            const SizedBox(height: 24), // مسافة فارغة

                            // Roles Selector - اختيار نوع المستخدم
                            FadeTransition( // أنيميشن ظهور اختيار الأدوار
                              opacity: _fadeAnimations[2], // ثالث حركة ظهور
                              child: Container( // وعاء شريط الاختيارات
                                padding: const EdgeInsets.all(4), // حواف داخلية للشريط
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf1f5f9), // خلفية رمادية فاتحة
                                  borderRadius: BorderRadius.circular(16), // حواف دائرية
                                ),
                                child: Wrap( // ترتيب الأزرار مع الالتفاف تلقائياً
                                  spacing: 4, // مسافة أفقية بين الأزرار
                                  runSpacing: 4, // مسافة رأسية بين الصفوف
                                  alignment: WrapAlignment.center, // توسيط الأزرار
                                  children: ['مسن', 'أسرة', 'ممرض', 'أخصائي اجتماعي', 'متطوع', 'إدارة'].map((role) {
                                    final isSelected = selectedRole == role; // هل هذا الدور هو المختار حالياً؟
                                    return GestureDetector( // كاشف للمسات المستخدم
                                        onTap: () => setState(() => selectedRole = role), // تحديث الدور المختار عند الضغط
                                        child: AnimatedContainer( // وعاء الزر مع تأثيرات حركية
                                          duration: const Duration(milliseconds: 300), // مدة التغيير 0.3 ثانية
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // حواف الزر
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.transparent, // أبيض للمختار وشفاف للبقية
                                            borderRadius: BorderRadius.circular(12), // حواف الزر
                                            boxShadow: isSelected // ظل فقط للزر المختار
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05), // ظل خفيف جداً
                                                      blurRadius: 8, // مدى الظل
                                                      offset: const Offset(0, 2), // موقع الظل
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Text( // اسم الدور (مسن، ممرض، إلخ)
                                            role,
                                            textAlign: TextAlign.center, // توسيط النص
                                            style: TextStyle(
                                              fontSize: 14, // حجم خط النص
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, // عريض للمختار
                                              color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF64748b), // تلوين المختار
                                            ),
                                          ),
                                        ),
                                      );
                                  }).toList(), // تحويل القائمة إلى عناصر واجهة
                                ),
                              ),
                            ),
                            const SizedBox(height: 24), // مسافة قبل حقول الإدخال

                            // Inputs - حقول الإدخال
                            FadeTransition( // أنيميشن ظهور حقل الهاتف
                              opacity: _fadeAnimations[3], // رابع حركة ظهور
                              child: _buildInput( // بناء حقل إدخال مخصص
                                controller: _phoneController, // ربط متحكم الهاتف
                                label: 'رقم الهاتف', // نص تلميحي
                                icon: Icons.phone_android_rounded, // أيقونة الهاتف
                              ),
                            ),
                            const SizedBox(height: 16), // مسافة بين الحقول

                            FadeTransition( // أنيميشن ظهور حقل كلمة المرور
                              opacity: _fadeAnimations[3], // نفس توقيت ظهور الحقل السابق
                              child: _buildInput( // بناء حقل إدخال مخصص
                                controller: _passwordController, // ربط متحكم كلمة المرور
                                label: 'كلمة المرور', // نص تلميحي
                                icon: Icons.lock_outline_rounded, // أيقونة القفل
                                isPassword: true, // تفعيل خاصية إخفاء النص
                              ),
                            ),
                            const SizedBox(height: 32), // مسافة قبل زر الدخول

                            // Login Button - زر تسجيل الدخول
                            FadeTransition( // أنيميشن ظهور زر الدخول
                              opacity: _fadeAnimations[4], // خامس حركة ظهور
                              child: GestureDetector( // كاشف للمسات المستخدم
                                onTap: () { // دالة التنفيذ عند الضغط
                                  ref.read(appRiverpod).login(selectedRole); // تنفيذ عملية الدخول بالدور المختار
                                },
                                child: Container( // وعاء الزر المتدرج
                                  width: double.infinity, // تمديد الزر بكامل العرض
                                  padding: const EdgeInsets.symmetric(vertical: 16), // حواف داخلية رأسية للزر
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient( // تدرج لوني جذاب للزر
                                      colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)], // أرجواني وبنفسجي فاتح
                                    ),
                                    borderRadius: BorderRadius.circular(20), // حواف دائرية للزر
                                    boxShadow: [ // توهج أسفل الزر
                                      BoxShadow(
                                        color: const Color(0xFF6C63FF).withOpacity(0.4), // لون التوهج
                                        blurRadius: 16, // مدى التوهج
                                        offset: const Offset(0, 8), // إزاحة التوهج
                                      ),
                                    ],
                                  ),
                                  child: const Text( // نص "دخول" على الزر
                                    'دخول',
                                    textAlign: TextAlign.center, // توسيط النص
                                    style: TextStyle(
                                      color: Colors.white, // نص أبيض ناصع
                                      fontSize: 18, // خط واضح
                                      fontWeight: FontWeight.bold, // عريض
                                      letterSpacing: 1, // تباعد بسيط
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // مسافة قبل رابط إنشاء الحساب

                            FadeTransition( // أنيميشن ظهور رابط التسجيل
                              opacity: _fadeAnimations[5], // آخر حركة ظهور
                              child: Center( // توسيط الرابط
                                child: GestureDetector( // كاشف للمسات المستخدم
                                  onTap: () { // التنقل لشاشة إنشاء الحساب
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignupScreen(), // فتح شاشة التسجيل
                                      ),
                                    );
                                  },
                                  child: RichText( // نص مركب بستايلات مختلفة
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 14, // حجم الخط
                                        color: Color(0xFF64748b), // لون رمادي للنص العادي
                                        fontFamily: 'Cairo', // استخدام خط كايرو العربي
                                      ),
                                      children: [
                                        TextSpan(text: 'ليس لديك حساب؟ '), // الجزء الأول من النص
                                        TextSpan(
                                          text: 'إنشاء حساب جديد', // الرابط القابل للضغط
                                          style: TextStyle(
                                            color: Color(0xFF6C63FF), // لون مميز للرابط
                                            fontWeight: FontWeight.bold, // خط عريض
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInput({ // دالة مساعدة لبناء حقول الإدخال بشكل موحد
    required TextEditingController controller, // المتحكم بالنص
    required String label, // التلميح داخل الحقل
    required IconData icon, // الأيقونة الجانبية
    bool isPassword = false, // هل هو حقل كلمة مرور؟
  }) {
    return Container( // وعاء الحقل مع التصميم الزجاجي
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // خلفية بيضاء شبه شفافة
        borderRadius: BorderRadius.circular(16), // حواف دائرية متناسقة
        border: Border.all(color: const Color(0xFFe2e8f0), width: 1.5), // إطار رمادي فاتح
      ),
      child: TextField( // مكون إدخال النص الأساسي
        controller: controller, // ربط المتحكم
        obscureText: isPassword, // إخفاء النص إذا كان كلمة مرور
        textAlign: TextAlign.right, // محاذاة النص لليمين (عربي)
        textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
        decoration: InputDecoration( // تصميم مكونات الحقل الداخلية
          hintText: label, // نص التلميح
          hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 15), // ستايل التلميح
          border: InputBorder.none, // إخفاء الإطار الافتراضي لفلاتر
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // حواف داخلية مريحة
          suffixIcon: Icon(icon, color: const Color(0xFF94a3b8), size: 20), // الأيقونة في نهاية الحقل (يساراً)
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../providers/app_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _fadeController;
  late List<Animation<double>> _fadeAnimations;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  String selectedRole = 'مسن';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimations = List.generate(
      8,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.08, 1.0, curve: Curves.easeOut),
        ),
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FadeTransition(
          opacity: _fadeAnimations[0],
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1e1b4b)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFFfdf4ff),
                          Color(0xFFf3e8ff),
                          Color(0xFFe0e7ff),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50 + cos(_bgController.value * 2 * pi) * 60,
                    right: -50 + sin(_bgController.value * 2 * pi) * 60,
                    child: Container(
                      width: size.width * 0.85,
                      height: size.width * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFf472b6).withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100 + sin(_bgController.value * 2 * pi) * 40,
                    left: -100 + cos(_bgController.value * 2 * pi) * 40,
                    child: Container(
                      width: size.width * 0.9,
                      height: size.width * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Blur Effect Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Main Form
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimations[1],
                    child: const Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1e1b4b),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: const Text(
                      'انضم لمنصة طبطبة وابقَ على تواصل مع أحبائك بكل سهولة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Glass Container for Form
                  FadeTransition(
                    opacity: _fadeAnimations[3],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF312e81).withOpacity(0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Roles Selector
                          FadeTransition(
                            opacity: _fadeAnimations[4],
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf1f5f9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                alignment: WrapAlignment.center,
                                children: ['مسن', 'أسرة', 'ممرض', 'أخصائي اجتماعي', 'متطوع', 'إدارة'].map((role) {
                                  final isSelected = selectedRole == role;
                                  return GestureDetector(
                                      onTap: () => setState(() => selectedRole = role),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          role,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? const Color(0xFFec4899) : const Color(0xFF64748b),
                                          ),
                                        ),
                                      ),
                                    );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Inputs
                          FadeTransition(
                            opacity: _fadeAnimations[5],
                            child: _buildInput(
                              controller: _nameController,
                              label: 'الاسم بالكامل',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          FadeTransition(
                            opacity: _fadeAnimations[5],
                            child: _buildInput(
                              controller: _phoneController,
                              label: 'رقم الهاتف',
                              icon: Icons.phone_android_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          FadeTransition(
                            opacity: _fadeAnimations[6],
                            child: _buildInput(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Signup Button
                          FadeTransition(
                            opacity: _fadeAnimations[7],
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                ref.read(appRiverpod).login(selectedRole);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFf472b6), Color(0xFFec4899)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFec4899).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'إنشــاء الحســاب',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FadeTransition(
                            opacity: _fadeAnimations[7],
                            child: Center(
                              child: Text(
                                'بالتسجيل أنت توافق على شروط الاستخدام وسياسة الخصوصية الخاصة بطبطبة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF64748b).withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: Icon(icon, color: const Color(0xFF94a3b8), size: 20),
        ),
      ),
    );
  }
}

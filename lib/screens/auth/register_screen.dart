import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../providers/app_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'أسرة';
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1e1b4b)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Lottie Animation Area
                Center(
                  child: SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/Welcome.json', // Suggestion: Use a specific registration animation here
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'إنشاء حساب جديد ✨',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e1b4b),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'خاص بالمتطوعين وأفراد الأسرة فقط',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748b),
                  ),
                ),
                const SizedBox(height: 32),

                _buildInput(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 24),

                const Text(
                  'أنا أسجل كـ:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1e1b4b),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _roleOption(
                        'متطوع',
                        _selectedRole == 'متطوع',
                        () => setState(() => _selectedRole = 'متطوع'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _roleOption(
                        'فرد أسرة',
                        _selectedRole == 'أسرة',
                        () => setState(() => _selectedRole = 'أسرة'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(appRiverpod).selfRegister(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            role: _selectedRole,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إنشاء الحساب بنجاح! يمكنك الدخول الآن'),
                          backgroundColor: Color(0xFF10b981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      elevation: 4,
                      shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'إنشاء الحساب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22), // Changed to suffixIcon for right alignment
        ),
      ),
    );
  }

  Widget _roleOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFE2E8F0),
            width: 2.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

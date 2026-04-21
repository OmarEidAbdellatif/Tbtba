import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_riverpod.dart';
import '../screens/common/profile_screen.dart';
import 'accessibility_dialog.dart';

class TaptabaDrawer extends ConsumerWidget {
  final String? overrideRole;
  const TaptabaDrawer({super.key, this.overrideRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);
    final user = provider.currentUser;
    final role = overrideRole ?? provider.currentRole;
    final themeColor = _getRoleColor(role);
    final hc = provider.isHighContrast;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Premium Glassmorphism Background
          if (!hc)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: themeColor
                      .withOpacity(0.05)
                      .withAlpha(240), // Subtle tint
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      bottomLeft: Radius.circular(35)),
                  border: Border(
                    left: BorderSide(
                        color: themeColor.withOpacity(0.3), width: 1.5),
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.2), width: 1.5),
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    bottomLeft: Radius.circular(35)),
              ),
            ),

          Column(
            children: [
              _buildModernHeader(provider, role, themeColor),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: hc ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    children: [
                      _buildPremiumMenuItem(
                        context,
                        Icons.person_outline_rounded,
                        'الحساب الشخصي',
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        themeColor,
                        hc,
                      ),
                      _buildPremiumMenuItem(
                        context,
                        Icons.text_fields_rounded,
                        'إعدادات الرؤية والخط',
                        () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const AccessibilityDialog());
                        },
                        themeColor,
                        hc,
                      ),
                      _buildPremiumMenuItem(
                        context,
                        Icons.support_agent_rounded,
                        'مركز المساعدة',
                        () {},
                        themeColor,
                        hc,
                      ),
                      _buildPremiumMenuItem(
                        context,
                        Icons.info_outline_rounded,
                        'عن طبطبة',
                        () {},
                        themeColor,
                        hc,
                      ),
                      _buildPremiumLogoutBtn(context, ref, hc),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ممرض':
        return const Color(0xFF0369A1); // Sky Blue
      case 'متطوع':
        return const Color(0xFF059669); // Emerald
      case 'عائلة':
      case 'أخصائي':
        return const Color(
            0xFFea580c); // Orange (Unified for Family and Specialist)
      case 'مدير':
        return const Color(0xFF1e293b); // Slate/Dark
      case 'مسن':
      default:
        return const Color(0xFF6C63FF); // Indigo/Purple
    }
  }

  List<Color> _getRoleGradient(String role) {
    switch (role) {
      case 'ممرض':
        return [
          const Color(0xFF0369A1),
          const Color(0xFF0EA5E9),
          const Color(0xFF38BDF8)
        ];
      case 'متطوع':
        return [
          const Color(0xFF064e3b),
          const Color(0xFF059669),
          const Color(0xFF10b981)
        ];
      case 'عائلة':
      case 'أخصائي':
        return [
          const Color(0xFFc2410c),
          const Color(0xFFea580c),
          const Color(0xFFf97316)
        ];
      case 'مدير':
        return [
          const Color(0xFF0f172a),
          const Color(0xFF1e293b),
          const Color(0xFF334155)
        ];
      case 'مسن':
      default:
        return [
          const Color(0xFF1a0533),
          const Color(0xFF3730a3),
          const Color(0xFF6C63FF)
        ];
    }
  }

  String _getRoleNameDisplay(String role) {
    switch (role) {
      case 'ممرض':
        return 'طاقم التمريض';
      case 'متطوع':
        return 'متطوع سعادة';
      case 'عائلة':
        return 'فرد من العائلة';
      case 'أخصائي':
        return 'أخصائي اجتماعي';
      case 'مدير':
        return 'مدير المركز';
      case 'مسن':
      default:
        return 'خبير سعادة';
    }
  }

  Widget _buildModernHeader(
      AppRiverpod provider, String role, Color themeColor) {
    final user = provider.currentUser;
    final gradient = _getRoleGradient(role);

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(45)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: themeColor.withOpacity(0.1),
                  backgroundImage:
                      const NetworkImage('https://i.pravatar.cc/150?u=elderly'),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Text(_getRoleNameDisplay(role),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildRoleQuickStat(role, provider),
        ],
      ),
    );
  }

  Widget _buildRoleQuickStat(String role, AppRiverpod provider) {
    String label = '';
    String value = '';
    IconData icon = Icons.star_rounded;

    if (role == 'مسن') {
      label = 'النقاط الحالية';
      value = '${provider.currentUser.points}';
      icon = Icons.stars_rounded;
    } else if (role == 'متطوع') {
      label = 'ساعات التطوع';
      value = '${provider.volunteerHours} س';
      icon = Icons.timer_rounded;
    } else if (role == 'ممرض') {
      label = 'الوردية الحالية';
      value = 'الصباحية';
      icon = Icons.wb_sunny_rounded;
    } else {
      label = 'إحصائيات متنوعة';
      value = 'متفاعل';
      icon = Icons.analytics_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMenuItem(BuildContext context, IconData icon,
      String label, VoidCallback onTap, Color themeColor, bool hc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hc ? Color(0xFF2D2D2D) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (hc ? Colors.white : themeColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: hc ? Colors.white : themeColor, size: 26),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hc ? Colors.white : const Color(0xFF1e293b))),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: hc ? Colors.white24 : const Color(0xFFcbd5e1)),
      ),
    );
  }

  Widget _buildPremiumLogoutBtn(BuildContext context, WidgetRef ref, bool hc) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: InkWell(
        onTap: () => _showLogoutDialog(context, ref, hc),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: hc ? const Color(0xFF421515) : const Color(0xFFFFFBFA),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 15),
              Text('تسجيل الخروج',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool hc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: hc ? const Color(0xFF252525) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('تأكيد الخروج',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hc ? Colors.white : Colors.black)),
        content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: hc ? Colors.white70 : Colors.black87)),
        actionsPadding: const EdgeInsets.all(25),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(appRiverpod).logout();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFef4444),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('نعم، اخرج',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                          color: hc ? Colors.white24 : const Color(0xFFcbd5e1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text('إلغاء',
                      style: TextStyle(
                          color: hc ? Colors.white60 : const Color(0xFF64748b),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

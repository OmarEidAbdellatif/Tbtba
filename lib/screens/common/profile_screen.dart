import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import '../../widgets/taptaba_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);
    final user = provider.currentUser;
    final role = provider.currentRole;
    final themeColor = _getRoleColor(role);

    return TaptabaScaffold(
      title: 'الملف الشخصي',
      titleColor: themeColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroHeader(context, ref, user, role, themeColor),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildStatsSection(role, provider, themeColor),
                  const SizedBox(height: 30),
                  _buildInformationSection(user, role, themeColor),
                  const SizedBox(height: 30),
                  _buildActionsSection(themeColor),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ممرض': return const Color(0xFF0369A1);
      case 'متطوع': return const Color(0xFF059669);
      case 'عائلة': return const Color(0xFFea580c);
      case 'أخصائي': return const Color(0xFFc026d3);
      case 'مدير': return const Color(0xFF1e293b);
      case 'مسن':
      default: return const Color(0xFF6C63FF);
    }
  }

  Widget _buildHeroHeader(BuildContext context, WidgetRef ref, User user, String role, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=elderly'),
                ),
              ),
              Positioned(
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
          Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
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

  Widget _buildStatsSection(String role, AppRiverpod provider, Color themeColor) {
    List<Map<String, dynamic>> stats = [];
    
    if (role == 'مسن') {
      stats = [
        {'label': 'النقاط', 'value': '${provider.currentUser.points}', 'icon': Icons.stars_rounded},
        {'label': 'الأنشطة', 'value': '${provider.currentUser.completedActivities}', 'icon': Icons.check_circle_rounded},
        {'label': 'الأيام', 'value': '${provider.currentUser.streakDays}', 'icon': Icons.calendar_today_rounded},
      ];
    } else if (role == 'متطوع') {
      stats = [
        {'label': 'الساعات', 'value': '${provider.volunteerHours}', 'icon': Icons.timer_rounded},
        {'label': 'المهام', 'value': '${provider.volunteerBookings.length}', 'icon': Icons.assignment_turned_in_rounded},
        {'label': 'التقييم', 'value': '${provider.averageRating}', 'icon': Icons.star_rounded},
      ];
    } else {
      stats = [
        {'label': 'الحالات', 'value': '${provider.residentFiles.length}', 'icon': Icons.people_rounded},
        {'label': 'التقارير', 'value': '١٥٦', 'icon': Icons.description_rounded},
        {'label': 'المركز', 'value': 'طبطبة', 'icon': Icons.business_rounded},
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((s) => _buildStatCard(s, themeColor)).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(stat['icon'], color: themeColor, size: 28),
          const SizedBox(height: 8),
          Text(stat['value'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(stat['label'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInformationSection(User user, String role, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المعلومات الأساسية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        _buildInfoTile(Icons.email_outlined, 'البريد الإلكتروني', 'ahmed.shereef@example.com'),
        _buildInfoTile(Icons.phone_outlined, 'رقم الهاتف', '01234567890'),
        _buildInfoTile(Icons.location_on_outlined, 'العنوان', 'القاهرة، المعادي'),
        _buildInfoTile(Icons.cake_outlined, 'تاريخ الميلاد', '١٥ يناير ١٩٥٠'),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
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
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(Color themeColor) {
    return Column(
      children: [
        _buildActionTile(Icons.settings_outlined, 'إعدادات الحساب'),
        _buildActionTile(Icons.security_rounded, 'الأمان والخصوصية'),
        _buildActionTile(Icons.help_outline_rounded, 'المساعدة والدعم'),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E293B)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.white,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back to dashboard (optional if logout forces a rebuild)
                    ref.read(appRiverpod).logout();
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
                child: OutlinedButton(
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

import 'package:flutter/material.dart';

class NurseProfileScreen extends StatelessWidget {
  const NurseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatsGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'جدول الورديات القادمة 🗓️'),
                  _buildShiftSchedule(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'الأوسمة والإنجازات 🏅'),
                  _buildBadges(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'آراء الأسر وتقييم الأداء ⭐'),
                  _buildFeedbackCard(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0369A1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildProfileImage(),
              const SizedBox(height: 16),
              const Text('أ. منى علي محمود', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('مشرف تمريض — المستوى الذهبي', style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('كود الموظف: #N-4892', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.person, size: 60, color: Color(0xFF0369A1)),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard(context, 'ساعات العمل', '١,٢٤٠', Icons.timer_outlined, const Color(0xFF0EA5E9))),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, 'دقة الأدوية', '٩٩.٢٪', Icons.verified_user_outlined, const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, 'التقييم', '٤.٩/٥', Icons.star_outline_rounded, const Color(0xFFFBBF24))),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
    );
  }

  Widget _buildShiftSchedule(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _shiftRow(context, 'الإثنين - ٢٧ أبريل', '٠٦:٠٠ ص - ٠٢:٠٠ ظ', 'صباحية', true),
          const Divider(height: 20, color: Colors.white10),
          _shiftRow(context, 'الثلاثاء - ٢٨ أبريل', '٠٦:٠٠ ص - ٠٢:٠٠ ظ', 'صباحية', true),
          const Divider(height: 20, color: Colors.white10),
          _shiftRow(context, 'الأربعاء - ٢٩ أبريل', 'راحة أسبوعية', '-', false),
        ],
      ),
    );
  }

  Widget _shiftRow(BuildContext context, String date, String time, String type, bool active) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active ? (isDark ? const Color(0xFF0369A1).withOpacity(0.2) : const Color(0xFFF0F9FF)) : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(type, style: TextStyle(color: active ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1)) : (isDark ? Colors.white38 : const Color(0xFF64748B)), fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Text(time, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: [
          _badge('مسعف محترف', '🩺', const Color(0xFFEF4444)),
          _badge('صديق الأسرة', '🤝', const Color(0xFF6366F1)),
          _badge('دقة متناهية', '🎯', const Color(0xFF10B981)),
          _badge('قائد فريق', '⭐', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _badge(String name, String emoji, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('سارة أحمد (ابنة الحاج يحيى)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  Text('منذ ٣ أيام', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Text('س', style: TextStyle(color: Color(0xFF0369A1)))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"ممرضة منى ممتازة جداً في التعامل، وتهتم بأدق التفاصيل الطبية والجانب النفسي لوالدي. شكراً لجهودكم."',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569), height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

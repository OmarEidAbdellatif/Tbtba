import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import 'widgets/add_skill_dialog.dart';
import 'widgets/edit_profile_sheet.dart';

class VolunteerProfileView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;

  const VolunteerProfileView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionLabel('ملفي الشخصي', const Color(0xFF065f46), 0),
          const SizedBox(height: 12),
          _buildProfileCard(context, ref),
          const SizedBox(height: 24),
          _buildSectionLabel('فرص تطوعية جديدة', const Color(0xFF059669), 1),
          const SizedBox(height: 12),
          ...provider.volunteerOpportunities.map((o) => _buildOpportunityCard(o)).toList(),
          const SizedBox(height: 24),
          _buildSectionLabel('حجوزاتي القادمة', const Color(0xFF059669), 2),
          const SizedBox(height: 12),
          ...provider.volunteerBookings.map((b) => _buildBookingCard(b)).toList(),
          const SizedBox(height: 24),
          _buildSectionLabel('سجل الساعات', const Color(0xFF059669), 3),
          const SizedBox(height: 12),
          _buildHoursLog(provider),
          const SizedBox(height: 24),
          _buildSectionLabel('شهاداتي ومكافآتي 🏅', const Color(0xFFf59e0b), 4),
          const SizedBox(height: 12),
          _buildCertificatesCarousel(provider),
          const SizedBox(height: 24),
          _buildSectionLabel('التقييم المتبادل ⭐', const Color(0xFF6366f1), 5),
          const SizedBox(height: 12),
          _buildRatingSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, int index) {
    return FadeTransition(
      opacity: fadeAnimations[min(index, 11)],
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

   Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
     final profile = ref.watch(appRiverpod).volunteerProfile;
     return FadeTransition(
       opacity: fadeAnimations[1],
       child: Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: const Color(0xFFa7f3d0), width: 1.5),
         ),
         child: Column(
           children: [
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Column(
                   children: [
                     IconButton(
                       onPressed: () => _showEditProfile(context),
                       icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF059669)),
                     ),
                     IconButton(
                       onPressed: () => _simulateShare(context, profile),
                       icon: const Icon(Icons.share_rounded, color: Color(0xFF059669), size: 20),
                     ),
                   ],
                 ),
                 const Spacer(),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(8)),
                           child: const Text('✓ موثّق', style: TextStyle(color: Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
                         ),
                         const SizedBox(width: 8),
                         Text(profile.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                       ],
                     ),
                     Text('${profile.location} · مسجل منذ مارس ٢٠٢٤',
                         style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                     const SizedBox(height: 8),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         if (profile.instagramUrl != null && profile.instagramUrl!.isNotEmpty)
                           _socialIcon('📸'),
                         if (profile.facebookUrl != null && profile.facebookUrl!.isNotEmpty)
                           _socialIcon('🔵'),
                         if (profile.linkedinUrl != null && profile.linkedinUrl!.isNotEmpty)
                           _socialIcon('💼'),
                       ],
                     ),
                   ],
                 ),
                 const SizedBox(width: 12),
                 Container(
                   width: 58,
                   height: 58,
                   decoration: const BoxDecoration(
                     gradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF10b981)]),
                     shape: BoxShape.circle,
                   ),
                   child: Center(child: Text(profile.name.substring(0, 2), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                 ),
               ],
             ),
             const SizedBox(height: 12),
             Text(profile.bio, 
                 textAlign: TextAlign.right,
                 style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.4)),
             const SizedBox(height: 16),
             Wrap(
               spacing: 8,
               runSpacing: 8,
               alignment: WrapAlignment.end,
               children: [
                 ...profile.skills.map((s) => _buildSkillTag(s, ref: ref)),
                 GestureDetector(
                   onTap: () => _showAddSkill(context, ref),
                   child: _buildSkillTag('+ إضافة مهارة', isAction: true),
                 ),
               ],
             ),
             if (profile.cvFileName != null || profile.recommendationFileName != null) ...[
               const SizedBox(height: 12),
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                 child: Row(
                   children: [
                     const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 14),
                     const SizedBox(width: 8),
                     Text('تم إرفاق الملفات المهنية بنجاح', style: const TextStyle(fontSize: 9, color: Color(0xFF065f46))),
                   ],
                 ),
               ),
             ]
           ],
         ),
       ),
     );
   }
 
   Widget _socialIcon(String emoji) {
     return Container(
       margin: const EdgeInsets.only(left: 8),
       padding: const EdgeInsets.all(4),
       decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFd1fae5))),
       child: Text(emoji, style: const TextStyle(fontSize: 12)),
     );
   }
 
   void _showEditProfile(BuildContext context) {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => const EditProfileSheet(),
     );
   }
 
   void _showAddSkill(BuildContext context, WidgetRef ref) {
     showDialog(
       context: context,
       builder: (context) => AddSkillDialog(
         onAdd: (s) => ref.read(appRiverpod).addVolunteerSkill(s),
       ),
     );
   }
 
   void _simulateShare(BuildContext context, VolunteerProfile profile) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: const Text('تم نسخ رابط ملفك الشخصي للمشاركة! 🔗', style: TextStyle(fontFamily: 'Cairo')),
         backgroundColor: const Color(0xFF0369A1),
         action: SnackBarAction(label: 'ممتاز', textColor: Colors.white, onPressed: () {}),
       ),
     );
   }
 
   Widget _buildSkillTag(String label, {bool isAction = false, WidgetRef? ref}) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
       decoration: BoxDecoration(
         color: isAction ? Colors.white : const Color(0xFFd1fae5),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: const Color(0xFFa7f3d0)),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           if (!isAction && ref != null)
             GestureDetector(
               onTap: () => ref.read(appRiverpod).removeVolunteerSkill(label),
               child: const Padding(
                 padding: EdgeInsets.only(right: 6),
                 child: Icon(Icons.close, size: 12, color: Color(0xFF065f46)),
               ),
             ),
           Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065f46))),
         ],
       ),
     );
   }

  Widget _buildOpportunityCard(VolunteerOpportunity opp) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: opp.isNew ? Offset(0, -4 * floatController.value) : Offset.zero,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: opp.isNew ? const Color(0xFF10b981) : const Color(0xFFa7f3d0), width: 1.5),
          boxShadow: opp.isNew ? [BoxShadow(color: const Color(0xFF10b981).withOpacity(0.1), blurRadius: 10, spreadRadius: 2)] : [],
        ),
        child: Stack(
          children: [
            if (opp.isNew)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF10b981), borderRadius: BorderRadius.circular(8)),
                  child: const Text('جديدة!', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildGlowButton('احجز الآن'),
                    const SizedBox(height: 8),
                    Text('⏱ ${opp.hours} ساعة · يضيف لرصيدك', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(opp.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(opp.org, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                      const SizedBox(height: 8),
                      // Wrap is simple here
                      Wrap(
                        spacing: 4,
                        children: opp.tags.map((t) => _buildBadge(t)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(opp.icon, style: const TextStyle(fontSize: 20))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowButton(String label) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10b981), Color(0xFF059669)],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10b981).withOpacity(0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Color(0xFF065f46), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBookingCard(VolunteerBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFa7f3d0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(8)),
            child: const Text('✓ مؤكد', style: TextStyle(color: Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(booking.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(booking.timeInfo, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10b981)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${booking.day}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(booking.month, style: const TextStyle(color: Colors.white, fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursLog(AppRiverpod provider) {
    final progress = provider.volunteerHours / provider.volunteerGoal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF065f46), Color(0xFF059669)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${provider.volunteerGoal}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('الهدف', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('⏱ ${provider.volunteerHours}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('ساعة تطوعية هذا الشهر', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerProgressBar(progress),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}% من هدفك — باقي ${provider.volunteerGoal - provider.volunteerHours} ساعة للشهادة الذهبية 🏆',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              _buildLogChip('قراءة: ١٥ س'),
              _buildLogChip('دعم نفسي: ١٢ س'),
              _buildLogChip('ترفيه: ١١ س'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerProgressBar(double progress) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              height: 10,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [Color(0xFF10b981), Color(0xFF6ee7b7), Color(0xFF10b981)],
                  stops: [
                    shimmerController.value - 0.4,
                    shimmerController.value,
                    shimmerController.value + 0.4,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLogChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCertificatesCarousel(AppRiverpod provider) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.volunteerCertificates.length,
        itemBuilder: (context, index) {
          final cert = provider.volunteerCertificates[index];
          return ScaleTransition(
            scale: popController,
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cert.isLocked ? Colors.transparent : const Color(0xFFf0fdf4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFa7f3d0),
                  style: cert.isLocked ? BorderStyle.none : BorderStyle.solid,
                ),
              ),
              child: Opacity(
                opacity: cert.isLocked ? 0.4 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cert.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(cert.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF065f46))),
                    Text(cert.isLocked ? cert.progressInfo : cert.date,
                        style: const TextStyle(fontSize: 8, color: Color(0xFF94a3b8))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFa7f3d0), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFfffbeb), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFfde68a))),
            child: Row(
              children: [
                const Text('🙏', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('قيّم جلسة القراءة — الحاج محمود', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text('جلسة الأحد ٦ أبريل · انتظر تقييمك', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(5, (index) => Text(index < 4 ? '★' : '☆', style: TextStyle(color: index < 4 ? Colors.amber : Colors.grey[300], fontSize: 16))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('تقييمات المقيمين لي', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFfbbf24))),
              const SizedBox(width: 8),
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFfbbf24), shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          _buildRatingRow('التعامل', 5.0),
          _buildRatingRow('التحضير', 4.0),
          _buildRatingRow('الالتزام', 5.0),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$rating', style: TextStyle(color: rating >= 5 ? const Color(0xFF10b981) : const Color(0xFFf59e0b), fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            children: List.generate(5, (i) => Text(i < rating ? '★' : '☆', style: TextStyle(color: i < rating ? Colors.amber : Colors.grey[300], fontSize: 12))),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 60, child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.grey))),
        ],
      ),
    );
  }
}

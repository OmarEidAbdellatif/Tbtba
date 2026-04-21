import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class VolunteerOpportunitiesView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;

  const VolunteerOpportunitiesView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
  });

  @override
  ConsumerState<VolunteerOpportunitiesView> createState() =>
      _VolunteerOpportunitiesViewState();
}

class _VolunteerOpportunitiesViewState
    extends ConsumerState<VolunteerOpportunitiesView> {
  String _selectedSkill = 'الكل (٨)';
  String _selectedSort = 'مطابقة';

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return Column(
      children: [
        _buildSearchFilter(),
        _buildSkillFilters(),
        _buildSortRow(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel('مثالي لمهاراتك ✨', const Color(0xFF10b981), 0),
                const SizedBox(height: 12),
                _buildFeaturedOpportunity(provider.volunteerOpportunities.first),
                const SizedBox(height: 24),
                _buildSectionLabel('فرص مناسبة لك', const Color(0xFF6366f1), 1),
                const SizedBox(height: 12),
                ...provider.volunteerOpportunities.skip(1).map((o) => _buildOpportunityCard(o, provider)).toList(),
                const SizedBox(height: 24),
                _buildSectionLabel('فرص أخرى', const Color(0xFF94a3b8), 2),
                const SizedBox(height: 12),
                _buildOtherOpportunity(),
                const SizedBox(height: 24),
                _buildImpactTracker(provider.volunteerImpact),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.filter_list, color: Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFf0fdf4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFa7f3d0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF94a3b8), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('ابحث عن نشاط أو مهارة...',
                        style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillFilters() {
    final skills = ['الكل (٨)', '📚 قراءة (٢)', '🧠 دعم نفسي (٢)', '🎮 ترفيه (٢)', '💻 رقمي (١)', '💊 تمريض (١)'];
    return Container(
      height: 50,
      color: const Color(0xFFf8fafc),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: skills.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedSkill == skills[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedSkill = skills[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10b981)])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFd1fae5)),
              ),
              child: Center(
                child: Text(skills[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF065f46),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortRow() {
    final sorts = ['مطابقة', 'الأقرب', 'الساعات', 'الجديد'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFf0fdf4),
        border: Border(bottom: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...sorts.map((s) {
            final isSelected = _selectedSort == s;
            return GestureDetector(
              onTap: () => setState(() => _selectedSort = s),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF059669) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFd1fae5)),
                ),
                child: Text(s,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF065f46),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            );
          }).toList(),
          const Text(':ترتيب', style: TextStyle(color: Color(0xFF065f46), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, int index) {
    return FadeTransition(
      opacity: widget.fadeAnimations[min(index, 11)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildFeaturedOpportunity(VolunteerOpportunity opp) {
    return AnimatedBuilder(
      animation: widget.floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * widget.floatController.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10b981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF10b981).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFfbbf24), borderRadius: BorderRadius.circular(10)),
                  child: const Text('🆕 جديدة اليوم', style: TextStyle(color: Color(0xFF78350f), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                Text(opp.icon, style: const TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 12),
            Text(opp.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(opp.org, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: opp.tags.map((t) => Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(appRiverpod).joinOpportunity(opp.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حجز "${opp.title}" بنجاح! 🎉',
                            style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  child: _buildGlowButton('احجز الآن'),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                       children: [
                          const Text('مكان واحد متبقي!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _buildAvatarsStack(),
                       ],
                    ),
                    const SizedBox(height: 4),
                    Text('${opp.filledSlots}/${opp.totalSlots} سُجّل', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarsStack() {
    return SizedBox(
      width: 45,
      height: 24,
      child: Stack(
        children: [
           Positioned(left: 0, child: _buildAvatar(const Color(0xFF6366f1), 'س')),
           Positioned(left: 14, child: _buildAvatar(const Color(0xFFf59e0b), 'م')),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color, String text) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF10b981), width: 1.5)),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildGlowButton(String label) {
    return AnimatedBuilder(
      animation: widget.shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(label, style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildOpportunityCard(VolunteerOpportunity opp, AppRiverpod provider) {
    bool isMatched = opp.tags.any((t) => t.contains('دعم نفسي') || t.contains('قراءة'));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMatched ? const Color(0xFF10b981) : const Color(0xFFd1fae5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           if (isMatched) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(8)),
                     child: const Row(
                        children: [
                           Text('مطابق', style: TextStyle(color: Color(0xFF065f46), fontSize: 8, fontWeight: FontWeight.bold)),
                           SizedBox(width: 4),
                           Icon(Icons.circle, color: Color(0xFF10b981), size: 6),
                        ],
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 8),
           ],
           Row(
              children: [
                 Expanded(
                   child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         Text(opp.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                         Text(opp.org, style: TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                         const SizedBox(height: 6),
                         Text(opp.description, style: TextStyle(color: Color(0xFF374151), fontSize: 10, height: 1.5), textAlign: TextAlign.right),
                      ],
                   ),
                 ),
                 const SizedBox(width: 12),
                 Container(
                   width: 48,
                   height: 48,
                   decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(14)),
                   child: Center(child: Text(opp.icon, style: const TextStyle(fontSize: 22))),
                 ),
              ],
           ),
           const SizedBox(height: 12),
           Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              children: opp.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(8)),
                child: Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              )).toList(),
           ),
           const SizedBox(height: 12),
           _buildSlotsProgressBar(opp.filledSlots / opp.totalSlots),
           const SizedBox(height: 12),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  GestureDetector(
                    onTap: () {
                      if (opp.id != 'vo2') {
                        // Avoid re-booking vo2 which is already marked as booked for demo
                        provider.joinOpportunity(opp.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم حجز "${opp.title}" بنجاح! 🎉',
                                style: const TextStyle(fontFamily: 'Cairo')),
                            backgroundColor: const Color(0xFF059669),
                          ),
                        );
                      }
                    },
                    child: _buildSmallActionBtn(
                        opp.id == 'vo2' ? '✓ محجوزة' : 'احجز',
                        isBooked: opp.id == 'vo2'),
                  ),
                 Row(
                    children: [
                       Text('+${opp.points} نقطة', style: const TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                       const SizedBox(width: 10),
                       Text('⏱ ${opp.hours} س', style: const TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                    ],
                 ),
              ],
           ),
        ],
      ),
    );
  }

  Widget _buildSlotsProgressBar(double progress) {
    return Container(
      height: 5,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.centerRight,
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * progress,
          decoration: BoxDecoration(color: const Color(0xFF10b981), borderRadius: BorderRadius.circular(3)),
        );
      }),
    );
  }

  Widget _buildSmallActionBtn(String label, {bool isBooked = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: isBooked ? null : const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10b981)]),
        color: isBooked ? const Color(0xFFd1fae5) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: isBooked ? const Color(0xFF065f46) : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOtherOpportunity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFffe4e6), width: 1.5),
      ),
      child: Row(
         children: [
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
               decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(10)),
               child: const Text('عرض', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            const Expanded(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text('مساعدة تمريض أساسية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                     Text('دار الرعاية النيل · الجمعة ٨:٠٠ ص', style: TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                     SizedBox(height: 4),
                     Text('⚠️ لا تتطابق مهاراتك', style: TextStyle(color: Color(0xFFef4444), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
               ),
            ),
            const SizedBox(width: 12),
            Container(
               width: 44,
               height: 44,
               decoration: BoxDecoration(color: const Color(0xFFffe4e6), borderRadius: BorderRadius.circular(12)),
               child: const Center(child: Text('💊', style: TextStyle(fontSize: 20))),
            ),
         ],
      ),
    );
  }

  Widget _buildImpactTracker(VolunteerImpact impact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFd1fae5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionLabel('أثرك التطوعي 💚', const Color(0xFF059669), 3),
          const SizedBox(height: 12),
          _buildImpactRow('👴', 'مقيمون استفادوا منك', 'منذ بداية تطوعك', '${impact.residentsServed} مقيم'),
          _buildImpactRow('😊', 'تقييمات إيجابية تلقيتها', 'من المقيمين والإدارة', '${impact.positiveRatings} ⭐'),
          _buildImpactRow('⏱', 'إجمالي ساعاتك التطوعية', 'منذ مارس ٢٠٢٤', '${impact.totalHours} ساعة'),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String icon, String title, String sub, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf0fdf4)))),
      child: Row(
        children: [
          Text(val, style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
              Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF94a3b8))),
            ],
          ),
          const SizedBox(width: 12),
          Text(icon, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

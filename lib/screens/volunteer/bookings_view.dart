import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class VolunteerBookingsView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;

  const VolunteerBookingsView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
  });

  @override
  ConsumerState<VolunteerBookingsView> createState() => _VolunteerBookingsViewState();
}

class _VolunteerBookingsViewState extends ConsumerState<VolunteerBookingsView> {
  int _selectedStatusTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled
  late Timer _countdownTimer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    // Mock target: 26 hours and 14 minutes from now
    final now = DateTime.now();
    final target = now.add(const Duration(hours: 26, minutes: 14));
    final diff = target.difference(now);

    if (diff.isNegative) {
      setState(() => _countdownText = 'بدأت الجلسة!');
    } else {
      setState(() => _countdownText = 'باقي ${diff.inHours} ساعة و${diff.inMinutes % 60} دقيقة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return Column(
      children: [
        _buildSummaryStrip(provider),
        _buildTabFilter(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.volunteerBookings.any((b) => b.isRatingRequired)) ...[
                  _buildRatingPrompt(provider.volunteerBookings.firstWhere((b) => b.isRatingRequired)),
                  const SizedBox(height: 16),
                ],
                _buildSectionLabel('الجلسة القادمة', const Color(0xFF10b981), 0),
                const SizedBox(height: 12),
                _buildNextSessionCard(provider.volunteerBookings.firstWhere((b) => b.status == 'confirmed')),
                const SizedBox(height: 24),
                _buildSectionLabel('حجوزاتي القادمة', const Color(0xFF6366f1), 1),
                const SizedBox(height: 12),
                ...provider.volunteerBookings
                    .where((b) => b.status == 'confirmed')
                    .skip(1)
                    .map((b) => _buildBookingCard(b))
                    .toList(),
                const SizedBox(height: 24),
                _buildSectionLabel('آخر جلسة مكتملة', const Color(0xFF6366f1), 2),
                const SizedBox(height: 12),
                _buildCompletedSessionCard(provider.volunteerBookings.firstWhere((b) => b.status == 'done')),
                const SizedBox(height: 24),
                _buildMonthlyStats(provider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStrip(AppRiverpod provider) {
    final upcomingCount = provider.volunteerBookings.where((b) => b.status == 'confirmed').length;
    final doneCount = provider.volunteerBookings.where((b) => b.status == 'done').length;
    final ratingCount = provider.volunteerBookings.where((b) => b.isRatingRequired).length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        children: [
          _buildSummaryCell('$upcomingCount', 'قادمة', const Color(0xFF059669)),
          _buildSummaryCell('$doneCount', 'مكتملة', const Color(0xFF6366f1)),
          _buildSummaryCell('$ratingCount', 'تقييم مطلوب', const Color(0xFFf59e0b)),
          _buildSummaryCell('${provider.volunteerHours}', 'ساعة هذا الشهر', const Color(0xFF0f172a)),
        ],
      ),
    );
  }

  Widget _buildSummaryCell(String val, String lbl, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFd1fae5)))),
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(lbl, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 8), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    final tabs = ['القادمة (٢)', 'المكتملة (١٢)', 'الملغاة (١)'];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFd1fae5))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedStatusTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatusTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF10b981) : Colors.transparent, width: 2.5)),
                ),
                child: Text(tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? const Color(0xFF059669) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRatingPrompt(VolunteerBooking booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfffbeb),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFfde68a)),
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             decoration: BoxDecoration(
               gradient: const LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFfbbf24)]),
               borderRadius: BorderRadius.circular(10),
             ),
             child: const Text('قيّم الآن', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
           ),
           const Spacer(),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 const Text('قيّم جلسة الأمس — الحاج محمود', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                 Text('${booking.title} · ${booking.day} ${booking.month}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
                 const SizedBox(height: 6),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: List.generate(5, (index) => Text(index < 4 ? '★' : '☆', style: TextStyle(color: index < 4 ? Colors.amber : Colors.grey[300], fontSize: 16))),
                 ),
               ],
             ),
           ),
           const SizedBox(width: 12),
           const Text('⭐', style: TextStyle(fontSize: 20)),
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

  Widget _buildNextSessionCard(VolunteerBooking booking) {
    return AnimatedBuilder(
      animation: widget.floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * widget.floatController.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10b981)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF10b981).withOpacity(0.35), blurRadius: 15, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('غداً — الخميس ١٠ أبريل', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(booking.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(booking.timeInfo, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('🧠', style: TextStyle(fontSize: 24))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(_countdownText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   const Text('⏱', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Text('تأكيد الحضور', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 14),
                    ],
                  ),
                ),
                Text('+${booking.points} نقطة عند الإتمام', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(VolunteerBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: booking.isUrgent ? const Color(0xFF10b981) : const Color(0xFFd1fae5), width: booking.isUrgent ? 2 : 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(10)),
                   child: const Text('✓ مؤكد', style: TextStyle(color: Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(booking.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                      Text(booking.timeInfo, style: const TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                           Text(booking.location, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 10)),
                           const SizedBox(width: 4),
                           const Icon(Icons.location_on_outlined, color: Color(0xFF94a3b8), size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: indexTabToColor(booking.day)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${booking.day}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(booking.month, style: const TextStyle(color: Colors.white, fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (booking.isUrgent) ...[
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: const BoxDecoration(color: Color(0xFFf0fdf4), border: Border(top: BorderSide(color: Color(0xFFd1fae5)))),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Text('check-in', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Icon(Icons.location_searching, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                    const Text('📍 تسجيل الحضور عند الوصول', style: TextStyle(color: Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
                 ],
               ),
             ),
          ],
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFf0fdf4)))),
            child: Row(
              children: [
                 _buildSmallCardAction('📋 تفاصيل'),
                 const SizedBox(width: 6),
                 _buildSmallCardAction('🗺️ الاتجاهات'),
                 const SizedBox(width: 6),
                 _buildSmallCardAction('✕ إلغاء', isDanger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> indexTabToColor(int day) {
     if (day == 10) return [const Color(0xFF059669), const Color(0xFF10b981)];
     return [const Color(0xFF6366f1), const Color(0xFF818cf8)];
  }

  Widget _buildSmallCardAction(String label, {bool isDanger = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFfff5f5) : const Color(0xFFf0fdf4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDanger ? const Color(0xFFfca5a5) : const Color(0xFFa7f3d0)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isDanger ? const Color(0xFFef4444) : const Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCompletedSessionCard(VolunteerBooking booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFe0e7ff), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('مكتملة', style: TextStyle(color: Color(0xFF3730a3), fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Color(0xFFe0e7ff))),
                const Spacer(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(booking.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(booking.timeInfo, style: const TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                           Text('تم توثيق ٢ ساعة بنجاح ✓', style: TextStyle(color: Color(0xFF10b981), fontSize: 10, fontWeight: FontWeight.bold)),
                           SizedBox(width: 4),
                           Icon(Icons.check_circle_outline, color: Color(0xFF10b981), size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366f1), const Color(0xFF818cf8)]),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${booking.day}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(booking.month, style: const TextStyle(color: Colors.white, fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFf0fdf4)))),
             child: Row(
               children: [
                 const Text('٣٨/٥٠', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Container(
                     height: 6,
                     decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(4)),
                     alignment: Alignment.centerRight,
                     child: FractionallySizedBox(
                       widthFactor: 0.76,
                       child: Container(decoration: BoxDecoration(color: const Color(0xFF10b981), borderRadius: BorderRadius.circular(4))),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 const Text('٢ ساعة', style: TextStyle(color: Color(0xFF64748b), fontSize: 10)),
               ],
             ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFf0fdf4)))),
            child: Row(
              children: [
                _buildSmallActionBtn('📄 تحميل شهادة الجلسة', flex: 2),
                const SizedBox(width: 8),
                _buildSmallActionBtn('⭐ تقييم'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: flex > 1 ? Colors.white : const Color(0xFFf0fdf4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFa7f3d0)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF065f46), fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMonthlyStats(AppRiverpod provider) {
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
          _buildSectionLabel('إحصائيات أبريل', const Color(0xFF059669), 3),
          const SizedBox(height: 12),
          _buildStatMiniRow('⏱', 'ساعات هذا الشهر', '${provider.volunteerHours} / ${provider.volunteerGoal}'),
          _buildStatMiniRow('📅', 'جلسات مكتملة', '١٢ جلسة'),
          _buildStatMiniRow('⭐', 'متوسط تقييمك', '٤.٧ / ٥'),
          _buildStatMiniRow('🏆', 'باقي للشهادة الذهبية', '١٢ ساعة', isShimmer: true),
        ],
      ),
    );
  }

  Widget _buildStatMiniRow(String icon, String label, String val, {bool isShimmer = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf0fdf4)))),
      child: Row(
        children: [
          if (isShimmer)
            AnimatedBuilder(
              animation: widget.shimmerController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [Color(0xFF059669), Color(0xFF34d399), Color(0xFF059669)],
                    stops: [widget.shimmerController.value - 0.2, widget.shimmerController.value, widget.shimmerController.value + 0.2],
                  ).createShader(bounds),
                  child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                );
              },
            )
          else
            Text(val, style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          Text(icon, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

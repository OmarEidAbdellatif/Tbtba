import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

/* 
 * واجهة تتبع وإدارة الشكاوى: 
 * تقوم هذه الشاشة بعرض قائمة الشكاوى الواردة من الأهالي، وتوفر أدوات 
 * لتصفية الشكاوى حسب حالتها (مفتوحة، قيد المعالجة، مكتملة)، 
 * بالإضافة إلى عرض الجدول الزمني لكل شكوى للمتابعة اللحظية.
 */

class SpecialistComplaintsView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistComplaintsView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);

    /* 
     * إدارة حالات الشكاوى:
     * يتم هنا فصل الشكاوى برمجياً بناءً على الحالة (Status)
     * لضمان ظهور كل شكوى في القسم المخصص لها في واجهة المستخدم.
     */

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeroKPI(provider),
              _buildSearchRow(context, provider),
              _buildFilterRow(provider),
              _buildKanbanPreview(provider),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(14),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionLabel('تحتاج تدخل فوري', const Color(0xFFef4444), 3,
                  isBlink: true), // قسم الشكاوى عالية الأهمية التي تتطلب تحركاً سريعاً
              const SizedBox(height: 8),
              // جلب وعرض الشكاوى المفتوحة ذات الأولوية القصوى
              ...provider.filteredSocialComplaints
                  .where((c) => c.status == 'open' && c.priority == 'high')
                  .map((c) => _buildDetailedComplaintCard(context, ref, c))
                  .toList(),
              const SizedBox(height: 20),
              _buildSectionLabel('قيد المعالجة', const Color(0xFFf59e0b), 4),
              const SizedBox(height: 8),
              ...provider.filteredSocialComplaints
                  .where((c) => c.status == 'progress')
                  .map((c) => _buildDetailedComplaintCard(context, ref, c))
                  .toList(),
              const SizedBox(height: 20),
              _buildSectionLabel('مُغلقة مؤخراً', const Color(0xFF10b981), 5),
              const SizedBox(height: 8),
              ...provider.filteredSocialComplaints
                  .where((c) => c.status == 'done')
                  .map((c) => _buildDetailedComplaintCard(context, ref, c))
                  .toList(),
              const SizedBox(height: 24),
              _buildMonthlyStats(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroKPI(AppRiverpod provider) {
    final stats = [
      {
        'val': '٣',
        'lbl': 'مفتوحة',
        'col': const Color(0xFFfca5a5),
        'blink': true
      },
      {
        'val': '٤',
        'lbl': 'جاري',
        'col': const Color(0xFFfde68a),
        'blink': false
      },
      {
        'val': '٨',
        'lbl': 'مُغلقة',
        'col': const Color(0xFF6ee7b7),
        'blink': false
      },
      {'val': '١٥', 'lbl': 'الكل', 'col': Colors.white, 'blink': false},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFc2410c), Color(0xFFea580c), Color(0xFFf97316)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          FadeTransition(
            opacity: popController,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: stats
                    .map((s) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              border: s == stats.last
                                  ? null
                                  : Border(
                                      left: BorderSide(
                                          color:
                                              Colors.white.withOpacity(0.2))),
                            ),
                            child: Column(
                              children: [
                                Text(s['val'] as String,
                                    style: TextStyle(
                                        color: s['col'] as Color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(s['lbl'] as String,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 8)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context, AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFfed7aa)))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAddComplaintDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('إضافة',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                  color: const Color(0xFFfff7ed),
                  border: Border.all(color: const Color(0xFFfed7aa)),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                onChanged: (v) {
                  // In a real app, update provider.searchComplaints(v)
                },
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو نوع الشكوى...',
                  hintStyle: TextStyle(color: Color(0xFF94a3b8), fontSize: 11),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF94a3b8), size: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddComplaintDialog(BuildContext context, AppRiverpod provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('تسجيل شكوى جديدة', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'اسم المقيم'),
            ),
            const TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'نوع الشكوى / العنوان'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: 'medium',
              items: const [
                DropdownMenuItem(value: 'high', child: Text('عاجل')),
                DropdownMenuItem(value: 'medium', child: Text('متوسط')),
                DropdownMenuItem(value: 'low', child: Text('خفيف')),
              ],
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: 'الأولوية'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم تسجيل الشكوى بنجاح'),
                backgroundColor: Color(0xFFea580c),
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFea580c)),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppRiverpod provider) {
    final filters = [
      'الكل (١٥)',
      '🔴 مفتوحة',
      '🟡 جاري',
      '✅ مُغلقة',
      '🏠 خدمات',
      '😔 نفسي',
      '🍽️ طعام'
    ];
    return Container(
      padding: const EdgeInsets.all(7),
      height: 48,
      decoration: const BoxDecoration(
          color: Color(0xFFf8fafc),
          border: Border(bottom: BorderSide(color: Color(0xFFe2e8f0)))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: filters.map((f) {
            final isAct = provider.selectedComplaintStatus == f;
            return GestureDetector(
              onTap: () => provider.setSelectedComplaintStatus(f),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAct ? null : Colors.white,
                  gradient: isAct
                      ? const LinearGradient(
                          colors: [Color(0xFFea580c), Color(0xFFf97316)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isAct ? null : Border.all(color: const Color(0xFFe2e8f0)),
                ),
                child: Text(f,
                    style: TextStyle(
                        color: isAct ? Colors.white : const Color(0xFF64748b),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKanbanPreview(AppRiverpod provider) {
    return FadeTransition(
      opacity: fadeAnimations[2],
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _buildKanbanColumn(
                'مُغلقة',
                '٨',
                const Color(0xFF10b981),
                const Color(0xFFd1fae5),
                provider.socialComplaints
                    .where((c) => c.status == 'done')
                    .toList()),
            const SizedBox(width: 7),
            _buildKanbanColumn(
                'جاري',
                '٤',
                const Color(0xFFf59e0b),
                const Color(0xFFfef3c7),
                provider.socialComplaints
                    .where((c) => c.status == 'progress')
                    .toList()),
            const SizedBox(width: 7),
            _buildKanbanColumn(
                'مفتوحة',
                '٣',
                const Color(0xFFef4444),
                const Color(0xFFfee2e2),
                provider.socialComplaints
                    .where((c) => c.status == 'open')
                    .toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String title, String count, Color col, Color bg,
      List<SocialSpecialistComplaint> items) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFe2e8f0), width: 1.5)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: bg.withOpacity(0.3),
                  border: Border(bottom: BorderSide(color: col, width: 2))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: bg, borderRadius: BorderRadius.circular(8)),
                    child: Text(count,
                        style: TextStyle(
                            color: col,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text(title,
                      style: TextStyle(
                          color: col,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: min(items.length, 2) + (items.length > 2 ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == 2)
                    return Center(
                        child: Text('+ ${items.length - 2} أخرى',
                            style: const TextStyle(
                                fontSize: 8, color: Color(0xFF94a3b8))));
                  final item = items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.priority == 'high'
                          ? const Color(0xFFfff5f5)
                          : const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: item.priority == 'high'
                              ? const Color(0xFFfca5a5)
                              : const Color(0xFFf1f5f9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w500)),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              color: _getPriorityBg(item.priority),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(_getPriorityLabel(item.priority),
                              style: TextStyle(
                                  color: _getPriorityColor(item.priority),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, int index,
      {bool isBlink = false}) {
    return FadeTransition(
      opacity: fadeAnimations[min(index, 11)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF9a3412),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  // بناء كارت الشكوى التفصيلي: يعرض كافة المعلومات الأساسية وحالة الأولوية
  Widget _buildDetailedComplaintCard(BuildContext context, WidgetRef ref,
      SocialSpecialistComplaint complaint) {
    return GestureDetector(
      onTap: () => _showComplaintDetails(context, ref, complaint), // فتح تفاصيل الشكوى والجدول الزمني عند الضغط
      child: FadeTransition(
        opacity: fadeAnimations[4],
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color:
                    _getStatusBorderColor(complaint.status, complaint.priority), // لون الإطار يعبر عن الحالة
                width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color:
                        _getStatusBgColor(complaint.status, complaint.priority),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16))),
                child: Row(
                  children: [
                    _buildStatusBadge(complaint.status, complaint.priority),
                    const Spacer(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(complaint.title,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0f172a))),
                          Text(
                              '${complaint.residentName} — غرفة ${complaint.room} · ${complaint.date}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF64748b))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: _getIconBg(complaint.category),
                          borderRadius: BorderRadius.circular(11)),
                      child: Center(
                          child: Text(complaint.icon,
                              style: const TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 9),
                    Container(
                        width: 4,
                        height: 36,
                        decoration: BoxDecoration(
                            color: _getPriorityColor(complaint.priority),
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              if (complaint.timeline.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Color(0xFFf8fafc)))),
                  child: Column(
                    children: complaint.timeline
                        .map((s) =>
                            _buildTimelineRow(s, s == complaint.timeline.last))
                        .toList(),
                  ),
                ),
              _buildCardActions(context, ref, complaint),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, WidgetRef ref,
      SocialSpecialistComplaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf8fafc),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(complaint.status, complaint.priority),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF64748b)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(complaint.title,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0f172a))),
                              Text(
                                  '${complaint.residentName} · غرفة ${complaint.room}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFFea580c))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getIconBg(complaint.category),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(complaint.icon,
                                style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDetailSectionTitle('تاريخ الشكوى'),
                    const SizedBox(height: 12),
                    Text(
                      'تم تقديم الشكوى بتاريخ ${complaint.date} بخصوص ${complaint.title}. الحالة الحالية هي "${_getStatusLabel(complaint.status)}".',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748b), height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    _buildDetailSectionTitle('سجل المتابعة'),
                    const SizedBox(height: 16),
                    ...complaint.timeline.map((s) => _buildTimelineItem(s)),
                    const SizedBox(height: 40),
                    if (complaint.status != 'done')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10b981),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showResolutionDialog(
                                      context, ref, complaint);
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('إغلاق وحل الشكوى ✓',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFea580c)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('تم تصعيد الشكوى للإدارة')));
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('تصعيد للإدارة ↑',
                                      style: TextStyle(
                                          color: Color(0xFFea580c),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155))),
        const SizedBox(width: 12),
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: const Color(0xFFea580c),
                borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildTimelineItem(ComplaintStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.time,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94a3b8))),
          const Spacer(),
          Expanded(
            child: Text(step.text,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    color: step.status == 'alert'
                        ? const Color(0xFFef4444)
                        : const Color(0xFF1e293b),
                    fontWeight: step.status == 'alert'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _getStepColor(step.status),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 30,
                color: const Color(0xFFe2e8f0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'open':
        return 'مفتوحة';
      case 'progress':
        return 'قيد المعالجة';
      case 'done':
        return 'مكتملة';
      default:
        return status;
    }
  }

  Widget _buildTimelineRow(ComplaintStep step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.time,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94a3b8))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(step.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10,
                  color: step.status == 'alert'
                      ? const Color(0xFFef4444)
                      : const Color(0xFF374151),
                  fontWeight: step.status == 'alert'
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: _getStepColor(step.status), shape: BoxShape.circle)),
            if (!isLast)
              Container(width: 1, height: 18, color: const Color(0xFFe2e8f0)),
          ],
        ),
      ],
    );
  }

  Widget _buildCardActions(BuildContext context, WidgetRef ref,
      SocialSpecialistComplaint complaint) {
    bool isClosed = complaint.status == 'done';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFf8fafc)))),
      child: Row(
        children: [
          if (!isClosed) ...[
            Expanded(
              child: _buildActionButton(
                '✓ إغلاق',
                type: 'done',
                onTap: () => _showResolutionDialog(context, ref, complaint),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionButton(
                complaint.status == 'open' ? '✏️ بدء التدخل' : '↑ تصعيد',
                type: 'primary',
                onTap: () {
                  if (complaint.status == 'open') {
                    ref.read(appRiverpod).startIntervention(complaint.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تصعيد الشكوى للإدارة')));
                  }
                },
              ),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  void _showResolutionDialog(BuildContext context, WidgetRef ref,
      SocialSpecialistComplaint complaint) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('إغلاق الشكوى 🏠',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('كيف تم حل المشكلة لـ ${complaint.residentName}؟',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFf8fafc),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFe2e8f0))),
              child: TextField(
                controller: noteController,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'اكتب تفاصيل الحل هنا...',
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                ref
                    .read(appRiverpod)
                    .closeComplaint(complaint.id, noteController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم إغلاق الشكوى وإخطار الأهل بنجاح ✅'),
                      backgroundColor: Color(0xFF10b981)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('تأكيد الإغلاق',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label,
      {required String type, VoidCallback? onTap}) {
    Color bg = const Color(0xFFfff7ed);
    Color fg = const Color(0xFF9a3412);
    Gradient? grad;
    Border? border = Border.all(color: const Color(0xFFfed7aa));

    if (type == 'primary') {
      grad =
          const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]);
      fg = Colors.white;
      border = null;
    } else if (type == 'done') {
      bg = const Color(0xFFd1fae5);
      fg = const Color(0xFF065f46);
      border = Border.all(color: const Color(0xFFa7f3d0));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
            color: grad == null ? bg : null,
            gradient: grad,
            borderRadius: BorderRadius.circular(9),
            border: border),
        child: Center(
            child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
              style: TextStyle(
                  color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
        )),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final stats = [
      {
        'lbl': 'نفسي / اجتماعي',
        'val': 6,
        'max': 10,
        'col': const Color(0xFF6366f1)
      },
      {
        'lbl': 'خدمات الدار',
        'val': 4,
        'max': 10,
        'col': const Color(0xFFf59e0b)
      },
      {
        'lbl': 'طعام وتغذية',
        'val': 3,
        'max': 10,
        'col': const Color(0xFFef4444)
      },
      {
        'lbl': 'أنشطة ورحلات',
        'val': 2,
        'max': 10,
        'col': const Color(0xFF10b981)
      },
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('إحصائيات هذا الشهر',
                  style: TextStyle(
                      color: Color(0xFF9a3412),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Color(0xFF6366f1), shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: stats
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Text(s['val'].toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: s['col'] as Color)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFf1f5f9),
                                  borderRadius: BorderRadius.circular(4)),
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor:
                                    (s['val'] as int) / (s['max'] as int),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: s['col'] as Color,
                                        borderRadius:
                                            BorderRadius.circular(4))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 75,
                              child: Text(s['lbl'] as String,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF64748b)))),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const Divider(color: Color(0xFFf1f5f9), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('٢.٣ يوم',
                  style: TextStyle(
                      color: Color(0xFFea580c),
                      fontWeight: FontWeight.bold,
                      fontSize: 10)),
              const Text('متوسط وقت الإغلاق',
                  style: TextStyle(color: Color(0xFF64748b), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _buildStatusBadge(String status, String priority) {
    if (priority == 'high' && status == 'open') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFfee2e2),
            borderRadius: BorderRadius.circular(9)),
        child: const Text('🔴 مفتوحة',
            style: TextStyle(
                color: Color(0xFF7f1d1d),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'progress') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFfef3c7),
            borderRadius: BorderRadius.circular(9)),
        child: const Text('🟡 جاري',
            style: TextStyle(
                color: Color(0xFF92400e),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: const Color(0xFFd1fae5),
          borderRadius: BorderRadius.circular(9)),
      child: const Text('✅ تمّت',
          style: TextStyle(
              color: Color(0xFF065f46),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusBorderColor(String status, String priority) {
    if (priority == 'high' && status == 'open') return const Color(0xFFfca5a5);
    if (status == 'progress') return const Color(0xFFfde68a);
    if (status == 'done') return const Color(0xFFa7f3d0);
    return const Color(0xFFe2e8f0);
  }

  Color _getStatusBgColor(String status, String priority) {
    if (priority == 'high' && status == 'open') return const Color(0xFFfff5f5);
    if (status == 'progress') return const Color(0xFFfffbeb);
    if (status == 'done') return const Color(0xFFf0fdf4);
    return Colors.white;
  }

  Color _getPriorityColor(String p) {
    if (p == 'high') return const Color(0xFFef4444);
    if (p == 'medium') return const Color(0xFFf59e0b);
    return const Color(0xFF10b981);
  }

  Color _getPriorityBg(String p) {
    if (p == 'high') return const Color(0xFFfee2e2);
    if (p == 'medium') return const Color(0xFFfef3c7);
    return const Color(0xFFd1fae5);
  }

  String _getPriorityLabel(String p) {
    if (p == 'high') return 'عاجل';
    if (p == 'medium') return 'متوسط';
    return 'خفيف';
  }

  Color _getIconBg(String cat) {
    if (cat == 'psych') return const Color(0xFFede9fe);
    if (cat == 'food') return const Color(0xFFfee2e2);
    return const Color(0xFFfef3c7);
  }

  Color _getStepColor(String s) {
    if (s == 'done') return const Color(0xFF10b981);
    if (s == 'alert') return const Color(0xFFef4444);
    if (s == 'pending') return const Color(0xFFf59e0b);
    return const Color(0xFF6366f1);
  }
}

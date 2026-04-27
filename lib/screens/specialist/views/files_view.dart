import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class SpecialistFilesView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistFilesView({
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
    final files = provider.filteredResidentFiles;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildSearchHeader(context, provider),
              _buildCategoryFilters(provider),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FadeTransition(
                  opacity: fadeAnimations[index % 10],
                  child: _buildFileCard(context, files[index]),
                );
              },
              childCount: files.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context, AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('ملفات المقيمين',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFc2410c))),
          const Text('إدارة السجلات الاجتماعية والنفسية',
              style: TextStyle(fontSize: 12, color: Color(0xFF9a3412))),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
            ),
            child: TextField(
              onChanged: (v) => provider.setResidentFilesSearchQuery(v),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث باسم المقيم أو رقم الغرفة...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFea580c)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(AppRiverpod provider) {
    final categories = ['الكل', 'اجتماعي', 'نفسي', 'طبي', 'إداري'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isAct = provider.selectedResidentFileCategory == cat;
          return GestureDetector(
            onTap: () => provider.setSelectedResidentFileCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isAct ? const Color(0xFFea580c) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isAct ? Colors.transparent : const Color(0xFFfed7aa)),
                boxShadow: isAct
                    ? [
                        BoxShadow(
                            color: const Color(0xFFea580c).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                      color: isAct ? Colors.white : const Color(0xFF9a3412),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, SpecialistResidentFile file) {
    return GestureDetector(
      onTap: () => _showFileDetails(context, file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFfed7aa).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatusIcon(file.status),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(file.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1f2937))),
                      Row(
                        children: [
                          Text('الغرفة ${file.room}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFea580c),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text(file.lastUpdate,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF64748b))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFfff7ed), Color(0xFFffedd5)]),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFfed7aa)),
                    ),
                    child: Center(
                      child: Text(file.initials,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFea580c))),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFfff7ed)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildActionLabel(Icons.history_edu_rounded, 'سجل النشاط'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showFileDetails(context, file),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFea580c).withOpacity(0.2),
                              blurRadius: 10)
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('فتح الملف الرقمي',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.folder_open_rounded,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileDetails(BuildContext context, SpecialistResidentFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(file.status),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(file.name,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0f172a))),
                            Text('غرفة ${file.room} · الطابق الأول',
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFFea580c))),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFfff7ed), Color(0xFFffedd5)]),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFFfed7aa), width: 2),
                          ),
                          child: Center(
                            child: Text(file.initials,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFea580c))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDetailSectionTitle('الأقسام المفعلة'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: file.categories.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFe2e8f0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getCategoryLabel(c),
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF1e293b))),
                              const SizedBox(width: 8),
                              Icon(_getCategoryIcon(c),
                                  size: 16, color: const Color(0xFFea580c)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildDetailSectionTitle('آخر التحديثات'),
                    const SizedBox(height: 16),
                    _buildTimelineItem('تحديث الملف النفسي', 'اليوم، ١٠:٣٠ ص',
                        'أ. سارة المنسق', true),
                    _buildTimelineItem('إضافة ملاحظة اجتماعية', 'أمس، ٠٩:١٥ م',
                        'أ. محمد علي', false),
                    _buildTimelineItem('توثيق الحالة المادية',
                        '٢٤ مايو، ٠٣:٠٠ م', 'أ. نورهان سعيد', false),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFea580c),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('جاري تنزيل الملف الرقمي بالكامل...'),
                              backgroundColor: Color(0xFFea580c),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('تنزيل التقرير الشامل (PDF)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 12),
                            Icon(Icons.download_rounded, color: Colors.white),
                          ],
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

  Widget _buildStatusBadge(String status) {
    String label = 'محدّث';
    Color color = const Color(0xFF10b981);
    if (status == 'pending') {
      label = 'قيد المراجعة';
      color = const Color(0xFFf59e0b);
    }
    if (status == 'critical') {
      label = 'حالة حرجة';
      color = const Color(0xFFef4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimelineItem(
      String title, String time, String author, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e293b))),
                Text('$time · بواسطة $author',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94a3b8))),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLast ? const Color(0xFFea580c) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFea580c), width: isLast ? 0 : 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFFe2e8f0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'social':
        return 'اجتماعي';
      case 'medical':
        return 'طبي';
      case 'psychological':
        return 'نفسي';
      case 'admin':
        return 'إداري';
      default:
        return cat;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'social':
        return Icons.people_alt_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'psychological':
        return Icons.psychology_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Widget _buildStatusIcon(String status) {
    IconData icon = Icons.check_circle_rounded;
    Color color = const Color(0xFF10b981);
    if (status == 'pending') {
      icon = Icons.pending_actions_rounded;
      color = const Color(0xFFf59e0b);
    }
    if (status == 'critical') {
      icon = Icons.report_problem_rounded;
      color = const Color(0xFFef4444);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94a3b8)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF64748b),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

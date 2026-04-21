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

    return Column(
      children: [
        _buildSearchHeader(context, provider),
        _buildCategoryFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: fadeAnimations[index % 10],
                child: _buildFileCard(context, files[index]),
              );
            },
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
          const Text('ملفات المقيمين', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFc2410c))),
          const Text('إدارة السجلات الاجتماعية والنفسية', style: TextStyle(fontSize: 12, color: Color(0xFF9a3412))),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: TextField(
              onChanged: (v) => provider.setResidentFilesSearchQuery(v),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث باسم المقيم أو رقم الغرفة...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFea580c)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['الكل', 'اجتماعي', 'نفسي', 'طبي', 'إداري'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isFirst ? const Color(0xFFea580c) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isFirst ? Colors.transparent : const Color(0xFFfed7aa)),
              boxShadow: isFirst ? [BoxShadow(color: const Color(0xFFea580c).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(color: isFirst ? Colors.white : const Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, SpecialistResidentFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFfed7aa).withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
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
                    Text(file.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
                    Row(
                      children: [
                        Text('الغرفة ${file.room}', style: const TextStyle(fontSize: 11, color: Color(0xFFea580c), fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(file.lastUpdate, style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFfff7ed), Color(0xFFffedd5)]),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFfed7aa)),
                  ),
                  child: Center(
                    child: Text(file.initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFea580c))),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFFea580c).withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: const Row(
                    children: [
                      Text('فتح الملف الرقمي', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.folder_open_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon = Icons.check_circle_rounded;
    Color color = const Color(0xFF10b981);
    if (status == 'pending') { icon = Icons.pending_actions_rounded; color = const Color(0xFFf59e0b); }
    if (status == 'critical') { icon = Icons.report_problem_rounded; color = const Color(0xFFef4444); }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94a3b8)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF64748b), fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

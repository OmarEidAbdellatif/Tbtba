import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';
import '../assessment_detailed_screen.dart';

class SpecialistAssessmentView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistAssessmentView({
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionLabel('أدوات التقييم المتاحة', const Color(0xFF6366f1), 0),
          const SizedBox(height: 12),
          _buildToolsCard(provider),
          const SizedBox(height: 24),
          _buildSectionLabel('مقيمون بحاجة لتقييم', const Color(0xFFef4444), 1),
          const SizedBox(height: 12),
          ...provider.socialResidentScores.map((score) => _buildResidentAssessmentCard(context, score)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, int index) {
    return FadeTransition(
      opacity: fadeAnimations[min(index, 11)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildToolsCard(AppRiverpod provider) {
    return FadeTransition(
      opacity: fadeAnimations[2],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
        ),
        child: Column(
          children: provider.socialAssessmentTools.map((tool) => _buildToolRow(tool)).toList(),
        ),
      ),
    );
  }

  Widget _buildToolRow(SocialSpecialistAssessmentTool tool) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFfff7ed)))),
      child: Row(
        children: [
          _buildToolAction(tool.status),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tool.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
              Text(tool.subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF9ca3af))),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _getToolColor(tool.icon), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(tool.icon, style: const TextStyle(fontSize: 15))),
          ),
        ],
      ),
    );
  }

  Widget _buildToolAction(String status) {
    final isDone = status == 'مكتمل';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFd1fae5) : const Color(0xFFffedd5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: isDone ? const Color(0xFF065f46) : const Color(0xFF9a3412), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _getToolColor(String icon) {
    if (icon == '🧠') return const Color(0xFFffedd5);
    if (icon == '🤝') return const Color(0xFFede9fe);
    if (icon == '🏃') return const Color(0xFFdbeafe);
    return const Color(0xFFd1fae5);
  }

  Widget _buildResidentAssessmentCard(BuildContext context, SocialSpecialistResidentScore score) {
    return FadeTransition(
      opacity: fadeAnimations[4],
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssessmentDetailedScreen())),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: score.isUrgent ? const Color(0xFFef4444).withOpacity(0.5) : const Color(0xFFfed7aa), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (score.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFfee2e2), borderRadius: BorderRadius.circular(9)),
                      child: const Text('عاجل', style: TextStyle(color: Color(0xFF7f1d1d), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${score.name} — ${score.room}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
                      Text('آخر تقييم: ${score.date} · يحتاج تجديد', style: const TextStyle(fontSize: 10, color: Color(0xFF6b7280))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(color: Color(0xFFffe4e6), shape: BoxShape.circle),
                        child: Center(child: Text(score.initials, style: const TextStyle(color: Color(0xFF9f1239), fontWeight: FontWeight.bold))),
                      ),
                      if (score.isUrgent)
                        Positioned(
                          bottom: 0, left: 0,
                          child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...score.scores.entries.map((e) => _buildProgressRow(e.key, e.value)).toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssessmentDetailedScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFffedd5), borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('📋 بدء التقييم', style: TextStyle(color: Color(0xFF9a3412), fontSize: 10, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('📝 إضافة ملاحظة', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double val) {
    final color = _getScoreColor(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 25, child: Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 7,
              decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: shimmerController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: val,
                    child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 50, child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF6b7280)))),
        ],
      ),
    );
  }

  Color _getScoreColor(String label) {
    if (label == 'نفسي') return const Color(0xFFf59e0b);
    if (label == 'اجتماعي') return const Color(0xFFef4444);
    if (label == 'بدني') return const Color(0xFF10b981);
    return const Color(0xFF6366f1);
  }
}

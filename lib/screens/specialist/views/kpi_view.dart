import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class SpecialistKPIView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistKPIView({
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
          _buildSectionLabel('مؤشرات الأداء الاجتماعي', const Color(0xFF10b981), 0),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: provider.socialKPIs.length,
            itemBuilder: (context, index) {
              final kpi = provider.socialKPIs[index];
              return _buildKPICard(kpi, index);
            },
          ),
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

  Widget _buildKPICard(SocialSpecialistKPI kpi, int index) {
    return FadeTransition(
      opacity: fadeAnimations[min(index + 1, 11)],
      child: ScaleTransition(
        scale: popController,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFfed7aa), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(kpi.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kpi.isPositive ? const Color(0xFF10b981) : const Color(0xFFef4444))),
              const SizedBox(height: 4),
              Text(kpi.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF6b7280))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kpi.isPositive ? const Color(0xFFd1fae5).withOpacity(0.5) : const Color(0xFFfee2e2).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(kpi.trend, style: TextStyle(color: kpi.isPositive ? const Color(0xFF065f46) : const Color(0xFF7f1d1d), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

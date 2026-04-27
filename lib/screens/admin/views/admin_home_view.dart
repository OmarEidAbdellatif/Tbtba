import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class AdminHomeView extends StatelessWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;

  const AdminHomeView({super.key, required this.fadeAnimations, required this.floatController});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(appRiverpod);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FadeTransition(opacity: fadeAnimations[0], child: _buildSectionTitle('الأداء التشغيلي')),
              const SizedBox(height: 16),
              _buildKPIGrid(provider.adminStats),
              const SizedBox(height: 32),
              FadeTransition(opacity: fadeAnimations[1], child: _buildSectionTitle('منحنى النمو والصحة')),
              const SizedBox(height: 16),
              _buildLargeChartCard(),
              const SizedBox(height: 32),
              FadeTransition(opacity: fadeAnimations[2], child: _buildSectionTitle('تنبيهات المركز العاجلة')),
              const SizedBox(height: 16),
              if (provider.filteredNotifications.where((n) => n.targetRole == 'مدير' || n.targetRole == 'all').isEmpty)
                _buildAlertCard('لا توجد تنبيهات إدارية عاجلة', 'الآن', Colors.green)
              else
                ...provider.filteredNotifications
                    .where((n) => n.targetRole == 'مدير' || n.targetRole == 'all')
                    .take(3)
                    .map((n) => _buildAlertCard(n.title, n.time, n.type == 'complaint' ? Colors.red : Colors.blue)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
        const SizedBox(width: 8),
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF0ea5e9), borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildKPIGrid(List<CenterOperationalStat> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
      itemBuilder: (context, index) {
        final s = stats[index];
        return FadeTransition(
          opacity: fadeAnimations[index + 1],
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFf1f5f9)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(s.label, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(s.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.trend,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: s.isPositive ? const Color(0xFF10b981) : const Color(0xFFef4444),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildMiniTrendChart(s.history, s.isPositive),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniTrendChart(List<double> history, bool positive) {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((h) => Container(
          width: 4,
          height: h * 20,
          decoration: BoxDecoration(color: (positive ? const Color(0xFF10b981) : const Color(0xFFef4444)).withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
        )).toList(),
      ),
    );
  }

  Widget _buildLargeChartCard() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0ea5e9), Color(0xFF0284c7)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF0ea5e9).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الإيرادات التشغيلية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('مقارنة بالشهر الماضي', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
               height: 60,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   _chartBar(40), _chartBar(60), _chartBar(30), _chartBar(80), _chartBar(50), _chartBar(90), _chartBar(70),
                 ],
               ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double height) {
    return Container(width: 8, height: height, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4)));
  }

  Widget _buildAlertCard(String msg, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 10)),
          const Spacer(),
          Text(msg, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(width: 12),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

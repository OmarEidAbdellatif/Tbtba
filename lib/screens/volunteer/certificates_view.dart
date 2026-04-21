import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class VolunteerCertificatesView extends ConsumerStatefulWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;

  const VolunteerCertificatesView({
    super.key,
    required this.fadeAnimations,
    required this.floatController,
    required this.shimmerController,
    required this.popController,
  });

  @override
  ConsumerState<VolunteerCertificatesView> createState() => _VolunteerCertificatesViewState();
}

class _VolunteerCertificatesViewState extends ConsumerState<VolunteerCertificatesView> {
  int _selectedCertIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    final earnedCerts = provider.volunteerCertificates.where((c) => !c.isLocked).toList();
    final activeCert = earnedCerts[_selectedCertIndex];

    return Column(
      children: [
        _buildCertSelector(earnedCerts),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCertificateDocument(activeCert, provider),
                const SizedBox(height: 20),
                _buildActionGrid(),
                const SizedBox(height: 24),
                _buildSectionLabel('شهاداتي الأخرى', const Color(0xFF92400e), 0),
                const SizedBox(height: 12),
                _buildMiniCertsRow(provider.volunteerCertificates),
                const SizedBox(height: 24),
                _buildSectionLabel('توزيع ساعاتك التطوعية', const Color(0xFF92400e), 1),
                const SizedBox(height: 12),
                _buildHoursDistribution(provider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertSelector(List<VolunteerCertificate> certs) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFfde68a))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: certs.length + 2,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          if (index >= certs.length) {
            final isGold = index == certs.length;
            return _buildCertTab(isGold ? 'الذهبية' : 'الماسية', isGold ? '🏆' : '💎', isLocked: true);
          }
          final isSelected = _selectedCertIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCertIndex = index),
            child: _buildCertTab(certs[index].name, certs[index].icon, isSelected: isSelected),
          );
        },
      ),
    );
  }

  Widget _buildCertTab(String label, String icon, {bool isSelected = false, bool isLocked = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFFd97706) : Colors.transparent, width: 2.5)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF92400e) : const Color(0xFF94a3b8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              )),
          if (isLocked) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFd97706), borderRadius: BorderRadius.circular(6)),
              child: const Text('قريباً', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificateDocument(VolunteerCertificate cert, AppRiverpod provider) {
    return ScaleTransition(
      scale: widget.popController,
      child: AnimatedBuilder(
        animation: widget.floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -5 * widget.floatController.value),
            child: child,
          );
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFd97706), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFfbbf24).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Stack(
                children: [
                  _buildCornerMarkup(Alignment.topLeft),
                  _buildCornerMarkup(Alignment.topRight),
                  _buildCornerMarkup(Alignment.bottomLeft),
                  _buildCornerMarkup(Alignment.bottomRight),
                  Column(
                    children: [
                      _buildVerifiedBadge(),
                      const SizedBox(height: 10),
                      Text(cert.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      const Text('دار رعاية النيل — برنامج التطوع',
                          style: TextStyle(color: Color(0xFF92400e), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      const Text('تشهد بفخر واعتزاز بأن', style: TextStyle(color: Color(0xFF64748b), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text('عمر أحمد الشريف',
                          style: TextStyle(color: const Color(0xFF78350f), fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Text(cert.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748b), fontSize: 10, height: 1.5)),
                      const SizedBox(height: 16),
                      Text(cert.awardTitle,
                          style: const TextStyle(color: Color(0xFF92400e), fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(cert.date, style: const TextStyle(color: Color(0xFFb45309), fontSize: 10)),
                      const SizedBox(height: 12),
                      _buildStarsRow(),
                      const SizedBox(height: 12),
                      _buildCertStats(provider),
                      const SizedBox(height: 16),
                      _buildSignatures(),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildQRCode(),
                  ),
                ],
              ),
            ),
            _buildConfettiOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarkup(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: const Opacity(opacity: 0.25, child: Text('✦', style: TextStyle(fontSize: 20))),
    );
  }

  Widget _buildVerifiedBadge() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFd1fae5), borderRadius: BorderRadius.circular(20)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: Color(0xFF10b981), size: 10),
            SizedBox(width: 4),
            Text('موثّقة رقمياً', style: TextStyle(color: Color(0xFF065f46), fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return FadeTransition(opacity: widget.fadeAnimations[index % 5], child: const Text('⭐', style: TextStyle(fontSize: 22)));
      }),
    );
  }

  Widget _buildCertStats(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFfef3c7)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('${provider.volunteerHours}', 'ساعة تطوعية', isShimmer: true),
          _buildStatColumn('١٢', 'جلسة مكتملة'),
          _buildStatColumn('٤.٧', 'متوسط التقييم'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String val, String label, {bool isShimmer = false}) {
    return Column(
      children: [
        if (isShimmer)
          AnimatedBuilder(
            animation: widget.shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFd97706), Color(0xFFfbbf24), Color(0xFFd97706)],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              );
            },
          )
        else
          Text(val, style: const TextStyle(color: Color(0xFF78350f), fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 8)),
      ],
    );
  }

  Widget _buildSignatures() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFfef3c7)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSigBlock('أ. نور الهدى', 'المديرة التنفيذية'),
          _buildSigBlock('أ. سمر الرشيد', 'منسقة التطوع'),
        ],
      ),
    );
  }

  Widget _buildSigBlock(String name, String role) {
    return Column(
      children: [
        Container(width: 80, height: 1, color: const Color(0xFFd97706)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Color(0xFF78350f), fontSize: 10, fontWeight: FontWeight.bold)),
        Text(role, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 8)),
      ],
    );
  }

  Widget _buildQRCode() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: const Icon(Icons.qr_code_2, color: Color(0xFFd97706), size: 30),
    );
  }

  Widget _buildConfettiOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 80,
      child: IgnorePointer(
        child: Stack(
          children: List.generate(10, (index) {
            return _buildConfettiDot(index);
          }),
        ),
      ),
    );
  }

  Widget _buildConfettiDot(int index) {
    final colors = [Colors.amber, Colors.green, Colors.blue, Colors.pink, Colors.red];
    return AnimatedBuilder(
      animation: widget.floatController,
      builder: (context, child) {
        final pos = (index * 0.1);
        return Positioned(
          left: (pos * 300) + (10 * sin(widget.floatController.value * 6)),
          top: (widget.floatController.value * 100) % 80,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors[index % colors.length], shape: index.isEven ? BoxShape.circle : BoxShape.rectangle),
          ),
        );
      },
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _buildActionBtn('📄 تحميل PDF', [const Color(0xFFd97706), const Color(0xFFf59e0b)]),
        _buildActionBtn('🔗 نسخ الرابط', [const Color(0xFF059669), const Color(0xFF10b981)]),
        _buildActionBtn('💬 واتساب', [const Color(0xFF25D366), const Color(0xFF2ecc71)]),
        _buildActionBtn('📧 بريد إلكتروني', [const Color(0xFF4f46e5), const Color(0xFF6366f1)]),
      ],
    );
  }

  Widget _buildActionBtn(String label, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildMiniCertsRow(List<VolunteerCertificate> certs) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: certs.length,
        itemBuilder: (context, index) {
          final cert = certs[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cert.isLocked ? const Color(0xFFfde68a).withOpacity(0.5) : const Color(0xFFfde68a), width: cert.isLocked ? 1 : 2),
            ),
            child: Opacity(
              opacity: cert.isLocked ? 0.5 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cert.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(cert.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF92400e))),
                  Text(cert.isLocked ? cert.date : cert.date, style: const TextStyle(fontSize: 8, color: Color(0xFF94a3b8))),
                  if (cert.isLocked) ...[
                     const SizedBox(height: 6),
                     Container(
                       height: 3,
                       decoration: BoxDecoration(color: const Color(0xFFfef3c7), borderRadius: BorderRadius.circular(3)),
                       alignment: Alignment.centerRight,
                       child: FractionallySizedBox(widthFactor: cert.progress, child: Container(decoration: BoxDecoration(color: const Color(0xFFd97706), borderRadius: BorderRadius.circular(3)))),
                     ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHoursDistribution(AppRiverpod provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFfde68a), width: 1.5)),
      child: Row(
        children: [
          _buildRingSummary(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('توزيع ساعاتك التطوعية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                const SizedBox(height: 10),
                _buildDistBar('قراءة', 15, const Color(0xFF10b981), 0.6),
                _buildDistBar('دعم نفسي', 12, const Color(0xFF6366f1), 0.48),
                _buildDistBar('ترفيه', 11, const Color(0xFFf59e0b), 0.44),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistBar(String label, int val, Color color, double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('$val س', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: const Color(0xFFfef3c7), borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(widthFactor: width, child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 55, child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748b)), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildRingSummary() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircularProgressIndicator(value: 0.76, strokeWidth: 6, backgroundColor: Color(0xFFfef3c7), color: Color(0xFFd97706)),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('٧٦٪', style: TextStyle(color: Color(0xFF92400e), fontSize: 14, fontWeight: FontWeight.bold)),
              Text('الهدف', style: TextStyle(color: Color(0xFFb45309), fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

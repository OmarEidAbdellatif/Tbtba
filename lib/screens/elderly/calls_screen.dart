import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import 'package:permission_handler/permission_handler.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _rippleController;
  late AnimationController _ringController;
  late AnimationController _waveController;
  late AnimationController _floatController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _rippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _ringController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750))
      ..repeat();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _rippleController.dispose();
    _ringController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    return Stack(
      children: [
        Column(
          children: [
            _buildHero(provider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    if (provider.isIncomingCall) _buildIncomingCall(provider),
                    if (provider.isIncomingCall) const SizedBox(height: 12),
                    _buildFamilyGrid(provider),
                    const SizedBox(height: 12),
                    _buildVoiceMessages(provider),
                    const SizedBox(height: 12),
                    _buildRecentCalls(),
                    const SizedBox(height: 100), // Space for recording button
                  ],
                ),
              ),
            ),
          ],
        ),
        // Recording Button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildRecordingButton(provider),
        ),
      ],
    );
  }

  Widget _buildRecordingButton(AppRiverpod provider) {
    return Center(
      child: GestureDetector(
        onTap: () => _showRecordDialog(provider),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFc084fc)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 20, spreadRadius: 4,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('اضغط لتسجيل رسالة للأسرة 🎤',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDialog(AppRiverpod provider) {
    bool isRecording = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎤 إرسال رسالة صوتية',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  isRecording ? 'جاري التسجيل...' : 'اضغط زر التسجيل للبدء',
                  style: TextStyle(
                    color: isRecording ? const Color(0xFFef4444) : const Color(0xFF94a3b8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => setS(() => isRecording = !isRecording),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isRecording
                            ? [const Color(0xFFef4444), const Color(0xFFf97316)]
                            : [const Color(0xFF6C63FF), const Color(0xFFc084fc)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? const Color(0xFFef4444) : const Color(0xFF6C63FF)).withOpacity(0.4),
                          blurRadius: 20, spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic,
                      color: Colors.white, size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          provider.sendVoiceMessageFromResident('رسالة من الجد — أنا بخير وبشوقكم');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال رسالتك الصوتية للأسرة 🎤❤️'),
                              backgroundColor: Color(0xFF6C63FF),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('إرسال ✨', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider) {
    int availableCount = provider.familyMembers.where((m) => m.isAvailable).length;
    int busyCount = provider.familyMembers.length - availableCount;
    int voiceMsgCount = provider.voiceMessages.length;
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0533),
                Color(0xFF3730a3),
                Color(0xFF0f3460),
                Color(0xFF6C63FF)
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildBlob(180, const Color(0xFF6C63FF), -50, -50, 7),
              _buildBlob(130, const Color(0xFFf472b6), -35, 30, 9),
              _buildBlob(80, const Color(0xFF0ea5e9), 80, -10, 6),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 22, top: 4, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          const Text('📞 الأسرة والتواصل',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$availableCount متاحين الآن',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 18)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 12, bottom: 24),
                      child: Row(
                        children: [
                          _buildHeroChip(
                              '● $availableCount', 'متاح', 0, const Color(0xFF4ade80), provider),
                          const SizedBox(width: 8),
                          _buildHeroChip('● $busyCount', 'مشغول', 1, Colors.white, provider),
                          const SizedBox(width: 8),
                          _buildHeroChip('🎙️ $voiceMsgCount', 'رسائل', 2, Colors.white, provider),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlob(
      double size, Color color, double right, double top, double duration) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value * 2 * pi;
        final x = sin(t * (duration / 7)) * 10;
        final y = cos(t * (duration / 7)) * 12;
        return Positioned(
          right: right + x,
          top: top + y,
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withOpacity(0.4))),
        );
      },
    );
  }

  Widget _buildHeroChip(
      String value, String label, int index, Color valueColor, AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return Expanded(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.6, end: 1),
        duration: Duration(milliseconds: 450 + (index * 120)),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(hc ? 0.08 : 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(hc ? 0.05 : 0.1))),
          child: Column(children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(hc ? 0.7 : 0.9), fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildIncomingCall(AppRiverpod provider) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF059669),
                  Color(0xFF10b981),
                  Color(0xFF34d399)
                ]),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF10b981).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 6))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1)))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _rippleController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          1 + (_rippleController.value * 1.4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white.withOpacity(
                                                    0.5 *
                                                        (1 -
                                                            _rippleController
                                                                .value)),
                                                width: 2)),
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) =>
                                      Transform.translate(
                                          offset: Offset(
                                              0, -4 * _floatController.value),
                                          child: child),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.25)),
                                    child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('سا',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500)),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AnimatedBuilder(
                                  animation: _ringController,
                                  builder: (context, child) {
                                    final shake = sin(
                                            _ringController.value * pi * 4) *
                                        (sin(_ringController.value * pi * 2) >
                                                0.5
                                            ? 14
                                            : -14);
                                    return Transform.rotate(
                                        angle: shake * pi / 180, child: child);
                                  },
                                  child: const Text('📲 بتتصل بك الآن...',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 4),
                                const Flexible(
                                  child: Text('سارة',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 4),
                                const Flexible(
                                  child: Text('مكالمة فيديو واردة',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _handleCallAction(provider, 'accept'),
                                child: AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) => Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: const Color(0xFF4ade80)
                                                  .withOpacity(0.5 + (_glowController.value * 0.5)),
                                              blurRadius: 10 + (_glowController.value * 10),
                                              spreadRadius: _glowController.value * 5)
                                        ]),
                                    child: const Icon(Icons.check,
                                        color: Color(0xFF059669), size: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => provider.rejectCall(),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.25)),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildWaveBar(4, 0),
                          const SizedBox(width: 3),
                          _buildWaveBar(9, 1),
                          const SizedBox(width: 3),
                          _buildWaveBar(14, 2),
                          const SizedBox(width: 3),
                          _buildWaveBar(9, 3),
                          const SizedBox(width: 3),
                          _buildWaveBar(4, 4),
                          const SizedBox(width: 8),
                          Text('مكالمة واردة',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveBar(double height, int index) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final delay = index * 0.1;
        final t = (_waveController.value + delay) % 1;
        final scale = 1 + (sin(t * pi * 2) * 0.8);
        return Transform.scale(
          scaleY: scale,
          child: Container(
              width: 3,
              height: height,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2))),
        );
      },
    );
  }

  Widget _buildFamilyGrid(AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeText = provider.fontScaleFactor >= 1.25;
        final cardWidth = isLargeText 
            ? constraints.maxWidth 
            : ((constraints.maxWidth - 46) / 2).floorToDouble();
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: hc ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(hc ? 0.2 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Color(0xFF6C63FF), size: 24),
                    const SizedBox(width: 8),
                    const Text('اتصل بالأسرة',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF))),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    for (int i = 0; i < provider.familyMembers.length; i += (isLargeText ? 1 : 2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            if (!isLargeText && i + 1 < provider.familyMembers.length) ...[
                              Expanded(
                                child: _buildPersonCard(
                                  provider.familyMembers[i + 1].name,
                                  provider.familyMembers[i + 1].relation,
                                  provider.familyMembers[i + 1].initials,
                                  provider.familyMembers[i + 1].isAvailable,
                                  [
                                    const [Color(0xFFf472b6), Color(0xFFdb2777)],
                                    const [Color(0xFF34d399), Color(0xFF059669)],
                                    const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                                    const [Color(0xFFfbbf24), Color(0xFFd97706)]
                                  ][(i + 1) % 4],
                                  i + 1,
                                  provider,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (!isLargeText) ...[
                              Expanded(child: const SizedBox()), // Empty slot for balance
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: _buildPersonCard(
                                provider.familyMembers[i].name,
                                provider.familyMembers[i].relation,
                                provider.familyMembers[i].initials,
                                provider.familyMembers[i].isAvailable,
                                [
                                  const [Color(0xFFf472b6), Color(0xFFdb2777)],
                                  const [Color(0xFF34d399), Color(0xFF059669)],
                                  const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                                  const [Color(0xFFfbbf24), Color(0xFFd97706)]
                                ][i % 4],
                                i,
                                provider,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonCard(String name, String relation, String initials,
      bool isOnline, List<Color> gradient, int delay, AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child)),
      child: Opacity(
        opacity: isOnline ? 1 : 0.65,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: hc ? const Color(0xFF252525) : const Color(0xFFf5f3ff),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: hc ? const Color(0xFF444444) : const Color(0xFFede9fe), width: 1.5)),
          child: Stack(
            children: [
              if (isOnline)
                Positioned(
                  top: 11,
                  left: 11,
                  child: AnimatedBuilder(
                    animation: _bgController,
                    builder: (context, child) => Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4ade80),
                          border: Border.all(
                          color: hc ? const Color(0xFF1E1E1E) : const Color(0xFFf5f3ff), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF4ade80).withOpacity(0.7),
                                blurRadius: 7)
                          ]),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 11,
                  left: 11,
                  child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFd1d5db),
                          border: Border.all(
                              color: hc ? const Color(0xFF1E1E1E) : const Color(0xFFf5f3ff), width: 2.5))),
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) => Transform.translate(
                          offset: Offset(
                              0, isOnline ? -4 * _floatController.value : 0),
                          child: child),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradient),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 14,
                                  offset: Offset(0, 4))
                            ]),
                        child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hc ? Colors.white : const Color(0xFF1f2937))),
                    const SizedBox(height: 4),
                    Text(relation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, color: hc ? Colors.white70 : const Color(0xFF6b7280), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleCallAction(provider, 'video', name: name, initials: initials),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isOnline
                                    ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)])
                                    : null,
                                color: isOnline ? null : const Color(0xFFede9fe),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam,
                                        color: isOnline ? Colors.white : const Color(0xFF6C63FF),
                                        size: 13),
                                    const SizedBox(width: 4),
                                    Text('فيديو',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isOnline ? Colors.white : const Color(0xFF6C63FF))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleCallAction(provider, 'audio', name: name, initials: initials),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xFFede9fe)
                                    : const Color(0xFFede9fe).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone,
                                        color: const Color(0xFF6C63FF).withOpacity(isOnline ? 1 : 0.5),
                                        size: 13),
                                    const SizedBox(width: 4),
                                    Text('صوت',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF6C63FF).withOpacity(isOnline ? 1 : 0.5))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildVoiceMessages(AppRiverpod provider) {
    if (provider.voiceMessages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFede9fe), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.scaleDown,
                    child: Text('🎙️ رسائل صوتية من الأسرة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...provider.voiceMessages.asMap().entries.map((entry) {
              final index = entry.key;
              final msg = entry.value;
              final sender = provider.familyMembers.firstWhere(
                  (m) => m.id == msg.senderId,
                  orElse: () => provider.familyMembers.first);
              final gradients = [
                const [Color(0xFFf472b6), Color(0xFFdb2777)],
                const [Color(0xFF34d399), Color(0xFF059669)],
                const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                const [Color(0xFFfbbf24), Color(0xFFd97706)],
              ];
              // Using sender order mapped to a gradient or just by msg index
              final pGradient = gradients[index % gradients.length];
              return Column(
                children: [
                  if (index > 0) const Divider(color: Color(0xFFf5f3ff)),
                  _buildVoiceMessageRow(provider, msg, sender, pGradient)
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceMessageRow(AppRiverpod provider, VoiceMessage msg,
      FamilyMember sender, List<Color> gradient) {
    bool isPlaying = msg.isPlaying;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              provider.toggleVoiceMessage(msg.id);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isPlaying
                          ? const [Color(0xFF6C63FF), Color(0xFFA78BFA)]
                          : const [Color(0xFFf472b6), Color(0xFFc084fc)]),
                  shape: BoxShape.circle),
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isPlaying
                ? Row(
                    children: [
                      _buildVoiceWave(4, 0, const Color(0xFFc4b5fd)),
                      const SizedBox(width: 2),
                      _buildVoiceWave(9, 1, const Color(0xFFc4b5fd)),
                      const SizedBox(width: 2),
                      _buildVoiceWave(13, 2, const Color(0xFFc4b5fd)),
                      const SizedBox(width: 2),
                      _buildVoiceWave(7, 3, const Color(0xFFc4b5fd)),
                      const SizedBox(width: 2),
                      _buildVoiceWave(10, 4, const Color(0xFFc4b5fd)),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                          width: 3,
                          height: 6,
                          decoration: BoxDecoration(
                              color: const Color(0xFFc4b5fd),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(
                          width: 3,
                          height: 11,
                          decoration: BoxDecoration(
                              color: const Color(0xFFa78bfa),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(
                          width: 3,
                          height: 5,
                          decoration: BoxDecoration(
                              color: const Color(0xFFc4b5fd),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(
                          width: 3,
                          height: 9,
                          decoration: BoxDecoration(
                              color: const Color(0xFF7c3aed),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(
                          width: 3,
                          height: 7,
                          decoration: BoxDecoration(
                              color: const Color(0xFFc4b5fd),
                              borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(msg.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0f172a))),
                const SizedBox(height: 4),
                Text(msg.timeDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF94a3b8))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle),
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(sender.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceWave(double height, int index, Color color) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final delay = index * 0.133;
        final t = (_waveController.value + delay) % 1;
        final scale = 1 + (sin(t * pi * 2) * 0.8);
        return Transform.scale(
          scaleY: scale,
          child: Container(
              width: 3,
              height: height,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
        );
      },
    );
  }

  Widget _buildRecentCalls() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFede9fe), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📋 آخر المكالمات',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF))),
              ],
            ),
            const SizedBox(height: 10),
            _buildRecentCallRow(
                'أم أحمد',
                'فيديو · ١٢ دقيقة · أمس ٦:٣٠ م',
                'أم',
                const [Color(0xFFf472b6), Color(0xFFdb2777)],
                'واردة',
                const Color(0xFFd1fae5),
                const Color(0xFF065f46)),
            const Divider(color: Color(0xFFf5f3ff)),
            _buildRecentCallRow(
                'أحمد',
                'صوت · ٥ دقائق · أمس ٢:١٥ م',
                'أح',
                const [Color(0xFF818cf8), Color(0xFF4f46e5)],
                'صادرة',
                const Color(0xFFede9fe),
                const Color(0xFF4c1d95)),
            const Divider(color: Color(0xFFf5f3ff)),
            _buildRecentCallRow(
                'سارة',
                'فيديو · الأحد ١١:٠٠ ص',
                'سا',
                const [Color(0xFF34d399), Color(0xFF059669)],
                'فائتة',
                const Color(0xFFfee2e2),
                const Color(0xFF7f1d1d)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCallRow(String name, String detail, String initials,
      List<Color> gradient, String badge, Color badgeBg, Color badgeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: badgeBg, borderRadius: BorderRadius.circular(12)),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: badgeText)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0f172a))),
                const SizedBox(height: 4),
                Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF94a3b8), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle),
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void _handleCallAction(AppRiverpod provider, String type, {String? name, String? initials}) async {
    // Permission Request Simulation
    bool granted = await _requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب الموافقة على إذن الكاميرا والميكروفون لإجراء المكالمة ⚠️'),
            backgroundColor: Color(0xFFef4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (type == 'accept') {
      provider.acceptCall();
    } else if (type == 'video' || type == 'audio') {
      provider.startVideoCall(name!, initials!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري الاتصال ب— $name...'),
            backgroundColor: const Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermissions() async {
    // Request Camera and Microphone permissions from the system
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted = statuses[Permission.camera] == PermissionStatus.granted;
    bool microGranted = statuses[Permission.microphone] == PermissionStatus.granted;

    return cameraGranted && microGranted;
  }
}

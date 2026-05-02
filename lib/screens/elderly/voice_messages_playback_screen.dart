import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

// شاشة استماع الرسائل الصوتية - مخصصة للمسنين لتسهيل سماع رسائل أحبائهم
class VoiceMessagesPlaybackScreen extends ConsumerStatefulWidget {
  const VoiceMessagesPlaybackScreen({super.key});

  @override
  ConsumerState<VoiceMessagesPlaybackScreen> createState() => _VoiceMessagesPlaybackScreenState();
}

class _VoiceMessagesPlaybackScreenState extends ConsumerState<VoiceMessagesPlaybackScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController; // متحكم لحركات النبض البصري عند تشغيل الصوت

  @override
  void initState() {
    super.initState();
    // تهيئة الأنيميشن ليعطي إحساساً بالحيوية عند استماع الرسائل
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    final messages = provider.voiceMessages; // جلب الرسائل الصوتية من المزود

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a), // خلفية ليلية أنيقة لتقليل إجهاد العين
      body: Stack(
        children: [
          // إضاءة خلفية خفيفة (Glow) لإعطاء عمق جمالي للتصميم
          Positioned(
            top: -100,
            left: -100,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(color: const Color(0xFF6366f1).withOpacity(0.15), shape: BoxShape.circle)),
          ),
          
          Column(
            children: [
              _buildHeader(context), // العنوان والوصف العلوي
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState() // حالة عدم وجود رسائل
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageCard(msg, index); // كرت الرسالة الفردي
                        },
                      ),
              ),
            ],
          ),
          
          // زر الرجوع للرئيسية - مصمم بحجم كبير لسهولة الضغط
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 70,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 28),
                    SizedBox(width: 12),
                    Text('رجوع للرئيسية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('🎙️ رسائل الأسرة', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('استمع لأحدث الأخبار من أحبائك بصوتهم', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.voice_over_off_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          const Text('لا توجد رسائل جديدة حالياً', style: TextStyle(color: Color(0xFF64748b), fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildMessageCard(VoiceMessage msg, int index) {
    final bool isUnread = msg.isUnread;
    final bool isPlaying = msg.isPlaying;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isPlaying 
            ? const LinearGradient(colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)]) 
            : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isPlaying ? Colors.transparent : (isUnread ? const Color(0xFF6366f1).withOpacity(0.5) : Colors.white10), width: 2),
        boxShadow: isPlaying ? [BoxShadow(color: const Color(0xFF6366f1).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))] : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (isUnread)
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFf43f5e), shape: BoxShape.circle)),
              const Spacer(),
              Text(msg.timeDescription, style: TextStyle(color: isPlaying ? Colors.white70 : const Color(0xFF64748b), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPlayButton(msg),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(msg.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(isPlaying ? 'جارِ التشغيل الآن...' : (isUnread ? 'رسالة جديدة ✨' : 'تم الاستماع إليها'), 
                        style: TextStyle(color: isPlaying ? Colors.white.withOpacity(0.8) : (isUnread ? const Color(0xFF38bdf8) : const Color(0xFF94a3b8)), fontSize: 14, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ],
          ),
          if (isPlaying) ...[
            const SizedBox(height: 24),
            _buildWaveform(),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayButton(VoiceMessage msg) {
    bool isPlaying = msg.isPlaying;
    return GestureDetector(
      onTap: () => ref.read(appRiverpod).toggleVoiceMessage(msg.id),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isPlaying ? Colors.white : const Color(0xFF6366f1),
              shape: BoxShape.circle,
              boxShadow: isPlaying ? [
                BoxShadow(color: Colors.white.withOpacity(0.3 * _pulseController.value), spreadRadius: 10 * _pulseController.value, blurRadius: 15)
              ] : [],
            ),
            child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: isPlaying ? const Color(0xFF6366f1) : Colors.white, size: 48),
          );
        },
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final double h = 5 + (20 * (0.5 + 0.5 * (index % 3 == 0 ? _pulseController.value : (index % 2 == 0 ? 1 - _pulseController.value : 0.7))));
            return Container(
              width: 4,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(2)),
            );
          },
        );
      }),
    );
  }
}

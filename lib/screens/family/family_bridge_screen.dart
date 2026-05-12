import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import '../../widgets/taptaba_scaffold.dart';

// شاشة "جسر العائلة" - تتيح للأقارب التواصل مع المقيم عبر الصور والرسائل الصوتية
class FamilyBridgeScreen extends ConsumerStatefulWidget {
  const FamilyBridgeScreen({super.key});

  @override
  ConsumerState<FamilyBridgeScreen> createState() => _FamilyBridgeScreenState();
}

class _FamilyBridgeScreenState extends ConsumerState<FamilyBridgeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotationController;
  bool _isUploading = false; // حالة الرفع الحالية
  double _uploadProgress = 0.0; // نسبة تقدم الرفع
  String _uploadStatus = ''; // نص حالة الرفع
  bool _isRecording = false; // هل يجري تسجيل صوتي الآن؟
  int _recordDuration = 0; // مدة التسجيل بالثواني
  Timer? _timer; // مؤقت لحساب وقت التسجيل

  @override
  void initState() {
    super.initState();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // بدء عملية التسجيل الصوتي (محاكاة)
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordDuration++);
    });
  }

  // إيقاف التسجيل وفتح نافذة التأكيد
  void _stopRecording() {
    _timer?.cancel();
    setState(() => _isRecording = false);
    _showConfirmUpload('تسجيل صوتي');
  }

  // محاكاة عملية الرفع مع تحديث شريط التقدم
  void _simulateUpload(String title, String type) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'جاري رفع $type...';
    });

    // محاكاة تأخير الرفع
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = i / 10.0;
      });
    }

    setState(() {
      _uploadStatus = 'تم الرفع بنجاح! 🎉';
    });

    await Future.delayed(const Duration(seconds: 1));

    // إنشاء كائن ذكرى جديدة وإضافته للمزود
    final newMoment = MemoryMoment(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      residentId: 'r1',
      residentName: 'محمود', // إضافة المعامل المطلوب لاسم المقيم
      imageUrl: type == 'صورة'
          ? 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=400'
          : 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400',
      activityTitle: title,
      date: 'الآن',
      appreciations: 0,
    );

    ref.read(appRiverpod).addMemoryMoment(newMoment);

    setState(() {
      _isUploading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تمت إضافة ذكرى جديدة للحائط ❤️'),
            backgroundColor: Color(0xFF10b981)),
      );
    }
  }

  // إظهار نافذة تأكيد قبل الرفع الفعلي
  void _showConfirmUpload(String type) {
    String title = type == 'صورة' ? 'صورة عائلية جديدة' : 'رسالة صوتية للأب';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('تأكيد الإرسال',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e293b))),
            const SizedBox(height: 8),
            Text('هل تريد إرسال ال$type الآن إلى الحاج محمود؟',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748b))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _simulateUpload(title, type);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFea580c),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('تأكيد وإرسال',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFe2e8f0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('إلغاء',
                        style: TextStyle(color: Color(0xFF64748b))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    final moments = provider.memoryMoments
        .where((m) => m.residentId == 'r1')
        .toList();

    return TaptabaScaffold(
      title: 'جسر العائلة',
      overrideRole: 'عائلة',
      hideAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildUploadActions(), // أزرار الرفع (صوت وصورة)
              Expanded(child: _buildGallery(moments)), // معرض الذكريات المرفوعة
            ],
          ),
          if (_isUploading) _buildUploadOverlay(), // واجهة التحميل عند الرفع
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFea580c),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(child: _buildAnimatedBackground()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('جسر العائلة ✨',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _rotationController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Orb 1 - Top Right
            Positioned(
              top: -50 + (30 * _floatController.value),
              right: -40 + (20 * _floatController.value),
              child: _buildRealisticOrb(180, [
                const Color(0xFFfb923c).withOpacity(0.35),
                const Color(0xFFea580c).withOpacity(0.15),
                Colors.transparent,
              ]),
            ),
            // Orb 2 - Bottom Left
            Positioned(
              bottom: -30 + (40 * (1 - _floatController.value)),
              left: -40 + (25 * _floatController.value),
              child: _buildRealisticOrb(160, [
                const Color(0xFFfdba74).withOpacity(0.3),
                const Color(0xFFf97316).withOpacity(0.1),
                Colors.transparent,
              ]),
            ),
            // Orb 3 - Center
            Positioned(
              top: 40,
              left: 100,
              child: _buildRealisticOrb(70, [
                const Color(0xFFfb923c).withOpacity(0.1),
                Colors.transparent,
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRealisticOrb(double size, List<Color> baseColors) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: baseColors,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            RotationTransition(
              turns: _rotationController,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: size * 0.1,
              left: size * 0.15,
              child: Container(
                width: size * 0.4,
                height: size * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: const Color(0xFFea580c),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b))),
      ],
    );
  }

  // بناء أزرار التفاعل السريع للرفع
  Widget _buildUploadActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFf1f5f9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSectionHeader('شارك لحظة جديدة'),
          const SizedBox(height: 16),
          Row(
            children: [
              _uploadBtn(
                  Icons.mic_rounded,
                  'رسالة صوتية',
                  const Color(0xFFa855f7),
                  _isRecording ? _stopRecording : _startRecording,
                  isRecording: _isRecording),
              const SizedBox(width: 12),
              _uploadBtn(Icons.image_rounded, 'صورة جديدة',
                  const Color(0xFF0ea5e9), () => _showConfirmUpload('صورة')),
            ],
          ),
          // عرض عداد الوقت عند التسجيل الصوتي
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('جاري التسجيل...',
                      style:
                          TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(
                      '${(_recordDuration ~/ 60).toString().padLeft(2, '0')}:${(_recordDuration % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  const Icon(Icons.circle, color: Colors.red, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // بناء زر الرفع الفردي بتصميم عصري
  Widget _uploadBtn(IconData icon, String label, Color color, VoidCallback onTap,
      {bool isRecording = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isRecording
                ? Colors.red.withOpacity(0.1)
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isRecording ? Colors.red : color.withOpacity(0.3),
                width: 1.5),
          ),
          child: Column(
            children: [
              Icon(isRecording ? Icons.stop_circle_rounded : icon,
                  color: isRecording ? Colors.red : color, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: isRecording ? Colors.red : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // بناء معرض الصور والرسائل المرفوعة (Grid View)
  Widget _buildGallery(List<MemoryMoment> moments) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: moments.length,
      itemBuilder: (context, i) {
        final m = moments[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: const Color(0xFFf1f5f9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(m.imageUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(m.activityTitle,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1e293b))),
                    Text(m.date,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF94a3b8))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // واجهة التغطية (Overlay) التي تظهر أثناء عملية الرفع
  Widget _buildUploadOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _uploadProgress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFf1f5f9),
                  color: const Color(0xFFea580c),
                ),
              ),
              const SizedBox(height: 24),
              Text(_uploadStatus,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              const SizedBox(height: 8),
              Text('${(_uploadProgress * 100).toInt()}% اكتمل',
                  style: const TextStyle(color: Color(0xFF64748b))),
            ],
          ),
        ),
      ),
    );
  }
}

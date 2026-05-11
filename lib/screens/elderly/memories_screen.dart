import 'dart:math';
import 'dart:io'; // للتعامل مع ملفات الصور المختارة من الاستوديو
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'voice_messages_playback_screen.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _heartController;
  late AnimationController _glowController;
  late AnimationController _waveController;
  late AnimationController _noteController;
  late AnimationController _shimmerController;

  int selectedCategory = 0;
  final categories = [
    'الكل',
    '🏠 المسكن',
    '👨‍👩‍👧 أسرة',
    '🌊 رحلات',
    '🎬 فيديو',
    '🎉 مناسبات',
    '🖼️ الاستوديو'
  ];

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _heartController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750))
      ..repeat();
    _noteController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    _heartController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _noteController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHero(provider),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
              child: Column(
                children: [
                  _buildCategoryTabs(),
                  const SizedBox(height: 12),
                  _buildFeaturedCard(),
                  const SizedBox(height: 12),
                  _buildVoiceMessage(provider),
                  const SizedBox(height: 12),
                  _buildPhotoGrid(provider),
                  const SizedBox(height: 12),
                  _buildFamilyNote(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(AppRiverpod provider) {
    int photoCount =
        provider.memoriesList.where((m) => m.type == 'image').length +
            provider.memoryMoments.length;
    int videoCount =
        provider.memoriesList.where((m) => m.type == 'video').length;
    int voiceCount = provider.voiceMessages.length;
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
              _buildBlob(80, const Color(0xFFc084fc), 80, -10, 6),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 28, top: 4, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('ذكرياتي الحلوة',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          Text('من الأسرة بكل الحب 💜',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 18)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 12, bottom: 24),
                      child: Row(
                        children: [
                          _buildHeroChip('$photoCount', 'صورة', 0),
                          const SizedBox(width: 8),
                          _buildHeroChip('🎬 $videoCount', 'فيديو', 1),
                          const SizedBox(width: 8),
                          _buildHeroChip('🎙️ $voiceCount', 'رسالة', 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
          left: right + x,
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

  Widget _buildHeroChip(String value, String label, int index) {
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
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)])
                    : null,
                color: isActive
                    ? null
                    : (hc ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color:
                        hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
                    width: 1.5),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : (hc
                            ? const Color(0xFF9FA8DA)
                            : const Color(0xFF7c3aed)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard() {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatController.value),
          child: Container(
            decoration: BoxDecoration(
              color: hc ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: hc ? const Color(0xFF333333) : const Color(0xFFddd6fe),
                  width: 2),
              boxShadow: [
                BoxShadow(
                    color:
                        const Color(0xFF6C63FF).withOpacity(hc ? 0.25 : 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 6)),
                BoxShadow(
                    color: const Color(0xFFa78bfa).withOpacity(
                        hc ? 0.2 : (0.35 + (_glowController.value * 0.45))),
                    blurRadius: 12 + (_glowController.value * 12),
                    spreadRadius: _glowController.value * 6),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFFddd6fe),
                        Color(0xFFc4b5fd),
                        Color(0xFFf9a8d4)
                      ]),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xFF6C63FF).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Text('🌟 ذكرى اليوم',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 16,
                                      offset: Offset(0, 4))
                                ]),
                            child: const Icon(Icons.play_arrow,
                                color: Color(0xFF6C63FF), size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('عيد ميلاد خالد ٢٠٢٤',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: hc
                                          ? Colors.white
                                          : const Color(0xFF0f172a))),
                              const SizedBox(height: 6),
                              Text('أرسلته سارة · ٥ مارس ٢٠٢٤',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: hc
                                          ? Colors.white70
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedBuilder(
                          animation: _heartController,
                          builder: (context, child) {
                            final t = _heartController.value * 2 * pi;
                            final scale =
                                1 + (sin(t) * 0.12) + (sin(t * 2) * 0.08);
                            return Transform.scale(scale: scale, child: child);
                          },
                          child:
                              const Text('💜', style: TextStyle(fontSize: 22)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceMessage(AppRiverpod provider) {
    final unreadCount = provider.voiceMessages.where((v) => v.isUnread).length;
    final latestMsg =
        provider.voiceMessages.isNotEmpty ? provider.voiceMessages.first : null;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const VoiceMessagesPlaybackScreen())),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF6C63FF),
            Color(0xFFA78BFA),
            Color(0xFFc084fc)
          ]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(
                  right: -15,
                  top: -15,
                  child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1)))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  latestMsg != null
                                      ? latestMsg.title
                                      : 'رسائل الأسرة',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  unreadCount > 0
                                      ? 'لديك $unreadCount رسائل جديدة ✨'
                                      : 'استمع لرسائل أحبائك',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 10),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFf43f5e),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('$unreadCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
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
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(2))),
        );
      },
    );
  }

  Widget _buildPhotoGrid(AppRiverpod provider) {
    final activeCategory = categories[selectedCategory];
    List<dynamic> items = provider.getMemoriesByCategory(activeCategory);

    if (activeCategory == '🖼️ الاستوديو') {
      items = provider.deviceGalleryImages;
    }

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('صندوق الذكريات',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0f172a))),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextButton.icon(
                onPressed: () => provider.pickMemoryImage(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined,
                    color: Color(0xFF6C63FF), size: 20),
                label: const Text('إضافة صور',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final mem = entry.value;

              String type = 'image';
              String? url;
              String? label;
              String? assetPath;
              AssetEntity? asset;

              if (mem is MemoryItem) {
                type = mem.type;
                label = mem.title;
                assetPath = mem.assetPath;
              } else if (mem is MemoryMoment) {
                type = 'image';
                url = mem.imageUrl;
                label = mem.activityTitle;
              } else if (mem is String) {
                type = 'image';
                url = mem;
              } else if (mem is AssetEntity) {
                type = 'image';
                asset = mem;
              }

              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 3,
                height: (MediaQuery.of(context).size.width - 44) / 3,
                child: _buildGridCell(provider, index, type, url, label, asset,
                    assetPath: assetPath),
              );
            }).toList(),
            if (items.isNotEmpty)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 3,
                height: (MediaQuery.of(context).size.width - 44) / 3,
                child: _buildMoreCell(provider),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCell(AppRiverpod provider, int index, String type,
      String? url, String? label, AssetEntity? asset,
      {String? assetPath}) {
    bool hc = provider.isHighContrast;
    final gradients = [
      const [Color(0xFFddd6fe), Color(0xFFc4b5fd)],
      const [Color(0xFFfce7f3), Color(0xFFf9a8d4)],
      const [Color(0xFFdbeafe), Color(0xFF93c5fd)],
      const [Color(0xFFd1fae5), Color(0xFF6ee7b7)],
      const [Color(0xFFfef3c7), Color(0xFFfcd34d)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: (url == null && asset == null)
            ? LinearGradient(colors: gradient)
            : null,
        image: url != null
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : (assetPath != null && assetPath.isNotEmpty)
                ? (assetPath.startsWith('assets/')
                    ? DecorationImage(
                        image: AssetImage(assetPath), fit: BoxFit.cover)
                    : DecorationImage(
                        image: FileImage(File(assetPath)), fit: BoxFit.cover))
                : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
            width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            if (asset != null)
              Positioned.fill(
                child: AssetEntityImage(
                  asset,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(200),
                  fit: BoxFit.cover,
                ),
              ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(url != null || asset != null ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(14))),
            Center(
              child: type == 'video'
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow,
                          color: Color(0xFFec4899), size: 14),
                    )
                  : (url == null && asset == null
                      ? Icon(Icons.image,
                          color: Colors.white.withOpacity(0.6), size: 20)
                      : const SizedBox.shrink()),
            ),
            if (label != null && (url != null || asset != null))
              Positioned(
                bottom: 4,
                right: 4,
                left: 4,
                child: Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCell(AppRiverpod provider) {
    bool hc = provider.isHighContrast;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: hc ? const Color(0xFF333333) : const Color(0xFFede9fe),
            width: 1.5),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('+٤١',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 1),
          Text('المزيد', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFamilyNote() {
    bool hc = ref.watch(appRiverpod).isHighContrast;
    return AnimatedBuilder(
      animation: _noteController,
      builder: (context, child) {
        final opacity = _noteController.value;
        final offset = (1 - _noteController.value) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: hc ? const Color(0xFF1E1E1E) : const Color(0xFFfffbeb),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: hc ? const Color(0xFFd97706) : const Color(0xFFfde68a),
              width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📝', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text('رسالة مكتوبة من الأسرة',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hc
                            ? const Color(0xFFfbbf24)
                            : const Color(0xFF92400e))),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '"بنحبك يا بابا ونشتاق إليك كتير — الجمعة الجاية إن شاء الله هنيجي 🌸"',
              style: TextStyle(
                  fontSize: 18,
                  color: hc ? Colors.white : const Color(0xFF78350f),
                  height: 1.7,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text('أم أحمد وسارة وأحمد · اليوم ٨:٠٠ ص',
                style: TextStyle(
                    fontSize: 14,
                    color: hc ? Colors.white54 : const Color(0xFFb45309),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

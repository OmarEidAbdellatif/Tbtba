import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';

class SpecialistHomeView extends ConsumerWidget {
  final List<Animation<double>> fadeAnimations;
  final AnimationController floatController;
  final AnimationController shimmerController;
  final AnimationController popController;
  final void Function(int) onNavigate;

  const SpecialistHomeView({
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

    return Column(
      children: [
        _buildFilterStrip(provider),
        _buildFloorTabs(provider),
        Expanded(
          child: Column(
            children: [
              _buildMapSection(context, ref, provider),
              _buildStatsStrip(provider),
              Expanded(child: _buildNeedsList(provider)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterStrip(AppRiverpod provider) {
    final filters = [
      {'label': 'الكل', 'count': '١٣', 'color': const Color(0xFF9a3412), 'bg': const Color(0xFFfff7ed)},
      {'label': 'نفسي', 'count': '٦', 'color': const Color(0xFF4c1d95), 'bg': const Color(0xFFede9fe)},
      {'label': 'أسري', 'count': '٤', 'color': const Color(0xFF92400e), 'bg': const Color(0xFFfef3c7)},
      {'label': 'مالي', 'count': '٢', 'color': const Color(0xFF7f1d1d), 'bg': const Color(0xFFfee2e2)},
      {'label': 'طبي', 'count': '١', 'color': const Color(0xFF065f46), 'bg': const Color(0xFFd1fae5)},
    ];

    return Container(
      height: 50,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: filters.map((f) {
            final String label = f['label'] as String;
            final isAct = provider.selectedSpecialistFilter == label;
            return GestureDetector(
              onTap: () => provider.setSelectedSpecialistFilter(label),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                decoration: BoxDecoration(
                  color: f['bg'] as Color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isAct ? (f['color'] as Color) : Colors.transparent, width: 1.5),
                ),
                child: Text(
                  '${f['label']} (${f['count']})',
                  style: TextStyle(color: f['color'] as Color, fontSize: 10, fontWeight: isAct ? FontWeight.bold : FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloorTabs(AppRiverpod provider) {
    final floors = ['الطابق الأول', 'الطابق الثاني', 'الطابق الثالث', 'المشترك'];
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFf8fafc),
        border: Border(bottom: BorderSide(color: Color(0xFFe2e8f0))),
      ),
      child: Row(
        children: List.generate(floors.length, (index) {
          final isAct = provider.selectedFloor == index + 1;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setSelectedFloor(index + 1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAct ? Colors.white : Colors.transparent,
                  border: Border(bottom: BorderSide(color: isAct ? const Color(0xFFea580c) : Colors.transparent, width: 2)),
                ),
                child: Text(
                  floors[index],
                  style: TextStyle(color: isAct ? const Color(0xFFea580c) : const Color(0xFF94a3b8), fontSize: 10, fontWeight: isAct ? FontWeight.bold : FontWeight.w500),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, WidgetRef ref, AppRiverpod provider) {
    return Container(
      height: 250,
      color: const Color(0xFFe8f0fe),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
               return GestureDetector(
                 onTapUp: (details) => _handleMapTap(details.localPosition, constraints.biggest, provider),
                 child: CustomPaint(
                   size: constraints.biggest,
                   painter: DetailedFloorMapPainter(
                     needs: provider.filteredSocialNeeds,
                     pulseValue: shimmerController.value,
                     selectedRoom: provider.selectedRoomNumber,
                   ),
                 ),
               );
            }
          ),
          // FAB
          Positioned(
            bottom: 14,
            left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showAddMomentSheet(context, ref, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0ea5e9), Color(0xFF38bdf8)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('بث سعادة📸', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showAddNeedSheet(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('تسجيل احتياج', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Popup Card
          if (provider.selectedRoomNumber != null) _buildPopupCard(provider),
        ],
      ),
    );
  }

  void _showAddMomentSheet(BuildContext context, WidgetRef ref, AppRiverpod provider) {
    final titleCtrl = TextEditingController();
    String? selectedRoom = provider.selectedRoomNumber;
    
    final mockImages = [
      {'title': 'ممارسة الرسم 🎨', 'url': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80&w=400'},
      {'title': 'العناية بالحديقة 🌿', 'url': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&q=80&w=400'},
      {'title': 'جلسة قراءة 📚', 'url': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400'},
      {'title': 'وقت الرياضة 🏃', 'url': 'https://images.unsplash.com/photo-1571019623452-970331006afc?auto=format&fit=crop&q=80&w=400'},
    ];
    int selectedImgIdx = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 24, right: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('بث لحظة سعادة 📸✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
              const Text('شارك عائلات المقيمين أجمل اللحظات اليومية', style: TextStyle(fontSize: 13, color: Color(0xFF64748b))),
              const SizedBox(height: 24),
              const Text('اختر النشاط المُلتقط', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: mockImages.length,
                  itemBuilder: (context, i) {
                    final isSel = selectedImgIdx == i;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedImgIdx = i),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? const Color(0xFF0ea5e9) : Colors.transparent, width: 2),
                          image: DecorationImage(image: NetworkImage(mockImages[i]['url']!), fit: BoxFit.cover),
                        ),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)])),
                          child: Text(mockImages[i]['title']!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('المقيم المستهدف', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFe2e8f0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('غرفة ١٠٣ (الحاج محمود)', style: TextStyle(fontSize: 13, color: Color(0xFF0f172a))),
                    const Icon(Icons.person_outline, color: Color(0xFF94a3b8), size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0ea5e9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: () {
                    ref.read(appRiverpod).addMemoryMoment(MemoryMoment(
                      id: 'm${DateTime.now().millisecondsSinceEpoch}',
                      residentId: 'r1',
                      residentName: 'الحاج محمود',
                      imageUrl: mockImages[selectedImgIdx]['url']!,
                      activityTitle: mockImages[selectedImgIdx]['title']!,
                      date: 'الآن',
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت مشاركة اللحظة مع الأهل بنجاح! 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF0ea5e9)));
                  },
                  child: const Text('بث السعادة للأهل 🤝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showAddNeedSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final roomCtrl = TextEditingController(text: '١٠٣');
    String selectedType = 'نفسي';
    bool isUrgent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFe2e8f0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('تسجيل احتياج جديد 🛡️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
              const Text('أدخل تفاصيل الحالة لتمكين الفريق من التدخل', style: TextStyle(fontSize: 12, color: Color(0xFF64748b))),
              const SizedBox(height: 24),
              _buildLabel('نوع الاحتياج'),
              const SizedBox(height: 8),
              Row(
                children: ['نفسي', 'أسري', 'مالي', 'طبي'].map((t) {
                  final isSel = selectedType == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedType = t),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFfff7ed) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? const Color(0xFFea580c) : const Color(0xFFe2e8f0)),
                        ),
                        child: Center(child: Text(t, style: TextStyle(color: isSel ? const Color(0xFFea580c) : const Color(0xFF64748b), fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal))),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _buildLabel('وصف الحالة'),
              const SizedBox(height: 8),
              TextField(
                controller: titleCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'مثال: يحتاج دعم نفسي بسبب عزلة مؤقتة...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFcbd5e1)),
                  filled: true,
                  fillColor: const Color(0xFFf8fafc),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Switch(
                    value: isUrgent,
                    onChanged: (v) => setModalState(() => isUrgent = v),
                    activeColor: const Color(0xFFea580c),
                  ),
                  const Text('حالة عاجلة؟', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFea580c),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) {
                      ref.read(appRiverpod).addSocialNeed(SocialSpecialistNeed(
                        id: 'n${DateTime.now().millisecondsSinceEpoch}',
                        roomNumber: roomCtrl.text,
                        type: selectedType,
                        label: selectedType.substring(0, 1),
                        isUrgent: isUrgent,
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تسجيل الاحتياج بنجاح ✅', style: TextStyle(fontFamily: 'Cairo'))),
                      );
                    }
                  },
                  child: const Text('حفظ وتسجيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)));
  }

  void _handleMapTap(Offset localPos, Size size, AppRiverpod provider) {
    // Basic mapping: 5 rooms top, 5 rooms bottom
    final roomWidth = (size.width - 60) / 5;
    final roomHeight = (size.height - 40 - 30) / 2; // Subtracting corridor
    
    // Check Top Row
    for (int i = 0; i < 5; i++) {
       final rect = Rect.fromLTWH(10 + i * (roomWidth + 10), 10, roomWidth, roomHeight);
       if (rect.contains(localPos)) {
         provider.setSelectedRoom('١٠${i + 1}');
         return;
       }
    }
    // Check Bottom Row
    for (int i = 0; i < 5; i++) {
       final rect = Rect.fromLTWH(10 + i * (roomWidth + 10), size.height - roomHeight - 10, roomWidth, roomHeight);
       if (rect.contains(localPos)) {
         provider.setSelectedRoom('١٠${i + 6}');
         return;
       }
    }
    // Clicked background or corridor
    provider.setSelectedRoom(null);
  }

  Widget _buildPopupCard(AppRiverpod provider) {
    final room = provider.selectedRoomNumber;
    final roomNeeds = provider.socialNeeds.where((n) => n.roomNumber == room).toList();
    if (roomNeeds.isEmpty) return Container(); // Or show "No Needs"
    
    final need = roomNeeds.first;

    return Positioned(
      top: 30, right: 20,
      child: FadeTransition(
        opacity: popController,
        child: ScaleTransition(
          scale: popController,
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe2e8f0), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => provider.setSelectedRoom(null),
                  child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFFf1f5f9), shape: BoxShape.circle), child: const Center(child: Icon(Icons.close, size: 12, color: Color(0xFF64748b)))),
                ),
                const Text('الحاج محمود سالم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                Text('غرفة $room · ٧٨ سنة', style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: need.isUrgent ? const Color(0xFFfee2e2) : const Color(0xFFfef3c7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${need.type} — ${need.isUrgent ? 'عاجل' : 'متابعة'}', style: TextStyle(color: need.isUrgent ? const Color(0xFF7f1d1d) : const Color(0xFF92400e), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: need.isUrgent ? Colors.red : Colors.amber, shape: BoxShape.circle)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text('يحتاج دعم لتغطية احتياجات شخصية — تم التحقق اليوم', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: Color(0xFF64748b), height: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: GestureDetector(onTap: () => onNavigate(1), child: _buildPopupButton('✏️ تدخّل', isPrimary: true))),
                    const SizedBox(width: 5),
                    Expanded(child: GestureDetector(onTap: () => onNavigate(4), child: _buildPopupButton('📋 ملف', isPrimary: false))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupButton(String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? null : const Color(0xFFfff7ed),
        gradient: isPrimary ? const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]) : null,
        borderRadius: BorderRadius.circular(8),
        border: isPrimary ? null : Border.all(color: const Color(0xFFfed7aa)),
      ),
      child: Center(child: Text(label, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF9a3412), fontSize: 9, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildStatsStrip(AppRiverpod provider) {
    final stats = [
      {'val': '٢', 'lbl': 'مالي', 'col': const Color(0xFFef4444)},
      {'val': '٤', 'lbl': 'أسري', 'col': const Color(0xFFf59e0b)},
      {'val': '٦', 'lbl': 'نفسي', 'col': const Color(0xFF6366f1)},
      {'val': '١', 'lbl': 'طبي', 'col': const Color(0xFF10b981)},
      {'val': '١٣', 'lbl': 'الكل', 'col': const Color(0xFFea580c)},
    ];

    return Container(
      height: 50,
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFf1f5f9)))),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Container(
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFf1f5f9)))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['val'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: s['col'] as Color)),
                Text(s['lbl'] as String, style: const TextStyle(fontSize: 8, color: Color(0xFF94a3b8))),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildNeedsList(AppRiverpod provider) {
    final sortedNeeds = List<SocialSpecialistNeed>.from(provider.filteredSocialNeeds)
      ..sort((a, b) => (b.isUrgent ? 1 : 0).compareTo(a.isUrgent ? 1 : 0));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedNeeds.length + 2, // Header + list
      itemBuilder: (context, index) {
        if (index == 0) return _buildListHeader('عاجل — يحتاج تدخل فوري', const Color(0xFFef4444), isBlink: true);
        if (index == 2) return _buildListHeader('يحتاج متابعة مستمرة', const Color(0xFFf59e0b), isBlink: false);
        
        final needIdx = index > 2 ? index - 2 : index - 1;
        if (needIdx >= sortedNeeds.length) return const SizedBox(height: 80); // padding at end
        
        final need = sortedNeeds[needIdx];
        return _buildNeedRow(need);
      },
    );
  }

  Widget _buildListHeader(String title, Color color, {bool isBlink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF9a3412), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildNeedRow(SocialSpecialistNeed need) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: need.isUrgent ? const Color(0xFFfff5f5) : const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: need.isUrgent ? const Color(0xFFfca5a5) : const Color(0xFFf1f5f9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getBadgeBg(need.type, need.isUrgent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(need.isUrgent ? 'عاجل' : need.type, style: TextStyle(color: _getBadgeFg(need.type, need.isUrgent), fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('المقيم في غرفة ${need.roomNumber} — احتياج ${need.type}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
              Text('غرفة ${need.roomNumber} · تم التحقق مؤخراً', style: const TextStyle(fontSize: 10, color: Color(0xFF64748b))),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تحت المراجعة', style: TextStyle(fontSize: 9, color: Color(0xFF94a3b8))),
                  const SizedBox(width: 4),
                  Icon(Icons.access_time, size: 10, color: const Color(0xFF94a3b8)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: _getIconBg(need.type), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(_getEmoji(need.type), style: const TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 10),
          Container(width: 4, height: 34, decoration: BoxDecoration(color: _getColor(need.type), borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Color _getBadgeBg(String type, bool urgent) {
    if (urgent) return const Color(0xFFfee2e2);
    if (type == 'أسري') return const Color(0xFFfef3c7);
    if (type == 'نفسي') return const Color(0xFFede9fe);
    return const Color(0xFFd1fae5);
  }

  Color _getBadgeFg(String type, bool urgent) {
        if (urgent) return const Color(0xFF7f1d1d);
    if (type == 'أسري') return const Color(0xFF92400e);
    if (type == 'نفسي') return const Color(0xFF4c1d95);
    return const Color(0xFF065f46);
  }

  Color _getIconBg(String type) {
    if (type == 'مالي') return const Color(0xFFfee2e2);
    if (type == 'أسري') return const Color(0xFFfef3c7);
    if (type == 'نفسي') return const Color(0xFFede9fe);
    return const Color(0xFFd1fae5);
  }

  Color _getColor(String type) {
    switch (type) {
      case 'نفسي': return const Color(0xFF6366f1);
      case 'أسري': return const Color(0xFFf59e0b);
      case 'مالي': return const Color(0xFFef4444);
      case 'طبي': return const Color(0xFF10b981);
      default: return Colors.grey;
    }
  }

  String _getEmoji(String type) {
    switch (type) {
      case 'نفسي': return '🧠';
      case 'أسري': return '👨👩👧';
      case 'مالي': return '💰';
      case 'طبي': return '🏥';
      default: return '📍';
    }
  }
}

class DetailedFloorMapPainter extends CustomPainter {
  final List<SocialSpecialistNeed> needs;
  final double pulseValue;
  final String? selectedRoom;

  DetailedFloorMapPainter({required this.needs, required this.pulseValue, this.selectedRoom});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFeef2f7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final corridorPaint = Paint()..color = const Color(0xFFdde3ec);
    canvas.drawRect(Rect.fromLTWH(0, size.height / 2 - 15, size.width, 30), corridorPaint);

    final roomWidth = (size.width - 60) / 5;
    final roomHeight = (size.height - 40 - 30) / 2;

    for (int i = 0; i < 5; i++) {
       _drawRoom(canvas, 10 + i * (roomWidth + 10), 10, roomWidth, roomHeight, '١٠${i+1}', true);
       _drawRoom(canvas, 10 + i * (roomWidth + 10), size.height - roomHeight - 10, roomWidth, roomHeight, '١٠${i+6}', false);
    }
  }

  void _drawRoom(Canvas canvas, double x, double y, double w, double h, String roomNum, bool isTop) {
     final rect = Rect.fromLTWH(x, y, w, h);
     final isSelected = selectedRoom == roomNum;
     
     final roomNeeds = needs.where((n) => n.roomNumber == roomNum).toList();
     final hasNeed = roomNeeds.isNotEmpty;
     
     Paint roomPaint = Paint()..color = const Color(0xFFf8fafc)..style = PaintingStyle.fill;
     if (hasNeed) {
       roomPaint.color = _getRoomHighlightColor(roomNeeds.first.type);
     }
     
     canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), roomPaint);
     canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), 
        Paint()..color = isSelected ? const Color(0xFFea580c) : const Color(0xFFcbd5e1)..style = PaintingStyle.stroke..strokeWidth = isSelected ? 2 : 1.2);

     // Room Number
     final tp = TextPainter(text: TextSpan(text: roomNum, style: const TextStyle(color: Color(0xFF64748b), fontSize: 8, fontWeight: FontWeight.w600)), textDirection: TextDirection.rtl)..layout();
     tp.paint(canvas, Offset(rect.center.dx - tp.width/2, rect.top + 10));

     // Draw Needs on Room
     if (hasNeed) {
        final center = Offset(rect.center.dx, rect.bottom - 20);
        final need = roomNeeds.first;
        final color = _getColor(need.type);

        if (need.isUrgent) {
           final pingPaint = Paint()..color = color.withOpacity(0.3 - (pulseValue * 0.3))..style = PaintingStyle.fill;
           canvas.drawCircle(center, 10 + (pulseValue * 15), pingPaint);
        }

        canvas.drawCircle(center, 12, Paint()..color = color);
        canvas.drawCircle(center, 12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

        final itp = TextPainter(text: TextSpan(text: need.label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)), textDirection: TextDirection.rtl)..layout();
        itp.paint(canvas, Offset(center.dx - itp.width/2, center.dy - itp.height/2));
     }
  }

  Color _getColor(String type) {
    if (type == 'نفسي') return const Color(0xFF6366f1);
    if (type == 'أسري') return const Color(0xFFf59e0b);
    if (type == 'مالي') return const Color(0xFFef4444);
    if (type == 'طبي') return const Color(0xFF10b981);
    return Colors.grey;
  }

  Color _getRoomHighlightColor(String type) {
    if (type == 'نفسي') return const Color(0xFF6366f1).withOpacity(0.1);
    if (type == 'أسري') return const Color(0xFFf59e0b).withOpacity(0.1);
    if (type == 'مالي') return const Color(0xFFef4444).withOpacity(0.1);
    if (type == 'طبي') return const Color(0xFF10b981).withOpacity(0.1);
    return Colors.transparent;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

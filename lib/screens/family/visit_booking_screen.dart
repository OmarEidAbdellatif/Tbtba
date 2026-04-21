import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_riverpod.dart';
import '../../models/app_models.dart';

class VisitBookingScreen extends ConsumerStatefulWidget {
  const VisitBookingScreen({super.key});

  @override
  ConsumerState<VisitBookingScreen> createState() => _VisitBookingScreenState();
}

class _VisitBookingScreenState extends ConsumerState<VisitBookingScreen> {
  int _selectedType = 0; // 0: Physical, 1: Video
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;

  final List<String> _slots = ['١٠:٠٠ ص', '١١:٣٠ ص', '٠١:٠٠ م', '٠٤:٠٠ م', '٠٥:٣٠ م', '٠٧:٠٠ م'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdfcfb),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionTitle('نوع الزيارة'),
                  const SizedBox(height: 12),
                  _buildVisitTypeTabs(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('تحديد التاريخ'),
                  const SizedBox(height: 12),
                  _buildCalendarMock(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('الأوقات المتاحة'),
                  const SizedBox(height: 12),
                  _buildSlotsGrid(),
                  const SizedBox(height: 40),
                  _buildConfirmButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFea580c),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('جدولة زيارة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFea580c), Color(0xFFf97316)],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
        const SizedBox(width: 8),
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFFea580c), borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildVisitTypeTabs() {
    return Row(
      children: [
        Expanded(child: _buildTypeCard(1, 'مكالمة فيديو', Icons.videocam_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildTypeCard(0, 'زيارة واقعية', Icons.people_alt_rounded)),
      ],
    );
  }

  Widget _buildTypeCard(int index, String label, IconData icon) {
    bool isSel = _selectedType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFfff7ed) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? const Color(0xFFea580c) : const Color(0xFFf1f5f9), width: 1.5),
          boxShadow: isSel ? [BoxShadow(color: const Color(0xFFea580c).withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSel ? const Color(0xFFea580c) : const Color(0xFF94a3b8), size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSel ? const Color(0xFFea580c) : const Color(0xFF64748b), fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarMock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf1f5f9)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.chevron_left, color: Color(0xFF94a3b8)),
              Text('أبريل ٢٠٢٤', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1f2937))),
              Icon(Icons.chevron_right, color: Color(0xFF94a3b8)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: 30,
            itemBuilder: (context, i) {
              int day = i + 1;
              bool isSelected = day == 25;
              bool isPast = day < 21;
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFea580c) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isPast ? const Color(0xFFcbd5e1) : const Color(0xFF475569)),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _slots.length,
      itemBuilder: (context, i) {
        bool isSel = _selectedSlot == _slots[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = _slots[i]),
          child: Container(
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFea580c) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? Colors.transparent : const Color(0xFFf1f5f9)),
            ),
            child: Center(
              child: Text(
                _slots[i],
                style: TextStyle(color: isSel ? Colors.white : const Color(0xFF64748b), fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    bool canConfirm = _selectedSlot != null;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canConfirm ? const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]) : null,
        color: canConfirm ? null : const Color(0xFFf1f5f9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: canConfirm ? [BoxShadow(color: const Color(0xFFea580c).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))] : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: canConfirm ? () {
           // Save to state
           final provider = ref.read(appRiverpod);
           provider.addFamilyVisit(FamilyVisit(
             id: 'v${DateTime.now().millisecondsSinceEpoch}',
             visitorName: 'سارة',
             date: '٢٥ أبريل', // In a real app, use formatted _selectedDate
             time: _selectedSlot!,
             type: _selectedType == 0 ? 'physical' : 'video',
             status: 'upcoming',
           ));
           _showSuccessSheet();
        } : null,
        child: const Text('تأكيد الطلب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFdcfce7), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Color(0xFF166534), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('تم تأكيد طلب الزيارة!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('سنكون في انتظاركم في الموعد المحدد. تم إرسال رسالة تأكيد لهاتفك.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748b))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFea580c), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // back to dashboard
                },
                child: const Text('فهمت', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

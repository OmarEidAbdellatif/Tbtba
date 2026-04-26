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
  int _selectedDay = 25;
  String? _selectedSlot;

  final List<String> _slots = [
    '١٠:٠٠ ص',
    '١١:٣٠ ص',
    '٠١:٠٠ م',
    '٠٤:٠٠ م',
    '٠٥:٣٠ م',
    '٠٧:٠٠ م'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionTitle('نوع الزيارة'),
                  const SizedBox(height: 16),
                  _buildVisitTypeTabs(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('تحديد التاريخ'),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('الأوقات المتاحة'),
                  const SizedBox(height: 16),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFea580c),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('جدولة زيارة',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b))),
        const SizedBox(width: 10),
        Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
                color: const Color(0xFFea580c),
                borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildVisitTypeTabs() {
    return Row(
      children: [
        Expanded(
            child:
                _buildTypeCard(1, 'مكالمة فيديو', Icons.videocam_rounded)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildTypeCard(
                0, 'زيارة واقعية', Icons.people_alt_rounded)),
      ],
    );
  }

  Widget _buildTypeCard(int index, String label, IconData icon) {
    bool isSel = _selectedType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFfff7ed) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSel ? const Color(0xFFea580c) : const Color(0xFFf1f5f9),
              width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isSel ? 0.05 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSel ? const Color(0xFFea580c) : const Color(0xFF94a3b8),
                size: 32),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    color: isSel
                        ? const Color(0xFFea580c)
                        : const Color(0xFF64748b),
                    fontSize: 16,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: Color(0xFF94a3b8)),
              const Text('أبريل ٢٠٢٤',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              const Icon(Icons.chevron_right, color: Color(0xFF94a3b8)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1),
            itemCount: 30,
            itemBuilder: (context, i) {
              int day = i + 1;
              bool isSelected = day == _selectedDay;
              bool isPast = day < 21;
              return GestureDetector(
                onTap: isPast ? null : () => setState(() => _selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFea580c)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isPast
                                ? const Color(0xFFcbd5e1)
                                : const Color(0xFF475569)),
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.end,
      children: _slots.map((slot) {
        bool isSel = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            width: (MediaQuery.of(context).size.width - 64) / 3,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFea580c) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isSel ? Colors.transparent : const Color(0xFFf1f5f9),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(isSel ? 0.1 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                    color: isSel ? Colors.white : const Color(0xFF64748b),
                    fontSize: 14,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton() {
    bool canConfirm = _selectedSlot != null;
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: canConfirm
            ? const LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)])
            : null,
        color: canConfirm ? null : const Color(0xFFe2e8f0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: canConfirm
            ? [
                BoxShadow(
                    color: const Color(0xFFea580c).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        onPressed: canConfirm
            ? () {
                final provider = ref.read(appRiverpod);
                provider.addFamilyVisit(FamilyVisit(
                  id: 'v${DateTime.now().millisecondsSinceEpoch}',
                  visitorName: 'سارة',
                  date: '$_selectedDay أبريل',
                  time: _selectedSlot!,
                  type: _selectedType == 0 ? 'physical' : 'video',
                  status: 'upcoming',
                ));
                _showSuccessSheet();
              }
            : null,
        child: const Text('تأكيد الموعد',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFFf0fdf4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFdcfce7), width: 4)),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF22c55e), size: 50),
            ),
            const SizedBox(height: 24),
            const Text('تم تأكيد الموعد بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
                'تم إرسال تفاصيل الزيارة إلى هاتفك وإلى إدارة المركز. نحن بانتظارك! ✨',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748b), fontSize: 16)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFea580c),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // back to dashboard
                },
                child: const Text('رجوع للرئيسية',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

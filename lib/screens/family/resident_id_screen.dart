import 'package:flutter/material.dart';

class ResidentIdScreen extends StatelessWidget {
  const ResidentIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1b4b), // Dark elegant background
      appBar: AppBar(
        title: const Text('الهوية الرقمية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              _buildDigitalCard(),
              const SizedBox(height: 48),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildCardHeader(),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildQRCodeMock(),
                const SizedBox(height: 32),
                const Text('الحاج محمود الجوهري', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1e1b4b))),
                const Text('الغرفة: ١٠١ — الجناح الشرقي', style: TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFf1f5f9)),
                const SizedBox(height: 16),
                _buildInfoGrid(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            color: const Color(0xFFea580c),
            child: const Center(child: Text('صالحة للزيارة اليوم', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFea580c), Color(0xFFf97316)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Image.network('https://cdn-icons-png.flaticon.com/512/3665/3665922.png', width: 30, height: 30, color: Colors.white),
           const Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
                Text('طبطبـة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text('تصريح دخول الأقارب', style: TextStyle(color: Colors.white70, fontSize: 8)),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildQRCodeMock() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFf1f5f9), width: 2)),
      child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MahmoudAlGohary_Room101', width: 160, height: 160),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMiniInfo('O+', 'فصيلة الدم'),
        _buildDivider(),
        _buildMiniInfo('سارة', 'جهة الاتصال'),
        _buildDivider(),
        _buildMiniInfo('٧٢', 'العمر'),
      ],
    );
  }

  Widget _buildMiniInfo(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 9)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 24, color: const Color(0xFFf1f5f9));
  }

  Widget _buildInstructions() {
    return const Column(
      children: [
        Icon(Icons.contactless_rounded, color: Color(0xFFfb923c), size: 32),
        SizedBox(height: 12),
        Text('امسح الرمز عند مدخل الدار لتأكيد الهوية وتسهيل عملية الدخول المباشر للغرفة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
      ],
    );
  }
}

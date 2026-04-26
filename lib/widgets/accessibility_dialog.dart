import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_riverpod.dart';

class AccessibilityDialog extends ConsumerWidget {
  const AccessibilityDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(appRiverpod);

    bool hc = provider.isHighContrast;
    bool dm = provider.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: (hc || dm) ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: hc ? Colors.white12 : const Color(0xFFe2e8f0), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          Text('إعدادات الرؤية والخط', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: hc ? Colors.white : const Color(0xFF1e293b))),
          const SizedBox(height: 8),
          Text('تحكم في حجم الكلام ليكون مريحاً لعينك', style: TextStyle(fontSize: 16, color: hc ? Colors.white70 : const Color(0xFF64748b))),
          const SizedBox(height: 40),
          
          _buildScaleControl(provider, ref),
          const SizedBox(height: 32),
          _buildNightModeControl(provider, ref),
          const SizedBox(height: 32),
          _buildContrastControl(provider, ref),
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: hc ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: (hc ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF)).withOpacity(0.3),
            ),
            child: Text('حفظ الإعدادات', style: TextStyle(color: hc ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleControl(AppRiverpod provider, WidgetRef ref) {
    bool hc = provider.isHighContrast;
    bool dm = provider.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('حجم الخط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (hc || dm) ? Colors.white : const Color(0xFF1e293b))),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.text_fields_rounded, size: 20, color: (hc || dm) ? Colors.white24 : const Color(0xFF94a3b8)),
            Expanded(
              child: Slider(
                value: provider.fontScaleFactor,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                activeColor: (hc || dm) ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF),
                inactiveColor: (hc || dm) ? Colors.white12 : const Color(0xFFe2e8f0),
                onChanged: (val) => ref.read(appRiverpod).updateFontScale(val),
              ),
            ),
            Icon(Icons.text_fields_rounded, size: 32, color: (hc || dm) ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF)),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: (hc || dm) ? const Color(0xFF252525) : const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(16)),
            child: Text(
              'هذا مثال لحجم الخط الحالي',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: (hc || dm) ? Colors.white : const Color(0xFF1e293b)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNightModeControl(AppRiverpod provider, WidgetRef ref) {
    bool hc = provider.isHighContrast;
    bool dm = provider.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch(
          value: dm,
          onChanged: (val) => ref.read(appRiverpod).toggleDarkMode(),
          activeColor: (hc || dm) ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الوضع الليلي (Night Mode)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (hc || dm) ? Colors.white : const Color(0xFF1e293b))),
              Text('واجهة داكنة مريحة للعين', style: TextStyle(fontSize: 12, color: (hc || dm) ? Colors.white70 : const Color(0xFF64748b))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContrastControl(AppRiverpod provider, WidgetRef ref) {
    bool hc = provider.isHighContrast;
    bool dm = provider.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch(
          value: provider.isHighContrast,
          onChanged: (val) => ref.read(appRiverpod).toggleHighContrast(),
          activeColor: (hc || dm) ? const Color(0xFF9FA8DA) : const Color(0xFF6C63FF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Text('وضع التباين العالي (لضعف الرؤية)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (hc || dm) ? Colors.white : const Color(0xFF1e293b))),
          ),
        ),
      ],
    );
  }
}

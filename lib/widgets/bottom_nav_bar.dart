import 'package:flutter/material.dart';


class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      BottomNavItem(icon: Icons.home, label: 'الرئيسية', index: 0),
      BottomNavItem(icon: Icons.medication, label: 'دواء', index: 1),
      BottomNavItem(icon: Icons.people, label: 'أسرة', index: 2),
      BottomNavItem(icon: Icons.photo, label: 'ذكريات', index: 3),
      BottomNavItem(icon: Icons.schedule, label: 'أنشطة', index: 4),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFede9fe), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _buildNavItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, BottomNavItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = currentIndex == item.index;
    final color = isActive ? const Color(0xFF6C63FF) : (isDark ? Colors.white38 : const Color(0xFF9ca3af));

    return GestureDetector(
      onTap: () => onTap(item.index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(item.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              )),
          if (isActive) ...[
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final int index;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

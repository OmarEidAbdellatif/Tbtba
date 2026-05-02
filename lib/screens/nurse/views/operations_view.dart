import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';
import '../nurse_medications_screen.dart';

class OperationsView extends ConsumerStatefulWidget {
  const OperationsView({super.key});

  @override
  ConsumerState<OperationsView> createState() => _OperationsViewState();
}

class _OperationsViewState extends ConsumerState<OperationsView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);

    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const NurseMedicationsScreen(),
              _buildCareChecklist(provider),
              _buildInventory(provider),
              _buildDoctorLog(provider),
              _buildNutrition(provider),
              _buildActivities(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('إدارة العمليات والمنشأة 🏢', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('تنظيم المهام اليومية، الأدوية، والمخزون', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF0EA5E9),
        unselectedLabelColor: isDark ? Colors.white38 : const Color(0xFF64748B),
        indicatorColor: const Color(0xFF0EA5E9),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
        tabs: const [
          Tab(text: 'جدول الأدوية'),
          Tab(text: 'قائمة المهام'),
          Tab(text: 'المخزون'),
          Tab(text: 'زيارات الأطباء'),
          Tab(text: 'التغذية'),
          Tab(text: 'الأنشطة'),
        ],
      ),
    );
  }

  // --- 1. Care Checklist ---
  Widget _buildCareChecklist(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.careTasks.length,
      itemBuilder: (context, index) {
        final task = provider.careTasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: task.isCompleted ? const Color(0xFF10B981).withOpacity(0.3) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => provider.toggleCareTask(task.id),
              activeColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
            subtitle: Text('${task.residentName} · ${task.time}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : const Color(0xFF64748B))),
            trailing: _categoryChip(task.category),
          ),
        );
      },
    );
  }

  Widget _categoryChip(String cat) {
    Color color = const Color(0xFF0EA5E9);
    if (cat == 'فندقية') color = const Color(0xFF6366F1);
    if (cat == 'ترفيهية') color = const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(cat, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  // --- 2. Inventory ---
  Widget _buildInventory(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.inventoryItems.length,
      itemBuilder: (context, index) {
        final item = provider.inventoryItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: item.isLowStock ? (isDark ? const Color(0xFF991B1B).withOpacity(0.2) : const Color(0xFFFEF2F2)) : (isDark ? const Color(0xFF0C4A6E).withOpacity(0.2) : const Color(0xFFF0F9FF)), borderRadius: BorderRadius.circular(10)),
                    child: Text(item.isLowStock ? 'مخزون منخفض ⚠️' : 'متوفر', style: TextStyle(color: item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: item.currentStock / (item.minRequired * 2),
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                        color: item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${item.currentStock} / ${item.minRequired * 2} ${item.unit}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRequestSimulation(item.name),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                      ),
                      child: Text('طلب توريد', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => provider.updateInventoryStock(item.id, 1),
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0EA5E9)),
                  ),
                  IconButton(
                    onPressed: () => provider.updateInventoryStock(item.id, -1),
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRequestSimulation(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تم إرسال طلب توريد لـ "$name" للمخازن المركزية 📦'),
      backgroundColor: const Color(0xFF0369A1),
    ));
  }

  // --- 3. Doctor Log ---
  Widget _buildDoctorLog(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.doctorVisits.length,
      itemBuilder: (context, index) {
        final visit = provider.doctorVisits[index];
        bool isUpcoming = visit.date.isAfter(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUpcoming ? (isDark ? const Color(0xFF0C4A6E).withOpacity(0.2) : const Color(0xFFF0F9FF)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isUpcoming ? const Color(0xFF0EA5E9).withOpacity(0.3) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isUpcoming ? 'زيارة مرتقبة 🗓️' : 'زيارة سابقة ✅', style: TextStyle(color: isUpcoming ? const Color(0xFF38BDF8) : (isDark ? Colors.white38 : const Color(0xFF64748B)), fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(visit.doctorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              Text('${visit.specialty} · ${visit.residentName}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF334155))),
              Divider(height: 24, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              Text('الغرض من الزيارة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black)),
              Text(visit.purpose, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : const Color(0xFF64748B))),
              if (visit.results.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('النتائج والتوصيات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF10B981))),
                Text(visit.results, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- 4. Nutrition ---
  Widget _buildNutrition(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.mealPlans.length,
      itemBuilder: (context, index) {
        final plan = provider.mealPlans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white, 
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC), 
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFF59E0B)),
                    Text('نظام تغذية: ${plan.residentName}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _mealRow('الإفطار 🍳', plan.breakfast),
                    const Divider(height: 20),
                    _mealRow('الغداء 🍲', plan.lunch),
                    const Divider(height: 20),
                    _mealRow('العشاء 🥛', plan.dinner),
                    if (plan.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDBA74))),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(plan.specialInstructions, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFF9A3412), fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mealRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0369A1))),
      ],
    );
  }

  // --- 5. Activities ---
  Widget _buildActivities(AppRiverpod provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.activitySessions.length,
      itemBuilder: (context, index) {
        final session = provider.activitySessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListTile(
                leading: const Icon(Icons.event_available_rounded, color: Color(0xFF6366F1)),
                title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${session.startTime.hour}:${session.startTime.minute} · ${session.location}', style: const TextStyle(fontSize: 11)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(session.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: session.participants.map((p) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Text(p, style: const TextStyle(fontSize: 9, color: Color(0xFF475569))),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

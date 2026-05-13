import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_riverpod.dart';
import '../../../models/app_models.dart';
import '../nurse_medications_screen.dart';
import '../widgets/healing_particles.dart';

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const HealingParticles(), // إضافة الأنيميشن الموحد
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إدارة العمليات والمنشأة 🏢', 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('تنظيم المهام اليومية، الأدوية، وإدارة المخزون', 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF0369A1),
        unselectedLabelColor: isDark ? Colors.white54 : const Color(0xFF94A3B8),
        indicatorColor: const Color(0xFF0369A1),
        indicatorWeight: 4,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Cairo'),
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
      padding: const EdgeInsets.all(20),
      itemCount: provider.careTasks.length,
      itemBuilder: (context, index) {
        final task = provider.careTasks[index];
        final isDone = task.isCompleted;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDone 
              ? (isDark ? const Color(0xFF10B981).withValues(alpha: 0.05) : const Color(0xFFF0FDF4))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone 
                ? const Color(0xFF10B981).withValues(alpha: 0.3) 
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: isDone ? 1.5 : 1.0,
            ),
            boxShadow: isDone ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => provider.toggleCareTask(task.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF10B981) : Colors.transparent,
                        border: Border.all(
                          color: isDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDone ? const Color(0xFF94A3B8) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${task.residentName} · ${task.time}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDone ? const Color(0xFFCBD5E1) : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _categoryChip(task.category),
                  ],
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Text(cat, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // --- 2. Inventory ---
  Widget _buildInventory(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.inventoryItems.length,
      itemBuilder: (context, index) {
        final item = provider.inventoryItems[index];
        final progress = item.currentStock / (item.minRequired * 2);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white, 
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.isLowStock 
                        ? (isDark ? const Color(0xFF991B1B).withValues(alpha: 0.2) : const Color(0xFFFEF2F2)) 
                        : (isDark ? const Color(0xFF0C4A6E).withValues(alpha: 0.2) : const Color(0xFFF0F9FF)), 
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      item.isLowStock ? 'مخزون منخفض ⚠️' : 'متوفر بشكل جيد ✅', 
                      style: TextStyle(
                        color: item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF0284C7), 
                        fontSize: 11, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress > 1.0 ? 1.0 : progress,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                        color: item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('${item.currentStock} / ${item.minRequired * 2} ${item.unit}', 
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSupplyRequestModal(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0369A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('طلب توريد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => provider.updateInventoryStock(item.id, 1),
                          icon: const Icon(Icons.add_rounded, color: Color(0xFF0EA5E9), size: 22),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                        IconButton(
                          onPressed: item.currentStock > 0 ? () => provider.updateInventoryStock(item.id, -1) : null,
                          icon: Icon(Icons.remove_rounded, color: item.currentStock > 0 ? const Color(0xFF64748B) : const Color(0xFFCBD5E1), size: 22),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSupplyRequestModal(InventoryItem item) {
    int requestedQuantity = item.minRequired; // الكمية الافتراضية للطلب
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24, left: 24, right: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  const Icon(Icons.inventory_2_rounded, size: 50, color: Color(0xFF0369A1)),
                  const SizedBox(height: 16),
                  Text('طلب توريد لـ ${item.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text('الرصيد الحالي: ${item.currentStock} ${item.unit}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: requestedQuantity > 1 ? () => setModalState(() => requestedQuantity--) : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 36, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 24),
                      Text('$requestedQuantity', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () => setModalState(() => requestedQuantity++),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 36, color: Color(0xFF0EA5E9)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('الكمية المطلوبة (${item.unit})', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(child: Text('تم إرسال طلب توريد ($requestedQuantity ${item.unit}) للمخازن المركزية بنجاح 📦')),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0369A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('تأكيد وإرسال الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // --- 3. Doctor Log ---
  Widget _buildDoctorLog(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.doctorVisits.length,
      itemBuilder: (context, index) {
        final visit = provider.doctorVisits[index];
        bool isUpcoming = visit.date.isAfter(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isUpcoming ? (isDark ? const Color(0xFF0C4A6E).withValues(alpha: 0.2) : const Color(0xFFF0F9FF)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isUpcoming ? const Color(0xFF0EA5E9).withValues(alpha: 0.3) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUpcoming ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(isUpcoming ? 'زيارة مرتقبة 🗓️' : 'تمت الزيارة ✅', 
                      style: TextStyle(color: isUpcoming ? const Color(0xFF0369A1) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Text(visit.doctorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              Text('${visit.specialty} · لمتابعة حالة ${visit.residentName}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF475569))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الغرض من الزيارة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(visit.purpose, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
                    if (visit.results.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text('النتائج والتوصيات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981))),
                      const SizedBox(height: 4),
                      Text(visit.results, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF334155))),
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

  // --- 4. Nutrition ---
  Widget _buildNutrition(AppRiverpod provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.mealPlans.length,
      itemBuilder: (context, index) {
        final plan = provider.mealPlans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white, 
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5)
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: Color(0xFFFFEDD5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.restaurant_rounded, color: Color(0xFFEA580C)),
                    Text('الخطة الغذائية لـ ${plan.residentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF9A3412))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _mealRow('وجبة الإفطار 🍳', plan.breakfast),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _mealRow('وجبة الغداء 🍲', plan.lunch),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _mealRow('وجبة العشاء 🥛', plan.dinner),
                    if (plan.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(plan.specialInstructions, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, height: 1.5))),
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
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4))),
        const SizedBox(width: 16),
        Container(
          width: 100,
          alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0369A1))),
        ),
      ],
    );
  }

  // --- 5. Activities ---
  Widget _buildActivities(AppRiverpod provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.activitySessions.length,
      itemBuilder: (context, index) {
        final session = provider.activitySessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.local_activity_rounded, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF312E81))),
                          const SizedBox(height: 2),
                          Text('${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')} · في ${session.location}', style: const TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.description, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5)),
                    const SizedBox(height: 20),
                    const Text('المشاركين:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: session.participants.map((p) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 6),
                            Text(p, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.bold)),
                          ],
                        ),
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


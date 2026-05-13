import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart'; // نماذج البيانات المستخدمة في التطبيق
import 'package:permission_handler/permission_handler.dart'; // مكتبة إدارة التصاريح
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // مكتبة التخزين الآمن
import 'package:flutter_contacts/flutter_contacts.dart'; // مكتبة جهات الاتصال
import 'package:url_launcher/url_launcher.dart'; // مكتبة تشغيل الروابط والمكالمات
import 'package:photo_manager/photo_manager.dart'; // مكتبة إدارة الصور
import 'package:image_picker/image_picker.dart'; // مكتبة اختيار الصور من المعرض
import 'dart:io'; // للتعامل مع ملفات الصور المختارة

import '../services/notification_service.dart';

final appRiverpod = ChangeNotifierProvider((ref) => AppRiverpod());

class AppRiverpod extends ChangeNotifier {
  int selectedIndex = 0;

  void scheduleMedicationReminders(NotificationService service) {
    for (var med in medications) {
      if (!med.isTaken &&
          med.scheduledTime != null &&
          med.scheduledTime!.isAfter(DateTime.now())) {
        service.scheduleNotification(
          id: med.id.hashCode,
          title: 'موعد دواء 💊',
          body: 'حان موعد تناول ${med.name} (${med.dosage})',
          scheduledDate: med.scheduledTime!,
          payload: 'medical',
        );
      }
    }
  }

  String currentRole = 'مسن'; // الدور الحالي للمستخدم (ممرض، متطوع، مدير، إلخ)
  bool hasSeenOnboarding = false; // هل شاهد المستخدم شاشات الترحيب؟
  bool isAuthenticated = false; // هل المستخدم مسجل دخوله؟
  double fontScaleFactor = 1.0; // حجم الخط المختار لسهولة القراءة
  bool isHighContrast = false; // تفعيل وضع التباين العالي
  bool isDarkMode = false; // تفعيل الوضع الليلي

  final _storage = const FlutterSecureStorage(); // إنشاء كائن التخزين الآمن
  bool isRefreshingSession = false;
  String selectedAdminDateFilter = 'اليوم';
  DateTime? _sessionExpiry;

  // --- إدارة الحسابات (Account Management) ---
  List<AppAccount> accounts = [
    AppAccount(
        email: 'admin@admin.com',
        password: '123',
        role: 'إدارة',
        name: 'م. إبراهيم الجوهري'),
    AppAccount(
        email: 'nurse@nurse.com',
        password: '123',
        role: 'ممرض',
        name: 'أ. منى زكي'),
    AppAccount(
        email: 'specialist@specialist.com',
        password: '123',
        role: 'أخصائي اجتماعي',
        name: 'د. سارة عثمان'),
  ];

  // دالة للمدير لإنشاء حسابات جديدة
  void createAccount(
      {required String name,
      required String email,
      required String password,
      required String role}) {
    accounts.add(
        AppAccount(name: name, email: email, password: password, role: role));
    notifyListeners();
  }

  // دالة للتسجيل الذاتي (للمتطوعين والأهالي)
  void selfRegister(
      {required String name,
      required String email,
      required String password,
      required String role}) {
    accounts.add(
        AppAccount(name: name, email: email, password: password, role: role));
    notifyListeners();
  }

  // ربط عائلة بمسن
  void linkFamilyToResident(String residentId, String familyEmail) {
    final idx = residentFiles.indexWhere((r) => r.id == residentId);
    if (idx != -1) {
      final r = residentFiles[idx];
      residentFiles[idx] = SpecialistResidentFile(
        id: r.id,
        name: r.name,
        nameEn: r.nameEn,
        room: r.room,
        status: r.status,
        lastUpdate: r.lastUpdate,
        categories: r.categories,
        initials: r.initials,
        phone: r.phone,
        age: r.age,
        familyMembers: r.familyMembers,
        familyEmail: familyEmail, // الحقل الجديد للربط
      );
      notifyListeners();
    }
  }

  AppRiverpod() {
    _loadAuthState(); // تحميل حالة الدخول عند بدء تشغيل المزود
  }

  // تحميل بيانات الدخول والجلسة من التخزين الآمن
  Future<void> _loadAuthState() async {
    final auth = await _storage.read(key: 'isAuthenticated');
    final role = await _storage.read(key: 'currentRole');
    final onboarding = await _storage.read(key: 'hasSeenOnboarding');
    final expiryStr = await _storage.read(key: 'sessionExpiry');

    if (auth == 'true') {
      isAuthenticated = true;
      if (expiryStr != null) {
        _sessionExpiry = DateTime.parse(expiryStr);
      }
    }
    if (role != null) currentRole = role;
    if (onboarding == 'true') hasSeenOnboarding = true;

    notifyListeners();
  }

  // محاكاة انتهاء الجلسة لأغراض العرض (Demo)
  void simulateSessionExpiry() {
    _sessionExpiry = DateTime.now().subtract(const Duration(minutes: 1));
    notifyListeners();
  }

  // التحقق من صحة الجلسة وتجديدها إذا لزم الأمر
  Future<bool> checkAndRefreshSession() async {
    if (!isAuthenticated || _sessionExpiry == null) return true;

    // إذا كانت الجلسة منتهية أو ستنتهي خلال دقيقة
    if (_sessionExpiry!.isBefore(DateTime.now())) {
      if (isRefreshingSession) return false;

      isRefreshingSession = true;
      notifyListeners();

      // محاكاة طلب تجديد الجلسة من السيرفر
      await Future.delayed(const Duration(seconds: 2));

      // نجاح التجديد (في ٩٠٪ من الحالات للمحاكاة)
      bool refreshSuccess = DateTime.now().second % 10 != 0;

      if (refreshSuccess) {
        _sessionExpiry = DateTime.now().add(const Duration(hours: 2));
        await _storage.write(
            key: 'sessionExpiry', value: _sessionExpiry!.toIso8601String());
        isRefreshingSession = false;
        notifyListeners();
        return true;
      } else {
        // فشل التجديد -> يتطلب تسجيل دخول جديد
        isRefreshingSession = false;
        logout(); // تسجيل الخروج التلقائي
        return false;
      }
    }
    return true;
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // تحديث فلتر التاريخ للوحة تحكم المدير ومحاكاة جلب البيانات بناءً على الفترة الزمنية
  void updateAdminDateFilter(String filter) {
    selectedAdminDateFilter = filter;
    // ملاحظة: هنا يمكن إضافة استدعاء للـ API لتحديث قائمة الإحصائيات (adminStats)
    // بناءً على التاريخ المختار (اليوم مقابل الشهر الماضي مثلاً)
    notifyListeners(); // إشعار كافة واجهات المدير بضرورة إعادة البناء بالبيانات الجديدة
  }

  // Offline Mode State
  List<PendingAssessment> pendingAssessments = [];
  bool isSyncing = false;

  void addPendingAssessment(PendingAssessment assessment) {
    pendingAssessments.add(assessment);
    notifyListeners();
  }

  Future<void> syncAssessments() async {
    if (pendingAssessments.isEmpty) return;
    isSyncing = true;
    notifyListeners();

    // محاكاة عملية الرفع للسيرفر
    await Future.delayed(const Duration(seconds: 2));

    pendingAssessments.clear();
    isSyncing = false;
    notifyListeners();
  }

  // Shift Handoff State
  List<ShiftHandoff> handoffs = [
    ShiftHandoff(
      nurseName: 'أ. منى زكي',
      shiftType: 'الوردية المسائية',
      notes:
          'جميع المقيمين استلموا أدويتهم. الحاج محمود ارتفع ضغطه قليلاً الساعة ٨ م وتم إعطاؤه الدواء اللازم.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      criticalCases: ['محمود Salem'],
    ),
  ];

  void submitHandoff(ShiftHandoff h) {
    handoffs.insert(0, h);
    notifyListeners();
  }

  // Real Notification State
  List<TaptabaNotification> notifications = [
    TaptabaNotification(
      id: '1',
      title: 'موعد الدواء',
      body: 'حان موعد جرعة "كونكور" الخاصة بك.',
      time: 'منذ ١٠ دقائق',
      type: 'medical',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: 'spec_1',
      title: 'شكوى جديدة ⚠️',
      body: 'تم استلام شكوى من الغرفة ٢٠٤ بخصوص جودة الطعام.',
      time: 'منذ ١٠ دقائق',
      type: 'complaint',
      targetRole: 'specialist',
    ),
    TaptabaNotification(
      id: 'spec_2',
      title: 'تأخر تقييم ⏳',
      body: 'المقيم محمود سالم يحتاج لتقييم اجتماعي دوري.',
      time: 'منذ ساعة',
      type: 'assessment',
      targetRole: 'specialist',
    ),
    TaptabaNotification(
      id: '1',
      title: 'موعد دواء',
      body: 'حان الآن موعد دواء الضغط.',
      time: 'الآن',
      type: 'medical',
      targetRole: 'nurse',
    ),
    TaptabaNotification(
      id: '2',
      title: 'زيارة مرتقبة',
      body: 'سارة في طريقها إليك الآن.',
      time: 'منذ ساعة',
      type: 'visit',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '3',
      title: 'تقرير مالي جديد',
      body: 'تم إصدار فاتورة شهر أبريل.',
      time: 'منذ ساعتين',
      type: 'admin',
      targetRole: 'أهل',
    ),
    TaptabaNotification(
      id: '4',
      title: 'تذكير بالماء 💧',
      body: 'حان وقت شرب كوب من الماء.',
      time: 'منذ ٣ ساعات',
      type: 'medical',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '5',
      title: 'رسالة من المتطوع',
      body: 'أحمد يريد زيارتك غداً صباحاً.',
      time: 'منذ ٤ ساعات',
      type: 'social',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '6',
      title: 'تحديث الطبيب',
      body: 'تم تحديث سجل الأدوية الخاص بك.',
      time: 'منذ ٥ ساعات',
      type: 'medical',
      targetRole: 'nurse',
    ),
    TaptabaNotification(
      id: '7',
      title: 'فعالية جديدة',
      body: 'غداً رحلة إلى حديقة الأزهر.',
      time: 'منذ ٦ ساعات',
      type: 'social',
      targetRole: 'all',
    ),
    TaptabaNotification(
      id: '8',
      title: 'تقييم مكتمل',
      body: 'تم الانتهاء من التقييم الاجتماعي الدوري.',
      time: 'منذ ٧ ساعات',
      type: 'assessment',
      targetRole: 'specialist',
    ),
    TaptabaNotification(
      id: '9',
      title: 'تنبيه أمان',
      body: 'تم تفعيل نظام الطوارئ في الغرفة ١٠١.',
      time: 'منذ ٨ ساعات',
      type: 'medical',
      targetRole: 'nurse',
    ),
    TaptabaNotification(
      id: '10',
      title: 'رسالة شكر',
      body: 'عائلة المقيم محمود تشكرك على مجهودك.',
      time: 'منذ ٩ ساعات',
      type: 'social',
      targetRole: 'volunteer',
    ),
    TaptabaNotification(
      id: '11',
      title: 'تحديث إداري',
      body: 'سيتم إجراء صيانة دورية للمصاعد غداً.',
      time: 'منذ ١٠ ساعات',
      type: 'admin',
      targetRole: 'all',
    ),
    TaptabaNotification(
      id: '12',
      title: 'صورة جديدة',
      body: 'تمت إضافة صورة جديدة لرحلة الإسكندرية.',
      time: 'أمس',
      type: 'social',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '13',
      title: 'فحص دوري',
      body: 'موعد فحص السكر بعد ١٠ دقائق.',
      time: 'أمس',
      type: 'medical',
      targetRole: 'nurse',
    ),
    TaptabaNotification(
      id: '14',
      title: 'اجتماع الأخصائيين',
      body: 'اجتماع تنسيقي لمناقشة حالات الطابق الثالث.',
      time: 'أمس',
      type: 'assessment',
      targetRole: 'specialist',
    ),
    TaptabaNotification(
      id: '15',
      title: 'زيارة عائلية',
      body: 'عائلة الحاجة فاطمة في صالة الاستقبال.',
      time: 'أمس',
      type: 'visit',
      targetRole: 'all',
    ),
    TaptabaNotification(
      id: '16',
      title: 'تذكير بالرياضة',
      body: 'حان موعد تمارين الصباح الخفيفة.',
      time: 'أمس',
      type: 'social',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '17',
      title: 'تسليم وردية',
      body: 'تم الانتهاء من تسليم الوردية الليلية.',
      time: 'أمس',
      type: 'admin',
      targetRole: 'nurse',
    ),
    TaptabaNotification(
      id: '18',
      title: 'شكوى مغلقة',
      body: 'تم حل شكوى الغرفة ٢٠٤ بنجاح.',
      time: 'أمس',
      type: 'complaint',
      targetRole: 'specialist',
    ),
    TaptabaNotification(
      id: '19',
      title: 'مكالمة فائتة',
      body: 'حاول ابنك الاتصال بك منذ قليل.',
      time: 'أمس',
      type: 'family',
      targetRole: 'مسن',
    ),
    TaptabaNotification(
      id: '20',
      title: 'هدية من المتطوع',
      body: 'وصلت هدية صغيرة من فريق المتطوعين.',
      time: 'أمس',
      type: 'social',
      targetRole: 'all',
    ),
  ];

  List<TaptabaNotification> get filteredNotifications {
    return notifications
        .where((n) => n.targetRole == currentRole || n.targetRole == 'all')
        .toList();
  }

  bool get hasNewNotification => filteredNotifications.any((n) => !n.isRead);

  void triggerNotification(
      {required String title,
      required String body,
      String type = 'admin',
      String targetRole = 'all'}) {
    final newNotif = TaptabaNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      time: 'الآن',
      type: type,
      targetRole: targetRole,
    );
    notifications.insert(0, newNotif);
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void markAllFilteredNotificationsAsRead() {
    for (var n in notifications) {
      if (n.targetRole == currentRole || n.targetRole == 'all') {
        n.isRead = true;
      }
    }
    notifyListeners();
  }

  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }

  // Nursing Notes State
  List<NursingNote> nursingNotes = [
    NursingNote(
      id: 'n1',
      residentName: 'الحاج محمود سالم',
      title: 'وجبة الغداء',
      content:
          'تناول الوجبة كاملة مع شهية جيدة. مستوى السكر كان مستقراً قبل الوجبة.',
      author: 'أ. منى (مشرف)',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NursingNote(
      id: 'n2',
      residentName: 'الحاجة فاطمة علي',
      title: 'متابعة الضغط',
      content:
          'الضغط في انخفاض تدريجي بعد تناول الجرعة الصباحية. الحالة مستقرة الآن.',
      author: 'أ. منى (مشرف)',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  void addNursingNote(NursingNote note) {
    nursingNotes.insert(0, note);
    notifyListeners();
  }

  List<NursingNote> getNotesForResident(String residentName) {
    return nursingNotes.where((n) => n.residentName == residentName).toList();
  }

  // Resident Medical Info State
  List<ResidentMedicalInfo> residentMedicalInfos = [
    ResidentMedicalInfo(
      residentName: 'الحاج محمود سالم',
      medications: ['ميتفورمين ٥٠٠ ملغ', 'أسبرين حماية', 'كونكور ٥ ملغ'],
      allergies: ['حساسية من البنسلين'],
      chronicDiseases: ['ضغط الدم المرتفع', 'سكري من النوع الثاني'],
    ),
    ResidentMedicalInfo(
      residentName: 'الحاجة فاطمة علي',
      medications: ['أملوديبين ٥ ملغ', 'أوميغا ٣'],
      allergies: ['حساسية من اللاكتوز'],
      chronicDiseases: ['أمراض القلب التاجية'],
    ),
  ];

  ResidentMedicalInfo getMedicalInfo(String residentName) {
    return residentMedicalInfos.firstWhere(
      (info) => info.residentName == residentName,
      orElse: () => ResidentMedicalInfo(residentName: residentName),
    );
  }

  void updateMedicalInfo(ResidentMedicalInfo newInfo) {
    final index = residentMedicalInfos
        .indexWhere((info) => info.residentName == newInfo.residentName);
    if (index != -1) {
      residentMedicalInfos[index] = newInfo;
    } else {
      residentMedicalInfos.add(newInfo);
    }
    notifyListeners();
  }

  // عملية تسجيل الدخول وحفظ البيانات آمنياً مع ضبط موعد انتهاء الجلسة (US-SmartLogin)
  Future<bool> login(String idRaw, String passRaw) async {
    final identifier = idRaw.trim();
    final password = passRaw.trim();

    // البحث في الحسابات المسجلة
    final accountIdx = accounts
        .indexWhere((a) => a.email == identifier && a.password == password);

    if (accountIdx != -1) {
      final acc = accounts[accountIdx];
      currentRole = acc.role;
      isAuthenticated = true;
      _sessionExpiry = DateTime.now().add(const Duration(hours: 2));

      await _storage.write(key: 'isAuthenticated', value: 'true');
      await _storage.write(key: 'currentRole', value: currentRole);
      await _storage.write(
          key: 'sessionExpiry', value: _sessionExpiry!.toIso8601String());

      notifyListeners();
      return true;
    }

    // دعم الدخول السريع للمحاكاة (Legacy Support)
    if (password == '123') {
      String role = 'أسرة';
      if (identifier.contains('@admin.com')) {
        role = 'إدارة';
      } else if (identifier.contains('@nurse.com')) {
        role = 'ممرض';
      } else if (identifier.contains('@specialist.com')) {
        role = 'أخصائي اجتماعي';
      } else if (identifier.startsWith('01')) {
        role = 'مسن';
      } else if (identifier.contains('@volunteer.com')) {
        role = 'متطوع';
      }

      currentRole = role;
      isAuthenticated = true;
      _sessionExpiry = DateTime.now().add(const Duration(hours: 2));
      notifyListeners();
      return true;
    }

    return false;
  }

  // عملية تسجيل الخروج ومسح البيانات الآمنة تماماً
  Future<void> logout() async {
    isAuthenticated = false;
    _sessionExpiry = null;

    // مسح التخزين الآمن تماماً
    await _storage.delete(key: 'isAuthenticated');
    await _storage.delete(key: 'currentRole');
    await _storage.delete(key: 'sessionExpiry');

    notifyListeners(); // العودة لشاشة تسجيل الدخول تلقائياً
  }

  // إتمام شاشات الترحيب وحفظ الحالة
  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    await _storage.write(key: 'hasSeenOnboarding', value: 'true');
    notifyListeners();
  }

  void updateFontScale(double value) {
    fontScaleFactor = value;
    notifyListeners();
  }

  void toggleHighContrast() {
    isHighContrast = !isHighContrast;
    notifyListeners();
  }

  // --- ELDERLY / RESIDENT STATE (RE-ADDED) ---
  User currentUser = User(
    name: 'أحمد الشريف',
    points: 1250,
    streakDays: 14,
    completedActivities: 42,
  );

  List<Medication> medications = [
    Medication(
        id: 'm1',
        name: 'كونكور ٥ مجم',
        dosage: 'قرص واحد',
        timeDescription: 'بعد الإفطار',
        timeOfDay: 'الصباح',
        isTaken: true,
        residentName: 'الحاج محمود سالم',
        scheduledTime: DateTime.now().subtract(const Duration(hours: 4)),
        dayTag: 'اليوم'),
    Medication(
        id: 'm2',
        name: 'أسبرين بروتكت',
        dosage: 'قرص واحد',
        timeDescription: 'بعد الغداء',
        timeOfDay: 'الظهر',
        residentName: 'الحاج محمود سالم',
        scheduledTime: DateTime.now().subtract(const Duration(minutes: 30)),
        dayTag: 'اليوم'),
    Medication(
        id: 'm_missed_1',
        name: 'أنسولين سريع المفعول',
        dosage: '١٠ وحدات',
        timeDescription: 'قبل الإفطار',
        timeOfDay: 'الصباح',
        residentName: 'الحاجة فاطمة الزهراء',
        scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
        isTaken: false,
        dayTag: 'اليوم'),
    Medication(
        id: 'm3',
        name: 'أوميجا ٣',
        dosage: 'كبسولة واحدة',
        timeDescription: 'قبل النوم',
        timeOfDay: 'المساء',
        residentName: 'الحاج محمود سالم',
        scheduledTime: DateTime.now().add(const Duration(hours: 6)),
        dayTag: 'اليوم'),
    Medication(
        id: 'm_nurse_1',
        name: 'دواء ضغط',
        dosage: 'قرص واحد',
        timeDescription: 'الساعة ٩ ص',
        timeOfDay: 'الصباح',
        residentName: 'أستاذ أحمد كمال',
        scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
        isTaken: false,
        dayTag: 'اليوم'),
  ];

  List<Medication> get missedMedications =>
      medications.where((m) => m.isMissed).toList();

  void markMedicationAsTaken(String id) {
    final index = medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = medications[index];
      medications[index].isTaken = true;

      // LINK: Notify Family when medication is taken
      triggerNotification(
        title: 'تم إعطاء الدواء 💊',
        body: 'الممرض قام بإعطاء ${med.name} لـ ${med.residentName} في موعده.',
        type: 'medical',
        targetRole: 'أهل',
      );

      // LINK: Notify Admin if a dose is marked after being missed
      if (med.isMissed) {
        triggerNotification(
          title: 'معالجة تأخير دواء ⚠️',
          body: 'تم إعطاء الجرعة المتأخرة لـ ${med.residentName}.',
          type: 'admin',
          targetRole: 'مدير',
        );
      }

      notifyListeners();
    }
  }

  List<Activity> activities = [
    Activity(
        id: 'a1',
        name: 'جلسة قراءة جماعية',
        emoji: '📚',
        location: 'المكتبة',
        time: '١٠:٠٠ ص',
        status: 'done',
        badges: 'تحفيز',
        pointsReward: 20,
        dayTag: 'اليوم'),
    Activity(
        id: 'a2',
        name: 'رياضة صباحية خفيفة',
        emoji: '🧘',
        location: 'الحديقة',
        time: '٠٨:٣٠ ص',
        status: 'done',
        badges: 'نشاط',
        pointsReward: 15,
        dayTag: 'اليوم'),
    Activity(
        id: 'a3',
        name: 'مسابقة الذاكرة',
        emoji: '🧩',
        location: 'قاعة الأنشطة',
        time: '٠٤:٠٠ م',
        status: 'active',
        badges: 'تحدي',
        pointsReward: 50,
        dayTag: 'اليوم'),
    Activity(
        id: 'a4',
        name: 'اتصال فيديو مع الأسرة',
        emoji: '📱',
        location: 'غرفتي',
        time: '٠٦:٠٠ م',
        status: 'later',
        badges: 'تواصل',
        pointsReward: 10,
        dayTag: 'اليوم'),
    Activity(
        id: 'a5',
        name: 'نزهة في الحديقة',
        emoji: '🌳',
        location: 'الخارج',
        time: '٠٥:٠٠ م',
        status: 'done',
        badges: 'ترفيه',
        pointsReward: 30,
        dayTag: 'أمس'),
    Activity(
        id: 'a6',
        name: 'فحص ضغط روتيني',
        emoji: '🩺',
        location: 'العيادة',
        time: '٠٩:٠٠ ص',
        status: 'coming',
        badges: 'صحة',
        pointsReward: 5,
        dayTag: 'غداً'),
  ];

  List<FamilyMember> familyMembersList = [
    FamilyMember(
      id: 'f1',
      name: 'سارة',
      relation: 'ابنة',
      avatarPath: '',
      initials: 'س',
      phoneNumber: '01012345678',
      zoomLink: 'https://zoom.us/j/1234567890',
      isAvailable: true,
    ),
    FamilyMember(
      id: 'f2',
      name: 'محمد',
      relation: 'ابن',
      avatarPath: '',
      initials: 'م',
      phoneNumber: '01122334455',
      zoomLink: 'https://zoom.us/j/0987654321',
      isAvailable: false,
    ),
    FamilyMember(
      id: 'f3',
      name: 'ليلى',
      relation: 'حفيدة',
      avatarPath: '',
      initials: 'ل',
      phoneNumber: '01233445566',
      zoomLink: 'https://zoom.us/j/1122334455',
      isAvailable: true,
    ),
  ];

  List<VoiceMessage> voiceMessagesList = [
    VoiceMessage(
        id: 'v1',
        senderId: 'f1',
        title: 'رسالة من سارة 💜',
        timeDescription: 'منذ ساعتين',
        isUnread: true),
    VoiceMessage(
        id: 'v2',
        senderId: 'f3',
        title: 'حكاية من ليلى 👧',
        timeDescription: 'اليوم ١٠:٠٠ ص',
        isUnread: true),
    VoiceMessage(
        id: 'v3',
        senderId: 'f2',
        title: 'أخبار من أحمد 🏠',
        timeDescription: 'أمس ٠٩:٣٠ م',
        isUnread: false),
    VoiceMessage(
        id: 'v4',
        senderId: 'f1',
        title: 'تحية صباحية ☕',
        timeDescription: 'أمس ٠٨:٠٠ ص',
        isUnread: false),
  ];

  // Call State
  bool isVideoCallActive = false;
  bool isIncomingCall = false;
  String activeCallerName = 'سارة';
  String activeCallerInitials = 'سا';

  // New Features State
  bool isAIInsightsEnabled = true;
  List<AIInsight> aiInsights = [
    AIInsight(
      id: 'ai1',
      residentName: 'الحاج محمود سالم',
      summary:
          'تحسن ملحوظ في التفاعل الاجتماعي خلال الأسبوع الماضي، مع زيادة في المشاركة في الأنشطة الجماعية بنسبة ٤٠٪.',
      rationale:
          'تم تحليل سجلات الحضور والمشاركة في الأنشطة اليومية، بالإضافة إلى ملاحظات الأخصائيين حول حالته المزاجية الإيجابية في الجلسات الجماعية.',
      generationDate: DateTime.now().subtract(const Duration(hours: 2)),
      confidenceScore: 0.92,
    ),
    AIInsight(
      id: 'ai2',
      residentName: 'الحاجة فاطمة علي',
      summary:
          'انخفاض طفيف في مستوى النشاط البدني الصباحي. قد يكون بسبب تغيير في نمط النوم.',
      rationale:
          'مقارنة قراءات الحركة الصباحية لآخر ٣ أيام مع المتوسط الشهري أظهرت تراجعاً ملحوظاً في الساعات الأولى من اليوم.',
      generationDate: DateTime.now().subtract(const Duration(days: 1)),
      confidenceScore: 0.78,
    ),
  ];

  bool isAICompanionEnabled = true;
  List<CompanionMessage> companionChatHistory = [
    CompanionMessage(
      id: 'c1',
      text: 'مرحباً بك يا حاج محمود! أنا رفيقك الذكي، كيف تشعر اليوم؟ ✨',
      isFromAI: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  bool isEmergencyActive = false;
  String currentMood = ''; // 'happy', 'calm', 'tired', 'active'
  bool isReadingAudio = false;
  String readingText = '';

  List<AssetEntity> deviceGalleryImages = []; // Real fetched device assets

  List<MemoryItem> memoriesList = [
    MemoryItem(
        id: 'mem1',
        category: 'أسرة',
        title: 'عيد ميلاد يحيى',
        date: '١٥ يناير ٢٠٢٤',
        type: 'image',
        assetPath: ''),
    MemoryItem(
        id: 'mem2',
        category: 'رحلات',
        title: 'رحلة الإسكندرية',
        date: '١٠ سبتمبر ٢٠٢٣',
        type: 'video',
        assetPath: ''),
    MemoryItem(
        id: 'mem3',
        category: 'مناسبات',
        title: 'حفل الزفاف',
        date: '٥ مارس ٢٠٢٤',
        type: 'image',
        assetPath: ''),
    MemoryItem(
        id: 'mem4',
        category: 'أسرة',
        title: 'الغداء الأسبوعي',
        date: '٢٠ أبريل ٢٠٢٤',
        type: 'image',
        assetPath: ''),
    MemoryItem(
        id: 'mem5',
        category: 'رحلات',
        title: 'يوم الشاطئ',
        date: '١٢ أغسطس ٢٠٢٣',
        type: 'image',
        assetPath: ''),
  ];

  // --- VOLUNTEER STATE ---
  int volunteerHours = 38;
  int volunteerGoal = 50;

  VolunteerProfile volunteerProfile = VolunteerProfile(
    name: 'عمر أحمد الشريف',
    location: 'القاهرة',
    bio:
        'شاب طموح يسعى لخدمة المجتمع من خلال التطوع في رعاية كبار السن وتعليمهم التكنولوجيا.',
    skills: ['قراءة', 'ترفيه', 'تعليم رقمي', 'دعم نفسي'],
    linkedinUrl: 'https://linkedin.com/in/omar',
    facebookUrl: 'https://facebook.com/omar',
    instagramUrl: 'https://instagram.com/omar',
  );

  List<VolunteerOpportunity> volunteerOpportunities = [
    VolunteerOpportunity(
      id: 'vo1',
      title: 'جلسة قراءة قصص',
      org: 'دار المسنين - المعادي',
      hours: 2,
      points: 20,
      tags: ['قراءة', 'دعم نفسي'],
      icon: '📚',
      isNew: true,
      description:
          'نبحث عن متطوع لقراءة الروايات والقصص القصيرة للمقيمين في فترة العصر.',
      totalSlots: 4,
      filledSlots: 3,
      dateInfo: 'اليوم',
    ),
    VolunteerOpportunity(
      id: 'vo2',
      title: 'تعليم أساسيات التابلت',
      org: 'دار رعاية النيل',
      hours: 3,
      points: 30,
      tags: ['تكنولوجيا', 'تعليم'],
      icon: '💻',
      description:
          'مساعدة كبار السن في التواصل مع ذويهم عبر برامج الفيديو ومواقع التواصل.',
      totalSlots: 2,
      filledSlots: 1,
      dateInfo: 'غداً',
    ),
    VolunteerOpportunity(
      id: 'vo3',
      title: 'نشاط ترفيهي جماعي',
      org: 'دار الأمل',
      hours: 4,
      points: 40,
      tags: ['ترفيه', 'جماعي'],
      icon: '🎮',
      description:
          'تنظيم مسابقات بسيطة وألعاب ذهنية للمقيمين لإضفاء جو من البهجة.',
      totalSlots: 8,
      filledSlots: 5,
      dateInfo: 'الخميس',
    ),
  ];

  List<VolunteerBooking> volunteerBookings = [
    VolunteerBooking(
      id: 'vb1',
      title: 'جلسة دعم نفسي جماعي',
      timeInfo: '٣:٠٠ م — ٦:٠٠ م · غرفة النشاط',
      day: 10,
      month: 'أبريل',
      status: 'confirmed',
      location: 'غرفة النشاط — الطابق الأول',
      points: 30,
      isUrgent: true,
      startTime: DateTime.now().add(const Duration(hours: 26, minutes: 14)),
    ),
    VolunteerBooking(
      id: 'vb2',
      title: 'ورشة تعليم رقمي',
      timeInfo: '١٠:٠٠ ص — ١٢:٠٠ م · قاعة الكمبيوتر',
      day: 14,
      month: 'أبريل',
      status: 'confirmed',
      location: 'قاعة الكمبيوتر — الطابق الثاني',
      points: 20,
    ),
    VolunteerBooking(
      id: 'vb3',
      title: 'جلسة قراءة أسبوعية',
      timeInfo: '٤:٠٠ م — ٦:٠٠ م · ٢ ساعة',
      day: 5,
      month: 'أبريل',
      status: 'done',
      location: 'الحديقة الخارجية',
      points: 20,
      isRatingRequired: true,
    ),
  ];

  List<VolunteerCertificate> volunteerCertificates = [
    VolunteerCertificate(
      id: 'vc1',
      icon: '🥇',
      name: 'المتطوع المميز',
      date: 'مارس ٢٠٢٥',
      awardTitle: 'المتطوع المميز',
      description:
          'قد أتمّ بتفانٍ وااحتراف مسيرته التطوعية المتميزة وأسهم في تحسين جودة حياة مقيمينا الكرام',
    ),
    VolunteerCertificate(
      id: 'vc2',
      icon: '📚',
      name: 'القارئ المحترف',
      date: 'فبراير ٢٠٢٥',
      awardTitle: 'القارئ المحترف',
      description:
          'تقديراً لجهوده المخلصة في إثراء المحتوى المعرفي للمقيمين من خلال جلسات القراءة الأسبوعية',
    ),
    VolunteerCertificate(
      id: 'vc3',
      icon: '🔥',
      name: '١٠ جلسات',
      date: 'يناير ٢٠٢٥',
      awardTitle: 'بطل الالتزام (١٠ جلسات)',
      description: 'لإتمامه ١٠ جلسات تطوعية متتالية بروح عالية وإيجابية ملحوظة',
    ),
    VolunteerCertificate(
      id: 'vc4',
      icon: '🏆',
      name: 'الذهبية',
      date: 'باقي ١٢ س',
      isLocked: true,
      progressInfo: '٧٦٪ تم الإنجاز',
      progress: 0.76,
    ),
    VolunteerCertificate(
      id: 'vc5',
      icon: '💎',
      name: 'الماسية',
      date: 'باقي ٦٢ س',
      isLocked: true,
      progressInfo: '٣٨٪ تم الإنجاز',
      progress: 0.38,
    ),
  ];

  List<VolunteerRating> volunteerRatings = [
    VolunteerRating(
      id: 'vr1',
      fromName: 'الحاج محمود صبحي',
      category: 'القراءة والتحاور',
      score: 5.0,
      comment:
          'عمر شاب مهذب جداً، وصوته هادئ ومريح أثناء القراءة. استمتعت جداً بجلستنا الأخيرة.',
      date: '٥ أبريل ٢٠٢٥',
      icon: '👴',
      chips: ['صبور', 'منظّم', 'محفّز'],
      criteriaScores: {'التعامل': 5.0, 'الالتزام': 5.0, 'جودة التحضير': 5.0},
    ),
    VolunteerRating(
      id: 'vr2',
      fromName: 'أ. سمر (منسقة الأنشطة)',
      category: 'الالتزام والتحضير',
      score: 4.5,
      comment:
          'ملتزم جداً بالمواعيد ويأتي دائماً مبتسماً. يحتاج فقط للتركيز أكثر على تنويع الكتب المختارة.',
      date: '٢ أبريل ٢٠٢٥',
      icon: '👩‍💼',
      chips: ['مبتسم', 'دقيق'],
      criteriaScores: {'التعامل': 4.7, 'الالتزام': 5.0, 'جودة التحضير': 4.0},
    ),
    VolunteerRating(
      id: 'vr3',
      fromName: 'السيدة زبيدة هانم',
      category: 'الدعم الرقمي',
      score: 5.0,
      comment:
          'بصبره وطول باله، علمني كيف أتحدث مع أحفادي عبر الفيديو. شكراً جزيلاً له.',
      date: '٣٠ مارس ٢٠٢٥',
      icon: '👵',
      chips: ['خبير تقني', 'هادئ'],
      criteriaScores: {'التعامل': 5.0, 'الالتزام': 4.8, 'المهارة': 5.0},
    ),
  ];

  List<VolunteerReview> volunteerReviews = [
    VolunteerReview(
      id: 'vw1',
      toName: 'الحاج محمود سالم',
      session: 'جلسة قراءة',
      date: 'أمس',
      score: 4.0,
      isPending: true,
      icon: 'مح',
    ),
    VolunteerReview(
      id: 'vw2',
      toName: 'الحاجة فاطمة',
      session: 'جلسة ترفيه',
      date: '٢٢ مارس',
      score: 5.0,
      isPending: false,
      icon: 'فا',
    ),
    VolunteerReview(
      id: 'vw3',
      toName: 'الحاج أحمد',
      session: 'دعم نفسي',
      date: '١٥ مارس',
      score: 5.0,
      isPending: false,
      icon: 'أح',
    ),
  ];

  // --- DYNAMIC QUESTION BANK ---
  Map<String, List<Map<String, dynamic>>> questionBank = {
    't1': [
      // Psychological (GDS-15)
      {
        'text': 'هل تشعر بالرضا عن حياتك بشكل عام؟',
        'type': 'choice',
        'options': ['نعم', 'لا']
      },
      {
        'text': 'هل تخلت عن الكثير من اهتماماتك؟',
        'type': 'choice',
        'options': ['نعم', 'لا']
      },
      {
        'text': 'هل تشعر بفرط الملل؟',
        'type': 'choice',
        'options': ['نعم', 'لا']
      },
      {
        'text': 'هل تشعر بالقلق من حدوث شيء سيء؟',
        'type': 'choice',
        'options': ['نعم', 'لا']
      },
      {
        'text': 'هل تشعر بالسعادة معظم الوقت؟',
        'type': 'choice',
        'options': ['نعم', 'لا']
      },
    ],
    't2': [
      // Social (LSNS-6)
      {
        'text': 'كم عدد الأصدقاء الذين تراهم أو تسمع منهم شهرياً؟',
        'type': 'choice',
        'options': ['٠', '١', '٢', '٣-٤', '٥-٨', '٩+']
      },
      {
        'text': 'مع كم من أصدقائك تشعر بالراحة للحديث عن أمورك الخاصة؟',
        'type': 'choice',
        'options': ['٠', '١', '٢', '٣-٤', '٥-٨', '٩+']
      },
      {
        'text':
            'كم عدد الأصدقاء الذين تشعر بقربهم بحيث يمكنك طلب المساعدة منهم؟',
        'type': 'choice',
        'options': ['٠', '١', '٢', '٣-٤', '٥-٨', '٩+']
      },
    ],
    't3': [
      // Physical (ADL)
      {
        'text': 'هل يمكنك الاستحمام بمفردك؟',
        'type': 'choice',
        'options': ['بشكل مستقل', 'بمساعدة جزئية', 'بمساعدة كاملة']
      },
      {
        'text': 'هل يمكنك ارتداء ملابسك بمفردك؟',
        'type': 'choice',
        'options': ['بشكل مستقل', 'بمساعدة جزئية', 'بمساعدة كاملة']
      },
      {
        'text': 'القدرة على الحركة والانتقال؟',
        'type': 'choice',
        'options': ['بشكل مستقل', 'بمساعدة جزئية', 'بمساعدة كاملة']
      },
    ],
  };

  List<Map<String, dynamic>> getQuestionsForTool(String toolId) {
    return questionBank[toolId] ??
        [
          {
            'text': 'سؤال عام ١',
            'type': 'choice',
            'options': ['نعم', 'لا']
          },
          {'text': 'سؤال عام ٢', 'type': 'scale'},
        ];
  }

  // --- SOCIAL SPECIALIST STATE ---
  String selectedSpecialistFilter = 'الكل';
  String residentSearchQuery = '';
  String? selectedHealthStatus; // 'stable', 'monitoring', 'critical'
  String? selectedRoomFilter;
  int selectedFloor = 1;

  List<SocialSpecialistAssessmentTool> socialAssessmentTools = [
    SocialSpecialistAssessmentTool(
      id: 't1',
      name: 'التقييم النفسي (GDS)',
      subtitle: 'مقياس الاكتئاب للمسنين',
      score: '٨/١٥',
      status: 'مكتمل',
      icon: '🧠',
    ),
    SocialSpecialistAssessmentTool(
      id: 't2',
      name: 'التقييم الاجتماعي',
      subtitle: 'شبكة التواصل والعلاقات',
      score: '٥/٢٠',
      status: 'يُوصى به',
      icon: '🤝',
    ),
    SocialSpecialistAssessmentTool(
      id: 't3',
      name: 'التقييم البدني (ADL)',
      subtitle: 'أنشطة الحياة اليومية',
      score: '٧٨/١٠٠',
      status: 'دوري',
      icon: '🏃',
    ),
    SocialSpecialistAssessmentTool(
      id: 't4',
      name: 'جودة الحياة',
      subtitle: 'الرضا العام والرفاهية',
      score: '٦٢/١٠٠',
      status: 'اختياري',
      icon: '❤️',
    ),
  ];

  List<SocialSpecialistNeed> socialNeeds = [
    SocialSpecialistNeed(
        id: 'n1', type: 'مالي', roomNumber: '١٠١', label: 'م', isUrgent: true),
    SocialSpecialistNeed(id: 'n2', type: 'أسري', roomNumber: '١٠٣', label: 'أ'),
    SocialSpecialistNeed(id: 'n3', type: 'نفسي', roomNumber: '١٠٤', label: 'ن'),
    SocialSpecialistNeed(id: 'n4', type: 'نفسي', roomNumber: '١٠٤', label: 'ن'),
    SocialSpecialistNeed(id: 'n5', type: 'أسري', roomNumber: '١٠٥', label: 'أ'),
    SocialSpecialistNeed(id: 'n6', type: 'نفسي', roomNumber: '١٠٦', label: 'ن'),
    SocialSpecialistNeed(id: 'n7', type: 'أسري', roomNumber: '١٠٧', label: 'أ'),
    SocialSpecialistNeed(id: 'n8', type: 'نفسي', roomNumber: '١٠٧', label: 'ن'),
    SocialSpecialistNeed(id: 'n9', type: 'طبي', roomNumber: '١٠٩', label: 'ط'),
    SocialSpecialistNeed(
        id: 'n10', type: 'نفسي', roomNumber: '١٠١', label: 'ن'),
    SocialSpecialistNeed(
        id: 'n11', type: 'نفسي', roomNumber: '١١٠', label: 'ن'),
    SocialSpecialistNeed(
        id: 'n12', type: 'أسري', roomNumber: '١٠٢', label: 'أ'),
    SocialSpecialistNeed(
        id: 'n13', type: 'مالي', roomNumber: '١٠٨', label: 'م'),
  ];

  List<SocialSpecialistResidentScore> socialResidentScores = [
    SocialSpecialistResidentScore(
      id: 'rs1',
      name: 'الحاج محمود سالم',
      initials: 'مح',
      room: '١٠٣',
      date: 'قبل ٣ أشهر',
      isUrgent: true,
      healthStatus: 'monitoring',
      lastAssessment: DateTime.now().subtract(const Duration(days: 90)),
      scores: {'نفسي': 0.45, 'اجتماعي': 0.30, 'بدني': 0.72, 'أسري': 0.55},
    ),
    SocialSpecialistResidentScore(
      id: 'rs2',
      name: 'الحاجة فاطمة الزهراء',
      initials: 'فا',
      room: '١٠٧',
      date: 'قبل أسبوع',
      isUrgent: false,
      healthStatus: 'stable',
      lastAssessment: DateTime.now().subtract(const Duration(days: 7)),
      scores: {'نفسي': 0.85, 'اجتماعي': 0.70, 'بدني': 0.62, 'أسري': 0.95},
    ),
    SocialSpecialistResidentScore(
      id: 'rs3',
      name: 'أستاذ أحمد كمال',
      initials: 'أح',
      room: '٢٠٤',
      date: 'مطلوب الآن',
      isUrgent: true,
      healthStatus: 'critical',
      lastAssessment: DateTime.now().subtract(const Duration(days: 120)),
      scores: {'نفسي': 0.25, 'اجتماعي': 0.40, 'بدني': 0.32, 'أسري': 0.15},
    ),
  ];

  List<SocialSpecialistResidentScore> get filteredResidentScores {
    return socialResidentScores.where((r) {
      final matchQuery = r.name.contains(residentSearchQuery) ||
          r.room.contains(residentSearchQuery);
      final matchStatus = selectedHealthStatus == null ||
          r.healthStatus == selectedHealthStatus;
      final matchRoom =
          selectedRoomFilter == null || r.room == selectedRoomFilter;
      return matchQuery && matchStatus && matchRoom;
    }).toList();
  }

  void setResidentSearch(String query) {
    residentSearchQuery = query;
    notifyListeners();
  }

  void setHealthFilter(String? status) {
    selectedHealthStatus = status;
    notifyListeners();
  }

  List<SocialSpecialistComplaint> socialComplaints = [
    SocialSpecialistComplaint(
      id: 'c1',
      title: 'شعور بالوحدة والعزلة الشديدة',
      residentName: 'الحاج محمود',
      room: '١٠١',
      date: 'اليوم ٩:٠٠ ص',
      priority: 'high',
      status: 'open',
      category: 'psych',
      icon: '😔',
      timeline: [
        ComplaintStep(
            text: 'تم استلام الشكوى من الممرضة',
            time: '٩:٠٠ ص',
            status: 'done'),
        ComplaintStep(
            text: 'بانتظار التحقق والمتابعة', time: 'الآن', status: 'alert'),
      ],
    ),
    SocialSpecialistComplaint(
      id: 'c2',
      title: 'اقتراح تنويع قائمة الطعام',
      residentName: 'الحاجة فاطمة',
      room: '١٠٧',
      date: 'أمس ٢:٣٠ م',
      priority: 'medium',
      status: 'progress',
      category: 'food',
      icon: '🍽️',
      timeline: [
        ComplaintStep(
            text: 'تم التحقق والتواصل مع المطبخ', time: 'أمس', status: 'done'),
        ComplaintStep(
            text: 'في انتظار موافقة الإدارة', time: 'اليوم', status: 'pending'),
      ],
    ),
    SocialSpecialistComplaint(
      id: 'c3',
      title: 'طلب رحلة للحديقة العامة',
      residentName: 'مجموعة مقيمين',
      room: 'عام',
      date: 'أمس ١١:٠٠ ص',
      priority: 'low',
      status: 'done',
      category: 'activity',
      icon: '🌳',
      timeline: [
        ComplaintStep(
            text: 'تمت الموافقة وتنظيم الرحلة',
            time: 'الأربعاء',
            status: 'done'),
        ComplaintStep(
            text: 'تم تنفيذ الرحلة بنجاح ✓', time: 'الخميس', status: 'done'),
      ],
    ),
    SocialSpecialistComplaint(
      id: 'c4',
      title: 'مشكلة في إضاءة الغرفة',
      residentName: 'سامي حسن',
      room: '١٠٤',
      date: 'اليوم ١٠:٠٠ ص',
      priority: 'low',
      status: 'open',
      category: 'maintenance',
      icon: '💡',
      timeline: [
        ComplaintStep(text: 'تم تسجيل الطلب', time: '١٠:٠٠ ص', status: 'done'),
      ],
    ),
  ];

  List<SocialSpecialistKPI> socialKPIs = [
    SocialSpecialistKPI(
        id: 'k1',
        label: 'معدل الرضا العام',
        value: '٨٤٪',
        trend: '↑ تحسّن ٤٪',
        isPositive: true),
    SocialSpecialistKPI(
        id: 'k2',
        label: 'مشاركة الأنشطة',
        value: '٧٦٪',
        trend: '↑ هذا الأسبوع',
        isPositive: true),
    SocialSpecialistKPI(
        id: 'k3',
        label: 'حالات حرجة',
        value: '٢',
        trend: '↑ تحتاج تدخل',
        isPositive: false),
    SocialSpecialistKPI(
        id: 'k4',
        label: 'شكاوى مفتوحة',
        value: '٣',
        trend: '← نفس الأسبوع',
        isPositive: true),
  ];

  // --- GETTERS ---
  int get totalResidentsCount => residentFiles.length;
  int get criticalResidentsCount =>
      residentFiles.where((f) => f.status == 'critical').length;
  int get compliancePercentage {
    if (medications.isEmpty) return 100;
    final takenCount = medications.where((m) => m.isTaken).length;
    return ((takenCount / medications.length) * 100).toInt();
  }

  int get unpaidBillsAmount {
    return familyBills
        .where((b) => !b.isPaid)
        .fold(0, (sum, b) => sum + b.amount.toInt());
  }

  int get totalOpenNeeds => socialNeeds.length;
  int get totalOpenComplaints =>
      socialComplaints.where((c) => c.status == 'open').length;
  int get totalPendingAssessments => 7;

  double get averageRating => 4.7;
  int get totalReviews => 12;
  String get topSkill => 'التعامل ⭐ ٥.٠';
  String get skillNeedsImprovement => 'التحضير ٤.٠';

  List<Medication> get todayMedications => medications;
  Medication? get nextMedication {
    try {
      return medications.firstWhere((m) => !m.isTaken);
    } catch (_) {
      return null;
    }
  }

  int get remainingSecondsToNextMed {
    final next = nextMedication;
    if (next == null || next.scheduledTime == null) return 0;
    final diff = next.scheduledTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  List<FamilyMember> get familyMembers => familyMembersList;

  // --- CONTACTS & COMMUNICATION LOGIC ---

  // طلب إذن الوصول لجهات الاتصال وجلب المفضلين
  Future<void> fetchFavoriteContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // جلب جهات الاتصال مع الصور وأرقام الهواتف
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      // جلب جهات الاتصال المفضلة (Starred) فقط
      final favorites = contacts.where((c) => c.isStarred).toList();

      // إذا لم يكن هناك مفضلين، نأخذ أول ٣ جهات اتصال كأمثلة
      final toShow =
          favorites.isNotEmpty ? favorites : contacts.take(3).toList();

      for (var contact in toShow) {
        if (contact.phones.isNotEmpty) {
          final phone = contact.phones.first.number;
          if (!familyMembersList.any((m) => m.phoneNumber == phone)) {
            familyMembersList.add(FamilyMember(
              id: contact.id,
              name: contact.displayName,
              relation: 'قريب', // صلة افتراضية
              avatarPath: '',
              initials: contact.displayName.isNotEmpty
                  ? contact.displayName.substring(0, 1)
                  : '؟',
              phoneNumber: phone,
              isAvailable: true,
            ));
          }
        }
      }
      notifyListeners();
    }
  }

  // إجراء مكالمة هاتفية حقيقية عبر تطبيق الهاتف
  Future<void> callPhoneNumber(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch dialer for $phone');
    }
  }

  // تشغيل اجتماعات زووم
  Future<void> launchZoom(String? link) async {
    if (link == null || link.isEmpty) return;

    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch Zoom link: $link');
    }
  }

  List<VoiceMessage> get voiceMessages => voiceMessagesList;
  List<MemoryItem> get memories => memoriesList;

  VolunteerImpact get volunteerImpact => VolunteerImpact(
        residentsServed: totalResidentsCount,
        positiveRatings: 18,
        totalHours: volunteerHours,
      );

  // --- DETAILED ASSESSMENT STATE ---
  List<AssessmentQuestion> gdsQuestions = [
    AssessmentQuestion(
        id: 'q1',
        text: 'هل تشعر بأساس من الرضا عن حياتك؟',
        type: 'choice',
        options: ['نعم', 'لا']),
    AssessmentQuestion(
        id: 'q2',
        text: 'هل تركت الكثير من أنشطتك واهتماماتك؟',
        type: 'choice',
        options: ['نعم', 'لا']),
    AssessmentQuestion(
        id: 'q3',
        text: 'هل تشعر أن حياتك فارغة؟',
        type: 'choice',
        options: ['نعم', 'لا']),
    AssessmentQuestion(
        id: 'q4',
        text: 'هل تشعر بالملل في كثير من الأحيان؟',
        type: 'choice',
        options: ['نعم', 'لا']),
    AssessmentQuestion(
        id: 'q5',
        text: 'هل تشعر بالروح المعنوية الجيدة في معظم الأوقات؟',
        type: 'choice',
        options: ['نعم', 'لا']),
    AssessmentQuestion(
        id: 'q6',
        text: 'هل تشعر بالقلق وأن هناك أشياء سيئة ستحدث لك؟',
        type: 'choice',
        options: ['نعم — أحياناً', 'لا — نادراً', 'أحياناً جداً']),
    AssessmentQuestion(
        id: 'q7',
        text: 'كيف تقيّم مزاجك العام خلال الأسبوع الماضي؟',
        type: 'scale'),
    AssessmentQuestion(
        id: 'q8',
        text: 'هل تشعر أنك عاجز عن مساعدة الآخرين؟ اشرح بكلماتك:',
        type: 'text'),
  ];

  List<AssessmentHistoricalEntry> assessmentHistory = [
    AssessmentHistoricalEntry(
        date: 'اليوم', score: 8, total: '15', trend: 'down'),
    AssessmentHistoricalEntry(
        date: 'يناير ٢٠٢٥', score: 9, total: '15', trend: 'down'),
    AssessmentHistoricalEntry(
        date: 'أكتوبر ٢٠٢٤', score: 11, total: '15', trend: 'stable'),
    AssessmentHistoricalEntry(
        date: 'يوليو ٢٠٢٤', score: 7, total: '15', trend: 'up'),
  ];

  // --- METHODS ---
  void setRole(String role) {
    currentRole = role;
    notifyListeners();
  }

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  List<Activity> getActivitiesForDay(int index) {
    final daysMapping = ['أمس', 'اليوم', 'غداً', 'الأسبوع'];
    String tag = daysMapping[index];
    if (tag == 'الأسبوع') return activities;
    return activities.where((a) => a.dayTag == tag).toList();
  }

  void completeActivity(String id) {
    final idx = activities.indexWhere((a) => a.id == id);
    if (idx != -1) {
      activities[idx].status = 'done';
      notifyListeners();
    }
  }

  void takeMedication(String id) {
    final idx = medications.indexWhere((m) => m.id == id);
    if (idx != -1 && !medications[idx].isTaken) {
      medications[idx].isTaken = true;
      medications[idx].isSkipped = false;
      addPoints(10); // Reward points for taking medication

      // إشعار الأسرة باكتمال أهداف المسن الصحية
      triggerNotification(
        title: 'إنجاز صحي جديد! 🏆',
        body:
            'والدك أتم أخذ دوائه (${medications[idx].name}) في الموعد وكسب 10 نقاط!',
        type: 'medical',
        targetRole: 'أسرة',
      );

      notifyListeners();
    }
  }

  void skipMedication(String id, String reason) {
    final idx = medications.indexWhere((m) => m.id == id);
    if (idx != -1) {
      medications[idx].isSkipped = true;
      medications[idx].isTaken = false;
      medications[idx].skipReason = reason;
      notifyListeners();
    }
  }

  List<Medication> getMedicationsForDay(int index) {
    final daysMapping = ['أمس', 'اليوم', 'غداً', 'الأسبوع'];
    String tag = daysMapping[index];
    if (tag == 'الأسبوع') return medications;
    return medications.where((m) => m.dayTag == tag).toList();
  }

  void addPoints(int p) {
    currentUser.points += p;
    notifyListeners();
  }

  // --- NEW FEATURES METHODS ---
  void toggleAIInsights(bool value) {
    isAIInsightsEnabled = value;
    notifyListeners();
  }

  void toggleAICompanion(bool value) {
    isAICompanionEnabled = value;
    notifyListeners();
  }

  void sendCompanionMessage(String text) {
    if (text.isEmpty) return;

    // Add user message
    companionChatHistory.add(CompanionMessage(
      id: DateTime.now().toString(),
      text: text,
      isFromAI: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Simulate supportive AI reply
    Future.delayed(const Duration(seconds: 1), () {
      String reply =
          'أنا هنا لأسمعك دائماً. يسعدني جداً تواصلك معي! هل هناك شيء آخر تود الحديث عنه؟';

      // Basic supportive logic based on keywords
      if (text.contains('وحيد') || text.contains('وحدة')) {
        reply =
            'لست وحدك أبداً، أنا معك وعائلتك تحبك كثيراً. ما رأيك أن نشاهد بعض الصور من صندوق الذكريات لاحقاً؟';
      } else if (text.contains('تعبان') || text.contains('مرض')) {
        reply =
            'سلامتك ألف سلامة. لا تنسَ تناول دوائك في موعده، وسأكون هنا لأطمئن عليك باستمرار.';
      } else if (text.contains('سعيد') || text.contains('جميل')) {
        reply =
            'يا له من خبر رائع! طاقتك الإيجابية تسعدني جداً. أتمنى أن يدوم هذا الشعور الجميل.';
      }

      companionChatHistory.add(CompanionMessage(
        id: DateTime.now().toString(),
        text: reply,
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  void triggerSOS() {
    isEmergencyActive = true;

    // إرسال إشعارات طوارئ للأطراف المعنية
    triggerNotification(
      title: '🚨 نداء طوارئ!',
      body: 'تم تفعيل الطوارئ في الغرفة. يرجى التوجه فوراً!',
      type: 'medical',
      targetRole: 'ممرض',
    );
    triggerNotification(
      title: 'طوارئ طبية (تتبع)',
      body: 'تم تفعيل إنذار طوارئ للمقيم، الفريق الطبي في الطريق.',
      type: 'admin',
      targetRole: 'إدارة',
    );
    triggerNotification(
      title: 'طمأنة بشأن والدك 🚨',
      body:
          'حدث استدعاء طوارئ، فريقنا الطبي متواجد مع والدك الآن وسنوافيكم بالتقارير.',
      type: 'medical',
      targetRole: 'عائلة',
    );

    notifyListeners();
  }

  void cancelSOS() {
    isEmergencyActive = false;
    notifyListeners();
  }

  // --- DEEP LINKING & NOTIFICATIONS (US-09-03) ---
  void handleDeepLink(String route) {
    // Logic for Elderly (مسن) role
    if (currentRole == 'مسن') {
      switch (route) {
        case 'medication':
          setElderlyTabIndex(1); // Medication screen
          break;
        case 'family_update':
          setElderlyTabIndex(3); // Memories screen
          break;
        case 'calls':
          setElderlyTabIndex(2); // Calls screen
          break;
        case 'activities':
          setElderlyTabIndex(4); // Activities screen
          break;
        default:
          setElderlyTabIndex(0); // Home
      }
    }
    // Logic for other roles could be added here

    notifyListeners();
  }

  void simulateNotification(String type) {
    // Simulate a push notification being clicked
    handleDeepLink(type);
  }

  void setMood(String mood) {
    currentMood = mood;
    addPoints(5); // Reward for check-in
    notifyListeners();
  }

  void startReading(String text) {
    readingText = text;
    isReadingAudio = true;
    notifyListeners();
    // Simulate reading end after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      isReadingAudio = false;
      notifyListeners();
    });
  }

  void toggleVoiceMessage(String id) {
    final idx = voiceMessagesList.indexWhere((v) => v.id == id);
    if (idx != -1) {
      voiceMessagesList[idx].isPlaying = !voiceMessagesList[idx].isPlaying;
      if (voiceMessagesList[idx].isUnread) {
        voiceMessagesList[idx].isUnread = false;
      }
      notifyListeners();
    }
  }

  void markVoiceMessageRead(String id) {
    final idx = voiceMessagesList.indexWhere((v) => v.id == id);
    if (idx != -1) {
      voiceMessagesList[idx].isUnread = false;
      notifyListeners();
    }
  }

  void setSelectedSpecialistFilter(String filter) {
    selectedSpecialistFilter = filter;
    notifyListeners();
  }

  void setSelectedRoom(String? room) {
    selectedRoomFilter = room;
    notifyListeners();
  }

  void setSelectedFloor(int floor) {
    selectedFloor = floor;
    notifyListeners();
  }

  String selectedComplaintStatus = 'الكل';

  void setSelectedComplaintStatus(String status) {
    selectedComplaintStatus = status;
    notifyListeners();
  }

  List<SocialSpecialistNeed> get filteredSocialNeeds {
    if (selectedSpecialistFilter == 'الكل') return socialNeeds;
    return socialNeeds
        .where((n) => n.type == selectedSpecialistFilter)
        .toList();
  }

  // --- تتبع الشكاوى والمتابعة الاجتماعية (US-07-04) ---

  // فلترة الشكاوى بناءً على حالتها (جديدة، قيد المعالجة، مكتملة)
  List<SocialSpecialistComplaint> get filteredSocialComplaints {
    if (selectedComplaintStatus.contains('الكل')) return socialComplaints;
    if (selectedComplaintStatus.contains('مفتوحة')) {
      return socialComplaints.where((c) => c.status == 'open').toList();
    }
    if (selectedComplaintStatus.contains('جاري')) {
      return socialComplaints.where((c) => c.status == 'progress').toList();
    }
    if (selectedComplaintStatus.contains('مُغلقة')) {
      return socialComplaints.where((c) => c.status == 'done').toList();
    }
    return socialComplaints;
  }

  List<dynamic> getMemoriesByCategory(String category) {
    List<dynamic> results = [];

    // Helper to strip emoji
    String cleanCategory =
        category.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '').trim();

    if (category == 'الكل') {
      results.addAll(memoriesList);
      results.addAll(memoryMoments);
    } else if (cleanCategory == 'أسرة') {
      results.addAll(memoriesList.where((m) => m.category == 'أسرة'));
    } else if (category == '🎬 فيديو' || cleanCategory == 'فيديو') {
      results.addAll(memoriesList.where((m) => m.type == 'video'));
    } else if (cleanCategory == 'المسكن') {
      results.addAll(memoryMoments);
    } else if (cleanCategory == 'رحلات') {
      results.addAll(memoriesList.where((m) => m.category == 'رحلات'));
    } else if (cleanCategory == 'مناسبات') {
      results.addAll(memoriesList.where((m) => m.category == 'مناسبات'));
    } else {
      results.addAll(memoriesList.where((m) => m.category == cleanCategory));
    }
    return results;
  }

  // --- FAMILY STATE ---
  List<FamilyHealthMetric> familyHealthMetrics = [
    FamilyHealthMetric(
        label: 'المزاج العام', value: 0.85, status: 'good', trend: 'up'),
    FamilyHealthMetric(
        label: 'النشاط البدني', value: 0.60, status: 'medium', trend: 'stable'),
    FamilyHealthMetric(
        label: 'جودة النوم', value: 0.75, status: 'good', trend: 'up'),
    FamilyHealthMetric(
        label: 'الشهية', value: 0.45, status: 'medium', trend: 'down'),
  ];

  List<FamilyVisit> familyVisits = [
    FamilyVisit(
        id: 'v1',
        date: '٢٤ أبريل',
        time: '٠٤:٠٠ م',
        visitorName: 'سارة (أنا)',
        status: 'upcoming',
        type: 'physical'),
    FamilyVisit(
        id: 'v2',
        date: '١٠ أبريل',
        time: '٠٦:٣٠ م',
        visitorName: 'محمد',
        status: 'completed',
        type: 'video'),
    FamilyVisit(
        id: 'v3',
        date: '٠٢ أبريل',
        time: '١١:٠٠ ص',
        visitorName: 'سارة (أنا)',
        status: 'completed',
        type: 'physical'),
  ];

  List<FamilyBill> familyBills = [
    FamilyBill(
        id: 'b1',
        title: 'إقامة ورعاية - أبريل',
        month: 'أبريل ٢٠٢٤',
        amount: 4500,
        isPaid: false,
        dueDate: '٣٠ أبريل'),
    FamilyBill(
        id: 'b2',
        title: 'خدمات طبية إضافية',
        month: 'أبريل ٢٠٢٤',
        amount: 750,
        isPaid: false,
        dueDate: '٣٠ أبريل'),
    FamilyBill(
        id: 'b3',
        title: 'إقامة ورعاية - مارس',
        month: 'مارس ٢٠٢٤',
        amount: 4500,
        isPaid: true,
        dueDate: '٣١ مارس'),
  ];

  // --- SPECIALIST FILES STATE ---
  List<SpecialistResidentFile> residentFiles = [
    SpecialistResidentFile(
        id: 'rf1',
        name: 'الحاج محمود الجوهري',
        nameEn: 'Mahmoud El Gohary',
        room: '١٠١',
        status: 'updated',
        lastUpdate: 'اليوم ١٠:٠٠ ص',
        initials: 'مح',
        categories: ['social', 'medical'],
        age: 72,
        phone: '01012345678',
        familyMembers: [
          FamilyMember(
              id: 'f1',
              name: 'أحمد محمود',
              relation: 'ابن',
              avatarPath: '',
              initials: 'أم',
              phoneNumber: '01011112222',
              isAvailable: true),
          FamilyMember(
              id: 'f2',
              name: 'سارة محمود',
              relation: 'ابنة',
              avatarPath: '',
              initials: 'سم',
              phoneNumber: '01033334444'),
        ]),
    SpecialistResidentFile(
        id: 'rf2',
        name: 'سعدية علي كامل',
        nameEn: 'Saadia Ali Kamel',
        room: '١٠٢',
        status: 'pending',
        lastUpdate: 'أمس ٠٩:٣٠ م',
        initials: 'سع',
        categories: ['social', 'admin'],
        age: 68,
        phone: '01112223334',
        familyMembers: [
          FamilyMember(
              id: 'f3',
              name: 'منى حسن',
              relation: 'ابنة',
              avatarPath: '',
              initials: 'مح',
              phoneNumber: '01155556666'),
        ]),
    SpecialistResidentFile(
        id: 'rf3',
        name: 'إبراهيم سليمان',
        nameEn: 'Ibrahim Soliman',
        room: '١٠٣',
        status: 'updated',
        lastUpdate: '١٨ أبريل',
        initials: 'إب',
        categories: ['medical', 'psychological']),
    SpecialistResidentFile(
        id: 'rf4',
        name: 'سامي حسن',
        nameEn: 'Sami Hassan',
        room: '١٠٤',
        status: 'critical',
        lastUpdate: 'اليوم ٠٨:١٥ ص',
        initials: 'اس',
        categories: ['social', 'psychological']),
    SpecialistResidentFile(
        id: 'rf5',
        name: 'فاطمة الزهراء',
        nameEn: 'Fatma El Zahraa',
        room: '١٠٥',
        status: 'updated',
        lastUpdate: '١٥ أبريل',
        initials: 'فا',
        categories: ['admin']),
    SpecialistResidentFile(
        id: 'rf6',
        name: 'عمر المختار',
        nameEn: 'Omar El Mokhtar',
        room: '٢٠١',
        status: 'pending',
        lastUpdate: '١٤ أبريل',
        initials: 'عم',
        categories: ['social']),
  ];

  String residentFilesSearchQuery = '';
  String selectedResidentFileCategory = 'الكل';

  void setResidentFilesSearchQuery(String query) {
    residentFilesSearchQuery = query;
    notifyListeners();
  }

  void setSelectedResidentFileCategory(String category) {
    selectedResidentFileCategory = category;
    notifyListeners();
  }

  List<SpecialistResidentFile> get filteredResidentFiles {
    List<SpecialistResidentFile> filtered = residentFiles;

    if (selectedResidentFileCategory != 'الكل') {
      final catMap = {
        'اجتماعي': 'social',
        'نفسي': 'psychological',
        'طبي': 'medical',
        'إداري': 'admin',
      };
      final targetCat = catMap[selectedResidentFileCategory];
      if (targetCat != null) {
        filtered =
            filtered.where((f) => f.categories.contains(targetCat)).toList();
      }
    }

    if (residentFilesSearchQuery.isNotEmpty) {
      filtered = filtered
          .where((f) =>
              f.name.contains(residentFilesSearchQuery) ||
              f.room.contains(residentFilesSearchQuery))
          .toList();
    }

    return filtered;
  }

  // --- NURSE MEDICAL ADMIN STATE ---
  List<MedicalSession> medicalSessions = [
    MedicalSession(
        id: 's1',
        type: 'doctor',
        specialistName: 'د. خالد صفا',
        time: '١٠:٣٠ ص',
        date: 'اليوم',
        notes: 'يُنصح بالاستمرار على الخطة العلاجية الحالية.',
        residentName: 'الحاج محمود'),
    MedicalSession(
        id: 's2',
        type: 'pt',
        specialistName: 'أ. سامر (علاج طبيعي)',
        time: '١٢:٠٠ م',
        date: 'اليوم',
        notes: 'تمارين تقوية عضلات الفخذ والمشي لمدة ١٥ دقيقة.',
        residentName: 'الحاج محمود'),
    MedicalSession(
        id: 's3',
        type: 'doctor',
        specialistName: 'د. ليلى حسن (قلب)',
        time: '٠٩:٠٠ ص',
        date: 'أمس',
        notes: 'الحالة مستقرة، استكمال علاج القلب بانتظام.',
        residentName: 'فاطمة الزهراء'),
  ];

  List<MedicalPrescription> medicalPrescriptions = [
    MedicalPrescription(
        id: 'p1',
        title: 'روشتة القلب وضبط الحالة',
        doctorName: 'د. خالد صفا',
        date: '١٨ أبريل ٢٠٢٤',
        residentName: 'الحاج محمود'),
    MedicalPrescription(
        id: 'p2',
        title: 'تقرير أشعة الصدر',
        doctorName: 'مركز النيل للأشعة',
        date: '١٠ أبريل ٢٠٢٤',
        residentName: 'الحاج محمود'),
  ];

  void addMedication(String residentName, Medication med) {
    medications.insert(0, med);

    // إرسال إشعار للأسرة عند إضافة دواء جديد
    triggerNotification(
      title: 'تمت إضافة جرعة دواء جديدة 💊',
      body:
          'قام فريق التمريض بإضافة دواء (${med.name}) لخطة $residentName العلاجية.',
      type: 'medical',
      targetRole: 'عائلة',
    );

    notifyListeners();
  }

  void logMedicalSession(MedicalSession session) {
    medicalSessions.insert(0, session);
    notifyListeners();
  }

  void addPrescription(MedicalPrescription p) {
    medicalPrescriptions.insert(0, p);

    // إرسال إشعار للأسرة عند إضافة روشتة طبية جديدة
    triggerNotification(
      title: 'روشتة طبية جديدة 📄',
      body:
          'تمت إضافة روشتة طبية جديدة لـ ${p.residentName} بواسطة ${p.doctorName}.',
      type: 'medical',
      targetRole: 'عائلة',
    );

    notifyListeners();
  }

  // --- ADMIN STATE ---
  List<CenterOperationalStat> get adminStats => [
        CenterOperationalStat(
            label: 'نسبة الإشغال',
            value: '٩٢٪',
            trend: '↑ ٢٪ عن الشهر الماضي',
            isPositive: true,
            history: [0.8, 0.82, 0.85, 0.88, 0.9, 0.92]),
        CenterOperationalStat(
            label: 'إيرادات الشهر',
            value: '٤٢٠,٠٠٠ ج.م',
            trend: '↑ ٥٪ هذا الربع',
            isPositive: true,
            history: [350.0, 380.0, 400.0, 410.0, 420.0, 420.0]),
        CenterOperationalStat(
            label: 'الحالات الحرجة',
            value: '$criticalResidentsCount',
            trend:
                criticalResidentsCount > 2 ? '↑ تحتاج متابعة' : '↓ مستقر وئام',
            isPositive: criticalResidentsCount <= 2,
            history: [5.0, 4.0, 3.0, criticalResidentsCount.toDouble()]),
        CenterOperationalStat(
            label: 'رضا الأهالي',
            value: '٤.٨ / ٥',
            trend: '↑ مستقر عند مستوى عالٍ',
            isPositive: true,
            history: [4.5, 4.6, 4.7, 4.8]),
      ];

  List<StaffPerformance> staffPerformanceList = [
    StaffPerformance(
        id: 'st1',
        name: 'أ. منى (تمريض)',
        role: 'Nurse',
        completionRate: 0.98,
        lastActive: 'نشط الآن',
        status: 'online'),
    StaffPerformance(
        id: 'st2',
        name: 'أ. نور الدين',
        role: 'Specialist',
        completionRate: 0.92,
        lastActive: 'منذ ١٥ دقيقة',
        status: 'online'),
    StaffPerformance(
        id: 'st3',
        name: 'أ. سامر (علاج طبيعي)',
        role: 'PT',
        completionRate: 0.85,
        lastActive: 'منذ ٢ ساعة',
        status: 'offline'),
  ];

  int get totalStaffCount => staffPerformanceList.length;
  int get activeStaffCount =>
      staffPerformanceList.where((s) => s.status == 'online').length;
  double get averageStaffCompletion {
    if (staffPerformanceList.isEmpty) return 0.0;
    final total = staffPerformanceList
        .map((s) => s.completionRate)
        .reduce((a, b) => a + b);
    return total / staffPerformanceList.length;
  }

  void addStaff(StaffPerformance staff) {
    staffPerformanceList.insert(0, staff);

    triggerNotification(
      title: 'موظف جديد بالمنشأة 📋',
      body: 'تم تسجيل ${staff.name} ضمن الطاقم (${staff.role}).',
      type: 'admin',
      targetRole: 'مدير',
    );

    notifyListeners();
  }

  void joinOpportunity(String opportunityId) {
    final idx = volunteerOpportunities.indexWhere((o) => o.id == opportunityId);
    if (idx != -1) {
      final opp = volunteerOpportunities[idx];

      // Add to bookings if not already there
      final bookingId = 'book_$opportunityId';
      if (!volunteerBookings.any((b) => b.id == bookingId)) {
        volunteerBookings.insert(
          0,
          VolunteerBooking(
            id: bookingId,
            title: opp.title,
            timeInfo: '${opp.dateInfo} · ${opp.hours} ساعة',
            day: DateTime.now().day + 1,
            month: 'أبريل',
            status: 'confirmed',
            location: opp.org,
            points: opp.points,
          ),
        );

        // Update slots instead of removing
        volunteerOpportunities[idx] = VolunteerOpportunity(
          id: opp.id,
          title: opp.title,
          org: opp.org,
          dateInfo: opp.dateInfo,
          icon: opp.icon,
          tags: opp.tags,
          hours: opp.hours,
          points: opp.points,
          isNew: opp.isNew,
          description: opp.description,
          totalSlots: opp.totalSlots,
          filledSlots: opp.filledSlots + 1,
        );

        // Trigger a real notification
        triggerNotification(
          title: 'تم الانضمام بنجاح! 🎉',
          body: 'أنت الآن مسجل في "${opp.title}". موعدنا قادماً!',
          type: 'volunteer',
          targetRole: 'متطوع',
        );

        notifyListeners();
      }
    }
  }

  void cancelBooking(String bookingId) {
    final idx = volunteerBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final booking = volunteerBookings[idx];
      volunteerBookings[idx] = VolunteerBooking(
        id: booking.id,
        title: booking.title,
        timeInfo: booking.timeInfo,
        day: booking.day,
        month: booking.month,
        status: 'cancelled',
        location: booking.location,
        points: booking.points,
        isUrgent: booking.isUrgent,
        startTime: booking.startTime,
        isRatingRequired: booking.isRatingRequired,
      );
      notifyListeners();
    }
  }

  void confirmAttendance(String bookingId) {
    final idx = volunteerBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = volunteerBookings[idx];
      volunteerBookings[idx] = VolunteerBooking(
        id: b.id,
        title: b.title,
        timeInfo: b.timeInfo,
        day: b.day,
        month: b.month,
        status: 'done',
        location: b.location,
        points: b.points,
        isUrgent: false,
        startTime: b.startTime,
        isRatingRequired: true,
      );
      addPoints(b.points);

      triggerNotification(
        title: 'تم تأكيد الحضور! ✅',
        body:
            'شكراً لمساهمتك في "${b.title}". تم إضافة ${b.points} نقطة لحسابك.',
        type: 'volunteer',
        targetRole: 'متطوع',
      );

      notifyListeners();
    }
  }

  void submitBookingRating(String bookingId) {
    final idx = volunteerBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = volunteerBookings[idx];
      volunteerBookings[idx] = VolunteerBooking(
        id: b.id,
        title: b.title,
        timeInfo: b.timeInfo,
        day: b.day,
        month: b.month,
        status: b.status,
        location: b.location,
        points: b.points,
        isUrgent: b.isUrgent,
        startTime: b.startTime,
        isRatingRequired: false,
      );
      notifyListeners();
    }
  }

  void saveMedicalVitals({
    required String residentName,
    required String bp,
    required String sugar,
    required String temp,
  }) {
    // In a real app, this would save to a database.
    // For this prototype, we'll create a new MedicalSession entry and trigger a notification.

    final newSession = MedicalSession(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      type: 'vitals', // Change type to 'vitals'
      specialistName: 'الممرضة منى',
      time: 'الآن',
      date: 'اليوم',
      notes:
          'تم فحص المؤشرات الحيوية: الضغط ($bp)، السكر ($sugar مجم/دل)، الحرارة ($temp°)',
      residentName: residentName,
    );

    medicalSessions.insert(0, newSession);

    // Trigger a real notification
    triggerNotification(
      title: 'تم حفظ القراءات 🏥',
      body: 'تم تسجيل العلامات الحيوية لـ $residentName بنجاح.',
      type: 'medical',
    );

    notifyListeners(); // Ensure UI updates
  }

  void addFamilyVisit(FamilyVisit visit) {
    familyVisits.insert(0, visit);
    notifyListeners();
  }

  void approveVisit(String id) {
    final idx = familyVisits.indexWhere((v) => v.id == id);
    if (idx != -1) {
      familyVisits[idx] = familyVisits[idx].copyWith(status: 'upcoming');
      notifyListeners();
    }
  }

  void rejectVisit(String id) {
    final idx = familyVisits.indexWhere((v) => v.id == id);
    if (idx != -1) {
      familyVisits[idx] = familyVisits[idx].copyWith(status: 'cancelled');
      notifyListeners();
    }
  }

  void sendFamilyMessage(String message, String residentName) {
    // LINK: Family to Specialist
    triggerNotification(
      title: 'رسالة من الأهل 📩',
      body: 'بخصوص $residentName: $message',
      type: 'complaint',
      targetRole: 'أخصائي',
    );
    notifyListeners();
  }

  void clearUnpaidBills() {
    // Mark all bills as paid for simulation
    familyBills = familyBills.map((b) => b.copyWith(isPaid: true)).toList();
    notifyListeners();
  }

  void addSocialNeed(SocialSpecialistNeed need) {
    socialNeeds.insert(0, need);

    triggerNotification(
      title: 'احتياج جديد مسجل 🛡️',
      body: 'تم تسجيل احتياج ${need.type} للغرفة ${need.roomNumber}.',
      type: 'specialist',
      targetRole: 'أخصائي',
    );

    notifyListeners();
  }

  void updateResident(SpecialistResidentFile resident) {
    final index = residentFiles.indexWhere((r) => r.id == resident.id);
    if (index != -1) {
      residentFiles[index] = resident;
      notifyListeners();
    }
  }

  void addResident(SpecialistResidentFile resident) {
    residentFiles.insert(0, resident);

    // Notify Admin and Specialist roles about the new resident
    triggerNotification(
      title: 'إضافة مقيم جديد 👥',
      body: 'تم تسجيل ${resident.name} في الغرفة ${resident.room}.',
      type: 'admin',
      targetRole: 'مدير',
    );

    triggerNotification(
      title: 'مقيم جديد تحت الرعاية 🛡️',
      body: 'الحاج ${resident.name} انضم للمسكن في الغرفة ${resident.room}.',
      type: 'social',
      targetRole: 'أخصائي',
    );

    notifyListeners();
  }

  // --- ANALYTICS & COMPLAINT RESOLUTION ---

  double get medicationComplianceRate {
    if (medications.isEmpty) return 1.0;
    final taken = medications.where((m) => m.isTaken).length;
    return taken / medications.length;
  }

  int get unresolvedComplaintsCount =>
      socialComplaints.where((c) => c.status != 'done').length;

  void closeComplaint(String id, String resolutionNote) {
    final idx = socialComplaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final c = socialComplaints[idx];

      // Update status and add to timeline
      final updatedTimeline = List<ComplaintStep>.from(c.timeline);
      updatedTimeline.add(ComplaintStep(
        text: 'تم الحل: $resolutionNote',
        time: 'الآن',
        status: 'done',
      ));

      socialComplaints[idx] = SocialSpecialistComplaint(
        id: c.id,
        title: c.title,
        residentName: c.residentName,
        room: c.room,
        date: c.date,
        priority: c.priority,
        status: 'done',
        category: c.category,
        icon: c.icon,
        timeline: updatedTimeline,
      );

      // Notify the family (simulated by triggering a notification for 'أهل' role)
      triggerNotification(
        title: 'تم حل شكواكم بنجاح ✅',
        body:
            'بخصوص "${c.title}" لسرير ${c.residentName}. التفاصيل: $resolutionNote',
        type: 'social',
        targetRole: 'أهل',
      );

      notifyListeners();
    }
  }

  String generatePerformanceSummary() {
    final compliance = (medicationComplianceRate * 100).toInt();
    const occupancy = 94; // Mocked for now
    return '''
ملخص أداء دار طبطبة للرعاية
التاريخ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

1. الإشغال: $occupancy% (مستوى ممتاز)
2. الالتزام الدوائي: $compliance%
3. الشكاوى المفتوحة: $unresolvedComplaintsCount شكاوى
4. الطاقم النشط: $activeStaffCount من أصل $totalStaffCount موظف

التوصيات: 
- الحفاظ على مستوى الاستجابة السريع للشكاوى.
- تعزيز فترات الراحة للطاقم الطبي لضمان استمرارية الجودة.
''';
  }

  Future<String> exportReport(String format) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    final dateStr =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    final fileName = "Taptaba_Report_$dateStr.$format";
    return fileName;
  }

  // --- MEMORY WALL ---

  List<MemoryMoment> memoryMoments = [
    MemoryMoment(
      id: 'm1',
      residentId: 'r1',
      residentName: 'الحاج محمود',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=400',
      activityTitle: 'جلسة اليوغا الصباحية 🧘',
      date: 'منذ ساعتين',
      appreciations: 3,
    ),
    MemoryMoment(
      id: 'm2',
      residentId: 'r1',
      residentName: 'الحاج محمود',
      imageUrl:
          'https://images.unsplash.com/photo-1595113316349-9fa4eb24f884?auto=format&fit=crop&q=80&w=400',
      activityTitle: 'ورشة الفخار اليدوي 🏺',
      date: 'أمس',
      appreciations: 5,
    ),
  ];

  void addMemoryMoment(MemoryMoment moment) {
    memoryMoments.insert(0, moment);

    // Notify the target family
    triggerNotification(
      title: 'لحظة سعادة جديدة 📸',
      body:
          'والدكم ${moment.residentName} يستمتع بوقته الآن في "${moment.activityTitle}".',
      type: 'social',
      targetRole: 'أهل',
    );

    notifyListeners();
  }

  void addAppreciation(String momentId) {
    final idx = memoryMoments.indexWhere((m) => m.id == momentId);
    if (idx != -1) {
      final m = memoryMoments[idx];
      memoryMoments[idx] = MemoryMoment(
        id: m.id,
        residentId: m.residentId,
        residentName: m.residentName,
        imageUrl: m.imageUrl,
        activityTitle: m.activityTitle,
        date: m.date,
        appreciations: m.appreciations + 1,
      );

      // Notify specialist about the appreciation (Bonus)
      triggerNotification(
        title: 'عائلة ${m.residentName} سعيدة! ❤️',
        body:
            'تم استلام "شكراً" من عائلة المقيم بخصوص صورة "${m.activityTitle}".',
        type: 'social',
        targetRole: 'أخصائي',
      );

      notifyListeners();
    }
  }

  // --- NAVIGATION (ELDERLY) ---

  int currentElderlyTabIndex = 0;
  void setElderlyTabIndex(int index) {
    currentElderlyTabIndex = index;
    notifyListeners();
  }

  MemoryMoment? get latestMemoryMoment =>
      memoryMoments.isNotEmpty ? memoryMoments.first : null;

  bool hasGalleryPermission = false;

  Future<void> requestGalleryPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    hasGalleryPermission = ps.isAuth;
    if (hasGalleryPermission) {
      // Fetch real images from gallery
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        List<AssetEntity> photos =
            await albums[0].getAssetListPaged(page: 0, size: 50);
        deviceGalleryImages = photos;
      }
    }
    notifyListeners();
  }

  void setGalleryPermission(bool val) {
    hasGalleryPermission = val;
    notifyListeners();
  }

  // Volunteer Profile Methods
  void updateVolunteerProfile(VolunteerProfile newProfile) {
    volunteerProfile = newProfile;
    notifyListeners();
  }

  void addVolunteerSkill(String skill) {
    if (!volunteerProfile.skills.contains(skill)) {
      final updatedSkills = List<String>.from(volunteerProfile.skills)
        ..add(skill);
      volunteerProfile = volunteerProfile.copyWith(skills: updatedSkills);
      notifyListeners();
    }
  }

  void removeVolunteerSkill(String skill) {
    final updatedSkills = List<String>.from(volunteerProfile.skills)
      ..remove(skill);
    volunteerProfile = volunteerProfile.copyWith(skills: updatedSkills);
    notifyListeners();
  }

  void uploadVolunteerDocument(String type, String fileName) {
    if (type == 'cv') {
      volunteerProfile = volunteerProfile.copyWith(cvFileName: fileName);
    } else if (type == 'recommendation') {
      volunteerProfile =
          volunteerProfile.copyWith(recommendationFileName: fileName);
    }

    triggerNotification(
      title: 'تم رفع الملف بنجاح 📁',
      body: 'تم تسجيل ملف "$fileName" كـ $type في ملفك الشخصي.',
      type: 'admin',
      targetRole: 'متطوع',
    );

    notifyListeners();
  }

  // --- FAMILY INTERACTION METHODS ---
  void startVideoCall(String name, String initials) {
    activeCallerName = name;
    activeCallerInitials = initials;
    isVideoCallActive = true;
    isIncomingCall = false; // Close incoming banner if we start a call
    notifyListeners();
  }

  void acceptCall() {
    isVideoCallActive = true;
    isIncomingCall = false;
    notifyListeners();
  }

  void rejectCall() {
    isIncomingCall = false;
    notifyListeners();
  }

  void endVideoCall() {
    isVideoCallActive = false;
    notifyListeners();
  }

  void sendVoiceMessageFromResident(String title) {
    final newMsg = VoiceMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'resident', // Special ID for the resident themselves
      title: title,
      timeDescription: 'الآن',
    );
    voiceMessagesList.insert(0, newMsg);

    // Add points for communicating!
    addPoints(15);

    triggerNotification(
      title: 'تم إرسال الرسالة! 🎙️',
      body: 'رسالتك الصوتية في طريقها لعائلتك الآن.',
      type: 'social',
      targetRole: 'مسن',
    );

    notifyListeners();
  }

  // --- NURSING OPERATIONS STATE ---
  List<CareTask> careTasks = [
    CareTask(
        id: 'c1',
        residentName: 'الحاج محمود سالم',
        title: 'تغيير ملابس الصباح',
        category: 'شخصية',
        time: '٠٧:٠٠ ص'),
    CareTask(
        id: 'c2',
        residentName: 'الحاج محمود سالم',
        title: 'رياضة تنفس خفيفة',
        category: 'ترفيهية',
        time: '٠٩:٠٠ ص'),
    CareTask(
        id: 'c3',
        residentName: 'الحاجة فاطمة علي',
        title: 'استحمام دوري',
        category: 'فندقية',
        time: '٠٨:٣٠ ص'),
    CareTask(
        id: 'c4',
        residentName: 'الحاجة فاطمة علي',
        title: 'تمارين حركة للأطراف',
        category: 'شخصية',
        time: '١٠:٠٠ ص'),
  ];

  List<InventoryItem> inventoryItems = [
    InventoryItem(
        id: 'i1',
        name: 'أسبوسيد ٧٥ مجم',
        category: 'أدوية',
        currentStock: 12,
        minRequired: 20,
        unit: 'شريط'),
    InventoryItem(
        id: 'i2',
        name: 'حفاضات كبار (L)',
        category: 'شخصي',
        currentStock: 45,
        minRequired: 30,
        unit: 'عبوة'),
    InventoryItem(
        id: 'i3',
        name: 'شاش معقم',
        category: 'مستلزمات',
        currentStock: 5,
        minRequired: 15,
        unit: 'علبة'),
    InventoryItem(
        id: 'i4',
        name: 'كونكور ٥ مجم',
        category: 'أدوية',
        currentStock: 25,
        minRequired: 10,
        unit: 'شريط'),
  ];

  List<DoctorVisit> doctorVisits = [
    DoctorVisit(
        id: 'v1',
        doctorName: 'د. يحيى الفخراني',
        specialty: 'باطنة وقلب',
        date: DateTime.now().subtract(const Duration(days: 2)),
        purpose: 'متابعة ضغط دورية',
        results: 'استقرار الحالة مع تعديل بسيط في جرعة الصباح',
        residentName: 'الحاج محمود سالم'),
    DoctorVisit(
        id: 'v2',
        doctorName: 'د. سميحة أيوب',
        specialty: 'عظام ومفاصل',
        date: DateTime.now().add(const Duration(days: 1)),
        purpose: 'فحص آلام الركبة',
        residentName: 'الحاجة فاطمة علي'),
  ];

  List<MealPlan> mealPlans = [
    MealPlan(
        residentName: 'الحاج محمود سالم',
        breakfast: 'فول بالزيت الحار، بيض مسلوق',
        lunch: 'فراخ مشوية، خضار سوتيه، أرز بني',
        dinner: 'زبادي بالعسل، ثمرة فاكهة',
        specialInstructions: 'قليل الملح جداً، منع السكريات'),
    MealPlan(
        residentName: 'الحاجة فاطمة علي',
        breakfast: 'جبنة قريش، توست سن',
        lunch: 'سمك مشوي، سلطة خضراء',
        dinner: 'شوربة خضار دافئة',
        specialInstructions: 'تقطيع الطعام قطع صغيرة جداً لتسهيل البلع'),
  ];

  List<ActivitySession> activitySessions = [
    ActivitySession(
        id: 's1',
        title: 'حلقة قراءة الصالون',
        description: 'قراءة مقتطفات من الأدب العربي ومناقشتها',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        location: 'القاعة الرئيسية',
        participants: ['الحاج محمود', 'الحاجة فاطمة']),
    ActivitySession(
        id: 's2',
        title: 'عرض سينمائي كلاسيكي',
        description: 'فيلم "غزل البنات" - نجيب الريحاني',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        location: 'غرفة العرض',
        participants: ['جميع المقيمين']),
  ];

  // Nursing Operations Methods
  void toggleCareTask(String id) {
    final idx = careTasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      careTasks[idx].isCompleted = !careTasks[idx].isCompleted;
      notifyListeners();
    }
  }

  void updateInventoryStock(String id, int change) {
    final idx = inventoryItems.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final newItem = InventoryItem(
        id: inventoryItems[idx].id,
        name: inventoryItems[idx].name,
        category: inventoryItems[idx].category,
        currentStock: inventoryItems[idx].currentStock + change,
        minRequired: inventoryItems[idx].minRequired,
        unit: inventoryItems[idx].unit,
      );
      inventoryItems[idx] = newItem;
      notifyListeners();
    }
  }

  void updateMealPlan(MealPlan plan) {
    final idx =
        mealPlans.indexWhere((p) => p.residentName == plan.residentName);
    if (idx != -1) {
      mealPlans[idx] = plan;
      notifyListeners();
    } else {
      mealPlans.add(plan);
    }
  }

  // بدء عملية التدخل الاجتماعي وتغيير حالة الشكوى
  void startIntervention(String id) {
    final idx = socialComplaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final updatedTimeline =
          List<ComplaintStep>.from(socialComplaints[idx].timeline);
      updatedTimeline.add(ComplaintStep(
        text: 'بدء التدخل والمتابعة',
        time: 'الآن',
        status: 'progress',
      ));

      socialComplaints[idx] = SocialSpecialistComplaint(
        id: socialComplaints[idx].id,
        title: socialComplaints[idx].title,
        residentName: socialComplaints[idx].residentName,
        room: socialComplaints[idx].room,
        date: socialComplaints[idx].date,
        priority: socialComplaints[idx].priority,
        status: 'progress',
        category: socialComplaints[idx].category,
        icon: socialComplaints[idx].icon,
        timeline: updatedTimeline,
      );

      notifyListeners();
    }
  }

  // حفظ تقييم اجتماعي جديد وتحديث درجات المقيم
  void saveSocialAssessment({
    required String residentId,
    required Map<String, double> newScores,
    required bool needsIntervention,
    String? notes,
  }) {
    final idx = filteredResidentScores.indexWhere((r) => r.id == residentId);
    if (idx != -1) {
      final r = filteredResidentScores[idx];

      // Update scores
      final updatedScores = Map<String, double>.from(r.scores);
      newScores.forEach((key, value) {
        updatedScores[key] = value;
      });

      filteredResidentScores[idx] = SocialSpecialistResidentScore(
        id: r.id,
        name: r.name,
        room: r.room,
        date: 'الآن',
        isUrgent: needsIntervention,
        scores: updatedScores,
        initials: r.initials,
        healthStatus: r.healthStatus,
        lastAssessment: DateTime.now(),
      );

      // Add a social notification if urgent
      if (needsIntervention) {
        notifications.insert(
            0,
            TaptabaNotification(
              id: 'soc_${DateTime.now().millisecondsSinceEpoch}',
              title: 'تنبيه تدخل اجتماعي: ${r.name}',
              body: 'المقيم بحاجة لمتابعة عاجلة بناءً على التقييم الأخير.',
              time: 'الآن',
              type: 'social',
              targetRole: 'specialist',
              residentId: residentId,
              isRead: false,
            ));
      }

      notifyListeners();
    }
  }

  // خريطة الاحتياجات: تجميع بيانات المقيمين مع حساب لون الحالة بصرياً
  List<Map<String, dynamic>> get needMapData {
    return filteredResidentScores.map((r) {
      // Calculate overall social health
      double avgScore = 0;
      if (r.scores.isNotEmpty) {
        avgScore = r.scores.values.reduce((a, b) => a + b) / r.scores.length;
      }

      Color statusColor;
      if (r.isUrgent || avgScore < 0.4) {
        statusColor = const Color(0xFFef4444); // High Need
      } else if (avgScore < 0.7) {
        statusColor = const Color(0xFFf59e0b); // Medium Need
      } else {
        statusColor = const Color(0xFF10b981); // Stable
      }

      return {
        'id': r.id,
        'name': r.name,
        'room': r.room,
        'color': statusColor,
        'score': avgScore,
        'initials': r.initials,
      };
    }).toList();
  }

  // وضع علامة "تم الحل" على التنبيهات الإدارية
  void resolveNotification(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  // --- MEMORIES METHODS ---
  Future<void> pickMemoryImage() async {
    // 1. طلب إذن الوصول للصور
    final PermissionStatus status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      final ImagePicker picker = ImagePicker();
      // 2. فتح معرض الصور لاختيار صورة
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // تقليل الجودة قليلاً لتوفير المساحة
      );

      if (image != null) {
        // 3. إنشاء عنصر ذكرى جديد بالصورة المختارة
        final newItem = MemoryItem(
          id: 'mem_custom_${DateTime.now().millisecondsSinceEpoch}',
          category: 'الاستوديو',
          title: 'ذكرى من الاستوديو',
          date: 'اليوم',
          type: 'image',
          assetPath: image.path, // تخزين المسار المحلي للملف
        );

        // 4. إضافتها إلى القائمة وتنبيه الواجهات
        memoriesList.insert(0, newItem);
        notifyListeners();

        triggerNotification(
          title: 'تمت إضافة ذكرى جديدة! 📸',
          body: 'ستجدها الآن في صندوق ذكرياتك الجميل.',
          type: 'social',
          targetRole: 'مسن',
        );
      }
    } else {
      // التعامل مع حالة رفض الإذن
      debugPrint('Permission denied for photos');
    }
  }

  // --- INTEGRATION & CROSS-ROLE REQUESTS ---

  void submitComplaint(String message, String type, String fromRole) {
    // محاكاة إرسال شكوى/طلب إلى الأخصائي الاجتماعي أو الإدارة
    // في الواقع سيتم رفعها للـ Backend وإنشاء Object من نوع Complaint
    final complaint = SocialSpecialistComplaint(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      residentName: fromRole == 'مسن' ? currentUser.name : 'أحد أفراد الأسرة',
      room: '١١٢', // محاكاة لغرفة المسن
      date: 'اليوم',
      title: type,
      category: 'عام',
      icon: '🚨',
      status: 'open',
      priority: 'high',
      timeline: [ComplaintStep(text: message, time: 'الآن', status: 'pending')],
    );
    socialComplaints.insert(0, complaint);

    // إرسال إشعار تأكيد للمرسل
    triggerNotification(
      title: 'تم إرسال طلبك بنجاح ✅',
      body: 'قام فريقنا باستلام طلبك بخصوص "$type" وسيتم التعامل معه فوراً.',
      type: 'system',
      targetRole: fromRole,
    );
    notifyListeners();
  }

  void requestConsultation(String type) {
    // محاكاة طلب استشارة من الأسرة للطبيب أو الأخصائي
    triggerNotification(
      title: 'طلب استشارة مرسل 💬',
      body:
          'تم تحويل طلب الاستشارة الـ $type إلى الفريق المختص، سيتم التواصل معك قريباً.',
      type: 'medical',
      targetRole: 'أسرة',
    );
    notifyListeners();
  }

  void addVolunteerOpportunity(VolunteerOpportunity opp) {
    // إضافة الفرصة إلى قائمة الفرص التطوعية لتظهر فوراً للمتطوعين
    volunteerOpportunities.insert(0, opp);

    // إشعار الإدارة بنجاح الإنشاء
    triggerNotification(
      title: 'تم نشر الفرصة بنجاح 🌟',
      body: 'أصبحت فرصة "${opp.title}" متاحة الآن للمتطوعين.',
      type: 'system',
      targetRole: 'إدارة',
    );

    notifyListeners();
  }

  void rateVolunteerSession(String volunteerId, int ratingScore) {
    // تقييم المتطوع من قِبل المسن (ratingScore: 1 لغير سعيد، 2 لعادي، 3 لسعيد)
    int pointsEarned = 0;
    if (ratingScore == 3) {
      pointsEarned = 15;
    } else if (ratingScore == 2) pointsEarned = 5;

    // إشعار للمسن بشكره على التقييم
    triggerNotification(
      title: 'شكراً لتقييمك! 💖',
      body: 'رأيك يهمنا جداً في تحسين جودة الرعاية المقدمة لك.',
      type: 'system',
      targetRole: 'مسن',
    );

    // تحديث نقاط المتطوع إذا أردنا (للمحاكاة فقط نعرض إشعار للمتطوع لو كان مسجلاً)
    notifyListeners();
  }

  void sendEncouragementMessage(String messageType) {
    // إرسال رسالة تشجيعية من الأسرة إلى المسن (صوتية أو هدية افتراضية)
    String title =
        messageType == 'voice' ? 'رسالة صوتية جديدة 🎤' : 'هدية جديدة 🎁';
    String body = messageType == 'voice'
        ? 'عائلتك أرسلت لك رسالة صوتية تشجيعية لسماعها!'
        : 'عائلتك أرسلت لك باقة ورد افتراضية تقديراً لالتزامك 🌸';

    triggerNotification(
      title: title,
      body: body,
      type: 'family',
      targetRole: 'مسن',
    );
    notifyListeners();
  }

  // --- Specialist Recommendations ---
  List<SpecialistRecommendation> specialistRecommendations = [];

  void addSpecialistRecommendation(SpecialistRecommendation rec) {
    specialistRecommendations.insert(0, rec);
    triggerNotification(
      title: 'توصية نفسية جديدة 🧠',
      body: 'توصية للمقيم ${rec.residentName}: ${rec.content}',
      type: 'medical',
      targetRole: 'ممرض',
    );
    notifyListeners();
  }
}

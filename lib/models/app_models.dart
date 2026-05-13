// نموذج يمثل بيانات المستخدم (المسن) ونظام النقاط التحفيزي
class User {
  String name; // اسم المستخدم
  int points; // إجمالي النقاط المكتسبة من الأنشطة
  int streakDays; // عدد الأيام المتتالية للنشاط (التحدي اليومي)
  int completedActivities; // إجمالي الأنشطة التي أتمها المستخدم

  User({
    required this.name,
    required this.points,
    required this.streakDays,
    required this.completedActivities,
  });
}

// نموذج يمثل الدواء والجرعة وحالة التناول والمتابعة
class Medication {
  final String id; // معرف فريد للدواء
  final String name; // اسم الدواء
  final String dosage; // الجرعة (مثلاً: قرص واحد)
  final String timeDescription; // وصف الوقت (مثلاً: ٨ صباحاً)
  final String timeOfDay; // الفترة الزمنية: 'الصباح', 'الظهر', 'المساء'
  bool isTaken; // هل تم تناول الجرعة؟
  bool isSkipped; // هل تم تجاوز الجرعة عمداً؟
  String? skipReason; // سبب تجاوز الجرعة (مثلاً: عدم الرغبة)
  final String dayTag; // تصنيف اليوم: 'أمس', 'اليوم', 'غداً'
  final String? residentName; // اسم المقيم (يستخدم في واجهة الممرض)
  final DateTime? scheduledTime; // الوقت المحدد للجرعة بدقة

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timeDescription,
    required this.timeOfDay,
    this.isTaken = false,
    this.isSkipped = false,
    this.skipReason,
    this.dayTag = 'اليوم',
    this.residentName,
    this.scheduledTime,
  });

  // التحقق مما إذا كانت الجرعة قد فاتت موعدها ولم تؤخذ
  bool get isMissed {
    if (isTaken || isSkipped || scheduledTime == null) return false;
    return DateTime.now().isAfter(scheduledTime!);
  }
}

// نموذج يمثل فرد من أفراد العائلة وسهولة الوصول إليه
class FamilyMember {
  String id;
  String name; // اسم قريب المسن
  String relation; // صلة القرابة (ابن، حفيدة، إلخ)
  String avatarPath; // مسار الصورة الشخصية
  String initials; // الحروف الأولى من الاسم (للعرض البديل)
  String phoneNumber; // رقم الهاتف لإجراء مكالمات حقيقية
  String? zoomLink; // رابط زووم للمكالمات المرئية
  bool isAvailable; // هل القريب متاح حالياً للمكالمة؟

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.avatarPath,
    required this.initials,
    required this.phoneNumber,
    this.zoomLink,
    this.isAvailable = false,
  });
}

// نموذج يمثل رسالة صوتية مرسلة من العائلة للمسن
class VoiceMessage {
  String id;
  String senderId; // معرف مرسل الرسالة
  String title; // عنوان الرسالة أو موضوعها
  String timeDescription; // وقت الإرسال (مثلاً: منذ ساعتين)
  bool isPlaying; // هل الرسالة قيد التشغيل حالياً؟
  bool isUnread; // هل الرسالة جديدة ولم تسمع بعد؟

  VoiceMessage({
    required this.id,
    required this.senderId,
    required this.title,
    required this.timeDescription,
    this.isPlaying = false,
    this.isUnread = true,
  });
}

class MemoryItem {
  String id;
  String category; // 'أسرة', 'رحلات', 'فيديو', 'مناسبات'
  String title;
  String date;
  String type; // 'image', 'video'
  String assetPath;

  MemoryItem({
    required this.id,
    required this.category,
    required this.title,
    required this.date,
    required this.type,
    required this.assetPath,
  });
}

class Activity {
  String id;
  String name;
  String emoji;
  String location;
  String time;
  String status; // 'done', 'active', 'later', 'coming'
  String badges;
  int pointsReward;
  String dayTag; // 'أمس', 'اليوم', 'غداً', 'الأسبوع'

  Activity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.location,
    required this.time,
    required this.status,
    required this.badges,
    required this.pointsReward,
    this.dayTag = 'اليوم',
  });
}

class VolunteerOpportunity {
  final String id;
  final String title;
  final String org;
  final String dateInfo;
  final String icon;
  final List<String> tags;
  final int hours;
  final bool isNew;
  final String description;
  final int totalSlots;
  final int filledSlots;
  final int points;

  VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.org,
    required this.dateInfo,
    required this.icon,
    required this.tags,
    required this.hours,
    this.isNew = false,
    this.description = '',
    this.totalSlots = 1,
    this.filledSlots = 0,
    this.points = 10,
  });

  String get status => filledSlots < totalSlots ? 'متاحة' : 'مكتملة';
  String get date => dateInfo;
}

class VolunteerImpact {
  final int residentsServed;
  final int positiveRatings;
  final int totalHours;

  VolunteerImpact({
    required this.residentsServed,
    required this.positiveRatings,
    required this.totalHours,
  });
}

class VolunteerBooking {
  final String id;
  final String title;
  final String timeInfo;
  final int day;
  final String month;
  final String status; // 'confirmed', 'done', 'cancelled'
  final String location;
  final int points;
  final bool isUrgent;
  final DateTime startTime;
  final bool isRatingRequired;

  VolunteerBooking({
    required this.id,
    required this.title,
    required this.timeInfo,
    required this.day,
    required this.month,
    required this.status,
    this.location = '',
    this.points = 10,
    this.isUrgent = false,
    DateTime? startTime,
    this.isRatingRequired = false,
  }) : startTime = startTime ?? DateTime.now().add(const Duration(hours: 26));
}

class VolunteerCertificate {
  final String id;
  final String name;
  final String icon;
  final String date;
  final bool isLocked;
  final String progressInfo;
  final String awardTitle;
  final String description;
  final double progress;

  VolunteerCertificate({
    required this.id,
    required this.name,
    required this.icon,
    required this.date,
    this.isLocked = false,
    this.progressInfo = '',
    this.awardTitle = '',
    this.description = '',
    this.progress = 0.0,
  });
}

class VolunteerRating {
  final String id;
  final String fromName;
  final String category;
  final double score;
  final String comment;
  final String date;
  final String icon;
  final List<String> chips;
  final Map<String, double> criteriaScores;

  VolunteerRating({
    required this.id,
    required this.fromName,
    required this.category,
    required this.score,
    required this.comment,
    required this.date,
    this.icon = '😊',
    this.chips = const [],
    this.criteriaScores = const {},
  });
}

class VolunteerReview {
  final String id;
  final String toName;
  final String session;
  final String date;
  final double score;
  final bool isPending;
  final String icon;

  VolunteerReview({
    required this.id,
    required this.toName,
    required this.session,
    required this.date,
    required this.score,
    required this.isPending,
    this.icon = '👴',
  });
}

class SocialSpecialistNeed {
  final String id;
  final String type; // 'نفسي', 'أسري', 'مالي', 'طبي'
  final String roomNumber;
  final bool isUrgent;
  final String label;

  SocialSpecialistNeed({
    required this.id,
    required this.type,
    required this.roomNumber,
    this.isUrgent = false,
    required this.label,
  });
}

class SocialSpecialistAssessmentTool {
  final String id;
  final String name;
  final String subtitle;
  final String score;
  final String status; // 'جديد', 'مكتمل', 'تحديث'
  final String icon;

  SocialSpecialistAssessmentTool({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.status,
    required this.icon,
  });
}

class SocialSpecialistResidentScore {
  final String id;
  final String name;
  final String initials;
  final String room;
  final String date;
  final Map<String, double> scores; // { 'نفسي': 0.45, ... }
  final bool isUrgent;
  final String healthStatus; // 'stable', 'monitoring', 'critical'
  final DateTime lastAssessment;

  SocialSpecialistResidentScore({
    required this.id,
    required this.name,
    required this.initials,
    required this.room,
    required this.date,
    required this.scores,
    this.isUrgent = false,
    this.healthStatus = 'stable',
    required this.lastAssessment,
  });
}

class ComplaintStep {
  final String text;
  final String time;
  final String status; // 'done', 'pending', 'alert'

  ComplaintStep({required this.text, required this.time, required this.status});
}

class SocialSpecialistComplaint {
  final String id;
  final String title;
  final String residentName;
  final String room;
  final String date;
  final String priority; // 'high', 'medium', 'low'
  final String status; // 'open', 'progress', 'done'
  final String category; // 'food', 'service', 'psych', 'maintenance'
  final String icon;
  final List<ComplaintStep> timeline;

  SocialSpecialistComplaint({
    required this.id,
    required this.title,
    required this.residentName,
    required this.room,
    required this.date,
    required this.priority,
    required this.status,
    required this.category,
    required this.icon,
    required this.timeline,
  });
}

class SocialSpecialistKPI {
  final String id;
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  SocialSpecialistKPI({
    required this.id,
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });
}

class AssessmentQuestion {
  final String id;
  final String text;
  final String type; // 'choice', 'scale', 'text'
  final List<String>? options;
  final String? userAnswer;
  final int? userScale;

  AssessmentQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.userAnswer,
    this.userScale,
  });
}

class AssessmentHistoricalEntry {
  final String date;
  final double score;
  final String total;
  final String trend; // 'up', 'down', 'stable'

  AssessmentHistoricalEntry({
    required this.date,
    required this.score,
    required this.total,
    required this.trend,
  });
}

class FamilyVisit {
  final String id;
  final String date;
  final String time;
  final String visitorName;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String type; // 'physical', 'video'

  FamilyVisit({
    required this.id,
    required this.date,
    required this.time,
    required this.visitorName,
    required this.status,
    required this.type,
  });

  FamilyVisit copyWith({
    String? id,
    String? date,
    String? time,
    String? visitorName,
    String? status,
    String? type,
  }) {
    return FamilyVisit(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      visitorName: visitorName ?? this.visitorName,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

class FamilyBill {
  final String id;
  final String title;
  final String month;
  final double amount;
  final bool isPaid;
  final String dueDate;

  FamilyBill({
    required this.id,
    required this.title,
    required this.month,
    required this.amount,
    required this.isPaid,
    required this.dueDate,
  });

  FamilyBill copyWith({
    String? id,
    String? title,
    String? month,
    double? amount,
    bool? isPaid,
    String? dueDate,
  }) {
    return FamilyBill(
      id: id ?? this.id,
      title: title ?? this.title,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class ShiftHandoff {
  final String nurseName;
  final String shiftType;
  final String notes;
  final DateTime timestamp;
  final List<String> criticalCases;

  ShiftHandoff({
    required this.nurseName,
    required this.shiftType,
    required this.notes,
    required this.timestamp,
    required this.criticalCases,
  });
}

class PendingAssessment {
  final String residentName;
  final String toolName;
  final Map<int, int> selections;
  final Map<int, int> scales;
  final String notes;
  final DateTime timestamp;

  PendingAssessment({
    required this.residentName,
    required this.toolName,
    required this.selections,
    required this.scales,
    required this.notes,
    required this.timestamp,
  });
}

class FamilyHealthMetric {
  final String label;
  final double value; // 0.0 to 1.0
  final String status; // 'good', 'medium', 'critical'
  final String trend; // 'up', 'down', 'stable'

  FamilyHealthMetric({
    required this.label,
    required this.value,
    required this.status,
    required this.trend,
  });
}

class SpecialistResidentFile {
  final String id;
  final String name; // الاسم بالعربية
  final String nameEn; // الاسم بالإنجليزية
  final String room;
  final String status; // 'updated', 'pending', 'critical'
  final String lastUpdate;
  final List<String>
      categories; // 'social', 'medical', 'psychological', 'admin'
  final String initials;
  final String? phone; // رقم التواصل
  final int? age; // العمر
  final String? familyEmail; // بريد العائلة المرتبط (لصلاحيات الوصول)
  final List<FamilyMember> familyMembers; // الربط العائلي

  SpecialistResidentFile({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.room,
    required this.status,
    required this.lastUpdate,
    required this.categories,
    required this.initials,
    this.phone,
    this.age,
    this.familyEmail,
    this.familyMembers = const [],
  });
}

class MedicalSession {
  final String id;
  final String type; // 'doctor', 'pt', 'nursing'
  final String specialistName;
  final String time;
  final String date;
  final String notes;
  final String residentName;

  MedicalSession({
    required this.id,
    required this.type,
    required this.specialistName,
    required this.time,
    required this.date,
    required this.notes,
    required this.residentName,
  });
}

class MedicalPrescription {
  final String id;
  final String title;
  final String doctorName;
  final String date;
  final String residentName;
  final String? imagePath;

  MedicalPrescription({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.residentName,
    this.imagePath,
  });
}

class StaffPerformance {
  final String id;
  final String name;
  final String role; // 'Specialist', 'Nurse'
  final double completionRate;
  final String lastActive;
  final String status; // 'online', 'offline'

  StaffPerformance({
    required this.id,
    required this.name,
    required this.role,
    required this.completionRate,
    required this.lastActive,
    required this.status,
  });
}

class CenterOperationalStat {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final List<double> history;

  CenterOperationalStat({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
    this.history = const [],
  });
}

// نموذج التنبيهات الموحد في التطبيق (الإشعارات الداخلية)
class TaptabaNotification {
  final String id; // المعرف الفريد للتنبيه
  final String title; // عنوان التنبيه (مثال: حالة طبية حرجة)
  final String body; // نص التنبيه التفصيلي
  final String time; // وقت وصول التنبيه (مثال: منذ ٥ دقائق)
  final String type; // نوع التنبيه (medical, complaint, social, stable)
  final String targetRole; // الدور المستهدف بالتنبيه (مدير، أخصائي، إلخ)
  final String?
      residentId; // معرف المقيم المرتبط بالتنبيه (للتنقل السريع لملفه)
  bool isRead; // حالة القراءة (هل تمت معالجة التنبيه؟)

  TaptabaNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.targetRole = 'all',
    this.residentId,
    this.isRead = false,
  });
}

class MemoryMoment {
  final String id;
  final String residentId;
  final String residentName;
  final String imageUrl;
  final String activityTitle;
  final String date;
  final int appreciations;

  MemoryMoment({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.imageUrl,
    required this.activityTitle,
    required this.date,
    this.appreciations = 0,
  });
}

class VolunteerProfile {
  final String name;
  final String location;
  final String bio;
  final List<String> skills;
  final String? linkedinUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? cvFileName;
  final String? recommendationFileName;
  final List<String> otherWorks;

  VolunteerProfile({
    required this.name,
    required this.location,
    required this.bio,
    required this.skills,
    this.linkedinUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.cvFileName,
    this.recommendationFileName,
    this.otherWorks = const [],
  });

  VolunteerProfile copyWith({
    String? name,
    String? location,
    String? bio,
    List<String>? skills,
    String? linkedinUrl,
    String? facebookUrl,
    String? instagramUrl,
    String? cvFileName,
    String? recommendationFileName,
    List<String>? otherWorks,
  }) {
    return VolunteerProfile(
      name: name ?? this.name,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      recommendationFileName:
          recommendationFileName ?? this.recommendationFileName,
      otherWorks: otherWorks ?? this.otherWorks,
    );
  }
}

class NursingNote {
  final String id;
  final String residentName;
  final String title;
  final String content;
  final String author;
  final DateTime timestamp;

  NursingNote({
    required this.id,
    required this.residentName,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
  });
}

class ResidentMedicalInfo {
  final String residentName;
  final List<String> medications;
  final List<String> allergies;
  final List<String> chronicDiseases;

  ResidentMedicalInfo({
    required this.residentName,
    this.medications = const [],
    this.allergies = const [],
    this.chronicDiseases = const [],
  });
}

class CareTask {
  final String id;
  final String residentName;
  final String title;
  final String category; // 'فندقية', 'شخصية', 'ترفيهية'
  bool isCompleted;
  final String time;

  CareTask({
    required this.id,
    required this.residentName,
    required this.title,
    required this.category,
    this.isCompleted = false,
    required this.time,
  });
}

class InventoryItem {
  final String id;
  final String name;
  final String category; // 'أدوية', 'مستلزمات', 'شخصي'
  final int currentStock;
  final int minRequired;
  final String unit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minRequired,
    this.unit = 'قطعة',
  });

  bool get isLowStock => currentStock <= minRequired;
}

class DoctorVisit {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String purpose;
  final String results;
  final String residentName;

  DoctorVisit({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.purpose,
    this.results = '',
    required this.residentName,
  });
}

class MealPlan {
  final String residentName;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snacks;
  final String specialInstructions;

  MealPlan({
    required this.residentName,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.snacks = '',
    this.specialInstructions = '',
  });
}

class ActivitySession {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final String location;
  final List<String> participants;

  ActivitySession({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.location,
    required this.participants,
  });
}

class AIInsight {
  final String id;
  final String residentName;
  final String summary;
  final String rationale;
  final DateTime generationDate;
  final double confidenceScore;

  AIInsight({
    required this.id,
    required this.residentName,
    required this.summary,
    required this.rationale,
    required this.generationDate,
    this.confidenceScore = 0.85,
  });
}

class CompanionMessage {
  final String id;
  final String text;
  final bool isFromAI;
  final DateTime timestamp;

  CompanionMessage({
    required this.id,
    required this.text,
    required this.isFromAI,
    required this.timestamp,
  });
}

class SpecialistRecommendation {
  final String id;
  final String residentName;
  final String content;
  final String time;

  SpecialistRecommendation({
    required this.id,
    required this.residentName,
    required this.content,
    required this.time,
  });
}

class AppAccount {
  final String name;
  final String email;
  final String password;
  final String role;

  AppAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

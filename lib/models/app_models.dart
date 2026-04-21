class User {
  String name;
  int points;
  int streakDays;
  int completedActivities;

  User({
    required this.name,
    required this.points,
    required this.streakDays,
    required this.completedActivities,
  });
}

class Medication {
  String id;
  String name;
  String dosage;
  String timeDescription;
  String timeOfDay; // 'الصباح', 'الظهر', 'المساء'
  bool isTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timeDescription,
    required this.timeOfDay,
    this.isTaken = false,
  });
}

class FamilyMember {
  String id;
  String name;
  String relation;
  String avatarPath;
  String initials;
  bool isAvailable;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.avatarPath,
    required this.initials,
    this.isAvailable = false,
  });
}

class VoiceMessage {
  String id;
  String senderId;
  String title;
  String timeDescription;
  bool isPlaying;

  VoiceMessage({
    required this.id,
    required this.senderId,
    required this.title,
    required this.timeDescription,
    this.isPlaying = false,
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

  Activity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.location,
    required this.time,
    required this.status,
    required this.badges,
    required this.pointsReward,
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

  SocialSpecialistResidentScore({
    required this.id,
    required this.name,
    required this.initials,
    required this.room,
    required this.date,
    required this.scores,
    this.isUrgent = false,
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
  final String name;
  final String room;
  final String status; // 'updated', 'pending', 'critical'
  final String lastUpdate;
  final List<String> categories; // 'social', 'medical', 'psychological', 'admin'
  final String initials;

  SpecialistResidentFile({
    required this.id,
    required this.name,
    required this.room,
    required this.status,
    required this.lastUpdate,
    required this.categories,
    required this.initials,
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

  MedicalPrescription({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.residentName,
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

class TaptabaNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // 'medical', 'activity', 'social', 'admin', 'visit'
  final String targetRole; // 'مسن', 'أهل', 'ممرض', 'أخصائي', 'مدير', 'متطوع', 'all'
  bool isRead;

  TaptabaNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.type = 'admin',
    this.targetRole = 'all',
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
       recommendationFileName: recommendationFileName ?? this.recommendationFileName,
       otherWorks: otherWorks ?? this.otherWorks,
     );
   }
 }

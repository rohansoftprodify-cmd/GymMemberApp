import 'package:gym_member_app/src/core/utils/json_map.dart';

class MemberAttendanceStats {
  const MemberAttendanceStats({
    required this.totalVisits,
    this.lastCheckInAt,
    this.isCheckedIn = false,
  });

  final int totalVisits;
  final String? lastCheckInAt;
  final bool isCheckedIn;

  factory MemberAttendanceStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MemberAttendanceStats(totalVisits: 0);
    }
    return MemberAttendanceStats(
      totalVisits: (map['total_visits'] as num?)?.toInt() ?? 0,
      lastCheckInAt: map['last_check_in_at'] as String?,
      isCheckedIn: map['is_checked_in'] == true,
    );
  }
}

class MemberProfileSubscription {
  const MemberProfileSubscription({
    required this.id,
    required this.planName,
    this.planDescription,
    this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    required this.amountPaid,
    required this.planPrice,
    required this.status,
  });

  final String id;
  final String planName;
  final String? planDescription;
  final int? durationDays;
  final String startDate;
  final String endDate;
  final String paymentStatus;
  final num amountPaid;
  final num planPrice;
  final String status;

  factory MemberProfileSubscription.fromMap(Map<String, dynamic> map) {
    return MemberProfileSubscription(
      id: map['id'] as String,
      planName: map['plan_name'] as String? ?? '-',
      planDescription: map['plan_description'] as String?,
      durationDays: (map['duration_days'] as num?)?.toInt(),
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      paymentStatus: map['payment_status'] as String? ?? 'due',
      amountPaid: map['amount_paid'] as num? ?? 0,
      planPrice: map['plan_price'] as num? ?? 0,
      status: map['status'] as String? ?? 'active',
    );
  }
}

class MemberProfile {
  const MemberProfile({
    required this.gymId,
    required this.memberId,
    required this.gymName,
    this.gymAddress,
    this.gymPhone,
    required this.fullName,
    this.email,
    this.phone,
    this.authEmail,
    required this.memberStatus,
    this.joinedOn,
    this.dateOfBirth,
    this.emergencyContact,
    this.address,
    this.notes,
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
    this.fitnessGoal,
    this.profileSetupCompleted = false,
    this.profileUpdatedAt,
    this.bmi,
    this.subscription,
    required this.attendanceStats,
  });

  final String gymId;
  final String memberId;
  final String gymName;
  final String? gymAddress;
  final String? gymPhone;
  final String fullName;
  final String? email;
  final String? phone;
  final String? authEmail;
  final String memberStatus;
  final String? joinedOn;
  final String? dateOfBirth;
  final String? emergencyContact;
  final String? address;
  final String? notes;
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? gender;
  final String? fitnessGoal;
  final bool profileSetupCompleted;
  final String? profileUpdatedAt;
  final double? bmi;
  final MemberProfileSubscription? subscription;
  final MemberAttendanceStats attendanceStats;

  factory MemberProfile.fromMap(Map<String, dynamic> map) {
    final sub = map['subscription'];
    final stats = map['attendance_stats'];
    return MemberProfile(
      gymId: map['gym_id'] as String,
      memberId: map['member_id'] as String,
      gymName: map['gym_name'] as String? ?? 'Gym',
      gymAddress: map['gym_address'] as String?,
      gymPhone: map['gym_phone'] as String?,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      authEmail: map['auth_email'] as String?,
      memberStatus: map['member_status'] as String? ?? 'active',
      joinedOn: map['joined_on'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      fitnessGoal: map['fitness_goal'] as String?,
      profileSetupCompleted: map['profile_setup_completed_at'] != null,
      profileUpdatedAt: map['profile_updated_at'] as String?,
      bmi: (map['bmi'] as num?)?.toDouble(),
      subscription: sub is Map
          ? MemberProfileSubscription.fromMap(asStringKeyMap(sub))
          : null,
      attendanceStats: MemberAttendanceStats.fromMap(
        stats is Map ? asStringKeyMap(stats) : null,
      ),
    );
  }
}

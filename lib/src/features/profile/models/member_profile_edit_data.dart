class MemberProfileEditData {
  const MemberProfileEditData({
    this.phone = '',
    this.emergencyContact = '',
    this.address = '',
    this.dateOfBirth,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    this.gender,
    required this.fitnessGoal,
  });

  final String phone;
  final String emergencyContact;
  final String address;
  final DateTime? dateOfBirth;
  final double weightKg;
  final double heightCm;
  final int age;
  final String? gender;
  final String fitnessGoal;

  static const defaultWeightKg = 65.0;
  static const defaultHeightCm = 170.0;
  static const defaultAge = 25;

  MemberProfileEditData copyWith({
    String? phone,
    String? emergencyContact,
    String? address,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
    bool clearGender = false,
    String? fitnessGoal,
  }) {
    return MemberProfileEditData(
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: clearGender ? null : (gender ?? this.gender),
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }
}

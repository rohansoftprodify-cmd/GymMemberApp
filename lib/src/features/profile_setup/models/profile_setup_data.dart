import 'package:flutter/material.dart';

class ProfileSetupData {
  const ProfileSetupData({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    this.gender,
    required this.fitnessGoal,
  });

  final double weightKg;
  final double heightCm;
  final int age;
  final String? gender;
  final String fitnessGoal;

  static const defaultWeightKg = 65.0;
  static const defaultHeightCm = 170.0;
  static const defaultAge = 25;

  factory ProfileSetupData.defaults() {
    return const ProfileSetupData(
      weightKg: defaultWeightKg,
      heightCm: defaultHeightCm,
      age: defaultAge,
      fitnessGoal: 'healthy',
    );
  }

  ProfileSetupData copyWith({
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? fitnessGoal,
  }) {
    return ProfileSetupData(
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }

  Map<String, dynamic> toJson() => {
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'age': age,
        'gender': gender,
        'fitness_goal': fitnessGoal,
      };

  factory ProfileSetupData.fromJson(Map<String, dynamic> json) {
    return ProfileSetupData(
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? defaultWeightKg,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? defaultHeightCm,
      age: (json['age'] as num?)?.toInt() ?? defaultAge,
      gender: json['gender'] as String?,
      fitnessGoal: json['fitness_goal'] as String? ?? 'healthy',
    );
  }
}

class FitnessGoalOption {
  const FitnessGoalOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
}

class GenderOption {
  const GenderOption({required this.key, required this.label});

  final String key;
  final String label;
}

const genderOptions = <GenderOption>[
  GenderOption(key: 'male', label: 'Male'),
  GenderOption(key: 'female', label: 'Female'),
  GenderOption(key: 'other', label: 'Other'),
  GenderOption(key: 'prefer_not_to_say', label: 'Prefer not to say'),
];

const fitnessGoalOptions = <FitnessGoalOption>[
  FitnessGoalOption(
    key: 'weight_loss',
    title: 'Lose weight',
    subtitle: 'Burn fat and improve cardio endurance',
    icon: Icons.local_fire_department_outlined,
  ),
  FitnessGoalOption(
    key: 'muscle_gain',
    title: 'Build muscle',
    subtitle: 'Gain strength with structured training',
    icon: Icons.fitness_center_outlined,
  ),
  FitnessGoalOption(
    key: 'healthy',
    title: 'Stay healthy',
    subtitle: 'Maintain fitness and overall wellness',
    icon: Icons.favorite_outline_rounded,
  ),
];

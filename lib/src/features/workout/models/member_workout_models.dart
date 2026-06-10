import 'package:flutter/material.dart';

class DietGoalInfo {
  const DietGoalInfo({
    required this.key,
    required this.title,
    required this.shortLabel,
    required this.icon,
  });

  final String key;
  final String title;
  final String shortLabel;
  final IconData icon;

  static DietGoalInfo? forKey(String? key) {
    return switch (key) {
      'weight_loss' => const DietGoalInfo(
          key: 'weight_loss',
          title: 'Weight loss',
          shortLabel: 'Lose',
          icon: Icons.trending_down_rounded,
        ),
      'muscle_gain' => const DietGoalInfo(
          key: 'muscle_gain',
          title: 'Muscle gain',
          shortLabel: 'Gain',
          icon: Icons.fitness_center_rounded,
        ),
      'healthy' => const DietGoalInfo(
          key: 'healthy',
          title: 'Healthy lifestyle',
          shortLabel: 'Healthy',
          icon: Icons.favorite_outline_rounded,
        ),
      _ => null,
    };
  }
}

class MemberWorkoutPlanSummary {
  const MemberWorkoutPlanSummary({
    required this.id,
    required this.name,
    required this.goalKey,
    required this.categoryName,
    this.description,
    this.durationWeeks = 4,
    this.sessionsPerWeek = 3,
    this.experienceLevel = 'beginner',
    this.equipmentHint,
    this.sessionCount = 0,
  });

  final String id;
  final String name;
  final String goalKey;
  final String categoryName;
  final String? description;
  final int durationWeeks;
  final int sessionsPerWeek;
  final String experienceLevel;
  final String? equipmentHint;
  final int sessionCount;

  DietGoalInfo? get goalInfo => DietGoalInfo.forKey(goalKey);

  factory MemberWorkoutPlanSummary.fromMap(Map<String, dynamic> map) {
    return MemberWorkoutPlanSummary(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      goalKey: map['goal_key'] as String? ?? 'healthy',
      categoryName: map['category_name'] as String? ?? '',
      description: map['description'] as String?,
      durationWeeks: (map['duration_weeks'] as num?)?.toInt() ?? 4,
      sessionsPerWeek: (map['sessions_per_week'] as num?)?.toInt() ?? 3,
      experienceLevel: map['experience_level'] as String? ?? 'beginner',
      equipmentHint: map['equipment_hint'] as String?,
      sessionCount: (map['session_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class MemberWorkoutExercise {
  const MemberWorkoutExercise({
    required this.exerciseName,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds,
    this.notes,
  });

  final String exerciseName;
  final int sets;
  final int reps;
  final int? restSeconds;
  final String? notes;

  factory MemberWorkoutExercise.fromMap(Map<String, dynamic> map) {
    return MemberWorkoutExercise(
      exerciseName: map['exercise_name'] as String? ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      restSeconds: (map['rest_seconds'] as num?)?.toInt(),
      notes: map['notes'] as String?,
    );
  }
}

class MemberWorkoutSession {
  const MemberWorkoutSession({
    required this.id,
    required this.dayLabel,
    this.dayNumber = 1,
    this.guidance,
    this.exercises = const [],
  });

  final String id;
  final String dayLabel;
  final int dayNumber;
  final String? guidance;
  final List<MemberWorkoutExercise> exercises;

  factory MemberWorkoutSession.fromMap(Map<String, dynamic> map) {
    final rawExercises = map['exercises'];
    final exercises = <MemberWorkoutExercise>[];
    if (rawExercises is List) {
      for (final item in rawExercises) {
        if (item is Map) {
          exercises.add(MemberWorkoutExercise.fromMap(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }
    return MemberWorkoutSession(
      id: map['id']?.toString() ?? '',
      dayLabel: map['day_label'] as String? ?? '',
      dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
      guidance: map['guidance'] as String?,
      exercises: exercises,
    );
  }
}

class MemberWorkoutPlanDetail {
  const MemberWorkoutPlanDetail({
    required this.id,
    required this.name,
    required this.goalKey,
    required this.categoryName,
    this.description,
    this.coachingTips,
    this.durationWeeks = 4,
    this.sessionsPerWeek = 3,
    this.experienceLevel = 'beginner',
    this.equipmentHint,
    this.sessions = const [],
  });

  final String id;
  final String name;
  final String goalKey;
  final String categoryName;
  final String? description;
  final String? coachingTips;
  final int durationWeeks;
  final int sessionsPerWeek;
  final String experienceLevel;
  final String? equipmentHint;
  final List<MemberWorkoutSession> sessions;

  DietGoalInfo? get goalInfo => DietGoalInfo.forKey(goalKey);

  factory MemberWorkoutPlanDetail.fromMap(Map<String, dynamic> map) {
    final rawSessions = map['sessions'];
    final sessions = <MemberWorkoutSession>[];
    if (rawSessions is List) {
      for (final item in rawSessions) {
        if (item is Map) {
          sessions.add(MemberWorkoutSession.fromMap(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }
    return MemberWorkoutPlanDetail(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      goalKey: map['goal_key'] as String? ?? 'healthy',
      categoryName: map['category_name'] as String? ?? '',
      description: map['description'] as String?,
      coachingTips: map['coaching_tips'] as String?,
      durationWeeks: (map['duration_weeks'] as num?)?.toInt() ?? 4,
      sessionsPerWeek: (map['sessions_per_week'] as num?)?.toInt() ?? 3,
      experienceLevel: map['experience_level'] as String? ?? 'beginner',
      equipmentHint: map['equipment_hint'] as String?,
      sessions: sessions,
    );
  }
}

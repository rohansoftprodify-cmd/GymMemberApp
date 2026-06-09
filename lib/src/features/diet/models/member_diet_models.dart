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

class MemberDietPlanSummary {
  const MemberDietPlanSummary({
    required this.id,
    required this.name,
    required this.goalKey,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.hydrationLiters,
    this.durationDays = 7,
    this.mealCount = 0,
    this.linkedMembershipPlanNames = const [],
  });

  final String id;
  final String name;
  final String goalKey;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final int? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final double? hydrationLiters;
  final int durationDays;
  final int mealCount;
  final List<String> linkedMembershipPlanNames;

  DietGoalInfo? get goalInfo => DietGoalInfo.forKey(goalKey);

  bool get isMembershipRestricted => linkedMembershipPlanNames.isNotEmpty;

  factory MemberDietPlanSummary.fromMap(
    Map<String, dynamic> map, {
    String? Function(String? path)? imageUrlResolver,
  }) {
    final rawLinks = map['linked_membership_plans'];
    final linkedNames = <String>[];
    if (rawLinks is List) {
      for (final item in rawLinks) {
        if (item is String && item.isNotEmpty) linkedNames.add(item);
      }
    }

    return MemberDietPlanSummary(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      goalKey: map['goal_key'] as String? ?? 'healthy',
      categoryName: map['category_name'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: imageUrlResolver?.call(map['image_path'] as String?),
      targetCalories: (map['target_calories'] as num?)?.toInt(),
      targetProteinG: (map['target_protein_g'] as num?)?.toDouble(),
      targetCarbsG: (map['target_carbs_g'] as num?)?.toDouble(),
      targetFatG: (map['target_fat_g'] as num?)?.toDouble(),
      hydrationLiters: (map['hydration_liters'] as num?)?.toDouble(),
      durationDays: (map['duration_days'] as num?)?.toInt() ?? 7,
      mealCount: (map['meal_count'] as num?)?.toInt() ?? 0,
      linkedMembershipPlanNames: linkedNames,
    );
  }
}

class MemberDietFoodItem {
  const MemberDietFoodItem({
    required this.foodName,
    this.portion,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.notes,
  });

  final String foodName;
  final String? portion;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final String? notes;

  factory MemberDietFoodItem.fromMap(Map<String, dynamic> map) {
    return MemberDietFoodItem(
      foodName: map['food_name'] as String? ?? '',
      portion: map['portion'] as String?,
      calories: (map['calories'] as num?)?.toInt(),
      proteinG: (map['protein_g'] as num?)?.toDouble(),
      carbsG: (map['carbs_g'] as num?)?.toDouble(),
      fatG: (map['fat_g'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
    );
  }
}

class MemberDietMeal {
  const MemberDietMeal({
    required this.mealLabel,
    this.mealTime,
    this.guidance,
    this.foods = const [],
  });

  final String mealLabel;
  final String? mealTime;
  final String? guidance;
  final List<MemberDietFoodItem> foods;

  int get totalCalories => foods.fold(0, (sum, f) => sum + (f.calories ?? 0));

  factory MemberDietMeal.fromMap(Map<String, dynamic> map) {
    final rawFoods = map['foods'];
    final foods = <MemberDietFoodItem>[];
    if (rawFoods is List) {
      for (final item in rawFoods) {
        if (item is Map) {
          foods.add(MemberDietFoodItem.fromMap(item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    }
    return MemberDietMeal(
      mealLabel: map['meal_label'] as String? ?? '',
      mealTime: map['meal_time'] as String?,
      guidance: map['guidance'] as String?,
      foods: foods,
    );
  }
}

class MemberDietPlanDetail {
  const MemberDietPlanDetail({
    required this.id,
    required this.name,
    required this.goalKey,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.nutritionTips,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.hydrationLiters,
    this.durationDays = 7,
    this.meals = const [],
  });

  final String id;
  final String name;
  final String goalKey;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final String? nutritionTips;
  final int? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final double? hydrationLiters;
  final int durationDays;
  final List<MemberDietMeal> meals;

  DietGoalInfo? get goalInfo => DietGoalInfo.forKey(goalKey);

  factory MemberDietPlanDetail.fromMap(
    Map<String, dynamic> map, {
    String? Function(String? path)? imageUrlResolver,
  }) {
    final rawMeals = map['meals'];
    final meals = <MemberDietMeal>[];
    if (rawMeals is List) {
      for (final item in rawMeals) {
        if (item is Map) {
          meals.add(MemberDietMeal.fromMap(item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    }

    return MemberDietPlanDetail(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      goalKey: map['goal_key'] as String? ?? 'healthy',
      categoryName: map['category_name'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: imageUrlResolver?.call(map['image_path'] as String?),
      nutritionTips: map['nutrition_tips'] as String?,
      targetCalories: (map['target_calories'] as num?)?.toInt(),
      targetProteinG: (map['target_protein_g'] as num?)?.toDouble(),
      targetCarbsG: (map['target_carbs_g'] as num?)?.toDouble(),
      targetFatG: (map['target_fat_g'] as num?)?.toDouble(),
      hydrationLiters: (map['hydration_liters'] as num?)?.toDouble(),
      durationDays: (map['duration_days'] as num?)?.toInt() ?? 7,
      meals: meals,
    );
  }
}

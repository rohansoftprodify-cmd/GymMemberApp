import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/supabase/supabase_client_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/features/profile/models/member_profile_edit_data.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';
import 'package:gym_member_app/src/features/support/models/member_support_faq.dart';
import 'package:gym_member_app/src/core/utils/json_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  MemberRepository(this._client);

  static const productImagesBucket = 'product-images';
  static const dietImagesBucket = 'diet-images';

  final SupabaseClient _client;

  Future<MemberProfile?> myProfile() async {
    final response = await _client.rpc('get_my_member_profile');
    if (response == null) return null;
    return MemberProfile.fromMap(asStringKeyMap(response));
  }

  Future<void> saveProfileSetup(ProfileSetupData data) async {
    await updateMyProfile(MemberProfileEditData(
      weightKg: data.weightKg,
      heightCm: data.heightCm,
      age: data.age,
      gender: data.gender,
      fitnessGoal: data.fitnessGoal,
    ));
  }

  Future<void> updateMyProfile(MemberProfileEditData data) async {
    await _client.rpc('update_my_member_profile', params: {
      'p_phone': data.phone.trim().isEmpty ? null : data.phone.trim(),
      'p_emergency_contact':
          data.emergencyContact.trim().isEmpty ? null : data.emergencyContact.trim(),
      'p_address': data.address.trim().isEmpty ? null : data.address.trim(),
      'p_date_of_birth': data.dateOfBirth == null
          ? null
          : '${data.dateOfBirth!.year.toString().padLeft(4, '0')}-'
              '${data.dateOfBirth!.month.toString().padLeft(2, '0')}-'
              '${data.dateOfBirth!.day.toString().padLeft(2, '0')}',
      'p_weight_kg': data.weightKg,
      'p_height_cm': data.heightCm,
      'p_age': data.age,
      'p_gender': data.gender,
      'p_fitness_goal': data.fitnessGoal,
    });
  }

  Future<void> syncLocalProfileSetupIfNeeded(ProfileSetupData data) async {
    final profile = await myProfile();
    if (profile?.profileSetupCompleted == true) return;
    await saveProfileSetup(data);
  }

  Future<List<Map<String, dynamic>>> myAttendance(
    String gymId,
    String memberId, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from('attendance_records')
        .select('id, check_in_at, check_out_at')
        .eq('gym_id', gymId)
        .eq('member_id', memberId)
        .order('check_in_at', ascending: false)
        .limit(limit);
    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> openAttendance(String gymId, String memberId) async {
    final rows = await _client
        .from('attendance_records')
        .select('id, check_in_at, check_out_at')
        .eq('gym_id', gymId)
        .eq('member_id', memberId)
        .isFilter('check_out_at', null)
        .order('check_in_at', ascending: false)
        .limit(1);
    final list = rows.cast<Map<String, dynamic>>();
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<void> markMyAttendance({
    required String gymId,
    required String action,
    required double latitude,
    required double longitude,
  }) async {
    await _client.rpc('member_mark_my_attendance', params: {
      'p_gym_id': gymId,
      'p_action': action,
      'p_latitude': latitude,
      'p_longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> validateCheckInQr(String raw) async {
    final response = await _client.rpc('validate_gym_check_in_qr', params: {'p_raw': raw});
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> markAttendanceFromQr({
    required String raw,
    required String action,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.rpc('member_mark_attendance_from_qr', params: {
      'p_raw': raw,
      'p_action': action,
      'p_latitude': latitude,
      'p_longitude': longitude,
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<Map<String, dynamic>>> activePromotions(String gymId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await _client
        .from('promotions')
        .select('id, title, description, start_at, end_at, card_design')
        .eq('gym_id', gymId)
        .eq('is_active', true)
        .lte('start_at', now)
        .gte('end_at', now)
        .order('end_at');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> gymInfo(String gymId) async {
    final row = await _client
        .from('gyms')
        .select('id, name, email, phone, address, timezone, latitude, longitude, check_in_radius_meters')
        .eq('id', gymId)
        .maybeSingle();
    if (row == null) return null;
    return row;
  }

  Future<Map<String, dynamic>?> todayOperatingHours(String gymId) async {
    final dayOfWeek = DateTime.now().weekday;
    final row = await _client
        .from('gym_operating_hours')
        .select('day_of_week, is_closed, open_time, close_time')
        .eq('gym_id', gymId)
        .eq('day_of_week', dayOfWeek)
        .maybeSingle();
    if (row == null) return null;
    return row;
  }

  Future<List<Map<String, dynamic>>> weeklyOperatingHours(String gymId) async {
    final rows = await _client
        .from('gym_operating_hours')
        .select('day_of_week, is_closed, open_time, close_time')
        .eq('gym_id', gymId)
        .order('day_of_week');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> productCategories(String gymId) async {
    final rows = await _client
        .from('product_categories')
        .select('id, name, sort_order')
        .eq('gym_id', gymId)
        .order('sort_order');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> products(String gymId, {String? categoryId}) async {
    var query = _client
        .from('products')
        .select(
          'id, name, description, price, actual_price, offer_price, '
          'stock_qty, category_id, image_path',
        )
        .eq('gym_id', gymId)
        .eq('is_active', true);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final rows = await query.order('name');
    return rows.cast<Map<String, dynamic>>();
  }

  String? productImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) return null;
    return _client.storage.from(productImagesBucket).getPublicUrl(imagePath.trim());
  }

  String? dietImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) return null;
    return _client.storage.from(dietImagesBucket).getPublicUrl(imagePath.trim());
  }

  Future<List<Map<String, dynamic>>> myDietPlans() async {
    try {
      final response = await _client.rpc('get_my_diet_plans');
      if (response is List) {
        return response
            .whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (_) {
      // RPC may be missing on older databases; fall back to RLS-scoped reads.
    }
    return _myDietPlansFallback();
  }

  Future<Map<String, dynamic>?> myDietPlanDetail(String dietPlanId) async {
    try {
      final response = await _client.rpc('get_my_diet_plan_detail', params: {
        'p_diet_plan_id': dietPlanId,
      });
      if (response != null) {
        final map = tryAsStringKeyMap(response);
        if (map != null && map['id'] != null) return map;
      }
    } catch (_) {
      // RPC may be missing on older databases; fall back to RLS-scoped reads.
    }
    return _myDietPlanDetailFallback(dietPlanId);
  }

  Future<String?> _myGymId() async {
    try {
      final response = await _client.rpc('get_my_member_context');
      final ctx = tryAsStringKeyMap(response);
      final gymId = ctx?['gym_id']?.toString();
      if (gymId != null && gymId.isNotEmpty) return gymId;
    } catch (_) {}

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('members')
        .select('gym_id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();
    return row?['gym_id']?.toString();
  }

  Future<List<Map<String, dynamic>>> _myDietPlansFallback() async {
    final gymId = await _myGymId();
    if (gymId == null) return [];

    final rows = await _client
        .from('diet_plans')
        .select(
          'id, name, description, image_path, target_calories, target_protein_g, '
          'target_carbs_g, target_fat_g, hydration_liters, duration_days, '
          'diet_plan_categories(goal_key, name)',
        )
        .eq('gym_id', gymId)
        .eq('is_active', true)
        .order('name');

    return rows.map(_mapDietPlanSummaryRow).toList();
  }

  Map<String, dynamic> _mapDietPlanSummaryRow(Map<String, dynamic> row) {
    final category = row['diet_plan_categories'];
    final categoryMap = category is Map
        ? category.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};

    return {
      'id': row['id']?.toString(),
      'name': row['name'],
      'description': row['description'],
      'image_path': row['image_path'],
      'target_calories': row['target_calories'],
      'target_protein_g': row['target_protein_g'],
      'target_carbs_g': row['target_carbs_g'],
      'target_fat_g': row['target_fat_g'],
      'hydration_liters': row['hydration_liters'],
      'duration_days': row['duration_days'],
      'goal_key': categoryMap['goal_key'],
      'category_name': categoryMap['name'],
      'meal_count': 0,
      'linked_membership_plans': const <String>[],
    };
  }

  Future<Map<String, dynamic>?> _myDietPlanDetailFallback(String dietPlanId) async {
    final gymId = await _myGymId();
    if (gymId == null) return null;

    final planRow = await _client
        .from('diet_plans')
        .select(
          'id, name, description, image_path, target_calories, target_protein_g, '
          'target_carbs_g, target_fat_g, hydration_liters, duration_days, '
          'diet_plan_categories(goal_key, name, nutrition_tips)',
        )
        .eq('id', dietPlanId)
        .eq('gym_id', gymId)
        .eq('is_active', true)
        .maybeSingle();
    if (planRow == null) return null;

    final mealsRaw = await _client
        .from('diet_meals')
        .select(
          'id, meal_label, meal_time, guidance, sort_order, '
          'diet_food_items(id, food_name, portion, calories, protein_g, carbs_g, fat_g, notes, sort_order)',
        )
        .eq('diet_plan_id', dietPlanId)
        .eq('gym_id', gymId)
        .order('sort_order');

    final category = planRow['diet_plan_categories'];
    final categoryMap = category is Map
        ? category.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};

    return {
      'id': planRow['id']?.toString(),
      'name': planRow['name'],
      'description': planRow['description'],
      'image_path': planRow['image_path'],
      'target_calories': planRow['target_calories'],
      'target_protein_g': planRow['target_protein_g'],
      'target_carbs_g': planRow['target_carbs_g'],
      'target_fat_g': planRow['target_fat_g'],
      'hydration_liters': planRow['hydration_liters'],
      'duration_days': planRow['duration_days'],
      'goal_key': categoryMap['goal_key'],
      'category_name': categoryMap['name'],
      'nutrition_tips': categoryMap['nutrition_tips'],
      'meals': _mapDietMealsForDetail(mealsRaw),
    };
  }

  Future<List<Map<String, dynamic>>> myWorkoutPlans() async {
    try {
      final response = await _client.rpc('get_my_workout_plans');
      if (response is List) {
        return response
            .whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (_) {}
    return _myWorkoutPlansFallback();
  }

  Future<Map<String, dynamic>?> myWorkoutPlanDetail(String workoutPlanId) async {
    try {
      final response = await _client.rpc('get_my_workout_plan_detail', params: {
        'p_workout_plan_id': workoutPlanId,
      });
      if (response != null) {
        final map = tryAsStringKeyMap(response);
        if (map != null && map['id'] != null) return map;
      }
    } catch (_) {}
    return _myWorkoutPlanDetailFallback(workoutPlanId);
  }

  Future<void> logMyWorkoutSession({
    required String workoutPlanId,
    required String workoutSessionId,
    String? notes,
    bool skipped = false,
  }) async {
    await _client.rpc('log_my_workout_session', params: {
      'p_workout_plan_id': workoutPlanId,
      'p_workout_session_id': workoutSessionId,
      'p_notes': notes,
      'p_skipped': skipped,
    });
  }

  Future<Map<String, dynamic>> adjustMyWorkoutPlan({
    required String gymId,
    required String workoutPlanId,
    required String goalKey,
  }) async {
    final response = await _client.functions.invoke(
      'ai-generate-workout-plan',
      body: {
        'gym_id': gymId,
        'goal_key': goalKey,
        'mode': 'adjust',
        'workout_plan_id': workoutPlanId,
      },
    );
    final data = response.data;
    if (response.status != 200 || data is! Map) {
      throw Exception(
        data is Map ? data['error']?.toString() ?? 'Adjust failed' : 'Adjust failed',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> applyWorkoutPlanSessions({
    required String workoutPlanId,
    required List<dynamic> sessions,
  }) async {
    await _client.rpc('apply_workout_plan_sessions', params: {
      'p_workout_plan_id': workoutPlanId,
      'p_sessions': sessions,
    });
  }

  Future<List<Map<String, dynamic>>> _myWorkoutPlansFallback() async {
    final gymId = await _myGymId();
    if (gymId == null) return [];
    final rows = await _client
        .from('workout_plans')
        .select(
          'id, name, description, duration_weeks, sessions_per_week, experience_level, '
          'equipment_hint, workout_plan_categories(goal_key, name)',
        )
        .eq('gym_id', gymId)
        .eq('is_active', true)
        .order('name');
    return rows.map(_mapWorkoutPlanSummaryRow).toList();
  }

  Map<String, dynamic> _mapWorkoutPlanSummaryRow(Map<String, dynamic> row) {
    final category = row['workout_plan_categories'];
    final categoryMap = category is Map
        ? category.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    return {
      'id': row['id']?.toString(),
      'name': row['name'],
      'description': row['description'],
      'duration_weeks': row['duration_weeks'],
      'sessions_per_week': row['sessions_per_week'],
      'experience_level': row['experience_level'],
      'equipment_hint': row['equipment_hint'],
      'goal_key': categoryMap['goal_key'],
      'category_name': categoryMap['name'],
      'session_count': 0,
    };
  }

  Future<Map<String, dynamic>?> _myWorkoutPlanDetailFallback(String workoutPlanId) async {
    final gymId = await _myGymId();
    if (gymId == null) return null;
    final planRow = await _client
        .from('workout_plans')
        .select(
          'id, name, description, duration_weeks, sessions_per_week, experience_level, '
          'equipment_hint, workout_plan_categories(goal_key, name, coaching_tips)',
        )
        .eq('id', workoutPlanId)
        .eq('gym_id', gymId)
        .eq('is_active', true)
        .maybeSingle();
    if (planRow == null) return null;
    final sessionsRaw = await _client
        .from('workout_sessions')
        .select(
          'id, day_label, day_number, guidance, sort_order, '
          'workout_session_exercises(exercise_name, sets, reps, rest_seconds, notes, sort_order)',
        )
        .eq('workout_plan_id', workoutPlanId)
        .eq('gym_id', gymId)
        .order('sort_order');
    final category = planRow['workout_plan_categories'];
    final categoryMap = category is Map
        ? category.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    return {
      'id': planRow['id']?.toString(),
      'name': planRow['name'],
      'description': planRow['description'],
      'duration_weeks': planRow['duration_weeks'],
      'sessions_per_week': planRow['sessions_per_week'],
      'experience_level': planRow['experience_level'],
      'equipment_hint': planRow['equipment_hint'],
      'goal_key': categoryMap['goal_key'],
      'category_name': categoryMap['name'],
      'coaching_tips': categoryMap['coaching_tips'],
      'sessions': _mapWorkoutSessionsForDetail(sessionsRaw),
    };
  }

  List<Map<String, dynamic>> _mapWorkoutSessionsForDetail(List<dynamic> sessionsRaw) {
    return sessionsRaw.whereType<Map>().map((session) {
      final sessionMap = session.map((k, v) => MapEntry(k.toString(), v));
      final exercisesRaw = sessionMap['workout_session_exercises'];
      final exercises = <Map<String, dynamic>>[];
      if (exercisesRaw is List) {
        for (final ex in exercisesRaw) {
          if (ex is Map) exercises.add(ex.map((k, v) => MapEntry(k.toString(), v)));
        }
      }
      exercises.sort((a, b) {
        final ao = (a['sort_order'] as num?)?.toInt() ?? 0;
        final bo = (b['sort_order'] as num?)?.toInt() ?? 0;
        return ao.compareTo(bo);
      });
      return {
        'id': sessionMap['id']?.toString(),
        'day_label': sessionMap['day_label'],
        'day_number': sessionMap['day_number'],
        'guidance': sessionMap['guidance'],
        'exercises': exercises,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapDietMealsForDetail(List<dynamic> mealsRaw) {
    final meals = mealsRaw.whereType<Map>().map((meal) {
      final mealMap = meal.map((k, v) => MapEntry(k.toString(), v));
      final foodsRaw = mealMap['diet_food_items'];
      final foods = <Map<String, dynamic>>[];
      if (foodsRaw is List) {
        for (final food in foodsRaw) {
          if (food is Map) {
            foods.add(food.map((k, v) => MapEntry(k.toString(), v)));
          }
        }
      }
      foods.sort((a, b) {
        final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
        final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
        final byOrder = aOrder.compareTo(bOrder);
        if (byOrder != 0) return byOrder;
        return (a['food_name'] as String? ?? '').compareTo(b['food_name'] as String? ?? '');
      });

      return {
        'id': mealMap['id']?.toString(),
        'meal_label': mealMap['meal_label'],
        'meal_time': mealMap['meal_time'],
        'guidance': mealMap['guidance'],
        'sort_order': mealMap['sort_order'],
        'foods': foods,
      };
    }).toList();

    meals.sort((a, b) {
      final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
      final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
      final byOrder = aOrder.compareTo(bOrder);
      if (byOrder != 0) return byOrder;
      return (a['meal_label'] as String? ?? '').compareTo(b['meal_label'] as String? ?? '');
    });

    return meals;
  }

  Future<Map<String, dynamic>> getFitnessChatQuota() async {
    final response = await _client.functions.invoke(
      'ai-fitness-chat',
      body: {'mode': 'quota'},
    );
    final data = response.data;
    if (response.status != 200 || data is! Map) {
      throw Exception(
        data is Map ? data['error']?.toString() ?? 'Could not load chat quota' : 'Could not load chat quota',
      );
    }
    final quota = data['quota'];
    if (quota is Map) return Map<String, dynamic>.from(quota);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> sendFitnessChatMessage({
    required String message,
    List<Map<String, String>>? history,
  }) async {
    final response = await _client.functions.invoke(
      'ai-fitness-chat',
      body: {
        'message': message,
        if (history != null && history.isNotEmpty) 'history': history,
      },
    );
    final data = response.data;
    if (response.status != 200 || data is! Map) {
      throw Exception(
        data is Map ? data['error']?.toString() ?? 'Chat failed' : 'Chat failed',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Future<List<MemberSupportFaqCategory>> memberSupportFaqs() async {
    final response = await _client.rpc('get_member_support_faqs');
    if (response == null) return [];

    final list = response is List ? response : <dynamic>[];
    return list
        .whereType<Map>()
        .map((row) => MemberSupportFaqCategory.fromMap(
              row.map((k, v) => MapEntry(k.toString(), v)),
            ))
        .toList();
  }
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(supabaseClientProvider));
});

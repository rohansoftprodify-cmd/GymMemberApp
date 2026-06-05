import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/supabase/supabase_client_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/features/profile/models/member_profile_edit_data.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';
import 'package:gym_member_app/src/core/utils/json_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  MemberRepository(this._client);

  static const productImagesBucket = 'product-images';

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
  }) async {
    await _client.rpc('member_mark_my_attendance', params: {
      'p_gym_id': gymId,
      'p_action': action,
    });
  }

  Future<List<Map<String, dynamic>>> activePromotions(String gymId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await _client
        .from('promotions')
        .select('id, title, description, start_at, end_at')
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
        .select('id, name, description, price, stock_qty, category_id, image_path')
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
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(supabaseClientProvider));
});

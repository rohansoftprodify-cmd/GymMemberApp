import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, dynamic> _asStringKeyMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  throw const FormatException('Expected a JSON object from Supabase.');
}

class GymsRepository {
  GymsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> listDirectoryGyms() async {
    final rows = await _client.rpc('list_directory_gyms');
    if (rows is! List) return [];
    return rows.map(_asStringKeyMap).toList();
  }

  Future<Map<String, dynamic>?> directoryGymDetail(String gymId) async {
    try {
      final response = await _client.rpc('get_directory_gym_detail', params: {
        'p_gym_id': gymId,
      });
      if (response == null) return _directoryGymDetailFallback(gymId);
      final detail = _asStringKeyMap(response);
      final gym = detail['gym'];
      if (gym == null || gym is! Map) {
        return _directoryGymDetailFallback(gymId);
      }
      return detail;
    } catch (_) {
      return _directoryGymDetailFallback(gymId);
    }
  }

  Future<Map<String, dynamic>?> _directoryGymDetailFallback(String gymId) async {
    final gymRow = await _client
        .from('gyms')
        .select('id, name, email, phone, address, timezone, amenities')
        .eq('id', gymId)
        .maybeSingle();
    if (gymRow == null) return null;

    final hoursRows = await _client
        .from('gym_operating_hours')
        .select('day_of_week, is_closed, open_time, close_time')
        .eq('gym_id', gymId)
        .order('day_of_week');

    List<Map<String, dynamic>> promos = [];
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final promoRows = await _client
          .from('promotions')
          .select('id, title, description, start_at, end_at, card_design')
          .eq('gym_id', gymId)
          .eq('is_active', true)
          .lte('start_at', now)
          .gte('end_at', now)
          .order('end_at');
      promos = promoRows.map(_asStringKeyMap).toList();
    } catch (_) {
      // Promotions may be blocked for anon; gym + hours still shown.
    }

    return {
      'gym': _asStringKeyMap(gymRow),
      'hours': hoursRows.map(_asStringKeyMap).toList(),
      'promotions': promos,
    };
  }
}

final gymsRepositoryProvider = Provider<GymsRepository>((ref) {
  return GymsRepository(ref.watch(supabaseClientProvider));
});

final directoryGymsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(gymsRepositoryProvider).listDirectoryGyms();
});

final directoryGymDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, gymId) => ref.watch(gymsRepositoryProvider).directoryGymDetail(gymId),
);

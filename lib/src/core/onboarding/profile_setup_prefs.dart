import 'dart:convert';

import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupPrefs {
  ProfileSetupPrefs._();

  static const _completedKey = 'profile_setup_completed_v1';
  static const _dataKey = 'profile_setup_data_v1';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }

  static Future<ProfileSetupData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ProfileSetupData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(ProfileSetupData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(data.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_dataKey);
  }
}

import 'package:intl/intl.dart';

class ProfileDisplayUtils {
  ProfileDisplayUtils._();

  static bool hasText(String? value) => value != null && value.trim().isNotEmpty;

  static String formatDate(String? raw, DateFormat format) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return format.format(parsed);
  }

  static String shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 4)}';
  }

  static String fitnessGoalLabel(String key) {
    return switch (key) {
      'weight_loss' => 'Lose weight',
      'muscle_gain' => 'Build muscle',
      'healthy' => 'Stay healthy',
      _ => key,
    };
  }

  static String genderLabel(String key) {
    return switch (key) {
      'male' => 'Male',
      'female' => 'Female',
      'other' => 'Other',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => key,
    };
  }

  static String? truncate(String? value, {int maxLength = 48}) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return '${trimmed.substring(0, maxLength - 1)}…';
  }
}

import 'dart:convert';

Map<String, dynamic> asStringKeyMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  if (value is String && value.trim().isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map) {
      return decoded.map((key, val) => MapEntry(key.toString(), val));
    }
  }
  throw const FormatException('Expected a JSON object.');
}

Map<String, dynamic>? tryAsStringKeyMap(dynamic value) {
  try {
    return asStringKeyMap(value);
  } catch (_) {
    return null;
  }
}

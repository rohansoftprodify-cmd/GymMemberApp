/// QR payload format for gym check-in stations.
/// Example: gym_checkin:550e8400-e29b-41d4-a716-446655440000
const String attendanceQrPrefix = 'gym_checkin:';

String attendanceQrPayload(String gymId) => '$attendanceQrPrefix$gymId';

String attendanceCheckInDeepLink(String gymId) => 'gymmember://checkin?gymId=$gymId';

String? gymIdFromAttendanceQr(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith(attendanceQrPrefix)) return null;
  final id = trimmed.substring(attendanceQrPrefix.length).trim();
  return id.isEmpty ? null : id;
}

String? gymIdFromCheckInDeepLink(Uri uri) {
  if (uri.scheme != 'gymmember') return null;
  if (uri.host != 'checkin') return null;
  final gymId = uri.queryParameters['gymId']?.trim();
  return gymId == null || gymId.isEmpty ? null : gymId;
}

/// Parses scanned QR text or a deep-link URL into a gym id.
String? gymIdFromCheckInInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final fromPayload = gymIdFromAttendanceQr(trimmed);
  if (fromPayload != null) return fromPayload;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  return gymIdFromCheckInDeepLink(uri);
}

/// Normalizes any supported check-in input to the standard QR payload string.
String? checkInQrPayloadFromInput(String raw) {
  final gymId = gymIdFromCheckInInput(raw);
  if (gymId == null) return null;
  return attendanceQrPayload(gymId);
}

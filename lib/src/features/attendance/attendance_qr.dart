/// QR payload format for gym check-in stations.
/// Example: gym_checkin:550e8400-e29b-41d4-a716-446655440000
const String attendanceQrPrefix = 'gym_checkin:';

String? gymIdFromAttendanceQr(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith(attendanceQrPrefix)) {
    final id = trimmed.substring(attendanceQrPrefix.length).trim();
    return id.isEmpty ? null : id;
  }
  return null;
}

String attendanceQrPayload(String gymId) => '$attendanceQrPrefix$gymId';

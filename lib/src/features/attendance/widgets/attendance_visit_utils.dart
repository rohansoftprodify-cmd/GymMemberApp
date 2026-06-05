import 'package:intl/intl.dart';

class AttendanceVisitInfo {
  const AttendanceVisitInfo({
    required this.checkIn,
    this.checkOut,
    this.recordId,
  });

  final DateTime checkIn;
  final DateTime? checkOut;
  final String? recordId;

  bool get isActive => checkOut == null;

  Duration? get duration {
    if (checkOut == null) return null;
    return checkOut!.difference(checkIn);
  }

  factory AttendanceVisitInfo.fromMap(Map<String, dynamic> map) {
    return AttendanceVisitInfo(
      recordId: map['id'] as String?,
      checkIn: DateTime.parse(map['check_in_at'] as String).toLocal(),
      checkOut: map['check_out_at'] == null
          ? null
          : DateTime.parse(map['check_out_at'] as String).toLocal(),
    );
  }
}

String formatVisitDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
  if (hours > 0) return '${hours}h';
  if (minutes > 0) return '${minutes}m';
  return '< 1m';
}

String visitDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEE').format(date);
}

String visitDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return DateFormat('MMM d').format(date);
  if (day == today.subtract(const Duration(days: 1))) return DateFormat('MMM d').format(date);
  return DateFormat('MMM d').format(date);
}

String visitSectionTitle(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEEE, MMM d').format(date);
}

Map<String, List<AttendanceVisitInfo>> groupVisitsByDay(List<Map<String, dynamic>> records) {
  final grouped = <String, List<AttendanceVisitInfo>>{};
  for (final record in records) {
    final visit = AttendanceVisitInfo.fromMap(record);
    final key = DateFormat('yyyy-MM-dd').format(visit.checkIn);
    grouped.putIfAbsent(key, () => []).add(visit);
  }
  return grouped;
}

List<String> sortedDayKeys(Map<String, List<AttendanceVisitInfo>> grouped) {
  return grouped.keys.toList()..sort((a, b) => b.compareTo(a));
}

int visitsThisMonth(List<Map<String, dynamic>> records) {
  final now = DateTime.now();
  return records.where((row) {
    final raw = row['check_in_at'] as String?;
    final time = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (time == null) return false;
    return time.year == now.year && time.month == now.month;
  }).length;
}

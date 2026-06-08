import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/features/attendance/attendance_qr.dart';
import 'package:gym_member_app/src/features/attendance/location_check_service.dart';

class CheckInFlowResult {
  const CheckInFlowResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}

/// Validates gym QR / deep link, verifies GPS proximity, and marks attendance.
Future<CheckInFlowResult> runCheckInFromQrPayload({
  required BuildContext context,
  required WidgetRef ref,
  required String qrPayload,
  required String memberGymId,
  required String memberName,
  required String gymName,
  required bool hasOpenSession,
  required double? gymLatitude,
  required double? gymLongitude,
  required int gymRadiusMeters,
}) async {
  final parsedGymId = gymIdFromAttendanceQr(qrPayload);
  if (parsedGymId == null) {
    return const CheckInFlowResult(success: false, message: 'Invalid gym QR code.');
  }

  if (parsedGymId != memberGymId) {
    return const CheckInFlowResult(
      success: false,
      message: 'This QR belongs to another gym.',
    );
  }

  final locationResult = await verifyNearGym(
    gymLatitude: gymLatitude,
    gymLongitude: gymLongitude,
    radiusMeters: gymRadiusMeters,
  );

  if (!locationResult.isSuccess) {
    return CheckInFlowResult(
      success: false,
      message: locationResult.errorMessage ?? 'Location check failed.',
    );
  }

  final latitude = locationResult.latitude;
  final longitude = locationResult.longitude;
  if (latitude == null || longitude == null) {
    return const CheckInFlowResult(success: false, message: 'Could not read your location.');
  }

  if (!context.mounted) {
    return const CheckInFlowResult(success: false, message: 'Cancelled.');
  }

  final action = hasOpenSession ? 'check_out' : 'check_in';
  final actionLabel = action == 'check_in' ? 'Check in' : 'Check out';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('$actionLabel?'),
      content: Text(
        'Mark attendance for $memberName at $gymName?\n\n'
        'You are within ${locationResult.distanceMeters?.round() ?? 0} m of the gym.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(actionLabel),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return const CheckInFlowResult(success: false, message: 'Cancelled.');
  }

  try {
    final repo = ref.read(memberRepositoryProvider);
    final result = await repo.markAttendanceFromQr(
      raw: qrPayload,
      action: action,
      latitude: latitude,
      longitude: longitude,
    );
    final name = result['member_name'] as String? ?? memberName;
    final verb = action == 'check_in' ? 'checked in' : 'checked out';
    ref.invalidate(memberContextProvider);
    return CheckInFlowResult(success: true, message: '$name $verb successfully.');
  } catch (e) {
    return CheckInFlowResult(
      success: false,
      message: e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

/// Deep link entry: gym id only — builds standard QR payload then runs flow.
Future<CheckInFlowResult> runCheckInFromGymId({
  required BuildContext context,
  required WidgetRef ref,
  required String gymId,
  required MemberContext member,
  required bool hasOpenSession,
  required double? gymLatitude,
  required double? gymLongitude,
  required int gymRadiusMeters,
}) {
  return runCheckInFromQrPayload(
    context: context,
    ref: ref,
    qrPayload: attendanceQrPayload(gymId),
    memberGymId: member.gymId,
    memberName: member.fullName,
    gymName: member.gymName,
    hasOpenSession: hasOpenSession,
    gymLatitude: gymLatitude,
    gymLongitude: gymLongitude,
    gymRadiusMeters: gymRadiusMeters,
  );
}

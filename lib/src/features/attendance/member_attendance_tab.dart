import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/location_check_service.dart';
import 'package:gym_member_app/src/features/attendance/check_in_flow.dart';
import 'package:gym_member_app/src/features/attendance/qr_scan_page.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_method_card.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_stats_row.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_status_hero.dart';
import 'package:gym_member_app/src/features/home/widgets/home_recent_attendance_section.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:intl/intl.dart';

class MemberAttendanceTab extends ConsumerStatefulWidget {
  const MemberAttendanceTab({super.key, required this.member});

  final MemberContext member;

  @override
  ConsumerState<MemberAttendanceTab> createState() => _MemberAttendanceTabState();
}

class _MemberAttendanceTabState extends ConsumerState<MemberAttendanceTab> {
  int _reloadToken = 0;
  bool _busy = false;

  static const _sectionGap = 18.0;

  void _refresh() => setState(() => _reloadToken++);

  Future<void> _pullRefresh() async {
    final repo = ref.read(memberRepositoryProvider);
    setState(() => _reloadToken++);
    await Future.wait<dynamic>([
      repo.openAttendance(widget.member.gymId, widget.member.memberId),
      repo.gymInfo(widget.member.gymId),
      repo.myAttendance(widget.member.gymId, widget.member.memberId, limit: 30),
    ]);
  }

  Future<void> _performAction(
    String action, {
    required double latitude,
    required double longitude,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(memberRepositoryProvider).markMyAttendance(
            gymId: widget.member.gymId,
            action: action,
            latitude: latitude,
            longitude: longitude,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'check_in' ? 'Checked in successfully' : 'Checked out successfully',
          ),
        ),
      );
      _refresh();
      ref.invalidate(memberContextProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _locationAttendance(Map<String, dynamic>? gym, Map<String, dynamic>? open) async {
    if (_busy) return;

    final lat = (gym?['latitude'] as num?)?.toDouble();
    final lng = (gym?['longitude'] as num?)?.toDouble();
    final radius = (gym?['check_in_radius_meters'] as num?)?.toInt() ?? 150;
    final hasCoords = lat != null && lng != null;

    if (!hasCoords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gym location is not configured. Use QR check-in or contact staff.')),
      );
      return;
    }

    setState(() => _busy = true);
    final locationResult = await verifyNearGym(
      gymLatitude: lat,
      gymLongitude: lng,
      radiusMeters: radius,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (!locationResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locationResult.errorMessage ?? 'Location check failed')),
      );
      return;
    }

    final action = open == null ? 'check_in' : 'check_out';
    await _performAction(
      action,
      latitude: locationResult.latitude!,
      longitude: locationResult.longitude!,
    );
  }

  Future<void> _qrAttendance(Map<String, dynamic>? gym, Map<String, dynamic>? open) async {
    if (_busy) return;
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(expectedGymId: widget.member.gymId),
      ),
    );
    if (payload == null || !mounted) return;

    setState(() => _busy = true);
    final lat = (gym?['latitude'] as num?)?.toDouble();
    final lng = (gym?['longitude'] as num?)?.toDouble();
    final radius = (gym?['check_in_radius_meters'] as num?)?.toInt() ?? 150;

    final result = await runCheckInFromQrPayload(
      context: context,
      ref: ref,
      qrPayload: payload,
      memberGymId: widget.member.gymId,
      memberName: widget.member.fullName,
      gymName: widget.member.gymName,
      hasOpenSession: open != null,
      gymLatitude: lat,
      gymLongitude: lng,
      gymRadiusMeters: radius,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.message != null && result.message != 'Cancelled.') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    }
    if (result.success) {
      _refresh();
    }
  }

  static int _visitsToday(List<Map<String, dynamic>> records) {
    final now = DateTime.now();
    return records.where((row) {
      final raw = row['check_in_at'] as String?;
      final time = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
      if (time == null) return false;
      return time.year == now.year && time.month == now.month && time.day == now.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final repo = ref.read(memberRepositoryProvider);
    final timeFormat = DateFormat('MMM d · h:mm a');
    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_reloadToken),
      future: Future.wait<dynamic>([
        repo.openAttendance(widget.member.gymId, widget.member.memberId),
        repo.gymInfo(widget.member.gymId),
        repo.myAttendance(widget.member.gymId, widget.member.memberId, limit: 30),
      ]),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(snap.error.toString(), textAlign: TextAlign.center),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final open = snap.data![0] as Map<String, dynamic>?;
        final gym = snap.data![1] as Map<String, dynamic>?;
        final allRecords = snap.data![2] as List<Map<String, dynamic>>;
        final recentRecords = allRecords.take(5).toList();

        final isCheckedIn = open != null;
        final checkInSince = open == null
            ? null
            : timeFormat.format(DateTime.parse(open['check_in_at'] as String).toLocal());
        final hasCoords = gym?['latitude'] != null && gym?['longitude'] != null;
        final radius = gym?['check_in_radius_meters'] ?? 150;

        return RefreshIndicator(
          onRefresh: _pullRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            children: [
              AttendanceStatusHero(
                isCheckedIn: isCheckedIn,
                checkInSince: checkInSince,
                gymName: widget.member.gymName,
              ),
              const SizedBox(height: _sectionGap),
              AttendanceStatsRow(
                totalVisits: allRecords.length,
                visitsToday: _visitsToday(allRecords),
                isCheckedIn: isCheckedIn,
              ),
              const SizedBox(height: _sectionGap),
              const HomeSectionLabel(
                title: 'Check-in methods',
                icon: Icons.touch_app_rounded,
              ),
              AttendanceMethodCard(
                icon: Icons.my_location_rounded,
                title: 'At gym (location)',
                subtitle: hasCoords
                    ? 'Must be within ${radius}m of the gym entrance'
                    : 'Gym GPS not set — ask staff or use QR',
                buttonLabel: isCheckedIn ? 'Check out with location' : 'Check in with location',
                onPressed: () => _locationAttendance(gym, open),
                loading: _busy,
                enabled: hasCoords,
                accentColor: colorScheme.primary,
              ),
              const SizedBox(height: 10),
              AttendanceMethodCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan QR code',
                subtitle: hasCoords
                    ? 'Scan gym QR — you must be on-site (within ${radius}m)'
                    : 'Gym location not set — ask staff to configure coordinates',
                buttonLabel: isCheckedIn ? 'Scan to check out' : 'Scan to check in',
                onPressed: hasCoords ? () => _qrAttendance(gym, open) : null,
                enabled: hasCoords,
                loading: _busy,
                accentColor: colorScheme.secondary,
              ),
              if (!hasCoords) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Location check-in needs gym coordinates. QR check-in still works.',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: _sectionGap),
              HomeRecentAttendanceSection(
                records: recentRecords,
                onViewAll: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MyAttendancePage(
                      gymId: widget.member.gymId,
                      memberId: widget.member.memberId,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Pull down to refresh status',
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

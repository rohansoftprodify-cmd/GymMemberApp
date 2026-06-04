import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/location_check_service.dart';
import 'package:gym_member_app/src/features/attendance/qr_scan_page.dart';
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

  void _refresh() => setState(() => _reloadToken++);

  Future<Map<String, dynamic>?> _loadGymInfo() {
    return ref.read(memberRepositoryProvider).gymInfo(widget.member.gymId);
  }

  Future<Map<String, dynamic>?> _loadOpen() {
    return ref
        .read(memberRepositoryProvider)
        .openAttendance(widget.member.gymId, widget.member.memberId);
  }

  Future<void> _performAction(String action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(memberRepositoryProvider).markMyAttendance(
            gymId: widget.member.gymId,
            action: action,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'check_in' ? 'Checked in successfully' : 'Checked out successfully'),
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

  Future<void> _locationAttendance() async {
    if (_busy) return;
    final gym = await _loadGymInfo();
    if (!mounted) return;

    final lat = (gym?['latitude'] as num?)?.toDouble();
    final lng = (gym?['longitude'] as num?)?.toDouble();
    final radius = (gym?['check_in_radius_meters'] as num?)?.toInt() ?? 150;

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

    final open = await _loadOpen();
    final action = open == null ? 'check_in' : 'check_out';
    await _performAction(action);
  }

  Future<void> _qrAttendance() async {
    if (_busy) return;
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(expectedGymId: widget.member.gymId),
      ),
    );
    if (ok != true || !mounted) return;

    final open = await _loadOpen();
    final action = open == null ? 'check_in' : 'check_out';
    await _performAction(action);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final repo = ref.read(memberRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_reloadToken),
      future: Future.wait([
        _loadOpen(),
        _loadGymInfo(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final open = snap.data![0] as Map<String, dynamic>?;
        final gym = snap.data![1] as Map<String, dynamic>?;
        final isCheckedIn = open != null;
        final checkInLabel = open == null
            ? null
            : DateFormat('MMM d · h:mm a')
                .format(DateTime.parse(open['check_in_at'] as String).toLocal());

        return ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 8),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: semantics.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCheckedIn
                      ? colorScheme.primary.withValues(alpha: 0.4)
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCheckedIn ? Icons.login_rounded : Icons.logout_rounded,
                        color: isCheckedIn ? colorScheme.primary : semantics.mutedText,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isCheckedIn ? 'You are checked in' : 'You are checked out',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  if (checkInLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Since $checkInLabel',
                      style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    isCheckedIn
                        ? 'Use either method below to check out.'
                        : 'Use either method below to check in at the gym.',
                    style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Check-in / Check-out',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _MethodCard(
              icon: Icons.my_location_rounded,
              title: 'At gym (location)',
              subtitle: gym?['latitude'] == null
                  ? 'Gym coordinates not set — contact staff'
                  : 'Must be within ${gym?['check_in_radius_meters'] ?? 150}m of the gym',
              buttonLabel: isCheckedIn ? 'Check out here' : 'Check in here',
              onPressed: _busy ? null : _locationAttendance,
              loading: _busy,
            ),
            const SizedBox(height: 10),
            _MethodCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan QR code',
              subtitle: 'Scan the QR posted at your gym entrance',
              buttonLabel: isCheckedIn ? 'Scan to check out' : 'Scan to check in',
              onPressed: _busy ? null : _qrAttendance,
              loading: _busy,
            ),
            const SizedBox(height: 20),
            Text(
              'Recent visits',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: repo.myAttendance(widget.member.gymId, widget.member.memberId, limit: 5),
              builder: (context, attSnap) {
                if (!attSnap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final rows = attSnap.data!;
                if (rows.isEmpty) {
                  return Text(
                    'No attendance yet.',
                    style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                  );
                }
                final format = DateFormat('MMM d, y · h:mm a');
                return Column(
                  children: [
                    for (final row in rows)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: semantics.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In: ${format.format(DateTime.parse(row['check_in_at'] as String).toLocal())}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              row['check_out_at'] == null
                                  ? 'Still checked in'
                                  : 'Out: ${format.format(DateTime.parse(row['check_out_at'] as String).toLocal())}',
                              style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

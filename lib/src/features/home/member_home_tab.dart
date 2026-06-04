import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/core/ui/section_header.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:gym_member_app/src/features/home/widgets/home_plan_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_quick_stat_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_recent_attendance_section.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/home/widgets/home_welcome_header.dart';
import 'package:gym_member_app/src/features/home/widgets/offers_carousel.dart';
import 'package:gym_member_app/src/features/home/widgets/payment_dues_list.dart';
import 'package:intl/intl.dart';

class MemberHomeTab extends ConsumerWidget {
  const MemberHomeTab({
    super.key,
    required this.member,
    this.onGoToAttendance,
  });

  final MemberContext member;
  final VoidCallback? onGoToAttendance;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _sectionGap = 20.0;
  static const _quickStatHeight = 132.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final sub = member.subscription;
    final repo = ref.read(memberRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        repo.openAttendance(member.gymId, member.memberId),
        repo.todayOperatingHours(member.gymId),
        repo.activePromotions(member.gymId),
        repo.myAttendance(member.gymId, member.memberId, limit: 5),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final openRecord = snap.data![0] as Map<String, dynamic>?;
        final hoursRow = snap.data![1] as Map<String, dynamic>?;
        final promos = snap.data![2] as List<Map<String, dynamic>>;
        final recentAttendance = snap.data![3] as List<Map<String, dynamic>>;
        final format = DateFormat('MMM d · h:mm a');

        final isCheckedIn = openRecord != null;
        final todayName = _dayNames[DateTime.now().weekday - 1];
        final slot = _slotInfo(hoursRow, todayName, colorScheme.primary, semantics);

        return ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 4),
          children: [
            HomeWelcomeHeader(
              member: member,
              onTapProfile: () => context.push('/profile'),
            ),
            const SizedBox(height: _sectionGap),
            const HomeSectionLabel(title: 'Today', icon: Icons.today_rounded),
            SizedBox(
              height: _quickStatHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomeQuickStatCard(
                      icon: isCheckedIn ? Icons.login_rounded : Icons.logout_rounded,
                      label: 'Attendance',
                      value: isCheckedIn ? 'Checked in' : 'Checked out',
                      accentColor: isCheckedIn ? colorScheme.primary : semantics.mutedText,
                      highlighted: isCheckedIn,
                      actionLabel: 'Open',
                      onAction: onGoToAttendance,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HomeQuickStatCard(
                      icon: slot.icon,
                      label: "Today's slot",
                      value: slot.value,
                      accentColor: slot.color,
                      highlighted: slot.highlighted,
                    ),
                  ),
                ],
              ),
            ),
            if (isCheckedIn && openRecord != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Checked in since ${DateFormat.jm().format(DateTime.parse(openRecord['check_in_at'] as String).toLocal())}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (sub != null) ...[
              const SizedBox(height: _sectionGap),
              HomePlanCard(subscription: sub),
            ],
            const SizedBox(height: _sectionGap),
            const SectionHeader(title: 'Offers'),
            const SizedBox(height: 6),
            OffersCarousel(promotions: promos),
            if (sub != null && _showPaymentAlerts(sub)) ...[
              const SizedBox(height: _sectionGap),
              const SectionHeader(title: 'Payment alerts'),
              const SizedBox(height: 6),
              PaymentDuesList(subscription: sub),
            ],
            const SizedBox(height: _sectionGap),
            HomeRecentAttendanceSection(
              records: recentAttendance,
              format: format,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyAttendancePage(
                    gymId: member.gymId,
                    memberId: member.memberId,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _showPaymentAlerts(MemberSubscriptionContext sub) {
    final status = sub.paymentStatus.toLowerCase();
    if (status == 'due' || status == 'partial') return true;
    final end = DateTime.tryParse(sub.endDate);
    if (end == null) return false;
    final days = end.difference(DateTime.now()).inDays;
    return days <= 15;
  }

  static _SlotDisplay _slotInfo(
    Map<String, dynamic>? hoursRow,
    String todayName,
    Color primary,
    AppSemanticColors semantics,
  ) {
    if (hoursRow == null) {
      return _SlotDisplay(
        icon: Icons.schedule_rounded,
        value: 'Not set',
        color: semantics.mutedText,
      );
    }
    if (hoursRow['is_closed'] == true) {
      return _SlotDisplay(
        icon: Icons.event_busy_rounded,
        value: '$todayName · Closed',
        color: semantics.accentCoral,
      );
    }
    final open = _formatTime(hoursRow['open_time']);
    final close = _formatTime(hoursRow['close_time']);
    return _SlotDisplay(
      icon: Icons.access_time_rounded,
      value: '$open – $close',
      color: primary,
      highlighted: true,
    );
  }

  static String _formatTime(dynamic raw) {
    if (raw == null) return '—';
    final s = raw.toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }
}

class _SlotDisplay {
  const _SlotDisplay({
    required this.icon,
    required this.value,
    required this.color,
    this.highlighted = false,
  });

  final IconData icon;
  final String value;
  final Color color;
  final bool highlighted;
}

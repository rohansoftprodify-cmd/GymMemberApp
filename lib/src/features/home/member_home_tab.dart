import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:gym_member_app/src/features/home/widgets/home_check_in_banner.dart';
import 'package:gym_member_app/src/features/home/widgets/home_plan_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_quick_actions.dart';
import 'package:gym_member_app/src/features/home/widgets/home_quick_stat_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_recent_attendance_section.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/home/widgets/home_welcome_header.dart';
import 'package:gym_member_app/src/features/home/widgets/offers_carousel.dart';
import 'package:gym_member_app/src/features/home/widgets/payment_dues_list.dart';

class MemberHomeTab extends ConsumerStatefulWidget {
  const MemberHomeTab({
    super.key,
    required this.member,
    this.onGoToAttendance,
    this.onGoToGyms,
  });

  final MemberContext member;
  final VoidCallback? onGoToAttendance;
  final VoidCallback? onGoToGyms;

  @override
  ConsumerState<MemberHomeTab> createState() => _MemberHomeTabState();
}

class _MemberHomeTabState extends ConsumerState<MemberHomeTab> {
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _sectionGap = 20.0;
  static const _quickStatHeight = 148.0;

  int _refreshTick = 0;

  Future<List<dynamic>> _loadHomeData() {
    final repo = ref.read(memberRepositoryProvider);
    return Future.wait([
      repo.openAttendance(widget.member.gymId, widget.member.memberId),
      repo.todayOperatingHours(widget.member.gymId),
      repo.activePromotions(widget.member.gymId),
      repo.myAttendance(widget.member.gymId, widget.member.memberId, limit: 5),
    ]);
  }

  Future<void> _onRefresh() async {
    ref.invalidate(memberProfileProvider);
    setState(() => _refreshTick++);
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final semantics = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final sub = widget.member.subscription;
    final profileAsync = ref.watch(memberProfileProvider);

    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_refreshTick),
      future: _loadHomeData(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final openRecord = snap.data![0] as Map<String, dynamic>?;
        final hoursRow = snap.data![1] as Map<String, dynamic>?;
        final promos = snap.data![2] as List<Map<String, dynamic>>;
        final recentAttendance = snap.data![3] as List<Map<String, dynamic>>;

        final isCheckedIn = openRecord != null;
        final todayName = _dayNames[DateTime.now().weekday - 1];
        final slot = _slotInfo(hoursRow, todayName, colorScheme.primary, semantics);
        final profile = profileAsync.valueOrNull;
        final totalVisits = profile?.attendanceStats.totalVisits;
        final fitnessGoalLabel = _fitnessGoalLabel(profile?.fitnessGoal);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            children: [
              HomeWelcomeHeader(
                member: widget.member,
                onTapProfile: () => context.push('/profile'),
                totalVisits: totalVisits,
                fitnessGoalLabel: fitnessGoalLabel,
                isCheckedIn: isCheckedIn,
              ),
              const SizedBox(height: 14),
              HomeQuickActions(
                actions: [
                  HomeQuickAction(
                    icon: isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                    label: 'Attendance',
                    accentColor: isCheckedIn ? colorScheme.primary : semantics.mutedText,
                    onTap: widget.onGoToAttendance ?? () {},
                  ),
                  HomeQuickAction(
                    icon: Icons.fitness_center_outlined,
                    label: 'My gym',
                    onTap: () => context.push('/gym/${widget.member.gymId}'),
                  ),
                  HomeQuickAction(
                    icon: Icons.psychology_rounded,
                    label: 'AI Coach',
                    onTap: () => context.push('/fitness-chat'),
                  ),
                  HomeQuickAction(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () => context.push('/profile'),
                  ),
                ],
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
                        onAction: widget.onGoToAttendance,
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
              if (isCheckedIn) ...[
                const SizedBox(height: 10),
                HomeCheckInBanner(
                  checkInAt: DateTime.parse(openRecord['check_in_at'] as String).toLocal(),
                  onOpenAttendance: widget.onGoToAttendance,
                ),
              ],
              if (sub != null) ...[
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Subscription', icon: Icons.card_membership_rounded),
                HomePlanCard(subscription: sub),
              ],
              const SizedBox(height: _sectionGap),
              const HomeSectionLabel(title: 'Offers', icon: Icons.local_offer_outlined),
              const SizedBox(height: 4),
              OffersCarousel(promotions: promos),
              if (sub != null && _showPaymentAlerts(sub)) ...[
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Payment alerts', icon: Icons.payments_outlined),
                const SizedBox(height: 4),
                PaymentDuesList(subscription: sub),
              ],
              const SizedBox(height: _sectionGap),
              HomeRecentAttendanceSection(
                records: recentAttendance,
                onViewAll: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MyAttendancePage(
                      gymId: widget.member.gymId,
                      memberId: widget.member.memberId,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _fitnessGoalLabel(String? key) {
    if (key == null || key.isEmpty) return null;
    return switch (key) {
      'weight_loss' => 'Lose weight',
      'muscle_gain' => 'Build muscle',
      'healthy' => 'Stay healthy',
      _ => null,
    };
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

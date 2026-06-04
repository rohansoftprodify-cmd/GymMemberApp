import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/core/ui/section_header.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:gym_member_app/src/features/home/widgets/check_in_status_card.dart';
import 'package:gym_member_app/src/features/home/widgets/offers_carousel.dart';
import 'package:gym_member_app/src/features/home/widgets/payment_dues_list.dart';
import 'package:gym_member_app/src/features/home/widgets/today_slot_card.dart';
import 'package:intl/intl.dart';

class MemberHomeTab extends ConsumerWidget {
  const MemberHomeTab({
    super.key,
    required this.member,
    this.onGoToAttendance,
  });

  final MemberContext member;
  final VoidCallback? onGoToAttendance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final sub = member.subscription;
    final dateFormat = DateFormat.yMMMd();
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

        return ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 4),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: semantics.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${member.fullName}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.email ?? member.phone ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (sub != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantics.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan details',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sub.planName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${dateFormat.format(DateTime.parse(sub.startDate))} → ${dateFormat.format(DateTime.parse(sub.endDate))}',
                      style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment: ${sub.paymentStatus.toUpperCase()} · Paid ₹${sub.amountPaid} / ₹${sub.planPrice}',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TodaySlotCard(hoursRow: hoursRow),
            const SizedBox(height: 12),
            CheckInStatusCard(
              openRecord: openRecord,
              onGoToAttendance: onGoToAttendance,
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Offers by gym'),
            const SizedBox(height: 8),
            OffersCarousel(promotions: promos),
            if (sub != null) ...[
              const SizedBox(height: 16),
              const SectionHeader(title: 'Payment alerts'),
              const SizedBox(height: 8),
              PaymentDuesList(subscription: sub),
            ],
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Last 5 attendance',
              actionLabel: 'View all',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyAttendancePage(
                    gymId: member.gymId,
                    memberId: member.memberId,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (recentAttendance.isEmpty)
              Text(
                'No visits recorded yet.',
                style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
              )
            else
              ...recentAttendance.map((row) {
                final checkIn = DateTime.parse(row['check_in_at'] as String).toLocal();
                final checkOutRaw = row['check_out_at'] as String?;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantics.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format.format(checkIn),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        checkOutRaw == null
                            ? 'Still checked in'
                            : 'Out ${format.format(DateTime.parse(checkOutRaw).toLocal())}',
                        style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

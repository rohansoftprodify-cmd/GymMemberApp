import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/domain/payment_utils.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';

class HomePlanCard extends StatelessWidget {
  const HomePlanCard({super.key, required this.subscription});

  final MemberSubscriptionContext subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat.yMMMd();

    final paid = subscription.amountPaid.toDouble();
    final total = subscription.planPrice.toDouble();
    final progress = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    final remaining = pendingAmount(planPrice: total, amountPaid: paid);
    final isDue = isPaymentDue(subscription.paymentStatus);
    final daysLeft = renewalDaysLeft(subscription.endDate);

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.12),
                  colorScheme.secondary.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.card_membership_rounded, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'My plan',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (daysLeft != null)
                  _StatusChip(
                    label: daysLeft == 0 ? 'Expires today' : '$daysLeft days left',
                    background: (daysLeft <= 7 ? semantics.accentCoral : colorScheme.primary)
                        .withValues(alpha: 0.12),
                    foreground: daysLeft <= 7 ? semantics.accentCoral : colorScheme.primary,
                  ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: subscription.paymentStatus.toUpperCase(),
                  background: (isDue ? semantics.accentCoral : colorScheme.primary)
                      .withValues(alpha: 0.12),
                  foreground: isDue ? semantics.accentCoral : colorScheme.primary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.planName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  '${dateFormat.format(DateTime.parse(subscription.startDate))} → ${dateFormat.format(DateTime.parse(subscription.endDate))}',
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid ₹${paid.toStringAsFixed(0)}',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      remaining > 0 ? 'Due ₹${remaining.toStringAsFixed(0)}' : 'Fully paid',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: remaining > 0 ? semantics.accentCoral : colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: foreground,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

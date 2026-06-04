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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'My plan',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDue ? semantics.accentCoral : colorScheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subscription.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isDue ? semantics.accentCoral : colorScheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              minHeight: 6,
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
    );
  }
}

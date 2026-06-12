import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/domain/payment_utils.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';

class PaymentDuesList extends StatelessWidget {
  const PaymentDuesList({super.key, required this.subscription});

  final MemberSubscriptionContext subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    final alerts = <_DueAlert>[];
    if (isPaymentDue(subscription.paymentStatus)) {
      final remaining = pendingAmount(
        planPrice: subscription.planPrice.toDouble(),
        amountPaid: subscription.amountPaid.toDouble(),
      );
      alerts.add(
        _DueAlert(
          title: 'Payment due',
          subtitle: subscription.planName,
          amount: remaining,
          status: subscription.paymentStatus.toUpperCase(),
          dueLabel: 'Plan ends ${DateFormat.yMMMd().format(DateTime.parse(subscription.endDate))}',
          accent: semantics.accentCoral,
        ),
      );
    }

    final daysLeft = renewalDaysLeft(subscription.endDate);
    if (daysLeft != null && daysLeft <= 15) {
      alerts.add(
        _DueAlert(
          title: 'Renewal soon',
          subtitle: subscription.planName,
          amount: subscription.planPrice.toDouble(),
          status: 'RENEW',
          dueLabel: daysLeft == 0 ? 'Expires today' : 'In $daysLeft days',
          accent: semantics.accentLime,
        ),
      );
    }

    if (alerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: semantics.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: colorScheme.primary.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'No payment alerts.',
              style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _DueCard(alert: alerts[i]),
      ),
    );
  }
}

class _DueAlert {
  const _DueAlert({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.dueLabel,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final double amount;
  final String status;
  final String dueLabel;
  final Color accent;
}

class _DueCard extends StatelessWidget {
  const _DueCard({required this.alert});

  final _DueAlert alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: semantics.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: alert.accent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: alert.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.status,
                        style: TextStyle(
                          color: alert.accent,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alert.dueLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: semantics.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${alert.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'AMOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: semantics.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';

class CheckInStatusCard extends StatelessWidget {
  const CheckInStatusCard({
    super.key,
    required this.openRecord,
    this.onGoToAttendance,
  });

  final Map<String, dynamic>? openRecord;
  final VoidCallback? onGoToAttendance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final isCheckedIn = openRecord != null;

    final statusLabel = isCheckedIn ? 'Checked in' : 'Checked out';
    final statusColor = isCheckedIn ? colorScheme.primary : semantics.mutedText;
    final subtitle = isCheckedIn
        ? 'Since ${DateFormat.jm().format(DateTime.parse(openRecord!['check_in_at'] as String).toLocal())}'
        : 'Tap Attendance tab to check in at the gym';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCheckedIn
              ? colorScheme.primary.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCheckedIn ? Icons.login_rounded : Icons.logout_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                ),
              ],
            ),
          ),
          if (onGoToAttendance != null)
            TextButton(
              onPressed: onGoToAttendance,
              child: const Text('Go'),
            ),
        ],
      ),
    );
  }
}

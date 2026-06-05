import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';

class HomeCheckInBanner extends StatelessWidget {
  const HomeCheckInBanner({
    super.key,
    required this.checkInAt,
    this.onOpenAttendance,
  });

  final DateTime checkInAt;
  final VoidCallback? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final timeLabel = DateFormat.jm().format(checkInAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.14),
            semantics.accentLime.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.login_rounded, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are checked in',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Since $timeLabel · Tap to manage attendance',
                    style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                  ),
                ],
              ),
            ),
            if (onOpenAttendance != null)
              IconButton(
                onPressed: onOpenAttendance,
                icon: Icon(Icons.arrow_forward_rounded, color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

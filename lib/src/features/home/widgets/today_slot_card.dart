import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class TodaySlotCard extends StatelessWidget {
  const TodaySlotCard({super.key, required this.hoursRow});

  final Map<String, dynamic>? hoursRow;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final todayName = _dayNames[DateTime.now().weekday - 1];

    String slotLabel;
    IconData icon;
    Color iconColor;

    if (hoursRow == null) {
      slotLabel = 'Hours not set for today';
      icon = Icons.schedule_rounded;
      iconColor = semantics.mutedText;
    } else if (hoursRow!['is_closed'] == true) {
      slotLabel = 'Closed today';
      icon = Icons.event_busy_rounded;
      iconColor = semantics.accentCoral;
    } else {
      final open = _formatTime(hoursRow!['open_time']);
      final close = _formatTime(hoursRow!['close_time']);
      slotLabel = '$open – $close';
      icon = Icons.access_time_rounded;
      iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's gym slot",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: semantics.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$todayName · $slotLabel',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '—';
    final s = raw.toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }
}

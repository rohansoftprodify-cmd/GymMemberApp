import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class GymWeeklyHoursCard extends StatelessWidget {
  const GymWeeklyHoursCard({super.key, required this.hours});

  final List<Map<String, dynamic>> hours;

  static const _dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    if (hours.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: semantics.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: semantics.mutedText),
            const SizedBox(width: 12),
            Text(
              'Operating hours not configured.',
              style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < hours.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            _HoursRow(row: hours[i], dayNames: _dayNames),
          ],
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.row, required this.dayNames});

  final Map<String, dynamic> row;
  final List<String> dayNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final day = row['day_of_week'] as int? ?? 1;
    final closed = row['is_closed'] == true;
    final label = closed
        ? 'Closed'
        : '${_formatTime(row['open_time'])} – ${_formatTime(row['close_time'])}';
    final isToday = day == DateTime.now().weekday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (isToday)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
            ),
          Expanded(
            child: Text(
              dayNames[day],
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? colorScheme.primary : null,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (closed ? semantics.accentCoral : colorScheme.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: closed ? semantics.accentCoral : semantics.mutedText,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
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

/// Resolves today's hours label from weekly hours list.
({String label, bool isOpen}) todayHoursInfo(List<Map<String, dynamic>> hours) {
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final today = DateTime.now().weekday;
  Map<String, dynamic>? row;
  for (final h in hours) {
    if ((h['day_of_week'] as int? ?? 0) == today) {
      row = h;
      break;
    }
  }

  if (row == null) {
    return (label: '${dayNames[today - 1]} · Hours N/A', isOpen: false);
  }
  if (row['is_closed'] == true) {
    return (label: '${dayNames[today - 1]} · Closed today', isOpen: false);
  }
  final open = _fmt(row['open_time']);
  final close = _fmt(row['close_time']);
  return (label: '${dayNames[today - 1]} · $open – $close', isOpen: true);
}

String _fmt(dynamic raw) {
  if (raw == null) return '—';
  final s = raw.toString();
  if (s.length >= 5) return s.substring(0, 5);
  return s;
}

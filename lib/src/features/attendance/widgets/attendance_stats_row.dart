import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class AttendanceStatsRow extends StatelessWidget {
  const AttendanceStatsRow({
    super.key,
    required this.totalVisits,
    required this.visitsToday,
    required this.isCheckedIn,
  });

  final int totalVisits;
  final int visitsToday;
  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 96,
      child: Row(
        children: [
          Expanded(
            child: _Tile(
              icon: Icons.history_rounded,
              label: 'Total visits',
              value: '$totalVisits',
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tile(
              icon: Icons.today_rounded,
              label: 'Today',
              value: '$visitsToday',
              color: semantics.mutedText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tile(
              icon: isCheckedIn ? Icons.fact_check_rounded : Icons.radio_button_unchecked_rounded,
              label: 'Status',
              value: isCheckedIn ? 'In gym' : 'Out',
              color: isCheckedIn ? colorScheme.primary : semantics.mutedText,
              highlighted: isCheckedIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: color),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: highlighted ? color : null,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: semantics.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

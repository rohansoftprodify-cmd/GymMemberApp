import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class AttendanceHistorySummary extends StatelessWidget {
  const AttendanceHistorySummary({
    super.key,
    required this.totalVisits,
    required this.visitsThisMonth,
    required this.activeSessions,
  });

  final int totalVisits;
  final int visitsThisMonth;
  final int activeSessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              icon: Icons.history_rounded,
              label: 'Total visits',
              value: '$totalVisits',
              color: colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          Expanded(
            child: _SummaryTile(
              icon: Icons.calendar_month_rounded,
              label: 'This month',
              value: '$visitsThisMonth',
              color: colorScheme.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          Expanded(
            child: _SummaryTile(
              icon: Icons.fact_check_rounded,
              label: 'Active now',
              value: '$activeSessions',
              color: activeSessions > 0 ? semantics.accentLime : semantics.mutedText,
              highlighted: activeSessions > 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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

    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: highlighted ? semantics.accentLime : null,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: semantics.mutedText,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

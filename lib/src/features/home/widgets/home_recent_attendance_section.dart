import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_visit_card.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_visit_utils.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
class HomeRecentAttendanceSection extends StatelessWidget {
  const HomeRecentAttendanceSection({
    super.key,
    required this.records,
    this.onViewAll,
    this.title = 'Recent visits',
    this.showHeader = true,
    this.compact = true,
  });

  final List<Map<String, dynamic>> records;
  final VoidCallback? onViewAll;
  final String title;
  final bool showHeader;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Expanded(
                child: HomeSectionLabel(title: title, icon: Icons.history_rounded),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (records.isEmpty)
          _EmptyVisitsCard(semantics: semantics, colorScheme: colorScheme, theme: theme)
        else
          Column(
            children: [
              for (var i = 0; i < records.length; i++) ...[
                if (i > 0) SizedBox(height: compact ? 6 : 8),
                AttendanceVisitCard(
                  visit: AttendanceVisitInfo.fromMap(records[i]),
                  compact: compact,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _EmptyVisitsCard extends StatelessWidget {
  const _EmptyVisitsCard({
    required this.semantics,
    required this.colorScheme,
    required this.theme,
  });

  final AppSemanticColors semantics;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.history_rounded, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'No visits recorded yet',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Check in at your gym to start tracking visits.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
          ),
        ],
      ),
    );
  }
}

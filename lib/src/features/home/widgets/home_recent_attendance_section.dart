import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';
import 'package:gym_member_app/src/core/ui/section_header.dart';

class HomeRecentAttendanceSection extends StatelessWidget {
  const HomeRecentAttendanceSection({
    super.key,
    required this.records,
    required this.format,
    this.onViewAll,
    this.title = 'Recent visits',
    this.showHeader = true,
  });

  final List<Map<String, dynamic>> records;
  final DateFormat format;
  final VoidCallback? onViewAll;
  final String title;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          SectionHeader(
            title: title,
            actionLabel: onViewAll != null ? 'View all' : null,
            onAction: onViewAll,
          ),
          const SizedBox(height: 8),
        ],
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: semantics.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: semantics.mutedText, size: 22),
                const SizedBox(width: 12),
                Text(
                  'No visits recorded yet.',
                  style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: semantics.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < records.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
                  _AttendanceRow(
                    checkIn: DateTime.parse(records[i]['check_in_at'] as String).toLocal(),
                    checkOutRaw: records[i]['check_out_at'] as String?,
                    format: format,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.checkIn,
    required this.checkOutRaw,
    required this.format,
  });

  final DateTime checkIn;
  final String? checkOutRaw;
  final DateFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final isOpen = checkOutRaw == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isOpen ? colorScheme.primary : semantics.mutedText).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOpen ? Icons.login_rounded : Icons.check_circle_outline_rounded,
              size: 18,
              color: isOpen ? colorScheme.primary : semantics.mutedText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.format(checkIn),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isOpen
                      ? 'Still checked in'
                      : 'Out ${format.format(DateTime.parse(checkOutRaw!).toLocal())}',
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

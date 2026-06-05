import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_visit_utils.dart';
import 'package:intl/intl.dart';

class AttendanceVisitCard extends StatelessWidget {
  const AttendanceVisitCard({
    super.key,
    required this.visit,
    this.compact = false,
  });

  final AttendanceVisitInfo visit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final isActive = visit.isActive;
    final timeFormat = DateFormat('h:mm a');
    final duration = visit.duration;
    final inTime = timeFormat.format(visit.checkIn);
    final outLabel = isActive ? 'Active' : timeFormat.format(visit.checkOut!);

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isActive ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              color: isActive ? colorScheme.primary : semantics.mutedText.withValues(alpha: 0.35),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 8 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        isActive ? Icons.login_rounded : Icons.fitness_center_rounded,
                        size: 14,
                        color: isActive ? colorScheme.primary : semantics.mutedText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _dateLine(visit.checkIn),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 12 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(
                        label: isActive ? 'ACTIVE' : 'DONE',
                        background: isActive
                            ? semantics.accentLime
                            : colorScheme.primary.withValues(alpha: 0.1),
                        foreground: isActive ? semantics.onAccentLime : colorScheme.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: semantics.mutedText,
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 11 : 12,
                            ),
                            children: [
                              TextSpan(
                                text: inTime,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: '  →  '),
                              TextSpan(
                                text: outLabel,
                                style: TextStyle(
                                  color: isActive ? semantics.accentCoral : colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (duration != null) ...[
                        const SizedBox(width: 8),
                        _DurationChip(
                          label: formatVisitDuration(duration),
                          color: colorScheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  String _dateLine(DateTime date) {
    final day = visitDayLabel(date);
    final formatted = DateFormat('MMM d').format(date);
    if (day == 'Today' || day == 'Yesterday') return '$day · $formatted';
    return '$day, $formatted';
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

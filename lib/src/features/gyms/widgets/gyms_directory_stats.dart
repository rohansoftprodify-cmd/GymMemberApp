import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class GymsDirectoryStats extends StatelessWidget {
  const GymsDirectoryStats({
    super.key,
    required this.totalCount,
    required this.showingCount,
    required this.hasLinkedGym,
  });

  final int totalCount;
  final int showingCount;
  final bool hasLinkedGym;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 88,
      child: Row(
        children: [
          Expanded(
            child: _Tile(
              icon: Icons.fitness_center_rounded,
              label: 'Partner gyms',
              value: '$totalCount',
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tile(
              icon: Icons.filter_list_rounded,
              label: 'Showing',
              value: '$showingCount',
              color: semantics.mutedText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tile(
              icon: Icons.star_rounded,
              label: 'Your gym',
              value: hasLinkedGym ? 'Linked' : '—',
              color: hasLinkedGym ? colorScheme.primary : semantics.mutedText,
              highlighted: hasLinkedGym,
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
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';

/// Compact facility chips for gym list cards and hero sections.
class GymAmenitiesChips extends StatelessWidget {
  const GymAmenitiesChips({
    super.key,
    required this.amenities,
    this.maxVisible = 5,
    this.compact = false,
    this.inverted = false,
  });

  final List<GymAmenity> amenities;
  final int maxVisible;
  final bool compact;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;
    final visible = amenities.take(maxVisible).toList();
    final remaining = amenities.length - visible.length;

    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 6 : 8,
      children: [
        for (final amenity in visible)
          _AmenityChip(
            amenity: amenity,
            compact: compact,
            inverted: inverted,
            colorScheme: colorScheme,
            semantics: semantics,
            theme: theme,
          ),
        if (remaining > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: inverted
                  ? Colors.white.withValues(alpha: 0.12)
                  : semantics.cardBackground,
              borderRadius: BorderRadius.circular(compact ? 6 : 8),
              border: Border.all(
                color: inverted
                    ? Colors.white.withValues(alpha: 0.35)
                    : colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '+$remaining more',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: inverted ? Colors.white : semantics.mutedText,
                fontSize: compact ? 9 : 10,
              ),
            ),
          ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({
    required this.amenity,
    required this.compact,
    required this.inverted,
    required this.colorScheme,
    required this.semantics,
    required this.theme,
  });

  final GymAmenity amenity;
  final bool compact;
  final bool inverted;
  final ColorScheme colorScheme;
  final AppSemanticColors semantics;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final fg = inverted ? Colors.white : colorScheme.onSurface;
    final iconColor = inverted ? Colors.white : colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.14)
            : colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: inverted
              ? Colors.white.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            amenity.icon,
            size: compact ? 12 : 14,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            amenity.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: compact ? 9 : 10,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

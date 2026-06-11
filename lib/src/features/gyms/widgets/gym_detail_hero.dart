import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_amenities_chips.dart';

class GymDetailHero extends StatelessWidget {
  const GymDetailHero({
    super.key,
    required this.gymName,
    this.isLinkedGym = false,
    this.todaySlotLabel,
    this.isOpenToday = true,
    this.amenities = const [],
  });

  final String gymName;
  final bool isLinkedGym;
  final String? todaySlotLabel;
  final bool isOpenToday;
  final List<GymAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fitness_center_rounded, color: colorScheme.onPrimary, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              gymName,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (isLinkedGym)
                  _Chip(
                    label: 'YOUR GYM',
                    background: semantics.accentLime,
                    textColor: semantics.onAccentLime,
                  ),
                if (todaySlotLabel != null)
                  _Chip(
                    label: todaySlotLabel!,
                    background: Colors.white.withValues(alpha: isOpenToday ? 0.22 : 0.15),
                    textColor: colorScheme.onPrimary,
                  ),
              ],
            ),
            if (amenities.isNotEmpty) ...[
              const SizedBox(height: 14),
              GymAmenitiesChips(
                amenities: amenities,
                maxVisible: 8,
                compact: true,
                inverted: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

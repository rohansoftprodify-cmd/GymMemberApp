import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/diet/models/member_diet_models.dart';

class DietMacroRow extends StatelessWidget {
  const DietMacroRow({
    super.key,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.hydrationLiters,
  });

  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? hydrationLiters;

  @override
  Widget build(BuildContext context) {
    final chips = <_MacroChipData>[];
    if (calories != null) {
      chips.add(_MacroChipData(Icons.local_fire_department_outlined, '$calories kcal', null));
    }
    if (proteinG != null) {
      chips.add(_MacroChipData(Icons.egg_outlined, '${proteinG!.toStringAsFixed(0)}g protein', null));
    }
    if (carbsG != null) {
      chips.add(_MacroChipData(Icons.grain_rounded, '${carbsG!.toStringAsFixed(0)}g carbs', null));
    }
    if (fatG != null) {
      chips.add(_MacroChipData(Icons.water_drop_outlined, '${fatG!.toStringAsFixed(0)}g fat', null));
    }
    if (hydrationLiters != null) {
      chips.add(_MacroChipData(Icons.water_outlined, '${hydrationLiters}L water', null));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in chips) _MacroChip(data: chip),
      ],
    );
  }
}

class _MacroChipData {
  const _MacroChipData(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color? color;
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.data});

  final _MacroChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = data.color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class DietMealSection extends StatelessWidget {
  const DietMealSection({super.key, required this.meal});

  final MemberDietMeal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restaurant_rounded, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.mealLabel,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (meal.mealTime != null && meal.mealTime!.isNotEmpty)
                        Text(
                          meal.mealTime!,
                          style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                        ),
                    ],
                  ),
                ),
                if (meal.totalCalories > 0)
                  Text(
                    '${meal.totalCalories} kcal',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ),
          if (meal.guidance != null && meal.guidance!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                meal.guidance!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: semantics.mutedText,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (meal.foods.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                'No food items listed.',
                style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
              ),
            )
          else
            for (var i = 0; i < meal.foods.length; i++) ...[
              Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              _FoodRow(food: meal.foods[i]),
            ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.food});

  final MemberDietFoodItem food;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (food.portion != null && food.portion!.isNotEmpty)
                  Text(
                    food.portion!,
                    style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                  ),
                if (food.notes != null && food.notes!.isNotEmpty)
                  Text(
                    food.notes!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: semantics.mutedText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (food.calories != null)
            Text(
              '${food.calories} kcal',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

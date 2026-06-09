import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/diet/models/member_diet_models.dart';

class DietPlanCard extends StatelessWidget {
  const DietPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  final MemberDietPlanSummary plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final goal = plan.goalInfo;

    return Material(
      color: semantics.cardBackground,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 88,
                  height: 96,
                  child: plan.imageUrl != null
                      ? Image.network(plan.imageUrl!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(
                            goal?.icon ?? Icons.restaurant_menu_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.name,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: semantics.mutedText, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.categoryName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (plan.targetCalories != null) '${plan.targetCalories} kcal/day',
                          '${plan.durationDays} days',
                          '${plan.mealCount} meals',
                        ].join(' · '),
                        style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                      ),
                      if (plan.description != null && plan.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          plan.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: semantics.mutedText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

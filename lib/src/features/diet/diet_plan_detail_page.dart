import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/diet/member_diet_plans_provider.dart';
import 'package:gym_member_app/src/features/diet/widgets/diet_macro_row.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class DietPlanDetailPage extends ConsumerWidget {
  const DietPlanDetailPage({super.key, required this.dietPlanId});

  final String dietPlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(myDietPlanDetailProvider(dietPlanId));
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Diet plan'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(myDietPlanDetailProvider(dietPlanId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const ShimmerDetailPage(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(err.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('Diet plan not found or not available.'));
          }

          final goal = plan.goalInfo;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: plan.imageUrl != null
                      ? Image.network(plan.imageUrl!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(
                            goal?.icon ?? Icons.restaurant_menu_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                plan.name,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.categoryName} · ${plan.durationDays} day plan',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (plan.description != null && plan.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  plan.description!,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ],
              const SizedBox(height: 14),
              DietMacroRow(
                calories: plan.targetCalories,
                proteinG: plan.targetProteinG,
                carbsG: plan.targetCarbsG,
                fatG: plan.targetFatG,
                hydrationLiters: plan.hydrationLiters,
              ),
              if (plan.nutritionTips != null && plan.nutritionTips!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Nutrition tips',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan.nutritionTips!,
                        style: theme.textTheme.labelSmall?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              HomeSectionLabel(
                title: 'Daily meals (${plan.meals.length})',
                icon: Icons.schedule_rounded,
              ),
              if (plan.meals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Meals have not been added to this plan yet.',
                    style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                  ),
                )
              else
                ...plan.meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DietMealSection(meal: meal),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

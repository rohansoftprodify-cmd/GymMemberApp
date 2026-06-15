import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/workout/member_workout_plans_provider.dart';
import 'package:gym_member_app/src/features/workout/models/member_workout_models.dart';

class MemberWorkoutPlansPage extends ConsumerWidget {
  const MemberWorkoutPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(myWorkoutPlansProvider);
    final theme = Theme.of(context);
    final semantics = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My workout plans'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(myWorkoutPlansProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const ShimmerPlanList(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center_rounded, size: 48, color: semantics.mutedText),
                    const SizedBox(height: 12),
                    Text(
                      'No workout plans yet',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your gym trainer can assign a personalized plan based on your goals and equipment.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedText),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const HomeSectionLabel(title: 'Your plans', icon: Icons.sports_gymnastics_rounded),
              ...plans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WorkoutPlanCard(
                    plan: plan,
                    onTap: () => context.push('/profile/workout/${plan.id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan, required this.onTap});

  final MemberWorkoutPlanSummary plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = plan.goalInfo;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(goal?.icon ?? Icons.fitness_center, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      '${plan.sessionsPerWeek} days/wk · ${plan.experienceLevel} · ${plan.sessionCount} sessions',
                      style: theme.textTheme.labelSmall,
                    ),
                    if (plan.equipmentHint != null)
                      Text(plan.equipmentHint!, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

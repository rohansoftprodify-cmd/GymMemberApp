import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/workout/member_workout_plans_provider.dart';
import 'package:gym_member_app/src/features/workout/models/member_workout_models.dart';

class WorkoutPlanDetailPage extends ConsumerStatefulWidget {
  const WorkoutPlanDetailPage({super.key, required this.workoutPlanId});

  final String workoutPlanId;

  @override
  ConsumerState<WorkoutPlanDetailPage> createState() => _WorkoutPlanDetailPageState();
}

class _WorkoutPlanDetailPageState extends ConsumerState<WorkoutPlanDetailPage> {
  bool _adjusting = false;

  Future<void> _logSession(MemberWorkoutSession session, {bool skipped = false}) async {
    try {
      await ref.read(memberRepositoryProvider).logMyWorkoutSession(
            workoutPlanId: widget.workoutPlanId,
            workoutSessionId: session.id,
            skipped: skipped,
            notes: skipped ? 'Skipped session' : 'Completed',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(skipped ? 'Session marked skipped' : '${session.dayLabel} logged')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _adjustPlan(MemberWorkoutPlanDetail plan) async {
    final gymId = ref.read(memberContextProvider).valueOrNull?.gymId;
    if (gymId == null) return;

    setState(() => _adjusting = true);
    try {
      final result = await ref.read(memberRepositoryProvider).adjustMyWorkoutPlan(
            gymId: gymId,
            workoutPlanId: widget.workoutPlanId,
            goalKey: plan.goalKey,
          );
      if (!mounted) return;
      final rawPlan = result['plan'];
      if (rawPlan is Map && rawPlan['sessions'] is List) {
        await ref.read(memberRepositoryProvider).applyWorkoutPlanSessions(
              workoutPlanId: widget.workoutPlanId,
              sessions: rawPlan['sessions'] as List,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan updated based on your workout progress')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not apply adjustment')),
        );
      }
      ref.invalidate(myWorkoutPlanDetailProvider(widget.workoutPlanId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _adjusting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(myWorkoutPlanDetailProvider(widget.workoutPlanId));
    final theme = Theme.of(context);
    final semantics = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout plan'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(myWorkoutPlanDetailProvider(widget.workoutPlanId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('Workout plan not found or not available.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                plan.name,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.categoryName} · ${plan.sessionsPerWeek} days/wk · ${plan.durationWeeks} weeks',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (plan.equipmentHint != null) ...[
                const SizedBox(height: 4),
                Text('Equipment: ${plan.equipmentHint}', style: theme.textTheme.labelSmall),
              ],
              if (plan.description != null && plan.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(plan.description!, style: theme.textTheme.bodySmall?.copyWith(height: 1.45)),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _adjusting ? null : () => _adjustPlan(plan),
                icon: _adjusting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_adjusting ? 'Adjusting…' : 'Adjust plan from my progress'),
              ),
              const SizedBox(height: 16),
              HomeSectionLabel(
                title: 'Sessions (${plan.sessions.length})',
                icon: Icons.calendar_today_rounded,
              ),
              ...plan.sessions.map(
                (session) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.dayLabel,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (session.guidance != null) ...[
                          const SizedBox(height: 4),
                          Text(session.guidance!, style: theme.textTheme.labelSmall),
                        ],
                        const SizedBox(height: 8),
                        ...session.exercises.map(
                          (ex) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ex.exerciseName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  '${ex.sets}×${ex.reps}',
                                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: session.id.isEmpty ? null : () => _logSession(session),
                                child: const Text('Mark complete'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: session.id.isEmpty ? null : () => _logSession(session, skipped: true),
                              child: const Text('Skip'),
                            ),
                          ],
                        ),
                      ],
                    ),
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

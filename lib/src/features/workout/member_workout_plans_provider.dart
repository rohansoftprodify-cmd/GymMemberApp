import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/features/workout/models/member_workout_models.dart';

final myWorkoutPlansProvider = FutureProvider<List<MemberWorkoutPlanSummary>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  final rows = await repo.myWorkoutPlans();
  return rows.map(MemberWorkoutPlanSummary.fromMap).toList();
});

final myWorkoutPlanDetailProvider = FutureProvider.family<MemberWorkoutPlanDetail?, String>(
  (ref, workoutPlanId) async {
    final repo = ref.watch(memberRepositoryProvider);
    final row = await repo.myWorkoutPlanDetail(workoutPlanId);
    if (row == null) return null;
    return MemberWorkoutPlanDetail.fromMap(row);
  },
);

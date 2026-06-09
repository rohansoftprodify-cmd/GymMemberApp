import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/features/diet/models/member_diet_models.dart';

final myDietPlansProvider = FutureProvider<List<MemberDietPlanSummary>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  final rows = await repo.myDietPlans();
  return rows
      .map((r) => MemberDietPlanSummary.fromMap(r, imageUrlResolver: repo.dietImageUrl))
      .toList();
});

final myDietPlanDetailProvider = FutureProvider.family<MemberDietPlanDetail?, String>(
  (ref, dietPlanId) async {
    final repo = ref.watch(memberRepositoryProvider);
    final row = await repo.myDietPlanDetail(dietPlanId);
    if (row == null) return null;
    return MemberDietPlanDetail.fromMap(row, imageUrlResolver: repo.dietImageUrl);
  },
);

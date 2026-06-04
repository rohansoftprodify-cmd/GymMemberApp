import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';

final memberProfileProvider = FutureProvider<MemberProfile?>((ref) async {
  return ref.watch(memberRepositoryProvider).myProfile();
});

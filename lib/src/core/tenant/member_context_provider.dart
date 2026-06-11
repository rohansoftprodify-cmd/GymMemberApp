import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/supabase/supabase_client_provider.dart';
import 'package:gym_member_app/src/core/utils/json_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberContext {
  const MemberContext({
    required this.gymId,
    required this.memberId,
    required this.gymName,
    required this.fullName,
    this.email,
    this.phone,
    this.memberStatus = 'active',
    this.subscription,
  });

  final String gymId;
  final String memberId;
  final String gymName;
  final String fullName;
  final String? email;
  final String? phone;
  final String memberStatus;
  final MemberSubscriptionContext? subscription;

  factory MemberContext.fromMap(Map<String, dynamic> map) {
    final gymId = map['gym_id']?.toString();
    final memberId = map['member_id']?.toString();
    if (gymId == null || gymId.isEmpty || memberId == null || memberId.isEmpty) {
      throw const FormatException('Invalid member context payload.');
    }

    final subRaw = map['subscription'];
    final sub = subRaw is Map
        ? subRaw.map((k, v) => MapEntry(k.toString(), v))
        : null;

    return MemberContext(
      gymId: gymId,
      memberId: memberId,
      gymName: map['gym_name'] as String? ?? 'Gym',
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      memberStatus: map['member_status'] as String? ?? 'active',
      subscription: sub == null ? null : MemberSubscriptionContext.fromMap(sub),
    );
  }
}

class MemberSubscriptionContext {
  const MemberSubscriptionContext({
    required this.id,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    required this.amountPaid,
    required this.planPrice,
  });

  final String id;
  final String planName;
  final String startDate;
  final String endDate;
  final String paymentStatus;
  final num amountPaid;
  final num planPrice;

  factory MemberSubscriptionContext.fromMap(Map<String, dynamic> map) {
    return MemberSubscriptionContext(
      id: map['id']?.toString() ?? '',
      planName: map['plan_name'] as String? ?? '-',
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      paymentStatus: map['payment_status'] as String? ?? 'due',
      amountPaid: map['amount_paid'] as num? ?? 0,
      planPrice: map['plan_price'] as num? ?? 0,
    );
  }
}

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final memberContextProvider = FutureProvider<MemberContext?>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseClientProvider);
  if (client.auth.currentUser == null) return null;

  final response = await client.rpc('get_my_member_context');
  if (response == null) return null;

  try {
    return MemberContext.fromMap(asStringKeyMap(response));
  } catch (_) {
    return null;
  }
});

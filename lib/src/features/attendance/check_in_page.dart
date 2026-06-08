import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/features/attendance/check_in_flow.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles gymmember://checkin?gymId=... deep links.
class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _process());
    }
  }

  Future<void> _process() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }

    final member = await ref.read(memberContextProvider.future);
    if (!mounted) return;

    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This account is not linked to a gym membership.')),
      );
      context.go('/explore');
      return;
    }

    if (widget.gymId != member.gymId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This check-in link is for another gym.')),
      );
      context.go('/');
      return;
    }

    final repo = ref.read(memberRepositoryProvider);
    final open = await repo.openAttendance(member.gymId, member.memberId);
    final gym = await repo.gymInfo(member.gymId);

    if (!mounted) return;

    final lat = (gym?['latitude'] as num?)?.toDouble();
    final lng = (gym?['longitude'] as num?)?.toDouble();
    final radius = (gym?['check_in_radius_meters'] as num?)?.toInt() ?? 150;

    final result = await runCheckInFromGymId(
      context: context,
      ref: ref,
      gymId: widget.gymId,
      member: member,
      hasOpenSession: open != null,
      gymLatitude: lat,
      gymLongitude: lng,
      gymRadiusMeters: radius,
    );

    if (!mounted) return;

    if (result.message != null && result.message != 'Cancelled.') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

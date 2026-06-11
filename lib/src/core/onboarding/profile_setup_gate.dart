import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/onboarding/profile_setup_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupGate {
  ProfileSetupGate._();

  static Future<bool> shouldShow({MemberRepository? memberRepository}) async {
    final session = Supabase.instance.client.auth.currentSession;
    // Profile setup runs only after sign-in, when a gym membership is linked.
    if (session == null || memberRepository == null) return false;

    if (await ProfileSetupPrefs.isCompleted()) return false;

    try {
      final profile = await memberRepository.myProfile();
      if (profile?.profileSetupCompleted == true) {
        await ProfileSetupPrefs.markCompleted();
        return false;
      }
    } catch (_) {
      // Fall back to local setup if profile fetch fails.
    }

    return true;
  }
}

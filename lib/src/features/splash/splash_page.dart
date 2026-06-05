import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/onboarding/onboarding_prefs.dart';
import 'package:gym_member_app/src/core/onboarding/profile_setup_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final onboardingDone = await OnboardingPrefs.isCompleted();
    if (!mounted) return;

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    final client = Supabase.instance.client;
    final showProfileSetup = await ProfileSetupGate.shouldShow(
      memberRepository: MemberRepository(client),
    );
    if (!mounted) return;

    if (showProfileSetup) {
      context.go('/profile-setup');
      return;
    }

    if (client.auth.currentSession != null) {
      context.go('/');
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center_rounded, size: 56, color: colorScheme.onPrimary),
              const SizedBox(height: 12),
              Text(
                'GYM MEMBER',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

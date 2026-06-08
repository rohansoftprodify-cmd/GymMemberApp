import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/features/attendance/check_in_page.dart';
import 'package:gym_member_app/src/features/auth/login_page.dart';
import 'package:gym_member_app/src/features/explore/explore_page.dart';
import 'package:gym_member_app/src/features/gyms/gym_detail_page.dart';
import 'package:gym_member_app/src/features/profile/edit_profile_page.dart';
import 'package:gym_member_app/src/features/profile/member_profile_page.dart';
import 'package:gym_member_app/src/features/shell/member_shell_page.dart';
import 'package:gym_member_app/src/features/onboarding/onboarding_page.dart';
import 'package:gym_member_app/src/features/profile_setup/profile_setup_page.dart';
import 'package:gym_member_app/src/features/splash/splash_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, state) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, state) => const OnboardingPage()),
    GoRoute(path: '/profile-setup', builder: (_, state) => const ProfileSetupPage()),
    GoRoute(path: '/explore', builder: (_, state) => const ExplorePage()),
    GoRoute(path: '/login', builder: (_, state) => const LoginPage()),
    GoRoute(
      path: '/checkin',
      builder: (_, state) {
        final gymId = state.uri.queryParameters['gymId'];
        if (gymId == null || gymId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Missing gym id')));
        }
        return CheckInPage(gymId: gymId);
      },
    ),
    GoRoute(
      path: '/gym/:gymId',
      builder: (_, state) {
        final gymId = state.pathParameters['gymId']!;
        return GymDetailPage(gymId: gymId);
      },
    ),
    GoRoute(path: '/profile', builder: (_, state) => const MemberProfilePage()),
    GoRoute(path: '/profile/edit', builder: (_, state) => const EditProfilePage()),
    GoRoute(path: '/', builder: (_, state) => const MemberShellPage()),
  ],
);

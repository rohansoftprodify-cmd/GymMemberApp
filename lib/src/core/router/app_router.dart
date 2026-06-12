import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/features/attendance/check_in_page.dart';
import 'package:gym_member_app/src/features/auth/login_page.dart';
import 'package:gym_member_app/src/features/explore/explore_page.dart';
import 'package:gym_member_app/src/features/gyms/gym_detail_page.dart';
import 'package:gym_member_app/src/features/diet/diet_plan_detail_page.dart';
import 'package:gym_member_app/src/features/diet/member_diet_plans_page.dart';
import 'package:gym_member_app/src/features/workout/member_workout_plans_page.dart';
import 'package:gym_member_app/src/features/workout/workout_plan_detail_page.dart';
import 'package:gym_member_app/src/features/profile/edit_profile_page.dart';
import 'package:gym_member_app/src/features/profile/member_profile_page.dart';
import 'package:gym_member_app/src/features/profile/profile_gym_details_page.dart';
import 'package:gym_member_app/src/features/profile/profile_personal_details_page.dart';
import 'package:gym_member_app/src/features/shell/member_shell_page.dart';
import 'package:gym_member_app/src/features/onboarding/onboarding_page.dart';
import 'package:gym_member_app/src/features/profile_setup/profile_setup_page.dart';
import 'package:gym_member_app/src/features/splash/splash_page.dart';
import 'package:gym_member_app/src/features/fitness_chat/fitness_chat_page.dart';
import 'package:gym_member_app/src/features/support/support_bot_page.dart';

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
    GoRoute(path: '/support', builder: (_, state) => const SupportBotPage()),
    GoRoute(path: '/fitness-chat', builder: (_, state) => const FitnessChatPage()),
    GoRoute(path: '/profile', builder: (_, state) => const MemberProfilePage()),
    GoRoute(path: '/profile/edit', builder: (_, state) => const EditProfilePage()),
    GoRoute(path: '/profile/personal', builder: (_, state) => const ProfilePersonalDetailsPage()),
    GoRoute(path: '/profile/gym', builder: (_, state) => const ProfileGymDetailsPage()),
    GoRoute(
      path: '/profile/diet',
      builder: (_, state) => const MemberDietPlansPage(),
      routes: [
        GoRoute(
          path: ':dietPlanId',
          builder: (_, state) {
            final dietPlanId = state.pathParameters['dietPlanId']!;
            return DietPlanDetailPage(dietPlanId: dietPlanId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/profile/workout',
      builder: (_, state) => const MemberWorkoutPlansPage(),
      routes: [
        GoRoute(
          path: ':workoutPlanId',
          builder: (_, state) {
            final workoutPlanId = state.pathParameters['workoutPlanId']!;
            return WorkoutPlanDetailPage(workoutPlanId: workoutPlanId);
          },
        ),
      ],
    ),
    GoRoute(path: '/', builder: (_, state) => const MemberShellPage()),
  ],
);

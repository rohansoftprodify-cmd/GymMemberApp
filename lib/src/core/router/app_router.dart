import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/features/auth/login_page.dart';
import 'package:gym_member_app/src/features/explore/explore_page.dart';
import 'package:gym_member_app/src/features/gyms/gym_detail_page.dart';
import 'package:gym_member_app/src/features/profile/member_profile_page.dart';
import 'package:gym_member_app/src/features/shell/member_shell_page.dart';
import 'package:gym_member_app/src/features/splash/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, state) => const SplashPage()),
    GoRoute(path: '/explore', builder: (_, state) => const ExplorePage()),
    GoRoute(path: '/login', builder: (_, state) => const LoginPage()),
    GoRoute(
      path: '/gym/:gymId',
      builder: (_, state) {
        final gymId = state.pathParameters['gymId']!;
        return GymDetailPage(gymId: gymId);
      },
    ),
    GoRoute(path: '/profile', builder: (_, state) => const MemberProfilePage()),
    GoRoute(path: '/', builder: (_, state) => const MemberShellPage()),
  ],
);

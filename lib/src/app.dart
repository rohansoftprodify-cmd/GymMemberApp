import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/auth/single_session_guard.dart';
import 'package:gym_member_app/src/core/router/app_router.dart';
import 'package:gym_member_app/src/core/theme/app_theme.dart';
import 'package:gym_member_app/src/core/theme/theme_mode_provider.dart';

class GymMemberApp extends ConsumerWidget {
  const GymMemberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gym Member',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        return SingleSessionGuard(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

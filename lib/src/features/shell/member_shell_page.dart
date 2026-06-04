import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/member_attendance_tab.dart';
import 'package:gym_member_app/src/features/buy/member_buy_tab.dart';
import 'package:gym_member_app/src/features/gyms/member_gyms_tab.dart';
import 'package:gym_member_app/src/features/home/member_home_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberShellPage extends ConsumerStatefulWidget {
  const MemberShellPage({super.key});

  @override
  ConsumerState<MemberShellPage> createState() => _MemberShellPageState();
}

class _MemberShellPageState extends ConsumerState<MemberShellPage> {
  int _index = 0;

  static const _navItems = <({String label, IconData icon, IconData selectedIcon})>[
    (label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
    (label: 'Attendance', icon: Icons.fact_check_outlined, selectedIcon: Icons.fact_check_rounded),
    (label: 'Gyms', icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center_rounded),
    (label: 'Buy', icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;
    final isDark = theme.brightness == Brightness.dark;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/explore'));
      return const SizedBox.shrink();
    }

    final memberAsync = ref.watch(memberContextProvider);
    return memberAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text(err.toString()))),
      data: (member) {
        if (member == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gym Member')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This account is not linked to a gym membership.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) context.go('/explore');
                      },
                      child: const Text('Back to login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final pages = [
          MemberHomeTab(
            member: member,
            onGoToAttendance: () => setState(() => _index = 1),
          ),
          MemberAttendanceTab(member: member),
          MemberGymsTab(member: member),
          MemberBuyTab(member: member),
        ];

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            toolbarHeight: 64,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              _index == 2 ? 'All gyms' : member.gymName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'My profile',
                onPressed: () => context.push('/profile'),
                icon: Icon(Icons.person_rounded, color: colorScheme.primary, size: 22),
              ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text('Sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout != true) return;
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) context.go('/explore');
                },
                icon: Icon(Icons.logout_rounded, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: pages[_index],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: semantics.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: isDark
                    ? Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4))
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: NavigationBar(
                  height: 60,
                  selectedIndex: _index,
                  elevation: 0,
                  backgroundColor: semantics.cardBackground,
                  indicatorColor: colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                  surfaceTintColor: Colors.transparent,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    for (final item in _navItems)
                      NavigationDestination(
                        icon: Icon(item.icon, size: 22),
                        selectedIcon: Icon(item.selectedIcon, size: 22),
                        label: item.label,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/auth/single_session_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:gym_member_app/src/features/home/widgets/home_plan_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/profile/profile_display_utils.dart';
import 'package:gym_member_app/src/features/profile/widgets/delete_account_dialog.dart';
import 'package:gym_member_app/src/features/profile/widgets/delete_account_tile.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_actions_card.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_hero_header.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_stats_row.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_summary_card.dart';
import 'package:intl/intl.dart';

const _profileSectionGap = 14.0;

class MemberProfilePage extends ConsumerWidget {
  const MemberProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My profile'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(memberProfileProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ShimmerProfilePage(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(err.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not available.'));
          }
          return _ProfileBody(
            profile: profile,
            onRefresh: () async => ref.invalidate(memberProfileProvider),
            onLogout: () => ref.read(singleSessionServiceProvider).signOutLocally(),
          );
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.profile,
    required this.onRefresh,
    required this.onLogout,
  });

  final MemberProfile profile;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final dateFormat = DateFormat.yMMMd();
    final sub = profile.subscription;

    final subscriptionContext = sub == null
        ? null
        : MemberSubscriptionContext(
            id: sub.id,
            planName: sub.planName,
            startDate: sub.startDate,
            endDate: sub.endDate,
            paymentStatus: sub.paymentStatus,
            amountPaid: sub.amountPaid,
            planPrice: sub.planPrice,
          );

    final personalSubtitle = profile.email ?? profile.phone ?? profile.authEmail ?? 'View contact & fitness info';
    final personalPreviews = <String>[
      if (ProfileDisplayUtils.hasText(profile.phone)) profile.phone!,
      if (profile.fitnessGoal != null)
        ProfileDisplayUtils.fitnessGoalLabel(profile.fitnessGoal!),
    ];

    final gymPreviews = <String>[
      if (ProfileDisplayUtils.hasText(profile.gymAddress))
        ProfileDisplayUtils.truncate(profile.gymAddress, maxLength: 42)!,
      if (ProfileDisplayUtils.hasText(profile.gymPhone)) profile.gymPhone!,
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          ProfileHeroHeader(profile: profile),
          const SizedBox(height: 12),
          ProfileStatsRow(profile: profile),
          if (sub != null && subscriptionContext != null) ...[
            const SizedBox(height: _profileSectionGap),
            const HomeSectionLabel(title: 'Subscription', icon: Icons.card_membership_rounded),
            HomePlanCard(subscription: subscriptionContext),
          ],
          const SizedBox(height: _profileSectionGap),
          const HomeSectionLabel(title: 'Details', icon: Icons.folder_open_outlined),
          ProfileSummaryCard(
            icon: Icons.person_outline_rounded,
            title: 'Personal details',
            subtitle: personalSubtitle,
            previewLines: personalPreviews,
            onTap: () => context.push('/profile/personal'),
          ),
          const SizedBox(height: 10),
          ProfileSummaryCard(
            icon: Icons.fitness_center_outlined,
            title: profile.gymName,
            subtitle: 'Member since ${ProfileDisplayUtils.formatDate(profile.joinedOn, dateFormat)}',
            previewLines: gymPreviews,
            onTap: () => context.push('/profile/gym'),
          ),
          const SizedBox(height: _profileSectionGap),
          const HomeSectionLabel(title: 'Account', icon: Icons.manage_accounts_outlined),
          DeleteAccountTile(
            onTap: () => showDeleteAccountDialog(
              context,
              ref,
              app: 'member',
              exitRoute: '/explore',
            ),
          ),
          const SizedBox(height: _profileSectionGap),
          const HomeSectionLabel(title: 'Quick actions', icon: Icons.bolt_rounded),
          ProfileActionsCard(
            actions: [
              ProfileActionItem(
                icon: Icons.edit_rounded,
                label: 'Edit profile',
                onTap: () => context.push('/profile/edit'),
              ),
              ProfileActionItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Diet plans',
                onTap: () => context.push('/profile/diet'),
              ),
              ProfileActionItem(
                icon: Icons.sports_gymnastics_rounded,
                label: 'Workout plans',
                onTap: () => context.push('/profile/workout'),
              ),
              ProfileActionItem(
                icon: Icons.psychology_rounded,
                label: 'AI Fitness Coach',
                onTap: () => context.push('/fitness-chat'),
              ),
              ProfileActionItem(
                icon: Icons.support_agent_outlined,
                label: 'Gym support',
                onTap: () => context.push('/support'),
              ),
              ProfileActionItem(
                icon: Icons.history_rounded,
                label: 'Attendance history',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MyAttendancePage(
                      gymId: profile.gymId,
                      memberId: profile.memberId,
                    ),
                  ),
                ),
              ),
              ProfileActionItem(
                icon: Icons.home_outlined,
                label: 'Back to home',
                onTap: () => context.pop(),
              ),
              ProfileActionItem(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                destructive: true,
                onTap: () => _logout(context, onLogout),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Profile synced from ${profile.gymName}',
              style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, Future<void> Function() onLogout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will return to the gym directory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await onLogout();
    if (context.mounted) context.go('/explore');
  }
}

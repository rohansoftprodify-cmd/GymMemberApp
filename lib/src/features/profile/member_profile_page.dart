import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/auth/single_session_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/utils/height_units.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/my_attendance_page.dart';
import 'package:gym_member_app/src/features/home/widgets/home_plan_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_actions_card.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_hero_header.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_info_section.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_stats_row.dart';
import 'package:intl/intl.dart';

const _profileSectionGap = 18.0;

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
        loading: () => const Center(child: CircularProgressIndicator()),
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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.onRefresh,
    required this.onLogout,
  });

  final MemberProfile profile;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          ProfileHeroHeader(profile: profile),
          const SizedBox(height: _profileSectionGap),
          ProfileStatsRow(profile: profile),
          if (sub != null && subscriptionContext != null) ...[
            const SizedBox(height: _profileSectionGap),
            const HomeSectionLabel(title: 'Subscription', icon: Icons.card_membership_rounded),
            HomePlanCard(subscription: subscriptionContext),
          ],
          const SizedBox(height: _profileSectionGap),
          const HomeSectionLabel(title: 'Personal', icon: Icons.person_outline_rounded),
          ProfileInfoSection(
            title: 'Contact & identity',
            icon: Icons.contact_mail_outlined,
            rows: [
              ProfileInfoRowData(
                label: 'Email',
                value: profile.email ?? profile.authEmail ?? '—',
              ),
              if (_hasText(profile.authEmail) &&
                  _hasText(profile.email) &&
                  profile.authEmail != profile.email)
                ProfileInfoRowData(label: 'Login', value: profile.authEmail!),
              ProfileInfoRowData(label: 'Phone', value: profile.phone ?? '—'),
              if (_hasText(profile.address))
                ProfileInfoRowData(label: 'Address', value: profile.address!),
              ProfileInfoRowData(
                label: 'Birthday',
                value: _formatDate(profile.dateOfBirth, dateFormat),
              ),
              ProfileInfoRowData(
                label: 'Emergency',
                value: profile.emergencyContact ?? '—',
              ),
              if (profile.weightKg != null)
                ProfileInfoRowData(
                  label: 'Weight',
                  value: '${profile.weightKg!.toStringAsFixed(1)} kg',
                ),
              if (profile.heightCm != null)
                ProfileInfoRowData(
                  label: 'Height',
                  value: HeightUnits.formatDisplay(profile.heightCm!),
                ),
              if (profile.age != null)
                ProfileInfoRowData(label: 'Age', value: '${profile.age}'),
              if (_hasText(profile.gender))
                ProfileInfoRowData(
                  label: 'Gender',
                  value: _genderLabel(profile.gender!),
                ),
              if (profile.bmi != null)
                ProfileInfoRowData(
                  label: 'BMI',
                  value: profile.bmi!.toStringAsFixed(1),
                ),
              if (_hasText(profile.fitnessGoal))
                ProfileInfoRowData(
                  label: 'Goal',
                  value: _fitnessGoalLabel(profile.fitnessGoal!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const HomeSectionLabel(title: 'Gym', icon: Icons.fitness_center_outlined),
          ProfileInfoSection(
            title: profile.gymName,
            icon: Icons.storefront_outlined,
            trailingLabel: 'View',
            onTap: () => context.push('/gym/${profile.gymId}'),
            rows: [
              if (_hasText(profile.gymAddress))
                ProfileInfoRowData(label: 'Address', value: profile.gymAddress!),
              if (_hasText(profile.gymPhone))
                ProfileInfoRowData(label: 'Phone', value: profile.gymPhone!),
              ProfileInfoRowData(
                label: 'Member since',
                value: _formatDate(profile.joinedOn, dateFormat),
              ),
              ProfileInfoRowData(
                label: 'Member ID',
                value: _shortId(profile.memberId),
                mono: true,
              ),
            ],
          ),
          if (_hasText(profile.notes)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Notes from gym',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ],
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
                icon: Icons.fitness_center_outlined,
                label: 'View my gym',
                onTap: () => context.push('/gym/${profile.gymId}'),
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

  static bool _hasText(String? v) => v != null && v.trim().isNotEmpty;

  static String _formatDate(String? raw, DateFormat format) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return format.format(parsed);
  }

  static String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 4)}';
  }

  static String _fitnessGoalLabel(String key) {
    return switch (key) {
      'weight_loss' => 'Lose weight',
      'muscle_gain' => 'Build muscle',
      'healthy' => 'Stay healthy',
      _ => key,
    };
  }

  static String _genderLabel(String key) {
    return switch (key) {
      'male' => 'Male',
      'female' => 'Female',
      'other' => 'Other',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => key,
    };
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

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
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.onRefresh});

  final MemberProfile profile;
  final Future<void> Function() onRefresh;

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
              ProfileInfoRowData(
                label: 'Birthday',
                value: _formatDate(profile.dateOfBirth, dateFormat),
              ),
              ProfileInfoRowData(
                label: 'Emergency',
                value: profile.emergencyContact ?? '—',
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
                onTap: () => _logout(context),
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

  Future<void> _logout(BuildContext context) async {
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
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/explore');
  }
}

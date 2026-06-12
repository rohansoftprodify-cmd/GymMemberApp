import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/core/utils/height_units.dart';
import 'package:gym_member_app/src/features/profile/profile_display_utils.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_detail_field.dart';
import 'package:intl/intl.dart';

class ProfilePersonalDetailsPage extends ConsumerWidget {
  const ProfilePersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal details')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not available.'));
          }
          return _PersonalDetailsBody(profile: profile);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/edit'),
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text('Edit'),
      ),
    );
  }
}

class _PersonalDetailsBody extends StatelessWidget {
  const _PersonalDetailsBody({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat.yMMMd();
    final initial = profile.fullName.trim().isEmpty
        ? '?'
        : profile.fullName.trim()[0].toUpperCase();

    final metrics = <({String label, String value, IconData icon})>[
      if (profile.weightKg != null)
        (label: 'Weight', value: '${profile.weightKg!.toStringAsFixed(1)} kg', icon: Icons.monitor_weight_outlined),
      if (profile.heightCm != null)
        (label: 'Height', value: HeightUnits.formatDisplay(profile.heightCm!), icon: Icons.height_rounded),
      if (profile.age != null)
        (label: 'Age', value: '${profile.age}', icon: Icons.cake_outlined),
      if (profile.bmi != null)
        (label: 'BMI', value: profile.bmi!.toStringAsFixed(1), icon: Icons.favorite_outline_rounded),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email ?? profile.authEmail ?? 'No email on file',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.88),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ProfileDisplayUtils.hasText(profile.fitnessGoal)) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: semantics.accentLime.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ProfileDisplayUtils.fitnessGoalLabel(profile.fitnessGoal!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: semantics.onAccentLime,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (metrics.isNotEmpty) ...[
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: metrics.length >= 4 ? 4 : metrics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: [
              for (final metric in metrics)
                ProfileMetricChip(
                  label: metric.label,
                  value: metric.value,
                  icon: metric.icon,
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        ProfileDetailSection(
          title: 'Contact',
          icon: Icons.contact_mail_outlined,
          children: [
            ProfileDetailField(
              icon: Icons.email_outlined,
              label: 'Email',
              value: profile.email ?? profile.authEmail ?? '—',
            ),
            if (ProfileDisplayUtils.hasText(profile.authEmail) &&
                ProfileDisplayUtils.hasText(profile.email) &&
                profile.authEmail != profile.email)
              ProfileDetailField(
                icon: Icons.login_rounded,
                label: 'Login email',
                value: profile.authEmail!,
              ),
            ProfileDetailField(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile.phone ?? '—',
            ),
            if (ProfileDisplayUtils.hasText(profile.address))
              ProfileDetailField(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: profile.address!,
              ),
          ],
        ),
        const SizedBox(height: 14),
        ProfileDetailSection(
          title: 'Personal',
          icon: Icons.person_outline_rounded,
          children: [
            ProfileDetailField(
              icon: Icons.cake_outlined,
              label: 'Birthday',
              value: ProfileDisplayUtils.formatDate(profile.dateOfBirth, dateFormat),
            ),
            ProfileDetailField(
              icon: Icons.emergency_outlined,
              label: 'Emergency contact',
              value: profile.emergencyContact ?? '—',
            ),
            if (ProfileDisplayUtils.hasText(profile.gender))
              ProfileDetailField(
                icon: Icons.wc_outlined,
                label: 'Gender',
                value: ProfileDisplayUtils.genderLabel(profile.gender!),
              ),
          ],
        ),
      ],
    );
  }
}

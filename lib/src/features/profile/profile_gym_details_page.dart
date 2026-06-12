import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_amenities_grid.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_payment_options_section.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_weekly_hours_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/home/widgets/offers_carousel.dart';
import 'package:gym_member_app/src/features/profile/profile_display_utils.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_detail_field.dart';
import 'package:intl/intl.dart';

class ProfileGymDetailsPage extends ConsumerWidget {
  const ProfileGymDetailsPage({super.key});

  static const _sectionGap = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My gym'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(memberProfileProvider);
              final gymId = profileAsync.valueOrNull?.gymId;
              if (gymId != null) {
                ref.invalidate(directoryGymDetailProvider(gymId));
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not available.'));
          }
          return _GymDetailsBody(profile: profile);
        },
      ),
    );
  }
}

class _GymDetailsBody extends ConsumerWidget {
  const _GymDetailsBody({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(directoryGymDetailProvider(profile.gymId));
    final dateFormat = DateFormat.yMMMd();

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (detail) {
        final gymRaw = detail?['gym'];
        final gym = gymRaw is Map
            ? gymRaw.map((k, v) => MapEntry(k.toString(), v))
            : <String, dynamic>{};
        final hours = _parseMapList(detail?['hours']);
        final promos = _parseMapList(detail?['promotions']);
        final amenities = gymAmenitiesFromKeys(gym['amenities']);
        final paymentOptions = _parseMapList(detail?['payment_options']);
        final repo = ref.read(gymsRepositoryProvider);
        final theme = Theme.of(context);
        final semantics = context.appColors;
        final colorScheme = theme.colorScheme;
        final isActive = profile.memberStatus.toLowerCase() == 'active';

        final phone = gym['phone'] as String? ?? profile.gymPhone;
        final email = gym['email'] as String?;
        final address = gym['address'] as String? ?? profile.gymAddress;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(memberProfileProvider);
            ref.invalidate(directoryGymDetailProvider(profile.gymId));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: colorScheme.onPrimary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.gymName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since ${ProfileDisplayUtils.formatDate(profile.joinedOn, dateFormat)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.88,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _StatusChip(
                          label: profile.memberStatus.toUpperCase(),
                          background: isActive
                              ? semantics.accentLime.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.2),
                          textColor: isActive
                              ? semantics.onAccentLime
                              : colorScheme.onPrimary,
                        ),
                        _StatusChip(
                          label: 'HOME GYM',
                          background: Colors.white.withValues(alpha: 0.2),
                          textColor: colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
                children: [
                  ProfileMetricChip(
                    label: 'Member ID',
                    value: ProfileDisplayUtils.shortId(profile.memberId),
                    icon: Icons.badge_outlined,
                  ),
                  ProfileMetricChip(
                    label: 'Visits',
                    value: '${profile.attendanceStats.totalVisits}',
                    icon: Icons.history_rounded,
                  ),
                ],
              ),
              if (promos.isNotEmpty) ...[
                //const SizedBox(height: ProfileGymDetailsPage._sectionGap),
                const HomeSectionLabel(
                  title: 'Offers',
                  icon: Icons.local_offer_outlined,
                ),
                OffersCarousel(promotions: promos),
              ],
              if (ProfileDisplayUtils.hasText(profile.notes)) ...[
                const SizedBox(height: ProfileGymDetailsPage._sectionGap),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes from gym',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (ProfileDisplayUtils.hasText(phone) ||
                  ProfileDisplayUtils.hasText(email) ||
                  ProfileDisplayUtils.hasText(address)) ...[
                const SizedBox(height: ProfileGymDetailsPage._sectionGap),
                ProfileDetailSection(
                  title: 'Contact',
                  icon: Icons.contact_phone_outlined,
                  children: [
                    if (ProfileDisplayUtils.hasText(phone))
                      ProfileDetailField(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone!,
                      ),
                    if (ProfileDisplayUtils.hasText(email))
                      ProfileDetailField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email!,
                      ),
                    if (ProfileDisplayUtils.hasText(address))
                      ProfileDetailField(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: address!,
                      ),
                  ],
                ),
              ],
              if (paymentOptions.any((o) => o['is_primary'] == true)) ...[
                const SizedBox(height: ProfileGymDetailsPage._sectionGap),
                const HomeSectionLabel(
                  title: 'Pay at gym',
                  icon: Icons.qr_code_2_rounded,
                ),
                GymPaymentOptionsSection(
                  options: paymentOptions,
                  imageUrlForPath: repo.paymentQrImageUrl,
                  primaryOnly: true,
                ),
              ],
              if (amenities.isNotEmpty) ...[
                const SizedBox(height: ProfileGymDetailsPage._sectionGap),
                const HomeSectionLabel(
                  title: 'Facilities',
                  icon: Icons.category_rounded,
                ),
                GymAmenitiesGrid(amenities: amenities),
              ],
              const SizedBox(height: ProfileGymDetailsPage._sectionGap),
              const HomeSectionLabel(
                title: 'Weekly hours',
                icon: Icons.schedule_rounded,
              ),
              GymWeeklyHoursCard(hours: hours),
            ],
          ),
        );
      },
    );
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

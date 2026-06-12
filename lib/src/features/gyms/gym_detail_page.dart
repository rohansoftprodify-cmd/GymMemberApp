import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_amenities_grid.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_detail_hero.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_payment_options_section.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_weekly_hours_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/home/widgets/offers_carousel.dart';
import 'package:gym_member_app/src/features/profile/widgets/profile_info_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GymDetailPage extends ConsumerWidget {
  const GymDetailPage({super.key, required this.gymId});

  final String gymId;

  static const _sectionGap = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final linkedGymId = ref.watch(memberContextProvider).valueOrNull?.gymId;
    final detailAsync = ref.watch(directoryGymDetailProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(directoryGymDetailProvider(gymId)),
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (!isLoggedIn)
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign in'),
            ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(err.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Gym not found.'));
          }

          final gymRaw = detail['gym'];
          if (gymRaw is! Map) {
            return const Center(child: Text('Gym not found.'));
          }
          final gym = gymRaw.map((k, v) => MapEntry(k.toString(), v));
          final hours = _parseMapList(detail['hours']);
          final promos = _parseMapList(detail['promotions']);
          final isLinked = linkedGymId == gymId;
          final todayInfo = todayHoursInfo(hours);
          final gymName = gym['name'] as String? ?? 'Gym';

          final amenities = gymAmenitiesFromKeys(gym['amenities']);
          final paymentOptions = _parseMapList(detail['payment_options']);
          final repo = ref.read(gymsRepositoryProvider);

          return _GymDetailBody(
            gymId: gymId,
            gym: gym,
            gymName: gymName,
            hours: hours,
            promos: promos,
            amenities: amenities,
            paymentOptions: paymentOptions,
            paymentQrImageUrl: repo.paymentQrImageUrl,
            isLinked: isLinked,
            isLoggedIn: isLoggedIn,
            todayInfo: todayInfo,
            onRefresh: () async => ref.invalidate(directoryGymDetailProvider(gymId)),
          );
        },
      ),
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

class _GymDetailBody extends StatelessWidget {
  const _GymDetailBody({
    required this.gymId,
    required this.gym,
    required this.gymName,
    required this.hours,
    required this.promos,
    required this.amenities,
    required this.paymentOptions,
    required this.paymentQrImageUrl,
    required this.isLinked,
    required this.isLoggedIn,
    required this.todayInfo,
    required this.onRefresh,
  });

  final String gymId;
  final Map<String, dynamic> gym;
  final String gymName;
  final List<Map<String, dynamic>> hours;
  final List<Map<String, dynamic>> promos;
  final List<GymAmenity> amenities;
  final List<Map<String, dynamic>> paymentOptions;
  final String? Function(String? path) paymentQrImageUrl;
  final bool isLinked;
  final bool isLoggedIn;
  final ({String label, bool isOpen}) todayInfo;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    final contactRows = <ProfileInfoRowData>[
      if (_hasText(gym['phone']))
        ProfileInfoRowData(label: 'Phone', value: gym['phone'] as String),
      if (_hasText(gym['email']))
        ProfileInfoRowData(label: 'Email', value: gym['email'] as String),
      if (_hasText(gym['address']))
        ProfileInfoRowData(label: 'Address', value: gym['address'] as String),
      if (_hasText(gym['timezone']))
        ProfileInfoRowData(label: 'Timezone', value: gym['timezone'] as String),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          GymDetailHero(
            gymName: gymName,
            isLinkedGym: isLinked,
            todaySlotLabel: todayInfo.label,
            isOpenToday: todayInfo.isOpen,
            amenities: amenities,
          ),
          const SizedBox(height: GymDetailPage._sectionGap),
          if (!isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Become a member',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in with credentials from this gym to check in, view your plan, and shop.',
                          style: theme.textTheme.labelSmall?.copyWith(height: 1.35),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push('/login'),
                          child: const Text('Member sign in'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GymDetailPage._sectionGap),
          ],
          if (isLinked && isLoggedIn) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: semantics.accentLime.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: semantics.accentLime.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: semantics.onAccentLime, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is your home gym. Use Attendance to check in when you visit.',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GymDetailPage._sectionGap),
          ],
          if (amenities.isNotEmpty) ...[
            const HomeSectionLabel(title: 'Facilities', icon: Icons.category_rounded),
            GymAmenitiesGrid(amenities: amenities),
            const SizedBox(height: GymDetailPage._sectionGap),
          ],
          if (contactRows.isNotEmpty) ...[
            const HomeSectionLabel(title: 'Contact', icon: Icons.contact_phone_outlined),
            ProfileInfoSection(
              title: 'Get in touch',
              icon: Icons.storefront_outlined,
              rows: contactRows,
            ),
            const SizedBox(height: GymDetailPage._sectionGap),
          ],
          if (paymentOptions.isNotEmpty) ...[
            const HomeSectionLabel(title: 'Pay at gym', icon: Icons.payments_outlined),
            GymPaymentOptionsSection(
              options: paymentOptions,
              imageUrlForPath: paymentQrImageUrl,
            ),
            const SizedBox(height: GymDetailPage._sectionGap),
          ],
          const HomeSectionLabel(title: 'Weekly hours', icon: Icons.schedule_rounded),
          GymWeeklyHoursCard(hours: hours),
          const SizedBox(height: GymDetailPage._sectionGap),
          const HomeSectionLabel(title: 'Offers', icon: Icons.local_offer_outlined),
          OffersCarousel(promotions: promos),
          if (isLoggedIn && isLinked) ...[
            const SizedBox(height: GymDetailPage._sectionGap),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded, size: 20),
                label: const Text('Go to member home'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _hasText(dynamic value) => value is String && value.isNotEmpty;
}

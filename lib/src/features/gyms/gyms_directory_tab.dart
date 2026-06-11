import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_list_tile.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gyms_directory_header.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class GymsDirectoryTab extends ConsumerStatefulWidget {
  const GymsDirectoryTab({
    super.key,
    this.linkedGymId,
    this.showSignInBanner = false,
  });

  final String? linkedGymId;
  final bool showSignInBanner;

  @override
  ConsumerState<GymsDirectoryTab> createState() => _GymsDirectoryTabState();
}

class _GymsDirectoryTabState extends ConsumerState<GymsDirectoryTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _facilityFilter;

  static const _sectionGap = 16.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGym(String gymId) {
    GoRouter.of(context).push('/gym/$gymId');
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
  }

  bool _matchesFilters(Map<String, dynamic> gym) {
    if (_facilityFilter != null) {
      final keys = gym['amenities'];
      final amenityKeys = keys is List ? keys.map((e) => e.toString()).toList() : <String>[];
      if (!amenityKeys.contains(_facilityFilter)) return false;
    }

    if (_query.isEmpty) return true;

    final q = _query.toLowerCase();
    final name = (gym['name'] as String? ?? '').toLowerCase();
    final address = (gym['address'] as String? ?? '').toLowerCase();
    final phone = (gym['phone'] as String? ?? '').toLowerCase();
    final facilityText = gymAmenitiesFromKeys(gym['amenities'])
        .map((a) => a.label.toLowerCase())
        .join(' ');

    return name.contains(q) ||
        address.contains(q) ||
        phone.contains(q) ||
        facilityText.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final gymsAsync = ref.watch(directoryGymsProvider);

    return gymsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(err.toString(), textAlign: TextAlign.center),
        ),
      ),
      data: (gyms) {
        final linked = widget.linkedGymId;
        final filtered = gyms.where(_matchesFilters).toList();

        Map<String, dynamic>? linkedGym;
        if (linked != null) {
          for (final g in gyms) {
            if (g['id'] == linked) {
              linkedGym = g;
              break;
            }
          }
        }

        final listGyms = linked == null
            ? List<Map<String, dynamic>>.from(filtered)
            : filtered.where((g) => g['id'] != linked).toList();

        listGyms.sort(
          (a, b) => (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''),
        );

        final showLinkedInResults =
            linkedGym != null && (_query.isEmpty && _facilityFilter == null || filtered.any((g) => g['id'] == linked));

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(directoryGymsProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: widget.showSignInBanner ? 8 : 100, top: 4),
            children: [
              GymsDirectoryHeader(
                totalCount: gyms.length,
                showingCount: filtered.length,
                searchController: _searchController,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v.trim()),
                onClearQuery: _clearQuery,
                selectedFacilityKey: _facilityFilter,
                onFacilitySelected: (key) => setState(() => _facilityFilter = key),
              ),
              if (showLinkedInResults && linkedGym != null) ...[
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Your gym', icon: Icons.star_rounded),
                GymListTile(
                  gym: linkedGym,
                  isLinkedGym: true,
                  featured: true,
                  onTap: () => _openGym(linked!),
                ),
              ],
              const SizedBox(height: _sectionGap),
              HomeSectionLabel(
                title: showLinkedInResults ? 'Other gyms' : 'All gyms',
                icon: Icons.fitness_center_outlined,
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: semantics.mutedText),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty && _facilityFilter == null
                              ? 'No gyms listed yet.'
                              : 'No gyms match your search.',
                          style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                        ),
                      ],
                    ),
                  ),
                )
              else if (listGyms.isEmpty && showLinkedInResults)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No other gyms match your filters.',
                    style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                  ),
                )
              else
                ...listGyms.map((gym) {
                  final id = gym['id'] as String;
                  return GymListTile(
                    gym: gym,
                    onTap: () => _openGym(id),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

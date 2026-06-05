import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_list_tile.dart';
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

  static const _sectionGap = 18.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGym(String gymId) {
    GoRouter.of(context).push('/gym/$gymId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
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
        final filtered = gyms.where((g) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          final name = (g['name'] as String? ?? '').toLowerCase();
          final address = (g['address'] as String? ?? '').toLowerCase();
          final phone = (g['phone'] as String? ?? '').toLowerCase();
          return name.contains(q) || address.contains(q) || phone.contains(q);
        }).toList();

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
            linkedGym != null && (_query.isEmpty || filtered.any((g) => g['id'] == linked));

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(directoryGymsProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            children: [
              // GymsDirectoryHero(
              //   gymCount: gyms.length,
              //   showSignInCta: widget.showSignInBanner,
              //   onSignIn: widget.showSignInBanner ? () => context.push('/login') : null,
              // ),
              //const SizedBox(height: _sectionGap),
              // GymsDirectoryStats(
              //   totalCount: gyms.length,
              //   showingCount: filtered.length,
              //   hasLinkedGym: linked != null && linkedGym != null,
              // ),
              // const SizedBox(height: _sectionGap),
              Container(
                decoration: BoxDecoration(
                  color: semantics.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search name, address, or phone',
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary, size: 22),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              if (showLinkedInResults) ...[
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
                          _query.isEmpty ? 'No gyms listed yet.' : 'No gyms match your search.',
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
                    'No other gyms match your search.',
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

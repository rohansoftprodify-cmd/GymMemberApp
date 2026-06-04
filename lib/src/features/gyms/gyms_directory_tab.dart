import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_list_tile.dart';

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
        final filtered = gyms.where((g) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          final name = (g['name'] as String? ?? '').toLowerCase();
          final address = (g['address'] as String? ?? '').toLowerCase();
          return name.contains(q) || address.contains(q);
        }).toList();

        final linked = widget.linkedGymId;
        if (linked != null) {
          filtered.sort((a, b) {
            final aLinked = a['id'] == linked;
            final bLinked = b['id'] == linked;
            if (aLinked == bLinked) {
              return (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? '');
            }
            return aLinked ? -1 : 1;
          });
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 4),
          children: [
            if (widget.showSignInBanner) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover gyms near you',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse all partner gyms. Sign in when you are a member to check in, track attendance, and more.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: colorScheme.primary,
                      ),
                      onPressed: () => context.push('/login'),
                      child: const Text('Member sign in'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'All gyms (${gyms.length})',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a gym to view hours, contact, and offers.',
              style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search by name or address',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    _query.isEmpty ? 'No gyms listed yet.' : 'No gyms match your search.',
                    style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                  ),
                ),
              )
            else
              ...filtered.map((gym) {
                final id = gym['id'] as String;
                return GymListTile(
                  gym: gym,
                  isLinkedGym: linked != null && linked == id,
                  onTap: () => _openGym(id),
                );
              }),
          ],
        );
      },
    );
  }
}

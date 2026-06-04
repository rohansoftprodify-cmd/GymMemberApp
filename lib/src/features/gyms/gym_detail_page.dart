import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/gyms_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GymDetailPage extends ConsumerWidget {
  const GymDetailPage({super.key, required this.gymId});

  final String gymId;

  static const _dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final linkedGymId = ref.watch(memberContextProvider).valueOrNull?.gymId;
    final detailAsync = ref.watch(directoryGymDetailProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym details'),
        actions: [
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
          final dateFormat = DateFormat.yMMMd();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: semantics.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLinked
                        ? colorScheme.primary.withValues(alpha: 0.45)
                        : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.fitness_center_rounded, color: colorScheme.primary, size: 36),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      gym['name'] as String? ?? 'Gym',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                    if (isLinked) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: semantics.accentLime,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOUR GYM',
                          style: TextStyle(
                            color: semantics.onAccentLime,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (_hasText(gym['phone']))
                      _InfoRow(icon: Icons.phone_outlined, label: gym['phone'] as String),
                    if (_hasText(gym['email'])) ...[
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.email_outlined, label: gym['email'] as String),
                    ],
                    if (_hasText(gym['address'])) ...[
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.location_on_outlined, label: gym['address'] as String),
                    ],
                    if (_hasText(gym['timezone'])) ...[
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.public_rounded, label: gym['timezone'] as String),
                    ],
                  ],
                ),
              ),
              if (!isLoggedIn) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sign in with member credentials from this gym to check in, view your plan, and shop.',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Weekly hours',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (hours.isEmpty)
                Text(
                  'Operating hours not configured.',
                  style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                )
              else
                ...hours.map((row) => _HoursRow(row: row, dayNames: _dayNames)),
              if (promos.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Active offers',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ...promos.map((p) {
                  final endAt = DateTime.tryParse(p['end_at']?.toString() ?? '');
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'] as String? ?? 'Offer',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_hasText(p['description']))
                          Text(
                            p['description'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        if (endAt != null)
                          Text(
                            'Until ${dateFormat.format(endAt)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  static bool _hasText(dynamic value) {
    return value is String && value.isNotEmpty;
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.row, required this.dayNames});

  final Map<String, dynamic> row;
  final List<String> dayNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final day = row['day_of_week'] as int? ?? 1;
    final closed = row['is_closed'] == true;
    final label = closed
        ? 'Closed'
        : '${_formatTime(row['open_time'])} – ${_formatTime(row['close_time'])}';
    final isToday = day == DateTime.now().weekday;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? colorScheme.primary.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dayNames[day],
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? colorScheme.primary : null,
              ),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: closed ? semantics.accentCoral : semantics.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '—';
    final s = raw.toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final semantics = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 18, color: semantics.mutedText),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }
}

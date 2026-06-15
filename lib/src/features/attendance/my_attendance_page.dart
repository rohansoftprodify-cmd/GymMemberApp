import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_history_summary.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_visit_card.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_visit_utils.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class MyAttendancePage extends ConsumerStatefulWidget {
  const MyAttendancePage({
    super.key,
    required this.gymId,
    required this.memberId,
  });

  final String gymId;
  final String memberId;

  @override
  ConsumerState<MyAttendancePage> createState() => _MyAttendancePageState();
}

class _MyAttendancePageState extends ConsumerState<MyAttendancePage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref
        .read(memberRepositoryProvider)
        .myAttendance(widget.gymId, widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Attendance history'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ShimmerAttendanceHistory();
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(snap.error.toString(), textAlign: TextAlign.center),
              ),
            );
          }

          final rows = snap.data ?? [];
          final grouped = groupVisitsByDay(rows);
          final dayKeys = sortedDayKeys(grouped);
          final activeSessions = rows
              .where((r) => r['check_out_at'] == null)
              .length;
          final monthCount = visitsThisMonth(rows);

          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
              await _future;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // AttendanceHistorySummary(
                //   totalVisits: rows.length,
                //   visitsThisMonth: monthCount,
                //   activeSessions: activeSessions,
                // ),
                //const SizedBox(height: 20),
                if (rows.isEmpty)
                  _HistoryEmptyState(
                    semantics: semantics,
                    colorScheme: colorScheme,
                    theme: theme,
                  )
                else ...[
                  const HomeSectionLabel(
                    title: 'All visits',
                    icon: Icons.list_alt_rounded,
                  ),
                  for (final dayKey in dayKeys) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        visitSectionTitle(grouped[dayKey]!.first.checkIn),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: semantics.mutedText,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    for (var i = 0; i < grouped[dayKey]!.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      AttendanceVisitCard(
                        visit: grouped[dayKey]![i],
                        compact: false,
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.semantics,
    required this.colorScheme,
    required this.theme,
  });

  final AppSemanticColors semantics;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: colorScheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance records yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your check-ins and check-outs will appear here once you start visiting the gym.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: semantics.mutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

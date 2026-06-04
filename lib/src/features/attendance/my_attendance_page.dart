import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/home/widgets/home_recent_attendance_section.dart';
import 'package:intl/intl.dart';

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
    _future = ref.read(memberRepositoryProvider).myAttendance(widget.gymId, widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM d, y · h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance history'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }

          final rows = snap.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
              await _future;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No attendance records yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.appColors.mutedText,
                            ),
                      ),
                    ),
                  )
                else
                  HomeRecentAttendanceSection(
                    records: rows,
                    format: format,
                    title: 'All visits',
                    showHeader: false,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

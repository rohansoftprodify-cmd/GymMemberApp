import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
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
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _future = ref
            .read(memberRepositoryProvider)
            .myAttendance(widget.gymId, widget.memberId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final format = DateFormat('MMM d, y · h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('My attendance')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (_future == null || snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No attendance records yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final row = rows[i];
              final checkIn = DateTime.parse(row['check_in_at'] as String).toLocal();
              final checkOutRaw = row['check_out_at'] as String?;
              final checkOut = checkOutRaw == null ? null : DateTime.parse(checkOutRaw).toLocal();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: semantics.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in: ${format.format(checkIn)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      checkOut == null ? 'Still checked in' : 'Check-out: ${format.format(checkOut)}',
                      style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

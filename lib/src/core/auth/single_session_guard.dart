import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/auth/single_session_provider.dart';
import 'package:gym_member_app/src/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SingleSessionGuard extends ConsumerStatefulWidget {
  const SingleSessionGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SingleSessionGuard> createState() => _SingleSessionGuardState();
}

class _SingleSessionGuardState extends ConsumerState<SingleSessionGuard>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  void _setup() {
    final service = ref.read(singleSessionServiceProvider);
    service.setTakeoverHandler(_showTakeoverDialog);

    if (Supabase.instance.client.auth.currentSession != null) {
      service.startMonitoring();
    }

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final sessionService = ref.read(singleSessionServiceProvider);
      if (data.session != null) {
        sessionService.startMonitoring();
      } else {
        sessionService.stopMonitoring();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        Supabase.instance.client.auth.currentSession != null) {
      ref.read(singleSessionServiceProvider).startMonitoring();
    }
  }

  Future<void> _showTakeoverDialog() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.devices_other_rounded),
        title: const Text('Signed out'),
        content: const Text(
          'Your account was signed in on another device. '
          'Only one device can be active at a time.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (context.mounted) {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

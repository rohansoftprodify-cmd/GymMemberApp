import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/auth/single_session_provider.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/onboarding/profile_setup_gate.dart';
import 'package:gym_member_app/src/core/onboarding/profile_setup_prefs.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _confirmSingleDeviceSignIn() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.devices_rounded),
        title: const Text('Already signed in elsewhere'),
        content: const Text(
          'This account is active on another device. '
          'Signing in here will log out that device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return proceed == true;
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final client = Supabase.instance.client;
    final sessionService = ref.read(singleSessionServiceProvider);

    try {
      final hasActiveElsewhere = await sessionService.emailHasActiveSession(email);
      if (!mounted) return;

      if (hasActiveElsewhere) {
        setState(() => _loading = false);
        final confirmed = await _confirmSingleDeviceSignIn();
        if (!confirmed || !mounted) return;
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      await sessionService.prepareForSignIn();

      await client.auth.signInWithPassword(
        email: email,
        password: _passwordController.text,
      );

      final ctx = await client.rpc('get_my_member_context');
      if (ctx == null) {
        await ref.read(singleSessionServiceProvider).signOutLocally();
        if (mounted) {
          setState(() {
            _error =
                'This login is not linked to a gym member record. '
                'Ask your gym to enable app login for your membership.';
          });
        }
        return;
      }

      await ref.read(singleSessionServiceProvider).completeSignInAfterPassword();

      if (!mounted) return;

      final repo = MemberRepository(client);

      if (await ProfileSetupPrefs.isCompleted()) {
        final local = await ProfileSetupPrefs.load();
        if (local != null) {
          try {
            await repo.syncLocalProfileSetupIfNeeded(local);
          } catch (_) {}
        }
      }

      final showProfileSetup = await ProfileSetupGate.shouldShow(
        memberRepository: repo,
      );
      if (!mounted) return;

      ref.invalidate(memberContextProvider);

      if (showProfileSetup) {
        context.go('/profile-setup');
      } else {
        context.go('/');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to sign in.');
    } finally {
      ref.read(singleSessionServiceProvider).finishSignInAttempt();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/explore'),
        ),
        title: const Text('Sign in'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Member Login',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in with credentials provided by your gym.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Only one device can stay signed in at a time.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      contentPadding: const EdgeInsets.all(20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(24)),
                    ),
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading ? null : () => context.go('/explore'),
                    child: const Text('Browse all gyms without signing in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

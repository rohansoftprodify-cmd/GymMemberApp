import 'package:flutter/material.dart';

class GymsDirectoryHero extends StatelessWidget {
  const GymsDirectoryHero({
    super.key,
    required this.gymCount,
    this.showSignInCta = false,
    this.onSignIn,
  });

  final int gymCount;
  final bool showSignInCta;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.explore_rounded, color: colorScheme.onPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showSignInCta ? 'Discover gyms' : 'Browse gyms',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$gymCount partner ${gymCount == 1 ? 'gym' : 'gyms'} available',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            showSignInCta
                ? 'Explore hours, offers, and contact info. Sign in as a member to check in and track your plan.'
                : 'View hours, offers, and contact details for every partner gym.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          if (showSignInCta && onSignIn != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                ),
                onPressed: onSignIn,
                child: const Text('Member sign in'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

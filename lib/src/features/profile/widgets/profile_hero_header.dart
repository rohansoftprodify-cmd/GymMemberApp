import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';

class ProfileHeroHeader extends StatelessWidget {
  const ProfileHeroHeader({super.key, required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initial = profile.fullName.trim().isEmpty
        ? '?'
        : profile.fullName.trim()[0].toUpperCase();
    final isActive = profile.memberStatus.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              profile.fullName,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              profile.gymName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.88),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _HeroChip(
                  label: profile.memberStatus.toUpperCase(),
                  background: isActive
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.15),
                  textColor: colorScheme.onPrimary,
                ),
                if (profile.attendanceStats.isCheckedIn)
                  _HeroChip(
                    label: 'CHECKED IN',
                    background: const Color(0xFFD4FF00).withValues(alpha: 0.9),
                    textColor: Colors.black,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}

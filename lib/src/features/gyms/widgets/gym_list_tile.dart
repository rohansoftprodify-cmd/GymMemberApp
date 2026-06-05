import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class GymListTile extends StatelessWidget {
  const GymListTile({
    super.key,
    required this.gym,
    required this.onTap,
    this.isLinkedGym = false,
    this.featured = false,
  });

  final Map<String, dynamic> gym;
  final VoidCallback onTap;
  final bool isLinkedGym;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final name = gym['name'] as String? ?? 'Gym';
    final address = gym['address'] as String?;
    final phone = gym['phone'] as String?;
    final email = gym['email'] as String?;
    final todayHours = gym['today_hours_label'] as String?;
    final isOpenToday = gym['is_open_today'] == true;
    final promoCount = (gym['active_promotions_count'] as num?)?.toInt() ?? 0;
    final highlight = isLinkedGym || featured;
    final accent = isLinkedGym ? semantics.accentLime : colorScheme.primary;
    final onAccent = isLinkedGym ? semantics.onAccentLime : colorScheme.onPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: featured ? 14 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? accent.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (highlight ? accent : colorScheme.primary).withValues(alpha: featured ? 0.14 : 0.06),
            blurRadius: featured ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: semantics.cardBackground,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GymCardHeader(
                name: name,
                initials: _gymInitials(name),
                accent: accent,
                onAccent: onAccent,
                isLinkedGym: isLinkedGym,
                featured: featured,
                todayHours: todayHours,
                isOpenToday: isOpenToday,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasText(address))
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: address!,
                        maxLines: 2,
                      ),
                    if (_hasText(phone)) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        text: phone!,
                        emphasized: true,
                      ),
                    ],
                    if (_hasText(email)) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.mail_outline_rounded,
                        text: email!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (promoCount > 0) ...[
                          _MetaChip(
                            icon: Icons.local_offer_outlined,
                            label: promoCount == 1 ? '1 offer' : '$promoCount offers',
                            background: semantics.accentCoral.withValues(alpha: 0.12),
                            foreground: semantics.accentCoral,
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Spacer(),
                        Text(
                          'View details',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  static String _gymInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _GymCardHeader extends StatelessWidget {
  const _GymCardHeader({
    required this.name,
    required this.initials,
    required this.accent,
    required this.onAccent,
    required this.isLinkedGym,
    required this.featured,
    this.todayHours,
    required this.isOpenToday,
  });

  final String name;
  final String initials;
  final Color accent;
  final Color onAccent;
  final bool isLinkedGym;
  final bool featured;
  final String? todayHours;
  final bool isOpenToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;
    final gradientEnd = isLinkedGym
        ? Color.lerp(accent, colorScheme.secondary, 0.35)!
        : colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, gradientEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -10,
            child: Icon(
              Icons.fitness_center_rounded,
              size: featured ? 88 : 72,
              color: onAccent.withValues(alpha: 0.1),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: featured ? 50 : 46,
                height: featured ? 50 : 46,
                decoration: BoxDecoration(
                  color: onAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: onAccent.withValues(alpha: 0.25)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: onAccent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: featured ? 16 : 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (isLinkedGym)
                          _HeaderChip(
                            label: 'YOUR GYM',
                            background: semantics.accentLime,
                            textColor: semantics.onAccentLime,
                          ),
                        if (todayHours != null && todayHours!.isNotEmpty)
                          _HeaderChip(
                            label: todayHours!,
                            background: onAccent.withValues(alpha: isOpenToday ? 0.22 : 0.14),
                            textColor: onAccent,
                            icon: isOpenToday ? Icons.schedule_rounded : Icons.event_busy_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.background,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color background;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.maxLines = 1,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final int maxLines;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: emphasized ? colorScheme.primary : semantics.mutedText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: emphasized ? colorScheme.primary : semantics.mutedText,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

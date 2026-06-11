import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_amenities_chips.dart';

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
    final amenities = gymAmenitiesFromKeys(gym['amenities']);
    final highlight = isLinkedGym || featured;
    final accent = isLinkedGym ? semantics.accentLime : colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: featured ? 14 : 10),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? accent.withValues(alpha: 0.55) : colorScheme.outline.withValues(alpha: 0.45),
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: highlight ? accent : colorScheme.outline.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _GymAvatar(
                              initials: _gymInitials(name),
                              accent: accent,
                              featured: featured,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toUpperCase(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isLinkedGym) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: semantics.accentLime,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'YOUR GYM',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: semantics.onAccentLime,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_hasText(address)) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: semantics.mutedText,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            address!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: semantics.mutedText,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (_hasText(phone)) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.phone_outlined, size: 14, color: colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          phone!,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: colorScheme.primary, size: 22),
                          ],
                        ),
                        if (amenities.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          GymAmenitiesChips(
                            amenities: amenities,
                            maxVisible: featured ? 6 : 5,
                            compact: true,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'VIEW DETAILS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

class _GymAvatar extends StatelessWidget {
  const _GymAvatar({
    required this.initials,
    required this.accent,
    required this.featured,
  });

  final String initials;
  final Color accent;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final size = featured ? 52.0 : 46.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: featured ? 18 : 16,
          fontWeight: FontWeight.w900,
          color: accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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
    final highlight = isLinkedGym || featured;

    return Container(
      margin: EdgeInsets.only(bottom: featured ? 12 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? colorScheme.primary.withValues(alpha: 0.55)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: featured
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: highlight && featured
            ? colorScheme.primary.withValues(alpha: 0.04)
            : semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              if (highlight)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isLinkedGym ? semantics.accentLime : colorScheme.primary,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: featured ? 52 : 48,
                        height: featured ? 52 : 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: colorScheme.primary,
                          size: featured ? 26 : 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: featured ? 15 : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLinkedGym)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: semantics.accentLime,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'YOUR GYM',
                                      style: TextStyle(
                                        color: semantics.onAccentLime,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (address != null && address.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                address,
                                maxLines: featured ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                              ),
                            ],
                            if (featured && phone != null && phone.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 12, color: semantics.mutedText),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
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
                      Icon(Icons.chevron_right_rounded, color: semantics.mutedText),
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
}

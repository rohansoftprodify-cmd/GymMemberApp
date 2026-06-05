import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';

class EditProfileGoalSection extends StatelessWidget {
  const EditProfileGoalSection({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        for (final option in fitnessGoalOptions) ...[
          _GoalTile(
            option: option,
            selected: option.key == selectedKey,
            colorScheme: colorScheme,
            semantics: semantics,
            onTap: () => onSelected(option.key),
          ),
          if (option != fitnessGoalOptions.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.option,
    required this.selected,
    required this.colorScheme,
    required this.semantics,
    required this.onTap,
  });

  final FitnessGoalOption option;
  final bool selected;
  final ColorScheme colorScheme;
  final AppSemanticColors semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.08)
          : semantics.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.55)
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: semantics.mutedText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

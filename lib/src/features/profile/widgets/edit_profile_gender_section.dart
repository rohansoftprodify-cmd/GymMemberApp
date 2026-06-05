import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';

class EditProfileGenderSection extends StatelessWidget {
  const EditProfileGenderSection({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in genderOptions)
          ChoiceChip(
            label: Text(option.label),
            selected: option.key == selectedKey,
            onSelected: (selected) => onSelected(selected ? option.key : null),
            selectedColor: colorScheme.primary.withValues(alpha: 0.15),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: option.key == selectedKey ? FontWeight.w700 : FontWeight.w500,
              color: option.key == selectedKey ? colorScheme.primary : semantics.mutedText,
            ),
            side: BorderSide(
              color: option.key == selectedKey
                  ? colorScheme.primary.withValues(alpha: 0.55)
                  : colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class EditableMetricRow extends StatelessWidget {
  const EditableMetricRow({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: semantics.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onEdit,
          icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
          label: Text(
            'Edit',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

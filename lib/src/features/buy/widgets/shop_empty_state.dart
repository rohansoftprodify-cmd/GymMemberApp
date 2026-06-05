import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class ShopEmptyState extends StatelessWidget {
  const ShopEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 36, color: semantics.mutedText),
          const SizedBox(height: 10),
          Text(
            'No products in this category',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back later or browse another category.',
            style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
          ),
        ],
      ),
    );
  }
}

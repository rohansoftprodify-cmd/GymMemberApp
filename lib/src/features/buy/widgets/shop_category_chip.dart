import 'package:flutter/material.dart';

class ShopCategoryChip extends StatelessWidget {
  const ShopCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? colorScheme.primary : null,
          fontSize: 12,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class ProductCartControls extends StatelessWidget {
  const ProductCartControls({
    super.key,
    required this.qty,
    required this.inStock,
    required this.canAddMore,
    required this.onAdd,
    required this.onSubtract,
    required this.onRemove,
  });

  final int qty;
  final bool inStock;
  final bool canAddMore;
  final VoidCallback? onAdd;
  final VoidCallback? onSubtract;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    if (!inStock) {
      return Text(
        'Out of stock',
        style: theme.textTheme.labelSmall?.copyWith(
          color: semantics.accentCoral,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      );
    }

    if (qty == 0) {
      if (onAdd == null) return const SizedBox.shrink();
      return Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 16, color: colorScheme.onPrimary),
                const SizedBox(width: 2),
                Text(
                  'ADD',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            icon: qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: qty == 1 ? semantics.accentCoral : colorScheme.primary,
            onTap: qty == 1 ? onRemove : onSubtract,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
          ),
          _ControlButton(
            icon: Icons.add_rounded,
            color: colorScheme.primary,
            onTap: canAddMore ? onAdd : null,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? color.withValues(alpha: 0.35) : color,
          ),
        ),
      ),
    );
  }
}

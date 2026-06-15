import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/buy/cart_provider.dart';
import 'package:gym_member_app/src/features/buy/models/cart_item.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_price_display.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final cart = ref.read(cartProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ProductPriceDisplay(
                  actualPrice: item.unitPrice,
                  mainStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Line total: ₹${item.lineTotal.toStringAsFixed(0)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: semantics.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Remove',
                onPressed: () => cart.remove(item.productId),
                icon: Icon(Icons.delete_outline_rounded, color: semantics.accentCoral, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onPressed: item.qty > 1
                        ? () => cart.setQty(item.productId, item.qty - 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${item.qty}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    onPressed: item.qty < item.stockQty
                        ? () => cart.setQty(item.productId, item.qty + 1)
                        : null,
                  ),
                ],
              ),
              Text(
                'Max ${item.stockQty}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: semantics.mutedText,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 16, color: onPressed == null ? colorScheme.outline : colorScheme.primary),
        ),
      ),
    );
  }
}

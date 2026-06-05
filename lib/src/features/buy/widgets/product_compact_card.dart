import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_image.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_stock_chip.dart';

class ProductCompactCard extends StatelessWidget {
  const ProductCompactCard({
    super.key,
    required this.name,
    required this.price,
    required this.stockQty,
    this.categoryName,
    this.imageUrl,
  });

  final String name;
  final double price;
  final int stockQty;
  final String? categoryName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final inStock = stockQty > 0;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ProductImage(
              imageUrl: hasImage ? imageUrl : null,
              name: name,
              inStock: inStock,
              compact: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (categoryName != null && categoryName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      categoryName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      ProductStockChip(
                        inStock: inStock,
                        stockQty: stockQty,
                        accent: inStock ? colorScheme.primary : semantics.accentCoral,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

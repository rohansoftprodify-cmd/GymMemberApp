import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_compact_card.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_image.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_stock_chip.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stockQty,
    this.description,
    this.imageUrl,
    this.categoryName,
    this.compact = false,
  });

  final String name;
  final double price;
  final int stockQty;
  final String? description;
  final String? imageUrl;
  final String? categoryName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ProductCompactCard(
        name: name,
        price: price,
        stockQty: stockQty,
        categoryName: categoryName,
        imageUrl: imageUrl,
      );
    }

    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final inStock = stockQty > 0;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductImage(
            imageUrl: hasImage ? imageUrl : null,
            name: name,
            inStock: inStock,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (categoryName != null && categoryName!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              categoryName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (description != null && description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: semantics.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    ProductStockChip(
                      inStock: inStock,
                      stockQty: stockQty,
                      accent: inStock ? colorScheme.primary : semantics.accentCoral,
                    ),
                    const Spacer(),
                    if (!inStock)
                      Text(
                        'Unavailable',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: semantics.accentCoral,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

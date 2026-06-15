import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_cart_controls.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_image_placeholder.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_price_display.dart';

class SuggestedProductCard extends StatelessWidget {
  const SuggestedProductCard({
    super.key,
    required this.name,
    required this.actualPrice,
    this.offerPrice,
    required this.stockQty,
    this.categoryName,
    this.imageUrl,
    this.cartQty = 0,
    this.onAdd,
    this.onSubtract,
    this.onRemove,
  });

  final String name;
  final double actualPrice;
  final double? offerPrice;
  final int stockQty;
  final String? categoryName;
  final String? imageUrl;
  final int cartQty;
  final VoidCallback? onAdd;
  final VoidCallback? onSubtract;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final inStock = stockQty > 0;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final hasOffer = offerPrice != null && offerPrice! > 0 && offerPrice! < actualPrice;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            semantics.accentLime.withValues(alpha: 0.14),
            semantics.cardBackground,
            semantics.cardBackground,
          ],
        ),
        border: Border.all(
          color: cartQty > 0
              ? colorScheme.primary.withValues(alpha: 0.5)
              : semantics.accentLime.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: semantics.accentLime.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: semantics.accentLime.withValues(alpha: 0.85),
            ),
            SizedBox(
              width: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ProductImagePlaceholder(
                        colorScheme: colorScheme,
                      ),
                    )
                  else
                    ProductImagePlaceholder(colorScheme: colorScheme),
                  if (!inStock)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      alignment: Alignment.center,
                      child: Text(
                        'OUT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: semantics.accentLime.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 11,
                                color: semantics.onAccentLime,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'PICK',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: semantics.onAccentLime,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasOffer) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: semantics.accentCoral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: semantics.accentCoral.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'OFFER',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: semantics.accentCoral,
                                fontWeight: FontWeight.w800,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
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
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ProductPriceDisplay(
                            actualPrice: actualPrice,
                            offerPrice: offerPrice,
                            mainStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        ProductCartControls(
                          qty: cartQty,
                          inStock: inStock,
                          canAddMore: cartQty < stockQty,
                          onAdd: onAdd,
                          onSubtract: onSubtract,
                          onRemove: onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

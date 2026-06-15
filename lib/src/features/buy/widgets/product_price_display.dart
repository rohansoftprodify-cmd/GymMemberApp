import 'package:flutter/material.dart';

class ProductPriceDisplay extends StatelessWidget {
  const ProductPriceDisplay({
    super.key,
    required this.actualPrice,
    this.offerPrice,
    this.mainStyle,
    this.strikeStyle,
  });

  final double actualPrice;
  final double? offerPrice;
  final TextStyle? mainStyle;
  final TextStyle? strikeStyle;

  bool get _hasOffer =>
      offerPrice != null && offerPrice! > 0 && offerPrice! < actualPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selling = _hasOffer ? offerPrice! : actualPrice;
    final priceStyle = mainStyle ??
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: colorScheme.primary,
        );
    final mutedStyle = strikeStyle ??
        theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          decoration: TextDecoration.lineThrough,
          fontSize: 10,
        );

    if (!_hasOffer) {
      return Text('₹${selling.toStringAsFixed(0)}', style: priceStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            '₹${actualPrice.toStringAsFixed(0)}',
            style: mutedStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text('₹${selling.toStringAsFixed(0)}', style: priceStyle),
      ],
    );
  }
}

double productActualPrice(Map<String, dynamic> product) {
  return (product['actual_price'] as num?)?.toDouble() ??
      (product['price'] as num?)?.toDouble() ??
      0;
}

double? productOfferPrice(Map<String, dynamic> product) {
  return (product['offer_price'] as num?)?.toDouble();
}

double productSellingPrice(Map<String, dynamic> product) {
  final actual = productActualPrice(product);
  final offer = productOfferPrice(product);
  if (offer != null && offer > 0 && offer < actual) return offer;
  return actual;
}

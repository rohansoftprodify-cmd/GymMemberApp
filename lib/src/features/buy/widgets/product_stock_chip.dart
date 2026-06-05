import 'package:flutter/material.dart';

class ProductStockChip extends StatelessWidget {
  const ProductStockChip({
    super.key,
    required this.inStock,
    required this.stockQty,
    required this.accent,
    this.compact = false,
  });

  final bool inStock;
  final int stockQty;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        compact
            ? (inStock ? '$stockQty' : '0')
            : (inStock ? 'In stock · $stockQty' : 'Out of stock'),
        style: TextStyle(
          color: accent,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

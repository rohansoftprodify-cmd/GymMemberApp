import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_card.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_price_display.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.categoryNames,
    required this.repo,
  });

  final List<Map<String, dynamic>> products;
  final Map<String, String> categoryNames;
  final MemberRepository repo;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final actualPrice = productActualPrice(p);
        final offerPrice = productOfferPrice(p);
        final stock = p['stock_qty'] as int? ?? 0;
        final categoryId = p['category_id'] as String?;
        return ProductCard(
          compact: true,
          name: p['name'] as String? ?? '-',
          description: p['description'] as String?,
          actualPrice: actualPrice,
          offerPrice: offerPrice,
          stockQty: stock,
          categoryName: categoryId == null ? null : categoryNames[categoryId],
          imageUrl: repo.productImageUrl(p['image_path'] as String?),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/features/buy/cart_provider.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_price_display.dart';
import 'package:gym_member_app/src/features/buy/widgets/suggested_product_card.dart';

class SuggestedProductList extends ConsumerWidget {
  const SuggestedProductList({
    super.key,
    required this.products,
    required this.categoryNames,
    required this.repo,
    required this.gymId,
    this.excludeProductIds = const {},
  });

  final List<Map<String, dynamic>> products;
  final Map<String, String> categoryNames;
  final MemberRepository repo;
  final String gymId;
  final Set<String> excludeProductIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);

    final visibleProducts = products
        .where((p) => !excludeProductIds.contains(p['id'] as String))
        .toList();

    if (visibleProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var i = 0; i < visibleProducts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final p = visibleProducts[i];
              final actualPrice = productActualPrice(p);
              final offerPrice = productOfferPrice(p);
              final sellingPrice = productSellingPrice(p);
              final stock = p['stock_qty'] as int? ?? 0;
              final categoryId = p['category_id'] as String?;
              final productId = p['id'] as String;
              final name = p['name'] as String? ?? '-';
              final imageUrl = repo.productImageUrl(p['image_path'] as String?);
              final cartQty = cartState.items[productId]?.qty ?? 0;

              return SuggestedProductCard(
                name: name,
                actualPrice: actualPrice,
                offerPrice: offerPrice,
                stockQty: stock,
                categoryName: categoryId == null ? null : categoryNames[categoryId],
                imageUrl: imageUrl,
                cartQty: cartQty,
                onAdd: stock > 0
                    ? () => cart.addProduct(
                          gymId: gymId,
                          productId: productId,
                          name: name,
                          unitPrice: sellingPrice,
                          stockQty: stock,
                          imageUrl: imageUrl,
                        )
                    : null,
                onSubtract: cartQty > 0
                    ? () {
                        final current = ref.read(cartProvider).items[productId]?.qty ?? 0;
                        if (current > 1) {
                          cart.setQty(productId, current - 1);
                        }
                      }
                    : null,
                onRemove: cartQty > 0 ? () => cart.remove(productId) : null,
              );
            },
          ),
        ],
      ],
    );
  }
}

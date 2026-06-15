import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/buy/cart_provider.dart';
import 'package:gym_member_app/src/features/buy/widgets/cart_item_tile.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_grid.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_price_display.dart';
import 'package:gym_member_app/src/features/buy/widgets/suggested_product_list.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final member = ref.watch(memberContextProvider).valueOrNull;
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final gymId = cart.gymId ?? member?.gymId;
    final repo = ref.read(memberRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: gymId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sign in and open the shop to use your cart.',
                  style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedText),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : cart.isEmpty
              ? _EmptyCartView(theme: theme, semantics: semantics)
              : FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    repo.productCategories(gymId),
                    repo.products(gymId),
                  ]),
                  builder: (context, snap) {
                    final categories = snap.hasData
                        ? snap.data![0] as List<Map<String, dynamic>>
                        : <Map<String, dynamic>>[];
                    final products = snap.hasData
                        ? snap.data![1] as List<Map<String, dynamic>>
                        : <Map<String, dynamic>>[];
                    final categoryNames = {
                      for (final c in categories)
                        c['id'] as String: c['name'] as String? ?? '',
                    };

                    final cartIds = cart.items.keys.toSet();
                    final splits = _splitProducts(
                      products: products,
                      cartProductIds: cartIds,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Products are from your home gym only.',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (final item in cart.items.values) CartItemTile(item: item),
                              if (snap.connectionState == ConnectionState.waiting) ...[
                                const SizedBox(height: 24),
                                const HomeSectionLabel(
                                  title: 'Suggested for you',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                                const SizedBox(height: 10),
                                const ShimmerSuggestedProducts(),
                              ],
                              if (splits.suggested.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const HomeSectionLabel(
                                  title: 'Suggested for you',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                                const SizedBox(height: 10),
                                SuggestedProductList(
                                  products: splits.suggested,
                                  categoryNames: categoryNames,
                                  repo: repo,
                                  gymId: gymId,
                                  excludeProductIds: cartIds,
                                ),
                              ],
                              if (splits.moreItems.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const HomeSectionLabel(
                                  title: 'Add more items',
                                  icon: Icons.shopping_bag_outlined,
                                ),
                                const SizedBox(height: 10),
                                ProductGrid(
                                  products: splits.moreItems,
                                  categoryNames: categoryNames,
                                  repo: repo,
                                  gymId: gymId,
                                  excludeProductIds: cartIds,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          decoration: BoxDecoration(
                            color: semantics.cardBackground,
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${cart.totalQty} item${cart.totalQty == 1 ? '' : 's'}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: semantics.mutedText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${cart.subtotal.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                      EdgeInsetsDirectional.symmetric(vertical: 20),
                                    ),
                                  ),
                                  onPressed: () => context.push('/checkout'),
                                  child: const Text('Proceed to checkout'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({
    required this.theme,
    required this.semantics,
  });

  final ThemeData theme;
  final AppSemanticColors semantics;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: semantics.mutedText),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Add products from your gym shop to checkout.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: semantics.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSplits {
  const _ProductSplits({required this.suggested, required this.moreItems});

  final List<Map<String, dynamic>> suggested;
  final List<Map<String, dynamic>> moreItems;
}

_ProductSplits _splitProducts({
  required List<Map<String, dynamic>> products,
  required Set<String> cartProductIds,
}) {
  final available = products.where((p) {
    final id = p['id'] as String?;
    final stock = p['stock_qty'] as int? ?? 0;
    return id != null && !cartProductIds.contains(id) && stock > 0;
  }).toList();

  final cartCategoryIds = products
      .where((p) => cartProductIds.contains(p['id'] as String?))
      .map((p) => p['category_id'] as String?)
      .whereType<String>()
      .toSet();

  final withOffer = available.where((p) {
    final offer = productOfferPrice(p);
    final actual = productActualPrice(p);
    return offer != null && offer > 0 && offer < actual;
  }).toList();

  final suggested = <Map<String, dynamic>>[];
  final suggestedIds = <String>{};

  void addSuggested(Map<String, dynamic> p) {
    final id = p['id'] as String?;
    if (id == null || suggestedIds.contains(id)) return;
    suggestedIds.add(id);
    suggested.add(p);
  }

  for (final p in available) {
    final categoryId = p['category_id'] as String?;
    if (categoryId != null && cartCategoryIds.contains(categoryId)) {
      addSuggested(p);
      if (suggested.length >= 4) break;
    }
  }

  if (suggested.length < 4) {
    for (final p in withOffer) {
      addSuggested(p);
      if (suggested.length >= 4) break;
    }
  }

  if (suggested.length < 4) {
    for (final p in available) {
      addSuggested(p);
      if (suggested.length >= 4) break;
    }
  }

  final moreItems = available.where((p) => !suggestedIds.contains(p['id'] as String)).toList();

  return _ProductSplits(suggested: suggested, moreItems: moreItems);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/features/buy/cart_provider.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_grid.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_grid_shimmer.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_category_bar.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_empty_state.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class MemberBuyTab extends ConsumerStatefulWidget {
  const MemberBuyTab({super.key, required this.member});

  final MemberContext member;

  @override
  ConsumerState<MemberBuyTab> createState() => _MemberBuyTabState();
}

class _MemberBuyTabState extends ConsumerState<MemberBuyTab> {
  String? _categoryId;
  List<Map<String, dynamic>>? _categories;
  List<Map<String, dynamic>>? _products;
  bool _loadingCategories = true;
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cartProvider.notifier).syncGym(widget.member.gymId);
    });
    _loadCategories();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant MemberBuyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.member.gymId != widget.member.gymId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(cartProvider.notifier).syncGym(widget.member.gymId);
      });
      _loadCategories();
      _loadProducts();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final repo = ref.read(memberRepositoryProvider);
      final categories = await repo.productCategories(widget.member.gymId);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _loadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final repo = ref.read(memberRepositoryProvider);
      final products = await repo.products(
        widget.member.gymId,
        categoryId: _categoryId,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = const [];
        _loadingProducts = false;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadCategories(), _loadProducts()]);
  }

  void _onCategorySelected(String? categoryId) {
    if (_categoryId == categoryId) return;
    setState(() => _categoryId = categoryId);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final repo = ref.read(memberRepositoryProvider);
    final categories = _categories ?? const <Map<String, dynamic>>[];
    final products = _products ?? const <Map<String, dynamic>>[];
    final categoryNames = {
      for (final c in categories) c['id'] as String: c['name'] as String? ?? '',
    };

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            children: [
              const SizedBox(height: 4),
              if (_loadingCategories && categories.isEmpty)
                const ShopCategoryBarShimmer()
              else
                ShopCategoryBar(
                  categories: categories,
                  selectedCategoryId: _categoryId,
                  onCategorySelected: _onCategorySelected,
                ),
              const SizedBox(height: 16),
              HomeSectionLabel(
                title: _categoryId == null ? 'All products' : 'Products',
                icon: Icons.shopping_bag_outlined,
              ),
              if (_loadingProducts)
                const ProductGridShimmer()
              else if (products.isEmpty)
                const ShopEmptyState()
              else
                ProductGrid(
                  products: products,
                  categoryNames: categoryNames,
                  repo: repo,
                  gymId: widget.member.gymId,
                ),
            ],
          ),
        ),
        if (cartCount > 0)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                label: Text('View cart ($cartCount)'),
              ),
            ),
          ),
      ],
    );
  }
}

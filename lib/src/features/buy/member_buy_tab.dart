import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_grid.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_category_bar.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_empty_state.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_header.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class MemberBuyTab extends ConsumerStatefulWidget {
  const MemberBuyTab({super.key, required this.member});

  final MemberContext member;

  @override
  ConsumerState<MemberBuyTab> createState() => _MemberBuyTabState();
}

class _MemberBuyTabState extends ConsumerState<MemberBuyTab> {
  String? _categoryId;
  int _reloadToken = 0;

  void _refresh() => setState(() => _reloadToken++);

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(memberRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
      key: ValueKey('$_categoryId-$_reloadToken'),
      future: Future.wait([
        repo.productCategories(widget.member.gymId),
        repo.products(widget.member.gymId, categoryId: _categoryId),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snap.data![0] as List<Map<String, dynamic>>;
        final products = snap.data![1] as List<Map<String, dynamic>>;
        final categoryNames = {
          for (final c in categories)
            c['id'] as String: c['name'] as String? ?? '',
        };

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            children: [
              ShopHeader(
                gymName: widget.member.gymName,
                productCount: products.length,
              ),
              const SizedBox(height: 16),
              ShopCategoryBar(
                categories: categories,
                selectedCategoryId: _categoryId,
                onCategorySelected: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),
              HomeSectionLabel(
                title: _categoryId == null ? 'All products' : 'Products',
                icon: Icons.shopping_bag_outlined,
              ),
              if (products.isNotEmpty)
                ProductGrid(
                  products: products,
                  categoryNames: categoryNames,
                  repo: repo,
                ),
            ],
          ),
        );
      },
    );
  }
}

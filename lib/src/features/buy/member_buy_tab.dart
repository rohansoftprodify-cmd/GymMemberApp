import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class MemberBuyTab extends ConsumerStatefulWidget {
  const MemberBuyTab({super.key, required this.member});

  final MemberContext member;

  @override
  ConsumerState<MemberBuyTab> createState() => _MemberBuyTabState();
}

class _MemberBuyTabState extends ConsumerState<MemberBuyTab> {
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final repo = ref.read(memberRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
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

        return ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 8),
          children: [
            Text(
              'Shop at the gym',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Browse supplements and gear available at your gym.',
              style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                  for (final c in categories)
                    _CategoryChip(
                      label: c['name'] as String? ?? '-',
                      selected: _categoryId == c['id'],
                      onTap: () => setState(() => _categoryId = c['id'] as String),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No products in this category.',
                    style: theme.textTheme.labelMedium?.copyWith(color: semantics.mutedText),
                  ),
                ),
              )
            else
              ...products.map((p) {
                final price = (p['price'] as num?)?.toDouble() ?? 0;
                final stock = p['stock_qty'] as int? ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: semantics.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String? ?? '-',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if ((p['description'] as String?)?.isNotEmpty == true)
                              Text(
                                p['description'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              stock > 0 ? 'In stock: $stock' : 'Out of stock',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: stock > 0 ? colorScheme.primary : semantics.accentCoral,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? colorScheme.primary : null,
          fontSize: 12,
        ),
      ),
    );
  }
}

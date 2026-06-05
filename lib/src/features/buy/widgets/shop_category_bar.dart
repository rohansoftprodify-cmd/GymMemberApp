import 'package:flutter/material.dart';
import 'package:gym_member_app/src/features/buy/widgets/shop_category_chip.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class ShopCategoryBar extends StatelessWidget {
  const ShopCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionLabel(title: 'Categories', icon: Icons.category_outlined),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ShopCategoryChip(
                label: 'All',
                selected: selectedCategoryId == null,
                onTap: () => onCategorySelected(null),
              ),
              for (final c in categories)
                ShopCategoryChip(
                  label: c['name'] as String? ?? '-',
                  selected: selectedCategoryId == c['id'],
                  onTap: () => onCategorySelected(c['id'] as String),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

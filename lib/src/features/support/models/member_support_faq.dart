class MemberSupportFaqCategory {
  const MemberSupportFaqCategory({
    required this.category,
    required this.categoryLabel,
    required this.sortOrder,
    required this.items,
  });

  final String category;
  final String categoryLabel;
  final int sortOrder;
  final List<MemberSupportFaqItem> items;

  factory MemberSupportFaqCategory.fromMap(Map<String, dynamic> map) {
    final itemsRaw = map['items'];
    final items = <MemberSupportFaqItem>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map) {
          items.add(MemberSupportFaqItem.fromMap(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }

    return MemberSupportFaqCategory(
      category: map['category'] as String? ?? 'general',
      categoryLabel: map['category_label'] as String? ?? 'General',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }
}

class MemberSupportFaqItem {
  const MemberSupportFaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.sortOrder,
  });

  final String id;
  final String question;
  final String answer;
  final int sortOrder;

  factory MemberSupportFaqItem.fromMap(Map<String, dynamic> map) {
    return MemberSupportFaqItem(
      id: map['id']?.toString() ?? '',
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

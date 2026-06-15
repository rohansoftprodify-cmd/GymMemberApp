import 'package:flutter/foundation.dart';

@immutable
class CartItem {
  const CartItem({
    required this.productId,
    required this.gymId,
    required this.name,
    required this.unitPrice,
    required this.qty,
    required this.stockQty,
    this.imageUrl,
  });

  final String productId;
  final String gymId;
  final String name;
  final double unitPrice;
  final int qty;
  final int stockQty;
  final String? imageUrl;

  double get lineTotal => unitPrice * qty;

  CartItem copyWith({int? qty, int? stockQty}) {
    return CartItem(
      productId: productId,
      gymId: gymId,
      name: name,
      unitPrice: unitPrice,
      qty: qty ?? this.qty,
      stockQty: stockQty ?? this.stockQty,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toOrderJson() => {
        'product_id': productId,
        'qty': qty,
      };
}

@immutable
class CartState {
  const CartState({
    this.gymId,
    this.items = const <String, CartItem>{},
  });

  final String? gymId;
  final Map<String, CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQty => items.values.fold(0, (sum, item) => sum + item.qty);

  double get subtotal => items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    String? gymId,
    Map<String, CartItem>? items,
    bool clearGymId = false,
  }) {
    return CartState(
      gymId: clearGymId ? null : gymId ?? this.gymId,
      items: items ?? this.items,
    );
  }
}

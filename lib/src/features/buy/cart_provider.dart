import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/features/buy/models/cart_item.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void syncGym(String gymId) {
    if (state.gymId != null && state.gymId != gymId) {
      state = CartState(gymId: gymId);
      return;
    }
    if (state.gymId == null) {
      state = state.copyWith(gymId: gymId);
    }
  }

  void addProduct({
    required String gymId,
    required String productId,
    required String name,
    required double unitPrice,
    required int stockQty,
    String? imageUrl,
    int qty = 1,
  }) {
    if (stockQty < 1) return;

    if (state.gymId != null && state.gymId != gymId) {
      state = CartState(gymId: gymId);
    } else if (state.gymId == null) {
      state = state.copyWith(gymId: gymId);
    }

    final existing = state.items[productId];
    final nextQty = (existing?.qty ?? 0) + qty;
    final cappedQty = nextQty > stockQty ? stockQty : nextQty;

    final updated = Map<String, CartItem>.from(state.items);
    updated[productId] = CartItem(
      productId: productId,
      gymId: gymId,
      name: name,
      unitPrice: unitPrice,
      qty: cappedQty,
      stockQty: stockQty,
      imageUrl: imageUrl,
    );
    state = state.copyWith(items: updated);
  }

  void setQty(String productId, int qty) {
    final item = state.items[productId];
    if (item == null) return;

    final updated = Map<String, CartItem>.from(state.items);
    if (qty < 1) {
      updated.remove(productId);
    } else {
      updated[productId] = item.copyWith(
        qty: qty > item.stockQty ? item.stockQty : qty,
      );
    }
    state = state.copyWith(items: updated);
  }

  void remove(String productId) {
    if (!state.items.containsKey(productId)) return;
    final updated = Map<String, CartItem>.from(state.items)..remove(productId);
    state = state.copyWith(items: updated);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalQty;
});

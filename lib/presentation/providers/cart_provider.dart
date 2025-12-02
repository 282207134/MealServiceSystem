import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(ProductModel product) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedCart = [...state];
      updatedCart[existingIndex] = updatedCart[existingIndex]
          .copyWith(quantity: updatedCart[existingIndex].quantity + 1);
      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(product: product, quantity: 1),
      ];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedCart = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = updatedCart;
  }

  void clearCart() {
    state = [];
  }

  double getTotal() {
    return state.fold(0, (sum, item) => sum + item.subtotal);
  }

  int getItemCount() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

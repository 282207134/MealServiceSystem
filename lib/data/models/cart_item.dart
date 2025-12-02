import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItem extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

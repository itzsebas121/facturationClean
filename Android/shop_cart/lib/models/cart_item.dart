import 'product.dart';

class CartItem {
  final int? cartId;
  final int? cartItemId;
  final Product product;
  int quantity;

  CartItem({
    this.cartId,
    this.cartItemId,
    required this.product,
    this.quantity = 1,
  });
}

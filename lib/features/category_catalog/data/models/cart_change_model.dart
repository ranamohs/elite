import 'catalog_model.dart';

enum CartOperation { add, decrease, remove }

class CartChangeModel {
  final int productId;
  final int? cartItemId;
  final int quantity;
  final CatalogItem? product;
  final Map<String, dynamic> message;
  const CartChangeModel({
    required this.productId,
    required this.quantity,
    required this.message,
    this.cartItemId,
    this.product,
  });

  factory CartChangeModel.fromJson(
      Map<String, dynamic> json, {
        required int productId,
        bool removed = false,
      }) {
    if (json['status'] != true || (!removed && !json.containsKey('item'))) {
      throw const FormatException('Invalid cart response');
    }
    final message = Map<String, dynamic>.from(json['message'] as Map? ?? {});
    final item = removed ? null : json['item'];
    if (item == null)
      return CartChangeModel(
        productId: productId,
        quantity: 0,
        message: message,
      );
    if (item is! Map || item['quantity'] is! num)
      throw const FormatException('Invalid cart item');
    final quantity = (item['quantity'] as num).toInt();
    if (quantity < 0) throw const FormatException('Invalid cart quantity');
    final product = item['product'] is Map
        ? CatalogItem.fromJson(
      Map<String, dynamic>.from(item['product'] as Map),
      isProduct: true,
    )
        : null;
    if (product != null && product.id != productId)
      throw const FormatException('Mismatched product');
    return CartChangeModel(
      productId: productId,
      quantity: quantity,
      message: message,
      cartItemId: (item['id'] as num?)?.toInt(),
      product: product,
    );
  }
  String localizedMessage(bool ar) =>
      '${message[ar ? 'ar' : 'en'] ?? message[ar ? 'en' : 'ar'] ?? ''}';
}

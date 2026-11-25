import 'catalog_model.dart';

class CartAddModel {
  final int id, quantity;
  final CatalogItem product;
  final Map<String, dynamic> message;
  const CartAddModel({
    required this.id,
    required this.quantity,
    required this.product,
    required this.message,
  });
  factory CartAddModel.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;
    final quantity = (item['quantity'] as num).toInt();
    if (json['status'] != true || quantity < 1) {
      throw const FormatException('Invalid cart response');
    }
    return CartAddModel(
      id: (item['id'] as num).toInt(),
      quantity: quantity,
      product: CatalogItem.fromJson(
        Map<String, dynamic>.from(item['product'] as Map),
        isProduct: true,
      ),
      message: Map<String, dynamic>.from(json['message'] as Map? ?? {}),
    );
  }
  String localizedMessage(bool ar) =>
      '${message[ar ? 'ar' : 'en'] ?? message[ar ? 'en' : 'ar'] ?? ''}';
}

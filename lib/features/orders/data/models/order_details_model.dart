import 'orders_history_model.dart';

class OrderDetailsModel {
  final OrderHistoryItem order;
  final List<OrderDetailsLine> lines;
  final double? price;
  final DateTime? createdAt, updatedAt;
  final int? proposedCount, pendingCount, approvedCount, rejectedCount;
  const OrderDetailsModel({
    required this.order,
    required this.lines,
    this.price,
    this.createdAt,
    this.updatedAt,
    required this.proposedCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });
  factory OrderDetailsModel.fromJson(Map<String, dynamic> response) {
    if (response['status'] != true || response['data'] is! Map)
      throw const FormatException('Invalid order details');
    final data = Map<String, dynamic>.from(response['data'] as Map);
    if (orderInt(data['id']) <= 0)
      throw const FormatException('Missing order ID');
    return OrderDetailsModel(
      order: OrderHistoryItem.fromJson(data),
      lines: (data['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => OrderDetailsLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      price: double.tryParse('${data['price']}'),
      createdAt: DateTime.tryParse('${data['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${data['updated_at'] ?? ''}'),
      proposedCount: int.tryParse('${data['product_proposals_count']}'),
      pendingCount: int.tryParse('${data['pending_products_count']}'),
      approvedCount: int.tryParse('${data['approved_products_count']}'),
      rejectedCount: int.tryParse('${data['rejected_products_count']}'),
    );
  }
}

class OrderDetailsLine {
  final Map<String, dynamic> name, description;
  final List<Map<String, dynamic>> categories;
  final int? quantity;
  final double? unitPrice, totalPrice;
  final String currency;
  const OrderDetailsLine({
    required this.name,
    required this.description,
    required this.categories,
    required this.currency,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });
  String title(bool ar) => localizedOrderText(name, ar);
  String details(bool ar) => localizedOrderText(description, ar)
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  String categoryPath(bool ar) => categories
      .map((e) => localizedOrderText(e, ar))
      .where((e) => e.isNotEmpty)
      .join(' ‹ ');
  factory OrderDetailsLine.fromJson(Map<String, dynamic> json) {
    final item = orderMap(json['item']);
    final category = orderMap(item['category']);
    final subcategory = orderMap(category['subcategory']);
    final main = orderMap(subcategory['maincategory']);
    return OrderDetailsLine(
      name: orderMap(item['name']),
      description: orderMap(item['description']),
      categories: [
        orderMap(main['name']),
        orderMap(subcategory['name']),
        orderMap(category['name']),
      ],
      quantity: int.tryParse('${json['quantity']}'),
      unitPrice: double.tryParse('${json['unit_price']}'),
      totalPrice: double.tryParse('${json['total_price']}'),
      currency: OrderHistoryLine.fromJson(json).currency,
    );
  }
}

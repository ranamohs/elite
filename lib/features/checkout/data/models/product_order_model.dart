class ProductOrderModel {
  final int orderId;
  final double? total;
  final Map<String, dynamic> message;
  const ProductOrderModel({
    required this.orderId,
    this.total,
    required this.message,
  });
  factory ProductOrderModel.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['order_id']}'),
        total = double.tryParse('${json['total']}');
    if (json['status'] != true || id == null || id <= 0)
      throw const FormatException('Invalid product order');
    return ProductOrderModel(
      orderId: id,
      total: total != null && total.isFinite ? total : null,
      message: json['message'] is Map
          ? Map<String, dynamic>.from(json['message'])
          : {},
    );
  }
  String text(bool ar) =>
      '${message[ar ? 'ar' : 'en'] ?? message[ar ? 'en' : 'ar'] ?? ''}';
}

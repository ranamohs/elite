class OrderInvoiceModel {
  final int id, orderId;
  final double? total, paid, remaining;
  final String status;
  final DateTime? createdAt;
  final String? receiptUrl;
  const OrderInvoiceModel({
    required this.id,
    required this.orderId,
    this.total,
    this.paid,
    this.remaining,
    required this.status,
    this.createdAt,
    this.receiptUrl,
  });
  factory OrderInvoiceModel.fromJson(Map<String, dynamic> response) {
    if (response['status'] != true || response['invoice'] is! Map)
      throw const FormatException('Invalid invoice');
    final json = Map<String, dynamic>.from(response['invoice'] as Map);
    final id = int.tryParse('${json['id']}'),
        orderId = int.tryParse('${json['order_id']}');
    if (id == null || id <= 0 || orderId == null || orderId <= 0)
      throw const FormatException('Invalid invoice IDs');
    double? number(dynamic raw) {
      final value = double.tryParse('$raw');
      return value != null && value.isFinite ? value : null;
    }

    final url = json['deposit_receipt_url'];
    return OrderInvoiceModel(
      id: id,
      orderId: orderId,
      total: number(json['total']),
      paid: number(json['paid']),
      remaining: number(json['remaining']),
      status: '${json['status'] ?? ''}',
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      receiptUrl: url is String && url.trim().isNotEmpty ? url.trim() : null,
    );
  }
}

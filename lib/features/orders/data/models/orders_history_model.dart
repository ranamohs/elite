class OrderHistoryItem {
  final int id;
  final String code, statusValue, statusLabel;
  final List<OrderHistoryLine> items;
  final Map<String, dynamic> fallbackName;
  final double price;
  final bool hasInvoice;
  final DateTime? date;
  const OrderHistoryItem({
    required this.id,
    required this.code,
    required this.statusValue,
    required this.statusLabel,
    required this.items,
    required this.price,
    required this.hasInvoice,
    required this.fallbackName,
    this.date,
  });

  bool get isPrevious => const {
    'completed',
    'complete',
    'finished',
    'closed',
    'cancelled',
    'canceled',
    'rejected',
    'delivered',
  }.contains(statusValue.toLowerCase());
  bool get isCancelled => const {
    'cancelled',
    'canceled',
    'rejected',
  }.contains(statusValue.toLowerCase());
  bool get awaitingPrice => !isCancelled && !hasInvoice && price == 0;
  String title(bool ar) {
    final names = items
        .map((e) => e.name(ar))
        .where((e) => e.isNotEmpty)
        .toList();
    if (names.isNotEmpty) return names.join(' + ');
    return localizedOrderText(fallbackName, ar);
  }

  String get currency {
    for (final item in items) {
      if (item.currency.isNotEmpty) return item.currency;
    }
    return '';
  }

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final nameSource = json['product'] ?? json['category'];
    return OrderHistoryItem(
      id: orderInt(json['id']),
      code: '${json['code'] ?? json['id'] ?? ''}',
      statusValue: status is Map
          ? '${status['value'] ?? ''}'
          : '${status ?? ''}',
      statusLabel: status is Map
          ? '${status['label'] ?? ''}'
          : '${status ?? ''}',
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => OrderHistoryLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      fallbackName: nameSource is Map ? orderMap(nameSource['name']) : {},
      price: orderDouble(json['price']),
      hasInvoice: json['has_invoice'] == true || json['has_invoice'] == 1,
      date: DateTime.tryParse('${json['date'] ?? json['created_at'] ?? ''}'),
    );
  }
}

class OrderHistoryLine {
  final int id, quantity;
  final String type, currency;
  final Map<String, dynamic> localizedName;
  final double unitPrice, totalPrice;
  const OrderHistoryLine({
    required this.id,
    required this.quantity,
    required this.type,
    required this.localizedName,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
  });
  String name(bool ar) => localizedOrderText(localizedName, ar);
  factory OrderHistoryLine.fromJson(Map<String, dynamic> json) {
    final item = orderMap(json['item']);
    final price = orderMap(item['price']);
    final label = price['label'];
    return OrderHistoryLine(
      id: orderInt(json['id']),
      quantity: orderInt(json['quantity']),
      type: '${json['type'] ?? ''}',
      localizedName: orderMap(item['name']),
      unitPrice: orderDouble(json['unit_price']),
      totalPrice: orderDouble(json['total_price']),
      currency: label is Map
          ? '${label['currency'] ?? ''}'
          : '${label ?? ''}'.replaceFirst(RegExp(r'^[\d.,\s]+'), '').trim(),
    );
  }
}

class OrdersHistoryModel {
  final List<OrderHistoryItem> orders;
  final int currentPage, lastPage;
  const OrdersHistoryModel({
    required this.orders,
    this.currentPage = 1,
    this.lastPage = 1,
  });
  factory OrdersHistoryModel.fromJson(Map<String, dynamic> json) {
    final meta = orderMap(json['meta']);
    return OrdersHistoryModel(
      orders: (json['data'] as List)
          .map(
            (e) =>
            OrderHistoryItem.fromJson(Map<String, dynamic>.from(e as Map)),
      )
          .toList(),
      currentPage: orderInt(meta['current_page'], 1),
      lastPage: orderInt(meta['last_page'], 1),
    );
  }
}

Map<String, dynamic> orderMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
int orderInt(dynamic value, [int fallback = 0]) =>
    int.tryParse('$value') ?? fallback;
double orderDouble(dynamic value) => double.tryParse('$value') ?? 0;
String localizedOrderText(Map<String, dynamic> value, bool ar) =>
    '${value[ar ? 'ar' : 'en'] ?? value[ar ? 'en' : 'ar'] ?? ''}';

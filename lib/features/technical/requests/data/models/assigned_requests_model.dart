class AssignedRequestStats {
  final int? total, canceled, completed, pending;
  const AssignedRequestStats({
    this.total,
    this.canceled,
    this.completed,
    this.pending,
  });
  factory AssignedRequestStats.fromJson(Map<String, dynamic> json) =>
      AssignedRequestStats(
        total: assignedInt(json['total']),
        canceled: assignedInt(json['canceled']),
        completed: assignedInt(json['completed']),
        pending: assignedInt(json['pending']),
      );
}

class AssignedProduct {
  final int? id, quantity;
  final Map<String, dynamic> name;
  final String type;
  final double? unitPrice, totalPrice;
  final String? image;
  const AssignedProduct({
    this.id,
    this.quantity,
    required this.name,
    required this.type,
    this.unitPrice,
    this.totalPrice,
    this.image,
  });
  String title(bool ar) =>
      '${name[ar ? 'ar' : 'en'] ?? name[ar ? 'en' : 'ar'] ?? ''}';
  factory AssignedProduct.fromJson(Map<String, dynamic> json) =>
      AssignedProduct(
        id: assignedInt(json['id']),
        quantity: assignedInt(json['quantity']),
        name: assignedMap(json['name']),
        type: '${json['type'] ?? ''}',
        unitPrice: assignedDouble(json['unit_price']),
        totalPrice: assignedDouble(json['total_price']),
        image: json['image']?.toString(),
      );
}

class AssignedRequest {
  final int id;
  final String code, statusValue, statusLabel;
  final List<AssignedProduct> products;
  final String? createdAt,
      customerDate,
      address,
      customerName,
      customerPhone,
      notes;
  final double? latitude, longitude;
  final bool hasInvoice;
  const AssignedRequest({
    required this.id,
    required this.code,
    required this.statusValue,
    required this.statusLabel,
    required this.products,
    this.createdAt,
    this.customerDate,
    this.address,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.latitude,
    this.longitude,
    required this.hasInvoice,
  });
  bool get isClosed => const {
    'completed',
    'complete',
    'finished',
    'closed',
    'canceled',
    'cancelled',
    'rejected',
  }.contains(statusValue.toLowerCase());
  bool get isCanceled => const {
    'canceled',
    'cancelled',
    'rejected',
  }.contains(statusValue.toLowerCase());
  String title(bool ar) => products
      .map((e) => e.title(ar))
      .where((e) => e.trim().isNotEmpty)
      .join(' + ');
  double? get itemsTotal =>
      products.isEmpty || products.any((e) => e.totalPrice == null)
          ? null
          : products.fold<double>(0, (sum, e) => sum + e.totalPrice!);
  bool get hasLocation =>
      latitude != null &&
          longitude != null &&
          latitude!.isFinite &&
          longitude!.isFinite &&
          latitude! >= -90 &&
          latitude! <= 90 &&
          longitude! >= -180 &&
          longitude! <= 180;
  factory AssignedRequest.fromJson(Map<String, dynamic> json) {
    final status = assignedMap(json['status']);
    final customer = assignedMap(json['customer']);
    final id = assignedInt(json['id']);
    if (id == null || id <= 0)
      throw const FormatException('Invalid assigned request');
    return AssignedRequest(
      id: id,
      code: '${json['code'] ?? id}',
      statusValue: '${status['value'] ?? ''}',
      statusLabel: '${status['label'] ?? ''}',
      products: (json['products'] as List? ?? [])
          .whereType<Map>()
          .map((e) => AssignedProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString(),
      customerDate: json['customer_date']?.toString(),
      address: json['address']?.toString(),
      customerName: customer['name']?.toString(),
      customerPhone: customer['phone']?.toString(),
      notes: json['customer_notes']?.toString(),
      latitude: assignedDouble(json['latitude']),
      longitude: assignedDouble(json['longitude']),
      hasInvoice: json['has_invoice'] == true,
    );
  }
}

class AssignedRequestsModel {
  final AssignedRequestStats? stats;
  final List<AssignedRequest> requests;
  final int currentPage;
  final int? lastPage;
  final String? next;
  const AssignedRequestsModel({
    this.stats,
    required this.requests,
    this.currentPage = 1,
    this.lastPage,
    this.next,
  });
  bool get hasMore =>
      (next?.isNotEmpty == true) ||
          (lastPage != null && currentPage < lastPage!);
  factory AssignedRequestsModel.fromJson(
      Map<String, dynamic> json, {
        int page = 1,
      }) {
    if (json['status'] != true || json['data'] is! List)
      throw const FormatException('Invalid assigned requests response');
    final meta = assignedMap(json['meta']);
    final links = assignedMap(json['links']);
    return AssignedRequestsModel(
      stats: json['stats'] is Map
          ? AssignedRequestStats.fromJson(assignedMap(json['stats']))
          : null,
      requests: (json['data'] as List)
          .map(
            (e) =>
            AssignedRequest.fromJson(Map<String, dynamic>.from(e as Map)),
      )
          .toList(),
      currentPage: assignedInt(meta['current_page']) ?? page,
      lastPage: assignedInt(meta['last_page']),
      next: links['next']?.toString(),
    );
  }
}

Map<String, dynamic> assignedMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
int? assignedInt(dynamic value) => int.tryParse('$value');
double? assignedDouble(dynamic value) => double.tryParse('$value');

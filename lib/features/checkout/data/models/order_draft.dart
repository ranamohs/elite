import '../../../category_catalog/data/models/catalog_model.dart';

class OrderAddress {
  final double? latitude, longitude;
  final String area, street, building, floor, apartment, label;
  const OrderAddress({
    this.latitude,
    this.longitude,
    required this.area,
    required this.street,
    required this.building,
    required this.floor,
    required this.apartment,
    required this.label,
  });
  String get details => '$area، $street، $building، $floor، $apartment';
}

class OrderDraft {
  int? orderId;
  bool isSubmitting = false;
  final List<CatalogItem> items;
  final Map<String, int> quantities;
  String description = '';
  List<String> photos = [];
  OrderAddress? address;
  DateTime? day;
  int? timeMinutes;
  DateTime? get appointment {
    final date = day;
    final minutes = timeMinutes;
    if (date == null || minutes == null || minutes < 0 || minutes >= 24 * 60)
      return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  String paymentMethod = 'cash';
  int rating = 0;
  String review = '';
  OrderDraft({
    required List<CatalogItem> items,
    required Map<String, int> quantities,
  }) : items = List.unmodifiable(items),
        quantities = Map.unmodifiable(quantities);
  double get subtotal => items.fold(
    0,
        (sum, item) => sum + item.price * (quantities[item.key] ?? 0),
  );
  String get currency {
    final values = items
        .map((e) => e.currency)
        .where((e) => e.isNotEmpty)
        .toSet();
    return values.length == 1 ? values.first : '';
  }

  String money(double value) => '${value.toStringAsFixed(3)} $currency'.trim();
}

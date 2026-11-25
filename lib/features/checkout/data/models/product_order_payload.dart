import 'order_draft.dart';

class ProductOrderPayload {
  final Map<String, dynamic> fields;
  final List<String> photos;
  final String? receipt;
  const ProductOrderPayload({
    required this.fields,
    required this.photos,
    this.receipt,
  });
  factory ProductOrderPayload.fromOrder(OrderDraft order) {
    if (order.items.length != 1 ||
        order.items.any((e) => !e.isProduct) ||
        order.items.any((e) => (order.quantities[e.key] ?? 0) <= 0)) {
      throw const FormatException('اختار منتجات لإكمال الطلب');
    }
    final id = order.cartId, address = order.address;
    if (id == null || id <= 0) {
      throw const FormatException(
        'تعذر تحديد السلة، أعد تحميل السلة وحاول مرة أخرى',
      );
    }
    final lat = address?.latitude, lng = address?.longitude;
    if (address == null ||
        address.details.trim().isEmpty ||
        lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      throw const FormatException('حدد عنوان الطلب وموقعه على الخريطة');
    }
    return ProductOrderPayload(
      fields: {
        'cart_id': id,
        'address': address.details,
        'latitude': lat,
        'longitude': lng,
      },
      photos: List.unmodifiable(order.photos),
      receipt: order.depositReceiptPath,
    );
  }
}

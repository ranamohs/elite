import 'package:elite/features/checkout/data/models/service_request_model.dart';
import 'package:elite/features/checkout/data/models/service_request_payload.dart';

import '../../../category_catalog/data/models/cart_add_model.dart';
import '../../../category_catalog/data/models/catalog_model.dart';
import 'order_draft.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void rejects(void Function() action, String message) {
  try {
    action();
  } on FormatException {
    return;
  }
  throw StateError(message);
}

void main() {
  final cart = CartAddModel.fromJson({
    'status': true,
    'message': {'ar': 'تمت الإضافة', 'en': 'Added'},
    'item': {
      'id': 8,
      'quantity': 2,
      'product': {
        'id': 1,
        'name': {'ar': 'سخان', 'en': 'Heater'},
        'price': {
          'label': {'original': '600', 'currency': 'ر.ع'},
          'value': 600,
        },
        'stock': 500,
        'image': '/media/heater.webp',
      },
    },
  });
  check(
    cart.id == 8 && cart.product.id == 1 && cart.quantity == 2,
    'Use cart item ID separately from product ID and server quantity',
  );
  check(
    cart.product.price == 600 && cart.product.isProduct,
    'Parse returned product',
  );
  check(
    cart.localizedMessage(false) == 'Added' &&
        cart.localizedMessage(true) == 'تمت الإضافة',
    'Localized cart message',
  );
  final service = CatalogItem.fromJson({
    'id': 4,
    'name': {'ar': 'تركيب'},
    'price': {'value': '600', 'label': '600 ر.ع'},
  }, isProduct: false);
  final order = OrderDraft(
    items: [service, cart.product],
    quantities: {service.key: 1, cart.product.key: 2},
  );
  order.day = DateTime(2099, 6, 6);
  order.timeMinutes = 14 * 60;
  order.description = 'تسريب';
  order.address = const OrderAddress(
    latitude: 30.1,
    longitude: 31.2,
    area: 'المعادي',
    street: '9',
    building: '12',
    floor: '3',
    apartment: '5',
    label: 'البيت',
  );
  order.photos = ['photo.png'];
  final payload = ServiceRequestPayload.fromOrder(order);
  check(
    payload.serviceId == 4 && payload.fields['date'] == '2099-06-06 14:00',
    'Service ID and required date format',
  );
  check(
    payload.fields['notes'] == 'تسريب' &&
        payload.fields['latitude'] == 30.1 &&
        payload.fields['longitude'] == 31.2 &&
        payload.fields['address'] == order.address!.details,
    'Pass actual notes and address coordinates',
  );
  check(
    !payload.fields.containsKey('product_id') &&
        !payload.fields.containsKey('quantity'),
    'Products are added to cart separately',
  );
  order.photos.clear();
  check(payload.photos.single == 'photo.png', 'Snapshot attachment paths');
  final invalid = OrderDraft(items: [service], quantities: {service.key: 2})
    ..day = DateTime(2099)
    ..timeMinutes = 10 * 60;
  rejects(
        () => ServiceRequestPayload.fromOrder(invalid),
    'Reject service quantity greater than one',
  );
  rejects(
        () => ServiceRequestPayload.fromOrder(
      OrderDraft(items: [service], quantities: {service.key: 1}),
    ),
    'Reject missing appointment',
  );
  final twoServices =
  OrderDraft(items: [service, service], quantities: {service.key: 1})
    ..day = DateTime(2099)
    ..timeMinutes = 10 * 60;
  rejects(
        () => ServiceRequestPayload.fromOrder(twoServices),
    'Reject multiple services',
  );
  final productOnly =
  OrderDraft(items: [cart.product], quantities: {cart.product.key: 2})
    ..day = DateTime(2099)
    ..timeMinutes = 10 * 60;
  rejects(
        () => ServiceRequestPayload.fromOrder(productOnly),
    'Do not request a service for product-only checkout',
  );
  final result = ServiceRequestModel.fromJson({
    'status': true,
    'order_id': 7,
    'message': {'ar': 'تم', 'en': 'Created'},
  });
  check(
    result.orderId == 7 && result.localizedMessage(false) == 'Created',
    'Parse order ID and localized response',
  );
  rejects(
        () => ServiceRequestModel.fromJson({'status': false, 'order_id': 7}),
    'Do not treat failed requests as created',
  );
  order.description = 'a' * 501;
  rejects(
        () => ServiceRequestPayload.fromOrder(order),
    'Enforce API notes limit',
  );
  print('Passed 14 catalog API model and payload checks.');
}

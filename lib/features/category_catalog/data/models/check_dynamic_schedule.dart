import '../../../checkout/data/models/order_draft.dart';
import '../../../checkout/data/models/service_request_payload.dart';
import 'catalog_model.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void rejects(OrderDraft order) {
  try {
    ServiceRequestPayload.fromOrder(order);
  } on FormatException {
    return;
  }
  throw StateError('An invalid or past appointment was accepted');
}

void main() {
  final service = CatalogItem.fromJson({
    'id': 4,
    'name': {'ar': 'تركيب'},
  }, isProduct: false);
  final order = OrderDraft(items: [service], quantities: {service.key: 1})
    ..day = DateTime(2099, 6, 6);
  order.timeMinutes = 7 * 60 + 35;
  check(
    ServiceRequestPayload.fromOrder(order).fields['date'] == '2099-06-06 07:35',
    'Use exact user-selected hour and minute',
  );
  order.timeMinutes = 5;
  check(
    ServiceRequestPayload.fromOrder(order).fields['date'] == '2099-06-06 00:05',
    'Format midnight and pad minutes',
  );
  order.timeMinutes = 23 * 60 + 59;
  check(
    ServiceRequestPayload.fromOrder(order).fields['date'] == '2099-06-06 23:59',
    'Use 24-hour API format',
  );
  order.timeMinutes = null;
  rejects(order);
  order.timeMinutes = -1;
  rejects(order);
  order.timeMinutes = 24 * 60;
  rejects(order);
  order.day = DateTime(2000, 1, 1);
  order.timeMinutes = 12 * 60;
  rejects(order);
  print('Passed 7 dynamic schedule checks.');
}

import '../../../category_catalog/data/models/catalog_model.dart';

import 'order_draft.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void main() {
  final service = CatalogItem.fromJson({
    'id': 4,
    'name': {'ar': 'تركيب'},
    'price': {'label': '600.000 ر.ع', 'value': '600.000'},
  }, isProduct: false);
  final product = CatalogItem.fromJson({
    'id': 4,
    'name': {'ar': 'سخان'},
    'price': {
      'label': {'original': '150', 'currency': 'ر.ع'},
      'value': 150,
    },
  }, isProduct: true);
  final items = [service, product];
  final quantities = {service.key: 2, product.key: 1};
  final draft = OrderDraft(items: items, quantities: quantities);
  check(
    draft.subtotal == 1350,
    'Total must include product and service quantities',
  );
  check(
    draft.money(draft.subtotal) == '1350.000 ر.ع',
    'Use actual API currency',
  );
  items.clear();
  quantities.clear();
  check(
    draft.items.length == 2 && draft.subtotal == 1350,
    'Copy catalog selections into checkout',
  );
  check(
    draft.address == null && draft.day == null && draft.timeSlot == null,
    'Do not invent address or schedule',
  );
  draft.address = const OrderAddress(
    latitude: 29.9602,
    longitude: 31.2569,
    area: 'المعادي',
    street: 'شارع 9',
    building: '12',
    floor: '3',
    apartment: '5',
    label: 'البيت',
  );
  check(
    draft.address!.details == 'المعادي، شارع 9، 12، 3، 5',
    'Address preserves entered fields',
  );
  draft.day = DateTime(2026, 11, 13);
  draft.timeSlot = 1;
  draft.paymentMethod = 'wallet';
  check(
    draft.day!.day == 13 &&
        draft.timeSlot == 1 &&
        draft.paymentMethod == 'wallet',
    'Preserve schedule and payment method',
  );
  check(
    draft.address!.latitude == 29.9602 && draft.address!.longitude == 31.2569,
    'Preserve selected map coordinates',
  );
  print('Passed 7 order draft checks.');
}

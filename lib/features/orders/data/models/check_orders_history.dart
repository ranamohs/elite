import 'dart:convert';
import 'dart:io';
import 'orders_history_model.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void main() {
  final fixture = File.fromUri(
    Platform.script.resolve('fixtures/orders_history.json.json'),
  );
  final history = OrdersHistoryModel.fromJson(
    jsonDecode(fixture.readAsStringSync()) as Map<String, dynamic>,
  );
  check(
    history.orders.length == 4 && history.orders.first.id == 8,
    'Parse the supplied history response',
  );
  check(
    history.currentPage == 1 && history.lastPage == 1,
    'Read API pagination',
  );
  check(
    history.orders.every((order) => !order.isPrevious),
    'New orders belong to current orders',
  );
  final order = history.orders.first;
  check(
    order.title(true) == 'تركيب سخان بدون مواسير' &&
        order.title(false) == 'Installing a tankless water heater',
    'Use actual localized item names',
  );
  check(
    order.date == null && order.code == '8',
    'Preserve missing dates and real order codes',
  );
  check(
    order.price == 0 && order.awaitingPrice,
    'Do not substitute line price for a missing invoice price',
  );
  check(
    order.items.single.unitPrice == 600 &&
        order.items.single.quantity == 1 &&
        order.currency == 'ر.ع',
    'Parse item prices and API currency',
  );
  final completed = OrderHistoryItem.fromJson({
    'id': 1,
    'items': [],
    'status': {'value': 'completed', 'label': 'مكتمل'},
    'has_invoice': true,
    'price': '320.5',
    'created_at': '2026-11-15T10:00:00Z',
  });
  check(
    completed.isPrevious &&
        !completed.isCancelled &&
        completed.price == 320.5 &&
        completed.date!.isUtc,
    'Completed orders are previous and preserve prices/dates',
  );
  final cancelled = OrderHistoryItem.fromJson({
    'id': 2,
    'status': {'value': 'cancelled'},
  });
  check(
    cancelled.isPrevious && cancelled.isCancelled,
    'Cancelled orders are previous',
  );
  final unknown = OrderHistoryItem.fromJson({
    'id': 3,
    'status': {'value': 'custom_status', 'label': 'بانتظار الموافقة'},
    'category': {
      'name': {'ar': 'صيانة'},
    },
  });
  check(
    !unknown.isPrevious &&
        unknown.statusLabel == 'بانتظار الموافقة' &&
        unknown.title(true) == 'صيانة',
    'Unknown statuses preserve backend label and category fallback',
  );
  final free = OrderHistoryItem.fromJson({
    'id': 4,
    'has_invoice': true,
    'price': 0,
  });
  check(
    !free.awaitingPrice && free.price == 0,
    'An actual zero-price invoice is not an unknown price',
  );
  final empty = OrdersHistoryModel.fromJson({
    'data': [],
    'meta': {'current_page': 2, 'last_page': 3},
  });
  check(
    empty.orders.isEmpty && empty.currentPage == 2 && empty.lastPage == 3,
    'Handle empty and paginated responses',
  );
  print(
    'Passed 12 order-history model checks, including the supplied API fixture.',
  );
}

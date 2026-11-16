import 'order_draft.dart';

class ServiceRequestPayload {
  final int serviceId;
  final Map<String, dynamic> fields;
  final List<String> photos;
  const ServiceRequestPayload({
    required this.serviceId,
    required this.fields,
    required this.photos,
  });
  factory ServiceRequestPayload.fromOrder(OrderDraft order) {
    final services = order.items.where((e) => !e.isProduct).toList();
    final appointment = order.appointment;
    if (services.length != 1 ||
        order.quantities[services.single.key] != 1 ||
        appointment == null ||
        !appointment.isAfter(DateTime.now())) {
      throw const FormatException('invalidServiceSelection');
    }
    if (order.description.length > 500 ||
        (order.address?.details.length ?? 0) > 255) {
      throw const FormatException('orderDetailsTooLong');
    }
    String pad(int value) => value.toString().padLeft(2, '0');
    return ServiceRequestPayload(
      serviceId: services.single.id,
      fields: {
        'date':
        '${appointment.year}-${pad(appointment.month)}-${pad(appointment.day)} ${pad(appointment.hour)}:${pad(appointment.minute)}',
        if (order.description.trim().isNotEmpty)
          'notes': order.description.trim(),
        if (order.address != null) 'address': order.address!.details,
        if (order.address?.latitude != null)
          'latitude': order.address!.latitude,
        if (order.address?.longitude != null)
          'longitude': order.address!.longitude,
      },
      photos: List.unmodifiable(order.photos),
    );
  }
}

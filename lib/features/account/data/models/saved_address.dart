import '../../../checkout/data/models/order_draft.dart';

class SavedAddress {
  final String id;
  final OrderAddress address;
  final bool isDefault;
  const SavedAddress({
    required this.id,
    required this.address,
    this.isDefault = false,
  });
  SavedAddress asDefault(bool value) =>
      SavedAddress(id: id, address: address, isDefault: value);
  Map<String, dynamic> toJson() => {
    'id': id,
    'default': isDefault,
    'area': address.area,
    'street': address.street,
    'building': address.building,
    'floor': address.floor,
    'apartment': address.apartment,
    'label': address.label,
    'latitude': address.latitude,
    'longitude': address.longitude,
  };
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String,
    isDefault: json['default'] == true,
    address: OrderAddress(
      area: '${json['area'] ?? ''}',
      street: '${json['street'] ?? ''}',
      building: '${json['building'] ?? ''}',
      floor: '${json['floor'] ?? ''}',
      apartment: '${json['apartment'] ?? ''}',
      label: '${json['label'] ?? ''}',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    ),
  );
}

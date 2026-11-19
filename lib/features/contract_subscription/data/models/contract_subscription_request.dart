class ContractSubscriptionRequest {
  final int contractId;
  final String imagePath, address;
  final double latitude, longitude;
  const ContractSubscriptionRequest({
    required this.contractId,
    required this.imagePath,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
  bool get isValid =>
      contractId > 0 &&
          imagePath.trim().isNotEmpty &&
          address.trim().isNotEmpty &&
          latitude.isFinite &&
          longitude.isFinite &&
          latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180;
  Map<String, dynamic> get fields => {
    'contract_id': contractId,
    'latitude': latitude,
    'longitude': longitude,
    'address': address.trim(),
  };
}

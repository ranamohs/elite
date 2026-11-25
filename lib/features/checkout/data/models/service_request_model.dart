class ServiceRequestModel {
  final int orderId;
  final Map<String, dynamic> message;
  const ServiceRequestModel({required this.orderId, required this.message});
  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final id = (json['order_id'] as num).toInt();
    if (json['status'] != true || id <= 0) {
      throw const FormatException('Invalid service order response');
    }
    return ServiceRequestModel(
      orderId: id,
      message: Map<String, dynamic>.from(json['message'] as Map? ?? {}),
    );
  }
  String localizedMessage(bool ar) =>
      '${message[ar ? 'ar' : 'en'] ?? message[ar ? 'en' : 'ar'] ?? ''}';
}

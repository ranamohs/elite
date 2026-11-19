import '../../../home/data/models/contracts_models/maintenance_contracts_model.dart';

class ContractSubscriptionModel {
  final int id;
  final String status;
  final DateTime? startDate, endDate;
  final MaintenanceContract contract;
  final ContractLocalizedText message;
  const ContractSubscriptionModel({
    required this.id,
    required this.status,
    required this.contract,
    required this.message,
    this.startDate,
    this.endDate,
  });
  factory ContractSubscriptionModel.fromJson(Map<String, dynamic> json) {
    if (json['status'] != true || json['data'] is! Map)
      throw const FormatException('Invalid subscription response');
    final data = Map<String, dynamic>.from(json['data'] as Map);
    final id = int.tryParse('${data['id']}');
    if (id == null || id <= 0 || data['maintenance_contracts'] is! Map)
      throw const FormatException('Missing subscription data');
    return ContractSubscriptionModel(
      id: id,
      status: '${data['status'] ?? ''}',
      startDate: DateTime.tryParse('${data['start_date'] ?? ''}'),
      endDate: DateTime.tryParse('${data['end_date'] ?? ''}'),
      contract: MaintenanceContract.fromJson(
        Map<String, dynamic>.from(data['maintenance_contracts'] as Map),
      ),
      message: ContractLocalizedText.fromJson(
        Map<String, dynamic>.from(json['message'] as Map? ?? {}),
      ),
    );
  }
}

import '../../../../../core/constants/end_points.dart';
import 'maintenance_contracts_model.dart';

class MaintenanceContractDetailsModel {
  final bool status;
  final ContractLocalizedText message;
  final MaintenanceContract data;

  MaintenanceContractDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MaintenanceContractDetailsModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceContractDetailsModel(
      status: json[ApiKey.status] ?? true,
      message: json[ApiKey.message] != null
          ? ContractLocalizedText.fromJson(json[ApiKey.message])
          : ContractLocalizedText(ar: '', en: ''),
      data: MaintenanceContract.fromJson(
        Map<String, dynamic>.from(json[ApiKey.data] as Map),
      ),
    );
  }
}

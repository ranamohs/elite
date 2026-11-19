import '../../../home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'contract_subscription_model.dart';

class ContractSubscriptionResult {
  final ContractSubscriptionModel? subscription;
  final ContractLocalizedText message;
  const ContractSubscriptionResult({required this.message, this.subscription});

  factory ContractSubscriptionResult.fromJson(Map<String, dynamic> json) {
    if (json['status'] != true)
      throw const FormatException('Subscription was not accepted');
    final rawMessage = json['message'];
    final message = rawMessage is Map
        ? ContractLocalizedText.fromJson(Map<String, dynamic>.from(rawMessage))
        : ContractLocalizedText(
      ar: rawMessage?.toString() ?? '',
      en: rawMessage?.toString() ?? '',
    );
    if (json['data'] is Map) {
      return ContractSubscriptionResult(
        message: message,
        subscription: ContractSubscriptionModel.fromJson(json),
      );
    }
    if (json['data'] == null &&
        (message.ar.trim().isNotEmpty || message.en.trim().isNotEmpty)) {
      // The API may confirm an existing subscription without returning its details.
      return ContractSubscriptionResult(message: message);
    }
    throw const FormatException('Invalid subscription response');
  }
  String localizedMessage(bool ar) =>
      (ar ? message.ar : message.en).trim().isNotEmpty
          ? (ar ? message.ar : message.en)
          : (ar ? message.en : message.ar);
}
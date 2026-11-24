import 'deposit_receipt.dart';

class NewPaymentRequest {
  final double amount;
  final List<int> serviceIds;
  final String notes, accountType;
  final DepositReceipt receipt;
  NewPaymentRequest({
    required this.amount,
    required List<int> serviceIds,
    required this.notes,
    required this.accountType,
    required this.receipt,
  }) : serviceIds = List.unmodifiable(serviceIds.toSet()) {
    if (!amount.isFinite ||
        amount <= 0 ||
        double.parse(amount.toStringAsFixed(2)) <= 0)
      throw const FormatException('Invalid payment amount');
    if (serviceIds.any((id) => id <= 0))
      throw const FormatException('Invalid service ID');
    if (!const {
      'cash',
      'employee_transfer',
      'company_transfer',
    }.contains(accountType))
      throw const FormatException('Invalid account type');
  }
  Map<String, String> get fields => {
    'amount': amount.toStringAsFixed(2),
    'deposit_account_type': accountType,
    if (notes.trim().isNotEmpty) 'notes': notes.trim(),
  };
}

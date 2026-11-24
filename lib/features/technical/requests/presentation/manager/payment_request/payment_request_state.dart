part of 'payment_request_cubit.dart';

@immutable

class PaymentRequestState {
  final bool loading, sent;
  final String? error, message;
  const PaymentRequestState({
    this.loading = false,
    this.sent = false,
    this.error,
    this.message,
  });
}


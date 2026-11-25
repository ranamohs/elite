part of 'order_invoice_cubit.dart';

@immutable
class OrderInvoiceState {
  final bool loading;
  final OrderInvoiceModel? invoice;
  final String? error;
  const OrderInvoiceState({this.loading = false, this.invoice, this.error});
}
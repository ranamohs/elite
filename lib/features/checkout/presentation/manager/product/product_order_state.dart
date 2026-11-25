part of 'product_order_cubit.dart';

@immutable
class ProductOrderState {
  final bool loading;
  final ProductOrderModel? result;
  final String? error;
  const ProductOrderState({this.loading = false, this.result, this.error});
}
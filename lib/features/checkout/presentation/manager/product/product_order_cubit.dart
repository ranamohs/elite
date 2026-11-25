import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/order_draft.dart';
import '../../../data/models/product_order_model.dart';
import '../../../data/models/product_order_payload.dart';
import '../../../data/repos/product_order_repo.dart';

part 'product_order_state.dart';

class ProductOrderCubit extends Cubit<ProductOrderState> {
  final ProductOrderRepo repo;
  ProductOrderCubit(this.repo) : super(const ProductOrderState());
  Future<void> submit(OrderDraft order) async {
    if (state.loading || order.isSubmitting || order.orderId != null) return;
    ProductOrderPayload payload;
    try {
      payload = ProductOrderPayload.fromOrder(order);
    } on FormatException catch (e) {
      emit(ProductOrderState(error: e.message.toString()));
      return;
    }
    order.isSubmitting = true;
    emit(const ProductOrderState(loading: true));
    final result = await repo.create(payload);
    order.isSubmitting = false;
    result.fold((_) {}, (model) {
      order.orderId = model.orderId;
      order.confirmedTotal = model.total;
    });
    if (isClosed) return;
    result.fold(
          (failure) => emit(ProductOrderState(error: failure.errMessage)),
          (model) => emit(ProductOrderState(result: model)),
    );
  }
}
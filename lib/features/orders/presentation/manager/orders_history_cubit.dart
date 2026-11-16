import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/orders_history_model.dart';
import '../../data/repos/orders_history_repo.dart';
import 'orders_history_state.dart';

class OrdersHistoryCubit extends Cubit<OrdersHistoryState> {
  final OrdersHistoryRepo repo;
  OrdersHistoryCubit({required this.repo}) : super(OrdersHistoryInitial());
  OrdersHistoryModel? get model {
    final current = state;
    if (current is OrdersHistorySuccess) return current.model;
    if (current is OrdersHistoryLoadingMore) return current.model;
    if (current is OrdersHistoryFailure) return current.model;
    return null;
  }

  Future<void> load({bool more = false}) async {
    if (state is OrdersHistoryLoading || state is OrdersHistoryLoadingMore)
      return;
    final previous = model;
    if (more && (previous == null || previous.currentPage >= previous.lastPage))
      return;
    final page = more ? previous!.currentPage + 1 : 1;
    if (more) {
      emit(OrdersHistoryLoadingMore(previous!));
    } else {
      emit(OrdersHistoryLoading());
    }
    final result = await repo.getOrders(page: page);
    if (isClosed) return;
    result.fold(
          (failure) =>
          emit(OrdersHistoryFailure(failure, model: previous, loadMore: more)),
          (data) {
        final orders = more
            ? {
          for (final order in [...previous!.orders, ...data.orders])
            order.id: order,
        }.values.toList()
            : data.orders;
        emit(
          OrdersHistorySuccess(
            OrdersHistoryModel(
              orders: orders,
              currentPage: data.currentPage,
              lastPage: data.lastPage,
            ),
          ),
        );
      },
    );
  }
}

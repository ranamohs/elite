import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/order_details_repo.dart';
import 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final OrderDetailsRepo repo;
  OrderDetailsCubit({required this.repo}) : super(OrderDetailsInitial());
  Future<void> load(int orderId) async {
    if (state is OrderDetailsLoading) return;
    emit(OrderDetailsLoading());
    final result = await repo.getDetails(orderId);
    if (isClosed) return;
    result.fold(
          (failure) => emit(OrderDetailsFailure(failure)),
          (model) => emit(OrderDetailsSuccess(model)),
    );
  }
}

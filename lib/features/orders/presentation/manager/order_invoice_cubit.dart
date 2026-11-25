import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/order_invoice_model.dart';
import '../../data/repos/order_invoice_repo.dart';

part 'order_invoice_state.dart';

class OrderInvoiceCubit extends Cubit<OrderInvoiceState> {
  final OrderInvoiceRepo repo;
  OrderInvoiceCubit(this.repo) : super(const OrderInvoiceState());
  Future<void> load(int id) async {
    if (state.loading) return;
    emit(const OrderInvoiceState(loading: true));
    final result = await repo.getInvoice(id);
    if (isClosed) return;
    result.fold(
          (failure) => emit(OrderInvoiceState(error: failure.errMessage)),
          (invoice) => emit(OrderInvoiceState(invoice: invoice)),
    );
  }
}

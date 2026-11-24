import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/new_payment_request.dart';
import '../../../data/repos/assigned_requests_repo.dart';

part 'payment_request_state.dart';

class PaymentRequestCubit extends Cubit<PaymentRequestState> {
  final AssignedRequestsRepo repo;
  PaymentRequestCubit(this.repo) : super(const PaymentRequestState());
  Future<void> send(int id, NewPaymentRequest request) async {
    if (state.loading || state.sent) return;
    emit(const PaymentRequestState(loading: true));
    final result = await repo.requestPayment(id, request);
    if (isClosed) return;
    result.fold(
          (failure) => emit(PaymentRequestState(error: failure.errMessage)),
          (message) => emit(PaymentRequestState(sent: true, message: message)),
    );
  }
}

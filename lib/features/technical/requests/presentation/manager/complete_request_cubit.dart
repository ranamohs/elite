import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/deposit_receipt.dart';
import '../../data/repos/assigned_requests_repo.dart';

part 'complete_request_state.dart';

class CompleteRequestCubit extends Cubit<CompleteRequestState> {
  final AssignedRequestsRepo repo;
  CompleteRequestCubit(this.repo) : super(const CompleteRequestState());
  Future<void> complete(int id, DepositReceipt receipt) async {
    if (state.loading || state.completed) return;
    emit(const CompleteRequestState(loading: true));
    final result = await repo.complete(id, receipt);
    if (isClosed) return;
    result.fold(
      (failure) => emit(CompleteRequestState(error: failure.errMessage)),
      (message) =>
          emit(CompleteRequestState(completed: true, message: message)),
    );
  }
}

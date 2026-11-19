import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/contract_subscription_request.dart';
import '../../data/repos/contract_subscription_repo.dart';
import 'contract_subscription_state.dart';

class ContractSubscriptionCubit extends Cubit<ContractSubscriptionState> {
  final ContractSubscriptionRepo repo;
  ContractSubscriptionCubit({required this.repo})
      : super(ContractSubscriptionInitial());
  Future<void> subscribe(ContractSubscriptionRequest request) async {
    if (state is ContractSubscriptionLoading ||
        state is ContractSubscriptionSuccess ||
        state is ContractSubscriptionNotice)
      return;
    emit(ContractSubscriptionLoading());
    final result = await repo.subscribe(request);
    if (isClosed) return;
    result.fold((failure) => emit(ContractSubscriptionFailure(failure)), (
        result,
        ) {
      final subscription = result.subscription;
      if (subscription != null) {
        emit(ContractSubscriptionSuccess(subscription));
      } else {
        emit(ContractSubscriptionNotice(result));
      }
    });
  }
}

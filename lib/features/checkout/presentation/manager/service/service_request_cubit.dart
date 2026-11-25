import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/order_draft.dart';
import '../../../data/models/service_request_payload.dart';
import '../../../data/repos/service_request_repo.dart';
import 'service_request_state.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ServiceRequestRepo repo;
  ServiceRequestCubit({required this.repo}) : super(ServiceRequestInitial());
  Future<void> submit(OrderDraft order) async {
    if (state is ServiceRequestLoading ||
        order.isSubmitting ||
        order.orderId != null)
      return;
    ServiceRequestPayload payload;
    try {
      payload = ServiceRequestPayload.fromOrder(order);
    } on FormatException catch (error) {
      emit(ServiceRequestFailure(UnexpectedFailure(errMessage: error.message.tr())));
      return;
    }
    order.isSubmitting = true;
    emit(ServiceRequestLoading());
    final result = await repo.requestService(payload);
    order.isSubmitting = false;
    // Preserve the server ID even if the screen was closed during the request.
    result.fold((_) {}, (model) => order.orderId = model.orderId);
    if (isClosed) return;
    result.fold(
          (failure) => emit(ServiceRequestFailure(failure)),
          (model) => emit(ServiceRequestSuccess(model)),
    );
  }
}

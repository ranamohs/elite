import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/assigned_requests_model.dart';
import '../../../data/repos/assigned_requests_repo.dart';
import 'assigned_requests_state.dart';

class AssignedRequestsCubit extends Cubit<AssignedRequestsState> {
  final AssignedRequestsRepo repo;
  AssignedRequestsCubit({required this.repo})
      : super(AssignedRequestsInitial());
  Future<String?> respond({required int id, required bool accept}) async {
    final old = assignedRequestsData(state);
    if (old == null ||
        state is AssignedRequestsResponding ||
        state is AssignedRequestsLoadingMore)
      return null;
    emit(AssignedRequestsResponding(old, id));
    final result = await repo.respond(id: id, accept: accept);
    if (isClosed) return null;
    String? error;
    result.fold((failure) => error = failure.errMessage, (_) {});
    emit(AssignedRequestsSuccess(old));
    if (error == null) await load();
    return error;
  }

  Future<void> load({bool more = false}) async {
    if (state is AssignedRequestsResponding ||
        state is AssignedRequestsLoading ||
        state is AssignedRequestsLoadingMore)
      return;
    final old = assignedRequestsData(state);
    if (more && (old == null || !old.hasMore)) return;
    final page = more ? old!.currentPage + 1 : 1;
    if (more) {
      emit(AssignedRequestsLoadingMore(old!));
    } else {
      emit(AssignedRequestsLoading());
    }
    final result = await repo.getAssignedRequests(page: page);
    if (isClosed) return;
    result.fold(
          (failure) =>
          emit(AssignedRequestsFailure(failure, model: old, more: more)),
          (model) {
        final data = more
            ? AssignedRequestsModel(
          stats: model.stats ?? old!.stats,
          requests: {
            for (final request in [...old!.requests, ...model.requests])
              request.id: request,
          }.values.toList(),
          currentPage: model.currentPage,
          lastPage: model.lastPage,
          next: model.next,
        )
            : model;
        emit(AssignedRequestsSuccess(data));
      },
    );
  }
}

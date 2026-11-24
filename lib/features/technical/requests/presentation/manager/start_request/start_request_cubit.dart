import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/repos/assigned_requests_repo.dart';

part 'start_request_state.dart';

class StartRequestCubit extends Cubit<StartRequestState> {
  final AssignedRequestsRepo repo;
  StartRequestCubit(this.repo) : super(const StartRequestState());

  Future<void> start(int id) async {
    if (state.loading || state.startedAt != null) return;
    emit(const StartRequestState(loading: true));
    final result = await repo.start(id);
    if (isClosed) return;
    result.fold(
          (failure) => emit(StartRequestState(error: failure.errMessage)),
          (_) => emit(StartRequestState(startedAt: DateTime.now())),
    );
  }
}
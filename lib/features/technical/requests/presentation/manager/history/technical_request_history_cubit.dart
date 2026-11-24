import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/assigned_requests_model.dart';
import '../../../data/models/technical_request_history.dart';
import '../../../data/repos/assigned_requests_repo.dart';

part 'technical_request_history_state.dart';


class TechnicalRequestHistoryCubit extends Cubit<TechnicalRequestHistoryState> {
  final AssignedRequestsRepo repo;
  TechnicalRequestHistoryCubit(this.repo)
      : super(const TechnicalRequestHistoryState());
  Future<void> refresh() async {
    await Future.wait(
      TechnicalRequestSource.values.map((source) => load(source)),
    );
  }

  Future<void> load(TechnicalRequestSource source, {bool more = false}) async {
    if (state.loading.contains(source)) return;
    final old = state.pages[source];
    if (more && (old == null || !old.hasMore)) return;
    emit(
      TechnicalRequestHistoryState(
        pages: state.pages,
        loading: {...state.loading, source},
        errors: {...state.errors}..remove(source),
      ),
    );
    final result = await repo.getRequestHistory(
      source,
      page: more ? old!.currentPage + 1 : 1,
    );
    if (isClosed) return;
    result.fold(
          (failure) => emit(
        TechnicalRequestHistoryState(
          pages: state.pages,
          loading: {...state.loading}..remove(source),
          errors: {...state.errors, source: failure.errMessage},
        ),
      ),
          (page) {
        final model = more
            ? AssignedRequestsModel(
          requests: {
            for (final request in [...old!.requests, ...page.requests])
              request.id: request,
          }.values.toList(),
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          next: page.next,
        )
            : page;
        emit(
          TechnicalRequestHistoryState(
            pages: {...state.pages, source: model},
            loading: {...state.loading}..remove(source),
            errors: {...state.errors}..remove(source),
          ),
        );
      },
    );
  }
}

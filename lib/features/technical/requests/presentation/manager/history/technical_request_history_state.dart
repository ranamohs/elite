part of 'technical_request_history_cubit.dart';

@immutable

class TechnicalRequestHistoryState {
  final Map<TechnicalRequestSource, AssignedRequestsModel> pages;
  final Set<TechnicalRequestSource> loading;
  final Map<TechnicalRequestSource, String> errors;
  const TechnicalRequestHistoryState({
    this.pages = const {},
    this.loading = const {},
    this.errors = const {},
  });
}
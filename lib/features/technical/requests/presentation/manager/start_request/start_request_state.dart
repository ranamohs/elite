part of 'start_request_cubit.dart';

@immutable


class StartRequestState {
  final bool loading;
  final String? error;
  final DateTime? startedAt;
  const StartRequestState({this.loading = false, this.error, this.startedAt});
}
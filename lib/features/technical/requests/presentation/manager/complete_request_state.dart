part of 'complete_request_cubit.dart';

@immutable
class CompleteRequestState {
  final bool loading, completed;
  final String? error, message;
  const CompleteRequestState({
    this.loading = false,
    this.completed = false,
    this.error,
    this.message,
  });
}
import 'package:equatable/equatable.dart';
import '../../../../../../core/errors/failure.dart';
import '../../data/models/assigned_requests_model.dart';

abstract class AssignedRequestsState extends Equatable {
  const AssignedRequestsState();
  @override
  List<Object?> get props => [];
}

class AssignedRequestsInitial extends AssignedRequestsState {}

class AssignedRequestsLoading extends AssignedRequestsState {}

class AssignedRequestsSuccess extends AssignedRequestsState {
  final AssignedRequestsModel model;
  const AssignedRequestsSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class AssignedRequestsLoadingMore extends AssignedRequestsState {
  final AssignedRequestsModel model;
  const AssignedRequestsLoadingMore(this.model);
  @override
  List<Object?> get props => [model];
}

class AssignedRequestsFailure extends AssignedRequestsState {
  final Failure failure;
  final AssignedRequestsModel? model;
  final bool more;
  const AssignedRequestsFailure(this.failure, {this.model, this.more = false});
  @override
  List<Object?> get props => [failure, model, more];
}

AssignedRequestsModel? assignedRequestsData(AssignedRequestsState state) =>
    switch (state) {
      AssignedRequestsSuccess() => state.model,
      AssignedRequestsLoadingMore() => state.model,
      AssignedRequestsFailure() => state.model,
      _ => null,
    };

class AssignedRequestsResponding extends AssignedRequestsSuccess {
  final int id;
  const AssignedRequestsResponding(super.model, this.id);
  @override
  List<Object?> get props => [model, id];
}
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/service_request_model.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();
  @override
  List<Object?> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestSuccess extends ServiceRequestState {
  final ServiceRequestModel model;
  const ServiceRequestSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class ServiceRequestFailure extends ServiceRequestState {
  final Failure failure;
  const ServiceRequestFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}

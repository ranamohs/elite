import '../../data/models/contract_subscription_result.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/contract_subscription_model.dart';

abstract class ContractSubscriptionState extends Equatable {
  const ContractSubscriptionState();
  @override
  List<Object?> get props => [];
}

class ContractSubscriptionInitial extends ContractSubscriptionState {}

class ContractSubscriptionLoading extends ContractSubscriptionState {}

class ContractSubscriptionSuccess extends ContractSubscriptionState {
  final ContractSubscriptionModel model;
  const ContractSubscriptionSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class ContractSubscriptionFailure extends ContractSubscriptionState {
  final Failure failure;
  const ContractSubscriptionFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}

class ContractSubscriptionNotice extends ContractSubscriptionState {
  final ContractSubscriptionResult result;
  const ContractSubscriptionNotice(this.result);
  @override
  List<Object?> get props => [result];
}

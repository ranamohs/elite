import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/order_details_model.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();
  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsSuccess extends OrderDetailsState {
  final OrderDetailsModel model;
  const OrderDetailsSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class OrderDetailsFailure extends OrderDetailsState {
  final Failure failure;
  const OrderDetailsFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}

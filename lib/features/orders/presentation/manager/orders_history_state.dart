import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/orders_history_model.dart';

abstract class OrdersHistoryState extends Equatable {
  const OrdersHistoryState();
  @override
  List<Object?> get props => [];
}

class OrdersHistoryInitial extends OrdersHistoryState {}

class OrdersHistoryLoading extends OrdersHistoryState {}

class OrdersHistorySuccess extends OrdersHistoryState {
  final OrdersHistoryModel model;
  const OrdersHistorySuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class OrdersHistoryLoadingMore extends OrdersHistoryState {
  final OrdersHistoryModel model;
  const OrdersHistoryLoadingMore(this.model);
  @override
  List<Object?> get props => [model];
}

class OrdersHistoryFailure extends OrdersHistoryState {
  final Failure failure;
  final OrdersHistoryModel? model;
  final bool loadMore;
  const OrdersHistoryFailure(this.failure, {this.model, this.loadMore = false});
  @override
  List<Object?> get props => [failure, model, loadMore];
}

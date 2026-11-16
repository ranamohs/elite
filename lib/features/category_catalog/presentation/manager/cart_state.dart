import '../../data/models/cart_change_model.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/cart_add_model.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {
  final int productId;
  final CartOperation operation;
  const CartLoading(this.productId, {this.operation = CartOperation.add});
  @override
  List<Object?> get props => [productId, operation];
}

class CartSuccess extends CartState {
  final CartAddModel model;
  const CartSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class CartFailure extends CartState {
  final Failure failure;
  const CartFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}

class CartChanged extends CartState {
  final CartChangeModel model;
  const CartChanged(this.model);
  @override
  List<Object?> get props => [model];
}

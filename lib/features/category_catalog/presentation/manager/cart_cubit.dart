import '../../data/models/cart_change_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/cart_repo.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo repo;
  CartCubit({required this.repo}) : super(CartInitial());
  Future<void> addProduct(int productId) async {
    if (state is CartLoading) return;
    emit(CartLoading(productId));
    final result = await repo.addProduct(productId);
    if (isClosed) return;
    result.fold(
          (failure) => emit(CartFailure(failure)),
          (model) => emit(CartSuccess(model)),
    );
  }

  Future<void> decreaseProduct(int productId) async {
    if (state is CartLoading) return;
    emit(CartLoading(productId, operation: CartOperation.decrease));
    final result = await repo.decreaseProduct(productId);
    if (isClosed) return;
    result.fold(
          (failure) => emit(CartFailure(failure)),
          (model) => emit(CartChanged(model)),
    );
  }

  Future<void> removeProduct({
    required int productId,
    required int cartItemId,
  }) async {
    if (state is CartLoading) return;
    emit(CartLoading(productId, operation: CartOperation.remove));
    final result = await repo.removeProduct(
      productId: productId,
      cartItemId: cartItemId,
    );
    if (isClosed) return;
    result.fold(
          (failure) => emit(CartFailure(failure)),
          (model) => emit(CartChanged(model)),
    );
  }
}

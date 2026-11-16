import '../models/cart_change_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/cart_add_model.dart';

abstract class CartRepo {
  Future<Either<Failure, CartChangeModel>> decreaseProduct(int productId);
  Future<Either<Failure, CartChangeModel>> removeProduct({
    required int productId,
    required int cartItemId,
  });
  Future<Either<Failure, CartAddModel>> addProduct(int productId);
}

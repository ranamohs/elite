import 'package:dartz/dartz.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/shops/data/models/wishlist_model.dart';

abstract class WishlistRepo {
  Future<Either<Failure, Unit>> toggleWishlist({required int shopId});
  Future<Either<Failure, WishlistModel>> getWishlist();
}
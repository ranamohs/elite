import '../models/cart_change_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/cart_add_model.dart';
import 'cart_repo.dart';

class CartRepoImpl implements CartRepo {
  final DioConsumer dioConsumer;
  final SecureStorageHelper secureStorageHelper;
  final NetworkConnectionCubit networkCubit;
  CartRepoImpl({
    required this.dioConsumer,
    required this.secureStorageHelper,
    required this.networkCubit,
  });
  @override
  Future<Either<Failure, CartAddModel>> addProduct(int productId) async {
    try {
      if (!await networkCubit.networkInfo.isConnected) {
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      }
      final token = await secureStorageHelper.getToken();
      if (token == null || token.isEmpty) {
        return Left(ServerFailure(errMessage: 'loginRequiredForCart'.tr()));
      }
      final response = await dioConsumer.post(
        EndPoints.addToCart,
        data: FormData.fromMap({'product_id': productId}),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response is Map<String, dynamic> && response['status'] == true) {
        final model = CartAddModel.fromJson(response);
        if (model.product.id == productId) return Right(model);
      }
      return Left(ServerFailure(errMessage: _message(response)));
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }

  @override
  Future<Either<Failure, CartChangeModel>> decreaseProduct(int productId) =>
      _changeProduct(productId: productId);

  @override
  Future<Either<Failure, CartChangeModel>> removeProduct({
    required int productId,
    required int cartItemId,
  }) => _changeProduct(productId: productId, cartItemId: cartItemId);

  Future<Either<Failure, CartChangeModel>> _changeProduct({
    required int productId,
    int? cartItemId,
  }) async {
    try {
      if (!await networkCubit.networkInfo.isConnected) {
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      }
      final token = await secureStorageHelper.getToken();
      if (token == null || token.isEmpty) {
        return Left(ServerFailure(errMessage: 'loginRequiredForCart'.tr()));
      }
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = cartItemId == null
          ? await dioConsumer.post(
        EndPoints.minusFromCart,
        data: FormData.fromMap({'product_id': productId}),
        headers: headers,
      )
          : await dioConsumer.delete(
        EndPoints.removeCartItem(cartItemId),
        headers: headers,
      );
      if (response is Map<String, dynamic> && response['status'] == true) {
        return Right(
          CartChangeModel.fromJson(
            response,
            productId: productId,
            removed: cartItemId != null,
          ),
        );
      }
      return Left(ServerFailure(errMessage: _message(response)));
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }

  String _message(dynamic response) {
    final message = response is Map ? response['message'] : null;
    if (message is Map) {
      return '${message['ar'] ?? message['en'] ?? AppStrings.serverConnectionFailed.tr()}';
    }
    return message is String ? message : AppStrings.serverConnectionFailed.tr();
  }
}

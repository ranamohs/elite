import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/catalog_model.dart';
import 'catalog_repo.dart';

class CatalogRepoImpl implements CatalogRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;
  final SecureStorageHelper secureStorageHelper;
  CatalogRepoImpl({
    required this.dioConsumer,
    required this.networkCubit,
    required this.secureStorageHelper,
  });

  @override
  Future<Either<Failure, CatalogPage>> getItems({
    required int categoryId,
    required bool isProduct,
    int page = 1,
  }) async {
    try {
      if (!await networkCubit.networkInfo.isConnected) {
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      }
      final token = await secureStorageHelper.getToken();
      final response = await dioConsumer.get(
        isProduct
            ? EndPoints.categoryProducts(categoryId)
            : EndPoints.categoryServices(categoryId),
        queryParameters: {Params.page: page},
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (response is Map<String, dynamic> &&
          response['status'] == true &&
          response['data'] is List) {
        return Right(CatalogPage.fromJson(response, isProduct: isProduct));
      }
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }
}

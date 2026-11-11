import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/category_services_model.dart';
import 'category_services_repo.dart';

class CategoryServicesRepoImpl implements CategoryServicesRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;
  final SecureStorageHelper? secureStorageHelper;

  CategoryServicesRepoImpl({
    required this.dioConsumer,
    required this.networkCubit,
    this.secureStorageHelper,
  });

  @override
  Future<Either<Failure, CategoryServicesModel>> getCategoryServices({
    required int categoryId,
    int? page,
  }) async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()));
    }

    try {
      final token = await secureStorageHelper?.getToken();
      final queryParameters = {if (page != null) Params.page: page};
      final endpoint = '/$categoryId/services';

      final response = await dioConsumer.get(
        endpoint,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        queryParameters: queryParameters,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final model = CategoryServicesModel.fromJson(response);
          return Right(model);
        } else {
          return Left(UnexpectedFailure(
            errMessage: AppStrings.unexpectedError.tr(),
          ));
        }
      } else {
        return Left(ServerFailure(
          errMessage: AppStrings.serverConnectionFailed.tr(),
        ));
      }
    } catch (e) {
      return Left(ServerFailure(
        errMessage: AppStrings.serverConnectionFailed.tr(),
      ));
    }
  }
}

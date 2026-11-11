import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/sub_category_model.dart';
import 'sub_category_repo.dart';

class SubCategoryRepoImpl implements SubCategoryRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;
  final SecureStorageHelper? secureStorageHelper;

  SubCategoryRepoImpl({
    required this.dioConsumer,
    required this.networkCubit,
    this.secureStorageHelper,
  });

  @override
  Future<Either<Failure, SubCategoryModel>> getSubCategories({
    required int subCategoryId,
    int? page,
  }) async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()));
    }

    try {
      final token = await secureStorageHelper?.getToken();
      final queryParameters = {if (page != null) Params.page: page};
      final endpoint = '/$subCategoryId/categories';

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
          final model = SubCategoryModel.fromJson(response);
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

import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/end_points.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/categories_models/recent_shops_models.dart';
import 'recent_shops_repo.dart';

class RcenetShopsRepoImpl implements RcenetShopsRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;

  RcenetShopsRepoImpl({required this.dioConsumer, required this.networkCubit});

  @override
  Future<Either<Failure, RcenetShopsModel>> getRcenetShops() async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()));
    }

    try {
      final response = await dioConsumer.get(EndPoints.recentShops);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey(ApiKey.data)) {
          final categoriesModel = RcenetShopsModel.fromJson(response);
          return Right(categoriesModel);
        } else {
          return Left(UnexpectedFailure(
            errMessage: AppStrings.unexpectedError.tr(),
          ));
        }
      } else {
        return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
      }
    } catch (e) {
      return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
    }
  }
}
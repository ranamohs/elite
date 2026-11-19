import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/offers_model.dart';
import 'offers_repo.dart';

class OffersRepoImpl implements OffersRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;

  OffersRepoImpl({required this.dioConsumer, required this.networkCubit});

  @override
  Future<Either<Failure, OffersModel>> getOffers() async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(
        NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
      );
    }

    try {
      final response = await dioConsumer.get(EndPoints.offers);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey(ApiKey.data) &&
            response[ApiKey.status] == true) {
          final model = OffersModel.fromJson(response);
          return Right(model);
        } else {
          String errorMessage = AppStrings.unexpectedError.tr();
          if (response[ApiKey.message] is Map) {
            errorMessage = response[ApiKey.message][ApiKey.ar] ?? errorMessage;
          }
          return Left(UnexpectedFailure(errMessage: errorMessage));
        }
      } else {
        return Left(
          ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }
}

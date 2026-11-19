import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/end_points.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contract_details_model.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'package:elite/features/home/data/repos/contracts_repo/maintenance_contracts_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class MaintenanceContractsRepoImpl implements MaintenanceContractsRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;

  MaintenanceContractsRepoImpl({
    required this.dioConsumer,
    required this.networkCubit,
  });

  @override
  Future<Either<Failure, MaintenanceContractsModel>> getMaintenanceContracts() async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()));
    }

    try {
      final response = await dioConsumer.get(EndPoints.maintenanceContracts);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey(ApiKey.data) && response[ApiKey.status] == true) {
          final model = MaintenanceContractsModel.fromJson(response);
          return Right(model);
        } else {
          String errorMessage = AppStrings.unexpectedError.tr();
          if (response[ApiKey.message] is Map) {
            errorMessage = response[ApiKey.message][ApiKey.ar] ?? errorMessage;
          }
          return Left(UnexpectedFailure(errMessage: errorMessage));
        }
      } else {
        return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
      }
    } catch (e) {
      return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceContractDetailsModel>>
  getMaintenanceContractDetails(int id) async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()));
    }

    try {
      final response =
      await dioConsumer.get(EndPoints.maintenanceContractDetails(id));

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey(ApiKey.data) &&
            response[ApiKey.data] is Map &&
            response[ApiKey.status] == true) {
          final model = MaintenanceContractDetailsModel.fromJson(response);
          return Right(model);
        } else {
          String errorMessage = AppStrings.unexpectedError.tr();
          if (response[ApiKey.message] is Map) {
            errorMessage = response[ApiKey.message][ApiKey.ar] ?? errorMessage;
          }
          return Left(UnexpectedFailure(errMessage: errorMessage));
        }
      } else {
        return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
      }
    } catch (e) {
      return Left(ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()));
    }
  }
}

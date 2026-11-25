import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/contract_subscription_result.dart';
import '../models/contract_subscription_request.dart';
import 'contract_subscription_repo.dart';

class ContractSubscriptionRepoImpl implements ContractSubscriptionRepo {
  final DioConsumer dioConsumer;
  final SecureStorageHelper storage;
  final NetworkConnectionCubit network;
  ContractSubscriptionRepoImpl({
    required this.dioConsumer,
    required this.storage,
    required this.network,
  });
  @override
  Future<Either<Failure, ContractSubscriptionResult>> subscribe(
      ContractSubscriptionRequest request,
      ) async {
    try {
      if (!request.isValid) {
        return Left(
          UnexpectedFailure(errMessage: 'subscriptionMissingFields'.tr()),
        );
      }
      if (!await network.networkInfo.isConnected) {
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      }
      final token = (await storage.getToken())?.trim();
      if (token == null || token.isEmpty) {
        return Left(
          ServerFailure(errMessage: 'loginRequiredForSubscription'.tr()),
        );
      }
      final file = File(request.imagePath);
      final extension = request.imagePath.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension) ||
          !await file.exists() ||
          await file.length() > 5120 * 1024) {
        return Left(
          UnexpectedFailure(errMessage: 'subscriptionInvalidImage'.tr()),
        );
      }
      final form = FormData.fromMap({
        ...request.fields,
        'image': await MultipartFile.fromFile(request.imagePath),
      });
      final response = await dioConsumer.post(
        EndPoints.subscribe,
        data: form,
        headers: {
          'Accept': 'application/json',
          Params.authorization: '${Params.bearer} $token',
        },
      );
      if (response is Map<String, dynamic> && response['status'] == true) {
        final result = ContractSubscriptionResult.fromJson(response);
        final subscription = result.subscription;
        if (subscription == null ||
            subscription.contract.id == request.contractId) {
          return Right(result);
        }
      }
      final message = response is Map ? response['message'] : null;
      final errors = response is Map ? response['errors'] : null;
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return Left(ServerFailure(errMessage: value.first.toString()));
          }
        }
      }
      return Left(
        ServerFailure(
          errMessage: message is String
              ? message
              : message is Map
              ? '${message['ar'] ?? message['en'] ?? AppStrings.serverConnectionFailed.tr()}'
              : AppStrings.serverConnectionFailed.tr(),
        ),
      );
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }
}

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
import '../models/service_request_payload.dart';
import '../models/service_request_model.dart';
import 'service_request_repo.dart';

class ServiceRequestRepoImpl implements ServiceRequestRepo {
  final DioConsumer dioConsumer;
  final SecureStorageHelper secureStorageHelper;
  final NetworkConnectionCubit networkCubit;
  ServiceRequestRepoImpl({
    required this.dioConsumer,
    required this.secureStorageHelper,
    required this.networkCubit,
  });
  @override
  Future<Either<Failure, ServiceRequestModel>> requestService(
      ServiceRequestPayload payload,
      ) async {
    try {
      if (!await networkCubit.networkInfo.isConnected) {
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      }
      final token = await secureStorageHelper.getToken();
      if (token == null || token.isEmpty) {
        return Left(ServerFailure(errMessage: 'loginRequiredForOrder'.tr()));
      }
      final form = FormData.fromMap(payload.fields);
      for (final path in payload.photos) {
        final extension = path.toLowerCase().split('.').last;
        if (!['png', 'jpg', 'jpeg', 'webp'].contains(extension) ||
            await File(path).length() > 2024 * 1024) {
          return Left(UnexpectedFailure(errMessage: 'invalidOrderImage'.tr()));
        }
        form.files.add(
          MapEntry('image_of_place[]', await MultipartFile.fromFile(path)),
        );
      }
      final response = await dioConsumer.post(
        EndPoints.serviceRequest(payload.serviceId),
        data: form,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response is Map<String, dynamic> && response['status'] == true) {
        return Right(ServiceRequestModel.fromJson(response));
      }
      final message = response is Map ? response['message'] : null;
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

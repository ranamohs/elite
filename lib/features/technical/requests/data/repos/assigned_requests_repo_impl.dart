import 'package:dio/dio.dart';
import '../models/deposit_receipt.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/constants/end_points.dart';
import '../../../../../../core/databases/api/dio_consumer.dart';
import '../../../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/assigned_requests_model.dart';
import 'assigned_requests_repo.dart';

class AssignedRequestsRepoImpl implements AssignedRequestsRepo {
  final DioConsumer dio;
  final SecureStorageHelper storage;
  final NetworkConnectionCubit network;
  AssignedRequestsRepoImpl({
    required this.dio,
    required this.storage,
    required this.network,
  });
  @override
  Future<Either<Failure, String>> respond({
    required int id,
    required bool accept,
  }) async {
    return action(
      accept
          ? EndPoints.receiveAssignedRequest(id)
          : EndPoints.declineAssignedRequest(id),
    );
  }

  @override
  Future<Either<Failure, String>> start(int id) =>
      action(EndPoints.startAssignedRequest(id));
  @override
  Future<Either<Failure, String>> complete(int id, DepositReceipt receipt) =>
      action(
        EndPoints.completeAssignedRequest(id),
        data: FormData.fromMap({
          'deposit_receipt': MultipartFile.fromBytes(
            receipt.bytes,
            filename: receipt.filename,
          ),
        }),
      );
  Future<Either<Failure, String>> action(String path, {dynamic data}) async {
    try {
      if (!await network.networkInfo.isConnected)
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      final token = (await storage.getToken())?.trim();
      if (token == null || token.isEmpty)
        return Left(ServerFailure(errMessage: 'loginRequiredForOrders'.tr()));
      final response = await dio.post(
        path,
        data: data,
        headers: {
          'Accept': 'application/json',
          Params.authorization: '${Params.bearer} $token',
        },
      );
      final raw = response is Map ? response['message'] : null;
      final message = raw is Map
          ? '${raw['ar'] ?? raw['en'] ?? ''}'
          : raw is String
          ? raw
          : '';
      if (response is Map && response['status'] == true) return Right(message);
      return Left(
        ServerFailure(
          errMessage: message.isEmpty
              ? AppStrings.serverConnectionFailed.tr()
              : message,
        ),
      );
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }

  @override
  Future<Either<Failure, AssignedRequestsModel>> getAssignedRequests({
    int page = 1,
  }) async {
    try {
      if (!await network.networkInfo.isConnected)
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      final token = (await storage.getToken())?.trim();
      if (token == null || token.isEmpty)
        return Left(ServerFailure(errMessage: 'loginRequiredForOrders'.tr()));
      final response = await dio.get(
        EndPoints.assignedRequests,
        queryParameters: {Params.page: page},
        headers: {
          'Accept': 'application/json',
          Params.authorization: '${Params.bearer} $token',
        },
      );
      if (response is Map<String, dynamic> &&
          response['status'] == true &&
          response['data'] is List)
        return Right(AssignedRequestsModel.fromJson(response, page: page));
      final message = response is Map ? response['message'] : null;
      return Left(
        ServerFailure(
          errMessage: message is Map
              ? '${message['ar'] ?? message['en'] ?? AppStrings.serverConnectionFailed.tr()}'
              : message is String
              ? message
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
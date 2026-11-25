import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/product_order_payload.dart';
import '../models/product_order_model.dart';
import 'product_order_repo.dart';

class ProductOrderRepoImpl implements ProductOrderRepo {
  final DioConsumer dio;
  final SecureStorageHelper storage;
  final NetworkConnectionCubit network;
  ProductOrderRepoImpl({
    required this.dio,
    required this.storage,
    required this.network,
  });
  @override
  Future<Either<Failure, ProductOrderModel>> create(
      ProductOrderPayload payload,
      ) async {
    try {
      if (!await network.networkInfo.isConnected)
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      final token = (await storage.getToken())?.trim();
      if (token == null || token.isEmpty)
        return Left(ServerFailure(errMessage: 'loginRequiredForCart'.tr()));
      final form = FormData.fromMap(payload.fields);
      for (final path in payload.photos) {
        final file = XFile(path);
        form.files.add(
          MapEntry(
            'image_of_place[]',
            MultipartFile.fromBytes(
              await file.readAsBytes(),
              filename: file.name,
            ),
          ),
        );
      }
      if (payload.receipt != null) {
        final file = XFile(payload.receipt!);
        form.files.add(
          MapEntry(
            'deposit_receipt',
            MultipartFile.fromBytes(
              await file.readAsBytes(),
              filename: file.name,
            ),
          ),
        );
      }
      final response = await dio.post(
        EndPoints.createFromCart,
        data: form,
        headers: {
          'Accept': 'application/json',
          Params.authorization: '${Params.bearer} $token',
        },
      );
      if (response is Map<String, dynamic> && response['status'] == true)
        return Right(ProductOrderModel.fromJson(response));
      final errors = response is Map ? response['errors'] : null;
      final raw = errors is Map && errors['message'] != null
          ? errors['message']
          : response is Map
          ? response['message']
          : null;
      final message = raw is Map
          ? '${raw['ar'] ?? raw['en'] ?? ''}'
          : raw is String
          ? raw
          : '';
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
}
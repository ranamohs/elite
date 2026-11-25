import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/order_invoice_model.dart';
import 'order_invoice_repo.dart';

class OrderInvoiceRepoImpl implements OrderInvoiceRepo {
  final DioConsumer dio;
  final SecureStorageHelper storage;
  final NetworkConnectionCubit network;
  OrderInvoiceRepoImpl({
    required this.dio,
    required this.storage,
    required this.network,
  });
  @override
  Future<Either<Failure, OrderInvoiceModel>> getInvoice(int orderId) async {
    try {
      if (!await network.networkInfo.isConnected)
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      final token = (await storage.getToken())?.trim();
      if (token == null || token.isEmpty)
        return Left(ServerFailure(errMessage: 'loginRequiredForOrders'.tr()));
      final response = await dio.get(
        EndPoints.getOrderInvoice(orderId),
        headers: {
          'Accept': 'application/json',
          Params.authorization: '${Params.bearer} $token',
        },
      );
      if (response is Map<String, dynamic> && response['status'] == true) {
        final invoice = OrderInvoiceModel.fromJson(response);
        if (invoice.orderId == orderId) return Right(invoice);
        return Left(
          ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
        );
      }
      final raw = response is Map ? response['message'] : null;
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

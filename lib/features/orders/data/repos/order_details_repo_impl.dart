import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/order_details_model.dart';
import 'order_details_repo.dart';

class OrderDetailsRepoImpl implements OrderDetailsRepo {
  final DioConsumer dioConsumer;
  final SecureStorageHelper secureStorageHelper;
  final NetworkConnectionCubit networkCubit;
  OrderDetailsRepoImpl({
    required this.dioConsumer,
    required this.secureStorageHelper,
    required this.networkCubit,
  });
  @override
  Future<Either<Failure, OrderDetailsModel>> getDetails(int orderId) async {
    try {
      if (!await networkCubit.networkInfo.isConnected)
        return Left(
          NoInternetFailure(errMessage: AppStrings.noInternetConnection.tr()),
        );
      final token = await secureStorageHelper.getToken();
      if (token == null || token.isEmpty)
        return Left(ServerFailure(errMessage: 'loginRequiredForOrders'.tr()));
      final response = await dioConsumer.get(
        EndPoints.orderHistoryDetails(orderId),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response is Map<String, dynamic> &&
          response['status'] == true &&
          response['data'] is Map) {
        final model = OrderDetailsModel.fromJson(response);
        if (model.order.id == orderId) return Right(model);
      }
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    } catch (_) {
      return Left(
        ServerFailure(errMessage: AppStrings.serverConnectionFailed.tr()),
      );
    }
  }
}

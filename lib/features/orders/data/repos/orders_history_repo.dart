import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/orders_history_model.dart';

abstract class OrdersHistoryRepo {
  Future<Either<Failure, OrdersHistoryModel>> getOrders({int page = 1});
}

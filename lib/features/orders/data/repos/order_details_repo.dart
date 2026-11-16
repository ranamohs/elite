import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/order_details_model.dart';

abstract class OrderDetailsRepo {
  Future<Either<Failure, OrderDetailsModel>> getDetails(int orderId);
}

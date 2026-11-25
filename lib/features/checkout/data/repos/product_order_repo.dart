import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/product_order_payload.dart';
import '../models/product_order_model.dart';

abstract class ProductOrderRepo {
  Future<Either<Failure, ProductOrderModel>> create(
      ProductOrderPayload payload,
      );
}

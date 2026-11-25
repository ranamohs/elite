import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/order_invoice_model.dart';

abstract class OrderInvoiceRepo {
  Future<Either<Failure, OrderInvoiceModel>> getInvoice(int orderId);
}

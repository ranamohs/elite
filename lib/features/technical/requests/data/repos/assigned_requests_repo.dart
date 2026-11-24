import '../models/technical_request_history.dart';
import '../models/new_payment_request.dart';
import '../models/deposit_receipt.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../models/assigned_requests_model.dart';

abstract class AssignedRequestsRepo {
  Future<Either<Failure, AssignedRequestsModel>> getRequestHistory(
      TechnicalRequestSource source, {
        int page = 1,
      });
  Future<Either<Failure, String>> requestPayment(
      int id,
      NewPaymentRequest payment,
      );
  Future<Either<Failure, String>> complete(int id, DepositReceipt receipt);
  Future<Either<Failure, String>> start(int id);
  Future<Either<Failure, String>> respond({
    required int id,
    required bool accept,
  });
  Future<Either<Failure, AssignedRequestsModel>> getAssignedRequests({
    int page = 1,
  });
}

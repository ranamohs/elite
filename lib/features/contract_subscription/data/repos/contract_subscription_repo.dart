import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/contract_subscription_result.dart';
import '../models/contract_subscription_request.dart';

abstract class ContractSubscriptionRepo {
  Future<Either<Failure, ContractSubscriptionResult>> subscribe(
      ContractSubscriptionRequest request,
      );
}
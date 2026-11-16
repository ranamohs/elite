import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/service_request_payload.dart';
import '../models/service_request_model.dart';

abstract class ServiceRequestRepo {
  Future<Either<Failure, ServiceRequestModel>> requestService(
      ServiceRequestPayload payload,
      );
}

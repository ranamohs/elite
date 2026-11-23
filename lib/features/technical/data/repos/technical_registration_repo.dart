import 'package:dartz/dartz.dart';
import '../models/technical_registration_failure.dart';
import '../models/technical_registration_model.dart';
import '../models/technical_registration_request.dart';

abstract class TechnicalRegistrationRepo {
  Future<Either<TechnicalRegistrationFailure, TechnicalRegistrationModel>>
  register(TechnicalRegistrationRequest request);
}

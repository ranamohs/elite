import 'package:elite/core/data/models/auth_failure_model.dart';
import 'package:elite/features/register/data/models/register_data_model.dart';
import 'package:elite/features/register/data/models/register_success_model.dart';
import 'package:dartz/dartz.dart';

abstract class RegisterRepo {
  Future<Either<AuthFailureModel, RegisterSuccessModel>> register({required RegisterDataModel registerData});
}

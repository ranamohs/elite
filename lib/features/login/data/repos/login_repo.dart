import 'package:elite/features/login/data/models/login_success_model.dart';
import 'package:elite/core/data/models/auth_failure_model.dart';
import 'package:dartz/dartz.dart';

abstract class LoginRepo {
  Future<Either<AuthFailureModel, LoginSuccessModel>> login({required String phoneNumber,required String password});
}

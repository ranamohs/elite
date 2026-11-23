import 'package:elite/features/login/data/models/login_success_model.dart';
import 'package:elite/features/login/data/repos/login_repo.dart';
import 'package:elite/features/login/presentation/manager/login_state.dart';
import 'package:elite/core/data/models/auth_failure_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit({required this.loginRepo}) : super(LoginInitialState());

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (state is LoginLoadingState) return;
    emit(LoginLoadingState());

    final Either<AuthFailureModel, LoginSuccessModel> result = await loginRepo
        .login(phoneNumber: phoneNumber, password: password);

    if (isClosed) return;
    result.fold((failure) => emit(LoginFailureState(failure)), (login) {
      emit(LoginSuccessState(login: login));
    });
  }
}

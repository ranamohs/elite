import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/end_points.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/databases/cache/secure_storage_helper.dart';
import 'package:elite/core/databases/cache/user_data_manager.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/features/register/data/models/register_data_model.dart';
import 'package:elite/core/data/models/auth_failure_model.dart';
import 'package:elite/features/register/data/models/register_success_model.dart';
import 'package:elite/features/register/data/repos/register_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterRepoImpl implements RegisterRepo {
  final DioConsumer dioConsumer;
  final NetworkConnectionCubit networkCubit;
  final SecureStorageHelper secureStorageHelper;
  final UserDataManager? userDataManager;

  RegisterRepoImpl({
    required this.dioConsumer,
    required this.networkCubit,
    required this.secureStorageHelper,
    this.userDataManager,
  });

  @override
  Future<Either<AuthFailureModel, RegisterSuccessModel>> register({
    required RegisterDataModel registerData,
  }) async {
    final isConnected = await networkCubit.networkInfo.isConnected;

    if (!isConnected) {
      return Left(
        AuthFailureModel(
          message: AppStrings.noInternetConnection.tr(),
          errors: {
            ApiKey.errors: [AppStrings.noInternetConnection.tr()],
          },
        ),
      );
    }

    try {
      final response = await dioConsumer.post(
        EndPoints.register,
        data: registerData.toJson(),
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey(ApiKey.token)) {
          final registerSuccessModel = RegisterSuccessModel.fromJson(response);
          final token = response[ApiKey.token];
          if (token != null) {
            await secureStorageHelper.saveToken(token: token.toString());
          }

          if (userDataManager != null &&
              response[ApiKey.user] is Map<String, dynamic>) {
            final userData = response[ApiKey.user] as Map<String, dynamic>;
            await userDataManager!.saveAccountSession(
              accountType: userData['account_type']?.toString() ?? 'customer',
              isActive: userData['is_active'] is bool
                  ? userData['is_active'] as bool
                  : null,
              registrationStatus: userData['registration_status']?.toString(),
            );
            final rawId = userData[ApiKey.id];
            if (rawId != null) {
              final parsedId = rawId is int
                  ? rawId
                  : int.tryParse(rawId.toString());
              if (parsedId != null) {
                userDataManager!.saveUserId(id: parsedId);
              }
            }

            final name = userData[ApiKey.name];
            if (name != null) {
              userDataManager!.saveUserName(name: name.toString());
            }

            final email = userData[ApiKey.email];
            if (email != null) {
              userDataManager!.saveUserEmail(email: email.toString());
            }

            final phone =
                userData[ApiKey.phone] ?? userData[ApiKey.phoneNumber];
            if (phone != null) {
              userDataManager!.saveUserPhoneNumber(
                phoneNumber: phone.toString(),
              );
            }

            final avatar = userData[ApiKey.avatar];
            userDataManager!.saveUserAvatarUrl(
              avatar: avatar != null ? avatar.toString() : '',
            );
            userDataManager!.saveUserStatus(isGuest: false);
          }

          return Right(registerSuccessModel);
        } else {
          return Left(AuthFailureModel.fromJson(response));
        }
      } else {
        return Left(
          AuthFailureModel(
            message: AppStrings.serverConnectionFailed.tr(),
            errors: {
              ApiKey.errors: [AppStrings.noInternetConnection.tr()],
            },
          ),
        );
      }
    } catch (e) {
      return Left(
        AuthFailureModel(
          message: AppStrings.unexpectedError.tr(),
          errors: {
            ApiKey.errors: [AppStrings.noInternetConnection.tr()],
          },
        ),
      );
    }
  }
}

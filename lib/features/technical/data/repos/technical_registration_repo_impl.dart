import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/databases/api/dio_consumer.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../models/technical_registration_request.dart';
import '../models/technical_registration_model.dart';
import '../models/technical_registration_failure.dart';
import 'technical_registration_repo.dart';

class TechnicalRegistrationRepoImpl implements TechnicalRegistrationRepo {
  final DioConsumer dioConsumer;
  final SecureStorageHelper storage;
  final UserDataManager userData;
  final NetworkConnectionCubit network;
  TechnicalRegistrationRepoImpl({
    required this.dioConsumer,
    required this.storage,
    required this.userData,
    required this.network,
  });
  @override
  Future<Either<TechnicalRegistrationFailure, TechnicalRegistrationModel>>
  register(TechnicalRegistrationRequest request) async {
    try {
      if (!request.isValid)
        return const Left(
          TechnicalRegistrationFailure(
            messages: {
              'ar': 'كمّلي البيانات والمستندات المطلوبة ووافقي على الشروط',
              'en':
              'Complete all required fields and documents and accept the terms',
            },
          ),
        );
      if (!await network.networkInfo.isConnected)
        return const Left(
          TechnicalRegistrationFailure(
            messages: {
              'ar': 'مفيش اتصال بالإنترنت',
              'en': 'No internet connection',
            },
          ),
        );
      final form = FormData.fromMap(request.fields);
      form.fields.addAll(request.arrayFields);
      for (final key in TechnicalRegistrationRequest.documentKeys) {
        final path = request.documents[key]!;
        if (![
          'jpg',
          'jpeg',
          'png',
        ].contains(path.toLowerCase().split('.').last) ||
            !await File(path).exists() ||
            await File(path).length() > 5 * 1024 * 1024) {
          return const Left(
            TechnicalRegistrationFailure(
              messages: {
                'ar':
                'المستندات لازم تكون JPG أو JPEG أو PNG وبحد أقصى 5 ميجابايت للصورة',
                'en': 'Documents must be JPG, JPEG or PNG, up to 5 MB each',
              },
            ),
          );
        }
        form.files.add(MapEntry(key, await MultipartFile.fromFile(path)));
      }
      // Public registration endpoint: never attach a previous user's Bearer token.
      final response = await dioConsumer.post(
        EndPoints.technicalRegister,
        data: form,
        headers: {'Accept': 'application/json'},
      );
      if (response is! Map<String, dynamic> || response['status'] != true)
        return Left(TechnicalRegistrationFailure.fromJson(response));
      final result = TechnicalRegistrationModel.fromJson(response);
      await userData.clearAllUserData();
      await storage.saveToken(token: result.token);
      final user = result.user;
      userData.saveUserId(id: int.parse('${user['id']}'));
      userData.saveUserName(name: '${user['name'] ?? ''}');
      userData.saveUserEmail(email: '${user['email'] ?? ''}');
      userData.saveUserPhoneNumber(phoneNumber: '${user['phone'] ?? ''}');
      userData.saveUserAvatarUrl(avatar: '${user['avatar'] ?? ''}');
      await userData.saveAccountSession(
        accountType: result.access.accountType,
        isActive: result.access.isActive,
        registrationStatus: result.access.registrationStatus,
      );
      userData.saveUserStatus(isGuest: false);
      return Right(result);
    } catch (_) {
      return const Left(
        TechnicalRegistrationFailure(
          messages: {
            'ar': 'تعذر إكمال التسجيل، حاولي مرة أخرى',
            'en': 'Could not complete registration. Please try again.',
          },
        ),
      );
    }
  }
}

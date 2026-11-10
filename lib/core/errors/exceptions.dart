import 'package:dio/dio.dart';
import 'package:elite/core/errors/error_model.dart';

//!ServerException
class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException(this.errorModel);
}

//!CacheException
class CacheException implements Exception {
  final String errorMessage;
  CacheException({required this.errorMessage});
}

class BadCertificateException extends ServerException {
  BadCertificateException(super.errorModel);
}

class ConnectionTimeoutException extends ServerException {
  ConnectionTimeoutException(super.errorModel);
}

class BadResponseException extends ServerException {
  BadResponseException(super.errorModel);
}

class ReceiveTimeoutException extends ServerException {
  ReceiveTimeoutException(super.errorModel);
}

class ConnectionErrorException extends ServerException {
  ConnectionErrorException(super.errorModel);
}

class SendTimeoutException extends ServerException {
  SendTimeoutException(super.errorModel);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException(super.errorModel);
}

class ForbiddenException extends ServerException {
  ForbiddenException(super.errorModel);
}

class NotFoundException extends ServerException {
  NotFoundException(super.errorModel);
}

class CoefficientException extends ServerException {
  CoefficientException(super.errorModel);
}

class CancelException extends ServerException {
  CancelException(super.errorModel);
}

class UnknownException extends ServerException {
  UnknownException(super.errorModel);
}

handleDioException(DioException e) {
  ErrorModel errorModel() => e.response?.data is Map<String, dynamic>
      ? ErrorModel.fromJson(e.response!.data)
      : ErrorModel(
          status: e.response?.statusCode,
          errorMessage: e.message ?? 'Unknown error',
        );

  switch (e.type) {
    case DioExceptionType.connectionError:
      throw ConnectionErrorException(errorModel());
    case DioExceptionType.badCertificate:
      throw BadCertificateException(errorModel());
    case DioExceptionType.connectionTimeout:
      throw ConnectionTimeoutException(errorModel());

    case DioExceptionType.receiveTimeout:
      throw ReceiveTimeoutException(errorModel());

    case DioExceptionType.sendTimeout:
      throw SendTimeoutException(errorModel());

    case DioExceptionType.transformTimeout:
      throw UnknownException(errorModel());

    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400: // Bad request

          throw BadResponseException(errorModel());

        case 401: //unauthorized
          throw UnauthorizedException(errorModel());

        case 403: //forbidden
          throw ForbiddenException(errorModel());

        case 404: //not found
          throw NotFoundException(errorModel());

        case 409: //coefficient

          throw CoefficientException(errorModel());

        case 504: // Server Exception

          throw BadResponseException(ErrorModel(
              status: 504,
              errorMessage: e.response?.data?.toString() ?? 'Server error'));

        default:
          throw BadResponseException(errorModel());
      }

    case DioExceptionType.cancel:
      throw CancelException(errorModel());

    case DioExceptionType.unknown:
      throw UnknownException(errorModel());
  }
}

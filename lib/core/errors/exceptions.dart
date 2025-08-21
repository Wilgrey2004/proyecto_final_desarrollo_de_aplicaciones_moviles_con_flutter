abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

class BadRequestException extends AppException {
  const BadRequestException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends AppException {
  const ForbiddenException(String message) : super(message);
}

class NotFoundException extends AppException {
  const NotFoundException(String message) : super(message);
}

class LocationException extends AppException {
  const LocationException(String message) : super(message);
}

class CameraException extends AppException {
  const CameraException(String message) : super(message);
}

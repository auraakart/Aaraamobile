sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Unable to reach the service. Please try again.',
  ]);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Your session is not authorized for this request.',
  ]);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class ServerException extends AppException {
  const ServerException([
    super.message = 'The service is temporarily unavailable. Please try again.',
  ]);
}

final class RepositoryException extends AppException {
  const RepositoryException([
    super.message = 'The request could not be completed. Please try again.',
  ]);
}

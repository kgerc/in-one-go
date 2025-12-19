// Base Exception
class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => message;
}

// Server Exception (API errors)
class ServerException extends AppException {
  const ServerException({required super.message});
}

// Network Exception (connectivity issues)
class NetworkException extends AppException {
  const NetworkException({required super.message});
}

// Parsing Exception (JSON/data parsing errors)
class ParsingException extends AppException {
  const ParsingException({required super.message});
}

// Cache Exception (local storage errors)
class CacheException extends AppException {
  const CacheException({required super.message});
}

// Authentication Exception (OAuth, login errors)
class AuthenticationException extends AppException {
  const AuthenticationException({required super.message});
}

// Permission Exception (microphone, calendar permissions)
class PermissionException extends AppException {
  const PermissionException({required super.message});
}

// Validation Exception (input validation)
class ValidationException extends AppException {
  const ValidationException({required super.message});
}

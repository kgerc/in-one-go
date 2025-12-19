import 'package:equatable/equatable.dart';

// Abstract Failure class (for clean architecture - domain layer)
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Parsing Failure
class ParsingFailure extends Failure {
  const ParsingFailure({required super.message});
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Authentication Failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message});
}

// Permission Failure
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Unexpected Failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

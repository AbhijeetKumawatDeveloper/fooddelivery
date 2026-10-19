import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => code != null
      ? '$runtimeType [$code]: $message'
      : '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred', super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'A local cache failure occurred',
    super.code,
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network connection failed',
    super.code,
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Requested resource not found',
    super.code,
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation requirements failed',
    super.code,
  ]);
}

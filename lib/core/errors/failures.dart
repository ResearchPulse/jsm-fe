import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'A server error occurred.',
    super.statusCode,
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection or network unreachable.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local cached data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}

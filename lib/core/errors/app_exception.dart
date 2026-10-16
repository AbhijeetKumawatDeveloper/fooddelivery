class DataException implements Exception {
  final String message;

  const DataException(this.message);

  @override
  String toString() => message;
}

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => code != null
      ? 'AppException [$code]: $message'
      : 'AppException: $message';
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'A server error occurred',
    super.code,
  ]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'A cache error occurred', super.code]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Requested resource not found',
    super.code,
  ]);
}

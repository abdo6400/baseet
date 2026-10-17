class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});
}

/// Base class for all app failures
abstract class Failure {
  final String message;
  final String? code;
  final Exception? originalException;

  Failure({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'Failure($code): $message';
}

/// Network-related failures
class NetworkFailure extends Failure {
  NetworkFailure({
    super.message = 'Network connection failed',
    super.code,
    super.originalException,
  });
}

/// Server-related failures
class ServerFailure extends Failure {
  ServerFailure({
    super.message = 'Server error occurred',
    super.code,
    super.originalException,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  CacheFailure({
    super.message = 'Cache operation failed',
    super.code,
    super.originalException,
  });
}

/// Parse-related failures (JSON parsing, etc.)
class ParseFailure extends Failure {
  ParseFailure({
    super.message = 'Failed to parse data',
    super.code,
    super.originalException,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
    super.originalException,
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code,
    super.originalException,
  });
}

/// User-friendly error messages
class ErrorMessages {
  ErrorMessages._();

  static const String networkUnavailable = 
      'Unable to connect. Please check your internet connection.';
  static const String serverError = 
      'Server is temporarily unavailable. Please try again later.';
  static const String cacheError = 
      'Unable to load cached data. Please try again.';
  static const String parseError = 
      'Unable to process the data. Please try again.';
  static const String notFound = 
      'The requested content was not found.';
  static const String genericError = 
      'Something went wrong. Please try again.';
  static const String timeoutError = 
      'Request timed out. Please check your connection and try again.';
}

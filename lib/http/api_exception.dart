class AIException implements Exception {
  /// The message to be displayed when the exception is thrown.
  final String message;

  AIException(this.message);

  @override
  String toString() {
    return message;
  }
}
class AIRequestException implements Exception {
  /// returns the error message of the request that failed, if any.
  final String message;

  /// returns the status code of the request that failed, if any.
  final int statusCode;

  /// This is thrown when a request fails.
  AIRequestException(this.message, this.statusCode);

  @override
  String toString() {
    return 'RequestFailedException{message: $message, statusCode: $statusCode}';
  }
}

/// Base for all expected, user-facing errors raised inside the app.
/// Infrastructure code should wrap platform exceptions in one of the
/// concrete subclasses so the presentation layer can map them to a
/// localized message via the `errorXxx` keys in the ARB files.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class FileMissingException extends AppException {
  const FileMissingException(super.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

class UnsupportedFormatException extends AppException {
  const UnsupportedFormatException(super.message);
}

class ReaderFailureException extends AppException {
  const ReaderFailureException(super.message);
}

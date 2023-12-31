abstract class KouchException extends Error {}

final class KouchAuthenticateException extends KouchException {
  final String error;
  KouchAuthenticateException(this.error);

  @override
  String toString() => error;
}

final class KouchDatabaseException extends KouchException {
  final String error;
  KouchDatabaseException(this.error);

  @override
  String toString() => error;
}
class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() =>
      'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.stackTrace});
}

class SyncException extends AppException {
  SyncException(super.message, {super.code, super.stackTrace});
}

class NoteException extends AppException {
  NoteException(super.message, {super.code, super.stackTrace});
}

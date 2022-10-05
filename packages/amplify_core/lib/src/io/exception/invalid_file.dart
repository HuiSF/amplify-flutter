import 'package:amplify_core/src/types/exception/amplify_exception.dart';

class InvalidFileException extends AmplifyException {
  const InvalidFileException({
    String? message,
    String? recoverySuggestion,
  }) : super(
          message ?? 'Invalid file.',
          recoverySuggestion: recoverySuggestion ??
              'Make sure to initialize AWSFile correctly.',
        );
}

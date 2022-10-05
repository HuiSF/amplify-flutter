import 'dart:io';

import 'package:amplify_core/src/io/aws_file.dart';
import 'package:amplify_core/src/io/exception/invalid_file.dart';
import 'package:async/async.dart';

class AWSFilePlatform extends AWSFile {
  AWSFilePlatform.fromFile(File file)
      : _inputFile = file,
        super.protected();

  AWSFilePlatform.fromPath(String path, {String? name})
      : _inputFile = File(path),
        super.protected(name: name);

  AWSFilePlatform.fromStream(
    Stream<List<int>> inputStream, {
    String? name,
    String? contentType,
  })  : _inputFile = null,
        super.protected(
          name: name,
          inputStream: inputStream,
          contentType: contentType,
        );

  AWSFilePlatform.fromData(
    List<int> data, {
    String? name,
    String? contentType,
  })  : _inputFile = null,
        super.protected(
          inputBytes: data,
          name: name,
          contentType: contentType,
        );

  final File? _inputFile;

  @override
  ChunkedStreamReader<int> getChunkedStreamReader() {
    final file = _inputFile;
    if (file != null) {
      return ChunkedStreamReader(file.openRead());
    }

    final inputStream = super.inputStream;
    if (inputStream != null) {
      return ChunkedStreamReader(inputStream);
    }

    final inputBytes = super.inputBytes;
    if (inputBytes != null) {
      return ChunkedStreamReader(Stream.fromIterable([inputBytes]));
    }

    throw const InvalidFileException();
  }
}

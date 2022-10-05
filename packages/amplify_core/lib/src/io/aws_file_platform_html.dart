import 'dart:html';

import 'package:amplify_core/src/io/aws_file.dart';
import 'package:amplify_core/src/io/exception/invalid_file.dart';
import 'package:async/async.dart';

const _readStreamChunkSize = 64 * 1024;

class AWSFilePlatform extends AWSFile {
  AWSFilePlatform.fromFile(File file)
      : _inputFile = file,
        _inputBlob = null,
        super.protected();

  AWSFilePlatform.fromBlob(Blob blob)
      : _inputBlob = blob,
        _inputFile = null,
        super.protected();

  AWSFilePlatform.fromPath(
    String path, {
    super.name,
  })  : _inputFile = null,
        _inputBlob = null,
        super.protected(path: path);

  AWSFilePlatform.fromStream(
    Stream<List<int>> stream, {
    String? name,
    String? contentType,
  })  : _inputFile = null,
        _inputBlob = null,
        super.protected(
          inputStream: stream,
          name: name,
          contentType: contentType,
        );

  AWSFilePlatform.fromData(
    List<int> data, {
    String? name,
    String? contentType,
  })  : _inputBlob = Blob(data, contentType),
        _inputFile = null,
        super.protected(
          inputBytes: data,
          name: name,
          contentType: contentType,
        );

  final File? _inputFile;
  final Blob? _inputBlob;

  @override
  ChunkedStreamReader<int> getChunkedStreamReader() {
    final file = _inputFile ?? _inputBlob;
    if (file != null) {
      return ChunkedStreamReader(_getReadStream(file));
    }

    final inputStream = super.inputStream;
    if (inputStream != null) {
      return ChunkedStreamReader(inputStream);
    }

    final inputBytes = super.inputBytes;
    if (inputBytes != null) {
      return ChunkedStreamReader(Stream.fromIterable([inputBytes]));
    }

    final path = super.path;
    if (path != null) {
      return ChunkedStreamReader(_getReadStreamFromPath(path));
    }

    throw const InvalidFileException();
  }

  static Stream<List<int>> _getReadStream(Blob blob) async* {
    final fileReader = FileReader();
    var currentPosition = 0;

    while (currentPosition < blob.size) {
      final readRange = currentPosition + _readStreamChunkSize > blob.size
          ? blob.size
          : currentPosition + _readStreamChunkSize;
      final blobToRead = blob.slice(currentPosition, readRange);
      fileReader.readAsArrayBuffer(blobToRead);
      await fileReader.onLoad.first;
      yield fileReader.result as List<int>;
      currentPosition += _readStreamChunkSize;
    }
  }

  static Stream<List<int>> _getReadStreamFromPath(String path) async* {
    late HttpRequest request;
    try {
      request = await HttpRequest.request(path, responseType: 'blob');
    } on ProgressEvent catch (e) {
      if (e.type == 'error') {
        throw const InvalidFileException(
          message: 'Could resolve file blob from provide path.',
          recoverySuggestion:
              'Ensure the file `path` in Web is an accessible url.',
        );
      }
      rethrow;
    }

    final retrievedBlob = request.response as Blob?;

    if (retrievedBlob == null) {
      throw const InvalidFileException(
        message: 'The retrieved blob cannot be null.',
        recoverySuggestion:
            'Ensure the file `path` in Web is an accessible url.',
      );
    }

    await for (final bytes in _getReadStream(retrievedBlob)) {
      yield bytes;
    }
  }
}

import 'dart:async';

import 'package:amplify_core/src/io/aws_file.dart';
import 'package:async/async.dart';

class AWSFilePlatform extends AWSFile {
  AWSFilePlatform() : super.protected();

  AWSFilePlatform.fromStream(
    Stream<List<int>> stream, {
    String? name,
    String? contentType,
  }) : super.protected(
          inputStream: stream,
          name: name,
          contentType: contentType,
        );

  AWSFilePlatform.fromPath(
    String path, {
    String? name,
    String? contentType,
  }) : super.protected(
          path: path,
          name: name,
          contentType: contentType,
        ) {
    throw UnimplementedError(
      'AWSFile is not available in the current runtime platform',
    );
  }

  AWSFilePlatform.fromData(
    List<int> data, {
    String? name,
    String? contentType,
  }) : super.protected(
          inputBytes: data,
          name: name,
          contentType: contentType,
        );

  @override
  ChunkedStreamReader<int> getChunkedStreamReader() {
    throw UnimplementedError(
      'getChunkedStreamReader is not available in the current runtime platform',
    );
  }
}

import 'package:async/async.dart';
import 'aws_file_platform.dart'
    if (dart.library.html) 'aws_file_html.dart'
    if (dart.library.io) 'aws_file_io.dart';

/// {@template amplify_core.io.aws_file}
/// A read only abstraction over platform File interface.
/// {@endtemplate}
abstract class AWSFile {
  /// Creates an [AWSFile] from a stream of bytes with specifying file `name`
  /// and `contentType`.
  factory AWSFile.fromStream(
    Stream<List<int>> stream, {
    String? name,
    String? contentType,
  }) = AWSFilePlatform.fromStream;

  /// Creates an [AWSFile] from a path with specifying file name.
  ///
  /// Make sure the file path is readable when using this factory.
  factory AWSFile.fromPath(
    String path, {
    String? name,
    String? contentType,
  }) = AWSFilePlatform.fromPath;

  /// Create an [AWSFile] from bytes.
  factory AWSFile.fromData(
    List<int> data, {
    String? name,
    String? contentType,
  }) = AWSFilePlatform.fromData;

  AWSFile.protected({
    this.path,
    this.inputStream,
    this.inputBytes,
    this.name,
    this.contentType,
  });

  final Stream<List<int>>? inputStream;
  final List<int>? inputBytes;
  final String? name;
  final String? path;
  final String? contentType;

  ChunkedStreamReader<int> getChunkedStreamReader();
}

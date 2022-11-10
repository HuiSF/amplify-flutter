// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: avoid_unused_constructor_parameters

import 'dart:async';

import 'package:amplify_core/src/io/aws_file.dart';
import 'package:async/async.dart';

/// {@template amplify_core.io.aws_file_platform}
/// A cross platform implementation of [AWSFile].
/// {@endtemplate}
class AWSFilePlatform extends AWSFile {
  AWSFilePlatform() : super.protected();

  /// {@macro amplify_core.io.aws_file.from_stream}
  AWSFilePlatform.fromStream(
    Stream<List<int>> stream, {
    String? name,
    String? contentType,
    required int size,
  }) : super.protected(
          stream: stream,
          name: name,
          contentType: contentType,
        );

  /// {@macro amplify_core.io.aws_file.from_path}
  AWSFilePlatform.fromPath(
    String path, {
    String? name,
  }) : super.protected(
          path: path,
          name: name,
        ) {
    throw UnimplementedError(
      'AWSFile is not available in the current runtime platform',
    );
  }

  /// {@macro amplify_core.io.aws_file.from_path}
  AWSFilePlatform.fromData(
    List<int> data, {
    String? name,
    String? contentType,
  }) : super.protected(
          bytes: data,
          name: name,
          contentType: contentType,
        );

  @override
  Future<int> get size {
    throw UnimplementedError(
      'size getter has not been implemented in the current runtime platform.',
    );
  }

  /// {@macro amplify_core.io.aws_file.chunked_reader}
  @override
  ChunkedStreamReader<int> getChunkedStreamReader() {
    throw UnimplementedError(
      'getChunkedStreamReader is not available in the current runtime platform',
    );
  }
}

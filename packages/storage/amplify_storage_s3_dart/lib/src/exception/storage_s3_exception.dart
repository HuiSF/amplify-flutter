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

import 'package:amplify_core/amplify_core.dart';
import 'package:smithy/smithy.dart';

/// {@template amplify_storage_s3_dart.storage_s3_exception}
/// Represents exceptions that may be thrown calling Storage S3 plugin APIs.
/// {@endtemplate}
class StorageS3Exception extends StorageException {
  /// {@macro amplify_storage_s3_dart.storage_s3_exception}
  const StorageS3Exception(
    super.message, {
    required String super.recoverySuggestion,
    super.underlyingException,
  });

  /// Creates a [StorageS3Exception] from [UnknownSmithyHttpException] that
  /// represents an exception returned from S3 service.
  factory StorageS3Exception.fromUnknownSmithyHttpException(
    UnknownSmithyHttpException exception,
  ) {
    switch (exception.statusCode) {
      case 403:
        return StorageS3Exception(
          'S3 access denied when making the API call.',
          recoverySuggestion:
              'Please check if specified correct `StorageAccessLevel` and `targetIdentityId` when making the API call.',
          underlyingException: exception,
        );
      default:
        return StorageS3Exception.unknownServiceException(exception);
    }
  }

  /// Creates a [StorageS3Exception] that represents an error that shouldn't
  /// happen normally.
  factory StorageS3Exception.unknownException() {
    return const StorageS3Exception(
      'Unknown exception occurred.',
      recoverySuggestion:
          'This exception is not expected. Please try again. If the exception persists, please file an issue at https://github.com/aws-amplify/amplify-flutter/issues',
    );
  }

  /// Creates a [StorageS3Exception] that represents an unexpected error
  /// returned from S3 service.
  factory StorageS3Exception.unknownServiceException([Object? exception]) {
    return StorageS3Exception(
      'Unknown service exception occurred.',
      recoverySuggestion:
          'This exception is not expected. Please try again. If the exception persists, please file an issue at https://github.com/aws-amplify/amplify-flutter/issues',
      underlyingException: exception,
    );
  }
}

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
import 'package:amplify_storage_s3_dart/amplify_storage_s3_dart.dart';

/// {@template storage.amplify_storage_s3.download_data_options}
/// The configurable parameters invoking Storage S3 plugin `downloadData` API.
/// {@endtemplate}
class S3StorageDownloadDataOptions extends StorageDownloadDataOptions {
  /// {@macro storage.amplify_storage_s3.download_data_options}
  const S3StorageDownloadDataOptions({
    StorageAccessLevel storageAccessLevel = StorageAccessLevel.guest,
    bool getProperties = false,
    S3DataBytesRange? bytesRange,
  }) : this._(
          storageAccessLevel: storageAccessLevel,
          bytesRange: bytesRange,
          getProperties: getProperties,
        );

  const S3StorageDownloadDataOptions._({
    super.storageAccessLevel = StorageAccessLevel.guest,
    this.getProperties = false,
    this.bytesRange,
    this.targetIdentityId,
  });

  /// {@macro storage.amplify_storage_s3.download_data_options}
  ///
  /// Use when call `downloadData` on an object that belongs to other user
  /// (identified by `targetIdentityId`) rather than the currently signed user.
  const S3StorageDownloadDataOptions.forIdentity(
    String targetIdentityId, {
    bool getProperties = false,
    S3DataBytesRange? bytesRange,
  }) : this._(
          storageAccessLevel: StorageAccessLevel.protected,
          targetIdentityId: targetIdentityId,
          getProperties: getProperties,
          bytesRange: bytesRange,
        );

  /// Data bytes range to download from the object.
  final S3DataBytesRange? bytesRange;

  /// The identity id of another user who uploaded the object that to download
  /// data from.
  ///
  /// Should be set by `S3StorageDownloadDataOptions.forIdentity()`
  /// constructor.
  final String? targetIdentityId;

  /// The flag that indicates whether to retrieve properties for the download
  /// result object via the `getProperties` API.
  final bool getProperties;
}

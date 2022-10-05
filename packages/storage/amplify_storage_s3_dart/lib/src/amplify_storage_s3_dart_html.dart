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
import 'package:amplify_storage_s3_dart/src/amplify_storage_s3_dart_base.dart';
import 'package:amplify_storage_s3_dart/src/utils_html/dom_helper.dart';
import 'package:meta/meta.dart';

/// {@macro amplify_storage_s3_dart.amplify_storage_s3_plugin_dart}
class AmplifyStorageS3Dart extends AmplifyStorageS3DartBase {
  /// {@macro amplify_storage_s3_dart.amplify_storage_s3_plugin_dart}
  AmplifyStorageS3Dart({
    super.delimiter,
    super.prefixResolver,
    @visibleForTesting super.dependencyManagerOverride,
  });

  /// {@macro amplify_storage_s3_dart.plugin_key}
  static const StoragePluginKey<
      S3StorageListOperation,
      S3StorageListOptions,
      S3StorageGetPropertiesOperation,
      S3StorageGetPropertiesOptions,
      S3StorageGetUrlOperation,
      S3StorageGetUrlOptions,
      StorageUploadDataOperation,
      StorageUploadDataOptions,
      S3StorageDownloadDataOperation,
      S3StorageDownloadDataOptions,
      S3StorageDownloadFileOperation,
      S3StorageDownloadFileOptions,
      S3StorageCopyOperation,
      S3StorageCopyOptions,
      S3StorageMoveOperation,
      S3StorageMoveOptions,
      S3StorageRemoveOperation,
      S3StorageRemoveOptions,
      S3StorageRemoveManyOperation,
      S3StorageRemoveManyOptions,
      S3StorageItem,
      S3TransferProgress,
      AmplifyStorageS3DartBase> pluginKey = AmplifyStorageS3DartBase.pluginKey;

  @override
  S3StorageDownloadFileOperation downloadFile({
    required StorageDownloadFileRequest request,
    void Function(S3TransferProgress)? onProgress,
  }) {
    Future<void> noOp() async {}
    return S3StorageDownloadFileOperation(
      request: StorageDownloadFileRequest(
        key: request.key,
        localFile: request.localFile,
        options: request.options as S3StorageDownloadFileOptions?,
      ),
      result: _downloadUrl(request),
      resume: noOp,
      pause: noOp,
      cancel: noOp,
    );
  }

  Future<S3StorageDownloadFileResult> _downloadUrl(
    StorageDownloadFileRequest request,
  ) async {
    final s3Options = request.options as S3StorageDownloadFileOptions? ??
        S3StorageDownloadFileOptions(
          storageAccessLevel: s3pluginConfig.defaultAccessLevel,
        );
    final url = (await storageS3Service.getUrl(
      key: request.key,
      options: S3StorageGetUrlOptions(
        storageAccessLevel: s3Options.storageAccessLevel,
        expiresIn: const Duration(minutes: 5),
      ),
    ))
        .url;

    DomHelper.instance.download(
      url: url.toString(),
      name: request.localFile.name,
    );

    return S3StorageDownloadFileResult(
      downloadedItem: s3Options.getProperties
          ? (await storageS3Service.getProperties(
              key: request.key,
              options: S3StorageGetPropertiesOptions(
                storageAccessLevel: s3Options.storageAccessLevel,
              ),
            ))
              .storageItem
          : S3StorageItem(key: request.key),
      localFile: request.localFile,
    );
  }
}

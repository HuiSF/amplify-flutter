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
import 'package:amplify_storage_s3_dart/src/prefix_resolver/storage_access_level_aware_prefix_resolver.dart';
import 'package:amplify_storage_s3_dart/src/storage_s3_service/storage_s3_service.dart';
import 'package:meta/meta.dart';

/// {@template amplify_storage_s3_dart.amplify_storage_s3_plugin_dart}
/// The Dart S3 plugin the Amplify Storage Category.
/// {@endtemplate}
class AmplifyStorageS3Dart extends StoragePluginInterface
    with AWSDebuggable, AWSLoggerMixin {
  /// {@macro amplify_storage_s3_dart.amplify_storage_s3_plugin_dart}
  AmplifyStorageS3Dart({
    String? delimiter,
    StorageS3PrefixResolver? prefixResolver,
    @visibleForTesting DependencyManager? dependencyManagerOverride,
  })  : _delimiter = delimiter,
        _prefixResolver = prefixResolver,
        _dependencyManagerOverride = dependencyManagerOverride,
        _dependencyManager = dependencyManagerOverride ?? DependencyManager();

  final String? _delimiter;
  final DependencyManager _dependencyManager;
  final DependencyManager? _dependencyManagerOverride;

  late final S3PluginConfig _s3pluginConfig;
  late final StorageS3Service _storageS3Service;

  StorageS3PrefixResolver? _prefixResolver;

  /// Gets prefix resolver for testing
  @visibleForTesting
  StorageS3PrefixResolver? get prefixResolver => _prefixResolver;

  @override
  Future<void> configure({
    AmplifyConfig? config,
    required AmplifyAuthProviderRepository authProviderRepo,
  }) async {
    final s3PluginConfig = config?.storage?.awsPlugin;

    if (s3PluginConfig == null) {
      throw const StorageException('No Storage config detected.');
    }

    _s3pluginConfig = s3PluginConfig;

    final identityProvider = authProviderRepo
        .getAuthProvider(APIAuthorizationType.userPools.authProviderToken);

    if (identityProvider == null) {
      throw const StorageException(
        'No Cognito User Pool provider found for Storage.',
        recoverySuggestion:
            'If you haven\'t already, please add amplify_auth_cognito plugin to your App.',
      );
    }

    _prefixResolver ??= StorageAccessLevelAwarePrefixResolver(
      delimiter: _delimiter,
      identityProvider: identityProvider,
    );

    final credentialsProvider = authProviderRepo
        .getAuthProvider(APIAuthorizationType.iam.authProviderToken);

    if (credentialsProvider == null) {
      throw const StorageException(
        'No credential provider found for Storage.',
        recoverySuggestion:
            'If you haven\'t already, please add amplify_auth_cognito plugin to your App.',
      );
    }

    //`_dependencyManagerOverride` should be available only in unit tests
    if (_dependencyManagerOverride == null) {
      _storageS3Service = StorageS3Service(
        credentialsProvider: credentialsProvider,
        defaultBucket: _s3pluginConfig.bucket,
        defaultRegion: _s3pluginConfig.region,
        prefixResolver: _prefixResolver!,
        logger: logger,
      );
      _dependencyManager.addInstance<StorageS3Service>(_storageS3Service);
    }
  }

  @override
  StorageListOperation list({
    required StorageListRequest request,
  }) {
    final s3Request = StorageS3ListRequest.fromStorageListRequest(request);
    final s3Service = _dependencyManager.getOrCreate<StorageS3Service>();

    return StorageS3ListOperation(
      request: s3Request,
      result: s3Service.list(
        path: request.path ?? '',
        options: s3Request.options ??
            StorageS3ListOptions(
              storageAccessLevel: _s3pluginConfig.defaultAccessLevel,
            ),
      ),
    );
  }

  @override
  StorageGetPropertiesOperation getProperties({
    required StorageGetPropertiesRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  StorageGetUrlOperation getUrl({
    required StorageGetUrlRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  StorageUploadDataOperation uploadData({
    required StorageUploadDataRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  StorageRemoveOperation remove({
    required StorageRemoveRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  StorageRemoveManyOperation removeMany({
    required StorageRemoveManyRequest request,
  }) {
    throw UnimplementedError();
  }

  // TODO(HuiSF): add interface for remaining APIs
  //  uploadFile, downloadFile, downloadData

  @override
  String get runtimeTypeName => 'AmplifyStorageS3Dart';
}

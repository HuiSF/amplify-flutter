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

import 'dart:async';

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3_dart/amplify_storage_s3_dart.dart';
import 'package:amplify_storage_s3_dart/src/sdk/s3.dart' as s3;
import 'package:amplify_storage_s3_dart/src/storage_s3_service/storage_s3_service.dart';
import 'package:meta/meta.dart';

/// {@template amplify_storage_s3_dart.download_state}
/// State of a download task.
/// {@endtemplate}
@internal
enum DownloadState {
  /// The download task is in progress.
  inProgress('inProgress'),

  /// The download task is paused.
  paused('paused'),

  /// The download task is canceled.
  canceled('canceled');

  /// {@macro amplify_storage_s3_dart.download_state}
  const DownloadState(this.value);

  /// The string value of the [DownloadState].
  final String value;
}

/// {@template amplify_storage_s3_dart.download_task}
/// A task created to fulfill a download operation.
/// {@template}
@internal
class S3DownloadTask {
  /// {@macro amplify_storage_s3_dart.download_task}
  S3DownloadTask({
    required s3.S3Client s3Client,
    required S3StoragePrefixResolver prefixResolver,
    required String bucket,
    required String key,
    required S3StorageDownloadDataOptions options,
    void Function(S3TransferProgress)? onProgress,
    required AWSLogger logger,
  })  : _downloadedBytes = [],
        _downloadCompleter = Completer<S3StorageDownloadDataResult>(),
        _s3Client = s3Client,
        _bucket = bucket,
        _key = key,
        _downloadDataOptions = options,
        _onProgress = onProgress,
        _prefixResolver = prefixResolver,
        _logger = logger,
        _downloadedBytesSize = 0;

  final List<int> _downloadedBytes;

  final s3.S3Client _s3Client;
  final S3StoragePrefixResolver _prefixResolver;
  final String _bucket;
  final String _key;
  final S3StorageDownloadDataOptions _downloadDataOptions;
  final void Function(S3TransferProgress)? _onProgress;
  final AWSLogger _logger;

  // the Completer to complete the final `result` Future.
  final Completer<S3StorageDownloadDataResult> _downloadCompleter;

  // the subscription to `S3Client.getObject` returned stream body.
  // Can be reassigned when pause/resume.
  late StreamSubscription<List<int>> _bytesSubscription;

  int _downloadedBytesSize;

  // The completer to ensure `pause`, `resume` and `cancel` to be executed
  // when an upcoming or ongoing bytes stream can be canceled.
  late Completer<void> _getObjectCompleter;
  late Completer<void> _pauseCompleter;

  late DownloadState _state;
  late final String _resolvedKey;

  // Total bytes that need to be downloaded, this field is set when the
  // very first `S3Client.getObject` response returns, value is from the
  // response header.
  late final int _totalBytes;

  Future<void> get _getObjectInitiated => _getObjectCompleter.future;
  Future<void> get _resumeCompleted => _pauseCompleter.future;

  /// The result of a download task
  Future<S3StorageDownloadDataResult> get result => _downloadCompleter.future;

  /// Starts the `S3DownloadTask`.
  ///
  /// This function should only be called internally
  @internal
  Future<void> start() async {
    _resetGetObjectCompleter();

    _state = DownloadState.inProgress;

    final resolvedPrefix = await StorageS3Service.getResolvedPrefix(
      prefixResolver: _prefixResolver,
      logger: _logger,
      storageAccessLevel: _downloadDataOptions.storageAccessLevel,
      identityId: _downloadDataOptions.targetIdentityId,
    );

    _resolvedKey = '$resolvedPrefix$_key';

    final getObjectOutput = await _getObject(
      bucket: _bucket,
      key: _resolvedKey,
      bytesRange: _downloadDataOptions.bytesRange,
    );

    final remoteSize = getObjectOutput.contentLength?.toInt();
    if (remoteSize == null) {
      throw S3StorageException.unexpectedContentLengthFromService();
    }
    _totalBytes = remoteSize;
    _listenToBytesSteam(getObjectOutput.body);
  }

  /// Pauses the [S3DownloadTask].
  Future<void> pause() async {
    // ensure the task has actually started before pausing
    await _getObjectInitiated;

    if (_state == DownloadState.paused || _state == DownloadState.canceled) {
      return;
    }

    _resetPauseCompleter();

    // TODO(HuiSF): when it's ready, invoke `AWSHttpOperation.cancel` here
    //  to cancel the underlying http request
    await _bytesSubscription.cancel();
    _state = DownloadState.paused;
    _onProgress?.call(
      S3TransferProgress(
        totalBytes: _totalBytes,
        transferredBytes: _downloadedBytesSize,
        state: _state.value,
      ),
    );
    _pauseCompleter.complete();
  }

  /// Resumes the [S3DownloadTask] from paused state.
  Future<void> resume() async {
    // ensure the task has actually been paused before resuming
    await _resumeCompleted;

    if (_state == DownloadState.inProgress) {
      return;
    }

    if (_state == DownloadState.canceled) {
      throw const S3StorageException(
        'The download data task has been canceled and can\'t be resumed.',
        recoverySuggestion:
            'You can resume a task that is paused by calling `pause()`.',
      );
    }

    _resetGetObjectCompleter();

    _state = DownloadState.inProgress;

    final bytesRangeToDownload = S3DataBytesRange(
      start: _downloadedBytesSize,
      end: _totalBytes,
    );

    final getObjectOutput = await _getObject(
      bucket: _bucket,
      key: _resolvedKey,
      bytesRange: bytesRangeToDownload,
    );

    _listenToBytesSteam(getObjectOutput.body);
  }

  /// Cancels the [S3DownloadTask], and throws a [S3StorageException] to
  /// terminate.
  ///
  /// A canceled [S3DownloadTask] is not resumable.
  Future<void> cancel() async {
    if (_state == DownloadState.canceled) {
      return;
    }

    _state = DownloadState.canceled;

    // TODO(HuiSF): when it's ready, invoke `AWSHttpOperation.cancel` here
    // to cancel the underlying http request
    await _bytesSubscription.cancel();
    _onProgress?.call(
      S3TransferProgress(
        totalBytes: _totalBytes,
        transferredBytes: _downloadedBytesSize,
        state: _state.value,
      ),
    );
    _downloadCompleter
        .completeError(S3StorageException.controllableOperationCanceled());
  }

  void _resetGetObjectCompleter() {
    _getObjectCompleter = Completer();
  }

  void _resetPauseCompleter() {
    _pauseCompleter = Completer();
  }

  void _listenToBytesSteam(Stream<List<int>>? bytesStream) {
    if (bytesStream == null) {
      throw S3StorageException.unexpectedGetObjectBody();
    }
    _bytesSubscription = bytesStream.listen((bytes) {
      _downloadedBytes.addAll(bytes);
      _downloadedBytesSize += bytes.length;
      _onProgress?.call(
        S3TransferProgress(
          transferredBytes: _downloadedBytesSize,
          totalBytes: _totalBytes,
          state: _state.value,
        ),
      );
    })
      ..onDone(() {
        if (_downloadedBytesSize == _totalBytes) {
          _downloadCompleter.complete(
            S3StorageDownloadDataResult(
              bytes: _downloadedBytes,
              downloadItem: S3StorageItem(
                key: _key,
              ),
            ),
          );
        } else {
          _downloadCompleter.completeError(
            S3StorageException.incompleteDownload(),
          );
        }
      })
      ..onError(_downloadCompleter.completeError);

    // After setting up the body stream listener, we consider the task is fully
    // started, and can be paused etc.
    _getObjectCompleter.complete();
  }

  Future<s3.GetObjectOutput> _getObject({
    required String bucket,
    required String key,
    required S3DataBytesRange? bytesRange,
  }) {
    final request = s3.GetObjectRequest.build((builder) {
      builder
        ..bucket = bucket
        ..key = key
        ..range = bytesRange?.headerString
        ..checksumMode = s3.ChecksumMode.enabled;
    });

    return _s3Client.getObject(request);
  }
}

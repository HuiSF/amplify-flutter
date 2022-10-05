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

/// Discrete state types of the download operation.
enum OperationStateType {
  /// {@macro amplify_storage_s3_dart.operation_not_started}
  notStarted,

  /// {@macro amplify_storage_s3_dart.operation_scheduled}
  scheduled,

  /// {@macro amplify_storage_s3_dart.operation_in_progress}
  inProgress,

  /// {@macro amplify_storage_s3_dart.operation_paused}
  paused,

  /// {@macro amplify_storage_s3_dart.operation_canceled}
  canceled,

  /// {@template amplify_storage_s3_dart.operation_success}
  success,

  /// {@template amplify_storage_s3_dart.operation_failure}
  failure,
}

/// Discrete states of the download operation.
abstract class OperationState extends StateMachineState<OperationStateType> {
  const OperationState._();

  /// {@macro amplify_storage_s3_dart.operation_not_started}
  const factory OperationState.notStarted() = OperationNotStarted;

  /// {@macro amplify_storage_s3_dart.operation_scheduled}
  const factory OperationState.scheduled() = OperationScheduled;

  /// {@macro amplify_storage_s3_dart.operation_in_progress}
  const factory OperationState.inProgress(S3TransferProgress progress) =
      OperationInProgress;

  /// {@macro amplify_storage_s3_dart.operation_paused}
  const factory OperationState.paused(S3TransferProgress progress) =
      OperationPaused;

  /// {@macro amplify_storage_s3_dart.operation_canceled}
  const factory OperationState.canceled() = OperationCanceled;

  /// {@template amplify_storage_s3_dart.operation_success}
  const factory OperationState.success() = OperationSuccess;

  /// {@template amplify_storage_s3_dart.operation_failure}
  const factory OperationState.failure(Exception exception) = OperationFailure;

  @override
  String get runtimeTypeName => 'OperationState';
}

/// {@template amplify_storage_s3_dart.operation_not_started}
/// The download operation has not yet started.
/// {@endtemplate}
class OperationNotStarted extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_not_started}
  const OperationNotStarted() : super._();

  @override
  OperationStateType get type => OperationStateType.notStarted;

  @override
  List<Object?> get props => [type];
}

/// {@template amplify_storage_s3_dart.operation_scheduled}
/// The download operation is starting.
/// {@endtemplate}
class OperationScheduled extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_scheduled}
  const OperationScheduled() : super._();

  @override
  OperationStateType get type => OperationStateType.scheduled;

  @override
  List<Object?> get props => [type];
}

/// {@template amplify_storage_s3_dart.operation_in_progress}
/// The download operation is in progress.
/// {@endtemplate}
class OperationInProgress extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_in_progress}
  const OperationInProgress(this.progress) : super._();

  /// [S3TransferProgress] of the download operation.
  final S3TransferProgress progress;

  @override
  OperationStateType get type => OperationStateType.inProgress;

  @override
  List<Object?> get props => [type, progress];
}

/// {@template amplify_storage_s3_dart.operation_paused}
/// The download operation is paused.
/// {@endtemplate}
class OperationPaused extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_paused}
  const OperationPaused(this.progress) : super._();

  /// [S3TransferProgress] of the download operation.
  final S3TransferProgress progress;

  @override
  OperationStateType get type => OperationStateType.paused;

  @override
  List<Object?> get props => [type, progress];
}

/// {@template amplify_storage_s3_dart.operation_canceled}
/// The download operation is canceled.
/// {@endtemplate}
class OperationCanceled extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_canceled}
  const OperationCanceled() : super._();

  @override
  OperationStateType get type => OperationStateType.canceled;

  @override
  List<Object?> get props => [type];
}

/// {@template amplify_storage_s3_dart.operation_success}
/// The download operation is canceled.
/// {@endtemplate}
class OperationSuccess extends OperationState {
  /// {@macro amplify_storage_s3_dart.operation_success}
  const OperationSuccess() : super._();

  @override
  OperationStateType get type => OperationStateType.success;

  @override
  List<Object?> get props => [type];
}

/// {@template amplify_storage_s3_dart.operation_failure}
/// The download operation is canceled.
/// {@endtemplate}
class OperationFailure extends OperationState with ErrorState {
  /// {@macro amplify_storage_s3_dart.operation_failure}
  const OperationFailure(this.exception) : super._();

  /// The exception thrown during download.
  @override
  final Exception exception;

  @override
  OperationStateType get type => OperationStateType.failure;

  @override
  List<Object?> get props => [type, exception];
}

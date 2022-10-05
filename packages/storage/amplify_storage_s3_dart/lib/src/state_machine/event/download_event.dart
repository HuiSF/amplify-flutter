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
import 'package:amplify_storage_s3_dart/src/state_machine/event/operation_event_type.dart';
import 'package:amplify_storage_s3_dart/src/state_machine/state/operation_state.dart';
import 'package:amplify_storage_s3_dart/src/storage_s3_service/service/task/s3_download_task.dart';

abstract class DownloadEvent
    extends StateMachineEvent<OperationEventType, OperationStateType> {
  const DownloadEvent._();

  @override
  String get runtimeTypeName => 'OperationEvent';
}

/// {@template amplify_auth_cognito.operation_scheduling}
/// The event to schedule an operation.
/// {@endtemplate}
class DownloadScheduling extends DownloadEvent {
  /// {@macro amplify_auth_cognito.operation_scheduling}
  const DownloadScheduling(this.downloadTask) : super._();

  /// The details of the download operation.
  final S3DownloadTask downloadTask;

  @override
  OperationEventType get type => OperationEventType.scheduling;

  @override
  List<Object?> get props => [type, downloadTask];
}

// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Flutter

enum PushNotificationOperationResult<Success> {
    case success(Success)
    case failure(FlutterError)
}

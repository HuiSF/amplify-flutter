// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import Foundation

private let completionHandlerIdKey = "completionHandlerId"

extension AmplifyPushNotificationsIosPlugin {
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // the cached token check is to reduce the frequence of emitting TOKEN_RECEIVED events
        // the deviceToken that client gets is still from the system directly
        if (cachedDeviceToken != token) {
            cachedDeviceToken = token;
            eventsStreamHandler.sendEvent(
                event: AmplifyPushNotificationsEvent(
                    event: NativeEvent.tokenReceived,
                    payload: ["token": token]
                )
            )
        }
    }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]
    ) -> Bool {
        if let remoteNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            if application.applicationState == .background {
                isBackgroundMode = true
            }

            if application.applicationState != .background {
                launchNotification = remoteNotification
            }
        }
        return true
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("registerForRemoteNotifications failed with error: \(error).")
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        if UIApplication.shared.applicationState == .background {
            let completionHandlerId = UUID().uuidString
            var userInfoCopy = userInfo

            remoteNotificationCompletionHandlers[completionHandlerId] = completionHandler
            userInfoCopy[completionHandlerIdKey] = completionHandlerId

            sendEvent(
                event: AmplifyPushNotificationsEvent(
                    event: NativeEvent.backgroundMessageReceived, payload: userInfoCopy
                )
            )
        } else if UIApplication.shared.applicationState == .inactive {
            if (isBackgroundMode) {
                isBackgroundMode = false
                launchNotification = userInfo
                sendEvent(
                    event: AmplifyPushNotificationsEvent(
                        event: NativeEvent.launchNotificationOpened, payload: userInfo
                    )
                )
            } else {
                sendEvent(
                    event: AmplifyPushNotificationsEvent(
                        event: NativeEvent.notificationOpened, payload: userInfo
                    )
                )
            }
        } else {
            sendEvent(
                event: AmplifyPushNotificationsEvent(
                    event: NativeEvent.foregroundMessageReceived, payload: userInfo
                )
            )
        }

        return true
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        application.registerForRemoteNotifications()
    }
}

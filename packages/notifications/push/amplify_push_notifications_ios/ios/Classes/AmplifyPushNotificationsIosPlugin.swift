// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import Foundation
import amplify_flutter_ios

private let pushNotificationMethodChannelName = "com.amazonaws.amplify/push_notification/method"

public class AmplifyPushNotificationsIosPlugin: NSObject, FlutterPlugin {
    private let methodChannel: FlutterMethodChannel

    internal var remoteNotificationCompletionHandlers: [String: (UIBackgroundFetchResult) -> Void] = [:]
    internal var isBackgroundMode = false

    internal let eventsStreamHandler: PushNotificationEventsStreamHandler
    internal var launchNotification: [AnyHashable: Any]?
    internal var cachedDeviceToken: String?

    init(
        eventsStreamHandler: PushNotificationEventsStreamHandler,
        methodChannel: FlutterMethodChannel
    ) {
        self.eventsStreamHandler = eventsStreamHandler
        self.methodChannel = methodChannel

        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let pluginInstance = AmplifyPushNotificationsIosPlugin(
            eventsStreamHandler: PushNotificationEventsStreamHandler(),
            methodChannel: FlutterMethodChannel(
                name: pushNotificationMethodChannelName,
                binaryMessenger: registrar.messenger()
            )
        )
        setUpEventChannels(registrar: registrar, pluginInstance: pluginInstance)
        registrar.addMethodCallDelegate(pluginInstance, channel: pluginInstance.methodChannel)
        registrar.addApplicationDelegate(pluginInstance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let atomicResult = AtomicResult(result, call.method)

        switch call.method {
        case "getPermissionStatus":
            getPermissionStatus { atomicResult($0) }
        case "requestPermissions":
            requestPermissions(args: call.arguments) { result in
                switch result {
                case .success(let granted):
                    atomicResult(granted)
                case .failure(let error):
                    atomicResult(error)
                }
            }
        case "getLaunchNotification":
            atomicResult(getLaunchNotification())
        case "getBadgeCount":
            atomicResult(getBadgeCount())
        case "setBadgeCount":
            setBadgeCount(args: call.arguments) { result in
                switch result {
                case .success(_):
                    atomicResult(true)
                case .failure(let error):
                    atomicResult(error)
                }
            }
        case "completeNotification":
            completeNotification(args: call.arguments) { result in
                switch result {
                case .success(_):
                    atomicResult(true)
                case .failure(let error):
                    atomicResult(error)
                }
            }
        default:
            atomicResult(FlutterMethodNotImplemented)
        }
    }

    private func requestPermissions(
        args: Any?,
        completionHandler: @escaping (PushNotificationOperationResult<Bool>) -> Void
    ) {
        guard let permissions = args as? [AnyHashable: Any] else {
            completionHandler(.failure(invalidArgumentsError))
            return
        }

        var options: UNAuthorizationOptions = []

        if permissions["alert"] as? Bool == true {
            options.insert(.alert)
        }

        if permissions["badge"] as? Bool == true {
            options.insert(.badge)
        }

        if permissions["sound"] as? Bool == true {
            options.insert(.sound)
        }

        if permissions["criticalAlert"] as? Bool == true {
            options.insert(.criticalAlert)
        }

        if permissions["provisional"] as? Bool == true {
            options.insert(.provisional)
        }

        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if (error != nil) {
                completionHandler(.failure(
                    FlutterError(code: "RequsetPermissionsError",
                                 message: "Error occurred requesting notitication center authorization.",
                                 details: error?.localizedDescription)))
            } else {
                completionHandler(.success(granted))
            }
        }
    }

    private func getPermissionStatus(completionHandler: @escaping (String) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var status: String

            switch settings.authorizationStatus {
            case .notDetermined:
                status = "NotDetermined"
            case .denied:
                status = "Denied"
            case .authorized:
                status = "Authorized"
            case .ephemeral:
                status = "Ephemeral"
            case .provisional:
                status = "Provisional"
            @unknown default:
                status = "NotDetermined"
            }
            completionHandler(status)
        }
    }

    private func getLaunchNotification() -> Any? {
        let launchNotification = self.launchNotification
        self.launchNotification = nil
        return launchNotification
    }

    private func getBadgeCount() -> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }

    private func setBadgeCount(
        args: Any?,
        completionHandler: @escaping (PushNotificationOperationResult<Bool>) -> Void
    ) {
        guard let count = args as? Int else {
            completionHandler(.failure(invalidArgumentsError))
            return
        }

        UIApplication.shared.applicationIconBadgeNumber = count
        completionHandler(.success(true))
    }

    private func completeNotification(
        args: Any?,
        completionHandler: @escaping (PushNotificationOperationResult<Bool>) -> Void
    ) {
        guard let completionHandlerId = args as? String else {
            completionHandler(.failure(invalidArgumentsError))
            return
        }

        if let completionHanlder = remoteNotificationCompletionHandlers[completionHandlerId] {
            completionHanlder(.noData)
            remoteNotificationCompletionHandlers.removeValue(forKey: completionHandlerId)
        }

        completionHandler(.success(true))
    }

    private static func setUpEventChannels(
        registrar: FlutterPluginRegistrar,
        pluginInstance: AmplifyPushNotificationsIosPlugin
    ) {
        eventChannels.forEach { eventChanelName in
            let eventChannel = FlutterEventChannel(
                name: eventChanelName, binaryMessenger: registrar.messenger()
            )

            eventChannel.setStreamHandler(pluginInstance.eventsStreamHandler)
        }
    }

    internal func sendEvent(event: AmplifyPushNotificationsEvent) {
        eventsStreamHandler.sendEvent(event: event)
    }
}

// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Flutter

private let channelNamePrefix = "com.amazonaws.amplify/push_notification/"

enum NativeEvent {
    case tokenReceived
    case notificationOpened
    case launchNotificationOpened
    case foregroundMessageReceived
    case backgroundMessageReceived

    var eventName: String {
        switch self {
        case .tokenReceived:
            return "TOKEN_RECEIVED"
        case .notificationOpened:
            return "NOTIFICATION_OPENED"
        case .launchNotificationOpened:
            return "LAUNCH_NOTIFICATION_OPENED"
        case .foregroundMessageReceived:
            return "FOREGROUND_MESSAGE_RECEIVED"
        case .backgroundMessageReceived:
            return "BACKGROUND_MESSAGE_RECEIVED"
        }
    }

    var eventChannelName: String {
        return "\(channelNamePrefix)event/\(self.eventName)"
    }
}

let eventChannels = [
    NativeEvent.tokenReceived.eventChannelName,
    NativeEvent.notificationOpened.eventChannelName,
    NativeEvent.launchNotificationOpened.eventChannelName,
    NativeEvent.foregroundMessageReceived.eventChannelName,
    NativeEvent.backgroundMessageReceived.eventChannelName
]

struct AmplifyPushNotificationsEvent {
    var event: NativeEvent
    var payload: [AnyHashable: Any]

    func toMap() -> [AnyHashable: Any] {
        return [
            "eventType": event.eventName,
            "payload": payload
        ]
    }
}

class PushNotificationEventsStreamHandler: NSObject, FlutterStreamHandler {
    private var eventQueues: [String: [AmplifyPushNotificationsEvent]] = [
        NativeEvent.tokenReceived.eventName: [],
        NativeEvent.notificationOpened.eventName: [],
        NativeEvent.foregroundMessageReceived.eventName: [],
        NativeEvent.backgroundMessageReceived.eventName: [],
        NativeEvent.launchNotificationOpened.eventName: []
    ]
    private var eventSinks: [String: FlutterEventSink?] = [:]

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {

        if let eventName = arguments as? String {
            eventSinks[eventName] = events
            flushEvents(eventName: eventName)
        }

        return nil
    }

    func onCancel(
        withArguments arguments: Any?
    ) -> FlutterError? {
        if let eventName = arguments as? String {
            eventSinks[eventName] = nil
            eventQueues[eventName]?.removeAll()
        }
        return nil
    }

    func sendEvent(event: AmplifyPushNotificationsEvent) {
        if let eventSink = eventSinks[event.event.eventName],
           let eventSink = eventSink {
            eventSink(event.toMap())
        } else {
            eventQueues[event.event.eventName]?.append(event)
        }
    }

    func sendError(event: NativeEvent, error: FlutterError) {
        if let eventSink = eventSinks[event.eventName],
           let eventSink = eventSink {
            eventSink(error)
        }
    }

    private func flushEvents(eventName: String) {
        if let eventSink = eventSinks[eventName],
        let eventSink = eventSink {
            while(eventQueues[eventName]?.isEmpty == false) {
                eventSink(eventQueues[eventName]?.removeFirst().toMap())
            }
        }
    }
}


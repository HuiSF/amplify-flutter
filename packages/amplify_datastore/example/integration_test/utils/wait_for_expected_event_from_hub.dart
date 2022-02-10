import 'dart:async';

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class WaitForExpectedEventFromHub<T extends HubEventPayload> {
  final Completer<T> _completer = Completer();
  late StreamSubscription hubSubscription;
  final Function eventMatcher;
  final String eventName;
  Duration timeout;

  WaitForExpectedEventFromHub({
    required this.eventMatcher,
    required this.eventName,
    Duration timeout = const Duration(seconds: 20),
  }) : this.timeout = timeout;

  Future<T> start() {
    hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (event) {
      if (event.eventName == this.eventName) {
        if (this.eventMatcher(event.payload)) {
          hubSubscription.cancel();
          _completer.complete(event.payload as T);
        }
      }
    });
    startTimeout();
    return _completer.future;
  }

  startTimeout() async {
    await Future.delayed(timeout);
    if (!_completer.isCompleted) {
      _completer
          .completeError('Timed out before getting expected event from hub!');
    }
  }
}

Future<SubscriptionDataProcessed> getExpectedSubscriptionDataProcessedEvent({
  required bool Function(SubscriptionDataProcessed) eventMatcher,
}) async {
  var getter = WaitForExpectedEventFromHub<SubscriptionDataProcessed>(
    eventName: 'subscriptionDataProcessed',
    eventMatcher: (HubEventPayload eventPayload) {
      if (eventPayload is SubscriptionDataProcessed) {
        return eventMatcher(eventPayload);
      }

      return false;
    },
  );
  return getter.start();
}

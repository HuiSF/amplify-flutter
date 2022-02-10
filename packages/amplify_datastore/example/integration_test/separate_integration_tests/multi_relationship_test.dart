/*
 * Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import 'package:amplify_datastore/amplify_datastore.dart';

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../utils/setup_utils.dart';
import '../utils/wait_for_expected_event_from_hub.dart';
import 'models/multi_relationship/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Model with multiple relationships', () {
    // schema
    // type MultiRelatedMeeting @model {
    //   id: ID! @primaryKey
    //   title: String!
    //   attendees: [MultiRelatedRegistration]
    //     @hasMany(indexName: "byMeeting", fields: ["id"])
    // }

    // type MultiRelatedAttendee @model {
    //   id: ID! @primaryKey
    //   meetings: [MultiRelatedRegistration]
    //     @hasMany(indexName: "byAttendee", fields: ["id"])
    // }

    // type MultiRelatedRegistration @model {
    //   id: ID! @primaryKey
    //   meetingId: ID @index(name: "byMeeting", sortKeyFields: ["attendeeId"])
    //   meeting: MultiRelatedMeeting! @belongsTo(fields: ["meetingId"])
    //   attendeeId: ID @index(name: "byAttendee", sortKeyFields: ["meetingId"])
    //   attendee: MultiRelatedAttendee! @belongsTo(fields: ["attendeeId"])
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var meetings = [
      MultiRelatedMeeting(title: 'test meeting 1'),
      MultiRelatedMeeting(title: 'test meeting 2'),
    ];
    var attendees = [
      MultiRelatedAttendee(),
      MultiRelatedAttendee(),
    ];
    var registrations = [
      MultiRelatedRegistration(attendee: attendees[0], meeting: meetings[0]),
      MultiRelatedRegistration(attendee: attendees[0], meeting: meetings[1]),
      MultiRelatedRegistration(attendee: attendees[1], meeting: meetings[1]),
    ];

    late Future<List<SubscriptionEvent<MultiRelatedMeeting>>> meetingEvents;
    late Future<List<SubscriptionEvent<MultiRelatedAttendee>>> attendeeEvents;
    late Future<List<SubscriptionEvent<MultiRelatedRegistration>>>
        registrationEvents;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      meetingEvents = Amplify.DataStore.observe(MultiRelatedMeeting.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(meetings.length)
          .toList();
      attendeeEvents = Amplify.DataStore.observe(MultiRelatedAttendee.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(attendees.length)
          .toList();
      registrationEvents = Amplify.DataStore.observe(
              MultiRelatedRegistration.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(registrations.length)
          .toList();
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedMeetings =
          await Amplify.DataStore.query(MultiRelatedMeeting.classType);
      expect(queriedMeetings, isEmpty);
      var queriedAttendees =
          await Amplify.DataStore.query(MultiRelatedAttendee.classType);
      expect(queriedAttendees, isEmpty);
      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(queriedRegistrations, isEmpty);
    });

    testWidgets('save meetings', (WidgetTester tester) async {
      for (var meeting in meetings) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is MultiRelatedMeeting) {
                return model.id == meeting.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(meeting);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(meeting);
        }
      }
      var queriedMeetings =
          await Amplify.DataStore.query(MultiRelatedMeeting.classType);
      expect(queriedMeetings, isNotEmpty);
    });

    testWidgets('save attendees', (WidgetTester tester) async {
      for (var attendee in attendees) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is MultiRelatedAttendee) {
                return model.id == attendee.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(attendee);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(attendee);
        }
      }
      var queriedAttendees =
          await Amplify.DataStore.query(MultiRelatedAttendee.classType);
      expect(queriedAttendees, isNotEmpty);
    });

    testWidgets('save registrations', (WidgetTester tester) async {
      for (var registration in registrations) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is MultiRelatedRegistration) {
                return model.id == registration.id &&
                    event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(registration);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(registration);
        }
      }
      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(queriedRegistrations, isNotEmpty);
    });

    testWidgets('query meetings', (WidgetTester tester) async {
      var queriedMeetings =
          await Amplify.DataStore.query(MultiRelatedMeeting.classType);
      for (var meeting in queriedMeetings) {
        expect(meetings.contains(meeting), isTrue);
      }
    });

    testWidgets('query attendees', (WidgetTester tester) async {
      var queriedAttendees =
          await Amplify.DataStore.query(MultiRelatedAttendee.classType);
      for (var attendee in queriedAttendees) {
        expect(attendees.contains(attendee), isTrue);
      }
    });

    testWidgets('query registraions', (WidgetTester tester) async {
      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      for (var registration in queriedRegistrations) {
        expect(
            registrations.indexWhere((e) =>
                    e.meeting == registration.meeting &&
                    e.attendee == registration.attendee) >
                -1,
            isTrue);
      }
    });

    testWidgets('observe meetings', (WidgetTester tester) async {
      var events = await meetingEvents;
      for (var i = 0; i < meetings.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedMeeting = event.item;
        var expectedMeeting = meetings[i];
        expect(eventType, EventType.create);
        expect(observedMeeting, expectedMeeting);
      }
    });

    testWidgets('observe attendees', (WidgetTester tester) async {
      var events = await attendeeEvents;
      for (var i = 0; i < attendees.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedAttendee = event.item;
        var expectedAttendee = attendees[i];
        expect(eventType, EventType.create);
        expect(observedAttendee, expectedAttendee);
      }
    });

    testWidgets('observe resgistrations', (WidgetTester tester) async {
      var events = await registrationEvents;
      for (var i = 0; i < registrations.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedRegistration = event.item;
        var expectedRegistration = registrations[i];
        expect(eventType, EventType.create);
        expect(observedRegistration, expectedRegistration);
      }
    });

    testWidgets('delete meeting (cascade delete associated registration)',
        (WidgetTester tester) async {
      var deletedMeeting = meetings[0]; // cascade delete registration[0]
      var deletedRegistration = registrations[0];

      if (enableCloudSync) {
        var mettingEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedMeeting) {
              return model.id == deletedMeeting.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );
        var registrationEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedRegistration) {
              return model.id == deletedRegistration.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedMeeting);

        var events =
            await Future.wait([mettingEventGetter, registrationEventGetter]);

        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(deletedMeeting);
      }

      var queriedMeetings =
          await Amplify.DataStore.query(MultiRelatedMeeting.classType);
      expect(queriedMeetings.length, meetings.length - 1);

      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(
          queriedRegistrations.indexWhere(
              (registration) => registration.meeting == deletedMeeting),
          -1);
    });

    testWidgets('delete attendee (cascade delete associated registration)',
        (WidgetTester tester) async {
      var deletedAttendee = attendees[0];
      var deletedRegistration = registrations[1];

      if (enableCloudSync) {
        var attendeeEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedAttendee) {
              return model.id == deletedAttendee.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );
        var registrationEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedRegistration) {
              return model.id == deletedRegistration.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedAttendee);

        var events =
            await Future.wait([attendeeEventGetter, registrationEventGetter]);
        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(deletedAttendee);
      }

      var queriedAttendees =
          await Amplify.DataStore.query(MultiRelatedAttendee.classType);
      expect(queriedAttendees.length, attendees.length - 1);

      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(
          queriedRegistrations.indexWhere(
              (registration) => registration.attendee == deletedAttendee),
          -1);
    });

    testWidgets('delete remaining meeting', (WidgetTester tester) async {
      var deletedMeeting = meetings[1];
      var deletedRegistration = registrations[2];

      if (enableCloudSync) {
        var mettingEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedMeeting) {
              return model.id == deletedMeeting.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );
        var cloudSyncedRegistrationEventGetter =
            getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedRegistration) {
              return model.id == deletedRegistration.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedMeeting);

        var events = await Future.wait(
            [mettingEventGetter, cloudSyncedRegistrationEventGetter]);
        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(deletedMeeting);
      }

      var queriedMeetings =
          await Amplify.DataStore.query(MultiRelatedMeeting.classType);
      expect(queriedMeetings, isEmpty);

      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(queriedRegistrations, isEmpty);
    });

    testWidgets('delete remaining attendee', (WidgetTester tester) async {
      var deletedAttendee = attendees[1];

      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is MultiRelatedAttendee) {
              return model.id == deletedAttendee.id &&
                  event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedAttendee);

        var event = await eventGetter;
        expect(event.element.deleted, isTrue);
      } else {
        await Amplify.DataStore.delete(deletedAttendee);
      }

      var queriedAttendees =
          await Amplify.DataStore.query(MultiRelatedAttendee.classType);
      expect(queriedAttendees, isEmpty);

      var queriedRegistrations =
          await Amplify.DataStore.query(MultiRelatedRegistration.classType);
      expect(queriedRegistrations, isEmpty);
    });
  });
}

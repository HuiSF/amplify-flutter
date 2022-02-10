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
import 'models/has_many_bidirectional/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HasMany (bi-directional with implicit connection field', () {
    // schema
    // type HasManyParentBiDirectionalExplicit @model {
    //   id: ID!
    //   name: String
    //   biDirectionalExplicitChildren: [HasManyChildBiDirectionalExplicit]
    //     @hasMany(indexName: "byHasManyParent", fields: ["id"])
    // }

    // type HasManyChildBiDirectionalExplicit @model {
    //   id: ID!
    //   name: String
    //   hasManyParentId: ID! @index(name: "byHasManyParent", sortKeyFields: ["name"])
    //   hasManyParent: HasManyParentBiDirectionalExplicit
    //     @belongsTo(fields: ["hasManyParentId"])
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var parent =
        HasManyParentBiDirectionalExplicit(name: 'has many parent (explicit)');
    var children = List.generate(
        5,
        (i) => HasManyChildBiDirectionalExplicit(
            name: 'has many child $i (explicit)', hasManyParent: parent));
    late Future<List<SubscriptionEvent<HasManyChildBiDirectionalExplicit>>>
        childEvents;
    late Future<SubscriptionEvent<HasManyParentBiDirectionalExplicit>>
        parentEvent;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      childEvents = Amplify.DataStore.observe(
              HasManyChildBiDirectionalExplicit.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(children.length)
          .toList();

      parentEvent = Amplify.DataStore.observe(
              HasManyParentBiDirectionalExplicit.classType)
          .first;
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedChildren = await Amplify.DataStore.query(
          HasManyChildBiDirectionalExplicit.classType);
      expect(queriedChildren, isEmpty);
      var queriedParents = await Amplify.DataStore.query(
          HasManyParentBiDirectionalExplicit.classType);
      expect(queriedParents, isEmpty);
    });

    testWidgets('save parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasManyParentBiDirectionalExplicit) {
              return model.id == parent.id && event.element.version == 1;
            }

            return false;
          },
        );

        await Amplify.DataStore.save(parent);

        var event = await eventGetter;
        expect(event.element.deleted, isFalse);
      } else {
        await Amplify.DataStore.save(parent);
      }
      var parents = await Amplify.DataStore.query(
          HasManyParentBiDirectionalExplicit.classType);
      expect(parents, isNotEmpty);
    });

    testWidgets('save children', (WidgetTester tester) async {
      for (var child in children) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is HasManyChildBiDirectionalExplicit) {
                return model.id == child.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(child);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(child);
        }
      }
      var queriedChildren = await Amplify.DataStore.query(
          HasManyChildBiDirectionalExplicit.classType);
      expect(queriedChildren, isNotEmpty);
    });

    testWidgets('query parent', (WidgetTester tester) async {
      var parents = await Amplify.DataStore.query(
          HasManyParentBiDirectionalExplicit.classType);
      var queriedParent = parents.single;
      expect(queriedParent, parent);
      expect(queriedParent.id, parent.id);
      expect(queriedParent.name, parent.name);
    });

    testWidgets('query children', (WidgetTester tester) async {
      var queriedChildren = await Amplify.DataStore.query(
          HasManyChildBiDirectionalExplicit.classType);
      for (var i = 0; i < children.length; i++) {
        var queriedChild = queriedChildren[i];
        var actualChild = children[i];
        expect(queriedChild, actualChild);
        expect(queriedChild.hasManyParent, actualChild.hasManyParent);
      }
    });

    testWidgets('observe parent', (WidgetTester tester) async {
      var event = await parentEvent;
      var observedParent = event.item;
      // full equality check can be performed since the parent has null children
      // and queries return null for nested hasMany data
      // this may need to be updated if/when https://github.com/aws-amplify/amplify-flutter/issues/642 is fully resolved
      expect(observedParent, parent);
    });

    testWidgets('observe children', (WidgetTester tester) async {
      var events = await childEvents;
      for (var i = 0; i < children.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedChild = event.item;
        var actualChild = children[i];
        expect(eventType, EventType.create);
        expect(observedChild, actualChild);
        expect(observedChild.hasManyParent, actualChild.hasManyParent);
      }
    });

    testWidgets('delete parent (cascade delete associated children)',
        (WidgetTester tester) async {
      if (enableCloudSync) {
        var parentEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasManyParentBiDirectionalExplicit) {
              return model.id == parent.id && event.element.version == 2;
            }

            return false;
          },
        );

        var childrenEventGetters =
            children.map((child) => getExpectedSubscriptionDataProcessedEvent(
                  eventMatcher: (event) {
                    var model = event.element.model;
                    if (model is HasManyChildBiDirectionalExplicit) {
                      return model.id == child.id && event.element.version == 2;
                    }

                    return false;
                  },
                ));

        await Amplify.DataStore.delete(parent);

        var parentChildrenEvents = [parentEventGetter];
        parentChildrenEvents.addAll(childrenEventGetters);
        var events = await Future.wait(parentChildrenEvents);

        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(parent);
      }
      var parents = await Amplify.DataStore.query(
          HasManyParentBiDirectionalExplicit.classType);
      expect(parents, isEmpty);

      var queriedChildren = await Amplify.DataStore.query(
          HasManyChildBiDirectionalExplicit.classType);
      expect(queriedChildren, isEmpty);
    });
  });
}

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
import 'models/has_many/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
      'HasMany (parent refers to children with explicit connection field and indexName)',
      () {
    // schema
    // type HasManyParent @model {
    //   id: ID!
    //   name: String
    //   explicitChildren: [HasManyChildExplicit]
    //     @hasMany(indexName: "byHasManyParent", fields: ["id"])
    // }
    // type HasManyChildExplicit @model {
    //   id: ID!
    //   name: String
    //   hasManyParentID: ID! @index(name: "byHasManyParent", sortKeyFields: ["name"])
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var parent = HasManyParent(name: 'has many parent (explicit)');
    var children = List.generate(
        5,
        (i) => HasManyChildExplicit(
            name: 'has many child $i (explicit)', hasManyParentID: parent.id));
    late Future<List<SubscriptionEvent<HasManyChildExplicit>>> childEvents;
    late Future<SubscriptionEvent<HasManyParent>> parentEvent;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      childEvents = Amplify.DataStore.observe(HasManyChildExplicit.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(children.length)
          .toList();

      parentEvent = Amplify.DataStore.observe(HasManyParent.classType).first;
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedChildren =
          await Amplify.DataStore.query(HasManyChildExplicit.classType);
      expect(queriedChildren, isEmpty);
      var queriedParents =
          await Amplify.DataStore.query(HasManyParent.classType);
      expect(queriedParents, isEmpty);
    });

    testWidgets('save parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasManyParent) {
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

      var parents = await Amplify.DataStore.query(HasManyParent.classType);
      expect(parents, isNotEmpty);
    });

    testWidgets('save children', (WidgetTester tester) async {
      for (var child in children) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is HasManyChildExplicit) {
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
      var queriedChildren =
          await Amplify.DataStore.query(HasManyChildExplicit.classType);
      expect(queriedChildren, isNotEmpty);
    });

    testWidgets('query parent', (WidgetTester tester) async {
      var parents = await Amplify.DataStore.query(HasManyParent.classType);
      var queriedParent = parents.single;
      expect(queriedParent, parent);
      expect(queriedParent.id, parent.id);
      expect(queriedParent.name, parent.name);
    });

    testWidgets('query children', (WidgetTester tester) async {
      var queriedChildren =
          await Amplify.DataStore.query(HasManyChildExplicit.classType);
      for (var i = 0; i < children.length; i++) {
        var queriedChild = queriedChildren[i];
        var actualChild = children[i];
        expect(queriedChild, actualChild);
        expect(queriedChild.hasManyParentID, actualChild.hasManyParentID);
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
        expect(observedChild.hasManyParentID, actualChild.hasManyParentID);
      }
    });

    testWidgets('delete parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasManyParent) {
              return model.id == parent.id && event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(parent);

        var event = await eventGetter;
        expect(event.element.deleted, isTrue);
      } else {
        await Amplify.DataStore.delete(parent);
      }

      var parents = await Amplify.DataStore.query(HasManyParent.classType);
      expect(parents, isEmpty);

      // cascade delete won't happen in this test case as there is no
      // connection field generated in the child model
      var queriedChildren =
          await Amplify.DataStore.query(HasManyChildExplicit.classType);
      expect(queriedChildren, isNotEmpty);
    });

    testWidgets('delete children', (WidgetTester tester) async {
      for (var child in children) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is HasManyChildExplicit) {
                return model.id == child.id && event.element.version == 2;
              }

              return false;
            },
          );

          await Amplify.DataStore.delete(child);

          var event = await eventGetter;
          expect(event.element.deleted, isTrue);
        } else {
          await Amplify.DataStore.delete(child);
        }
      }

      var queriedChildren =
          await Amplify.DataStore.query(HasManyChildExplicit.classType);
      expect(queriedChildren, isEmpty);
    });
  });
}

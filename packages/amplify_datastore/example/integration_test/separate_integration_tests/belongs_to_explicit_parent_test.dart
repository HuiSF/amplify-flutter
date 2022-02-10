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
import 'models/belongs_to/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BelongsTo (child refers to parent with explicit connection field)',
      () {
    // schema
    // type BelongsToParent @model {
    //   id: ID!
    //   name: String
    //   explicitChild: BelongsToChildExplicit @hasOne
    // }
    // type BelongsToChildExplicit @model {
    //   id: ID!
    //   name: String
    //   belongsToParentID: ID
    //   belongsToParent: BelongsToParent @belongsTo(fields: ["belongsToParentID"])
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var parent = BelongsToParent(name: 'belongs to parent');
    var child = BelongsToChildExplicit(
        name: 'belongs to child (explicit)', belongsToParent: parent);
    late Future<SubscriptionEvent<BelongsToParent>> parentEvent;
    late Future<SubscriptionEvent<BelongsToChildExplicit>> childEvent;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      parentEvent = Amplify.DataStore.observe(BelongsToParent.classType).first;
      childEvent =
          Amplify.DataStore.observe(BelongsToChildExplicit.classType).first;
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedChildren =
          await Amplify.DataStore.query(BelongsToChildExplicit.classType);
      expect(queriedChildren, isEmpty);
      var queriedParents =
          await Amplify.DataStore.query(BelongsToParent.classType);
      expect(queriedParents, isEmpty);
    });

    testWidgets('save parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is BelongsToParent) {
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

      var parents = await Amplify.DataStore.query(BelongsToParent.classType);
      expect(parents, isNotEmpty);
    });

    testWidgets('save child', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is BelongsToChildExplicit) {
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

      var children =
          await Amplify.DataStore.query(BelongsToChildExplicit.classType);
      expect(children, isNotEmpty);
    });

    testWidgets('query parent', (WidgetTester tester) async {
      var parents = await Amplify.DataStore.query(BelongsToParent.classType);
      var queriedParent = parents.single;
      expect(queriedParent, parent);
    });

    testWidgets('query child', (WidgetTester tester) async {
      var children =
          await Amplify.DataStore.query(BelongsToChildExplicit.classType);
      var queriedChild = children.single;
      expect(queriedChild, child);
      expect(queriedChild.belongsToParent, parent);
    });

    testWidgets('observe parent', (WidgetTester tester) async {
      var event = await parentEvent;
      var observedParent = event.item;
      expect(observedParent, parent);
    });

    testWidgets('observe child', (WidgetTester tester) async {
      var event = await childEvent;
      var observedChild = event.item;
      expect(observedChild, child);
      expect(observedChild.belongsToParent, parent);
    });

    testWidgets('delete parent (cascade delete child)',
        (WidgetTester tester) async {
      if (enableCloudSync) {
        var parentEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is BelongsToParent) {
              return model.id == parent.id && event.element.version == 2;
            }

            return false;
          },
        );

        var childEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is BelongsToChildExplicit) {
              return model.id == child.id && event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(parent);

        var events = await Future.wait([parentEventGetter, childEventGetter]);
        var parentEvent = events[0];
        var childEvent = events[1];

        expect(parentEvent.element.deleted, isTrue);
        expect(childEvent.element.deleted, isTrue);
      } else {
        await Amplify.DataStore.delete(parent);
      }

      var parents = await Amplify.DataStore.query(BelongsToParent.classType);
      expect(parents, isEmpty);
      var children =
          await Amplify.DataStore.query(BelongsToChildExplicit.classType);
      expect(children, isEmpty);
    });
  });
}

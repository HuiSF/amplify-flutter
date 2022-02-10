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
import 'models/has_one/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HasOne (parent refers to child with implicit connection field)', () {
    // schema
    // type HasOneParent @model {
    //   id: ID!
    //   name: String
    //   implicitChild: HasOneChild @hasOne
    // }
    // type HasOneChild @model {
    //   id: ID!
    //   name: String
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var child = HasOneChild(name: 'child');
    // Curretly with @hasOne, parent -> child relationship is created
    // by assign child.id to the connection field of the parent
    // the connection field is automatically generated when the child
    // is implicitly referred in the schema
    var parent = HasOneParent(
        name: 'HasOne (implicit)', hasOneParentImplicitChildId: child.id);
    late Future<SubscriptionEvent<HasOneChild>> childEvent;
    late Future<SubscriptionEvent<HasOneParent>> parentEvent;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      childEvent = Amplify.DataStore.observe(HasOneChild.classType).first;
      parentEvent = Amplify.DataStore.observe(HasOneParent.classType).first;
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedChildren =
          await Amplify.DataStore.query(HasOneChild.classType);
      expect(queriedChildren, isEmpty);
      var queriedParents =
          await Amplify.DataStore.query(HasOneParent.classType);
      expect(queriedParents, isEmpty);
    });

    testWidgets('save child', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasOneChild) {
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

      var children = await Amplify.DataStore.query(HasOneChild.classType);
      expect(children, isNotEmpty);
    });

    testWidgets('save parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasOneParent) {
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

      var parents = await Amplify.DataStore.query(HasOneParent.classType);
      expect(parents, isNotEmpty);
    });

    testWidgets('query parent', (WidgetTester tester) async {
      var parents = await Amplify.DataStore.query(HasOneParent.classType);
      var queriedParent = parents.single;
      // hasOne relationships do not return the child, so an exact match cannot be performed
      // to be updated if/when https://github.com/aws-amplify/amplify-flutter/issues/642 is fully resolved
      expect(queriedParent.id, parent.id);
      expect(queriedParent.name, parent.name);
      expect(queriedParent.hasOneParentImplicitChildId, child.id);
    });

    testWidgets('query child', (WidgetTester tester) async {
      var children = await Amplify.DataStore.query(HasOneChild.classType);
      var queriedChild = children.single;
      expect(queriedChild, child);
    });

    testWidgets('observe parent', (WidgetTester tester) async {
      var event = await parentEvent;
      var observedParent = event.item;
      // hasOne relationships in iOS do not return the child, so an exact match cannot be performed
      // to be updated if/when https://github.com/aws-amplify/amplify-flutter/issues/642 is fully resolved
      expect(observedParent.id, parent.id);
      expect(observedParent.name, parent.name);
      expect(observedParent.hasOneParentImplicitChildId, child.id);
    });

    testWidgets('observe child', (WidgetTester tester) async {
      var event = await childEvent;
      var observedChild = event.item;
      expect(observedChild, child);
    });

    // cascade delete currently doesn't support has one parent -> has one child
    testWidgets('delete parent', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasOneParent) {
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

      var parents = await Amplify.DataStore.query(HasOneParent.classType);
      expect(parents, isEmpty);
    });

    testWidgets('delete child', (WidgetTester tester) async {
      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is HasOneChild) {
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

      var children = await Amplify.DataStore.query(HasOneChild.classType);
      expect(children, isEmpty);
    });
  });
}

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

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../utils/setup_utils.dart';
import '../utils/wait_for_expected_event_from_hub.dart';
import 'models/basic_model_operation/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final enableCloudSync = shouldEnableCloudSync();
  group(
      'Basic model operation${enableCloudSync ? ' with API sync 🌩 enabled' : ''} -',
      () {
    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);
    });

    testWidgets(
        'should save a new model ${enableCloudSync ? 'and sync to cloud' : ''}',
        (WidgetTester tester) async {
      Blog testBlog = Blog(name: 'test blog');

      if (enableCloudSync) {
        // set an async getter to retrieve a desired hub event with a speicfic
        // event matcher
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) =>
              (event.element.model as Blog).id == testBlog.id &&
              // newly saved model at this step should have version: 1
              event.element.version == 1,
        );

        // save model locally and to sync to cloud
        await Amplify.DataStore.save(testBlog);

        // wait for the desired event to arrive
        var event = await eventGetter;
        expect(event.element.deleted, isFalse);
      } else {
        await Amplify.DataStore.save(testBlog);
      }

      var blogs = await Amplify.DataStore.query(Blog.classType);
      expect(blogs.length, 1);
      expect(blogs.contains(testBlog), isTrue);
    });

    testWidgets(
      'should update existing model ${enableCloudSync ? 'and sync to cloud' : ''}',
      (WidgetTester tester) async {
        // get previously saved model
        var testBlog = (await Amplify.DataStore.query(Blog.classType))[0];
        // update model
        var updatedTestBlog = testBlog.copyWith(name: "updated test blog");

        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) =>
                (event.element.model as Blog).id == updatedTestBlog.id &&
                // updated model at this step should have version: 2
                event.element.version == 2,
          );

          await Amplify.DataStore.save(updatedTestBlog);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(updatedTestBlog);
        }

        var updatedBlogs = await Amplify.DataStore.query(Blog.classType);

        // verify blog was updated
        expect(updatedBlogs.length, 1);
        expect(updatedBlogs.contains(updatedTestBlog), isTrue);
      },
    );

    testWidgets(
      'should delete existing model ${enableCloudSync ? 'and sync to cloud' : ''}',
      (WidgetTester tester) async {
        // get previously saved model
        var testBlog = (await Amplify.DataStore.query(Blog.classType))[0];

        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) =>
                (event.element.model as Blog).id == testBlog.id &&
                // deleted model at this step should have version: 3
                event.element.version == 3,
          );

          await Amplify.DataStore.delete(testBlog);

          var event = await eventGetter;
          expect(event.element.deleted, isTrue);
        } else {
          await Amplify.DataStore.delete(testBlog);
        }

        var blogs = await Amplify.DataStore.query(Blog.classType);

        // verify blog was deleted
        expect(blogs, isEmpty);
      },
    );
  });
}

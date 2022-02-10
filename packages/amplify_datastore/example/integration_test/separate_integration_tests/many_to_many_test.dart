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
import 'models/many_to_many/ModelProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Many-to-many', () {
    // schema
    // type Post @model {
    //   id: ID!
    //   title: String!
    //   rating: Int!
    //   tags: [Tag] @manyToMany(relationName: "PostTags")
    // }
    // type Tag @model {
    //   id: ID!
    //   label: String!
    //   posts: [Post] @manyToMany(relationName: "PostTags")
    // }
    final enableCloudSync = shouldEnableCloudSync();
    var posts = [
      Post(title: 'many to many post 1', rating: 10),
      Post(title: 'many to many post 2', rating: 5),
    ];
    var tags = [
      Tag(label: 'many to many tag 1'),
      Tag(label: 'many to maby tag 2')
    ];
    var postTags = [
      PostTags(post: posts[0], tag: tags[0]),
      PostTags(post: posts[0], tag: tags[0]),
      PostTags(post: posts[1], tag: tags[1]),
      PostTags(post: posts[1], tag: tags[1])
    ];
    late Future<List<SubscriptionEvent<Post>>> postEvents;
    late Future<List<SubscriptionEvent<Tag>>> tagEvents;
    late Future<List<SubscriptionEvent<PostTags>>> postTagsEvents;

    setUpAll(() async {
      await configureDataStore(
          enableCloudSync: enableCloudSync,
          modelProvider: ModelProvider.instance);

      postEvents = Amplify.DataStore.observe(Post.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(posts.length)
          .toList();
      tagEvents = Amplify.DataStore.observe(Tag.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(tags.length)
          .toList();
      postTagsEvents = Amplify.DataStore.observe(PostTags.classType)
          .where((event) => event.eventType == EventType.create)
          .distinct((prev, next) =>
              prev.eventType == next.eventType && prev.item.id == next.item.id)
          .take(postTags.length)
          .toList();
    });

    testWidgets('precondition', (WidgetTester tester) async {
      var queriedPosts = await Amplify.DataStore.query(Post.classType);
      expect(queriedPosts, isEmpty);
      var queriedTags = await Amplify.DataStore.query(Tag.classType);
      expect(queriedTags, isEmpty);
      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(queriedPostTags, isEmpty);
    });

    testWidgets('save post', (WidgetTester tester) async {
      for (var post in posts) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is Post) {
                return model.id == post.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(post);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(post);
        }
      }
      var queriedPosts = await Amplify.DataStore.query(Post.classType);
      expect(queriedPosts, isNotEmpty);
    });

    testWidgets('save tags', (WidgetTester tester) async {
      for (var tag in tags) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is Tag) {
                return model.id == tag.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(tag);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(tag);
        }
      }
      var queriedTags = await Amplify.DataStore.query(Tag.classType);
      expect(queriedTags, isNotEmpty);
    });

    testWidgets('save postTags', (WidgetTester tester) async {
      for (var postTag in postTags) {
        if (enableCloudSync) {
          var eventGetter = getExpectedSubscriptionDataProcessedEvent(
            eventMatcher: (event) {
              var model = event.element.model;
              if (model is PostTags) {
                return model.id == postTag.id && event.element.version == 1;
              }

              return false;
            },
          );

          await Amplify.DataStore.save(postTag);

          var event = await eventGetter;
          expect(event.element.deleted, isFalse);
        } else {
          await Amplify.DataStore.save(postTag);
        }
      }
      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(queriedPostTags, isNotEmpty);
    });

    testWidgets('query posts', (WidgetTester tester) async {
      var queriedPosts = await Amplify.DataStore.query(Post.classType);
      for (var post in queriedPosts) {
        expect(posts.contains(post), isTrue);
      }
    });

    testWidgets('query tags', (WidgetTester tester) async {
      var queriedTags = await Amplify.DataStore.query(Tag.classType);
      for (var tag in queriedTags) {
        expect(tags.contains(tag), isTrue);
      }
    });

    testWidgets('query postTags', (WidgetTester tester) async {
      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      for (var postTag in queriedPostTags) {
        expect(
            postTags.indexWhere(
                    (e) => e.post == postTag.post && e.tag == postTag.tag) >
                -1,
            isTrue);
      }
    });

    testWidgets('observe posts', (WidgetTester tester) async {
      var events = await postEvents;
      for (var i = 0; i < posts.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedPost = event.item;
        var expectedPost = posts[i];
        expect(eventType, EventType.create);
        expect(observedPost, expectedPost);
      }
    });

    testWidgets('observe tags', (WidgetTester tester) async {
      var events = await tagEvents;
      for (var i = 0; i < tags.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedTag = event.item;
        var expectedTag = tags[i];
        expect(eventType, EventType.create);
        expect(observedTag, expectedTag);
      }
    });

    testWidgets('observe postTags', (WidgetTester tester) async {
      var events = await postTagsEvents;
      for (var i = 0; i < tags.length; i++) {
        var event = events[i];
        var eventType = event.eventType;
        var observedPostTag = event.item;
        var expectedPostTag = postTags[i];
        expect(eventType, EventType.create);
        expect(observedPostTag, expectedPostTag);
      }
    });

    testWidgets('delete post (cascade delete associated postTag)',
        (WidgetTester tester) async {
      var deletedPost = posts[0];
      var deletedPostTags = postTags.getRange(0, 2).toList();

      if (enableCloudSync) {
        var postEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is Post) {
              return model.id == deletedPost.id && event.element.version == 2;
            }

            return false;
          },
        );

        var postTagsEventsGetter = deletedPostTags
            .map((postTag) => getExpectedSubscriptionDataProcessedEvent(
                  eventMatcher: (event) {
                    var model = event.element.model;
                    if (model is PostTags) {
                      return model.id == postTag.id &&
                          event.element.version == 2;
                    }

                    return false;
                  },
                ));

        var deleteModelsEvents = [postEventGetter];
        deleteModelsEvents.addAll(postTagsEventsGetter);

        await Amplify.DataStore.delete(deletedPost);

        var events = await Future.wait(deleteModelsEvents);

        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(deletedPost);
      }

      var queriedPosts = await Amplify.DataStore.query(Post.classType);
      expect(queriedPosts.length, posts.length - 1);

      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(
          queriedPostTags.indexWhere((postTag) => postTag.post == deletedPost),
          -1);
    });

    testWidgets('delete tag (cascade delete associated postTag)',
        (WidgetTester tester) async {
      var deletedTag = tags[1];
      var deletedPostTags = postTags.getRange(2, postTags.length).toList();

      if (enableCloudSync) {
        var tagEventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is Tag) {
              return model.id == deletedTag.id && event.element.version == 2;
            }

            return false;
          },
        );

        var postTagsEventsGetter = deletedPostTags
            .map((postTag) => getExpectedSubscriptionDataProcessedEvent(
                  eventMatcher: (event) {
                    var model = event.element.model;
                    if (model is PostTags) {
                      return model.id == postTag.id &&
                          event.element.version == 2;
                    }

                    return false;
                  },
                ));

        var deleteModelsEvents = [tagEventGetter];
        deleteModelsEvents.addAll(postTagsEventsGetter);

        await Amplify.DataStore.delete(deletedTag);

        var events = await Future.wait(deleteModelsEvents);

        events.forEach((event) {
          expect(event.element.deleted, isTrue);
        });
      } else {
        await Amplify.DataStore.delete(deletedTag);
      }

      var queriedTags = await Amplify.DataStore.query(Tag.classType);
      expect(queriedTags.length, tags.length - 1);

      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(queriedPostTags.indexWhere((postTag) => postTag.tag == deletedTag),
          -1);
    });

    testWidgets('delete remaining post', (WidgetTester tester) async {
      var deletedPost = posts[1];

      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is Post) {
              return model.id == deletedPost.id && event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedPost);

        var event = await eventGetter;
        expect(event.element.deleted, isTrue);
      } else {
        await Amplify.DataStore.delete(deletedPost);
      }

      var queriedPosts = await Amplify.DataStore.query(Post.classType);
      expect(queriedPosts, isEmpty);

      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(queriedPostTags, isEmpty);
    });

    testWidgets('delete remaining tag', (WidgetTester tester) async {
      var deletedTag = tags[0];

      if (enableCloudSync) {
        var eventGetter = getExpectedSubscriptionDataProcessedEvent(
          eventMatcher: (event) {
            var model = event.element.model;
            if (model is Tag) {
              return model.id == deletedTag.id && event.element.version == 2;
            }

            return false;
          },
        );

        await Amplify.DataStore.delete(deletedTag);

        var event = await eventGetter;
        expect(event.element.deleted, isTrue);
      } else {
        await Amplify.DataStore.delete(deletedTag);
      }

      var queriedTags = await Amplify.DataStore.query(Tag.classType);
      expect(queriedTags, isEmpty);

      var queriedPostTags = await Amplify.DataStore.query(PostTags.classType);
      expect(queriedPostTags, isEmpty);
    });
  });
}

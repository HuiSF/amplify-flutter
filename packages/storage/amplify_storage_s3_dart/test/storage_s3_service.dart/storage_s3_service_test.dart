// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:amplify_core/amplify_core.dart' hide PaginatedResult;
import 'package:amplify_storage_s3_dart/amplify_storage_s3_dart.dart';
import 'package:amplify_storage_s3_dart/src/sdk/s3.dart';
import 'package:amplify_storage_s3_dart/src/storage_s3_service/storage_s3_service.dart';
import 'package:built_collection/built_collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smithy/smithy.dart';
import 'package:test/test.dart';

import '../utils/mocks.dart';
import '../utils/test_token_provider.dart';

const testDelimiter = '#';

class TestPrefixResolver implements StorageS3PrefixResolver {
  @override
  Future<String> resolvePrefix({
    required StorageAccessLevel storageAccessLevel,
    String? identityId,
  }) async {
    if (identityId == 'throw exception for me') {
      throw Exception('elaborated exception');
    }

    return '${storageAccessLevel.defaultPrefix}$testDelimiter';
  }
}

void main() {
  group('StorageS3Service', () {
    const testBucket = 'bucket1';
    const testRegion = 'west-2';
    final testPrefixResolver = TestPrefixResolver();
    late DependencyManager dependencyManager;
    late S3Client s3Client;
    late StorageS3Service storageS3Service;
    late AWSLogger logger;

    setUpAll(() {
      registerFallbackValue(MockListObjectV2Request());
    });

    setUp(() {
      s3Client = MockS3Client();
      logger = MockAWSLogger();
      dependencyManager = DependencyManager()..addInstance<S3Client>(s3Client);
      storageS3Service = StorageS3Service(
        defaultBucket: testBucket,
        defaultRegion: testRegion,
        prefixResolver: testPrefixResolver,
        credentialsProvider: TestIamAuthProvider(),
        logger: logger,
        dependencyManagerOverride: dependencyManager,
      );
    });

    group('_getResolvedPrefix()', () {
      test(
          'should throw a StorageS3Exception if supplied prefix resolver throws an exception',
          () async {
        const testOptions = StorageS3ListOptions(
          storageAccessLevel: StorageAccessLevel.private,
          targetIdentityId: 'throw exception for me',
        );

        try {
          await storageS3Service.list(path: 'a path', options: testOptions);
        } on Object catch (error) {
          expect(error is StorageS3Exception, isTrue);
        }

        verify(() => logger.error(any(), any(), any())).called(1);
      });
    });

    group('list() API', () {
      var calledPageSize = 0;
      StorageS3ListResult? listResult;
      const testPageSize = 100;
      const testBucketName = 'a-bucket';
      const testStorageAccessLevel = StorageAccessLevel.private;
      const testHasNext = true;
      final testPrefixToDrop =
          '${testStorageAccessLevel.defaultPrefix}$testDelimiter';
      final testCommonPrefix = CommonPrefix(prefix: testPrefixToDrop);

      test('should invoke S3Client.listObjectsV2 with expected parameters',
          () async {
        final testS3Objects = [1, 2, 3, 4, 5].map(
          (e) => S3Object(
            key: '${testPrefixToDrop}object-$e',
            size: Int64(100 * 4),
            eTag: 'object-$e-eTag',
          ),
        );
        const testPath = 'album';
        const testTargetIdentityId = 'someone-else-id';
        const testOptions = StorageS3ListOptions(
          storageAccessLevel: testStorageAccessLevel,
          pageSize: testPageSize,
          targetIdentityId: testTargetIdentityId,
        );
        final testSecondPaginatedResult =
            PaginatedResult<ListObjectsV2Output, int>(
          ListObjectsV2Output(),
          hasNext: testHasNext,
          next: ([int? pageSize]) {
            throw UnimplementedError();
          },
        );
        final testPaginatedResult = PaginatedResult<ListObjectsV2Output, int>(
          ListObjectsV2Output(
            contents: BuiltList(testS3Objects),
            commonPrefixes: BuiltList([testCommonPrefix]),
            delimiter: testDelimiter,
            name: testBucketName,
            maxKeys: testPageSize,
          ),
          hasNext: testHasNext,
          next: ([int? pageSize]) async {
            if (pageSize != null) {
              calledPageSize = pageSize;
            }
            return testSecondPaginatedResult;
          },
        );

        when(
          () => s3Client.listObjectsV2(
            any(),
          ),
        ).thenAnswer(
          (_) => Future.value(testPaginatedResult),
        );

        listResult = await storageS3Service.list(
          path: testPath,
          options: testOptions,
        );

        final capturedRequest = verify(
          () => s3Client.listObjectsV2(
            captureAny<ListObjectsV2Request>(),
          ),
        ).captured.last;
        expect(capturedRequest is ListObjectsV2Request, isTrue);

        final request = capturedRequest as ListObjectsV2Request;
        expect(request.bucket, testBucket);
        expect(
          request.prefix,
          '${await testPrefixResolver.resolvePrefix(
            storageAccessLevel: testStorageAccessLevel,
            identityId: testTargetIdentityId,
          )}$testPath',
        );
        expect(request.maxKeys, testPageSize);
      });

      test('should return correct StorageS3ListResult', () async {
        expect(listResult, isNotNull);
        final result = listResult!;
        result.items.asMap().forEach((index, item) {
          expect(item.key, isNot(contains(testPrefixToDrop)));
          expect(item.key, 'object-${index + 1}');
        });
        expect(result.hasNext, testHasNext);

        final result2 = await result.next();
        expect(calledPageSize, testPageSize);
        expect(result2.next(), throwsA(isA<UnimplementedError>()));
      });

      test(
          'should throw StorageS3Exception when UnknownSmithHttpException is returned from service',
          () async {
        const testOptions = StorageS3ListOptions();
        const testUnknownException = UnknownSmithyHttpException(
          statusCode: 403,
          body: 'some exception',
        );

        when(
          () => s3Client.listObjectsV2(
            any(),
          ),
        ).thenThrow(testUnknownException);

        try {
          await storageS3Service.list(path: 'a path', options: testOptions);
        } on Object catch (error) {
          expect(error is StorageS3Exception, isTrue);
        }
      });
    });
  });
}

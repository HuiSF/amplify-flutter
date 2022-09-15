import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3_dart/amplify_storage_s3_dart.dart';
import 'package:amplify_storage_s3_dart/src/sdk/s3.dart';
import 'package:amplify_storage_s3_dart/src/storage_s3_service/storage_s3_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageS3Service extends Mock implements StorageS3Service {}

class MockStorageS3ListOptions extends Mock implements StorageS3ListOptions {}

class MockS3Client extends Mock implements S3Client {}

class MockAWSLogger extends Mock implements AWSLogger {}

class MockListObjectV2Request extends Mock implements ListObjectsV2Request {}

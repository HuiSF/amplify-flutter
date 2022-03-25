#!/bin/sh
# flutter test integration_test/model_relationship_test/has_one_implicit_child_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/has_one_explicit_child_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/belongs_to_implicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/belongs_to_explicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/has_many_implicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/has_many_explicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/has_many_bidirectional_implicit_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/has_many_bidirectional_explicit_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/many_to_many_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk
# flutter test integration_test/model_relationship_test/multi_relationship_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d sdk

# flutter test integration_test/model_relationship_test/has_one_implicit_child_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/has_one_explicit_child_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/belongs_to_implicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/belongs_to_explicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/has_many_implicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/has_many_explicit_parent_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/has_many_bidirectional_implicit_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/has_many_bidirectional_explicit_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/many_to_many_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
# flutter test integration_test/model_relationship_test/multi_relationship_test.dart --no-pub --dart-define ENABLE_CLOUD_SYNC=true -d iPhone
TEST_ENTRIES=`ls integration_test/separate_integration_tests/*.dart`
DEFAULT_DEVICE_ID="sdk"
DEFAULT_ENABLE_CLOUD_SYNC="true"

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--device-id)
            deviceId="$2"
            ;;
        -ec|--enable-cloud-sync)
            case "$2" in
                true|false)
                    enableCloudSync="$2"
                ;;
                *)
                    echo "Invalid value for $1"
                    exit 1
            esac
            ;;
        *)
            echo "Invalid arguments"
            exit 1
    esac
    shift
    shift
done

deviceId=${deviceId:-$DEFAULT_DEVICE_ID}
enableCloudSync=${enableCloudSync:-$DEFAULT_ENABLE_CLOUD_SYNC}
echo $deviceId
if [ $enableCloudSync == "true" ]
then
    echo "Run $ENTRY WITH API Sync"
else
    echo "Run $ENTRY WITHOUT API Sync"
fi
# echo "Run tests in iOS platform"
# for ENTRY in $TEST_ENTRIES
# do
#     flutter test \
#         --no-pub \
#         --dart-define ENABLE_CLOUD_SYNC=true \
#         -d iPhone \
#         $ENTRY
# done

# echo "Run tests in Android platform"
# for ENTRY in $TEST_ENTRIES
# do
#     flutter test \
#         --no-pub \
#         --dart-define ENABLE_CLOUD_SYNC=true \
#         -d sdk \
#         $ENTRY
# done

declare -a array
array+=(10)
array+=(20)
array+=(30)

for i in "${!array[@]}"; do
    echo "${array[i]}"
    if [ "${array[i]}" == 20 ]
    then
        echo "✅ ${array[i]}"
    else
        testFailure=1
        echo "❌ ${array[i]}"
    fi
done

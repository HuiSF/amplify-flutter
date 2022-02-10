#!/bin/bash

if [ ! -d android ]; then
    echo "No Android project to test" >&2
    exit
fi

TARGET=integration_test/main_test.dart
if [ ! -e $TARGET ]; then
    echo "$TARGET file not found" >&2
    exit
fi

flutter test \
    --no-pub \
    -d sdk \
    $TARGET

TEST_ENTRIES=`ls integration_test/separate_integration_tests/*.dart`
for ENTRY in $TEST_ENTRIES
do
    echo "Run $ENTRY WITH API Sync"
    flutter test \
        --no-pub \
        --dart-define ENABLE_CLOUD_SYNC=true \
        -d sdk \
        $ENTRY
done

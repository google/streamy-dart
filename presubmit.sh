#!/bin/bash

# Run this script before sending code for review.

set -x
set -e

# Build everything
pub get
pub build test --mode=debug

# Check for compiler warnings
ANALYZE_CMD="dartanalyzer build/test/all_tests.dart"
WARNING_COUNT=`${ANALYZE_CMD} | grep -ci warning || echo ''`

if [ ${WARNING_COUNT} -gt 0 ]
then
  echo 'Code contains compiler warnings'
  ${ANALYZE_CMD}
  exit 1
fi

# Run unit tests
dart -c --package-root=build/test/packages \
  build/test/all_tests.dart

# Run integration tests
test/integration/run_tests.sh

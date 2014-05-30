#!/bin/bash

# Run this script before sending code for review.

set -x
set -e
pub get

# Run unit tests
pub build test --mode=debug
dart -c --package-root=build/test/packages \
  build/test/all_tests.dart

# Run integration tests
test/integration/run_tests.sh

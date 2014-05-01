#!/bin/bash
set -x
set -e

# Run unit tests
dart -c test/all_tests.dart

# Run integration tests
integration/run_tests.sh

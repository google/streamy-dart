#!/bin/bash
set -x
set -e

# Run apigen test
dart -c bin/apigen.dart \
  --config=test/generated/bank_api_test.streamy.yaml \
  --output-dir=test/integration \
  --package-name=bankapi \
  --package-version=0.0.0 \
  --local-streamy-location=../../..

# NOTE: The (cmd1 && cmd2 && ...) trick doesn't work because it
#       does not exist on error. Have to cd in and out explicitly.
cd test/integration/apigen_test
pub get
pub build bin --mode=debug
dart -c --package-root=build/bin/packages build/bin/main.dart
cd ../../..

# Run transformer test
cd test/integration/transformer_test
pub get
pub build bin --mode=debug
dart -c --package-root=build/bin/packages build/bin/main.dart
cd ../../..

echo 'SUCCESS'

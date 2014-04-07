#!/bin/bash -x -e

# Run apigen test
set +e
mkdir integration/bankapi
set -e
dart -c bin/apigen.dart \
  --client-file-name=bankapi \
  --discovery-file=test/generated/bank_api_test.json \
  --output-dir=integration/bankapi \
  --local-streamy-location=../..

(cd integration/apigen_test && \
  pub get && \
  dart -c bin/main.dart)

# Run transformer test
(cd integration/transformer_test && \
  pub get && \
  pub build --mode debug bin && \
  dart -c --package-root=build/bin/packages bin/main.dart)

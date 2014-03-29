#!/bin/bash -x

# Run apigen test
mkdir integration/bankapi
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
  pub build bin && \
  dart -c --package-root=build bin/main.dart)

# Helper script to get a VM, like the one provided in Cloud 9, to work with
# Streamy. It installs the Dart SDK and sets up environment variables to use.
#
# Usage:
# ./c9.sh
#
# Flags:
# --skip-install: Just configures the environment and outputs SDK versions.
if [ "$1" != '--skip-install' ]; then
  # Install Dart.
  echo "Downloading the latest Dart SDK"

  # Enable HTTPS for apt.
  sudo apt-get update
  sudo apt-get install apt-transport-https

  # Get the Google Linux package signing key.
  sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'

  # Set up the location of the stable repository.
  sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

  echo "Updating Dart SDK"
  sudo apt-get update
  sudo apt-get install dart
fi

echo "Configurating environment variables for Dart"
export PATH=$PATH:/usr/lib/dart/bin

dart --version
pub --version

echo "Done."

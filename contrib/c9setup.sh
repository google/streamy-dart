# Use this script to bootstrap your Cloud9 environment. This script:
#  - Tests SSH connection to GitHub
#  - Upgrades to the latest Dart SDK

set +e
echo "Testing connection to GitHub"
ssh -T "git@github.com"
SSH_RETURN_CODE=$?
set -e

# Because GitHub doesn't allow shell access the return code is 1 for success
# and (afaik) 255 for failure.
[ $SSH_RETURN_CODE -ne 1 ] && echo "Connection to GitHub failed" && exit 1

echo "Downloading the latest Dart SDK"
rm -f "./dartsdk-linux-64.tar.gz"
wget --tries=3 "http://storage.googleapis.com/dart-editor-archive-integration/latest/dartsdk-linux-64.tar.gz"

echo "Updating Dart SDK"
rm -Rf ./dart-sdk
tar -zxvf "./dartsdk-linux-64.tar.gz"

echo "Make sure" `git config user.email` "is registered in your GitHub's Account Settings > Emails."
echo "Make sure" `git config user.name` "is your GitHub user account name."
echo "Make sure to add your Cloud9 SSH key to your GitHub's Account Settings > SSH Keys, which you can find on your Cloud9 Dashboard (look for 'Show your SSH key'."
echo "Done."

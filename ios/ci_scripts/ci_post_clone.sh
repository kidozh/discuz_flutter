#!/bin/sh

set -eu

FLUTTER_VERSION="3.47.2"
EXPECTED_XCODE_VERSION="26.6"
FLUTTER_SDK_PATH="$HOME/flutter-$FLUTTER_VERSION"

export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PATH="$PATH:$FLUTTER_SDK_PATH/bin"
export HOMEBREW_NO_AUTO_UPDATE=1

cd "$CI_PRIMARY_REPOSITORY_PATH"

actual_xcode_version=$(xcodebuild -version | awk 'NR == 1 { print $2 }')
echo "Xcode Cloud Xcode: $actual_xcode_version"
if [ "$actual_xcode_version" != "$EXPECTED_XCODE_VERSION" ]; then
  echo "error: Xcode Cloud must use Xcode $EXPECTED_XCODE_VERSION; selected $actual_xcode_version. Update the workflow Environment in App Store Connect."
  exit 1
fi

if [ ! -x "$FLUTTER_SDK_PATH/bin/flutter" ]; then
  git clone \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git \
    "$FLUTTER_SDK_PATH"
fi

flutter --version
flutter precache --ios
flutter pub get --enforce-lockfile

app_version=$(awk '$1 == "version:" { print $2; exit }' pubspec.yaml)
app_build_name=${app_version%%+*}
app_build_number=${app_version#*+}
if [ -z "$app_build_name" ] || [ "$app_build_number" = "$app_version" ]; then
  echo "error: pubspec.yaml version must use <version>+<build>, for example 2.0.0+155."
  exit 1
fi

echo "Configuring Xcode archive version $app_build_name ($app_build_number)"
flutter build ios \
  --config-only \
  --release \
  --no-pub \
  --build-name="$app_build_name" \
  --build-number="$app_build_number"

if ! command -v pod >/dev/null 2>&1; then
  brew install cocoapods
fi

cd ios
pod install

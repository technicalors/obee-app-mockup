#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# All flavors already select AppIcon. Run 0.14.4 against a disposable project
# so its unrelated ASSETCATALOG edits never touch the project open in Xcode.
source_dir="$PWD"
icon_workspace="$(mktemp -d)"
trap 'rm -rf "$icon_workspace"' EXIT

for entry in pubspec.yaml pubspec.lock .fvmrc flutter_launcher_icons.yaml; do
  cp "$entry" "$icon_workspace/$entry"
done
mkdir -p "$icon_workspace/.dart_tool" "$icon_workspace/android/app/src/main" \
  "$icon_workspace/ios/Runner" "$icon_workspace/ios/Runner.xcodeproj"
# A linked .dart_tool can resolve the app back to the live project during
# implicit pub get. Copy its package metadata so the temporary app stays local.
cp .dart_tool/package_config.json .dart_tool/package_graph.json \
  "$icon_workspace/.dart_tool/"
ln -s "$source_dir/assets" "$icon_workspace/assets"
ln -s "$source_dir/android/app/src/main/res" \
  "$icon_workspace/android/app/src/main/res"
cp android/app/src/main/AndroidManifest.xml "$icon_workspace/android/app/src/main/"
cp ios/Runner.xcodeproj/project.pbxproj "$icon_workspace/ios/Runner.xcodeproj/"
ln -s "$source_dir/ios/Runner/Assets.xcassets" \
  "$icon_workspace/ios/Runner/Assets.xcassets"

cd "$icon_workspace"
fvm dart run flutter_launcher_icons

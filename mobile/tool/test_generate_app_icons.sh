#!/usr/bin/env bash
set -euo pipefail

tool_dir="$(cd "$(dirname "$0")" && pwd)"
test_workspace="$(mktemp -d)"
trap 'rm -rf "$test_workspace"' EXIT

fixture="$test_workspace/mobile with spaces"
mkdir -p "$fixture/tool" "$fixture/android/app/src/main/res" "$fixture/assets" \
  "$fixture/.dart_tool" "$fixture/ios/Runner/Assets.xcassets" \
  "$fixture/ios/Runner.xcodeproj" "$test_workspace/bin"
cp "$tool_dir/generate_app_icons.sh" "$fixture/tool/"
printf 'fixture manifest\n' > "$fixture/android/app/src/main/AndroidManifest.xml"
for entry in pubspec.yaml pubspec.lock .fvmrc flutter_launcher_icons.yaml; do
  printf 'fixture\n' > "$fixture/$entry"
done
for entry in package_config.json package_graph.json; do
  printf 'fixture\n' > "$fixture/.dart_tool/$entry"
done

# Mock the generator's project rewrite and an independent Xcode save to the
# live project. Native output must still land in the real asset directories.
cat > "$test_workspace/bin/fvm" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ "$*" == "dart run flutter_launcher_icons" ]]
[[ "$PWD" != "$ICON_TEST_SOURCE" ]]
[[ ! -L ios/Runner.xcodeproj/project.pbxproj ]]
[[ ! -L .dart_tool ]]
[[ -f .dart_tool/package_config.json && -f .dart_tool/package_graph.json ]]
grep -q 'original project' ios/Runner.xcodeproj/project.pbxproj
printf 'generator project rewrite\n' > ios/Runner.xcodeproj/project.pbxproj
printf 'saved in Xcode during generation\n' \
  > "$ICON_TEST_SOURCE/ios/Runner.xcodeproj/project.pbxproj"
printf 'generated Android icon\n' > android/app/src/main/res/generated-icon
printf 'generated iOS icon\n' > ios/Runner/Assets.xcassets/generated-icon
printf '%s' "$PWD" > "$ICON_TEST_SOURCE/last-generator-workspace"
exit "$ICON_TEST_EXIT_CODE"
MOCK
chmod +x "$test_workspace/bin/fvm"

for generator_exit in 0 7; do
  printf 'original project\n' > "$fixture/ios/Runner.xcodeproj/project.pbxproj"
  result=0
  PATH="$test_workspace/bin:$PATH" \
    ICON_TEST_SOURCE="$fixture" ICON_TEST_EXIT_CODE="$generator_exit" \
    bash "$fixture/tool/generate_app_icons.sh" || result=$?

  [[ "$result" == "$generator_exit" ]]
  [[ "$(cat "$fixture/ios/Runner.xcodeproj/project.pbxproj")" \
    == 'saved in Xcode during generation' ]]
  [[ "$(cat "$fixture/android/app/src/main/res/generated-icon")" == 'generated Android icon' ]]
  [[ "$(cat "$fixture/ios/Runner/Assets.xcassets/generated-icon")" == 'generated iOS icon' ]]
  [[ ! -e "$(cat "$fixture/last-generator-workspace")" ]]
  printf 'PASS: generator exit %s preserves Xcode saves and cleans its workspace\n' \
    "$generator_exit"
done

# Obee Mobile

Android and iOS clients using the current web API contracts. Flutter is pinned
to `3.44.1` in `.fvmrc`; use FVM from this directory.

## Setup and environments

```bash
fvm install
fvm flutter pub get
cp env/dev.json.example env/dev.json
fvm flutter run --flavor dev --dart-define-from-file=env/dev.json
```

Each environment requires `OBEE_ENV` (`dev`, `staging`, `prod`),
`OBEE_API_BASE_URL` ending in `/api`, and `OBEE_APP_BASE_URL` containing the
public origin for asset URLs. Flutter flavor and `OBEE_ENV` must match.
Staging/prod require HTTPS. Replace sample staging/prod hostnames before use;
environment JSON files are ignored by Git. Dart defines are bundled into the
app and must never contain passwords or signing secrets.

## iOS setup

iOS builds target iOS 15 or later and require macOS, Xcode, and an installed
iOS Simulator runtime. Select Xcode's command-line tools and complete first-run
setup:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
fvm flutter doctor -v
env -u DEVELOPER_DIR xcode-select -p
```

The last command must report Xcode's `Contents/Developer`, not
`/Library/Developer/CommandLineTools`. Dart build hooks filter `DEVELOPER_DIR`,
so setting that variable in the shell does not replace selecting Xcode globally.

Install a simulator runtime in Xcode's Settings > Platforms, then from
`mobile/` run:

```bash
fvm flutter devices
fvm flutter run -d <simulator-id> --flavor dev --dart-define-from-file=env/dev.json
```

The shared Xcode schemes are `dev`, `staging`, and `prod`, matching the Android
flavors and `OBEE_ENV`. The runner permits local `.local` networking for the
`http://obee.local` example and asks for location access only while the app is
in use for attendance. Running on a physical device requires selecting an
Apple development team in Xcode; simulator builds do not require signing.
Keychain capability is configured for every flavor and build mode; session
storage is checked by the native integration test below.

Before building directly in Xcode, generate configuration for the intended
flavor and open `ios/Runner.xcworkspace`:

```bash
fvm flutter build ios --config-only --no-codesign --flavor dev --dart-define-from-file=env/dev.json
```

Select the matching scheme in Xcode. Repeat the config command with the matching
flavor and environment file when switching to staging or prod; all schemes read
the generated Flutter configuration, which retains the last command's defines.
On this Xcode 27 setup, the pinned Flutter SDK's generic simulator build fails
while verifying a universal framework with `lipo`; targeting a simulator through
`flutter run -d <simulator-id>` builds its native architecture successfully.

Dev/staging have separate Android and iOS application IDs, display names and
token namespaces. Existing installations must log in again after the token-key
change. Backup excludes tokens. Native auth uses Sanctum bearer tokens through
`/mobile/auth/*`; feature calls use the same routes and DTOs as web.

## App icons

Android and iOS use the Obee bee-and-circle icon on a white background. The
`dev`, `staging`, and `prod` flavors share the same icon; their display names
identify the environment.

The committed 1024 × 1024 PNG inputs are in `assets/app_icon/`:

- `app_icon.png`: opaque white background with the mark centered in an 840 × 840
  area, used for iOS and legacy Android icons. The OS applies the corner mask.
- `foreground.png`: the colored mark on a transparent canvas for Android
  adaptive icons.
- `monochrome.png`: a black alpha mask derived from the supplied monochrome
  artwork for Android themed icons.

The supplied `obee-icons` SVG exports contain embedded PNG artwork rather than
vector paths. The PNG inputs retain that artwork and are stored inside this
repository so icon generation does not depend on an adjacent directory. They
are build inputs, not additional Flutter runtime assets.

`flutter_launcher_icons.yaml` configures the shared icons. Its 20% inset on each
side keeps Android's foreground and monochrome layers within the central
66/108 safe zone; the white background fills the launcher mask. iOS icons have
no alpha channel.

After replacing an input image or changing the icon configuration, run from
`mobile/`:

```bash
fvm flutter pub get
bash tool/generate_app_icons.sh
```

The script runs the generator against a temporary copy of `project.pbxproj`:
`flutter_launcher_icons` 0.14.4 otherwise rewrites unrelated `ASSETCATALOG`
build settings. Asset directories point to this repository, so the generated
icons update here while the live Xcode project is never written or restored.
Every flavor already selects the shared `AppIcon` asset catalog.

Check the script's concurrent-save and generator-failure handling with
`bash tool/test_generate_app_icons.sh`.

Commit the input PNGs, icon configuration, dependency lockfile and generated
resources under `android/app/src/main/res/` and
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`. Regenerate icons only when the
inputs or configuration change. Rebuild and reinstall the app to see the icon;
hot reload does not update native launcher resources. Check iOS Home Screen
and Android circular/adaptive masks and themed icons.

## Verification

```bash
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart format --output=none --set-exit-if-changed lib test integration_test
fvm flutter analyze
fvm flutter test
fvm flutter test integration_test/session_storage_test.dart -d emulator-5554 --flavor dev --dart-define-from-file=env/dev.json
fvm flutter build apk --debug --flavor dev --target-platform android-x64 --dart-define-from-file=env/dev.json
fvm flutter test integration_test/session_storage_test.dart -d <simulator-id> --flavor dev --dart-define-from-file=env/dev.json
```

Use `android-arm64` for most physical devices. CI checks generated code,
formatting, analysis and unit/widget tests. APK builds are verified locally with
the commands above; CI does not build APKs or provision Java/Gradle.

The `flutter` CI job runs all checks and uses two concurrent test
processes: Flutter's default on a two-core runner is only one. Test discovery
and assertions remain unchanged. Dart caching is limited to the `build_runner`
compiler entrypoint and Flutter's incremental test compiler snapshot, keyed by
OS, architecture, pinned SDK, lockfile and builder configuration. Generated models
are regenerated with a fresh build graph and checked for differences on every
run; the full test suite and the separate timezone checks always execute.
The `mobile-test-results` artifact retains JSON test events and timings for seven
days, including failed runs. Compare CI step durations after a cache has been
populated; the first run still pays the cold compilation cost. Increment the
`mobile-compile-v1` cache prefix in the workflow to discard Dart compiler caches.

## Release signing

Copy `android/key.properties.example` to `android/key.properties` and populate
it with the real keystore path and credentials. Keep both properties and
keystore outside version control. Release builds fail if signing configuration
is absent; the debug key is no longer used for release.

```bash
fvm flutter build appbundle --release --flavor prod --dart-define-from-file=env/prod.json
```

## Current scope

Existing login, attendance, schedule and profile flows are connected to the
backend. Employees may edit name and the personal fields of their provisioned
profile via `/profile`; employment and authorization fields remain administered.
User snapshots use `organization_id` and `organization`; authenticated snapshots
also include nullable `root_organization_id`. Schedule selection loads
`/users/tree?root_organization_id=...` and renders the full organization parent
chain, including users assigned directly to the root. Attendance locations expose
`organizations` for their access assignments.
Mobile tokens expire after 30 days and password changes revoke them. HTTP 401
ends the current session and clears feature state. Business dates/times follow
`Asia/Ho_Chi_Minh`; date-only values remain date-only.

Authorization stays on the backend. The opaque Sanctum token identifies the
session; its `mobile` ability is not a snapshot of the user's roles or permissions.
Login returns the initial user snapshot, and `/mobile/auth/user` returns the
current roles and permissions from the database. Mobile refreshes this snapshot
on session restore, on return to the foreground, on calendar pull-to-refresh,
and after an authenticated feature request returns HTTP 403. A 403 keeps the
session and is shown by the feature; the rejected operation is not replayed.
Concurrent snapshot refreshes share one request, and responses from an old
session cannot replace the current user. A refresh network failure keeps the
session and reports the error; only a 401 expires it. Without a refresh trigger,
the displayed capabilities remain the last server snapshot. Every protected
operation is still authorized by the backend using the current database state.

Chat is still a prototype. Notifications, leave management, push and live chat
are separate feature work. The iOS runner supports development builds; Apple
signing and store distribution setup remain specific to the target team/account.

Location implementations remain direct dependencies to avoid unused desktop
plugins. The Android implementation stays pinned to `5.0.2`; its next major
requires a separate native permission review. Gradle configuration cache remains
disabled because the current Flutter tasks are incompatible with it.

If a local build stalls while Kotlin searches for a stale daemon, retry with
`env 'ORG_GRADLE_PROJECT_kotlin.compiler.execution.strategy=in-process' fvm flutter build ...`.
Local Android build verification passed with Temurin 25.
The Gradle launchers enable native access for Gradle's JNI library on newer JDKs.
Android plugin Java 8 targets are preserved; only javac's obsolete source/target
option warnings are suppressed. The `geolocator_android` deprecated API note
comes from plugin source and can still appear on recompilation.

References: [Flutter flavors](https://docs.flutter.dev/deployment/flavors),
[secure storage](https://pub.dev/packages/flutter_secure_storage),
[integration tests](https://docs.flutter.dev/testing/integration-tests).

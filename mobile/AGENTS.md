# Flutter Mobile

Apply the root instructions. Run commands from `mobile/` using `fvm flutter` and `fvm dart`; `.fvmrc` pins the SDK. See `README.md` for flavors, environment setup, signing, device checks, and feature scope.

## Conventions

- Keep app wiring in `lib/src/app/`, shared capabilities in `lib/src/core/`, and features in `lib/src/features/<feature>/{data,state,logic,ui}/` as needed. Reuse `lib/src/app/router.dart`; do not relocate code to match skill examples.
- Use Riverpod for state/DI, `go_router` for navigation, and the shared Dio `ApiClient`. Keep API/DTOs in `data/` and orchestration in `state/`.
- Preserve Sanctum bearer tokens and environment-scoped secure storage. The base URL ends in `/api`; request paths must not add it again.
- Follow Freezed/`json_serializable` patterns; regenerate committed models from source and never hand-edit generated output.
- For dependency changes, review the resolved graph, run `fvm flutter pub get`, and include any resulting `pubspec.lock` changes. For CI changes, follow the existing `.github/workflows/mobile.yml` at the repository root and keep its SDK aligned with `.fvmrc`.
- Use `core/time/business_time.dart` for `Asia/Ho_Chi_Minh` business time; preserve date-only values.
- Keep user-facing copy Vietnamese. When migrating a screen to generated localizations, group ARB keys by feature and put new copy/validation messages there. The app does not yet generate `AppLocalizations`.

## Skills

Select the relevant skills from `../.agents/skills/`:

| Task                                      | Skills                                                    |
| ----------------------------------------- | --------------------------------------------------------- |
| Screens/widgets; adaptive layout/overflow | `widget-composition`; `adaptive-layout`                   |
| State/DI; routes/guards/deep links        | `state-management-riverpod`; `navigation-and-routing`     |
| Forms/focus/keyboard; native/side effects | `forms-and-input`; `service-boundary-and-native`          |
| Performance                               | `flutter-performance`                                     |
| Unit tests, test design, fakes, state     | `testing-strategy`                                        |
| Widget; device integration tests          | `flutter-add-widget-test`; `flutter-add-integration-test` |
| Codegen, analyzer, SDK pinning            | `codegen-and-toolchain`                                   |

Use hand-written fakes for owned dependencies, following `testing-strategy`. Keep device tests on `integration_test` with `IntegrationTestWidgetsFlutterBinding`; add Flutter Driver only when explicitly required. Skill guidance does not require unrelated packages, storage engines, directory migrations, or gates.

## Verification

- Test changed logic/state without widgets where possible; use widget tests for UI and device tests for native/cross-screen behavior when needed. Responsive fixes need a narrow-width case; use semantic `ValueKey`s for tested inputs/actions.
- When generator inputs change, run `fvm dart run build_runner build --delete-conflicting-outputs` before analysis.
- For Dart/mobile configuration changes, run:

  ```bash
  fvm dart format --output=none --set-exit-if-changed lib test integration_test
  fvm flutter analyze
  fvm flutter test
  ```

- Run affected `integration_test/` tests separately with device/flavor/environment arguments from `README.md`; the default test command excludes them. Documentation-only changes follow root verification rules.

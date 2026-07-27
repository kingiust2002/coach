# Quality Gates

## Supported toolchain

- Flutter: `3.32.6`
- Dart: version bundled with Flutter 3.32.6
- Android and iOS platform projects are committed to the repository.
- `pubspec.lock` is committed and generated with the supported toolchain.

## Required checks

Every change must pass:

1. `flutter pub get`
2. `dart format --output=none --set-exit-if-changed lib test`
3. `flutter analyze --no-fatal-infos`
4. `flutter test`
5. `flutter build apk --debug`
6. `flutter build ios --debug --no-codesign`

## Compatibility policy

- Production code must not use APIs introduced after Flutter 3.32 while FlutLab remains on the 3.32 line.
- SDK upgrades are explicit migrations and must update `.flutter-version`, `pubspec.yaml`, CI, platform projects and tests together.
- Dependency updates must preserve the lockfile and pass all required checks.
- Signing keys, passwords, provisioning profiles and credentials must never be committed.

# FlutLab development signing

The repository contains `android/coach-flutlab-dev.jks`, a public development-only Android signing key.

Its purpose is deterministic signing for debug and fallback release APKs created by newly imported FlutLab workspaces. Android accepts an in-place update only when the application ID and signing certificate match and the new version code is not lower.

## Development update path

- Application ID: `com.kingiust.coach`
- Development alias: `coach-flutlab-dev`
- Development keystore: `android/coach-flutlab-dev.jks`
- The Gradle configuration signs both debug builds and unsigned fallback release builds with this key.
- Every installable revision must increment the `+versionCode` suffix in `pubspec.yaml`.

An APK signed by an older FlutLab workspace or another keystore cannot be updated by this development key. That transition requires one uninstall and reinstall. After the first installation signed by this repository key, later FlutLab imports can update it without deleting application data.

## Production warning

This development key is intentionally public and must not be used for Play Store or production distribution. Production builds override it by supplying a private `android/key.properties` and private keystore. Never commit the private production keystore.

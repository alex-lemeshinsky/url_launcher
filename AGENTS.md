# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter app for saving titled URLs and opening them externally. App code lives in `lib/`: `screens/` contains the home and add/edit views, `widgets/` holds shared UI, `providers/db_provider.dart` manages the Hive box, `models/` defines stored items, and `functions/` handles URL launching. The end-to-end test is `integration_test/app_test.dart`; there is no `test/` directory yet. Platform projects are in `android/` and `ios/`. The source icon is `assets/app-icon.png`.

## Build, Test, and Development Commands

- `flutter pub get`: install dependencies from `pubspec.yaml`.
- `flutter run`: launch the app on a connected device or emulator.
- `flutter analyze`: run the configured `flutter_lints` checks.
- `dart format lib integration_test`: format Dart source and tests.
- `flutter test integration_test/app_test.dart`: run the add, validation, edit, delete, and persistence flow on a device or emulator.
- `dart run build_runner build --delete-conflicting-outputs`: regenerate Hive adapters after model changes.

Use `flutter build apk` or `flutter build ios` when checking a release build for the relevant platform. iOS plugin integration uses Swift Package Manager.

## Coding Style & Naming Conventions

Use standard Dart formatting (two-space indentation), `lower_snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Keep UI in screens/widgets and persistence in `DbProvider`. Import app files with `package:url_launcher_app/...`. Do not edit `lib/models/item.g.dart` or `lib/hive_registrar.g.dart` manually. Preserve existing `@HiveField` numbers so stored data remains readable.

## Testing Guidelines

Use `flutter_test` and `integration_test`; name new tests `*_test.dart` and describe the user behavior they verify. Run `flutter analyze` and the relevant tests before a PR. No coverage threshold is configured. The integration test clears the `URLBox` Hive box at startup, so run it only on a device whose saved app data can be replaced.

## Commit & Pull Request Guidelines

Recent commits use short, imperative, sentence-case subjects such as `Add app features` and `Upgrade to Flutter 3.47 and latest packages`. Follow that pattern and keep each commit focused. PRs should explain the behavior changed, list verification commands and results, link a related issue when one exists, and include screenshots for visible UI changes.
